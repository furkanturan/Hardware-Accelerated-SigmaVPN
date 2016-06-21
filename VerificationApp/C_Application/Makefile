#CC = arm-xilinx-linux-gnueabi-gcc
CC = gcc
CFLAGS = -g

OBJ = main.o proto_nacltai.o crypto_box.o hsalsa20.o poly1305.o tai.o pack.o

SODIUM_INSTALLDIR ?= $(PWD)/libsodium
SODIUM_LDFLAGS ?= -L$(SODIUM_INSTALLDIR)/lib -lsodium
LDFLAGS += $(SODIUM_LDFLAGS) -ldl

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS) $(LDFLAGS)

cryptotest: $(OBJ)
	${CC} -o $@ $^ $(CFLAGS) $(LDFLAGS)

clean:
	rm -f $(OBJ)