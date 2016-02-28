# Hardware Design of the Project

There are two TCL scipts in this directory. By compiling them, you can create the vivado projects of the hardware design.

## NACL CryptoBox Coprocessor

/nacl_cb/nacl.tcl creates the coprocessor vivado project under the /nacl_cb directory and packages the project in to IP under /nacl_cb/ip_repo/

Ip repo should be constructed before the base system.

## Base System

./basesystem.tck file creates the main hardware design of the project, where the Zynq's configuration is done for the ZYBO board.