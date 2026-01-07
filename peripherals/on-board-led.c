#include "./on-board-led.h"

void initialize_onboard_led()
{
    volatile int *funcntion_select_4 = (GPIO_BASE + GPIO_GPFSEL4);
    *funcntion_select_4 = *funcntion_select_4 & ~(0b001 << 20);
}

void toggle_led()
{
    volatile int *gp_clear1 = (GPIO_BASE + GPIO_GPCLR1);
    volatile int *gp_set1 = (GPIO_BASE + GPIO_GPSET1);

    if ((*gp_clear1 & (1 << 14)) == (1 << 14))
        *gp_set1 = *gp_set1 | (1 << 14);
    else
        *gp_clear1 = *gp_clear1 | (1 << 14);
}

void set_led()
{
    volatile int *gp_clear1 = (GPIO_BASE + GPIO_GPCLR1);
    *gp_clear1 = *gp_clear1 | (1 << 14);
}

void clear_led()
{
    volatile int *gp_set1 = (GPIO_BASE + GPIO_GPSET1);
    *gp_set1 = *gp_set1 | (1 << 14);
}