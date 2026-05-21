#include "include/flutter_volume_controller/alsa.h"

#include <alsa/asoundlib.h>
#include <glib.h>

#include <algorithm>
#include <cmath>
#include <cstdlib>

namespace {

constexpr char kDefaultCardName[] = "(default)";
constexpr char kDefaultDeviceName[] = "default";
constexpr guint kWatchIntervalMs = 100;
constexpr double kVolumeChangeEpsilon = 0.0001;

const char *const kPreferredElements[] = {
        "Master",
        "PCM",
        "Speaker",
        "Headphone",
        nullptr,
};

struct MixerSnapshot {
    double volume = 0;
    gboolean muted = FALSE;
};

void log_alsa_error(const char *operation, int error) {
    g_warning("ALSA %s failed: %s", operation, snd_strerror(error));
}

double clamp_volume(double value) {
    if (!std::isfinite(value)) {
        return 0;
    }

    return std::max(0.0, std::min(1.0, value));
}

bool is_default_card_name(const char *card_name) {
    return card_name == nullptr || card_name[0] == '\0' ||
           g_strcmp0(card_name, kDefaultCardName) == 0 ||
           g_strcmp0(card_name, kDefaultDeviceName) == 0;
}

gchar *resolve_device_name(const char *card_name) {
    if (is_default_card_name(card_name)) {
        return g_strdup(kDefaultDeviceName);
    }

    if (g_str_has_prefix(card_name, "hw:") ||
        g_str_has_prefix(card_name, "plughw:") ||
        g_str_has_prefix(card_name, "sysdefault") ||
        g_str_has_prefix(card_name, "default")) {
        return g_strdup(card_name);
    }

    int card_index = -1;
    while (true) {
        const int next_result = snd_card_next(&card_index);
        if (next_result < 0) {
            log_alsa_error("card enumeration", next_result);
            break;
        }

        if (card_index < 0) {
            break;
        }

        char *alsa_name = nullptr;
        const int name_result = snd_card_get_name(card_index, &alsa_name);
        if (name_result < 0) {
            log_alsa_error("card name lookup", name_result);
            continue;
        }

        const bool matches = g_strcmp0(alsa_name, card_name) == 0;
        free(alsa_name);

        if (matches) {
            return g_strdup_printf("hw:%d", card_index);
        }
    }

    return g_strdup(card_name);
}

snd_mixer_t *open_mixer(const char *device_name) {
    snd_mixer_t *mixer = nullptr;

    int result = snd_mixer_open(&mixer, 0);
    if (result < 0) {
        log_alsa_error("mixer open", result);
        return nullptr;
    }

    result = snd_mixer_attach(mixer, device_name);
    if (result < 0) {
        log_alsa_error("mixer attach", result);
        snd_mixer_close(mixer);
        return nullptr;
    }

    result = snd_mixer_selem_register(mixer, nullptr, nullptr);
    if (result < 0) {
        log_alsa_error("simple element registration", result);
        snd_mixer_close(mixer);
        return nullptr;
    }

    result = snd_mixer_load(mixer);
    if (result < 0) {
        log_alsa_error("mixer load", result);
        snd_mixer_close(mixer);
        return nullptr;
    }

    return mixer;
}

bool has_playback_volume(snd_mixer_elem_t *element) {
    return element != nullptr && snd_mixer_selem_is_active(element) &&
           snd_mixer_selem_has_playback_volume(element);
}

snd_mixer_elem_t *find_playback_element_by_name(snd_mixer_t *mixer,
                                                const char *name) {
    if (mixer == nullptr || name == nullptr || name[0] == '\0') {
        return nullptr;
    }

    snd_mixer_selem_id_t *element_id = nullptr;
    snd_mixer_selem_id_alloca(&element_id);
    snd_mixer_selem_id_set_index(element_id, 0);
    snd_mixer_selem_id_set_name(element_id, name);

    snd_mixer_elem_t *element = snd_mixer_find_selem(mixer, element_id);
    return has_playback_volume(element) ? element : nullptr;
}

snd_mixer_elem_t *find_first_playback_element(snd_mixer_t *mixer) {
    if (mixer == nullptr) {
        return nullptr;
    }

    for (const char *const *name = kPreferredElements; *name != nullptr; ++name) {
        snd_mixer_elem_t *element = find_playback_element_by_name(mixer, *name);
        if (element != nullptr) {
            return element;
        }
    }

    for (snd_mixer_elem_t *element = snd_mixer_first_elem(mixer);
         element != nullptr;
         element = snd_mixer_elem_next(element)) {
        if (has_playback_volume(element)) {
            return element;
        }
    }

    return nullptr;
}

bool first_playback_channel(snd_mixer_elem_t *element,
                            snd_mixer_selem_channel_id_t *channel) {
    if (element == nullptr || channel == nullptr) {
        return false;
    }

    for (int index = 0; index < 32; ++index) {
        const auto candidate = static_cast<snd_mixer_selem_channel_id_t>(index);
        if (snd_mixer_selem_has_playback_channel(element, candidate)) {
            *channel = candidate;
            return true;
        }
    }

    return false;
}

bool playback_volume_range(snd_mixer_elem_t *element, long *min, long *max) {
    if (element == nullptr || min == nullptr || max == nullptr) {
        return false;
    }

    const int result = snd_mixer_selem_get_playback_volume_range(element, min, max);
    if (result < 0) {
        log_alsa_error("volume range read", result);
        return false;
    }

    if (*max <= *min) {
        g_warning("ALSA playback volume range is invalid: [%ld, %ld]", *min, *max);
        return false;
    }

    return true;
}

long normalized_to_raw_volume(double volume, long min, long max, int dir) {
    const double raw = static_cast<double>(min) + clamp_volume(volume) *
            static_cast<double>(max - min);

    if (dir > 0) {
        return static_cast<long>(std::ceil(raw));
    }

    if (dir < 0) {
        return static_cast<long>(std::floor(raw));
    }

    return static_cast<long>(std::lround(raw));
}

bool read_snapshot(AlsaCard *card, MixerSnapshot *snapshot);
void notify_values_changed(AlsaCard *card);
void remember_snapshot(AlsaCard *card);

}  // namespace

