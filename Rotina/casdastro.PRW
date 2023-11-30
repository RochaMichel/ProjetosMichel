#include "totvs.ch"
#include "protheus.ch"
 
User Function Exemp001()


    Local aArea  	:= GetArea()
    Local cTitulo	:= "Importação Cadastro de Produtos" //Titulo da tela
    Local nOpcao 	:= 0 //Opções dos botões
    Local aButtons 	:= {} //Array de botões
    Local aSays    	:= {} //Array de texto
    Local aPerg		:= {} //Array de perguntas
    Private cArquivo:= "" //Variável de arquivo
    Private oProcess //Objeto que pr
    Private lRenomear:= .F. 
    Private lMsErroAuto := .F.
    RpcClearEnv()
    RpcSetType(3)
    RpcSetEnv("99","01","admin","","079")
 
    Pergunte(aPerg,.F.) //Manipula as perguntas
 
    AADD(aSays,OemToAnsi("Rotina para Importação de arquivo texto para tabela SB1")) //Caixa de texto
    AADD(aSays,"")
    AADD(aSays,OemToAnsi("Clique no botão PARAMETRO para informar os parametros que deverão ser considerados."))//Caixa de texto
    AADD(aSays,"")
    AADD(aSays,OemToAnsi("Após isso, clique no botão OK.")) //Caixa de texto
 
    AADD(aButtons, {01,.T.,{|o| nOpcao:= 1,o:oWnd:End()} } ) //Botão ok
    AADD(aButtons, {02,.T.,{|o| nOpcao:= 2,o:oWnd:End()} } ) //Botão cancelar
    AADD(aButtons, {05,.T.,{| | ajustaSx1(aPerg)  } } ) //Botão de parâmetros

    FormBatch( cTitulo, aSays, aButtons,,200,530 ) //Mensagem na tela com as opções(Tela inicial)
 
    if nOpcao = 1 //Se o botão ok for apertado
        cArquivo:= Alltrim(MV_PAR01) //Lê o arquivo ignorando espaços em branco
 
        if Empty(cArquivo) //Se o arquivo estiver vazio
            MsgStop("Informe o nome do arquivo!!!","Erro") //Mensagem de parada
            return //Retorno
        Endif //Fim do if
 
        oProcess := MsNewProcess():New( { || Importa() } , "Importação de registros " , "Aguarde..." , .F. ) //Barras na tela de processamento
        oProcess:Activate() //Abre a janela com as barras de processamento
        
    EndIf //Fim do if
 
    RestArea(aArea)
 
Return
//ok

