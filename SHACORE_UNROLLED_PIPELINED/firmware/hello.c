#include "firmware.h"
#include "stats_helper.c"


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
#define INPUT_BASE 0x30000100
#define OUTPUT_BASE 0x30000200

#define START_SIG 0x01
#define TIMEOUT 1000

#define ROTLEFT(a,b) (((a) << (b)) | ((a) >> (32-(b))))
#define ROTRIGHT(a,b) (((a) >> (b)) | ((a) << (32-(b))))

#define CH(x,y,z) (((x) & (y)) ^ (~(x) & (z)))
#define MAJ(x,y,z) (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))
#define EP0(x) (ROTRIGHT(x,2) ^ ROTRIGHT(x,13) ^ ROTRIGHT(x,22))
#define EP1(x) (ROTRIGHT(x,6) ^ ROTRIGHT(x,11) ^ ROTRIGHT(x,25))
#define SIG0(x) (ROTRIGHT(x,7) ^ ROTRIGHT(x,18) ^ ((x) >> 3))
#define SIG1(x) (ROTRIGHT(x,17) ^ ROTRIGHT(x,19) ^ ((x) >> 10))

void WriteMessage(unsigned int x[16]);
void StartAndWait(void);
void GetOutput_print(void);
void GetOutput(void);

//Sending message input
void WriteMessage(unsigned int x[16])
{
    volatile unsigned int *p = (unsigned int *)INPUT_BASE;
    *p = x[0];
    for(int i = 1; i < 16; i++){
        p = p + 1;
        *p = x[i];
    }
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
    volatile unsigned int *p = (unsigned int *)OUTPUT_BASE;
    //print_dec(*p);
    //print_str(" ");
    for(int i = 1; i < 8; i++){
        p = p + 1;
        //print_dec(*p);
        //print_str(" ");
    }
    
}

int sha_256(unsigned int message[16]);
void sha_256_print(unsigned int message[16]);

int sha_256(unsigned int message[16])
{
    unsigned int k[64];
    k[0] = 0x428a2f98;
    k[1] = 0x71374491;
    k[2] = 0xb5c0fbcf;
    k[3] = 0xe9b5dba5;
    k[4] = 0x3956c25b;
    k[5] = 0x59f111f1;
    k[6] = 0x923f82a4;
    k[7] = 0xab1c5ed5;
	k[8] = 0xd807aa98;
    k[9] = 0x12835b01;
    k[10] = 0x243185be;
    k[11] = 0x550c7dc3;
    k[12] = 0x72be5d74;
    k[13] = 0x80deb1fe;
    k[14] = 0x9bdc06a7;
    k[15] = 0xc19bf174;
	k[16] = 0xe49b69c1;
    k[17] = 0xefbe4786;
    k[18] = 0x0fc19dc6;
    k[19] = 0x240ca1cc;
    k[20] = 0x2de92c6f;
    k[21] = 0x4a7484aa;
    k[22] = 0x5cb0a9dc;
    k[23] = 0x76f988da;
	k[24] = 0x983e5152;
    k[25] = 0xa831c66d;
    k[26] = 0xb00327c8;
    k[27] = 0xbf597fc7;
    k[28] = 0xc6e00bf3;
    k[29] = 0xd5a79147;
    k[30] = 0x06ca6351;
    k[31] = 0x14292967;
	k[32] = 0x27b70a85;
    k[33] = 0x2e1b2138;
    k[34] = 0x4d2c6dfc;
    k[35] = 0x53380d13;
    k[36] = 0x650a7354;
    k[37] = 0x766a0abb;
    k[38] = 0x81c2c92e;
    k[39] = 0x92722c85;
	k[40] = 0xa2bfe8a1;
    k[41] = 0xa81a664b;
    k[42] = 0xc24b8b70;
    k[43] = 0xc76c51a3;
    k[44] = 0xd192e819;
    k[45] = 0xd6990624;
    k[46] = 0xf40e3585;
    k[47] = 0x106aa070;
	k[48] = 0x19a4c116;
    k[49] = 0x1e376c08;
    k[50] = 0x2748774c;
    k[51] = 0x34b0bcb5;
    k[52] = 0x391c0cb3;
    k[53] = 0x4ed8aa4a;
    k[54] = 0x5b9cca4f;
    k[55] = 0x682e6ff3;
	k[56] = 0x748f82ee;
    k[57] = 0x78a5636f;
    k[58] = 0x84c87814;
    k[59] = 0x8cc70208;
    k[60] = 0x90befffa;
    k[61] = 0xa4506ceb;
    k[62] = 0xbef9a3f7;
    k[63] = 0xc67178f2;

    unsigned int h0, h1, h2, h3, h4, h5, h6, h7;
    h0 = 0x6a09e667;
	h1 = 0xbb67ae85;
	h2 = 0x3c6ef372;
	h3 = 0xa54ff53a;
	h4 = 0x510e527f;
	h5 = 0x9b05688c;
	h6 = 0x1f83d9ab;
	h7 = 0x5be0cd19;

    unsigned int a,b,c,d,e,f,g,h;
    a = h0;
	b = h1;
	c = h2;
	d = h3;
	e = h4;
	f = h5;
	g = h6;
	h = h7;

    unsigned int w[64];
    unsigned int s0, s1;
    for(int i = 0; i < 16; i++)
    {
        w[i] = message[i];
    }
    
    for(int i = 16; i < 64; i++)
    {    
        s0 = SIG0(w[i-15]);
        s1 = SIG1(w[i-2]);
        w[i] = s0 + s1 + w[i-16] + w[i-7];
    }
        
    unsigned int temp1, ch, S1, S0, maj, temp2;
    for (int i = 0; i < 64; i++)
    {
        S1 = EP1(e);
        ch = CH(e,f,g);
        temp1 = h + S1 + ch + k[i] + w[i];
        S0 = EP0(a);
        maj = MAJ(a,b,c);
        temp2 = S0 + maj;

        h = g;
        g = f;
        f = e;
        e = d + temp1;
        d = c;
        c = b;
        b = a;
        a = temp1 + temp2;
    }

    unsigned int hash_output[8];
    hash_output[0] = h0 + a;
    hash_output[1] = h1 + b;
    hash_output[2] = h2 + c;
    hash_output[3] = h3 + d;
    hash_output[4] = h4 + e;
    hash_output[5] = h5 + f;
    hash_output[6] = h6 + g;
    hash_output[7] = h7 + h;

    for(int i = 0; i < 8; i++)
    {    //print_dec(hash_output[i]);
         //print_str(" ");
    } 

    return (hash_output[0]);
}


