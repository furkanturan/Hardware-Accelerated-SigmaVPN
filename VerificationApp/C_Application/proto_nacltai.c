//
//  proto_nacltai.c
//  Sigma nacltai protocol code
//
//  Copyright (c) 2011, Neil Alexander T.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with
//  or without modification, are permitted provided that the following
//  conditions are met:
//
//  - Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//  The nacltai code is derived, with permission, from Quicktun written
//  by Ivo Smits. http://oss.ucis.nl/hg/quicktun/
//

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

#include "./libsodium/include/sodium.h"
#include "proto_nacltai.h"
#include "proto.h"
#include "tai.h"
#include "pack.h"

#include "crypto_box.h"

#define noncelength TAIA_PACK_LEN
#define nonceoffset (crypto_box_NONCEBYTES - noncelength)
#define rxtaiacount 16

typedef struct sigma_proto_nacl
{
    sigma_proto baseproto;

    uint8_t privatekey[crypto_box_SECRETKEYBYTES];
    uint8_t publickey[crypto_box_PUBLICKEYBYTES];
    uint8_t precomp[crypto_box_BEFORENMBYTES];
    uint8_t encnonce[crypto_box_NONCEBYTES];
    uint8_t decnonce[crypto_box_NONCEBYTES];

    struct taia cdtaie;
    uint8_t rxtaialog[rxtaiacount][TAIA_PACK_LEN];
}
sigma_proto_nacl;

void proto_genkeys(sigma_proto* instance)
{
    crypto_box_keypair(((sigma_proto_nacl*) instance)->publickey, ((sigma_proto_nacl*) instance)->privatekey);
}

int proto_set(sigma_proto* instance, char* param, char* value)
{
    size_t read;

    if (strcmp(param, "publickey") == 0)
    {
        read = hex2bin(((sigma_proto_nacl*) instance)->publickey, value, crypto_box_PUBLICKEYBYTES);

        if (read != crypto_box_PUBLICKEYBYTES || value[crypto_box_PUBLICKEYBYTES * 2] != '\0')
        {
            fprintf(stderr, "Public key is incorrect length\n");
            errno = EILSEQ;
            return -1;
        }
    }
        else
    if (strcmp(param, "privatekey") == 0)
    {
        read = hex2bin(((sigma_proto_nacl*) instance)->privatekey, value, crypto_box_SECRETKEYBYTES);

        if (read != crypto_box_SECRETKEYBYTES || value[crypto_box_SECRETKEYBYTES * 2] != '\0')
        {
            fprintf(stderr, "Private key is incorrect length\n");
            errno = EILSEQ;
            return -1;
        }
    }
        else
    {
        read = 0;

        fprintf(stderr, "Unknown attribute '%s'\n", param);
        errno = EINVAL;
        return -1;
    }

    return read;
}

int proto_encode(sigma_proto *instance, uint8_t* input, uint8_t* output, size_t len)
{
    int i = 0, j, cnt = 4;
    
    //char n[] = {0xf8, 0xa4, 0x1b, 0x13, 0xb5, 0xca, 0x4e, 0xe8, 0x98, 0x32, 0x38, 0xe0, 0x79, 0x4d, 0x3d, 0x34, 0xbc, 0x5f, 0x4e, 0x77, 0xfa, 0xcb, 0x6c, 0x05}; 
    //char p[] = {0xec, 0x67, 0xf9, 0x92, 0x66, 0x78, 0x38, 0xd2, 0x7d, 0x9c, 0x9e, 0x01, 0x5c, 0x96, 0xb4, 0x76, 0x76, 0x20, 0x9f, 0xbc, 0x00, 0xaf, 0xff, 0xea, 0x6c, 0x63, 0xd1, 0xe5, 0xce, 0xb9, 0xe4, 0xda};
    
    sigma_proto_nacl* inst = (sigma_proto_nacl*) instance;

    // Create a temporary buffer for the input
    // Those 32 bytes extra comes here
    // Make its first 32 bytes 0 and then the input string
    uint8_t tempbufferinput[len + crypto_box_ZEROBYTES];
    bzero(tempbufferinput, crypto_box_ZEROBYTES);
    memcpy(tempbufferinput + crypto_box_ZEROBYTES, input, len);
    len += crypto_box_ZEROBYTES;

    // Get time and set it as encnonce
    //taia_now(&inst->cdtaie);
    //taia_pack(inst->encnonce + nonceoffset, &(inst->cdtaie));

    
    printf("crypto_box_ZEROBYTES[] is: %d\n", crypto_box_ZEROBYTES);
    //printf("crypto_box_ZEcrypto_box_BOXZEROBYTESROBYTES[] is: %d\n", crypto_box_BOXZEROBYTES);
    // getchar();

        // for(i=0; i<32; i++)
        //     inst->encnonce[i] = n[i];
            
        // for(i=0; i<48; i++)
        //     ((sigma_proto_nacl*) instance)->precomp[i] = p[i];

    printf("NONCE[] is %d, %d:\n", nonceoffset, noncelength);
    for (i = 0; i < 6; i++)
    {
        for (j = 3; j >=0; j--)
        //for (j = 0; j <4; j++)
        {
            printf("%02x", inst->encnonce[i*4+j]);
            //printf("dev.buffer_mem[%d] = 0x%02x;\n", cnt++, inst->encnonce[i*4+j]);
        }        
        printf(",\n");
    }
    printf("\n");

    printf("PRECOMP[] is:\n");
    for (i = 0; i < 8; i++)
    {
        for (j = 3; j >=0; j--)
        //for (j = 0; j <4; j++)
        {
            printf("%02x", ((sigma_proto_nacl*) instance)->precomp[i*4+j]);
            //printf("dev.buffer_mem[%d] = 0x%02x;\n", cnt++, ((sigma_proto_nacl*) instance)->precomp[i*4+j]);
        }
        printf(",\n");
    }
    printf(",\n");
    
    getchar();
        
    printf("MESSAGE[] is:\n");
    for (i = 0; i < 512/4; i++)
    {
        for (j = 3; j >=0; j--)
        //for (j = 0; j <4; j++)
        {
            printf("%02x", input[i*4+j]);
            //printf("dev.buffer_mem[%d] = 0x%02x;\n", cnt++, input[i*4+j]);
        }
        printf(",\n");
    }
    printf("\n");


    // Run crypto box
    int result = my_crypto_box_afternm(
        output,
        tempbufferinput,
        len,
        inst->encnonce,
        ((sigma_proto_nacl*) instance)->precomp
    );

    if (result)
    {
        fprintf(stderr, "Encryption failed (length %u, given result %i)\n", (unsigned) len, result);
        errno = EINVAL;
        return -1;
    }

    memcpy(output, inst->encnonce + nonceoffset, noncelength);
    
    printf("CIPHER[] is:\n");
    for (i = 0; i <= (len/4); i++)
    {
        //for (j = 3; j >=0; j--)
        for (j = 0; j <4; j++)
            printf("%02x", output[i*4+j]);
        //printf(",\n");
    }
    printf("\n");
    
    return len;
}

