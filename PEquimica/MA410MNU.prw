#Include 'Protheus.ch'
#Include 'RwMake.ch'
#Include 'TopConn.ch'

User Function MA410MNU()
    Local aArea := GetArea()
     
    //Adicionando função de vincular
    aadd(aRotina,{"Atualizar Msg Nota","U_MSGNOTA", 0 , 4, 0 , Nil})
     
    RestArea(aArea)
Return
