#Include "TOTVS.CH"
#Include "RESTFUL.CH"
#Include "tbiconn.ch"
#Include "topconn.ch"

WSRESTFUL CargaOms DESCRIPTION "Serviço REST para geracao de carga."
	WSMethod POST Description "Inclusão de carga" WSSYNTAX  "/CargaOms/"
END WSRESTFUL

WSMETHOD POST WSSERVICE CargaOms
//user function teste12234()
	Local aArea            := GetArea()
	Local oParseJSON       As Object
	Local cJson            := Self:GetContent()
	Local lRet             :=  .T.
	Local aCab             := {}
	Local aItem            := {}
	Local aLog             := {}
	Local cTexto           := ""
	Local nX               :=  0
	

	//cJson += '{ '
	//cJson += '   "Carga":{ '
	//cJson += '      "codigo_romaneio":"86", '
	//cJson += '      "peso_carga":"52.2", '
	//cJson += '      "codigo_motorista":"6048", '
	//cJson += '      "codigo_caminhao":"1", '
	//cJson += '      "data_hora_carga":"2023-11-27 11:48:10", '
	//cJson += '      "Clientes":[ '
	//cJson += '         { '
	//cJson += '            "codigo_cliente":"10808491", '
	//cJson += '            "codigo_protheus":"027771", '
	//cJson += '            "lote":"15" '
	//cJson += '         }, '
	//cJson += '         { '
	//cJson += '            "codigo_cliente":"06098758", '
	//cJson += '            "codigo_protheus":"958449", '
	//cJson += '            "lote":"15" '
	//cJson += '         } '
	//cJson += '      ] '
	//cJson += '   } '
	//cJson += '} '
	
    Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	Private lMsHelpAuto :=.T.
	Private lAtivAmb := .F.

	// Prepara o ambiente caso precise
	If Select("SX2") == 0
		RPCClearEnv()
		RpcSetType( 3 )
		RpcSetEnv( "01",'010101', , , "",,, , , ,  )
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif

	FwJsonDeserialize(cJson,@oParseJSON)
	DbSelectArea('DAK')
	aCab := {;
	    {"DAK_FILIAL", xFilial("DAK"),                               Nil},;
		{"DAK_COD"   , GETSX8NUM("DAK","DAK_COD"),                        Nil},; //Campo com inicializador padrão para pegar GESX8NUM
	    {"DAK_SEQCAR", '01'/*oParseJSON:carga[1]:sequencia_carga */,      Nil},;
		{"DAK_ROTEIR", '999999'/*oParseJSON:carga[1]:cod_rota   */ ,      Nil},;
		{"DAK_CAMINH", oParseJSON:CARGA:CODIGO_CAMINHAO          ,         Nil},;
		{"DAK_MOTORI", oParseJSON:CARGA:CODIGO_MOTORISTA        ,         Nil},;
		{"DAK_PESO"  , 0                                           ,         Nil},; // Calculado pelo OMSA200
	    {"DAK_DATA"  , CtoD(Substr(oParseJSON:CARGA:DATA_HORA_CARGA,1,9))     ,   	  Nil},;
		{"DAK_HORA"  , SubStr(oParseJSON:CARGA:DATA_HORA_CARGA,10,17)           ,   	  Nil},;
		{"DAK_JUNTOU","Manual" /*oParseJSON:carga[1]:juntou_carga     */, Nil},;
		{"DAK_ACECAR","2" /*oParseJSON:carga[1]:carga_ok         */,      Nil},;
		{"DAK_ACEVAS","2" /*oParseJSON:carga[1]:embalagens_ok    */,      Nil},;
		{"DAK_ACEFIN","2" /*oParseJSON:carga[1]:financeiro_ok    */,      Nil},;
		{"DAK_FLGUNI","2" /*oParseJSON:carga[1]:carga_inutilizada*/,      Nil},; //Campo com inicializador padrão  - 2
	    {"DAK_TRANSP", "999999"    ,                                      Nil},;
		{"DAK_AJUDA1", ""          ,						              Nil},;
		{"DAK_AJUDA2", ""          ,						              Nil},;
		{"DAK_AJUDA3", ""          ,						              Nil},;
		{"DAK_OK"    ,"0006"       ,						              Nil},;
		{"DAK_HRSTAR",  ""         ,						              Nil},;
		{"DAK_CDTPOP",  "1"        ,						              Nil};
		}

	// Informações do segundo pedido
	// Este array não tem o formato padrão de execuções automáticas
	DbSelectArea('SA1')
	DbSelectArea('SC5')
	For nX := 1 To Len(oParseJSON:CARGA:CLIENTES)
		SA1->(DbSetOrder(1))
		SC5->(DbSetOrder(1))
		SA1->(DbSeek(xFilial('SA1')+oParseJSON:CARGA:CLIENTES[nx]:CODIGO_CLIENTE))
		SC5->(DbSeek(xFilial('SC5')+oParseJSON:CARGA:CLIENTES[nx]:CODIGO_PROTHEUS))
		Aadd(aItem, {;
		aCab[2,2],; // 01 - Código da carga
		"999999" ,; // 02 - Código da Rota - 999999 (Genérica)
		"999999" ,; // 03 - Código da Zona - 999999 (Genérica)
		"999999" ,; // 04-  Código do Setor - 999999 (Genérico)
		SC5->C5_NUM   ,; // 05 - Código do Pedido Venda
		SA1->A1_COD   ,; // 06 - Código do Cliente
		SA1->A1_LOJA  ,; // 07 - Loja do Cliente
		SA1->A1_NOME  ,; // 08 - Nome do Cliente
		SA1->A1_BAIRRO,; // 09 - Bairro do Cliente
		SA1->A1_MUN   ,; // 10 - Município do Cliente
		SA1->A1_EST   ,; // 11 - Estado do Cliente
		SC5->C5_FILIAL,; // 12 - Filial do Pedido Venda
		SA1->A1_FILIAL,; // 13 - Filial do Cliente
		0   ,; // 14 - Peso Total dos Itens (Calculado pelo OMSA200)
		0     ,; // 15 - Volume Total dos Itens (Calculado pelo OMSA200)
		"08:00"/*oParseJSON:Carga[1]:Pedidos[nx]:hora_chegada*/      ,; // 16 - Hora Chegada
		"0001:00"/*oParseJSON:Carga[1]:Pedidos[nx]:time_service */      ,; // 17 - Time Service
		Nil           ,; // 18 - Não Usado
		SToD("")    ,; // 19 - Data Chegada
		dDatabase     ,; // 20 - Data Saída
		Nil           ,; // 21 - Não Usado
		Nil           ,; // 22 - Não Usado
		0/*oParseJSON:Carga[1]:Pedidos[nx]:valor_frete      */       ,; // 23 - Valor do Frete
		0/*oParseJSON:Carga[1]:Pedidos[nx]:frete_autonomo   */          ,; // 24 - Frete Autonomo
		0             ,; // 25 - Valor Total dos Itens (Calculado pelo OMSA200)
		0             ,; // 26 - Quantidade Total dos Itens (Calculado pelo OMSA200)
		Nil  ,;
		})
	Next
	SetFunName("OMSA200")

	MSExecAuto( { |x, y, z| OMSA200(x, y, z) }, aCab, aItem, 3 )

	If lMsErroAuto
		aLog      := GetAutoGRLog()
		cTexto := EncodeUTF8(Upper(FwCutOff(aLog[1],.T.)))
		SetRestFault(400,cTexto,.T.)
		lRet := .F.
	Else
		::SetResponse('{"Carga": "'+DAK->DAK_COD+'","Status": "cadastrado com sucesso!" }')
	EndIf
	RestArea(aArea)
	FreeObj(oParseJSON)
	If lAtivAmb
		RPCClearEnv()
	Endif
Return (lRet)
