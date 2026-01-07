.section irq_table
.org 0x0 ldr pc,=schaduler
.org 0x4 ldr pc,=mini_uart_valid_byte
.org 0x8 ldr pc,=mini_uart_tx_empty
.org 0xc ldr pc,=mini_uart_receiver_overrun
.org 0x10 ldr pc,=void_irq
.org 0x14 ldr pc,=unkown_irq


.ltorg
.section irq_routines 
.eq MINI_UART_LICENSE #0x1B14 # ownership of mini uart by tasks or hardware limitation.
.eq MINI_UART_LICENSE_OWNED_TASK_ID #0xC
.eq MINI_UART_LICENSE_BARE_STATUS #0xB
.eq MINI_UART_LICENSE_BAUDRATE #0xA
.eq MINI_UART_LICENSE_RX_BUFFER_SIZE #0x8
.eq MINI_UART_LICENSE_RX_BUFFER_LEN #0x4
.eq MINI_UART_LICENSE_RX_BUFFER #0x0

.eq MINI_UART_BASE #0x7E210000
.eq MINI_UART_MU_IO #0x5040

.eq SYSTEM_STAT #0x1B34
.eq SYSTEM_STAT_IRQ_FALL_COUNT #0x4
.eq SYSTEM_STAT_SERIAL_CHAR_MISS #0x8

.eq VOID_IRQ #0x1B50

mini_uart_tx_empty:
    # 28 B
    str r0,[r13,#-4]!
    ldrb r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_BARE_STATUS]
    orr r0,r0,#1 # set tx fifo is empty bit.
    strb r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_BARE_STATUS]

    ldr r0,[r13]
    add r13,r13,#4
    ldr pc,[r0] # back to irq handler.

mini_uart_valid_byte: 
    # 120 B
    stmfd r13!,{r0,r3}

    ldr r2,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_RX_BUFFER_SIZE] # check if buffer even created (by size).
    ldr r1,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_RX_BUFFER_LEN] # check if buffer even created (by length).
    ldr r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_RX_BUFFER] # check if buffer even created.
    
    cmp r0,#0
    ldreq r0,[r13],#4
    ldreq pc,[r0] # back to irq handler.

    cmp r1,#0
    ldreq r0,[r13],#4
    ldreq pc,[r0]

    cmp r2,#0
    ldreq r0,[r13],#4
    ldreq pc,[r0]

    ldr r0,[r0] # point to buffer.
    cmp r1,r2 # compare buffer length and size.

    ldrge r0,[=SYSTEM_STAT,=SYSTEM_STAT_SERIAL_CHAR_MISS]
    addge r0,r0,#1
    strge r0,[=SYSTEM_STAT,=SYSTEM_STAT_SERIAL_CHAR_MISS]
    ldrge r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_BARE_STATUS] # read mini uart license.
    orrge r0,r0,#2 # turn on overflow bit.
    strge r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_BARE_STATUS] # store mini uart license.
    ldrge r0,[r13],#4
    ldrge pc,[r0]

    ldrb r3,[=MINI_UART_BASE,=MINI_UART_MU_IO] # read byte.
    
    strb r3,[=MINI_UART_LICENSE_RX_BUFFER,r1] # store readed byte info buffer.
    add r1,r1,#1 # update length of buffer.

    ldr r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_RX_BUFFER_LEN] # get pointer of buffer length.
    str r1,[r0] # store current length to pointed --> rx buffer length.

    ldmfd r13!,{r3,r0}
    ldr pc,[r0]

mini_uart_receiver_overrun:
    # 28 B
    str r0,[r13,#-4]!

    ldrb r0,[=MINI_UART_LICENSE,=MINI_UART_MU_IO] # discard current bit.

    ldrh r0,[=SYSTEM_STAT,=SYSTEM_STAT_SERIAL_CHAR_MISS] # read char misses in system.
    add r0,r0,#1 # increment char misses.
    strh r0,[=SYSTEM_STAT,=SYSTEM_STAT_SERIAL_CHAR_MISS] # apply new char miss to system status.
    
    ldr r0,[r13],#4
    ldr pc,[r0]

void_irq:
    # 20 B
    str r0,[r13,#-4]!

    mov r0,#0
    strb r0,[=VOID_IRQ]

    ldr r0,[r13],#4
    ldr pc,[r0]

unkown_irq:
    # 30 B
    str r0,[r13,#-4]!

    ldrh r0,[=SYSTEM_STAT,=SYSTEM_STAT_IRQ_FALL_COUNT] # get current irq fall counts.
    add r0,r0,#1

    strh r0,[=SYSTEM_STAT,=SYSTEM_STAT_IRQ_FALL_COUNT] # store new irq fall counts.

    ldr r0,[r13],#4
    ldr pc,[r0]

.ltorg