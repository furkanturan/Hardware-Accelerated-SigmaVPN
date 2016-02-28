#!/bin/bash
clear

export CROSS_COMPILE=arm-xilinx-linux-gnueabi-
source /opt/Xilinx/Vivado/2014.3.1/settings64.sh

cd TestApp
make ZYBO=1
cp testapp ../BootFiles/testapp

echo ""
