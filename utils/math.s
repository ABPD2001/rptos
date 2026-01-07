max:
    cmp r0,r1
    movge r0,r0
    movls r0,r1
    mov pc,lr

min:
    cmp r0,r1
    movge r0,r1
    movls r0,r0
    mov pc,lr