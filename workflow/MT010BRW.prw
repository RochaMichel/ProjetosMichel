#Include "TOTVS.ch"
#Include 'Protheus.ch'

USER FUNCTION MT010BRW ()
 
    Local aLegMnu:={}
    aAdd(aLegMnu,{"Legenda","U_MT010LEG", 0, 3, 0, Nil })
 
RETURN aLegMnu
 
USER FUNCTION MT010LEG()
 
    Local aLegenda := {}
 
    aAdd(aLegenda,{'BR_VERMELHO' ,"Não Enviado"})
    aAdd(aLegenda,{'BR_VERDE' ,"Aprovado"})
    aAdd(aLegenda,{'BR_AZUL' ,"Aprovação Pendente"})
    aAdd(aLegenda,{'BR_LARANJA' ,"Reprovado"})
    BrwLegenda("Legendas","Legenda de acordo com o Status", aLegenda )
 
Return
