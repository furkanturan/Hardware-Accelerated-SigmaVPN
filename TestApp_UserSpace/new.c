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


int main(void)
{
    uint32_t *ctrl, *buffer;
    uint8_t *b;
    uint8_t i;
    
    /////////////////////////////////////////////////////////////////
        
    ctrl = io_base(dev.ctrl_mem, 0);   
    buffer = io_base(dev.buffer_mem, 0);   
    b = data_base(dev.buffer_mem, 0);
    
    printf("\n");
    
    printCTRL(ctrl);
    
    ctrl[S2MM_DMA_CONTROL_REG] = 4097;
    ctrl[S2MM_DMA_STATUS_REG] = 4096;
    ctrl[MM2S_DMA_CONTROL_REG] = 1;     mb();
    
    printCTRL(ctrl);    
        
    //buffer[00] = 0x00200001;
    b[0] = 0x01;
    b[1] = 0x00;
    b[2] = 0x20;
    b[3] = 0x00;
    
    b[4] = 0xf8;
    b[5] = 0xa4;
    b[6] = 0x1b;
    b[7] = 0x13;
    
    buffer[ 1] = 0x131ba4f8;
    buffer[ 2] = 0xe84ecab5;
    buffer[ 3] = 0xe0383298;
    buffer[ 4] = 0x343d4d79;
    buffer[ 5] = 0x774e5fbc;
    buffer[ 6] = 0x056ccbfa;
     
    buffer[ 7] = 0x92f967ec;
    buffer[ 8] = 0xd2387866;
    buffer[ 9] = 0x019e9c7d;
    buffer[10] = 0x76b4965c;
    buffer[11] = 0xbc9f2076;
    buffer[12] = 0xeaffaf00;
    buffer[13] = 0xe5d1636c;
    buffer[14] = 0xdae4b9ce;
 
    buffer[15] = 0x7369c667;
    buffer[16] = 0xec4aff51;
    buffer[17] = 0xabbacd29;
    buffer[18] = 0x46e3fbf2;
    buffer[19] = 0xf854c27c;
    buffer[20] = 0x8de7e81b;
    buffer[21] = 0x632e5a76;
    buffer[22] = 0x9ac99f33;
     
    buffer[23] = 0xb70d3266;
    buffer[24] = 0x5aa35831;
    buffer[25] = 0x17055d25;
    buffer[26] = 0xd45ee958;
    buffer[27] = 0xc6cdb2ab;
    buffer[28] = 0x1154b49b;
    buffer[29] = 0x4174820e;

    ctrl[MM2S_TRANSFER_LENGTH] = 60 + 32;   mb();
        
    printCTRL(ctrl);
    
    for(i=0; i<32; i++)
    {
        printf("b[%d]:\t%08x\n", i, buffer[i]); mb();  
    }
    
    getchar();
    
    return 0;
}
