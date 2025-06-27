org 0x7C00

start:
    cli
    mov [boot_disk], dl

    ; Set video mode to 80x25 text mode
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Setup stack
    xor ax, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Load 32 sectors from disk (LBA 1..32) to 0x1000
    mov bx, 0x1000        ; Start loading at 0x1000
    mov cl, 2             ; Start at sector 2
    mov si, 32            ; Number of sectors to load

load_loop:
    mov ax, 0x0000
    mov es, ax            ; ES = 0
    mov ah, 0x02          ; BIOS read sectors
    mov al, 1             ; Read 1 sector
    mov ch, 0             ; Cylinder 0
    mov dh, 0             ; Head 0
    ; cl already set to sector number
    int 0x13
    jc disk_error

    add bx, 0x200         ; Next 512 bytes
    inc cl                ; Next sector
    dec si
    jnz load_loop

    ; Setup GDT
    lgdt [gdt_descriptor]

    ; Enter protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Far jump to flush pipeline and load CS
    jmp 0x08:protected_mode_start

disk_error:
    mov si, disk_msg
.print:
    lodsb
    or al, al
    jz .hang
    mov ah, 0x0E
    int 0x10
    jmp .print
.hang:
    jmp .hang

disk_msg db 'Disk read error!', 0

boot_disk: db 0

gdt_start:
    dq 0                      ; Null descriptor

    ; Code segment descriptor
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

    ; Data segment descriptor
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

[bits 32]
protected_mode_start:
    mov ax, 0x10         ; Data segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Jump to loaded kernel at 0x1000 (must be 32-bit code)
    jmp 0x08:0x1000

times 510-($-$$) db 0
db 0x55, 0xAA