#include "nacl_cb_hw.h"

#include <stdio.h>
#include <stdlib.h>

#include <string.h>
#include <fcntl.h>
#include <sys/time.h>
#include <unistd.h>
#include <sys/mman.h>


void NaCl_CryptoBox_HW_ENCRYPT_with_PC( unsigned char* ct,
                                        unsigned char* mac,
                                        unsigned char* pt,
                                        unsigned short len,
                                        unsigned char* nonce,
                                        unsigned char* precomp)
{   
    unsigned char extrabytes;
    
    unsigned char *buffer;
    buffer = (unsigned char *) malloc(sizeof(unsigned char) * (len+60+4));
         
    buffer[0] = 1;
    buffer[1] = 0;
    buffer[2] = len;
    buffer[3] = len>>8;
    
    memcpy(buffer+4,        nonce,          CB_NONCEBYTES);
    memcpy(buffer+28,       precomp,        CB_BEFORENMBYTES);
    memcpy(buffer+60,       pt,             len);
    memset(buffer+60+len,   0,              4);
    
    // printf("\nINPUTS\n");
    // for (i = 0; i < (len+60)/4+1; i++)
    // {
    //     //printf("buffer[%d] = 0x", cnt); 
    //     //for (j = 0; j <4; j++)
    //     for (j = 3; j >=0; j--)
    //     {
    //         printf("%02x", buffer[i*4+j]);
    //     }        
    //     printf("\n");
    // }
    // printf("\n");
    
    fd = open("/dev/axi-dma1", O_RDWR);
    write(fd, buffer, 32);
    close(fd);
    
    extrabytes = 4 - (len % 4);
    if(extrabytes == 4)    extrabytes = 0;
    
    memcpy(ct,  buffer,                     len);
    memcpy(mac, buffer + extrabytes + len,  CB_MACBYTES);  
    
    free(buffer); 
}


void NaCl_CryptoBox_HW_ENCRYPT(         unsigned char* ct,
                                        unsigned char* mac,
                                        unsigned char* pt,
                                        unsigned short len,
                                        unsigned char* nonce)
{   
    unsigned char extrabytes;
        
    unsigned char *buffer;
    buffer = (unsigned char *) malloc(sizeof(unsigned char) * (len+28+4));
        
    buffer[0] = 0;
    buffer[1] = 0;
    buffer[2] = len;
    buffer[3] = len>>8;
    
    memcpy(buffer+4,        nonce,          CB_NONCEBYTES);
    memcpy(buffer+28,       pt,             len);
    memset(buffer+28+len,   0,              4);
    
    // printf("\nINPUTS\n");
    // for (i = 0; i < (len+28)/4+1; i++)
    // {
    //     //printf("buffer[%d] = 0x", cnt); 
    //     //for (j = 0; j <4; j++)
    //     for (j = 3; j >=0; j--)
    //     {
    //         printf("%02x", buffer[i*4+j]);
    //     }        
    //     printf("\n");
    // }
    // printf("\n");
    
    write(fd, buffer, 32);
    //close(fd);
    
    extrabytes = 4 - (len % 4);
    if(extrabytes == 4)    extrabytes = 0;
    
    memcpy(ct,  buffer,                     len);
    memcpy(mac, buffer + extrabytes + len,  CB_MACBYTES);  
    
    free(buffer);  
}

int NaCl_CryptoBox_HW_DECRYPT_with_PC(  unsigned char* ct,
                                        unsigned char* mac,
                                        unsigned char* pt,
                                        unsigned short len,
                                        unsigned char* nonce,
                                        unsigned char* precomp)
{       
    unsigned char comp_mac[CB_MACBYTES];
    
    unsigned char extrabytes;
            
    unsigned char *buffer;
    buffer = (unsigned char *) malloc(sizeof(unsigned char) * (len+60+4));
        
    buffer[0] = 3;
    buffer[1] = 0;
    buffer[2] = len;
    buffer[3] = len>>8;
    
    memcpy(buffer+4,        nonce,          CB_NONCEBYTES);
    memcpy(buffer+28,       precomp,        CB_BEFORENMBYTES);
    memcpy(buffer+60,       ct,             len);
    memset(buffer+60+len,   0,              4);
    
    // printf("\nINPUTS\n");
    // for (i = 0; i < (len+60)/4+1; i++)
    // {
    //     //printf("buffer[%d] = 0x", cnt); 
    //     //for (j = 0; j <4; j++)
    //     for (j = 3; j >=0; j--)
    //     {
    //         printf("%02x", buffer[i*4+j]);
    //     }        
    //     printf("\n");
    // }
    // printf("\n");
    
    fd = open("/dev/axi-dma1", O_RDWR);
    write(fd, buffer, 32);
    close(fd);
    
    extrabytes = 4 - (len % 4);
    if(extrabytes == 4)    extrabytes = 0;
    
    memcpy(pt,       buffer,                     len);
    memcpy(comp_mac, buffer + extrabytes + len,  CB_MACBYTES);
    
    free(buffer);
    
    return memcmp(comp_mac, mac, CB_MACBYTES);
}

int NaCl_CryptoBox_HW_DECRYPT(          unsigned char* ct,
                                        unsigned char* mac,
                                        unsigned char* pt,
                                        unsigned short len,
                                        unsigned char* nonce)
{   
    unsigned char comp_mac[CB_MACBYTES];
    
    unsigned char extrabytes;
        
    unsigned char *buffer;
    buffer = (unsigned char *) malloc(sizeof(unsigned char) * (len+28+4));
        
    buffer[0] = 2;
    buffer[1] = 0;
    buffer[2] = len;
    buffer[3] = len>>8;
    
    memcpy(buffer+4,        nonce,          CB_NONCEBYTES);
    memcpy(buffer+28,       ct,             len);
    memset(buffer+28+len,   0,              4);
    
    // printf("\nINPUTS\n");
    // for (i = 0; i < (len+60)/4+1; i++)
    // {
    //     //printf("buffer[%d] = 0x", cnt); 
    //     //for (j = 0; j <4; j++)
    //     for (j = 3; j >=0; j--)
    //     {
    //         printf("%02x", buffer[i*4+j]);
    //     }        
    //     printf("\n");
    // }
    // printf("\n");
    
    //fd = open("/dev/axi-dma1", O_RDWR);
    write(fd, buffer, 32);
    
    extrabytes = 4 - (len % 4);
    if(extrabytes == 4)    extrabytes = 0;
    
    memcpy(pt,       buffer,                     len);
    memcpy(comp_mac, buffer + extrabytes + len,  CB_MACBYTES);
    
    free(buffer);
    
    return memcmp(comp_mac, mac, CB_MACBYTES);
}