Static Function Importa()
    //Local cArqProc   := cArquivo+".processado"
    Local cLinha     := ""
    Local lPrim      := .T.
    Local aCampos    := {}
    Local aDados     := {}
    Local aProduto   := {}
    Local nCont		 := 1
    Local nPosCod    := 0
    Local nPosDesc   := 0
    Local nPosTipo   := 0
    Local nPosUni    := 0
    local nPosArma   := 0
    local j := 0
    local i := 0
    Private aErro 	 := {}
    
 
    If !File(cArquivo) //Se FILE for diferente de cArquivo
        MsgStop("O arquivo " + cArquivo + " não foi encontrado. A importação será abortada!","[AEST904] - ATENCAO") //Mensagem de parada
        Return //Retorno
    EndIf //Fim do if
 
    FT_FUSE(cArquivo) //Disponibiliza as funções FT_F para uso
    oProcess:SetRegua1(FT_FLASTREC()) //Preenche a regua com a quantidade de registros encontrados
    FT_FGOTOP() //coloca o arquivo no topo
    While !FT_FEOF() //Enquanto FT diferente de fim do arquivo
        nCont++ //Incrementa um contando
        oProcess:IncRegua1('Validando Linha: ' + Alltrim(Str(nCont))) //Incrementa barra de processamento do RPTStatus
        
        cLinha := FT_FREADLN() 
        cLinha := ALLTRIM(cLinha)
    
        If lPrim //considerando que a primeira linha são os campos do cadastros, reservar numa variavel
            aCampos := Separa(cLinha,";",.T.)
            lPrim := .F.
        Else// gravar em outra variavel os registros
            AADD(aDados,Separa(cLinha,";",.T.))
        EndIf
    
        FT_FSKIP()
    EndDo
 
    FT_FUSE()        
    
    //utilizaremos a aScan para localizar a posição dos campos na variavel que armazenará o nome dos campos
    nPosCod    	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_COD" })
    nPosDesc   	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_DESC" })
    nPosTipo   	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_TIPO" })
    nPosUni    	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_UM" })
    nPosArma    := aScan(aCampos,{ |x| ALLTRIM(X) == "B1_LOCPAD"})

 
 
    oProcess:SetRegua1(len(aDados)) //guardar novamente a quantidade de registros
    
    For i:=1 to Len(aDados)
    
        oProcess:IncRegua1("Importando Produtos..."+aDados[i,nPosCod]+aDados[i,nPosDesc])
        
        aProduto := {}
    
        dbSelectArea("SB1")
        dbSetOrder(1)
        dbGoTop()
 
        //Neste exemplo iremos incluir registros, portanto iremos validar se o mesmo não existe na tabela de clientes
        If !dbSeek(xFilial("SB1")+aDados[i,nPosCod]+aDados[i,nPosDesc])
            oProcess:SetRegua2(len(aCampos))

            For j :=1 to Len(aCampos)

                oProcess:IncRegua2('Processando coluna: ' + ALLTRIM(aCampos[j]))
                //Iremos verificar também se o campo existe, para evitar erros durante a importação
                //É importante tambem, validar o tipo que o campo é, pois quando importa um arquivo texto, o conteudo também será texto
                
                dbSelectArea("SX3")
                dbSetOrder(2)
                dbGoTop()
                         
         
                        If dbSeek(ALLTRIM(aCampos[j]))                
                            If ALLTRIM(aCampos[j]) == "B1_COD"
                                AADD(aProduto,{ALLTRIM(aCampos[j]), aDados[i,j], NIL})
                                EndIF
                            If ALLTRIM(aCampos[j]) == "B1_DESC"
                                AADD(aProduto,{ALLTRIM(aCampos[j]),aDados[i,j], NIL})
                                EndIF                        
                            If ALLTRIM(aCampos[j]) == "B1_TIPO"
                                AADD(aProduto,{ALLTRIM(aCampos[j]), aDados[i,j], NIL})
                                EndIF
                            if ALLTRIM(aCampos[j]) == "B1_UM"
                                AADD(aProduto,{ALLTRIM(aCampos[j]), aDados[i,j], NIL})
                                EndIF
                            If ALLTRIM(aCampos[j]) == "B1_LOCPAD"
                                AADD(aProduto,{ALLTRIM(aCampos[j]), aDados[i,j], NIL})
                                EndIF
                        EndIf
                         
                       
                    
            Next j
            
            lMsErroAuto := .F.
            //Utilizar o MsExecAuto para incluir registros na tabela de clientes, utilizando a opção 3
            MSExecAuto({|x,y| mata010(x,y)},aProduto,3)
            //Caso encontre erro exibir na tela
                if lMsErroAuto
                MostraErro()
                MostraErro("\SYSTEM\LOG\",FUNNAME() + ".LOG")
                GravaErro(aDados[i,nPosCod],aDados[i,nPosDesc],aDados[i,nPosTipo],NIL)
                DisarmTransaction()
                EndIF


 
        Else //Caso o registro exista, gravar o log
        GravaErro(aDados[i,nPosCod],aDados[i,nPosDesc],aDados[i,nPosTipo],"O registro já está cadastrado!")
            
        EndIf 
        
    Next i 
    if lMsErroAuto == .F.
    FwAlertSuccess("produto(s) cadastrado(s)","Resultado")
    ENDIF
 
Return

Static Function ajustaSx1(aPerg) //Função resposável pelos parâmteros
     aAdd(aPerg,{6,"Aponte o arquivo:",Space(100),"","","",70,.F.,"Todos os arquivos (*.*) |*.*"}) //Pergunta do parâmetro
     ParamBox(aPerg, OemToAnsi("Seleção de arquivo")) //Tela customizada
Return
  