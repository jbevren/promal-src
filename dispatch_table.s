
;
; PROMAL for the Commodore 64
; Copyright (C) 1985, SMA, Inc.
; Re-source (C) 2015 jbevren
;

; dispatch vector table (originally $e00)

; version 0
; status: matches original


; Jump table for promal p-codes
dsptchl =*
dsptchh =*+1
Ppbrkv    .WORD Pbrk
PPwordv1  .WORD PPword
Ppeekbv   .WORD Ppeekb
PpeekWv   .WORD PpeekW
PpeekRv   .WORD PpeekR
PpeekWIv  .WORD PpeekWI
PLkLstv   .WORD PLkLst
Pc0Ev     .WORD Pc0E
PpokeBv   .WORD PpokeB
PpokeWv   .WORD PpokeW
PpokeRv   .WORD PpokeR
PPkIdxv   .WORD PPkIdx
PFindStv  .WORD PFindSt
Pc1Av     .WORD Pc1A
Paddwwv   .WORD Paddww
Padd2swv  .WORD Padd2sw
Pc20v     .WORD Pc20
Pgotov    .WORD Pgoto
Pbzerov   .WORD Pbzero
Pbjsrv    .WORD Pbjsr
Pgosubv   .WORD Pgosub
Pselbv    .WORD Pselb
Pselwv    .WORD Pselw
PphBWv    .WORD PphBW
PPbytev   .WORD PPbyte
PPwordv   .WORD PPword
PPrealv   .WORD PPreal
PGVarAdv  .WORD PGVarAd
PVar2stBv .WORD PVar2stB
PVar2stWv .WORD PVar2stW
Pc3Cv     .WORD Pc3C
Padd230v  .WORD Padd230
Pstkribv  .WORD Pstkrib
Pstkriwv  .WORD Pstkriw
Pc44v     .WORD Pc44
Pc46v     .WORD pr16af
Pst2varBv .WORD Pst2varB
Pst2varWv .WORD Pst2varW
Pc4Cv     .WORD Pc4C
Pstkwibv  .WORD Pstkwib
Pstkwiwv  .WORD Pstkwiw
Pc52v     .WORD Pc52
refugev   .WORD refuge
escapev   .WORD escape
Pc58b     .WORD Pc58
PIll5Av   .WORD eillop
PIll5Cv   .WORD eillop
PIll5Ev   .WORD eillop
PIll60v   .WORD eillop
PIll62v   .WORD eillop
PIll64v   .WORD eillop
PIll66v   .WORD eillop
PPzero1v  .WORD PPzero1
PPonev    .WORD PPone
PPtwov    .WORD PPtwo
Pwherewv  .WORD Pwherew
PIll70v   .WORD eillop
PisLTbv   .WORD PisLTb
PisLTwv   .WORD PisLTw
PisLTiv   .WORD PisLTi
PisLTrv   .WORD PisLTr
PisLEbv   .WORD PisLEb
PisLEwv   .WORD PisLEw
PisLEiv   .WORD PisLEi
PisLErv   .WORD PisLEr
PisEQbv   .WORD PisEQb
PisEQwv   .WORD PisEQw
PisEQrv   .WORD PisEQr
PisNEbv   .WORD PisNEb
PisNEiv   .WORD PisNEi
PisNErv   .WORD PisNEr
PisGEbv   .WORD PisGEb
PisGEwv   .WORD PisGEw
PisGEiv   .WORD PisGEi
PisGErv   .WORD PisGEr
PisGTbv   .WORD PisGTb
PisGTwv   .WORD PisGTw
PisGTiv   .WORD PisGTi
PisGTrv   .WORD PisGTr
Psgnflpv  .WORD Psgnflp
PcA0v     .WORD PcA0
Paddbv    .WORD Paddb
Paddwv    .WORD Paddw
Paddrv    .WORD Paddr
Psubbv    .WORD Psubb
Psubwv    .WORD Psubw
Psubrv    .WORD Psubr
Pmulwv    .WORD Pmulw
Pmulrv    .WORD Pmulr
Pdiviv    .WORD Pdivi
Pdivwv    .WORD Pdivw
Pdivrv    .WORD Pdivr
Pdivmodv  .WORD Pdivmod
Pshlbv    .WORD Pshlb
Pshlwv    .WORD Pshlw
Pshrbv    .WORD Pshrb
Pshrwv    .WORD Pshrw
Pnotbv    .WORD Pnotb
Pandbv    .WORD Pandb
Porbv     .WORD Porb
Pxorbv    .WORD Pxorb
Ppopbv    .WORD Ppopb
Ppop1bv   .WORD Ppop1b
Pr2wv     .WORD Pr2w
PPzerov   .WORD PPzero
Pb2rv     .WORD Pb2r
Pw2rv     .WORD Pw2r
Pi2rv     .WORD Pi2r
Pswapbv   .WORD Pswapb
PcDAv     .WORD PcDA
PcDCv     .WORD PcDC
PcDEv     .WORD PcDE
Prtsv     .WORD Prts
Prts1v    .WORD Prts
PcE4v     .WORD PcE4
PcE6v     .WORD pr1737
Pdupwv    .WORD Pdupw
Ppoprv    .WORD Ppopr
Pendv     .WORD Pend
Pnextv    .WORD Pnext
Pstkpbv   .WORD Pstkpb
Pstkpwv   .WORD Pstkpw
PcF4v     .WORD PcF4
Ppopb1v   .WORD Ppopb1
Ppopwv    .WORD Ppopw
Prolwv    .WORD Prolw
PIllFCv   .WORD eillop
PIllFEv   .WORD eillop
