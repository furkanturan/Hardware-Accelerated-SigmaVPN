#include <sodium.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <time.h>
#include <fcntl.h>
#include <sys/time.h>
#include <unistd.h>
#include <sys/mman.h>
#include <errno.h>

#include "nacl_cb_hw.h"


////////////////////////////

static inline unsigned int get_cyclecount (void)
{
    unsigned int value;
    // Read CCNT Register
    asm volatile ("MRC p15, 0, %0, c9, c13, 0\t\n": "=r"(value));
    return value;
}

static inline void init_perfcounters (int32_t do_reset, int32_t enable_divider)
{
    // in general enable all counters (including cycle counter)
    int32_t value = 1;

    // peform reset:
    if (do_reset)
    {
        value |= 2;     // reset all counters to zero.
        value |= 4;     // reset cycle counter to zero.
    }

    if (enable_divider)
    value |= 8;     // enable "by 64" divider for CCNT.

    value |= 16;

    // program the performance-counter control-register:
    asm volatile ("MCR p15, 0, %0, c9, c12, 0\t\n" :: "r"(value));

    // enable all counters:
    asm volatile ("MCR p15, 0, %0, c9, c12, 1\t\n" :: "r"(0x8000000f));

    // clear overflows:
    asm volatile ("MCR p15, 0, %0, c9, c12, 3\t\n" :: "r"(0x8000000f));
}

////////////////////////////

unsigned char precomp[crypto_box_BEFORENMBYTES];

void NaCl_CryptoBox_Init()
{
    unsigned char pk[crypto_box_PUBLICKEYBYTES];
    unsigned char sk[crypto_box_SECRETKEYBYTES];
    unsigned int i;

    crypto_box_keypair(pk, sk);
    
    // printf("\nPRIVATE KEY: ");
    // for (i = 0; i < crypto_box_SECRETKEYBYTES; i ++)
    //     printf("%02x", sk[i]);

    // printf("\n PUBLIC KEY: ");
    // for (i = 0; i < crypto_box_PUBLICKEYBYTES; i ++)
    //     printf("%02x", pk[i]);
    
    if(  crypto_box_beforenm(   precomp,
                                pk,
                                sk )
    )
    
        printf("Beforenm Failed");
    
    
    // printf("\n PRECOMP: ");
    // for (i = 0; i < crypto_box_BEFORENMBYTES; i ++)
    // {
    //     printf("%02x", precomp[i]);
    // }
}

void NaCl_CryptoBox_SW_ENCRYPT( unsigned char* ct,
                                unsigned char* pt,
                                unsigned short  len,
                                unsigned char* nonce,
                                unsigned char* mac)
{ 
    uint8_t tempbufferpt[len + crypto_box_ZEROBYTES];
    bzero(tempbufferpt, crypto_box_ZEROBYTES);
    memcpy(tempbufferpt + crypto_box_ZEROBYTES, pt, len);
    
    unsigned int msglen = len + crypto_box_ZEROBYTES; 
    
    uint8_t tempbufferct[len + crypto_box_ZEROBYTES];
    
    if( 
        
        crypto_box_afternm( tempbufferct,
                            tempbufferpt,
                            msglen,
                            nonce,
                            precomp) 
      )
        printf("\nEncryption failed");
    
    memcpy(mac, tempbufferct + crypto_box_MACBYTES, crypto_box_MACBYTES);   
    memcpy(ct, tempbufferct + crypto_box_ZEROBYTES, len); 
          
}

void NaCl_CryptoBox_SW_DECRYPT( unsigned char* ct,
                                unsigned char* pt,
                                unsigned short  len,
                                unsigned char* nonce,
                                unsigned char* mac)
{
    unsigned int i;
    
    uint8_t tempbufferct[len + crypto_box_ZEROBYTES];
    bzero(tempbufferct, crypto_box_ZEROBYTES);  
    
    memcpy(tempbufferct + crypto_box_MACBYTES, mac, crypto_box_MACBYTES);  
    memcpy(tempbufferct + crypto_box_ZEROBYTES, ct, len);  
    
    unsigned int msglen = len + crypto_box_ZEROBYTES; 
    
    uint8_t tempbufferpt[len + crypto_box_ZEROBYTES];
    
    // printf("\n CT: 0x");
    // for (i = 0; i < len + crypto_box_ZEROBYTES; i ++)
    //     printf("%02x", tempbufferct[i]); 
    
    if( 
        
        crypto_box_open_afternm( tempbufferpt,
                                 tempbufferct,
                                 msglen,
                                 nonce,
                                 precomp) 
      )
        printf("\nDecryption failed");
    
    memcpy(pt, tempbufferpt + crypto_box_ZEROBYTES, len);       
}






void enablePerfCounters()
{
    unsigned int *bufferIN;
    bufferIN = (unsigned int *) malloc(sizeof(unsigned int) * 16);
    int fd = open("/dev/axi-dma1", O_RDWR);
    read(fd, bufferIN, 64);
    close(fd);    
}

#define MAX_LENGTH 2048


