/* alsa.h
 * The file is forked and modified from PNmixer written by Nick Lanham.
 * Source: <http://github.com/nicklan/pnmixer>
 */

/**
 * @file alsa.h
 * Header for alsa.c.
 * @brief Header for alsa.c.
 */

#ifndef ALSA_H_
#define ALSA_H_

#include <glib.h>

typedef struct alsa_card AlsaCard;

enum alsa_event {
    ALSA_CARD_ERROR,
    ALSA_CARD_DISCONNECTED,
    ALSA_CARD_VALUES_CHANGED
};

typedef void (*AlsaCb)(enum alsa_event event, gpointer data);

AlsaCard *alsa_card_new(const char *card, const char *channel);

gboolean alsa_card_add_watch(AlsaCard *card);

void alsa_card_remove_watch(AlsaCard *card);

void alsa_card_free(AlsaCard *card);

void alsa_card_install_callback(AlsaCard *card, AlsaCb callback, gpointer data, gboolean emit_on_start);

const char *alsa_card_get_name(AlsaCard *card);

const char *alsa_card_get_channel(AlsaCard *card);

gboolean alsa_card_has_mute(AlsaCard *card);

gboolean alsa_card_is_muted(AlsaCard *card, gboolean *muted);

gboolean alsa_card_set_mute(AlsaCard *card, gboolean muted);

gboolean alsa_card_toggle_mute(AlsaCard *card);

gboolean alsa_card_get_volume(AlsaCard *card, double *volume);

gboolean alsa_card_set_volume(AlsaCard *card, double value, int dir);

GSList *alsa_list_cards();

GSList *alsa_list_channels(const char *card_name);

#endif
