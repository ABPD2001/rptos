.global kwrite,kpwrite,kalloc_serial,kfree_serial,kserial_settings,kserial_status_check,ktoggle_led,kpstrwrite
kwrite:
    swi #1
    mov pc,lr

kpwrite:
    swi #0
    mov pc,lr

kread:
    swi #2
    mov pc,lr

kalloc_serial:
    swi #3
    mov pc,lr

kfree_serial:
    swi #4
    mov pc,lr

kserial_settings:
    swi #5
    mov pc,lr

kserial_status_check:
    swi #6
    mov pc,lr

ktoggle_led:
    swi #7
    mov pc,lr
    
kpstrwrite:
    swi #8
    mov pc,lr