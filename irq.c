typedef unsigned char ubyte_t;
typedef unsigned short int u16_t;
typedef unsigned int u32_t;

typedef struct
{
    u32_t uart_buffer_length;
    u16_t baudrate;
    ubyte_t bare_status;
    ubyte_t owned_task_id;
    ubyte_t rx_buffer_stat;
    ubyte_t reserved[3]; // padding
} UART_LICENSE_t;

typedef struct
{
    u16_t irq_fall_count;
} SYSTEM_STAT_t;