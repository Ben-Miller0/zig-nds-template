SECTIONS {
        . = 0x02000000;

        .text : { *(.text) }
        .data : { *(.data) }
        .bss : { *(.bss) }
}
