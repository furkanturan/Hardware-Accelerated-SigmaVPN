#ifndef cryptobox_h
#define cryptobox_h

int my_cryptobox_afternm(unsigned char *c, const unsigned char *m,
                       unsigned long long mlen, const unsigned char *n,
                       const unsigned char *k);

int my_crypto_stream_xsalsa20_xor(
                               unsigned char *c,
                         const unsigned char *m,unsigned long long mlen,
                         const unsigned char *n,uint64_t ic,
                         const unsigned char *k
                     );

int my_crypto_stream_salsa20_xor_ic(
                             unsigned char *c,
                       const unsigned char *m,unsigned long long mlen,
                       const unsigned char *n, uint64_t ic,
                       const unsigned char *k
                    );

#endif
