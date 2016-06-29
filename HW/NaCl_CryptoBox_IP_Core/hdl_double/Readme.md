# HDL Files of Cryto Coprocessor

## InputReg

Input registers of the design. It reads data from DMA (when coprocessor's
driver makes DMA send data from RAM to the coprocessor). It has 5 important
 registers explained below.

It has two states, one is to read operation parameters, such as an instruction 
(command), message length, nonce. In the other state, it reads package data in 
blocks of 64 byte. RDY signal input is to inform this module that coprocessor 
finished processing current block, so reading next block of package can be
started.

Moreover, there is one more consideration about PRECOMP data which can be 
included in operation parameters or exluded. The idea is that PRECOMP is
calculated by SW using beforenm function of the NaCl cryptobox, and it remains
same as long as session keys are same. Therefore, lowest bit of CMD is used to
inform this module that RPECOMP is also read from the RAM together with
operation parameters, or it will not (the old value will be kept).

**CMD** - _output_ - 16 bits / 2 bytes

Stores command to the coprocessors such as encryption/decryption etc. 

**MLEN** - _output_ - 16 bits / 2 bytes

Stores length of the input array.

**NONCE** - _output_ - 192 bits / 24 bytes / 6 int32

Stores nonce created by the CryptoBox.

**L1KEY** - _output_ - 255 bits / 32 bytes / 8 int32

Stores precomputed 1st level key for the HSalsa20 function to derive 2nd level
key from it (using nonce).

**L2KEY** - _output_ - 255 bits / 32 bytes / 8 int32

Stores derived 2nd level key.

**MESSAGE** - _output_ - 522 bits / 64 bytes / 16 int32

Stores one block of input message as either plaintext or cipher text. The 
length is equal to output length of Salsa20 function.

**L2KEY_IN** - _input_ - 255 bits / 32 bytes / 8 int32

Input for calculated 2nd level key.

**L2KEY_IN_LOAD** - _input_ - Active High

Load signal of 2nd level key. Together with receiving this signal and Clock 
edge, 2nd level key will be loaded to PRECOMP register.

**RDY** - _input_ - Active High

Since MESSAGE register should be loaded block wise, this signal informs DMA
master that it is ready to read next input block.

**DONE** - _output_ - Active High

When final block of data is read from DMA master, this signal will be asserted.

## NonceMUX

Nonce is first read as input from the SW. Lower 16 bits of it is used to
calculate 2nd level key using HSalsa20, then upper 8 bits together with
concatenation 8 bits counter value is used to create a block of cipher stream.
For calculating each block of cipher stream, of the nonce is incremented by one.

**NONCE_IN** - _input_ - 192 bits / 24 bytes / 6 int32

Receives nonce input from InputReg.

**NONCE_OUT** - _output_ - 128 bits / 16 bytes / 4 int32

Nonce signal provided to HSalsa20 or Salsa20 function.

**SEL** - _input_

+ 0 for HSalsa20: `NONCE_OUT <= NONCE_IN[127 downto 0]`
+ 1 for Salsa20: `NONCE_OUT <= counter & NONCE_IN[191 downto 128]`

**UPD** - _input_ - Active High

Increments counter.

## hSalsa20

Implements either HSalsa20 or Salsa20 functions.

**D_IN** - _input_ - 128 bits / 16 bytes / 4 int32

Input from NonceMUX.

**KEY** - _input_ - 255 bits / 32 bytes / 8 int32

Key input as PRECOMP from InputReg. 

**D_OUT** - _output_ - 511 bits / 64 bytes / 16 int32

When used for HSalsa20, lower 256 bits stores the hash output which is 2nd 
level key here.
When used for Salsa20, it stores one block of stream cipher.

**SEL** - _input_

+ 0 for HSalsa20
+ 1 for Salsa20

**INIT** - _input_ - Active High

Starts operation if it is in wait state (system start or done).

**DONE** - _output_ - Active High

Asserted done signal when output is ready. Cleared by (re-)initing the 
operation.


## DMA_Controller

Configures DMA to write output data back to RAM.

> Should be updated: Renew signal names, and provide transfer length from MLEN  
register in InputREG.

**INIT_AXI_TXN** - _input_ - Active High

Starts configuring DMA for transfer operation. But doesn't set the transfer 
length register of DMA which will start data transfer.

**CONT_AXI_TXN** - _input_ - Active High

Sets transfer length register of DMA which starts the data transfer.

**TXN_DONE** - _output_ - Active High

Asserted after DMA's configuration is done. Cleared when reset or (re-)inited.

## OutputDMA

Sends a block of (64 byte) cipher or plain text (or MAC) output to RAM.

> Update to be able to set counter to 2 at reset state, since there is 32 byte 
of offset for the first block of output

**D_IN** - _input_ - 511 bits / 64 bytes / 16 int32

Sends its content by 32bit blocks to RAM via DMA, starting from lower 32 bits 
to higher.

> Not specific from where it is yet

**INIT** - _input_ - Active High

Initializes transfer.

**M_AXIS_TLAST** - _output_ - Active High

Don't have a done signal, but this one is good for that purpose, informs the 
DMA that last block of data is on the line.

Just calculates R and S values for Poly1305 which are defined [here]
(http://cr.yp.to/mac/poly1305-20050329.pdf)

Loads R and S values to internal register with active high insertion of INIT
signal. Source of data is first ciphertext block at the output of the Salsa20
function.

## Poly1305

Poly1305 is defined [here](http://cr.yp.to/mac/poly1305-20050329.pdf)

This function receives key to calculated R and S at first and stores them in
dedicated registers. Then, The MAC code is calculated with 16 byte chucks of 
the ciphertext, where block's output value is added with an accumulator value 
and their sum is processed by Poly1305_Chucks function, and result is stored to
accumulator again. So the function is:

    ACC := ((ACC + MESSAGE_CHUNK) * R) mod (2^130-5);

And finalization operation is:

    ACC := (ACC + S) mod 2^128;

**INIT** - _input_ - Active High

Initializes calculation.    

**KEY** - _input_ - 256 bits / 32 bytes / 4 int32  

Key input from the first 32 byte of ciphertext.

**LOAD_RS** - _input_ - Active High

Together with the clock edge, Calculates R and S values from the KEY input, 
and stores them into R and S registers inside.

**MSG** - _input_ - 128 bits / 16 bytes / 4 int32  
**MSG_LEN** - _input_ - 5 bits

Message whose MAC will be calculated and its length. Since message is going to
be processed with max 16 byte chunks, MLEN can go upto 16. In fact MLEN equals 
to 0 is undefined for now. and it can be fixed if needed. This length 
information is important when processing the final block of the ciphertext. 

**LAST** - _input_ - Active High

Informs the blocks that current chunk, is the last chunk, so it executes the
final operation which is adding S to the accumulator. Should be asserted 
together with the INIT signal.

**DONE** - _output_ - Active High

Asserted done pulse signal when output is ready. Cleared immediately after. 

**MAC** - _output_ - 128 bits / 16 bytes / 4 int32

 Calculated MAC.