int proto_decode(sigma_proto *instance, uint8_t* input, uint8_t* output, size_t len)
{
    if (len < crypto_box_ZEROBYTES)
    {
        fprintf(stderr, "Short packet received: %u\n", (unsigned) len);
        errno = EINVAL;
        return -1;
    }

    sigma_proto_nacl* inst = (sigma_proto_nacl*) instance;

    // Check last 16 nonce's and see if there is reuse.
    int i, taioldest = 0;
    for (i = 0; i < rxtaiacount; i ++)
    {
        if (memcmp(input, inst->rxtaialog[i], noncelength) == 0)
        {
            fprintf(stderr, "Timestamp reuse detected, possible replay attack (packet length %u)\n", (unsigned) len);
            errno = EINVAL;
            return -1;
        }

        if (i != 0 && memcmp(inst->rxtaialog[i], inst->rxtaialog[taioldest], noncelength) < 0)
            taioldest = i;
    }

    // Check if timestamp is new
    if (memcmp(input, inst->rxtaialog[taioldest], noncelength) < 0)
    {
        fprintf(stderr, "Timestamp older than our oldest known timestamp, possible replay attack (packet length %u)\n", (unsigned) len);
        errno = EINVAL;
        return -1;
    }

    // Create temporary buffer
    uint8_t tempbufferout[len];

    memcpy(inst->decnonce + nonceoffset, input, noncelength);
    bzero(input, crypto_box_BOXZEROBYTES);

    int result = crypto_box_open_afternm(
        tempbufferout,
        input,
        len,
        inst->decnonce,
        inst->precomp
    );

    if (result)
    {
        fprintf(stderr, "Decryption failed (length %u, given result %i)\n", (unsigned) len, result);
        errno = EINVAL;
        return -1;
    }

    len -= crypto_box_ZEROBYTES;
    memcpy(output, tempbufferout + crypto_box_ZEROBYTES, len);
    memcpy(inst->rxtaialog[taioldest], inst->decnonce + nonceoffset, noncelength);

    return len;
}

int proto_init(sigma_proto *instance)
{
    sigma_proto_nacl* inst = ((sigma_proto_nacl*) instance);
    uint8_t taipublickey[crypto_box_PUBLICKEYBYTES];

    crypto_box_beforenm(
        inst->precomp,
        inst->publickey,
        inst->privatekey
    );

    bzero(inst->encnonce, crypto_box_NONCEBYTES);
    bzero(inst->decnonce, crypto_box_NONCEBYTES);

    crypto_scalarmult_curve25519_base(taipublickey, inst->privatekey);

    inst->encnonce[nonceoffset - 1] = memcmp(taipublickey, inst->publickey, crypto_box_PUBLICKEYBYTES) > 0 ? 1 : 0;
    inst->decnonce[nonceoffset - 1] = inst->encnonce[nonceoffset - 1] ? 0 : 1;

    return 0;
}

int proto_reload(sigma_proto *instance)
{
    return proto_init(instance);
}

sigma_proto* proto_descriptor()
{
    sigma_proto_nacl* proto_nacltai = calloc(1, sizeof(sigma_proto_nacl));

    proto_nacltai->baseproto.encrypted = true;
    proto_nacltai->baseproto.stateful = false;
    proto_nacltai->baseproto.state = 0;

    return (sigma_proto*) proto_nacltai;
}
