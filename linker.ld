ENTRY(reset_handler)
SECTIONS {
    . = 0x0;
    .vector_table:{
        *(.vector_table)
    }
    . = 0x1624;
    .irq_table:{
        *(.irq_table)
    }
    . = 0x163C;
    .swi_table:{
        *(.swi_table)
    }
    . = 0x1664;
    .vector_handlers:{
        *(.vector_handlers)
    }
    
    . = 0x1798; 
    .swi_routines:{
        *(.swi_routines)
    }
    . = 0x1A30; 
    .irq_routines:{
        *(.irq_routines)
    }
    . = 0x1B88; 
    .text:{
        *(.text)
    }
    .rodata:{
        *(.rodata)
    }
    .data:{*(.data)}
    .bss:{*(.bss)}
    _stack_top = 0x8000000;
}