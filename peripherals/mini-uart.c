#include "./mini-uart.h"

int serial_protected_write(char *chars)
{
    volatile int *license_bare_status = MINI_UART_LICENSE + MINI_UART_LICENSE_BARE_STATUS;
    volatile int *mini_uart_mu_io = MINI_UART_BASE + MINI_UART_MU_IO;

    while (1)
    {
        if (*license_bare_status & 0b1)
            continue;
        if (*chars == NULL)
            break;
        *(mini_uart_mu_io) &= 0xFFFFFF00; // clear byte in
        *(mini_uart_mu_io) |= (*chars);   // store byte into mu_io register.
        chars++;
    }

    return 0;
}
int serial_protected_write(char ch)
{
    volatile int *license_bare_status = MINI_UART_LICENSE + MINI_UART_LICENSE_BARE_STATUS;
    volatile int *mini_uart_mu_io = MINI_UART_BASE + MINI_UART_MU_IO;

    if (*license_bare_status & 0b1)
        return 1;
    *(mini_uart_mu_io) &= 0xFFFFFF00; // clear byte in mu_io
    *(mini_uart_mu_io) |= ch;         // store byte into mu_io register.
    return 0;
}

void serial_write(char *chars)
{
    volatile int *mini_uart_mu_io = MINI_UART_BASE + MINI_UART_MU_IO;

    while (1)
    {
        if (*chars == NULL)
            break;
        *(mini_uart_mu_io) &= 0xFFFFFF00; // clear byte in
        *(mini_uart_mu_io) |= (*chars);   // store byte into mu_io register.
        chars++;
    }
}

void serial_write(char ch)
{
    volatile int *mini_uart_mu_io = MINI_UART_BASE + MINI_UART_MU_IO;

    *(mini_uart_mu_io) &= 0xFFFFFF00; // clear byte in
    *(mini_uart_mu_io) |= (u32_t)ch;  // store byte into mu_io register.
}

void serial_read(char *buffer, u32_t length, u32_t size)
{
    UART_LICENSE_t *license = MINI_UART_LICENSE;
    license->uart_buffer_length = length;
    license->uart_buffer_size = size;
    license->uart_buffer = buffer;
}

void serial_settings(UART_settings_t *settings)
{
    if (settings->enabled)
    {
        set_pin_mode(GPIO_ALT5, GPIO_GPFSEL1, 5); // set function for gpio 14
        set_pin_mode(GPIO_ALT5, GPIO_GPFSEL1, 6); // set function for gpio 15
        volatile int *uart_preph = MINI_UART_BASE + MINI_UART_PREF;

        *uart_preph |= 0b1; // enable mini-uart.
    }
    else
    {
        set_pin_mode(GPIO_INPUT, GPIO_GPFSEL1, 5); // set function for gpio 14
        set_pin_mode(GPIO_INPUT, GPIO_GPFSEL1, 6); // set function for gpio 15
        volatile int *uart_preph = MINI_UART_BASE + MINI_UART_PREF;

        *uart_preph &= 0xFFFFFFFE; // disable mini-uart.
    }

    volatile int *baudrate = MINI_UART_BASE + MINI_UART_BAUDRATE;
    *baudrate = (u32_t)settings->baudrate; // set baudrate.

    if (settings->data_size)
    {
        volatile int *lcr = MINI_UART_BASE + MINI_UART_LCR;
        *lcr |= 0b1; // enable 8-bits mode.
    }
    else
    {
        volatile int *lcr = MINI_UART_BASE + MINI_UART_LCR;
        *lcr &= 0xFFFFFFFE; // enable 7-bits mode.
    }
    volatile int *stat = MINI_UART_BASE + MINI_UART_STAT;
    volatile int *iir = MINI_UART_BASE + MINI_UART_IIR;

    if (settings->rx_enabled)
        *stat |= 0b1; // enable receiver.
    else
        *stat &= 0xFFFFFFFE; // disabled receiver.

    if (settings->tx_enabled)
        *stat |= 0b10; // enable transmitter.
    else
        *stat &= 0b10; // disable transmitter.

    if (settings->tx_irq_enabled)
        *iir |= 0b1; // disable transmitter irq.
    else
        *iir &= 0xFFFFFFFE; // enable transmitter irq.

    if (settings->rx_irq_enabled)
        *iir |= 0b10; // enable receiver irq.
    else
        *iir &= 0xFFFFFFFD; // disable receiver irq.
    toggle_led();
}