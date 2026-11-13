ENTRY(ResetISR)

MEMORY
{
    FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 256K
    RAM   (rwx) : ORIGIN = 0x1FFFE000, LENGTH = 32K
}

_estack = ORIGIN(RAM) + LENGTH(RAM);
PROVIDE(_vStackTop = _estack);

SECTIONS
{
    /* Tabla de vectores: debe comenzar en 0x00000000 */
    .isr_vector :
    {
        . = ALIGN(4);
        KEEP(*(.isr_vector))
        . = ALIGN(4);
    } > FLASH

    /* Configuración de seguridad de Flash: dirección 0x400 */
    .FlashConfig 0x00000400 :
    {
        KEEP(*(.FlashConfig))
    } > FLASH

    /* Código y constantes */
    .text 0x00000410 :
    {
        . = ALIGN(4);
        *(.after_vectors*)
        *(.text*)
        *(.rodata*)
        *(.glue_7)
        *(.glue_7t)
        *(.vfp11_veneer)
        *(.ARM.extab*)
        *(.ARM.exidx*)
        . = ALIGN(4);
    } > FLASH

    /* Tabla de inicialización de .data */
    .data_section_table :
    {
        . = ALIGN(4);
        __data_section_table = .;

        LONG(LOADADDR(.data));
        LONG(ADDR(.data));
        LONG(SIZEOF(.data));

        __data_section_table_end = .;
    } > FLASH

    /* Tabla de inicialización de .bss */
    .bss_section_table :
    {
        . = ALIGN(4);
        __bss_section_table = .;

        LONG(ADDR(.bss));
        LONG(SIZEOF(.bss));

        __bss_section_table_end = .;
    } > FLASH

    /* Variables inicializadas: carga en Flash, ejecución en RAM */
    .data :
    {
        . = ALIGN(4);
        _sdata = .;
        *(.data*)
        . = ALIGN(4);
        _edata = .;
    } > RAM AT > FLASH

    /* Variables sin inicializar */
    .bss (NOLOAD) :
    {
        . = ALIGN(4);
        _sbss = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } > RAM

    /* Variables que no deben inicializarse */
    .noinit (NOLOAD) :
    {
        . = ALIGN(4);
        *(.noinit*)
        . = ALIGN(4);
    } > RAM

    /* Final de RAM y comienzo del heap*/
    _end = .;
    end = .;

    /* Comprobaciones */
    ASSERT(ADDR(.isr_vector) == 0x00000000,
           "La tabla de vectores no comienza en 0x00000000")

    ASSERT(ADDR(.FlashConfig) == 0x00000400,
           "FlashConfig no esta en 0x400")

    ASSERT(_end <= ORIGIN(RAM) + LENGTH(RAM),
           "La memoria RAM esta desbordada")
}