void sha_256_print(unsigned int message[16])
{
    unsigned int k[64];
    k[0] = 0x428a2f98;
    k[1] = 0x71374491;
    k[2] = 0xb5c0fbcf;
    k[3] = 0xe9b5dba5;
    k[4] = 0x3956c25b;
    k[5] = 0x59f111f1;
    k[6] = 0x923f82a4;
    k[7] = 0xab1c5ed5;
	k[8] = 0xd807aa98;
    k[9] = 0x12835b01;
    k[10] = 0x243185be;
    k[11] = 0x550c7dc3;
    k[12] = 0x72be5d74;
    k[13] = 0x80deb1fe;
    k[14] = 0x9bdc06a7;
    k[15] = 0xc19bf174;
	k[16] = 0xe49b69c1;
    k[17] = 0xefbe4786;
    k[18] = 0x0fc19dc6;
    k[19] = 0x240ca1cc;
    k[20] = 0x2de92c6f;
    k[21] = 0x4a7484aa;
    k[22] = 0x5cb0a9dc;
    k[23] = 0x76f988da;
	k[24] = 0x983e5152;
    k[25] = 0xa831c66d;
    k[26] = 0xb00327c8;
    k[27] = 0xbf597fc7;
    k[28] = 0xc6e00bf3;
    k[29] = 0xd5a79147;
    k[30] = 0x06ca6351;
    k[31] = 0x14292967;
	k[32] = 0x27b70a85;
    k[33] = 0x2e1b2138;
    k[34] = 0x4d2c6dfc;
    k[35] = 0x53380d13;
    k[36] = 0x650a7354;
    k[37] = 0x766a0abb;
    k[38] = 0x81c2c92e;
    k[39] = 0x92722c85;
	k[40] = 0xa2bfe8a1;
    k[41] = 0xa81a664b;
    k[42] = 0xc24b8b70;
    k[43] = 0xc76c51a3;
    k[44] = 0xd192e819;
    k[45] = 0xd6990624;
    k[46] = 0xf40e3585;
    k[47] = 0x106aa070;
	k[48] = 0x19a4c116;
    k[49] = 0x1e376c08;
    k[50] = 0x2748774c;
    k[51] = 0x34b0bcb5;
    k[52] = 0x391c0cb3;
    k[53] = 0x4ed8aa4a;
    k[54] = 0x5b9cca4f;
    k[55] = 0x682e6ff3;
	k[56] = 0x748f82ee;
    k[57] = 0x78a5636f;
    k[58] = 0x84c87814;
    k[59] = 0x8cc70208;
    k[60] = 0x90befffa;
    k[61] = 0xa4506ceb;
    k[62] = 0xbef9a3f7;
    k[63] = 0xc67178f2;

    unsigned int h0, h1, h2, h3, h4, h5, h6, h7;
    h0 = 0x6a09e667;
	h1 = 0xbb67ae85;
	h2 = 0x3c6ef372;
	h3 = 0xa54ff53a;
	h4 = 0x510e527f;
	h5 = 0x9b05688c;
	h6 = 0x1f83d9ab;
	h7 = 0x5be0cd19;

    unsigned int a,b,c,d,e,f,g,h;
    a = h0;
	b = h1;
	c = h2;
	d = h3;
	e = h4;
	f = h5;
	g = h6;
	h = h7;

    unsigned int w[64];
    unsigned int s0, s1;
    for(int i = 0; i < 16; i++)
    {
        w[i] = message[i];
    }
    
    for(int i = 16; i < 64; i++)
    {    
        s0 = SIG0(w[i-15]);
        s1 = SIG1(w[i-2]);
        w[i] = s0 + s1 + w[i-16] + w[i-7];
    }
        
    unsigned int temp1, ch, S1, S0, maj, temp2;
    for (int i = 0; i < 64; i++)
    {
        S1 = EP1(e);
        ch = CH(e,f,g);
        temp1 = h + S1 + ch + k[i] + w[i];
        S0 = EP0(a);
        maj = MAJ(a,b,c);
        temp2 = S0 + maj;

        h = g;
        g = f;
        f = e;
        e = d + temp1;
        d = c;
        c = b;
        b = a;
        a = temp1 + temp2;
    }

    unsigned int hash_output[8];
    hash_output[0] = h0 + a;
    hash_output[1] = h1 + b;
    hash_output[2] = h2 + c;
    hash_output[3] = h3 + d;
    hash_output[4] = h4 + e;
    hash_output[5] = h5 + f;
    hash_output[6] = h6 + g;
    hash_output[7] = h7 + h;

    for(int i = 0; i < 8; i++)
    {    print_hex(hash_output[i], 8);
         print_str(" ");
    } 
}




