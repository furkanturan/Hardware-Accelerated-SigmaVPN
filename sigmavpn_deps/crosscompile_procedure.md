// Linux version running on the Zybo Board is:
//      Linux (none) 3.18.0-xilinx-46110-gd627f5d #1 SMP PREEMPT Tue Aug 25 17:21:47 CEST 2015 armv7l GNU/Linux

// Take the dependencies

export CROSS_COMPILE=arm-xilinx-linux-gnueabi-
source /opt/Xilinx/Vivado/2014.3.1/settings64.sh

// Cross compile libdsodium into:   /home/ft/Thesis/SigmaVPN/Zybo/libsodium_installdir
// Instructions are here, but I changed them for "arm-xilinx-linux-gnueabi"
//      http://doc.libsodium.org/installation/index.html#cross-compiling

export PATH=/opt/Xilinx/SDK/2014.3.1/gnu/arm/lin/bin:$PATH
export CFLAGS='-g'
./configure --host=arm-xilinx-linux-gnueabi --prefix=/home/ft/Thesis/SigmaVPN/Zybo/libsodium_installdir
make install

// To cross compile libpcap install these dependencies of making libpcap first:
//      apt-get install flex
//      apt-cache search yacc
//
// Got help from:   https://emreboy.wordpress.com/2013/03/02/cross-compile-libpcap-source-code/

// Then cross compile libpcap

CC=arm-xilinx-linux-gnueabi-gcc ac_cv_linux_vers=2 CFLAGS=-g ./configure --host=arm-xilinx-linux --with-pcap=linux
make

// Then make SigmaVPN with new Makefile
