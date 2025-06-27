org 0x7C00                  ; Boot sector loads at memory address 0x7C00

start:
    cli                     ; Disable interrupts
    mov [boot_disk], dl     ; Save boot disk number

    ; Set video mode to 80x25 text mode
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Setup stack in real mode
    xor ax, ax
    mov ss, ax
    mov sp, 0x7C00          ; Stack grows down from 0x7C00

    ; Load 32 sectors from disk (LBA 1..32) to 0x1000
    mov bx, 0x1000          ; Start loading at 0x1000
    mov cl, 2               ; Start at sector 2 (sector 1 is the boot sector)
    mov si, 32              ; Number of sectors to load

load_loop:
    mov ax, 0x0000
    mov es, ax              ; ES = 0
    mov ah, 0x02            ; BIOS read sectors function
    mov al, 1               ; Read 1 sector
    mov ch, 0               ; Cylinder 0
    mov dh, 0               ; Head 0

    int 0x13                ; BIOS disk interrupt
    jc disk_error           ; Jump if carry flag set (error)

    add bx, 0x200           ; Move to next 512-byte block
    inc cl                  ; Next sector
    dec si                  ; Decrement sector count
    jnz load_loop           ; Repeat if more sectors to load

    ; Setup GDT (Global Descriptor Table)
    lgdt [gdt_descriptor]

    ; Enter protected mode
    mov eax, cr0
    or eax, 1               ; Set PE (Protection Enable) bit
    mov cr0, eax

    ; Far jump to flush pipeline and load CS with new selector
    jmp 0x08:protected_mode_start

disk_error:
    mov si, disk_msg        ; Point to error message
.print:
    lodsb                   ; Load next byte from string
    or al, al               ; Check for null terminator
    jz .hang                ; If zero, end of string
    mov ah, 0x0E            ; BIOS teletype output
    int 0x10
    jmp .print
.hang:
    jmp .hang               ; Infinite loop on error

disk_msg db 'Disk read error!', 0

boot_disk: db 0             ; Storage for boot disk number

gdt_start:
    dq 0                    ; Null descriptor

    ; Code segment descriptor (base=0, limit=4GB, type=code)
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

    ; Data segment descriptor (base=0, limit=4GB, type=data)
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Size of GDT - 1
    dd gdt_start                ; Address of GDT

[bits 32]
protected_mode_start:
    mov ax, 0x10            ; 0x10 = data segment selector in GDT
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x9FC00        ; Set up stack pointer (just below 640KB)
    mov ebp, esp            ; Set base pointer

    jmp 0x08:0x1000         ; Jump to kernel entry (0x1000, code segment selector 0x08)

times 510-($-$$) db 0       ; Pad boot sector to 510 bytes
db 0x55, 0xAA               ; Boot sector signature also known as magic number