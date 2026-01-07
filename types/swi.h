#include "./common.h"
#define GPIO_OUTPUT 0
#define GPIO_INPUT 1

typedef struct
{
    u16_t baudrate;         // 2B
    ubyte_t enabled;        // 1B
    ubyte_t tx_enabled;     // 1B
    ubyte_t rx_enabled;     // 1B
    ubyte_t tx_irq_enabled; // 1B
    ubyte_t rx_irq_enabled; // 1B
    ubyte_t data_size;      // 1B
} UART_settings_t;          // 8 B