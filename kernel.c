#include "./types/common.h"
#include "./peripherals/on-board-led.h"

void schaduler();
void short_schaduler();
void long_schaduler();

void kernel()
{
    initialize_onboard_led();
    set_led(); // blink to signal kernel is up.
}