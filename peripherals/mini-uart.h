#ifndef MINI_UART_H
#define MINI_UART_H
#include "../types/swi.h"
#include "../types/irq.h"
#include "../types/common.h"
#include "../peripherals/gpio.h"

int serial_protected_write(char *chars);
int serial_protected_write(char ch);

void serial_write(char *ch);
void serial_write(char ch);

void serial_read(char *buffer, u32_t length, u32_t size);
void serial_settings(UART_settings_t settings);
#endif