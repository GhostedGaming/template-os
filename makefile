AS=nasm
CC=i386-elf-gcc
LD=i386-elf-ld
OBJCOPY=i386-elf-objcopy

BOOT_SRC=src/bootloader/boot.asm
KERNEL_ENTRY_SRC=src/bootloader/kernel_entry.asm

OUTPUT=output
IMAGE=os.bin

# Find all C and ASM files (except boot.asm and kernel_entry.asm)
C_SRCS := $(shell find src/kernel -name '*.c')
ASM_SRCS := $(shell find src/bootloader -name '*.asm' ! -name 'boot.asm' ! -name 'kernel_entry.asm')

# Object files for C and ASM
C_OBJS := $(patsubst src/kernel/%.c,$(OUTPUT)/%.o,$(C_SRCS))
ASM_OBJS := $(patsubst src/bootloader/%.asm,$(OUTPUT)/%.o,$(ASM_SRCS))

# Special objects
BOOT_BIN=$(OUTPUT)/boot.bin
KERNEL_ENTRY_O=$(OUTPUT)/kernel_entry.o

KERNEL_ELF=$(OUTPUT)/kernel.elf
KERNEL_BIN=$(OUTPUT)/kernel.bin

all: $(IMAGE)

$(OUTPUT):
	mkdir -p $(OUTPUT)

# Compile all C files
$(OUTPUT)/%.o: src/kernel/%.c | $(OUTPUT)
	$(CC) -ffreestanding -m32 -c $< -o $@

# Assemble all ASM files (except boot.asm and kernel_entry.asm)
$(OUTPUT)/%.o: src/bootloader/%.asm | $(OUTPUT)
	$(AS) -f elf32 $< -o $@

# Assemble bootloader
$(BOOT_BIN): $(BOOT_SRC) | $(OUTPUT)
	$(AS) -f bin $(BOOT_SRC) -o $(BOOT_BIN)

# Assemble kernel entry
$(KERNEL_ENTRY_O): $(KERNEL_ENTRY_SRC) | $(OUTPUT)
	$(AS) -f elf32 $(KERNEL_ENTRY_SRC) -o $(KERNEL_ENTRY_O)

# Link kernel
$(KERNEL_ELF): $(KERNEL_ENTRY_O) $(C_OBJS) $(ASM_OBJS)
	$(LD) -Ttext 0x1000 -o $(KERNEL_ELF) -nostdlib --nmagic $(KERNEL_ENTRY_O) $(C_OBJS) $(ASM_OBJS)

# Convert kernel ELF to binary
$(KERNEL_BIN): $(KERNEL_ELF)
	$(OBJCOPY) -O binary $(KERNEL_ELF) $(KERNEL_BIN)

# Combine bootloader and kernel binary
$(IMAGE): $(BOOT_BIN) $(KERNEL_BIN)
	cat $(BOOT_BIN) $(KERNEL_BIN) > $(IMAGE)
	truncate -s $$((512*33)) $(IMAGE)

run: all
	qemu-system-x86_64 -drive format=raw,file=os.bin,index=0,if=floppy -m 128M

clean:
	rm -rf $(OUTPUT) $(IMAGE)

.PHONY: all clean run