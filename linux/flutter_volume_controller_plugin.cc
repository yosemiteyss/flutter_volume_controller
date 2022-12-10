#include "include/flutter_volume_controller/flutter_volume_controller_plugin.h"
#include "include/flutter_volume_controller/method_handler.h"
#include "include/flutter_volume_controller/constants.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <cstring>

#define FLUTTER_VOLUME_CONTROLLER_PLUGIN(obj)                                       \
    (G_TYPE_CHECK_INSTANCE_CAST((obj), flutter_volume_controller_plugin_get_type(), \
                                FlutterVolumeControllerPlugin))

struct _FlutterVolumeControllerPlugin {
    GObject parent_instance;

    FlEventChannel *event_channel = NULL;
    gboolean send_events = FALSE;

    AlsaCard *card;
};

G_DEFINE_TYPE(FlutterVolumeControllerPlugin, flutter_volume_controller_plugin, g_object_get_type()
)

static void flutter_volume_controller_plugin_handle_method_call(
        FlutterVolumeControllerPlugin *self,
        FlMethodCall *method_call) {
    g_autoptr(FlMethodResponse)
            response = NULL;
    FlValue *args = fl_method_call_get_args(method_call);
    const gchar *method = fl_method_call_get_name(method_call);

    if (!self->card) {
        g_critical("Failed to initiate default card instance");
        return;
    }

    if (strcmp(method, METHOD_GET_VOLUME) == 0) {
        response = get_volume(self->card);
    } else if (strcmp(method, METHOD_SET_VOLUME) == 0) {
        FlValue *volume_value = fl_value_lookup_string(args, ARG_VOLUME);
        double volume = fl_value_get_float(volume_value);
        response = set_volume(self->card, volume);
    } else if (strcmp(method, METHOD_RAISE_VOLUME) == 0) {
        FlValue *step_value = fl_value_lookup_string(args, ARG_STEP);
        double step = !step_value ? 0.15 : fl_value_get_float(step_value);
        response = raise_volume(self->card, step);
    } else if (strcmp(method, METHOD_LOWER_VOLUME) == 0) {
        FlValue *step_value = fl_value_lookup_string(args, ARG_STEP);
        double step = !step_value ? 0.15 : fl_value_get_float(step_value);
        response = lower_volume(self->card, step);
    } else if (strcmp(method, METHOD_GET_MUTE) == 0) {
        response = get_mute(self->card);
    } else if (strcmp(method, METHOD_SET_MUTE) == 0) {
        FlValue *is_muted_value = fl_value_lookup_string(args, ARG_IS_MUTED);
        gboolean is_muted = fl_value_get_bool(is_muted_value);
        response = set_mute(self->card, is_muted);
    } else if (strcmp(method, METHOD_TOGGLE_MUTE) == 0) {
        response = toggle_mute(self->card);
    }

    fl_method_call_respond(method_call, response, NULL);
}

static void flutter_volume_controller_plugin_dispose(GObject *object) {
    FlutterVolumeControllerPlugin *self = FLUTTER_VOLUME_CONTROLLER_PLUGIN(object);

    /* Dispose card instance */
    alsa_card_free(self->card);

    g_object_unref(self->event_channel);

    G_OBJECT_CLASS(flutter_volume_controller_plugin_parent_class)->dispose(object);
}

static void flutter_volume_controller_plugin_class_init(FlutterVolumeControllerPluginClass *klass) {
    G_OBJECT_CLASS(klass)->dispose = flutter_volume_controller_plugin_dispose;
}

static void on_alsa_values_changed(FlutterVolumeControllerPlugin *self) {
    double volume;
    gchar buffer[G_ASCII_DTOSTR_BUF_SIZE] = {0};

    alsa_card_get_volume(self->card, &volume);
    g_ascii_dtostr(buffer, sizeof(buffer), volume);

    g_autoptr(FlValue)
            return_value = fl_value_new_string(buffer);
    fl_event_channel_send(self->event_channel, return_value, NULL, NULL);
}

