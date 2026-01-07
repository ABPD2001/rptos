#ifndef MINI_UART_SYSCALLS_H
#define MINI_UART_SYSCALLS_H
#include "../types/common.h"
#include "../types/swi.h"

extern u32_t kpwrite(char ch);
extern u32_t kwrite(char ch);
extern u32_t kpstrwrite(char *chars);
extern u32_t read(char *buffer, u32_t len, u32_t size);
extern u32_t kalloc_serial(ubyte_t task_id);
extern u32_t kfree_serial();
extern u32_t kserial_settings(UART_settings_t *settings);
extern u32_t kserial_status_check();
extern void ktoggle_led();
#endif