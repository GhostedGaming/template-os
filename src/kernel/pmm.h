#ifndef PMM_H
#define PMM_H

#include <stdint.h>

// Initialize the physical memory manager
// mem_size: total size of RAM in bytes
// bitmap_addr: address where the bitmap will be stored
void pmm_init(uint32_t mem_size, uint32_t bitmap_addr);

// Allocate a single 4KB block of physical memory
void* pmm_alloc_block();

// Free a previously allocated 4KB block
void pmm_free_block(void* addr);

#endif