#ifndef hsalsa20_h
#define hsalsa20_h

int my_crypto_core_hsalsa20(
            unsigned char *out,
      const unsigned char *in,
      const unsigned char *k,
      const unsigned char *c
);

int my_crypto_core_salsa20(
        unsigned char *out,
  const unsigned char *in,
  const unsigned char *k,
  const unsigned char *c
);

#endif
