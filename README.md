# promal-src

Re-source of PROMAL nucleus

re-source work (c) 2015-2016 David Wood (jbevren)
original (c) 1986, SMA, Inc.

This project is intended to enable interoperability between the Commodore 64 and new plaforms that PROMAL may be ported to in the future.

To build this, just use 64tass and assemble the promal.s file.  Promal.s includes all other files in the correct order to build a nearly identical image.

$ 64tass -o promal promal.s

Differences:
 * abandoned loader code between basic stub and system heap is not included
 * proquitz is changed from jmp fce2 to jmp (fffc)

A visual difference comparison using vbindiff shows no other differences between the reassembled binary and the original.

If any issues arise from moving adding or deleting code, please contact me.  I won't include an email address, but it shouldn't be difficult to find me anyway. ;-)

Note also that this does not include the complete operating system.  The utilities on the disk are beyond the scope of this source code archive.

-jbevren
