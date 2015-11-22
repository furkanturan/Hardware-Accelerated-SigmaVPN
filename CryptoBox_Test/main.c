#include <stdio.h>
#include <stdlib.h>

#include "proto_nacltai.h"
#include "proto.h"

char *pub_key1 = "19f0818f7173e6614f66e3c8c98a24288beb67facf12cc9ace60c3cbfb79040b";
char *prv_key1 = "243c1d70bd186ffa030d0420668cc50e2177ba5c41fea67f76f2ca0e1ca0e9dc";

char *pub_key2 = "b598befbc22322323f102ad39fd5dda34e5cc4640d9dbc8e9c7b6275ef4bf315";
char *prv_key2 = "64f1d9924e10f95ddf8010ade99bbc5bc86a69b4dad9c0078a47d5dd82589ac5";

char *plaintext = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse non massa vel enim semper placerat ut vel sapien. Quisque elementum, diam quis condimentum tincidunt, nulla tortor egestas quam, vel pharetra libero leo eget lacus. Donec sed scelerisque nulla. Vestibulum rutrum vestibulum ipsum, et ullamcorper nulla pretium id. Cras a lorem augue. Cras et viverra nunc, nec tincidunt lacus. Mauris vitae urna at lectus vulputate egestas. Vivamus et blandit tortor. Donec ac blandit purus, lacinia massa nunc.";
char ciphertext[1024] = {0,};
char newplaintext[1024] = {0,};

#define __NOPRINT__ 0

int salsa20_counter = 0;
int hsalsa20_counter = 0;
int poly1305_counter = 0;

int main(int argc, const char** argv)
{
	char* pub_name = "publickey";
    char* prv_name = "privatekey";
    int len = 0;
	uint32_t i = 0;

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

	printf("salsa20_counter: %d\n", salsa20_counter);
		printf("hsalsa20_counter: %d\n", hsalsa20_counter);
			printf("poly1305_counter: %d\n", poly1305_counter);

    return 0;
}
