#!/bin/bash
clear

echo "Taking Deps: Arm Xilinx Linux GNUEABI"

export CROSS_COMPILE=arm-xilinx-linux-gnueabi-
source /opt/Xilinx/Vivado/2014.3.1/settings64.sh

cd ./sigmavpn

echo ""
echo "Cleaning"

make ZYBO=1 clean

echo ""
echo "Making"

make ZYBO=1

echo ""
echo "Installing"

make ZYBO=1 install
echo ""
echo "Done"
