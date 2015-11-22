# Function Maps

poly1305_blocks                     ->  poly1305_donna.h

rotate                              ->  core_salsa20.c
load_littleendian
store_littleendian
crypto_core (crypto_core_salsa20)

rotate                              ->  core_hsalsa20.c
load_littleendian
store_littleendian
crypto_core (crypto_core_hsalsa20)

crypto_stream_salsa20_xor_ic        -> xor_salsa20_ref.c

U8TO32                              -> poly1305_donna32.h
U32TO8