static void on_alsa_event(enum alsa_event event, gpointer data) {
    FlutterVolumeControllerPlugin *self = (FlutterVolumeControllerPlugin *) data;

    /* Check event channel is active */
    if (!self->send_events)
        return;

    switch (event) {
        case ALSA_CARD_ERROR:
            g_critical("alsa card error");
            return;
        case ALSA_CARD_DISCONNECTED:
            g_critical("alsa card disconnected");
            return;
        case ALSA_CARD_VALUES_CHANGED:
            on_alsa_values_changed(self);
            break;
        default:
            g_critical("unhandled alsa event");
            return;
    }
}

static void flutter_volume_controller_plugin_init(FlutterVolumeControllerPlugin *self) {
    /* Initiate the default card instance */
    self->card = alsa_card_new(NULL, NULL);

    if (self->card == NULL)
        g_critical("Failed to initiate default card instance");
}

static void method_call_cb(FlMethodChannel *channel,
                           FlMethodCall *method_call,
                           gpointer user_data) {
    FlutterVolumeControllerPlugin *self = FLUTTER_VOLUME_CONTROLLER_PLUGIN(user_data);
    flutter_volume_controller_plugin_handle_method_call(self, method_call);
}

static FlMethodErrorResponse *event_listen_cb(FlEventChannel *channel, FlValue *args, gpointer user_data) {
    FlutterVolumeControllerPlugin *self = (FlutterVolumeControllerPlugin *)
            user_data;
    AlsaCard *card = self->card;
    FlValue *emit_on_start_value = fl_value_lookup_string(args, ARG_EMIT_ON_START);

    bool emit_on_start = fl_value_get_bool(emit_on_start_value);

    /* Check card is existed */
    if (card == NULL)
        return fl_method_error_response_new(ERROR_CODE_REG_VOLUME_LISTENER, ERROR_MSG_REG_VOLUME_LISTENER, NULL);

    /* Start watching alsa card */
    if (alsa_card_add_watch(card) == FALSE)
        return fl_method_error_response_new(ERROR_CODE_REG_VOLUME_LISTENER, ERROR_MSG_REG_VOLUME_LISTENER, NULL);

    alsa_card_install_callback(card, on_alsa_event, user_data, emit_on_start);

    self->send_events = TRUE;

    return NULL;
}

static FlMethodErrorResponse *event_cancel_cb(FlEventChannel *channel, FlValue *args, gpointer user_data) {
    FlutterVolumeControllerPlugin *self = (FlutterVolumeControllerPlugin *)
            user_data;
    AlsaCard *card = self->card;

    /* Stop watching alsa card */
    if (card != NULL)
        alsa_card_remove_watch(card);

    self->send_events = FALSE;

    return NULL;
}

void flutter_volume_controller_plugin_register_with_registrar(FlPluginRegistrar *registrar) {
    FlutterVolumeControllerPlugin *self =
            FLUTTER_VOLUME_CONTROLLER_PLUGIN(
                    g_object_new(flutter_volume_controller_plugin_get_type(), nullptr));

    g_autoptr(FlStandardMethodCodec)
            codec = fl_standard_method_codec_new();

    /* Create method channel */
    g_autoptr(FlMethodChannel)
            method_channel = fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                                                   "com.yosemiteyss.flutter_volume_controller/method",
                                                   FL_METHOD_CODEC(codec));
    fl_method_channel_set_method_call_handler(
            method_channel, method_call_cb, g_object_ref(self), g_object_unref);

    /* Create event channel */
    self->event_channel = fl_event_channel_new(fl_plugin_registrar_get_messenger(registrar),
                                               "com.yosemiteyss.flutter_volume_controller/event",
                                               FL_METHOD_CODEC(codec));
    fl_event_channel_set_stream_handlers(self->event_channel, event_listen_cb, event_cancel_cb,
                                         g_object_ref(self),
                                         g_object_unref);

    g_object_unref(self);
}
