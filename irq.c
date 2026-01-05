typedef unsigned char ubyte_t;
typedef unsigned short int u16_t;
typedef unsigned int u32_t;

typedef struct
{
    char *uart_buffer;         // 4B
    u32_t *uart_buffer_length; // 4B
    u32_t *uart_buffer_size;   // 4B
    u16_t baudrate;            // 2B
    ubyte_t bare_status;       // 1B
    ubyte_t owned_task_id;     // 1B
    ubyte_t rx_buffer_stat;    // 1B
    ubyte_t reserved;          // padding --> 3B
} UART_LICENSE_t;

typedef struct
{
    u16_t irq_fall_count;
    u16_t serial_character_miss;
} SYSTEM_STAT_t;