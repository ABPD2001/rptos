.section .vector_table
.org 0x0 reset_handler
.org 0x08 swi_handler
.org 0x18 irq_handler
.org 0x1c fiq_handler 

.ltorg
.section .vector_handlers
.eq SVC_MODE #0x13
.eq IRQ_MODE #0x12
.eq FIQ_MODE #0x11
.eq USR_MODE #0x10

.eq CLR_MODE #0xE0

.eq SVC_STACK #0x1020
.eq IRQ_STACK #0x1420
.eq FIQ_STACK #0x1620

.eq IRQ_ENABLE #0x40

.eq SYSTEM_TIMER_BASE #0x7E003000 # note: cs is 0x0 offset.
.eq C0_SYSTEM_TIMER_MATCH_OFFSET #0xC

.eq MINI_UART_BASE #0x7E21
.eq MINI_UART_IER_REG #0x5048
.eq MINI_UART_LSR_REG #0x5054

.eq MINI_UART_LICENSE #0x1B14 # ownership of mini uart by tasks or hardware limitation.

.eq VOID_IRQ #0x1B54

.eq SWI_TABLE #0x163C

.eq IRQ_TABLE #0x1624

reset_handler:
    # 64 B

    mov r13,=SVC_STACK
    
    mrs cpsr_c,r0
    and r0,=CLR_MODE
    orr r0,=IRQ_MODE
    mrs r0,cpsr_c
    mov r13,IRQ_STACK
    
    mrs cpsr_c,r0
    and r0,=CLR_MODE
    orr r0,=FIQ_MODE
    mrs r0,cpsr_c
    mov r13,=FIQ_STACK
    
    mrs cpsr_c,r0
    and r0,=CLR_MODE
    orr r0,=SVC_MODE
    mrs r0,cpsr_c

    b kernel # start kernel 

fiq_handler:
    # 4 B
    bl fiq_handler # dummy handler.

# IRQ IDs:
# 0: timer 0 period --> 0 pri.
# 1: mini uart has a valid byte in fifo --> 3 pri.
# 2: mini uart transmitter is free --> 4 pri. 
# 3: mini uart receiver overrun (rx fifo panic) --> 2 pri.
# 4: void irq --> 1 pri.
# 5: unkown irq -- pri 5. 
    

irq_routine_identifier:
    # 152 B
    ldr r0,[=SYSTEM_TIMER_BASE] # read cs register in system timer.
    and r0,r0,#1
    cmp r0,#1
    ldreq r0,[=SYSTEM_TIMER_BASE]
    and r0,r0,#3
    streq r0,[=SYSTEM_TIMER_BASE] # remove SYSTEM_TIMER_C0_IRQ mask.
    moveq r2,#0
    moveq pc,lr

    ldrb r0,[=VOID_IRQ] # check void irq.
    cmp r0,#0
    movge r2,#4
    movge pc,lr

    ldr r0,[=MINI_UART_BASE,=MINI_UART_IER_REG] # check if mini uart irq is pending (continue if is pending).
    and r0,r0,#1
    cmp r0,#0
    movne r2,#5 # unkown irq detected.
    movne pc,lr

    ldr r0,[=MINI_UART_BASE,=MINI_UART_LSR_REG] # check for reciver overrun.
    and r0,r0,#2
    cmp r0,#2
    moveq r2,#3
    moveq pc,lr

    ldr r0,[=MINI_UART_BASE,=MINI_UART_IER_REG] # read mini uart offset.
    mov r1,r0
    and r0,r0,#4
    cmp r0,#4
    moveq r2,r2,#1
    ldreq r0,[=MINI_UART_BASE,=MINI_UART_IER_REG]
    orreq r0,r0,#2
    streq r0,[=MINI_UART_BASE,=MINI_UART_IER_REG] # remove mini uart RX_FIFO_IRQ mask.
    moveq pc,lr

    and r1,r1,#2
    cmp r1,#2
    moveq r2,#2
    ldreq r0,[=MINI_UART_BASE,=MINI_UART_IER_REG]
    orreq r0,r0,#4
    streq r0,[=MINI_UART_BASE,=MINI_UART_IER_REG] # remove mini uart TX_FIFO_IRQ mask.
    moveq pc,lr


irq_handler: # reentrant irq handler
    # 76 B
    subs lr,#4 # link register calculation.
    
    stmfd r13!,{lr,r0~r2}
    msr spsr_irq, r0 
    str r0,[r13,-#4]!  # minimum context saved.
    
    bl irq_routine_identifier # find triggred irq.    

    mov r1,r13 # save stack address to r1 (for passing to svc mode).
    msr cpsr_c,r0
    and r0,=CLR_MODE
    orr r0,=SVC_MODE
    orr r0,=IRQ_ENABLE
    mrs r0,cpsr_c # apply to svc mode and enable irqs.

    # at this point, r0 --> used to change mode, r1 --> 13, r2 --> irq id.
    # also in stack we have these: r2 (irq old register) - r1 (irq old register) - r0 (irq old register) - lr (return address)
    
    mov r0,r1 # pass stack to first argument.
    mov r1,#4
    mul r1,r1,r2
    add r1,=IRQ_TABLE # find ISR address via IRQ_TABLE.

    str pc,[r13,-#4]!
    mov pc,r1 # go to ISR.

    # note: we should add a return instruction to this block in end of ISR (for returning to return address).
    ldr r0,[r13],#4
    msr spsr_svc, r0 
    ldmfd r13!,{r2,r1,r0,pc}^ # back to task space.   


swi_handler:
    # 76 B
    stmfd r13!,{lr,r0~r2}
    msr spsr_svc, r0 
    str r0,[r13,-#4]!  # minimum context saved.
    
    and r2,lr,#0xFF000000 # read requested swi id.

    mov r1,r13 # save stack address to r1 (for passing to svc mode).
    msr cpsr_c,r0
    orr r0,r0,=IRQ_ENABLE
    mrs r0,cpsr_c # apply to enable irqs.

    mov r0,r1 # pass stack to first argument.
    mov r1,#4
    mul r1,r1,r2
    add r1,r1,=SWI_TABLE # find ISR address via SWI_TABLE.
    mov lr,r1

    str pc,[r13,-#4]!
    ldmfd r13!,{r2,r1,r0}
    str pc,[r13,#-4]!
    mov pc,lr # go to routine.

    # note: we should add a return instruction to this block in end of routine (for returning to return address).
    ldmfd r13!,{lr}
    mov pc,lr # back to tasks address   

.ltorg