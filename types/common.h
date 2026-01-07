#ifndef TYPES_H
#define TYPES_H

#define GPIO_BASE 0x7E20
#define GPIO_GPFSEL0 0x0
#define GPIO_GPFSEL1 0x4
#define GPIO_GPFSEL2 0x8
#define GPIO_GPFSEL3 0xC
#define GPIO_GPFSEL4 0x10
#define GPIO_GPFSEL5 0x14

#define GPIO_GPSET0 0x001C
#define GPIO_GPSET1 0x0020

#define GPIO_GPCLR0 0x0028
#define GPIO_GPCLR1 0x002C

typedef unsigned char ubyte_t;
typedef unsigned short int u16_t;
typedef unsigned int u32_t;
#endif