int main(int argc, char **argv)
{
    if (argc == 0)
    {
        printf("Forgot to set the length");
        return -1;
    }
        
    unsigned int LOOP_COUNT = atoi(argv[1]);
    
    unsigned int error_enc=0, error_encmac=0;
    unsigned int error_dec=0, error_decmac=0;
    
    unsigned int cycles[7][10000][4] = {0,}, cnt=0;
    
    unsigned long long tmp;
    
    
    unsigned int len, i, j;
                    
            unsigned int overhead, t;

    unsigned char *nonce;
    unsigned char *output_sw, *output_hw;
    unsigned char *input_sw,  *input_hw;
    unsigned char *mac_sw,    *mac_hw;
    
    nonce       = malloc( crypto_box_NONCEBYTES * sizeof(unsigned char));
    output_sw   = malloc( MAX_LENGTH            * sizeof(unsigned char));
    output_hw   = malloc( MAX_LENGTH            * sizeof(unsigned char));
    input_sw    = malloc( MAX_LENGTH            * sizeof(unsigned char));
    input_hw    = malloc( MAX_LENGTH            * sizeof(unsigned char));
    mac_sw      = malloc( crypto_box_MACBYTES   * sizeof(unsigned char));
    mac_hw      = malloc( crypto_box_MACBYTES   * sizeof(unsigned char));
    
    srand((unsigned) time(&t));    
    
    // This will derive keys and calculate the precomp value
    NaCl_CryptoBox_Init();
        
    NaCl_CryptoBox_HW_ENCRYPT_with_PC(output_hw, mac_hw, input_hw, 32, nonce, precomp);
    
    
    enablePerfCounters();
    init_perfcounters (1, 0);
    overhead = get_cyclecount();
    overhead = get_cyclecount() - overhead;
    
    
    fd = open("/dev/axi-dma1", O_RDWR);
    
    for(len = 16; len < 2048; len*=2)
    {
        for(j=0; j<LOOP_COUNT; j++)
        {
        
            // Fill inputs and nonce with randomn bytes
            for (i=0; i < len; i++)
            {
                input_sw[i] = rand();
                input_hw[i] = input_sw[i];
            }
            
            for (i=0; i < crypto_box_NONCEBYTES; i++)
                nonce[i] = rand();
            
            
                init_perfcounters (1, 0);
                t = get_cyclecount();
            NaCl_CryptoBox_SW_ENCRYPT(output_sw, input_sw, len, nonce, mac_sw);
                cycles[cnt][j][0] += get_cyclecount() - t;

                init_perfcounters (1, 0);
                t = get_cyclecount();
            NaCl_CryptoBox_HW_ENCRYPT(output_hw, mac_hw, input_hw, len, nonce);
                cycles[cnt][j][1] += get_cyclecount() - t;
            
            if(memcmp(output_hw, output_sw, len) != 0)           error_enc++;
            
            if(memcmp(mac_sw, mac_hw, crypto_box_MACBYTES) != 0) error_encmac++;
            
            memset(input_sw, 0, len);
            memset(input_hw, 0, len);
                
                init_perfcounters (1, 0);
                t = get_cyclecount();
            NaCl_CryptoBox_SW_DECRYPT(output_sw, input_sw, len, nonce, mac_sw);
                cycles[cnt][j][2] += get_cyclecount() - t;
            
                init_perfcounters (1, 0);
                t = get_cyclecount();
            NaCl_CryptoBox_HW_DECRYPT(output_hw, mac_hw, input_hw, len, nonce);
                cycles[cnt][j][3] += get_cyclecount() - t;
                
            if(memcmp(input_sw, input_hw, len) != 0)              error_dec++;
        }
        
        cnt++;
    }
    
    //close(fd);
    
    printf("\n# of errors in encryption is: %d",       error_enc);
    printf("\n# of errors in encryption mac is: %d",   error_encmac);
    printf("\n# of errors in decryption is: %d",       error_dec);
    printf("\n# of errors in decryption mac is: %d",   error_decmac);
    
    
    printf("\n\nENCRYTPTION\n");
    
    printf("\nLen\tCyc\tCyc");
    
    
    cnt=0;
    for(len = 16; len < 2048; len*=2)
    {
    
        tmp = 0;
        for(j=0; j<LOOP_COUNT; j++)
        {
            tmp += cycles[cnt][j][0];    
        }
        
        printf("\n%d\t%llu\t", len, tmp/LOOP_COUNT);
        
        tmp = 0;
        for(j=0; j<LOOP_COUNT; j++)
        {
            tmp += cycles[cnt][j][1];    
        }
        
        printf("%llu", tmp/LOOP_COUNT);
        
        cnt++;
    }
    
    printf("\n\nDECRYTPTION\n");
    
    printf("\nLen\tCyc\tCyc");
    
    cnt=0;
    for(len = 16; len < 2048; len*=2)
    {
        tmp = 0;
        for(j=0; j<LOOP_COUNT; j++)
        {
            tmp += cycles[cnt][j][2];    
        }
        
        printf("\n%d\t%llu\t", len, tmp/LOOP_COUNT);
        
        tmp = 0;
        for(j=0; j<LOOP_COUNT; j++)
        {
            tmp += cycles[cnt][j][3];    
        }
        
        printf("%llu", tmp/LOOP_COUNT);
        
        cnt++;
    }
    
    printf("\n");
    
    return 0;
}
