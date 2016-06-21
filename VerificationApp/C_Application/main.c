#include <stdio.h>
#include <stdlib.h>

#include "proto_nacltai.h"
#include "proto.h"
#include "poly1305.h"

char *pub_key1 = "19f0818f7173e6614f66e3c8c98a24288beb67facf12cc9ace60c3cbfb79040b";
char *prv_key1 = "243c1d70bd186ffa030d0420668cc50e2177ba5c41fea67f76f2ca0e1ca0e9dc";

char *pub_key2 = "b598befbc22322323f102ad39fd5dda34e5cc4640d9dbc8e9c7b6275ef4bf315";
char *prv_key2 = "64f1d9924e10f95ddf8010ade99bbc5bc86a69b4dad9c0078a47d5dd82589ac5";

char *plaintext = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse non massa vel enim semper placerat ut vel sapien. Quisque elementum, diam quis condimentum tincidunt, nulla tortor egestas quam, vel pharetra libero leo eget lacus. Donec sed scelerisque nulla. Vestibulum rutrum vestibulum ipsum, et ullamcorper nulla pretium id. Cras a lorem augue. Cras et viverra nunc, nec tincidunt lacus. Mauris vitae urna at lectus vulputate egestas. Vivamus et blandit tortor. Donec ac blandit purus, lacinia massa nunc.";

//char plaintext[] = {0x67, 0xc6, 0x69, 0x73, 0x51, 0xff, 0x4a, 0xec, 0x29, 0xcd, 0xba, 0xab, 0xf2, 0xfb, 0xe3, 0x46, 0x7c, 0xc2, 0x54, 0xf8, 0x1b, 0xe8, 0xe7, 0x8d, 0x76, 0x5a, 0x2e, 0x63, 0x33, 0x9f, 0xc9, 0x9a, 0x66, 0x32, 0x0d, 0xb7, 0x31, 0x58, 0xa3, 0x5a, 0x25, 0x5d, 0x05, 0x17, 0x58, 0xe9, 0x5e, 0xd4, 0xab, 0xb2, 0xcd, 0xc6, 0x9b, 0xb4, 0x54, 0x11, 0x0e, 0x82, 0x74, 0x41, 0x21, 0x3d, 0xdc, 0x87, 0x70, 0xe9, 0x3e, 0xa1, 0x41, 0xe1, 0xfc, 0x67, 0x3e, 0x01, 0x7e, 0x97, 0xea, 0xdc, 0x6b, 0x96, 0x8f, 0x38, 0x5c, 0x2a, 0xec, 0xb0, 0x3b, 0xfb, 0x32, 0xaf, 0x3c, 0x54, 0xec, 0x18, 0xdb, 0x5c, 0x02, 0x1a, 0xfe, 0x43, 0xfb, 0xfa, 0xaa, 0x3a, 0xfb, 0x29, 0xd1, 0xe6, 0x05, 0x3c, 0x7c, 0x94, 0x75, 0xd8, 0xbe, 0x61, 0x89, 0xf9, 0x5c, 0xbb, 0xa8, 0x99, 0x0f, 0x95, 0xb1, 0xeb, 0xf1, 0xb3, 0x05, 0xef, 0xf7, 0x00, 0xe9, 0xa1, 0x3a, 0xe5, 0xca, 0x0b, 0xcb, 0xd0, 0x48, 0x47, 0x64, 0xbd, 0x1f, 0x23, 0x1e, 0xa8, 0x1c, 0x7b, 0x64, 0xc5, 0x14, 0x73, 0x5a, 0xc5, 0x5e, 0x4b, 0x79, 0x63, 0x3b, 0x70, 0x64, 0x24, 0x11, 0x9e, 0x09, 0xdc, 0xaa, 0xd4, 0xac, 0xf2, 0x1b, 0x10, 0xaf, 0x3b, 0x33, 0xcd, 0xe3, 0x50, 0x48, 0x47, 0x15, 0x5c, 0xbb, 0x6f, 0x22, 0x19, 0xba, 0x9b, 0x7d, 0xf5, 0x0b, 0xe1, 0x1a, 0x1c, 0x7f, 0x23, 0xf8, 0x29};

char ciphertext[1024] = {0,};
char newplaintext[1024] = {0,};

#define __NOPRINT__ 0

int salsa20_counter = 0;
int hsalsa20_counter = 0;
int poly1305_counter = 0;

int main(int argc, const char** argv)
{
    // int i;
    
    // unsigned char mac[16] = {};
    // unsigned char k[] = {46, 157, 203, 70, 127, 98, 29, 236, 220, 198, 238, 173, 48, 35, 201, 34, 38, 209, 204, 112, 165, 173, 225, 134, 62, 229, 62, 116, 115, 74, 219, 49 };
    // unsigned char m[] = {244, 211, 34, 196, 174, 106, 60, 198, 214, 235, 107, 145, 117, 192, 86, 243, 91, 168, 37, 5, 202, 184, 237, 143, 25, 247, 47, 144, 69, 194, 88, 167, 196, 168, 46, 38, 81, 43, 88, 90, 26, 183, 143, 10, 52, 193, 22, 236, 136, 245, 163, 50, 21, 118, 34, 145, 250, 120, 62, 13, 123, 134, 15, 190 };
    
    // my_crypto_onetimeauth_poly1305(mac, m, 55, k);

    // printf("\nmac is: \n");
    // for (i = 15;i >= 0;i--)
    // {
    //     printf("%02x", mac[i]);
    // }
    
    


	char* pub_name = "publickey";
    char* prv_name = "privatekey";
    int len = 0;
	uint32_t i = 0;
    
    
    if(argc != 3)
    {
        printf("This app, should be executed with two parameters.\n");
        printf("First param: \tTest Vector's length in bytes.\n");
        printf("Second param:\tHow many times the operation will be repeated.\n");        
        
        return -1;
    }
    
    
    getchar();

    sigma_proto* sp1 = proto_descriptor();

    proto_set(sp1, pub_name, pub_key1);
    proto_set(sp1, prv_name, prv_key1);

    proto_init(sp1);

	sigma_proto* sp2 = proto_descriptor();

    proto_set(sp2, pub_name, pub_key2);
    proto_set(sp2, prv_name, prv_key2);

    proto_init(sp2);

	for(i=0; i<atoi(argv[2]); i++)
	{

		#ifdef __NOPRINT__
		    printf("Plain Text is: \n%s \n\n", plaintext);
		#endif

		len = proto_encode(sp1, (uint8_t*)plaintext, (uint8_t*)ciphertext, atoi(argv[1]));

		#ifdef __NOPRINT__
		    printf("Cipher Text is: %d\n\n", len);
		#endif
        
		len = proto_decode(sp2, (uint8_t*)ciphertext, (uint8_t*)newplaintext, len);

		#ifdef __NOPRINT__
		    printf("Plain Text is: \n%s \n\n", newplaintext);
		#endif

	}

	// printf("salsa20_counter: %d\n", salsa20_counter);
    // printf("hsalsa20_counter: %d\n", hsalsa20_counter);
    // printf("poly1305_counter: %d\n", poly1305_counter);

    return 0;
}
