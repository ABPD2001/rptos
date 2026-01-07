.section swi_table
.org 0x0 ldr pc,=protected_write 
.org 0x4 ldr pc,=write
.org 0x8 ldr pc,=read
.org 0xC ldr pc,=allocate_serial
.org 0x10 ldr pc,=deallocate_serial
.org 0x14 ldr pc,=serial_settings
.org 0x18 ldr pc,=serial_status_check
.org 0x20 ldr pc,=toggle_onboard_led
.org 0x24 ldr pc,=protected_write_str

.ltorg
.section swi_routines
.set MINI_UART_BASE #0x7E210000
.set MINI_UART_STAT #0x5064
.set MINI_UART_MU_IO #0x5040
.set MINI_UART_BAUDRATE #0x5068
.set MINI_UART_IIR #0x5044
.set MINI_UART_LSR #0x5054
.set MINI_UART_MU_CNTL #0x5060 
.set MINI_UART_PREF #0x5004
.set MINI_UART_LCR #0x504C

.set MINI_UART_LICENSE #0x1B14 # ownership of mini uart by tasks or hardware limitation.
.set MINI_UART_LICENSE_RX_BUFFER_STAT #0xE
.set MINI_UART_LICENSE_OWNED_TASK_ID #0xC
.set MINI_UART_LICENSE_BARE_STATUS #0xB
.set MINI_UART_LICENSE_BAUDRATE #0xA
.set MINI_UART_LICENSE_RX_BUFFER_SIZE #0x8
.set MINI_UART_LICENSE_RX_BUFFER_LEN #0x4
.set MINI_UART_LICENSE_RX_BUFFER #0x0

.set GPIO_BASE #0x7E200000
.set GPIO_GPFSEL0 #0x0
.set GPIO_GPFSEL1 #0x4
.set GPIO_GPFSEL2 #0x8
.set GPIO_GPFSEL3 #0xC
.set GPIO_GPFSEL4 #0x10
.set GPIO_GPFSEL5 #0x14

.set GPIO_GPSET0 #0x001C
.set GPIO_GPSET1 #0x0020

.set GPIO_GPCLR0 #0x0028
.set GPIO_GPCLR1 #0x002C

protected_write_str_loop:
    # 20 B
    ldr r1,[r0,#1]
    cmp r1,#0
    ldreq pc,[r13],#4
    strb r1,[=MINI_UART_BASE,=MINI_UART_MU_IO] # write byte into mini uart.
    b protected_write_str_loop

protected_write_str:
    # 80 B

    stmfd r13!,{r0,r1}
    
    ldr r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_OWNED_TASK_ID]
    cmp r0,r2

    movne r0,#1 # 1 means: mini-uart is allocated by other process.
    ldrne r1,[r13],#4
    ldrne pc,[r13],#4

    ldr r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_BARE_STATUS] # check if mini-uart its empty.
    and r0,r0,#1
    cmp r0,#1
    
    movne r0,#2 # 2 means: mini-uart is full.
    ldrne r1,[r13],#4
    ldrne pc,[r13],#4
    
    ldr r0,[r13],#4
    str pc,[r13,-#4]
    b protected_write_str_loop # start loop to navigate the buffer.

    ldrb r1,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_BARE_STATUS] # read mini-uart access.
    and r1,r1,#0xEE # turn off access (tx idle, tx free).
    strb r1,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_BARE_STATUS] # apply access.

    mov r0,#0 # 0 means: done.
    ldmfd r13!,{r1,pc} # quit routine.

protected_write:
    # 80 B

    and r0,r0,#0x000000FF
    stmfd r13!,{r0,r1}
    
    ldr r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_OWNED_TASK_ID]
    cmp r0,r2

    movne r0,#1 # 1 means: mini-uart is allocated by other process.
    ldrne r1,[r13],#4
    ldrne pc,[r13],#4

    ldr r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_BARE_STATUS] # check if mini-uart its empty.
    and r0,r0,#1
    cmp r0,#1
    
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
    # 40 B

    and r0,r0,#0x000000FF
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
    # 36 B
    ldr r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_OWNED_TASK_ID]
    cmp r0,r1

    movne r0,#1 # 1 mean: mini uart is allocated by other process.
    ldrne pc,[r13],#4

    str r0,[=MINI_UART_LICENSE,=MINI_UART_RX_BUFFER]
    str r1,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_RX_BUFFER_LEN]
    str r2,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_RX_BUFFER_SIZE]
    mov r0,#0 # 0 means: done.

    ldr pc,[r13],#4

allocate_serial:
    # 48 B
    str r1,[r13,-#4]!
    mov r1,r0
    and r1,r1,#0x000000FF
    ldr r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_OWNED_TASK_ID]
    cmp r0,r1

    movne r0,#1 
    ldmfdne r13!,{r1,pc}

    mov r0,r1
    ldr r1,[r13],#4
    
    strb r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_OWNED_TASK_ID]
    mov r0,#0

    ldr pc,[r13],#4

deallocate_serial:
    # 44 B
    str r1,[r13,-#4]!
    
    ldr r1,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_OWNED_TASK_ID]
    cmp r1,r0
    movne r0,#1
    ldmfdne r13!,{r1,pc}

    mov r0,#0
    str r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_RX_BUFFER]
    str r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_RX_BUFFER_LEN]
    str r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_RX_BUFFER_SIZE]

    ldmfd r13!,{r1,pc}

