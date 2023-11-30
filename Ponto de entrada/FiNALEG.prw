#INCLUDE "PROTHEUS.CH"
 
User Function FINALeg()
 
Local nReg := PARAMIXB[1] // Com valor: Abrir a telinha de legendas ### Sem valor: Retornar as regras
Local cAlias := PARAMIXB[2] // SE1 ou SE2
Local aRegras := {} // Regras do padr�o
Local aLegendas		:= {{"BR_VERDE", 	 "Titulo em aberto" },;	//1.  "Titulo em aberto"
						{"BR_AZUL", 	"Baixado parcialmente" },;	//2.  "Baixado parcialmente"
						{"BR_VERMELHO", "Titulo Baixado" },;	//3.  "Titulo Baixado"
						{"BR_PRETO", 	"Titulo em Bordero" },;	//4.  "Titulo em Bordero"
						{"BR_BRANCO", 	"Adiantamento com saldo" },;	//5.  "Adiantamento com saldo"
						{"BR_CINZA",	"Titulo baixado parcialmente e em bordero" },; //6. "Titulo baixado parcialmente e em bordero"
						{"BR_AMARELO",  "Adiantamento de Imp. Bx. com saldo"} } 	//7. "Adiantamento de Imp. Bx. com saldo"
Local aRet := {}
Local nI := 0
 
/*
    Sem Recno --> Retornar array com as regras para o Browse colocar as cores nas colunas.
    Com Recno --> Chamada quando acionado bot�o Legendas do browse -> Abrir telinha de Legendas (BrwLegenda)
*/
If nReg = Nil
 
    /*
        aRegras passado cont�m as regras do padr�o
        O array retornado dever� conter todas as regras, do padr�o e customizadas.
 
        Dicas:
        Lembrando que as regras de legenda s�o consideradas na ordem do array retornado.
        A Primeira regra atendida definir� a cor que ser� atribu�da.
        Aten��o para com a ordem das regras e com regras conflitantes.
        A �ltima regra do padr�o, caso n�o atenda a nenhuma condi��o anterior � a .T. -> BR_VERDE -> T�tulo em aberto
    */
    If cAlias = "SE1"
 
        /*
            Exemplo: adicionar uma regra de legenda "mais priorit�ria" que as do padr�o
        */
        aAdd(aRet,{"!Empty(E1_PORTADO) .AND. Empty(E1_NUMBOR)","BR_LARANJA"})
     
        /*
            Regras do padr�o para retorno
        */
        For nI := 1 To Len(aRegras)
            aAdd(aRet,{aRegras[nI][1],aRegras[nI][2]})
        Next nI
 
    Else // SE2
 
        /*
            Exemplo para retornar as mesmas regras do padr�o sem altera��o
        */
        aRet := aRegras
 
    Endif
 
 
Else // Abrir telinha de Legendas (BrwLegenda)
 
    If cAlias = "SE1"
 
        aAdd(aLegendas,{"BR_LARANJA","T�tulo em Portador"})
 
    Else // SE2
        /*
            Adicionar a cor e descri��o de legendas para SE2 aqui. Exemplo:
            Aadd(aLegendas, {"BR_AMARELO", "Titulo aguardando liberacao"}) //Titulo aguardando liberacao
        */
    Endif
 
    BrwLegenda(cCadastro, "Legenda", aLegendas)
 
Endif
 
Return aRet


User Function F040URET()
    Local aArea := GetArea()
    Local aRet  := {}
 
    aAdd(aRet,{"!Empty(E1_PORTADO) .AND. Empty(E1_NUMBOR)","BR_LARANJA"})
     
    RestArea(aArea)
Return aRet
