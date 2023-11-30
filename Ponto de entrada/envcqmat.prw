#Include 'Protheus.ch'
/*/{Protheus.doc} ENVCQMAT
Ponto de entrada ENVCQMAT
@type function
@author CodERP Tecnologia
@since 01/08/2023
@return variant, Nill
/*/ 

User Function ENVCQMAT()

    Local lEnvCQ := PARAMIXB[1]
    Local cFilCQ := GetMV("MV_XFILCQ",,"0101")
    Local cTesCQ := GetMV("MV_XTESCQ",,"400/401")

    If cFilAnt $ cFilCQ
        If SD1->D1_TES $ cTesCQ
            lEnvCQ := .F.
        Endif 
    Endif

Return lEnvCQ