serial_settings:
    # 180 B
    stmfd r13!,{r1,r2}

    mov r2,r1
    ldrb r1,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_OWNED_TASK_ID]
    
    cmp r2,r1
    movne r0,#1
    ldmfdne r13!,{r2,r1,pc}
    
    ldrh r1,[r0]
    strh [=MINI_UART_BASE,=MINI_UART_BAUDRATE]

    ldr r2,[=MINI_UART_BASE,=MINI_UART_PREF]
    ldrb r1,[r0,#2]
    cmp r1,#0
    orrne r2,r2,#1 # turn on mini-uart enablation bit.
    andeq r2,r2,#0xFFFFFFFE # turn off mini-uart enablation bit.

    str r2,[=MINI_UART_BASE,=MINI_UART_PREF]
    
    ldr r2,[=GPIO_BASE,=GPIO_GPFSEL1] # enable pin 14,15 function mode for mini uart (alternative function 5)
    and r2,r2,#0xFFF60FFF
    orr r2,r2,#0xFFF72FFF

    ldr r2,[=MINI_UART_BASE,=MINI_UART_MU_CNTL]
    ldrb r1,[r0,#3]

    cmp r1,#0
    orrne r2,r2,#1
    andeq r2,r2,#0xFFFFFFFE

    ldrb r1,[r0,#4]
    
    cmp r1,#0
    orrne r2,r2,#2
    andeq r2,r2,#0xFFFFFFFC

    str r2,[=MINI_UART_BASE,=MINI_UART_MU_CNTL]

    ldr r2,[=MINI_UART_BASE,=MINI_UART_IIR]
    ldr r1,[r0,#5]

    cmp r1,#0
    orrne r2,r2,#1 # turn on receiver bit.
    andeq r2,r2,#0xFFFFFFFE # turn off receiver bit.

    ldr r1,[r0,#6]
    orrne r2,r2,#2 # turn on transmitter bit.
    andeq r2,r2,#0xFFFFFFC # turn off transmitter bit.

    str r2,[=MINI_UART_BASE,=MINI_UART_IIR]

    ldr r1,[r0,#7]
    ldr r2,[=MINI_UART_BASE,=MINI_UART_LCR]    

    cmp r1,#0
    orrne r2,r2,#1
    andeq r2,r2,#0xFFFFFFFE

    str r2,[=MINI_UART_BASE,=MINI_UART_LSR]
    mov r0,#0
    ldm r13!,{r2,r1,pc}

serial_status_check:
    # 136 B
    stmfd r13!,{r1,r2}
    mov r1,r0
    ldrb r0,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_OWNED_TASK_ID]

    cmp r0,r1
    movne r0,#1
    ldmfdne r13!,{r2,r1,pc}

    ldr r2,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_BARE_STATUS]

    ldr r0,[=MINI_UART_BASE,=MINI_UART_MU_CNTL]
    mov r1,r0
    
    and r0,r0,#1
    and r1,r1,#2

    cmp r0,#1
    orreq r2,r2,#8

    cmp r1,#2
    orreq r2,r2,#4

    ldr r0,[=MINI_UART_BASE,=MINI_UART_STAT]
    mov r1,r0

    and r0,r0,#4
    and r1,r1,#8

    cmp r0,#4
    orreq r2,r2,#0x20 
    
    cmp r1,#8
    orreq r1,r1,#0x10

    ldr r0,[=MINI_UART_BASE,=MINI_UART_LSR]
    and r0,r0,#1

    cmp r0,#1
    orreq r2,#0x40

    ldr r0,[=MINI_UART_BASE,=MINI_UART_PREF]
    and r0,r0,#1
    
    cmp r0,#1
    orreq r2,#0x80 

    str r2,[=MINI_UART_LICENSE,=MINI_UART_LICENSE_BARE_STATUS]
    mov r0,r2

    ldmfd r13!,{r2,r1,pc} 


@ gpio_set_mode: # pin 14,15 are not allowed to use (its busy by serial).
@     cmp r0,#14
@     cmpeq r1,#1
@     ldreq pc,[r13],#4 # test for pin 14

@     cmp r0,#15
@     cmpeq r1,#1
@     ldreq pc,[r13],#4 # test for pin 15

@     stmfd r13!,{r1-r4} # save minimum context

@     mul r4,r1,#4
@     mul r3,#3,r0

@     mov r0,#1,LSL r3
@     sub r3,r3,#1
@     mov r1,#1,LSL r3
@     sub r3,r3,#1
@     mov r2,#1,LSL r3

@     orr r0,r0,r1
@     orr r0,r0,r2
@     orr r0,r0,r3

@     mvn r0,r0

@     ldr r1,[=GPIO_BASE,r4]
@     and r1,r1,r0

@     ldr r2,[r13,#8] # restore nth of pin.

toggle_onboard_led:
    # 60 B

    stmfd r13!,{r0-r2}

    ldr r0,[=GPIO_BASE,=GPIO_GPCLR1]
    ldr r1,[=GPIO_BASE,=GPIO_GPSET1]

    mov r2,#1,LSL #14
    
    and r0,r0,r2
    and r1,r1,r2

    cmp r0,r2
    ldreq r0,[=GPIO_BASE,=GPIO_GPCLR1]
    orreq r0,r0,r2
    streq r0,[=GPIO_BASE,=GPIO_GPCLR1]
    ldmfdeq r13!,{r2,r1,r0,pc}

    ldr r1,[=GPIO_BASE,=GPIO_GPSET1]
    orr r1,r1,r2
    str r1,[=GPIO_BASE,=GPIO_GPSET1]
    ldmfd r13!,{r2,r1,r0,pc}

.ltorg