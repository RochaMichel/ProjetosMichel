
#Include 'Protheus.ch'
#Include 'RwMake.ch'
#Include 'TopConn.ch'


User Function MovAplica(cProduto, cLocal, nQtdAj)
    Local aCab      := {}
    Local aItem     := {}
    Local aItens    := {}
    Local cCodTM    := GETMV("MV_XTMAPLI",,"501")

    Private lMsErroAuto := .f. //necessario a criacao

    aCab := {{"D3_DOC"     , GetSxeNum("SD3","D3_DOC") , NIL},;
             {"D3_TM"      , cCodTM                           , NIL},;
             {"D3_EMISSAO" , dDataBase                        , NIL}}


    aItem := {{"D3_COD"     , cProduto , NIL},;
              {"D3_QUANT"   , nQtdAj   , NIL},;
              {"D3_LOCAL"   , cLocal   , NIL}}

    aadd(aItens, aItem) 
    
    MSExecAuto({|x,y,z| MATA241(x,y,z)}, aCab, aItens, 3)

    If lMsErroAuto 
        Mostraerro() 
        DisarmTransaction() 
        break
    EndIf

Return