void hello(void)
{

    unsigned int message[16];
    
    message[0] = 0x70726F6A; //1886547818
    message[1] = 0x65637466; //1701016678
    message[2] = 0x7067612E; //1885823278
    message[3] = 0x636F6D80; //1668246912
    message[4] = 0x00000000;
    message[5] = 0x00000000;
    message[6] = 0x00000000;
    message[7] = 0x00000000;
    message[8] = 0x00000000;
    message[9] = 0x00000000;
    message[10] = 0x00000000;
    message[11] = 0x00000000;
    message[12] = 0x00000000;
    message[13] = 0x00000000;
    message[14] = 0x00000000;
    message[15] = 0x00000078; //120
    
    print_str("\nHashed Value in hex: ");
    sha_256_print(message);
    
    unsigned int t_start1 = get_num_cycles();
    unsigned int num_instr_start1 = get_num_instr();
    
    sha_256(message);
    
    unsigned int num_instr_end1 = get_num_instr();
    unsigned int t_end1   = get_num_cycles();
    
    print_str("\n\nSoftware Calculation Completed in ");
    unsigned int num_cycles1 = t_end1 - t_start1;
    print_dec(t_end1 - t_start1);
	print_str(" cycles.\n");

    unsigned int num_instr1 = num_instr_end1- num_instr_start1;//num_instr_end1;
    print_str("Instruction counter ..");
	print_dec(num_instr1);
	print_str("\nCPI: ");
	stats_print_dec((num_cycles1 / num_instr1), 0, false);
	print_str(".");
	stats_print_dec(((100 * num_cycles1) / num_instr1) % 100, 2, true);
	print_str("\n");
    
    
    //print_str("\nHardware Hashed Value in dec: ");
    print_str("\n");
    unsigned int t_start2 = get_num_cycles();
    unsigned int num_instr_start2 = get_num_instr();
    
    WriteMessage(message);
    StartAndWait();
    GetOutput();
    
    unsigned int num_instr_end2 = get_num_instr();
    unsigned int t_end2   = get_num_cycles();
    print_str("\nHardware Calculation Completed in ");
    unsigned int num_cycles2 = t_end2 - t_start2;
    print_dec(t_end2 - t_start2);
	print_str(" cycles.\n");
    
    unsigned int num_instr2 = num_instr_end2- num_instr_start2;
    print_str("Instruction counter ..");
	print_dec(num_instr2);
	print_str("\nCPI: ");
	stats_print_dec((num_cycles2 / num_instr2), 0, false);
	print_str(".");
	stats_print_dec(((100 * num_cycles2) / num_instr2) % 100, 2, true);
	print_str("\n\n");

    
    //print_str("\nTime taken for accelerator to compute: ");
    WriteMessage(message);
    
    print_str("\n");
    unsigned int t_start4 = get_num_cycles();
    unsigned int num_instr_start4 = get_num_instr();
    
    StartAndWait();
    
    unsigned int num_instr_end4 = get_num_instr();
    unsigned int t_end4   = get_num_cycles();
    print_str("Time taken for accelerator to compute:");
    unsigned int num_cycles4 = t_end4 - t_start4;
    print_dec(t_end4 - t_start4);
	print_str(" cycles.\n");
    
    unsigned int num_instr4 = num_instr_end4- num_instr_start4;
    print_str("Instruction counter ..");
	print_dec(num_instr4);
	print_str("\nCPI: ");
	stats_print_dec((num_cycles4 / num_instr4), 0, false);
	print_str(".");
	stats_print_dec(((100 * num_cycles4) / num_instr4) % 100, 2, true);
	print_str("\n\n");

    GetOutput();
    
    send_stat(true);
}