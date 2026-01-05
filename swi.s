.section swi_table
.org 0x0 ldr pc,=protected_write 
.org 0x4 ldr pc,=write
.org 0x8 ldr pc,=read
.org 0xc ldr pc,=allocate_serial
.org 0x10 ldr pc,=deallocate_serial

.section swi_routines
.eq MINI_UART_BASE #0x7E21
.eq MINI_UART_STAT #0x5064
.eq MINI_UART_MU_IO #0x5040
.eq MINI_UART_BAUDRATE #0x5068
.eq MINI_UART_AUX_MU #0x5060
.eq MINI_UART_IIR #0x5044
.eq MINI_UART_LSR #0x5054

.eq MINI_UART_LICENSE_RX_BUFFER_STAT #0xE
.eq MINI_UART_LICENSE_OWNED_TASK_ID #0xC
.eq MINI_UART_LICENSE_BARE_STATUS #0xB
.eq MINI_UART_LICENSE_BAUDRATE #0xA
.eq MINI_UART_LICENSE_RX_BUFFER_SIZE #0x8
.eq MINI_UART_LICENSE_RX_BUFFER_LEN #0x4
.eq MINI_UART_LICENSE_RX_BUFFER #0x0

protected_write:
    and r0,r0,#0x000F
    stmfd r13!,{r0,r1}
    
    ldr r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_OWNED_TASK_ID]
    cmp r0,r2

    movne r0,#1 # 1 means: mini-uart is allocated by other process.
    ldrne r1,[r13],#4
    ldrne pc,[r13],#4

    ldr r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_BARE_STATUS] # check if mini-uart its empty.
    and r0,r0,#0x01
    cmp r0,#0x01
    
    movne r0,#2 # 2 means: mini-uart is full.
    ldrne r1,[r13],#4
    ldrne pc,[r13],#4
    
    ldr r0,[r13],#4
    strb r0,[=MINI_UART_BASE,=MINI_UART_MU_IO] # write byte into mini uart.
    ldrb r1,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_BARE_STATUS] # read mini-uart access.

    and r1,r1,#0xEE # turn off access (tx idle, tx free).
    strb r1,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_BARE_STATUS] # apply access.

    mov r0,#0 # 0 means: done.
    ldmfd r13!,{r1,pc} # quit routine.

write:
    and r0,r0,#0x000F
    str r0,[r13,-#4]!
    
    ldr r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_OWNED_TASK_ID]
    cmp r0,r2

    movne r0,#1 # 1 means: mini-uart is allocated by other process.
    ldmfdne r13!,{r0,pc}

    ldr r0,[r13],#4
    strb r0,[=MINI_UART_BASE,=MINI_UART_MU_IO]
    
    mov r0,#0 # 0 means: done.
    ldr pc,[r13],#4

read:
    ldr r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_OWNED_TASK_ID]
    cmp r0,r1

    movne r0,#1 # 1 mean: mini uart is allocated by other process.
    ldrne pc,[r13],#4

    str r0,[=MINI_UART_LICENSE,=MINI_UART_RX_BUFFER]
    mov r0,#0 # 0 means: done.

    ldr pc,[r13],#4

allocate_serial:
    str r1,[r13,-#4]!
    mov r1,r0
    and r1,r1,#0x000F
    ldr r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_OWNED_TASK_ID]
    cmp r0,r1

    movne r0,#1 
    ldmfdne r13!,{r1,pc}

    mov r0,r1
    ldr r1,[r13],#4
    
    strb r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_OWNED_TASK_ID]
    str r1,[=MINI_UART_LICENSE,=MINI_UART_RX_BUFFER]
    str r2,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_RX_BUFFER_LEN]
    str r3,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_RX_BUFFER_SIZE]
    mov r0,#0

    ldr pc,[r13],#4

deallocate_serial:
    str r1,[r13,-#4]!
    
    ldr r1,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_OWNED_TASK_ID]
    cmp r1,r0

    mov r0,#0
    str r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_RX_BUFFER]
    str r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_RX_BUFFER_LEN]
    str r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_RX_BUFFER_SIZE]

    ldr r1,[r13],#4
    ldr pc,[r13],#4

uart_settings:
    stmfd r13!,{r1,r2}
    
    ldrh r1,[r0]
    strh [=MINI_UART_BASE,=MINI_UART_BAUDRATE]

    ldr r2,[=MINI_UART_BASE,#0x5004]
    ldrb r1,[r0,#2]
    cmp r1,#0
    orrne r2,r2,#0x0001
    andeq r2,r2,#0xFFFE

    str r2,[=MINI_UART_BASE,#0x5004]
    
    ldr r2,[=MINI_UART_BASE,=MINI_UART_AUX_MU]
    ldrb r1,[r0,#3]

    cmp r1,#0
    orrne r2,r2,#0x0001
    andeq r2,r2,#0xFFFE

    ldrb r1,[r0,#4]
    
    cmp r1,#0
    orrne r2,r2,#0x0002
    andeq r2,r2,#0xFFFC

    str r2,[=MINI_UART_BASE,=MINI_UART_AUX_MU]

    ldr r2,[=MINI_UART_BASE,=MINI_UART_IIR]
    ldr r1,[r0,#5]

    cmp r1,#0
    orrne r2,r2,#0x0001
    andeq r2,r2,#0xFFFE

    ldr r1,[r0,#6]
    orrne r2,r2,#0x0002
    andeq r2,r2,#0xFFFC

    str r2,[=MINI_UART_BASE,=MINI_UART_IIR]

    ldr r1,[r0,#7]
    ldr r2,[=MINI_UART_BASE,=MINI_UART_LSR]    

    cmp r1,#0
    orrne r2,r2,#0x0001
    andeq r2,r2,#0xFFFE

    str r2,[=MINI_UART_BASE,=MINI_UART_LSR]

uart_status_check:
    # nothing ...