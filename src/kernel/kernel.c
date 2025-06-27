#include "pmm.h"           // Physical memory manager header
#include "util.h"          // Include util.h where memset is declared

#define VGA_BUFFER 0xB8000 // VGA text buffer memory address

extern void disable_interrupts(void);
extern void enable_interrupts(void);    // External asm functions

// Function to draw a string to the top-left of the VGA text buffer
void draw(char *word) {
    char* vga = (char*)VGA_BUFFER; // Pointer to VGA memory
    int i = 0;
    while (word[i]) {              // Loop through each character in the string
        vga[i * 2] = word[i];      // Write character to VGA buffer
        vga[i * 2 + 1] = 0x0F;     // Set attribute byte (white on black)
        i++;
    }
}

// Kernel entry point
void main() {
    // Clear the VGA text buffer (80*25*2 bytes)
    memset((void*)VGA_BUFFER, 0, 80 * 25 * 2);

    draw((char*)"Hello, world!");  // Display "Hello, world!" on the screen
    while (1)
    {
        asm volatile ("hlt");      // Halt CPU until next interrupt (infinite loop)
    }
}