SECTIONS {
        . = 0x037F8000;

        .text : { *(.text) }
        .data : { *(.data) }
        .bss : { *(.bss) }
}
