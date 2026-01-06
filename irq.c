typedef unsigned char ubyte_t;
typedef unsigned short int u16_t;
typedef unsigned int u32_t;

typedef struct
{
    char *uart_buffer;         // 4B
    u32_t *uart_buffer_length; // 4B
    u32_t *uart_buffer_size;   // 4B
    u16_t baudrate;            // 2B
    ubyte_t bare_status;       // 1B --> tx fifo empty | rx buffer panic/overflow | tx enabled | rx enabled | tx is idle | rx is idle | data type (7-8 bits mode) | mini uart enabled
    ubyte_t owned_task_id;     // 1B
} UART_LICENSE_t;

typedef struct
{
    u16_t baudrate;         // 2B
    ubyte_t enabled;        // 1B
    ubyte_t tx_enabled;     // 1B
    ubyte_t rx_enabled;     // 1B
    ubyte_t tx_irq_enabled; // 1B
    ubyte_t rx_irq_enabled; // 1B
    ubyte_t data_size;      // 1B
    ubyte_t reserved[3];    // padding --> 3B
} UART_settings_t;
typedef struct
{
    u16_t irq_fall_count;
    u16_t serial_character_miss;
} SYSTEM_STAT_t;