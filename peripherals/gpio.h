#ifndef GPIO_H
#define GPIO_H
#define GPIO_OUT 0b001
#define GPIO_IN 0b000
#define GPIO_ALT5 0b010
#include "../utils/math.h"

void set_pin_mode(int mode, int *function_table, u32_t nth);
void set_pin(int *set_table, u32_t nth);
void clear_pin(int *clear_table, u32_t nth);
void toggle_pin(int *clear_table, int *set_table, u32_t nth);
#endif