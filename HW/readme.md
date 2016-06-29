# Hardware Design of the Project

This directory includes the two *NaCl CryptoBox IP Cores*, and *base system design*. The IP Cores are designed to implement the encryption and decryption operations of the NaCl's CryptoBox. One implementation has double instantiation of the Salsa20 and Poly1305 hardware modules to be able to process double length the input in a unit time.

To build the IP Cores you can use the *.tcl* files provided in the sub-folder, and the base system design will provide you the design made for Zybo by means of settings, configurations, and connections between the PS, DMA and the NaCl CryptoBox Croprocessor.

Note that the IP cores does not implement the NaCl CryptoBox completely. The CryptoBox is often used in a way that its session key derivation, and encryption operations are separated. This HW implementations follows this method, and implements the encryption and decryption functions, excluding the session key derivation parts. 

Namely, the `crypto_box_beforenm` function mentioned in the NaCl's [documentation](https://nacl.cr.yp.to/box.html) is exempted in hardware implementation, byt `crypto_box_afternm` and `crypto_box_open_afternm` are implemented.

As you study the input and output data structures, you should notice that for decryption operation received MAC is not provided as an input but output contains the calculated MAC. That is a design decision to decrease the total execution time, and reduce resource consumption as it is descibed in Master Thesis text in the documentation folder. The verification of the MAC is left as a task for software. In the decryption case, the software invokes the coprocessor, received its output, and when receiving the output compare the received MAC with the calculated one. Only if the two are same, it uses the decrypted message.

The zybo_bsd folders contains the base system design that consists of the design used for creating the VPN Device with connections of PS, DMA, and the NaCl CryptoBox Croprocessor.

## NACL CryptoBox Coprocessor

The Coprocessor is designed as an IP Core with three AXI Ports:
```
         ___Coprocessor_IP___
        |                    |
        |       M_AXI_LITE > |
        |                    |
        |           M_AXIS > |
        |                    |
        | < S_AXIS           |
        |____________________|
```
The IP Core's execution starts with a DMA transfer from PS to NaCl Coprocessor through its S_AXIS port. The transfer should send the input data to the coprocessor that has the message to be encrypted togeter with the operation specific metadata, e.g., a command, message length, nonce. The strucutre of the input data will be discussed below in detail. As the coprocessor receives the data buffer, it immediately starts executing the operation.

To transfer the results back to the PS, it configures the DMA from using its M_AXI_LITE port, and offers the output data to the PS using M_AXIS port.

The figures showing the block diagram of how PS, DMA and NaCl CryptoBox are connected to each other are given in the Figure 3.3 of the Master Thesis text in the documentation folder.

### The Stucture of the Input Data Buffer

The input data buffer from PS to the coprocessor has following fields in the following order:

**CMD** - A 2-byte command, 

0'th bit: denotes whether the L1Key (the session key in the context of NaCl) will be included in the next bytes of the transfer or will be excluded from the data transfer. If it is '0', L1 key is chosen to be exempted in the transfer, then the coprocessor will use the last received L1Key to encrypt or decrypt the current message input with.

1'th bit: denotes if the message will be encrypted or decypted. If it is '1', then the message will be encrypted, otherwise decrypted.

**MLEN** - A 2-byte field to store the message length in bytes.

**NONCE** - A 24-byte field to store the Nonce (number used once) that will be used in the encyption, or in the decyryption case it is the nonce that has been used while the message was encrypted.

**L1KEY** - A 32-byte session key generated using the from public and private key pairs by calling the `crypto_box_beforenm` function of the NaCl CryptoBox in software.

**MESSAGE** - The field to store the input message to the coprocessor.

### The Stucture of the Output Data Buffer

As the encryption or decryption operation is processed the outputs will be pushed to the RAM for the software in PS. 

In encryption case the output data will consist of the ciphertext followed by a 16-byte MAC.

In the decyption case the output data will consist of the plaintext followed by a 16-byte MAC.  