struct alsa_card {
    char *name;
    char *device;
    char *channel;

    snd_mixer_t *mixer;
    snd_mixer_elem_t *element;

    guint watch_id;
    AlsaCb cb_func;
    gpointer cb_data;

    gboolean has_last_snapshot;
    double last_volume;
    gboolean last_muted;
};

namespace {

bool read_snapshot(AlsaCard *card, MixerSnapshot *snapshot) {
    if (card == nullptr || snapshot == nullptr) {
        return false;
    }

    if (!alsa_card_get_volume(card, &snapshot->volume)) {
        return false;
    }

    if (!alsa_card_is_muted(card, &snapshot->muted)) {
        return false;
    }

    return true;
}

void notify_values_changed(AlsaCard *card) {
    if (card != nullptr && card->cb_func != nullptr) {
        card->cb_func(ALSA_CARD_VALUES_CHANGED, card->cb_data);
    }
}

void remember_snapshot(AlsaCard *card) {
    MixerSnapshot snapshot;
    if (!read_snapshot(card, &snapshot)) {
        return;
    }

    card->last_volume = snapshot.volume;
    card->last_muted = snapshot.muted;
    card->has_last_snapshot = TRUE;
}

gboolean poll_mixer(gpointer user_data) {
    auto *card = static_cast<AlsaCard *>(user_data);
    if (card == nullptr || card->mixer == nullptr) {
        return FALSE;
    }

    const int event_result = snd_mixer_handle_events(card->mixer);
    if (event_result < 0) {
        log_alsa_error("mixer event handling", event_result);
        if (card->cb_func != nullptr) {
            card->cb_func(ALSA_CARD_ERROR, card->cb_data);
        }
        return TRUE;
    }

    MixerSnapshot snapshot;
    if (!read_snapshot(card, &snapshot)) {
        if (card->cb_func != nullptr) {
            card->cb_func(ALSA_CARD_ERROR, card->cb_data);
        }
        return TRUE;
    }

    const bool changed = card->has_last_snapshot &&
            (std::fabs(snapshot.volume - card->last_volume) > kVolumeChangeEpsilon ||
             snapshot.muted != card->last_muted);

    card->last_volume = snapshot.volume;
    card->last_muted = snapshot.muted;
    card->has_last_snapshot = TRUE;

    if (changed) {
        notify_values_changed(card);
    }

    return TRUE;
}

}  // namespace

