#include "./gpio.h"

void set_pin_mode(int mode, int *function_table, u32_t nth)
{
    *function_table = (*function_table) & ~(111 << (3 * (max(0, nth - 1))));
    *function_table = *function_table | (mode << (nth - 1));
}

void set_pin(int *set_table, u32_t nth)
{
    *set_table &= ~(1 << (nth - 1));
    *set_table |= (1 << (nth - 1));
}

void clear_pin(int *clear_table, u32_t nth)
{
    *clear_table &= ~(1 << (nth - 1));
    *clear_table |= (1 << (nth - 1));
}

void toggle_pin(int *clear_table, int *set_table, u32_t nth)
{
    if (*clear_table & (1 << nth))
        clear_pin(clear_table, nth);
    else
        set_pin(set_table, nth);
}