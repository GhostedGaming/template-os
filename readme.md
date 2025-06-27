# Simple x86 OS Template

A minimal x86 OS template for learning and experimentation.
THIS DOES NOT SUPPORT MULTIBOOT!

## Features
- 16-bit bootloader loads a 32-bit kernel
- Simple VGA text output
- Easy to extend

## Build & Run

### Dependencies

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install nasm gcc-multilib qemu
```

#### Arch Linux
```bash
sudo pacman -Syu nasm qemu base-devel
yay -S i386-elf-gcc i386-elf-binutils
```

### Build
```bash
make
```

### Run
```bash
make run
```

## File Structure

- `src/bootloader/boot.asm` - Bootloader (16-bit)
- `src/bootloader/kernel_entry.asm` - Kernel entry (32-bit)
- `src/kernel/kernel.c` - Main kernel code
- `src/kernel/util.c`/`util.h` - Utility functions

## Extending

To add new kernel features, edit `src/kernel/kernel.c` and rebuild.