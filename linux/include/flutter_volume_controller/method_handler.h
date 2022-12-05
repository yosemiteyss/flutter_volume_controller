#ifndef METHOD_HANDLER_H
#define METHOD_HANDLER_H

#include "alsa.h"

#include <flutter_linux/flutter_linux.h>

FlMethodResponse *get_volume(AlsaCard *card);

FlMethodResponse *set_volume(AlsaCard *card, double volume);

FlMethodResponse *raise_volume(AlsaCard *card, double step);

FlMethodResponse *lower_volume(AlsaCard *card, double step);

FlMethodResponse *get_mute(AlsaCard *card);

FlMethodResponse *set_mute(AlsaCard *card, gboolean muted);

FlMethodResponse *toggle_mute(AlsaCard *card);

#endif
