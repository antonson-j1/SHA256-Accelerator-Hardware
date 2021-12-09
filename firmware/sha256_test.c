/*************************** HEADER FILES ***************************/
#include <stdio.h>
#include <memory.h>
#include <string.h>
#include <time.h>
#include "sha256.h"

/*********************** FUNCTION DEFINITIONS ***********************/
int sha256_test(BYTE text1[], BYTE text2[])
{

    BYTE buf1[SHA256_BLOCK_SIZE];
    BYTE buf2[SHA256_BLOCK_SIZE];
	SHA256_CTX ctx1;
    SHA256_CTX ctx2;
	int idx;
	int pass = 1;

	sha256_init(&ctx1);
	sha256_update(&ctx1, text1, strlen(text1));
	sha256_final(&ctx1, buf1);
    
    printf("The hashvalue calculated from Software for (1) = ");
    int i;
    for (i = 0; i < 32; i++)
    {
        printf("%02X", buf1[i]);
    }
    printf("\n");
    
    
    sha256_init(&ctx2);
	sha256_update(&ctx2, text2, strlen(text2));
	sha256_final(&ctx2, buf2);
    
    printf("The hashvalue calculated from Software for (2) = ");
    int j;
    for (j = 0; j < 32; j++)
    {
        printf("%02X", buf2[j]);
    }
    printf("\n");
    
    pass = pass && !memcmp(buf2, buf1, SHA256_BLOCK_SIZE);
    
	return(pass);
}

int main()
{
	//printf("SHA-256 tests: %s\n", sha256_test() ? "SUCCEEDED" : "FAILED");

    //printf("%s\n", sha256_test());
    
    
    /*BYTE hash1[SHA256_BLOCK_SIZE] = {0xba,0x78,0x16,0xbf,0x8f,0x01,0xcf,0xea,0x41,0x41,0x40,0xde,0x5d,0xae,0x22,0x23,
	                                 0xb0,0x03,0x61,0xa3,0x96,0x17,0x7a,0x9c,0xb4,0x10,0xff,0x61,0xf2,0x00,0x15,0xad};*/
    clock_t t;
    t = clock();
    
    BYTE text1[] = {"abc"};
    BYTE text2[] = {"abd"};
    
    printf("SHA-256 tests: %s\n", sha256_test(text1, text2) ? "SUCCEEDED" : "FAILED");
    
    
    t = clock() - t;
    //double time_taken = ((double)t)/CLOCKS_PER_SEC; // in seconds
  
    double time_taken = ((double)t);
        
    printf("the hashing took %f seconds to execute \n", time_taken);
    
	return(0);
}