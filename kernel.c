#include "./types/common.h"
#include "./peripherals/on-board-led.h"
#include "./peripherals/mini-uart.h"

void schaduler();
void short_schaduler();
void long_schaduler();

void kernel()
{
    initialize_onboard_led();
    set_led();                                                        // blink to signal kernel is up.
    serial_settings((UART_settings_t){9600, 1, 1, 1, 1, 1, 1, NULL}); // initialize serial uart (mini-uart).
    serial_protected_write("serial & on-board status led initialized.\n");
}
