#include "../std/mini-uart.h"

int main()
{
    kalloc_serial(0x1);
    kpstrwrite("hello, world!");
    ktoggle_led();
}