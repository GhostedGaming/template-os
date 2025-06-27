#include "util.h"

// Sets 'count' bytes at 'dest' to the value 'val'
void memset(void* dest, uint8_t val, uint32_t count) {
    uint8_t* ptr = (uint8_t*)dest;
    for (uint32_t i = 0; i < count; i++) {
        ptr[i] = val;
    }
}
