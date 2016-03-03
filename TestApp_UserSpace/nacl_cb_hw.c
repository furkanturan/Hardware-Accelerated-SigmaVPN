#include "nacl_cb_hw.h"

#include <stdio.h>
#include <stdlib.h>

#include <string.h>
#include <fcntl.h>
#include <sys/time.h>
#include <unistd.h>
#include <sys/mman.h>

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


#define mb() asm volatile ("": : :"memory")

#define MM2S_DMA_CONTROL_REG		0
#define MM2S_DMA_STATUS_REG			1
#define MM2S_SOURCE_ADDR_REG		6
#define MM2S_TRANSFER_LENGTH		10

#define S2MM_DMA_CONTROL_REG		12
#define S2MM_DMA_STATUS_REG			13
#define S2MM_DEST_ADDR_REG	        18
#define S2MM_BUFFER_LENGTH			22

#define MMAP_DMA_CNTRL (sysconf(_SC_PAGESIZE) * 0)
#define MMAP_DMA_BUFFY (sysconf(_SC_PAGESIZE) * 1)

void printCTRL(uint32_t *ctrl);

static inline uint32_t *io_base(void *mem, size_t offset)
{
    return (uint32_t *)((unsigned char *)mem + offset);
}

static inline uint8_t *data_base(void *mem, size_t offset)
{
    return (uint8_t *)((unsigned char *)mem + offset);
}

uint32_t *ctrl;
uint8_t *buffer;

void NaCl_CryptoBox_HW_Init(unsigned char* precomp)
{
    unsigned char dummy[32];
        
    dev.fd = open("/dev/ds_axidma", O_RDWR);
    
    
    if (dev.fd == -1)
        printf("Device could not opened. \n");
    else
        printf("Device is opened. \n");
    
    /////////////////////////////////////////////////////////////////
    
    dev.ctrl_mem = mmap(    NULL, 
                            400, 
                            PROT_READ | PROT_WRITE,
                            MAP_SHARED, 
                            dev.fd, 
                            MMAP_DMA_CNTRL);
                        
    if (dev.ctrl_mem == MAP_FAILED)
        printf("Mapping CONTROL is failed \n");
    else
        printf("Mapping CONTROL is successed \n");
        
    /////////////////////////////////////////////////////////////////
    
    dev.buffer_mem = mmap(  NULL,
                            1600,
                            PROT_READ | PROT_WRITE,
                            MAP_SHARED,
                            dev.fd,
                            MMAP_DMA_BUFFY);
                        
    if (dev.buffer_mem == MAP_FAILED)
        printf("Mapping DATA is failed \n");
    else
        printf("Mapping DATA is successed \n");
    
    /////////////////////////////////////////////////////////////////
    
    write(dev.fd, dummy, 32);
    
    /////////////////////////////////////////////////////////////////
    
    ctrl = io_base(dev.ctrl_mem, 0);   
    buffer = data_base(dev.buffer_mem, 0);
    
    /////////////////////////////////////////////////////////////////
        
    ctrl[S2MM_DMA_CONTROL_REG] = 4097;
    ctrl[S2MM_DMA_STATUS_REG] = 4096;
    ctrl[MM2S_DMA_CONTROL_REG] = 1;     mb();
    
    buffer[0] = 0x01;
    buffer[1] = 0x00;
    buffer[2] = 0x20;
    buffer[3] = 0x00;
    
    memset(buffer+4,        0,              CB_NONCEBYTES);
    memcpy(buffer+28,       precomp,        CB_BEFORENMBYTES);
    memset(buffer+60,       0,              32);
    
    ctrl[MM2S_TRANSFER_LENGTH] = 60 + 32;   mb();    
    
    printCTRL(ctrl);  
}

void NaCl_CryptoBox_HW_ENCRYPT(         unsigned char* ct,
                                        unsigned char* mac,
                                        unsigned char* pt,
                                        unsigned short len,
                                        unsigned char* nonce)
{   
    ctrl[S2MM_DMA_CONTROL_REG] = 4097;  
    ctrl[S2MM_DMA_STATUS_REG] = 4096;   
    ctrl[MM2S_DMA_CONTROL_REG] = 1;
        
    buffer[0] = 0;
    buffer[1] = 0;
    buffer[2] = len;
    buffer[3] = len>>8;
        
    memcpy(buffer+4,        nonce,          CB_NONCEBYTES);
    memcpy(buffer+28,       pt,             len);
    
    ctrl[MM2S_TRANSFER_LENGTH] = 28 + len;  mb();
        
    while(!(ctrl[S2MM_DMA_STATUS_REG] & 0x00001000))
    {
        mb();
    }
    
    memcpy(ct,  buffer,       len);
    memcpy(mac, buffer + len, CB_MACBYTES);    
}

int NaCl_CryptoBox_HW_DECRYPT(          unsigned char* ct,
                                        unsigned char* mac,
                                        unsigned char* pt,
                                        unsigned short len,
                                        unsigned char* nonce)
{   
    uint32_t status;
    unsigned char comp_mac[CB_MACBYTES];
    
    ctrl[S2MM_DMA_CONTROL_REG] = 4097;  
    ctrl[S2MM_DMA_STATUS_REG] = 4096;   
    ctrl[MM2S_DMA_CONTROL_REG] = 1;     
    
    buffer[0] = 2;
    buffer[1] = 0;
    buffer[2] = len;
    buffer[3] = len>>8;
    
    memcpy(buffer+4,        nonce,          CB_NONCEBYTES);
    memcpy(buffer+28,       ct,             len);
    
    ctrl[MM2S_TRANSFER_LENGTH] = 28 + len;  mb();
    
    status = ctrl[S2MM_DMA_STATUS_REG];  mb();
    
    while(!(status & 1<<12) || !(status & 1<<1))
    {
        status = ctrl[S2MM_DMA_STATUS_REG];   mb();
    }
    
    memcpy(pt,       buffer,        len);
    memcpy(comp_mac, buffer + len,  CB_MACBYTES);
        
    return memcmp(comp_mac, mac, CB_MACBYTES);
}

void printCTRL(uint32_t *ctrl)
{
    uint32_t tmp;
    
    printf("\n");
    printf("DMA REGISTERS\n");
    
    tmp = ctrl[MM2S_DMA_CONTROL_REG]; mb();  
    printf("MM2S_DMA_CONTROL_REG:\t%08x\n", tmp);
    
    tmp = ctrl[MM2S_DMA_STATUS_REG]; mb();  
    printf("MM2S_DMA_STATUS_REG:\t%08x\n", tmp);
    
    tmp = ctrl[MM2S_SOURCE_ADDR_REG]; mb();  
    printf("MM2S_SOURCE_ADDR_REG:\t%08x\n", tmp);
    
    tmp = ctrl[MM2S_TRANSFER_LENGTH]; mb();  
    printf("MM2S_TRANSFER_LENGTH:\t%08x\n", tmp);
    
    
    tmp = ctrl[S2MM_DMA_CONTROL_REG]; mb();  
    printf("S2MM_DMA_CONTROL_REG:\t%08x\n", tmp);
    
    tmp = ctrl[S2MM_DMA_STATUS_REG]; mb();  
    printf("S2MM_DMA_STATUS_REG:\t%08x\n", tmp);
    
    tmp = ctrl[S2MM_DEST_ADDR_REG]; mb();  
    printf("S2MM_DEST_ADDR_REG:\t%08x\n", tmp);
    
    tmp = ctrl[S2MM_BUFFER_LENGTH]; mb();  
    printf("S2MM_BUFFER_LENGTH:\t%08x\n", tmp);    
}