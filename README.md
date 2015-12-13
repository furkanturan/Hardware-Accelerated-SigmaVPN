# Hardware-Accelerated-SigmaVPN

This is a VPN device design project using SigmaVPN application as base VPN
solution. The SigmaVPN code is altered into a device form where it has two ports
one as public and the other as private communication ports. Moreover, I am
running it on ZYNQ FPGA on a ZYBO boards, and providing it HW accelerators
implemented on FPGA fabric. This is currently an ongoing project done as
Master Thesis work in KU Leuven - ESAT.

## VPN device

It is configured as two port device which are named as public and private ports.
Private port listens every packet arriving the device i.e. all TCP, UDP, DHCP,
ARP, ... All specific or broadcast messages received by private port are
encrypted and transmitted to pair device over public port. So public port just
provides a socket communication.

In that scheme, all messages arriving to private sides of both VPN devices are
carried to each other, and PC's or subnetworks connected to private sides of
both VPN pairs can communicate with each other as if they are physically
connected. And the packets traveling in between two private pairs are
transferred over internet under encryption.

## Explanation of Directories

### BootFiles

This directory contains required files that you need to copy into a MicroSD card
and run the ZYBO board with.

Whole the end result of the project is to prepare this files, and they give the
device mentioned in the description in the project.

(Project is not completed yet, so for now it only gives you partial results.)

### Linux Kernel

The device runs [this Linux kernel](https://github.com/Digilent/linux-digilent-dev ) provided by Digilent for ZYBO board.
It is not added as sub-repository to the project, but two modifications are
included for how to compile it are included.

The first modification is done to `.config` file to enable AX88179_178A drivers
needed to enable USB-Ethernet device. Therefore, provided `.config` file should
be used instead of creating default configuration file using
'xilinx_xynq_defconfig'.

Another modification is to provide DMA driver in 'drivers/dma/xilinx/'
directory. This is the driver file used to communicate with DMA and so handle
communication with coprocessor to provide HW accelerators of cryptographic
functions.

You can use this tutorial to learn how to compile Linux and play with ZYBO
board [here](http://www.instructables.com/id/Embedded-Linux-Tutorial-Zybo/?ALLSTEPS).

### SigmaVPN

This folder has a fork of original SigmaVPN code. In this fork a new module
instead of TUN/TAP is created. The purpose of that module is to offer a private
communication block to sniff any packet in the private side of the VPN device
so that all of those messages can be directed to the private side of pair device
and so both private sides of the both pair VPN devices will be virtually linked
to each other.

### HW_Design

This folder includes the base HW design of FPGA as Vivado project.

WARNING: It is an actively developed piece of the project, so what is pushed
here is project files after some milestones. Doesn't has always the most updated
project files.

TODO: Provide them as not Vivado project file but as a TCL script.

### CryptoCP

This folder includes a piece of the base HW design, namely the coprocessor IP
core prepared for this project and used by base design.
