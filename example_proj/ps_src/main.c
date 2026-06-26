#include <stdio.h>
#include "xil_printf.h"
#include <sleep.h>
#include <stdlib.h>

#define AXI_BASEADDR  0x40000000
#define AXI_SIZE      0x2000000   /* 32 MB */

int main(void)
{
    xil_printf("Hello World\r\n");
    while (1);
    return 0;
}
