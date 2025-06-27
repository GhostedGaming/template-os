global disable_interrupts
global enable_interrupts            ; This makes the label global so you can call it from your C code

disable_interrupts:
    cli             ; Disable interrupts
    ret

enable_interrupts:
    sti             ; Enable interrupts
    ret