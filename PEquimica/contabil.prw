#INCLUDE 'totvs.ch'

user function contaGat()
local cRetorno := ''
cRetorno := SRZ->RZ_PD + " - " + ALLTRIM(POSICIONE("SRV",1,xFILIAL("SRV")+SRZ->RZ_PD,"RV_DESC"))+" REF.FOLHA DE "+ SUBS(DTOC(DDATABASE),4,7)                                                                        
Return cRetorno
