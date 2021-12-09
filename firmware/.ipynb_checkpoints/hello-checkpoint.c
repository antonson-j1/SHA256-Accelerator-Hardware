// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include "firmware.h"

#define STAT_ADDR 0x21000000
void send_stat(bool status);
void send_stat(bool status)
{
    if (status) {
        *((volatile int *)STAT_ADDR) = 1;
    } else {
        *((volatile int *)STAT_ADDR) = 0;
    }
}

#define BASE 0x30000000
#define INPUT_BASE 0x30000300
#define OUTPUT_BASE 0x30000200

#define START_SIG 0x01
#define TIMEOUT 1000

// Function prototypes
void WriteMessage(int, int, int, int, int, int, int, int, int, int, int, int, int, int, int, int);

void StartAndWait(void);
void GetOutput(void);

//Sending message input
void WriteMessage(int x1, int x2, int x3, int x4, int x5, int x6, int x7, int x8, int x9, int x10, int x11, int x12, int x13, int x14, int x15, int x16)
{
    volatile int *p = (int *)INPUT_BASE;
    *p = x1;
    p = p + 1;
    *p = x2;
    p = p + 1;
    *p = x3;
    p = p + 1;
    *p = x4;
    p = p + 1;
    *p = x5;
    p = p + 1;
    *p = x6;
    p = p + 1;
    *p = x7;
    p = p + 1;
    *p = x8;
    p = p + 1;
    *p = x9;
    p = p + 1;
    *p = x10;
    p = p + 1;
    *p = x11;
    p = p + 1;
    *p = x12;
    p = p + 1;
    *p = x13;
    p = p + 1;
    *p = x14;
    p = p + 1;
    *p = x15;
    p = p + 1;
    *p = x16;
    p = p + 1;
    
    /**p = x[0];
    for(int i = 1; i < 16; i++){
        p = p + 1;
        *p = x[i];
    }*/
}

//wait until the signal "ready" comes back as 1
void StartAndWait(void)
{
    volatile int *p = (int *)BASE;
    *p = START_SIG; 
    // Remove the reset signal.  
    *p = 0;
    bool rdy = false;
    int count = 0;
    while (!rdy && (count < TIMEOUT)) {
        volatile int x = (*p); // read from MULT_BASE
        if ((x & 0x01) == 1) rdy = true;
        count ++;
    }
    if (count == TIMEOUT) {
        print_str("TIMED OUT: did not get a 'rdy' signal back!");
    }
}


void GetOutput(void)
{
    volatile int *p = (int *)OUTPUT_BASE;
    print_dec(*p);
    print_str(" ");
    for(int i = 1; i < 8; i++){
        p = p + 1;
        print_dec(*p);
        print_str(" ");
    }
    
}

void hello(void)
{
    //int x[16] = {0x70726F6A, 0x65637466, 0x7067612E, 0x636F6D80, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000078};
    
    int x1 = 0x70726F6A;
    int x2 = 0x65637466;
    int x3 = 0x7067612E;
    int x4 = 0x636F6D80;
    int x5 = 0x00000000;
    int x6 = 0x00000000;
    int x7 = 0x00000000;
    int x8 = 0x00000000;
    int x9 = 0x00000000;
    int x10 = 0x00000000;
    int x11 = 0x00000000;
    int x12 = 0x00000000;
    int x13 = 0x00000000;
    int x14 = 0x00000000;
    int x15 = 0x00000000;
    int x16 = 0x00000078;
    
    WriteMessage(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16);
    StartAndWait();
    GetOutput();
    
/*
e2547202 3797185026
08ff3334 150942516
31f723cb 838280139
e00b9c1d 3758857245
45fc65b7 1174169015
ac165015 2887143445
1a3d8eb0 440241840
cbd885a3 3419964835

3419964835 440241840 2887143445 1174169015 3758857245 838280139 150942516 3797185026
    
    */
    send_stat(true);
}