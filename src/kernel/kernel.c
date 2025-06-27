#define VGA_BUFFER 0xb8000

void draw(char *word) {
    char* vga = (char*)VGA_BUFFER;
    int i = 0;
    while (word[i]) {
        vga[i * 2] = word[i];
        vga[i * 2 + 1] = 0x0F;
        i++;
    }
}

void main() {
    draw((char*)"Hello, world!");
}