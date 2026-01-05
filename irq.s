.section irq_table
.org 0x0 schaduler
.org 0x4 mini_uart_valid_byte
.org 0x8 mini_uart_tx_empty
.org 0xc mini_uart_receiver_overrun
.org 0x10 void_irq
.org 0x14 unkown_irq

.section irq_handlers
.eq MINI_UART_RX_BUFFER
.eq MINI_UART_LICENSE 
# a byte for owned task_id
# also includes these in a byte:
# 1- tx fifo empty.
# 2- rx buffer panic/overflow. 
# 3- tx enabled.
# 4- rx enabled.
# 5- tx is idle.
# 6- rx is idle.
# 7- data type (7-8 bits mode).
# 8- mini uart enabled.
# and two bytes for baudrate (16-bit baudrate).
# four byte for uart buffer length.
# a four byte for rx buffering topics that includes:
# 1- receiver overrun.
# 2- uart buffer size.
# 3- one byte free space at least.
# 4~8- reserved.
# (3 bytes reserved.)

.eq MINI_UART_LICENSE_RX_BUFFER_STAT #0x8
.eq MINI_UART_LICENSE_OWNED_TASK_ID #0x7
.eq MINI_UART_LICENSE_BARE_STATUS #0x6
.eq MINI_UART_LICENSE_BAUDRATE #0x4
.eq MINI_UART_LICENSE_RX_BUFFER_LEN #0x0

.eq MINI_UART_BASE #0x7E21
.eq MINI_UART_MU_IO #0x5040

.eq SYSTEM_STAT
.eq SYSTEM_STAT_IRQ_FALL_COUNT
.eq VOID_IRQ

mini_uart_tx_empty:
    subs r13,r13,#4
    str r0,[r13]
    ldrb r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_BARE_STATUS]
    orr r0,r0,#0x1 # set tx fifo is empty bit.
    strb r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_BARE_STATUS]

    ldr r0,[r13]
    add r13,r13,#4
    ldr pc,[r0] # back to irq handler.

mini_uart_valid_byte: 
    subs r13,r13,#4
    str r0,[r13]
    
    ldr r1,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_RX_BUFFER_LEN]
    ldr r0,[=MINI_UART_LICENSE,=MINI_UART_RX_BUFFER_STAT] # check rx buffer if is free.
    and r0,r0,#0x4
    cmp r0,#0x4

    ldreq r0,[r13]
    addeq r13,r13,#4
    ldreq pc,[r0] # back to irq handler.
    ldrb r0,[=MINI_UART_BASE,=MINI_UART_MU_IO] # read byte.
    strb r0,[=MINI_UART_LICENSE,r1]
    add r1,r1,#1 # update length of buffer.
    str r1,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_RX_BUFFER_LEN] # store current length.

    ldr r0,[r13]
    add r13,r13,#4
    ldr pc,[r0]

mini_uart_receiver_overrun:
    subs r13,r13,#4
    str r0,[r13]

    ldrb r0,[=MINI_UART_LICENSE,=MINI_UART_MU_IO] # discard current bit.
    ldr r1,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_RX_BUFFER_LEN]
    strb #0,[=MINI_UART_LICENSE,r1]
    add r1,r1,#1 # update length of buffer.
    str r1,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_RX_BUFFER_LEN] # store current length.

    ldr r0,[r13]
    add r13,r13,#4
    ldr pc,[r0]

void_irq:
    subs r13,r13,#4
    str r0,[r13]

    mov r0,#0
    strb r0,[=VOID_IRQ]

    ldr r0,[r13]
    add r13,r13,#4
    ldr pc,[r0]

unkown_irq:
    subs r13,r13,#4
    str r0,[r13]

    ldrh r0,[=SYSTEM_STAT,=SYSTEM_STAT_IRQ_FALL_COUNT] # get current irq fall counts.
    add r0,r0,#1

    strh r0,[=SYSTEM_STAT,=SYSTEM_STAT_IRQ_FALL_COUNT] # store new irq fall counts.

    ldr r0,[r13]
    add r13,r13,#4
    ldr pc,[r0]