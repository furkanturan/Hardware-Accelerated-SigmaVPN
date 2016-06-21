#ifndef proto_nacltai_h
#define proto_nacltai_h

#include "proto.h"
#include "tai.h"
#include "pack.h"

void proto_genkeys(sigma_proto* instance);
int proto_set(sigma_proto* instance, char* param, char* value);
int proto_encode(sigma_proto *instance, uint8_t* input, uint8_t* output, size_t len);
int proto_decode(sigma_proto *instance, uint8_t* input, uint8_t* output, size_t len);

int proto_init(sigma_proto *instance);
int proto_reload(sigma_proto *instance);
sigma_proto* proto_descriptor();

#endif
