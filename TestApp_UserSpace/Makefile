
Zybo =

ifeq ($(ZYBO),1)

PWD		= $(shell pwd)

INSTALLDIR ?= $(PWD)/install
BINDIR ?= $(INSTALLDIR)/bin
SYSCONFDIR ?= $(INSTALLDIR)/etc
LIBEXECDIR ?= $(INSTALLDIR)/lib/sigmavpn

SODIUM_INSTALLDIR ?= $(PWD)/../sigmavpn_deps/libsodium_installdir
SODIUM_CPPFLAGS ?= -I$(SODIUM_INSTALLDIR)/include
SODIUM_LDFLAGS ?= -Wl,-static -L$(SODIUM_INSTALLDIR)/lib -lsodium -Wl,-Bdynamic

LIBPCAP_PATH ?= $(PWD)/../sigmavpn_deps/libpcap-1.7.4
LIBPCAP_CPPFLAGS ?= -I$(LIBPCAP_PATH)
LIBPCAP_LDFLAGS ?= -L$(LIBPCAP_PATH) -lpcap

CC = arm-xilinx-linux-gnueabi-gcc
CFLAGS ?= -g3 -O2 -fPIC -Wall -Wextra -lc
CPPFLAGS += -g3 -O2 $(SODIUM_CPPFLAGS)
LDFLAGS += $(SODIUM_LDFLAGS) -ldl -pthread
DYLIB_CFLAGS ?= $(CFLAGS) -shared

TARGETS_OBJS = main.o nacl_cb_hw.o
TARGETS_BIN = testapp

TARGETS = $(TARGETS_OBJS) $(TARGETS_BIN)

all: $(TARGETS)

clean:
	rm -f $(TARGETS)    

distclean: clean

install: all
	mkdir -p $(BINDIR) $(SYSCONFDIR) $(LIBEXECDIR)
	cp $(TARGETS_BIN) $(BINDIR)
	cp $(TARGETS_MODULES) $(LIBEXECDIR)

testapp: main.o
	$(CC) -o testapp main.o nacl_cb_hw.o $(LDFLAGS)

%.o: %.c $(HEADERS)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@
    
else

INSTALLDIR ?= /usr/local
BINDIR ?= $(INSTALLDIR)/bin
SYSCONFDIR ?= $(INSTALLDIR)/etc
LIBEXECDIR ?= $(INSTALLDIR)/lib/sigmavpn

SODIUM_CPPFLAGS ?= -I/usr/local/include
SODIUM_LDFLAGS ?= -L/usr/local/lib -lsodium
CFLAGS ?= -g3 -O2 -fPIC -Wall -Wextra
CPPFLAGS += -g3 -O2 $(SODIUM_CPPFLAGS)
LDFLAGS += $(SODIUM_LDFLAGS) -ldl -pthread
DYLIB_CFLAGS ?= $(CFLAGS) -shared

CC = gcc

TARGETS_OBJS = main.o nacl_cb_hw.o
TARGETS_BIN = testapp

TARGETS = $(TARGETS_OBJS) $(TARGETS_BIN)


all: $(TARGETS)

clean:
	rm -f $(TARGETS)    

distclean: clean

install: all
	mkdir -p $(BINDIR) $(SYSCONFDIR) $(LIBEXECDIR)
	cp $(TARGETS_BIN) $(BINDIR)
	cp $(TARGETS_MODULES) $(LIBEXECDIR)

testapp: main.o
	$(CC) -o testapp main.o nacl_cb_hw.o $(LDFLAGS)

%.o: %.c $(HEADERS)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@
    
endif