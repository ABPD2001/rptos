#include "./timer.h"

void set_timer(u32_t time, u32_t nth)
{

    volatile u32_t *clo = (TIMER_BASE + TIMER_CLO);
    volatile u32_t *cnth = (TIMER_BASE + 0xC + nth * 4);

    *cnth = *clo + time; // set timer.
}

u64_t get_time()
{
    volatile u32_t *clo = (TIMER_BASE + TIMER_CLO);
    volatile u32_t *chi = (TIMER_BASE + TIMER_CHI);

    u64_t dword_time = (u64_t)clo | ((u64_t)chi << 32); // merge lower bits and higher bits.
    return dword_time;
}