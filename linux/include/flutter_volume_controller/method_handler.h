#ifndef METHOD_HANDLER_H
#define METHOD_HANDLER_H

#include "alsa.h"

#include <flutter_linux/flutter_linux.h>

FlMethodResponse *get_volume(AlsaCard *card);

FlMethodResponse *set_volume(AlsaCard *card, float volume);

FlMethodResponse *raise_volume(AlsaCard *card, float step);

FlMethodResponse *lower_volume(AlsaCard *card, float step);

#endif
