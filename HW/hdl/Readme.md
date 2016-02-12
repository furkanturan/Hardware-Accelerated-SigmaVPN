# HDL Files of Cryto Coprocessor

## InputReg

Input registers of the design. It reads data from DMA (when coprocessor's driver
makes DMA send data from RAM to the coprocessor). It has 5 important register's:

> Will be modified to read PRECOMP only once, not at each run.

**CMD** - _output_ - 16 bits / 2 bytes
Stores command to the coprocessors such as encryption/decryption etc. 

**MLEN** - _output_ - 16 bits / 2 bytes
Stores length of the input array.

**NONCE** - _output_ - 192 bits / 24 bytes / 6 int32
Stores nonce created by the CryptoBox.

**PRECOMP** - _output_ - 255 bits / 32 bytes / 8 int32
Stores key for the HSalsa20 and Salsa20 functions. At first it stores SW calculated 1st level key, then at the beginning of operation with HSalsa20 2nd level key is calculated and overwritten to this register.

**MESSAGE** - _output_ - 522 bits / 64 bytes / 16 int32
Stores one block of input message as either plaintext or cipher text. The length is equal to output length of Salsa20 function.

**SL_KEY** - _input_ - 255 bits / 32 bytes / 8 int32
Input for calculated 2nd level key.

**SL_KEY_LOAD** - _input_ - Active High
Load signal of 2nd level key. Together with receiving this signal and Clock edge, 2nd level key will be loaded to PRECOMP register.

**RDY** - _input_ - Active High
Since MESSAGE register should be loaded block wise, this signal informs DMA master that it is ready to read next input block.

**DONE** - _output_ - Active High
When final block of data is read from DMA master, this signal will be asserted.

## NonceMUX

Nonce is first read as input from the SW. Lower 16 bits of it is used to calculate 2nd level key using HSalsa20, then upper 8 bits together with concatenation 8 bits counter value is used to create a block of cipher stream. For calculating each block of cipher stream, of the nonce is incremented by one.

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
When used for HSalsa20, lower 256 bits stores the hash output which is 2nd level key here.
When used for Salsa20, it stores one block of stream cipher.

**SEL** - _input_

+ 0 for HSalsa20
+ 1 for Salsa20

**INIT** - _input_ - Active High
Starts operation if it is in wait state (system start or done).

**DONE** - _output_ - Active High
Asserted done signal when output is ready. Cleared by (re-)initing the operation.


## DMA_Controller

Configures DMA to write output data back to RAM.

> Should be updated: Renew signal names, and provide transfer length from MLEN  register in InputREG.

**INIT_AXI_TXN** - _input_ - Active High
Starts configuring DMA for transfer operation. But doesn't set the transfer length register of DMA which will start data transfer.

**CONT_AXI_TXN** - _input_ - Active High
Sets transfer length register of DMA which starts the data transfer.

**TXN_DONE** - _output_ - Active High
Asserted after DMA's configuration is done. Cleared when reset or (re-)inited.

## OutputDMA

Sends a block of (64 byte) cipher or plain text (or MAC) output to RAM.

> Update to be able to set counter to 2 at reset state, since there is 32 byte of offset for the first block of output

**D_IN** - _input_ - 511 bits / 64 bytes / 16 int32
Sends its content by 32bit blocks to RAM via DMA, starting from lower 32 bits to higher.

> Not specific from where it is yet

**INIT** - _input_ - Active High
Initializes transfer.

**M_AXIS_TLAST** - _output_ - Active High
Don't have a done signal, but this one is good for that purpose, informs the DMA that last block of data is on the line.

##Poly1305_RS

> There will be changes. There will be no input MUX, input is directly from Salsa20's output.
