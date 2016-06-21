#ifndef poly1305_h
#define poly1305_h

#include "./libsodium/include/sodium.h"

typedef struct my_crypto_onetimeauth_poly1305_state {
    unsigned long long aligner;
    unsigned char      opaque[136];
} my_crypto_onetimeauth_poly1305_state;

typedef my_crypto_onetimeauth_poly1305_state my_poly1305_context;


#define poly1305_block_size 16

typedef struct poly1305_state_internal_t {
        unsigned long r[5];
        unsigned long h[5];
        unsigned long pad[4];
        unsigned long long leftover;
        unsigned char buffer[poly1305_block_size];
        unsigned char final;
} poly1305_state_internal_t;

int my_crypto_onetimeauth_poly1305(unsigned char *out, unsigned char *m,
                                  unsigned long long inlen,
                                  unsigned char *key);

static void my_poly1305_init(my_poly1305_context *ctx, const unsigned char key[32]);
static void my_poly1305_update(my_poly1305_context *ctx, const unsigned char *m, unsigned long long bytes);
void my_poly1305_finish(my_poly1305_context *ctx, unsigned char mac[16]);
static void my_poly1305_blocks(poly1305_state_internal_t *st, const unsigned char *m, unsigned long long bytes);

#endif
