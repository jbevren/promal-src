
;
; PROMAL for the Commodore 64
; Copyright (C) 1985, SMA, Inc.
; Re-source (C) 2015 jbevren
;

; system library jump table.  THIS CANNOT BE MOVED.

; version 
; status: 


init    JMP initz
r283e   JMP r283ez
        JMP erun
getc    JMP getcz
GETCF   JMP getcfz
GETL    JMP getlz
GETLF   JMP getlfz
PUT     JMP putz
PUTF    JMP putfz
STRVAL  JMP strvalz
INTSTR  JMP intstrz
WORDSTR JMP wordstrz
OPEN    JMP openz
CLOSE   JMP closez
FILL    JMP fillz
CMPSTR  JMP cmpstrz
blkmov  JMP blkmovz
movstr  JMP movstrz
LENSTR  JMP lenstrz
EXIT    JMP exitz
ABORT   JMP abortz
TOUPPER JMP toupperz
ALPHA   JMP alphaz
NUMERIC JMP numericz
drvcmd  JMP drvcmdz     ; undocumented: Send command to drive
GETBLKF JMP getblkfz
PUTBLKF JMP putblkfz
inlist  JMP inlistz
LOOKSTR JMP lookstrz
OUTPUT  JMP outputz
OUTPUTF JMP outputfz
CURSET  JMP cursetz
CURCOL  JMP curcolz
CURLINE JMP curlinez
INSET   JMP insetz
RANDOM  JMP randomz
GETARGS JMP getargsz
TESTKEY JMP testkeyz
ZAPFILE JMP zapfilez
CHKSUM  JMP chksumz
DIR     JMP dirz
redirect JMP redirectz
RENAME  JMP renamez
MIN     JMP minz
MAX     JMP maxz
load    JMP loadz
relocate JMP relocz
EDLINE  JMP edlinez
INLINE  JMP inlinez
FKEYSET JMP fkeysetz
FKEYGET JMP fkeygetz
getver  JMP getverz
swpmem  JMP swpmemz
mlget   JMP mlgetz
clsall  JMP clsallz
GETKEY  JMP getkeyz
STRREAL JMP strrealz
REALSTR JMP realstrz
p100f   JMP p100fz
noreal  JMP norealz
pjsr    JMP pjsrz
SUBSTR  JMP substrz
        JMP erun
        JMP erun
        JMP erun
        JMP erun
gettst  JMP gettstz
ABS     JMP absz
proquit JMP proquitz
        JMP erun
        JMP erun
        JMP erun