AlsaCard *alsa_card_new(const char *card_name, const char *channel_name) {
    auto *card = g_new0(AlsaCard, 1);
    card->name = g_strdup(is_default_card_name(card_name) ? kDefaultCardName : card_name);
    card->device = resolve_device_name(card_name);

    card->mixer = open_mixer(card->device);
    if (card->mixer == nullptr) {
        alsa_card_free(card);
        return nullptr;
    }

    card->element = find_playback_element_by_name(card->mixer, channel_name);
    if (card->element == nullptr) {
        card->element = find_first_playback_element(card->mixer);
    }

    if (card->element == nullptr) {
        g_warning("ALSA could not find a playable mixer element for %s", card->device);
        alsa_card_free(card);
        return nullptr;
    }

    card->channel = g_strdup(snd_mixer_selem_get_name(card->element));
    remember_snapshot(card);

    return card;
}

void alsa_card_free(AlsaCard *card) {
    if (card == nullptr) {
        return;
    }

    alsa_card_remove_watch(card);

    if (card->mixer != nullptr) {
        snd_mixer_close(card->mixer);
        card->mixer = nullptr;
    }

    g_free(card->channel);
    g_free(card->device);
    g_free(card->name);
    g_free(card);
}

gboolean alsa_card_add_watch(AlsaCard *card) {
    if (card == nullptr) {
        return FALSE;
    }

    if (card->watch_id != 0) {
        return TRUE;
    }

    remember_snapshot(card);
    card->watch_id = g_timeout_add(kWatchIntervalMs, poll_mixer, card);

    return card->watch_id != 0;
}

void alsa_card_remove_watch(AlsaCard *card) {
    if (card == nullptr || card->watch_id == 0) {
        return;
    }

    g_source_remove(card->watch_id);
    card->watch_id = 0;
}

void alsa_card_install_callback(AlsaCard *card,
                                AlsaCb callback,
                                gpointer user_data,
                                gboolean emit_on_start) {
    if (card == nullptr) {
        return;
    }

    card->cb_func = callback;
    card->cb_data = user_data;

    if (emit_on_start && callback != nullptr) {
        callback(ALSA_CARD_VALUES_CHANGED, user_data);
    }
}

const char *alsa_card_get_name(AlsaCard *card) {
    return card == nullptr ? nullptr : card->name;
}

const char *alsa_card_get_channel(AlsaCard *card) {
    return card == nullptr ? nullptr : card->channel;
}

gboolean alsa_card_has_mute(AlsaCard *card) {
    return card != nullptr && card->element != nullptr &&
           snd_mixer_selem_has_playback_switch(card->element);
}

gboolean alsa_card_is_muted(AlsaCard *card, gboolean *muted) {
    if (card == nullptr || card->element == nullptr || muted == nullptr) {
        return FALSE;
    }

    if (!snd_mixer_selem_has_playback_switch(card->element)) {
        *muted = FALSE;
        return TRUE;
    }

    snd_mixer_selem_channel_id_t channel;
    if (!first_playback_channel(card->element, &channel)) {
        *muted = FALSE;
        return TRUE;
    }

    int switch_value = 1;
    const int result = snd_mixer_selem_get_playback_switch(card->element,
                                                           channel,
                                                           &switch_value);
    if (result < 0) {
        log_alsa_error("mute switch read", result);
        return FALSE;
    }

    *muted = switch_value == 0;
    return TRUE;
}

gboolean alsa_card_set_mute(AlsaCard *card, gboolean muted) {
    if (card == nullptr || card->element == nullptr) {
        return FALSE;
    }

    if (!snd_mixer_selem_has_playback_switch(card->element)) {
        return TRUE;
    }

    const int result = snd_mixer_selem_set_playback_switch_all(card->element,
                                                               muted ? 0 : 1);
    if (result < 0) {
        log_alsa_error("mute switch write", result);
        return FALSE;
    }

    remember_snapshot(card);
    return TRUE;
}

