#include "./common.h"
typedef struct
{
    char *uart_buffer;        // 4B
    u32_t uart_buffer_length; // 4B
    u32_t uart_buffer_size;   // 4B
    u16_t baudrate;           // 2B
    ubyte_t bare_status;      // 1B --> tx fifo empty | rx buffer panic/overflow | tx enabled | rx enabled | tx is idle | rx is idle | data type (7-8 bits mode) | mini uart enabled
    ubyte_t owned_task_id;    // 1B
} UART_LICENSE_t;             // 16 B

typedef struct
{
    u16_t irq_fall_count;
    u16_t serial_character_miss;
} SYSTEM_STAT_t; // 32 B