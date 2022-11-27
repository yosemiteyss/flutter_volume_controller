#include "include/flutter_volume_controller/method_handler.h"
#include "include/flutter_volume_controller/constants.h"

FlMethodResponse *get_volume(AlsaCard *card) {
    gdouble volume;

    if (alsa_card_get_volume(card, &volume) == FALSE)
        return FL_METHOD_RESPONSE(fl_method_error_response_new(ERROR_CODE_DEFAULT, ERROR_MSG_GET_VOLUME, NULL));

    g_autoptr(FlValue) res = fl_value_new_float((float) volume);
    return FL_METHOD_RESPONSE(fl_method_success_response_new(res));
}

FlMethodResponse *set_volume(AlsaCard *card, float volume) {
    if (alsa_card_set_volume(card, volume, 0) == FALSE)
        return FL_METHOD_RESPONSE(fl_method_error_response_new(ERROR_CODE_DEFAULT, ERROR_MSG_SET_VOLUME, NULL));

    return FL_METHOD_RESPONSE(fl_method_success_response_new(NULL));
}

FlMethodResponse *raise_volume(AlsaCard *card, float step) {
    if (alsa_card_set_volume(card, step, 1) == FALSE)
        return FL_METHOD_RESPONSE(fl_method_error_response_new(ERROR_CODE_DEFAULT, ERROR_MSG_RAISE_VOLUME, NULL));

    return FL_METHOD_RESPONSE(fl_method_success_response_new(NULL));
}

FlMethodResponse *lower_volume(AlsaCard *card, float step) {
    if (alsa_card_set_volume(card, step, -1) == FALSE)
        return FL_METHOD_RESPONSE(fl_method_error_response_new(ERROR_CODE_DEFAULT, ERROR_MSG_LOWER_VOLUME, NULL));

    return FL_METHOD_RESPONSE(fl_method_success_response_new(NULL));
}