gboolean alsa_card_toggle_mute(AlsaCard *card) {
    gboolean muted = FALSE;
    if (!alsa_card_is_muted(card, &muted)) {
        return FALSE;
    }

    return alsa_card_set_mute(card, !muted);
}

gboolean alsa_card_get_volume(AlsaCard *card, double *volume) {
    if (card == nullptr || card->element == nullptr || volume == nullptr) {
        return FALSE;
    }

    snd_mixer_selem_channel_id_t channel;
    if (!first_playback_channel(card->element, &channel)) {
        g_warning("ALSA playback element has no readable channels");
        return FALSE;
    }

    long min = 0;
    long max = 0;
    if (!playback_volume_range(card->element, &min, &max)) {
        return FALSE;
    }

    long raw_volume = 0;
    const int result = snd_mixer_selem_get_playback_volume(card->element,
                                                           channel,
                                                           &raw_volume);
    if (result < 0) {
        log_alsa_error("volume read", result);
        return FALSE;
    }

    *volume = clamp_volume(static_cast<double>(raw_volume - min) /
                           static_cast<double>(max - min));
    return TRUE;
}

gboolean alsa_card_set_volume(AlsaCard *card, double value, int dir) {
    if (card == nullptr || card->element == nullptr) {
        return FALSE;
    }

    long min = 0;
    long max = 0;
    if (!playback_volume_range(card->element, &min, &max)) {
        return FALSE;
    }

    double target_volume = clamp_volume(value);
    if (dir != 0) {
        double current_volume = 0;
        if (!alsa_card_get_volume(card, &current_volume)) {
            return FALSE;
        }

        target_volume = clamp_volume(
                current_volume + (dir > 0 ? target_volume : -target_volume));
    }

    const long raw_volume = normalized_to_raw_volume(target_volume, min, max, dir);
    const int result = snd_mixer_selem_set_playback_volume_all(card->element, raw_volume);
    if (result < 0) {
        log_alsa_error("volume write", result);
        return FALSE;
    }

    remember_snapshot(card);
    notify_values_changed(card);

    return TRUE;
}

GSList *alsa_list_cards() {
    GSList *cards = nullptr;

    snd_mixer_t *default_mixer = open_mixer(kDefaultDeviceName);
    if (default_mixer != nullptr) {
        if (find_first_playback_element(default_mixer) != nullptr) {
            cards = g_slist_append(cards, g_strdup(kDefaultCardName));
        }
        snd_mixer_close(default_mixer);
    }

    int card_index = -1;
    while (true) {
        const int next_result = snd_card_next(&card_index);
        if (next_result < 0) {
            log_alsa_error("card enumeration", next_result);
            break;
        }

        if (card_index < 0) {
            break;
        }

        gchar *device = g_strdup_printf("hw:%d", card_index);
        snd_mixer_t *mixer = open_mixer(device);
        g_free(device);

        if (mixer == nullptr) {
            continue;
        }

        if (find_first_playback_element(mixer) != nullptr) {
            char *alsa_name = nullptr;
            const int name_result = snd_card_get_name(card_index, &alsa_name);
            if (name_result >= 0) {
                cards = g_slist_append(cards, g_strdup(alsa_name));
                free(alsa_name);
            } else {
                log_alsa_error("card name lookup", name_result);
            }
        }

        snd_mixer_close(mixer);
    }

    return cards;
}

GSList *alsa_list_channels(const char *card_name) {
    GSList *channels = nullptr;
    gchar *device = resolve_device_name(card_name);
    snd_mixer_t *mixer = open_mixer(device);
    g_free(device);

    if (mixer == nullptr) {
        return nullptr;
    }

    for (snd_mixer_elem_t *element = snd_mixer_first_elem(mixer);
         element != nullptr;
         element = snd_mixer_elem_next(element)) {
        if (has_playback_volume(element)) {
            channels = g_slist_append(channels,
                                      g_strdup(snd_mixer_selem_get_name(element)));
        }
    }

    snd_mixer_close(mixer);
    return channels;
}
