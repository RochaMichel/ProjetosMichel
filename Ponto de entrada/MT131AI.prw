#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MT131AI
Adiciona campos no envio de e-mail após gerar cotação.
@author  Felipe Valença - Newsiga
@since   14/09/22
@version 1.0
/*/
//-------------------------------------------------------------------

User Function MT131AI()

    Local aItemAux := {} 
    Local cNomeCom := ""
    Local cEmailCo := ""
    Local cFoneCom  := ""
    Local aArea := GetArea()
    
    aADD(aItemAux,{'cIE'      ,SM0->M0_INSC})

    dbSelectArea("SY1")
    dbSetOrder(3)
    If dbSeek(xFilial("SY1") + RetCodUsr() )
        cNomeCom := SY1->Y1_NOME
        cEmailCo := SY1->Y1_EMAIL
        cFoneCom := SY1->Y1_TEL
    Endif    
    aADD(aItemAux,{'cNomeCom' ,cNomeCom})
    aADD(aItemAux,{'cEmailCo' ,cEmailCo})
    aADD(aItemAux,{'cFoneCom' ,cFoneCom})

    aADD(aItemAux,{'It.cUmMed' ,SB1->B1_UM})
    aADD(aItemAux,{'It.fabric' ,SB1->B1_FABRIC})
    aADD(aItemAux,{'It.cMemo'  ,SC1->C1_OBS})
    RestArea(aArea)

Return aItemAux

