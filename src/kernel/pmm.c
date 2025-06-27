#include "pmm.h"

#define BLOCK_SIZE 4096 // Each block is 4KB

static uint8_t* bitmap;       // Pointer to the bitmap tracking used/free blocks
static uint32_t total_blocks; // Total number of blocks managed

// Initialize the physical memory manager
void pmm_init(uint32_t mem_size, uint32_t bitmap_addr) {
    bitmap = (uint8_t*)bitmap_addr;           // Set bitmap location
    total_blocks = mem_size / BLOCK_SIZE;     // Calculate total number of blocks
    memset(bitmap, 0, total_blocks / 8);      // Mark all blocks as free (0)
}

// Allocate a single free 4KB block and return its address
void* pmm_alloc_block() {
    for (uint32_t i = 0; i < total_blocks; i++) {
        uint32_t byte = i / 8, bit = i % 8;
        if (!(bitmap[byte] & (1 << bit))) {   // If block is free
            bitmap[byte] |= (1 << bit);       // Mark block as used
            return (void*)(i * BLOCK_SIZE);   // Return address of block
        }
    }
    return 0; // Out of memory
}

// Free a previously allocated 4KB block
void pmm_free_block(void* addr) {
    uint32_t block = ((uint32_t)addr) / BLOCK_SIZE; // Find block index
    bitmap[block / 8] &= ~(1 << (block % 8));       // Mark block as free
}