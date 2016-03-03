#ifndef nacl_cb_hw_h
#define nacl_cb_hw_h

#define CB_NONCEBYTES       24
#define CB_BEFORENMBYTES    32
#define CB_MACBYTES         16

struct nacl_dev {
    void    *ctrl_mem;
    void    *buffer_mem;
    
    int fd;
};

struct nacl_dev dev;

void NaCl_CryptoBox_HW_Init(            unsigned char* precomp);

void NaCl_CryptoBox_HW_ENCRYPT(         unsigned char* ct,
                                        unsigned char* mac,
                                        unsigned char* pt,
                                        unsigned short len,
                                        unsigned char* nonce);

int NaCl_CryptoBox_HW_DECRYPT(          unsigned char* ct,
                                        unsigned char* mac,
                                        unsigned char* pt,
                                        unsigned short len,
                                        unsigned char* nonce);


#endif
