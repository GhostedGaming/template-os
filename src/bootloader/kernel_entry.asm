[bits 32]
global _start

_start:
    extern main
    call main
.hang:
    hlt
    jmp .hang