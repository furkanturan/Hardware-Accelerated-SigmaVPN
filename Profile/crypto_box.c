#include "./libsodium/include/sodium.h"

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "hsalsa20.h"
#include "poly1305.h"

int my_crypto_box_afternm(
            unsigned char *c,           // output
            const unsigned char *m,     // message
            unsigned long long mlen,    // message length
            const unsigned char *n,     // nonce
            const unsigned char *k)     // precomputed first level key
{
    int i;
    if (mlen < 32)
        return -1;

    // typedef unsigned long int	uint64_t;
    // (unsigned long long)0 == 0ULL
    my_crypto_stream_xsalsa20_xor(c,m,mlen,n,0ULL,k);
    my_crypto_onetimeauth_poly1305(c + 16,c + 32,mlen - 32,c);

    for (i = 0;i < 16; ++i)
        c[i] = 0;

    return 0;
}

static const unsigned char sigma[16] = {
    'e', 'x', 'p', 'a', 'n', 'd', ' ',
    '3', '2', '-', 'b', 'y', 't', 'e', ' ', 'k'
};

int my_crypto_stream_xsalsa20_xor(
            unsigned char *c,
            const unsigned char *m,
            unsigned long long mlen,
            const unsigned char *n,
            uint64_t ic,
            const unsigned char *k)
{
    unsigned char subkey[32];
    int ret;

    // compute second level key
    my_crypto_core_hsalsa20(subkey,n,k,sigma);

    // compute long secret and xor the message with it
    ret = my_crypto_stream_salsa20_xor_ic(c,m,mlen,n + 16,ic,subkey);

    sodium_memzero(subkey, sizeof subkey);
    return ret;
}

int my_crypto_stream_salsa20_xor_ic(
            unsigned char *c,           // output
            const unsigned char *m,     // message
            unsigned long long mlen,    // message length
            const unsigned char *n,     // nonce (last 8 bytes of 24 byte nonce)
            uint64_t ic,
            const unsigned char *k)     // second level key
                                        // (first 32 bytes of second level key)
{
    unsigned char in[16];
    unsigned char block[64];
    unsigned char kcopy[32];
    unsigned int i;
    unsigned int u;

    uint64_t nonce2ndhalf = ic;

    if (!mlen) return 0;

    // first 32 bytes of second level key
    for (i = 0;i < 32;++i) kcopy[i] = k[i];

    // // first 8 byte of in[] is nonce's last 8 bytes
    // for (i = 0;i < 8;++i) in[i] = n[i];
    //
    // // last 8 byte of in[] are:
    // for (i = 8;i < 16;++i)
    // {
    //     in[i] = (unsigned char) (ic & 0xff);
    //     ic >>= 8;
    // }
    //
    // printf("\nnonce is: \n");
    // for (i = 0;i < 16;++i)
    // {
    //     printf("%x ", in[i]);
    // }

    // my version instead of above
    memcpy(in + 0, n, 8);
    memcpy(in + 8, &nonce2ndhalf, 8);

    while (mlen >= 64)
    {
        // create 64 bytes of long secret stream
        my_crypto_core_salsa20(block,in,kcopy,sigma);

        // xor (a 64 bytes block of) long secret stream with the message
        for (i = 0; i < 64; ++i)
            c[i] = m[i] ^ block[i];

        // update the second half of the nonce in a way that
        // those 8 bytes of nonce will be considered as a number
        // whose least significant byte is nonce's 8th byte but
        // the most significant byte is nonce's 15th
        // and that 8 byte number is incremented by 1

        // u = 1;
        // for (i = 8; i < 16; ++i)
        // {
        //     u += (unsigned int) in[i];
        //     in[i] = u;
        //     u >>= 8;
        // }

        // my version instead of above
        nonce2ndhalf++;
        memcpy(in+8, &nonce2ndhalf, 8);

        mlen -= 64;
        c += 64;
        m += 64;
    }

    if (mlen)
    {
        my_crypto_core_salsa20(block,in,kcopy,sigma);

        for (i = 0;i < (unsigned int) mlen; ++i)
            c[i] = m[i] ^ block[i];
    }

    sodium_memzero(block, sizeof block);
    sodium_memzero(kcopy, sizeof kcopy);

    return 0;
}
