# Potential Gains of Going to HW

Reference is implemented Salsa20 code, which takes 10000 cycles on ARM
processors of the ZYNQ on ZYBO board, but took around 1000 with designed
coprocessor. However, the overhead of going to kernel mode on Linux to
communicate with the HW is a big penalty which tooks 7000 cycles.

Now what is considered is to go to HW and process all the `crypto_box_afternm()`
and `crypto_box_open_afternm()` once and so pay the penalty only once.

For those functions, time or processing power consuming functions are given
below, including how many times they are called, and potential overall gain
of going to HW only once is calculated assuming that execution of every function
will be reduced to 10% as it is the case of `salsa20` function.

## Rough Cycle Estimations Corresponding to Each Function

| Function  | Cycles (CPU) | Cycles (HW) |
| :---      | :---         | :---        |
| Salsa20   | 10000        | 1000        |
| HSalsa20  | 10000        | 1000        |
| Poly1305  | 20000        | 2000        |
| Penalty   | 0            | 7000        |

## Rough Gain Estimations for Different Length of Message Encryption


| Message Len  (In Bytes)| # of calls Salsa20/Hsalsa20/Poly1305 | Cycles (CPU) | Cycles (HW) | Reduce To (%)|
| :-----                 | :-----      | :-----       | :-----      | :-----      |
| 128                    | 3/1/1       | 60000        | 13000       | 21        |
| 256         | 5/1/1       | 80000        | 15000       | 18.7      |
| 512         | 9/1/1       | 120000       | 19000       | 15.8      |
| 1024        | 17/1/1      | 200000       | 27000       | 13.5      |
| 1536        | 25/1/1      | 280000       | 35000       | 12.5      |
