#INCLUDE "PROTHEUS.CH"
#Include 'FWMVCDef.ch'
#include "topconn.ch"

//#Include "HBUTTON.CH"

/*/{Protheus.doc} User Function CFGF003
    (long_description)
    Extração de dados para cargas
    @type  Function
    @author user
    Edson Bella - MRC
    @since 14/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (CFGF003DW
    /*/
User Function CFGF003

Static cTitulo := "Logs de execuções DW"

//RpcSetEnv( "01", "010101",,,'FAT',,{"ZZ9"})

    Local aArea   := GetArea()
    Local oBrowse
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("ZZ9")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Legendas
    oBrowse:AddLegend( "ZZ9->ZZ9_STATUS == 0","YELLOW"  , "Não há dados para enviar" )
    oBrowse:AddLegend( "ZZ9->ZZ9_STATUS == 1","GREEN"   , "Gerado e Enviado com sucesso" )
    oBrowse:AddLegend( "ZZ9->ZZ9_STATUS == 2","RED"     , "Gerado e Erro no envio")

    //Ativa a Browse
    oBrowse:Activate()

//    oBrowse:SetMenuDef("CFGF003")

     
    RestArea(aArea)
Return Nil
 
/*/{Protheus.doc} MenuDef
    (long_description)
    @type  Static Function
    @author user
    Edson BElla - MRC
    @since 14/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function MenuDef()
    
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar'  ACTION 'VIEWDEF.CFGF003'    OPERATION 1 ACCESS 0 //OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE "Legenda"     ACTION 'u_zMVC01Leg()'      OPERATION 9 ACCESS 0
    ADD OPTION aRot TITLE "Parâmetros"  ACTION 'u_PARAMSX6()'       OPERATION 3 ACCESS 0
    ADD OPTION aRot TITLE "Nf Saída"    ACTION "u_PROCDW('S','1')"  OPERATION 3 ACCESS 0
    ADD OPTION aRot TITLE "Clientes"    ACTION "u_PROCDW('S','2')"  OPERATION 3 ACCESS 0
    ADD OPTION aRot TITLE "Produtos"    ACTION "u_PROCDW('S','3')"  OPERATION 3 ACCESS 0
    ADD OPTION aRot TITLE "Sol.Compras" ACTION "u_PROCDW('S','4')"  OPERATION 3 ACCESS 0
    ADD OPTION aRot TITLE "Obras"       ACTION "u_PROCDW('S','5')"  OPERATION 3 ACCESS 0
    ADD OPTION aRot TITLE "Vendedores"  ACTION "u_PROCDW('S','6')"  OPERATION 3 ACCESS 0
    ADD OPTION aRot TITLE "Nf Entrada"  ACTION "u_PROCDW('S','7')"  OPERATION 3 ACCESS 0
    ADD OPTION aRot TITLE "Estr.Prod."  ACTION "u_PROCDW('S','8')"  OPERATION 3 ACCESS 0
    ADD OPTION aRot TITLE "O.Produção"  ACTION "u_PROCDW('S','9')"  OPERATION 3 ACCESS 0
    ADD OPTION aRot TITLE "Ped.Vendas"  ACTION "u_PROCDW('S','10')" OPERATION 3 ACCESS 0
    ADD OPTION aRot TITLE "Cargas"      ACTION "u_PROCDW('S','11')" OPERATION 3 ACCESS 0
    ADD OPTION aRot TITLE "Ctas a pagar"ACTION "u_PROCDW('S','12')" OPERATION 3 ACCESS 0
    ADD OPTION aRot TITLE "Ped.Compras "ACTION "u_PROCDW('S','13')" OPERATION 3 ACCESS 0
    ADD OPTION aRot TITLE "Ctas a receb"ACTION "u_PROCDW('S','14')" OPERATION 3 ACCESS 0
    ADD OPTION aRot TITLE "Fornecedores"ACTION "u_PROCDW('S','15')" OPERATION 3 ACCESS 0
    ADD OPTION aRot TITLE "Mov.bancária"ACTION "u_PROCDW('S','16')" OPERATION 3 ACCESS 0

    //ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.CFGF003' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    //ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.CFGF003' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    //ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.CFGF003' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot
 
/*/{Protheus.doc} ModelDef
    (long_description)
    @type  Static Function
    @author user
    Edson BElla - MRC
    @since 14/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
     
    //Criação da estrutura de dados utilizada na interface
    Local oStZZ9 := FWFormStruct(1, "ZZ9")
     
    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("CFGF003",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMZZ9",/*cOwner*/,oStZZ9)
     
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'ZZ9_FILIAL','ZZ9_TABELA','ZZ9_DATA','ZZ9_HRIN'})
     
    //Adicionando descrição ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    //Setando a descrição do formulário
    oModel:GetModel("FORMZZ9"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel
 
/*/{Protheus.doc} ViewDef
    (long_description)
    @type  Static Function
    @author user
    Edson BElla - MRC
    @since 14/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ViewDef()
    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("CFGF003")
     
    //Criação da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStZZ9 := FWFormStruct(2, "ZZ9")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
     
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_ZZ9", oStZZ9, "FORMZZ9")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
    oView:CreateVerticalBox( 'CABESQ', 92, 'TELA' )
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_ZZ9', 'Logs DW' )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_ZZ9","CABESQ")
Return oView
 
/*/{Protheus.doc} zMVC01Leg
Função para mostrar a legenda das rotinas MVC com grupo de produtos
@author Atilio
@since 17/08/2015
@version 1.0
    @example
    u_zMVC01Leg()
/*/
 
User Function zMVC01Leg()
    Local aLegenda := {}
     
    //Monta as cores
    AADD(aLegenda,{"BR_AMARELO" ,   "Não há dados"  })
    AADD(aLegenda,{"BR_VERDE"   ,   "Sucesso"})
    AADD(aLegenda,{"BR_VERMELHO",   "Erro no Envio"})

    BrwLegenda("Status", "Status DW", aLegenda)
Return

/*/{Protheus.doc} User Function PROCDW
    (long_description
    @author user
    @since 03/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function PROCDW(_cUsuInter,_cDW)

Private _cOrig      := "MAN"
Private _cHtml      := ""
Private _nHandle
Private _cCampo
Private _cHrIn
Private _lNUser     := IsBlind() .Or. _cUsuInter == "N"  //se não tem interface com o usuário, ou se a rotina não foi chamada através do menu

AtuConou('1')

If _lNUser
    If IsBlind()
        _cOrig:='JOB'
    END
    RpcSetEnv( "01", "010101",,,'FAT',,{"ZZ9"})
End

Private _cEmailRet  := GetMv("EL_DWMAIL") // "edson.bella@mrconsultoria.com.br" //"rogerio.belarmino@grupoelizabeth.com.br" //
Private _cCtaEmail  := GetMv("EL_DWCEMAI")
Private cServer1    := GetMv("EL_DWSFTP") //"velisftp01.eliane.com:52798"
Private cUser1      := GetMv("EL_DWUSFTP") //'s126868'
Private cPasswd1    := GetMv("EL_DWPSFTP") //'VomCirrEdd6frult#'
Private cDest       := GetMv("EL_DWDEST") //"/home/homologacao/"
Private _cPasta     := GetMv("EL_DWPASTA") // "\temp\"

If _cDW=='T' .Or. _cDW=='1'
    _cHrIn      :=  TIME()
    NOTASSAIDA()
END
If _cDW=='T' .Or. _cDW=='2'    
    _cHrIn      :=  TIME()
    QCCCLIENTE()
END
If _cDW=='T' .Or. _cDW=='3'
    _cHrIn      :=  TIME()
    QEPITEM()
END
If _cDW=='T' .Or. _cDW=='4'
    _cHrIn      :=  TIME()
    QLOSOLCOMPRA()
END
If _cDW=='T' .Or. _cDW=='5'
    _cHrIn      :=  TIME()
    QVEOBRAS()
END
If _cDW=='T' .Or. _cDW=='6'
    _cHrIn      :=  TIME()
    QVEAGENTE()
END
If _cDW=='T' .Or. _cDW=='7'
    _cHrIn      :=  TIME()
    QLONFENTRA()
END
If _cDW=='T' .Or. _cDW=='8'
    _cHrIn      :=  TIME()
    QEPESTRUTU()
END
If _cDW=='T' .Or. _cDW=='9'
    _cHrIn      :=  TIME()
    QPFOF()
END
If _cDW=='T' .Or. _cDW=='10'
    _cHrIn      :=  TIME()
    QVEPEDIDOS()
END
If _cDW=='T' .Or. _cDW=='11'
    _cHrIn      :=  TIME()
    QVEPROGCARGA()
END
If _cDW=='T' .Or. _cDW=='12'
    _cHrIn      :=  TIME()
    QCPTITPAG()
END
If _cDW=='T' .Or. _cDW=='13'
    _cHrIn      :=  TIME()
    QLOPEDCOMPRA()
END
If _cDW=='T' .Or. _cDW=='14'
    _cHrIn      :=  TIME()
    QCRTITREC()
END
If _cDW=='T' .Or. _cDW=='15'
    _cHrIn      :=  TIME()
    QLOFORNECEDOR()
END
If _cDW=='T' .Or. _cDW=='16'
    _cHrIn      :=  TIME()
    QMOVTIT()
END

IF _lNUser
    RpcClearEnv()
else
    DBSELECTAREA( "ZZ9" )
END

RETURN

/*/{Protheus.doc} NOTASSAIDA
    Extração de dados de nota de saída
    @type  Static Function
    @author user
    Edson Bella Gonçalves - MRC
    @since 08/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)@see (links_or_references)
/*/

Static Function NOTASSAIDA()
    
Local   _aPergs     := {}
Local   _cFilialDe  := Space(6)
Local   _cFilialAte := Space(6)
Local   _dEmissaoD  := Ctod('  /  /    ')
Local   _dEmissaoA  := Ctod('  /  /    ')

Private _nNfdias    := GetMv("EL_DWNSDIA")
Private _nNfdiasR   := GetMv("EL_DWNSQD")
Private _cAlias     :=  GetNextAlias()
Private _nHandle
Private _cTabela    :=  "QFTNOTASSAIDA"
Private _cArquivo   :=  _cPasta+_cTabela

If _lNUser
    MV_PAR01    :=  ' '
    MV_PAR02    :=  'ZZZZZZ'
    MV_PAR03    :=  date()-_nNfdiasR //CtoD('01/10/2022') //
    MV_PAR04    :=  date() //CtoD('31/12/2022') //

else
    aAdd(_aPergs, {1, "Filial de",   _cFilialDe,    "", ".T.", "",".T.", 40,.T.})
    aAdd(_aPergs, {1, "Filial até",  _cFilialAte,   "", ".T.", "",".T.", 40,.F.})
    aAdd(_aPergs, {1, "Emissão de",  _dEmissaoD,    "", ".T.", "",".T.", 60,.T.})
    aAdd(_aPergs, {1, "Emissão até", _dEmissaoA,    "", ".T.", "",".T.", 60,.F.})

    If !ParamBox(_aPergs, "Informe os parâmetros")
        AtuConou('2')
        RETURN .t.
    End

END

MsAguarde({|| PNOTASSAIDA()}, "Aguarde...", "Processando Registros "+_cTabela+"...")

AtuConou('4')

Return

//
Static Function PNOTASSAIDA

AtuConou('3')

BeginSql Alias _cAlias

    SELECT 
    CT1_DESC01,
    CTT_DESC01,
    NNR_DESCRI,
    A1_NOME   ,
    a3v1.A3_NOME A3_NVEND1  ,
    a3v2.A3_NOME  A3_NVEND2 ,
    a3v3.A3_NOME A3_NVEND3  ,
    A4_NOME   ,
    B1_DESC   ,
    BM_DESC ,
    D2_FILIAL ,
    D2_ITEM   ,
    D2_COD    ,
    D2_SEGUM  ,
    D2_UM     ,
    D2_QUANT  ,
    D2_PRCVEN ,
    D2_TOTAL  ,
    D2_VALIPI ,
    D2_VALICM ,
    D2_TES    ,
    D2_CF     ,
    D2_DESC   ,
    D2_IPI    ,
    D2_VALCSL ,
    D2_PICM   ,
    D2_PESO   ,
    D2_CONTA  ,
    D2_OP     ,
    D2_PEDIDO ,
    D2_ITEMPV ,
    D2_CLIENTE,
    D2_LOJA   ,
    D2_LOCAL  ,
    D2_DOC    ,
    D2_SERIE  ,
    D2_GRUPO  ,
    D2_TP     ,
    D2_EMISSAO,
    //substr(D2_EMISSAO,7,2)||substr(D2_EMISSAO,5,2)||substr(D2_EMISSAO,1,4),
    D2_CUSTO1 ,
    D2_CUSTO2 ,
    D2_CUSTO3 ,
    D2_CUSTO4 ,
    D2_CUSTO5 ,
    D2_PRUNIT ,
    D2_QTSEGUM,
    D2_NUMSEQ ,
    D2_EST    ,
    D2_DESCON ,
    D2_TIPO   ,
    D2_NFORI  ,
    D2_SERIORI,
    D2_QTDEDEV,
    D2_VALDEV ,
    D2_ORIGLAN,
    D2_BRICMS ,
    D2_BASEORI,
    D2_BASEICM,
    D2_VALACRS,
    D2_IDENTB6,
    D2_CODISS ,
    D2_GRADE  ,
    D2_SEQCALC,
    D2_ICMSRET,
    D2_COMIS1 ,
    D2_COMIS2 ,
    D2_COMIS3 ,
    D2_COMIS4 ,
    D2_COMIS5 ,
    D2_LOTECTL,
    D2_NUMLOTE,
    D2_DTVALID,
    //substr(D2_DTVALID,7,2)||substr(D2_DTVALID,5,2)||substr(D2_DTVALID,1,4),
    D2_DESCZFR,
    D2_PDV    ,
    D2_NUMSERI,
    D2_DTLCTCT,
    //substr(D2_DTLCTCT,7,2)||substr(D2_DTLCTCT,5,2)||substr(D2_DTLCTCT,1,4),
    D2_CUSFF1 ,
    D2_CUSFF2 ,
    D2_CUSFF3 ,
    D2_CUSFF4 ,
    D2_CUSFF5 ,
    D2_CLASFIS,
    D2_BASIMP1,
    D2_REMITO ,
    D2_SERIREM,
    D2_BASIMP2,
    D2_BASIMP3,
    D2_ITEMREM,
    D2_BASIMP4,
    D2_BASIMP5,
    D2_BASIMP6,
    D2_VALIMP1,
    D2_VALIMP2,
    D2_VALIMP3,
    D2_VALIMP4,
    D2_VALIMP5,
    D2_VALIMP6,
    D2_ITEMORI,
    D2_CODFAB ,
    D2_LOJAFA ,
    D2_ALQIMP1,
    D2_ALQIMP2,
    D2_ALQIMP3,
    D2_ALQIMP4,
    D2_ALQIMP5,
    D2_ALQIMP6,
    D2_CCUSTO ,
    D2_ITEMCC ,
    D2_LOCALIZ,
    D2_ENVCNAB,
    //substr(D2_ENVCNAB,7,2)||substr(D2_ENVCNAB,5,2)||substr(D2_ENVCNAB,1,4),
    D2_ALIQINS,
    D2_ABSCINS,
    D2_PREEMB ,
    D2_ALIQISS,
    D2_BASEIPI,
    D2_BASEISS,
    D2_VALISS ,
    D2_SEGURO ,
    D2_VALFRE ,
    D2_TPDCENV,
    D2_DESPESA,
    D2_OK     ,
    D2_CLVL   ,
    D2_BASEINS,
    D2_ICMFRET,
    D2_SERVIC ,
    D2_STSERV ,
    D2_VALINS ,
    D2_PROJPMS,
    D2_EDTPMS ,
    D2_TASKPMS,
    D2_LICITA ,
    D2_VARPRUN,
    D2_FORMUL ,
    D2_TIPODOC,
    D2_VAC    ,
    D2_TIPOREM,
    D2_QTDEFAT,
    D2_QTDAFAT,
    D2_SEQUEN ,
    D2_POTENCI,
    D2_TPESTR ,
    D2_VALBRUT,
    D2_REGWMS ,
    D2_DTDIGIT,
    //substr(D2_DTDIGIT,7,2)||substr(D2_DTDIGIT,5,2)||substr(D2_DTDIGIT,1,4),
    D2_NUMCP  ,
    D2_CUSRP1 ,
    D2_CUSRP2 ,
    D2_CUSRP3 ,
    D2_CUSRP4 ,
    D2_CUSRP5 ,
    D2_CNATREC,
    D2_CFPS   ,
    D2_VALCF3 ,
    D2_BASECSL,
    D2_ALIQINA,
    D2_VALINA ,
    D2_VALIRRF,
    D2_BASETST,
    D2_ALIQCF3,
    D2_PRFDSUL,
    D2_CODROM ,
    D2_ABATISS,
    D2_PRUNDA ,
    D2_TRT    ,
    D2_BASEPS3,
    D2_ALIQTST,
    D2_ESTCRED,
    D2_ALIQPS3,
    D2_BASECOF,
    D2_VALTST ,
    D2_DESCZFP,
    D2_TNATREC,
    D2_DESCICM,
    D2_VALPS3 ,
    D2_BASEINA,
    D2_BASEPIS,
    D2_DESCZFC,
    D2_BASECF3,
    D2_ABATMAT,
    D2_GRUPONC,
    D2_VALCOF ,
    D2_VALFDS ,
    D2_UFERMS ,
    D2_BASEIRR,
    D2_ALQIRRF,
    D2_ORDSEP ,
    D2_DTFIMNT ,
    //substr(D2_DTFIMNT,7,2)||substr(D2_DTFIMNT,5,2)||substr(D2_DTFIMNT,1,4),
    D2_CODLAN ,
    D2_BASEFUN,
    D2_RATEIO ,
    D2_VALFUN ,
    D2_VLSENAR,
    D2_BSSENAR,
    D2_ALQPIS ,
    D2_CODLPRE,
    D2_ALSENAR,
    D2_ITLPRE ,
    D2_MARGEM ,
    D2_ALQCOF ,
    D2_CBASEAF,
    D2_VALPIS ,
    D2_ALIQFUN,
    D2_ALQCSL ,
    D2_VLINCMG,
    D2_PRINCMG,
    D2_VREINT ,
    D2_BSREIN ,
    D2_CRPRESC,
    D2_ALIQSOL,
    D2_ABATINS,
    D2_BASEFAB,
    D2_ALIQFAB,
    D2_VALFAB ,
    D2_BASEFAC,
    D2_ALIQFAC,
    D2_VALFAC ,
    D2_BASEFET,
    D2_ALIQFET,
    D2_VALFET ,
    D2_OKISS  ,
    D2_XQUALIF,
    D2_XTONAL ,
    D2_XBITOLA,
    D2_VCAT156,
    D2_VLIMPOR,
    D2_09CAT17,
    D2_16CAT17,
    D2_USERLGI,
    D2_USERLGA,
    D2_TOTIMP ,
    D2_IDCFC  ,
    D2_ESPECIE,
    D2_SITTRIB,
    D2_NFCUP  ,
    D2_ESTOQUE,
    D2_FCICOD ,
    D2_IDSF7  ,
    D2_IDSF4  ,
    D2_IDSBZ  ,
    D2_IDSB5  ,
    D2_IDSB1  ,
    D2_PRODFIN,
    D2_REVISAO,
    D2_DFABRIC,
    //substr(D2_DFABRIC,7,2)||substr(D2_DFABRIC,5,2)||substr(D2_DFABRIC,1,4),
    D2_TOTFED ,
    D2_TOTEST ,
    D2_TOTMUN ,
    D2_VALCPM ,
    D2_BASECPM,
    D2_ALQCPM ,
    D2_VALFMP ,
    D2_BASEFMP,
    D2_ALQFMP ,
    D2_BASEFMD,
    D2_ALQFMD ,
    D2_VALFMD ,
    D2_GRPCST ,
    D2_BASECPB,
    D2_VALCPB ,
    D2_ALIQCPB,
    D2_ICMSCOM,
    D2_DIFAL  ,
    D2_PDORI  ,
    D2_PDDES  ,
    D2_ALFCCMP,
    D2_ALIQCMP,
    D2_BASEDES,
    D2_VFCPDIF,
    D2_FTRICMS,
    D2_VRDICMS,
    D2_VALFUND,
    D2_BASFUND,
    D2_ALIFUND,
    D2_VALIMA ,
    D2_BASIMA ,
    D2_ALIIMA ,
    D2_VALFASE,
    D2_BASFASE,
    D2_ALIFASE,
    D2_MSIDENT,
    D2_MSEXP  ,
    D2_INDICE ,
    D2_CSOSN  ,
    D2_CP0101 ,
    D2_CP0201 ,
    D2_CP0301 ,
    D2_CP0401 ,
    D2_CP0501 ,
    D2_CP0601 ,
    D2_CP0701 ,
    D2_CP0801 ,
    D2_CP0901 ,
    D2_CP1001 ,
    D2_CP1101 ,
    D2_CP1201 ,
    D2_CP1301 ,
    D2_CP1401 ,
    D2_CP1501 ,
    D2_CP1601 ,
    D2_CP1701 ,
    D2_CP1801 ,
    D2_CP1901 ,
    D2_CP2001 ,
    D2_CP2101 ,
    D2_CP2201 ,
    D2_CP2301 ,
    D2_CP2401 ,
    D2_CP2501 ,
    D2_CP2601 ,
    D2_CP2701 ,
    D2_CP2801 ,
    D2_CP2901 ,
    D2_ALQFECP,
    D2_VALFECP,
    D2_VFECPST,
    D2_MSRESP ,
    D2_ALFCPST,
    D2_ICMSDIF,
    D2_VOPDIF ,
    D2_SERMAN ,
    D2_HREXPO ,
    D2_BASFEEF,
    D2_VALFEEF,
    D2_ALQFEEF,
    D2_ITEMGAR,
    D2_ORCGAR ,
    D2_ALMTERC,
    D2_SDOC   ,
    D2_SDOCREM,
    D2_SDOCMAN,
    D2_SDOCORI,
    D2_BASEPRO,
    D2_VALPRO ,
    D2_NRECAGR,
    D2_ALIQPRO,
    D2_TPREPAS,
    D2_BSFCCMP,
    D2_FCPAUX ,
    D2_BASFECP,
    D2_BSFCPST,
    D2_CTAREC ,
    D2_IDTRIB ,
    D2_DECQTD ,
    D2_PAFMD5 ,
    D2_DECVLU ,
    F2_DOC    ,
    F2_SERIE  ,
    F2_CLIENTE,
    F2_LOJA   ,
    F2_COND   ,
    F2_DUPL   ,
    F2_EMISSAO,
    //substr(F2_EMISSAO,7,2)||substr(F2_EMISSAO,5,2)||substr(F2_EMISSAO,1,4),
    F2_EST    ,
    F2_FRETE  ,
    F2_SEGURO ,
    F2_ICMFRET,
    F2_TIPOCLI,
    F2_VALBRUT,
    F2_VALICM ,
    F2_BASEICM,
    F2_VALIPI ,
    F2_BASEIPI,
    F2_VALMERC,
    F2_NFORI  ,
    F2_DESCONT,
    F2_SERIORI,
    F2_TIPO   ,
    F2_ESPECI1,
    F2_ESPECI2,
    F2_ESPECI3,
    F2_ESPECI4,
    F2_VOLUME1,
    F2_VOLUME2,
    F2_VOLUME3,
    F2_VOLUME4,
    F2_ICMSRET,
    F2_PLIQUI ,
    F2_PBRUTO ,
    F2_TRANSP ,
    F2_REDESP ,
    F2_VEND1  ,
    F2_VEND2  ,
    F2_VEND3  ,
    F2_VEND4  ,
    F2_VEND5  ,
    F2_OK     ,
    F2_FIMP   ,
    F2_DTLANC ,
    //substr(F2_DTLANC ,7,2)||substr(F2_DTLANC ,5,2)||substr(F2_DTLANC ,1,4) ,
    F2_DTREAJ ,
    //substr(F2_DTREAJ ,7,2)||substr(F2_DTREAJ ,5,2)||substr(F2_DTREAJ ,1,4) ,
    F2_REAJUST,
    F2_DTBASE0,
    //substr(F2_DTBASE0,7,2)||substr(F2_DTBASE0,5,2)||substr(F2_DTBASE0,1,4),
    F2_FATORB0,
    F2_DTBASE1,
    //substr(F2_DTBASE1,7,2)||substr(F2_DTBASE1,5,2)||substr(F2_DTBASE1,1,4),
    F2_FILIAL ,
    F2_FATORB1,
    F2_VARIAC ,
    F2_BASEISS,
    F2_CONTSOC,
    F2_VALISS ,
    F2_VALFAT ,
    F2_ICMAUTO,
    F2_DESPESA,
    F2_BRICMS ,
    F2_FRETAUT,
    F2_NEXTDOC,
    F2_PDV    ,
    F2_MAPA   ,
    F2_ECF    ,
    F2_PREFIXO,
    F2_BASIMP1,
    F2_BASIMP2,
    F2_BASIMP3,
    F2_BASIMP4,
    F2_BASIMP5,
    F2_BASIMP6,
    F2_VALIMP1,
    F2_VALIMP2,
    F2_VALIMP3,
    F2_VALIMP4,
    F2_VALIMP5,
    F2_VALIMP6,
    F2_ORDPAGO,
    F2_NEXTSER,
    F2_ESPECIE,
    F2_HORA   ,
    F2_NFCUPOM,
    F2_VALINSS,
    F2_MOEDA  ,
    F2_REGIAO ,
    F2_VALCSLL,
    F2_VALCOFI,
    F2_TXMOEDA,
    F2_CLEOK  ,
    F2_CHVCLE ,
    F2_IDCLE  ,
    F2_VALPIS ,
    F2_LOTE   ,
    F2_VALIRRF,
    F2_RECFAUT,
    F2_BASEINS,
    F2_PEDPEND,
    F2_CARGA  ,
    F2_SEQCAR ,
    F2_FORMUL ,
    F2_TIPODOC,
    F2_DESCCAB,
    F2_DTENTR ,
    //substr(F2_DTENTR ,7,2)||substr(F2_DTENTR ,5,2)||substr(F2_DTENTR ,1,4) ,
    F2_SEQENT ,
    F2_NFEACRS,
    F2_TIPOREM,
    F2_RECISS ,
    F2_VALCF3 ,
    F2_ICMSDIF,
    F2_HORNFE ,
    F2_CHVNFE ,
    F2_FLAGDEV,
    F2_VALACRS,
    F2_ORDSEP ,
    F2_BASECF3,
    F2_TPFRETE,
    F2_NFELETR,
    F2_NODIA  ,
    F2_BASEPS3,
    F2_EMINFE ,
    //substr(F2_EMINFE ,7,2)||substr(F2_EMINFE ,5,2)||substr(F2_EMINFE ,1,4) ,
    F2_ESTCRED,
    F2_VEICUL2,
    F2_VALPS3 ,
    F2_HAWB   ,
    F2_BASEIRR,
    F2_BASPIS ,
    F2_CREDNFE,
    F2_CODNFE ,
    F2_DIACTB ,
    F2_TIPORET,
    F2_CGCCLI ,
    F2_RECOPI ,
    F2_FILDEST,
    F2_VEICUL1,
    F2_VLSENAR,
    F2_BASCSLL,
    F2_NFSUBST,
    F2_CLIENT ,
    F2_VALTST ,
    F2_SERSUBS,
    F2_NTFECP ,
    F2_NFICMST,
    F2_BASETST,
    F2_REFTAXA,
    F2_BASCOFI,
    F2_VLR_FRT,
    F2_BASEFUN,
    F2_REFMOED,
    F2_VEICUL3,
    F2_PREFORI,
    F2_LOJENT ,
    F2_VREINT ,
    F2_BSREIN ,
    F2_VALFAB ,
    F2_VALFAC ,
    F2_VALFET ,
    F2_VALINA ,
    F2_BASEINA,
    F2_DESCZFR,
    F2_EVENFLG,
    F2_IDCCE  ,
    F2_FLAGRGS,
    F2_IDRGS  ,
    F2_CODRGS ,
    F2_DAUTNFE,
    //substr(F2_DAUTNFE,7,2)||substr(F2_DAUTNFE,5,2)||substr(F2_DAUTNFE,1,4),
    F2_HAUTNFE,
    F2_DTDIGIT,
    //substr(F2_DTDIGIT,7,2)||substr(F2_DTDIGIT,5,2)||substr(F2_DTDIGIT,1,4),
    F2_VALFDS ,
    F2_TPNFEXP,
    F2_USERLGI,
    F2_USERLGA,
    F2_XCPFMOT,
    F2_XPLACA ,
    F2_XMOTORI,
    F2_XUFPLAC,
    F2_FORMDES,
    F2_NUMORC ,
    F2_IDSA1  ,
    F2_IDSA2  ,
    F2_IDSED  ,
    F2_LOJADES,
    F2_FORDES ,
    F2_TOTIMP ,
    F2_TIPIMP ,
    F2_DTTXREF,
    //substr(F2_DTTXREF,7,2)||substr(F2_DTTXREF,5,2)||substr(F2_DTTXREF,1,4),
    F2_TXREF  ,
    F2_MENNOTA,
    F2_IDRECOP,
    F2_XLACRE ,
    F2_TOTFED ,
    F2_TOTEST ,
    F2_TOTMUN ,
    F2_VLCPM  ,
    F2_BASECPM,
    F2_VALFMP ,
    F2_BASEFMP,
    F2_VALFMD ,
    F2_SERMDF ,
    F2_NUMMDF ,
    F2_STATUS ,
    F2_XREFAT ,
    F2_XTRACCE,
    F2_GNRFECP,
    F2_GNRDIF ,
    F2_XBONMES,
    F2_XBONTRI,
    F2_XORIGEM,
    F2_DTESERV,
    //substr(F2_DTESERV,7,2)||substr(F2_DTESERV,5,2)||substr(F2_DTESERV,1,4),
    F2_VALFUND,
    F2_VALIMA ,
    F2_VALFASE,
    F2_MSEXP  ,
    F2_MSIDENT,
    F2_XDTCANH,
    //substr(F2_XDTCANH,7,2)||substr(F2_XDTCANH,5,2)||substr(F2_XDTCANH,1,4),
    F2_XGNRE  ,
    F2_XFRETE ,
    F2_XVLRFRT,
    F2_MSRESP ,
    F2_SERSAT ,
    F2_LTRAN  ,
    F2_TPCOMPL,
    F2_CNO    ,
    F2_SDOCSUB,
    F2_SDOCMAN,
    F2_SDOCORI,
    F2_SDOCMDF,
    F2_SDOCNXT,
    F2_SDOC   ,
    F2_BSFCCMP,
    F2_LOJARET,
    F2_BASFECP,
    F2_BSFCPST,
    F2_CLIRET ,
    F2_MUNPRES,
    F2_ESTPRES,
    F2_FRTCFOP,
    F2_PAFMD5 ,
    F2_CMUNOR ,
    F2_CMUNDE ,
    F2_IDNF   ,
    F2_UFDEST ,
    F2_UFORIG ,
    F2_CLIREM ,
    F2_LOJAREM,
    F2_CODA1U ,
    CASE WHEN F4_DUPLIC = 'S' THEN 'SIM' ELSE 'NAO'END f4_DUPLIC,
    CASE WHEN F4_ESTOQUE = 'S' THEN 'SIM' ELSE 'NAO'END F4_ESTOQUE,
    F4_FINALID TIPO_MOVI,
    X5_CFOP.X5_DESCRI NAT_OPERACAO,
    SAH_UM.ah_descpo AS AH_DESC_UM1,
    SAH_SEGUN.ah_descpo AS AH_DESC_UM2,
    M0_NOMECOM,
    e4_DESCRI

    FROM %table:SF2% F2

    inner join %table:SA1%  A1 on F2_CLIENTE = A1_COD and F2_LOJA = A1_LOJA and A1.%notdel%
    left join %table:SE4%   E4 on substr(F2_FILIAL,1,2) = trim(E4_filial) and F2_COND = E4_CODIGO and E4.%notdel%
    left join %table:SA4%   A4 on F2_TRANSP = A4_COD and A4.%notdel%
    left join sys_company   M0 on F2_FILIAL = M0_CODFIL and M0.%notdel%
    left join %table:SD2%   D2 on F2_FILIAL = D2_FILIAL and F2_DOC = D2_DOC and D2_SERIE = D2_SERIE and F2_CLIENTE = D2_CLIENTE and F2_LOJA = D2_LOJA and d2.%notdel%
    left join %table:SB1%   B1 ON D2_COD = B1_COD and b1.%notdel%
    left join %table:SA3%   A3v1 ON F2_FILIAL = a3v1.A3_FILIAL AND  F2_VEND1 = a3v1.A3_COD  and a3v1.%notdel%
    left join %table:SA3%   A3v2 ON F2_FILIAL = a3v2.A3_FILIAL AND  F2_VEND2 = a3v2.A3_COD  and a3v2.%notdel%
    left join %table:SA3%   A3v3 ON F2_FILIAL = a3v3.A3_FILIAL AND  F2_VEND3 = a3v3.A3_COD  and a3v3.%notdel%
    left join %table:SAH%   SAH_UM ON D2_UM = SAH_UM.AH_UNIMED  AND sah_UM.%notdel%
    left join %table:SAH%   SAH_SEGUN ON D2_SEGUM = SAH_SEGUN.AH_UNIMED  AND sah_segun.%notdel%
    LEFT JOIN %table:SF4%   SF4  ON D2_FILIAL = F4_FILIAL AND D2_TES = SF4.F4_CODIGO AND SF4.%notdel%
    LEFT JOIN %table:SX5%   X5_CFOP ON D2_CF = X5_CFOP.X5_CHAVE AND X5_TABELA = '13'
    LEFT JOIN %table:CT1%   CT1 ON D2_CONTA = CT1.CT1_CONTA AND CT1.%notdel%
    LEFT JOIN %table:NNR%   NNR ON TRIM(SUBSTR(D2_FILIAL,1,4)) = TRIM(NNR_FILIAL) AND D2_LOCAL = NNR_CODIGO AND NNR.%notdel%
    LEFT JOIN %table:SBM%   SBM ON D2_GRUPO = BM_GRUPO AND SBM.%notdel%
    LEFT JOIN %table:CTT%   CTT ON D2_FILIAL = CTT_FILIAL and d2_cCUSTO = ctt_custo AND CTT.%notdel%

    //WHERE F2_FILIAL = '020203' AND F2_EMISSAO BETWEEN '20221001' AND '20221231' AND F2.%notdel%
    //and rownum<101

    WHERE F2_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND F2_EMISSAO BETWEEN %Exp:DTOS(MV_PAR03)% AND %Exp:DTOS(MV_PAR04)% AND F2.%notdel%
    //and rownum<101

    ORDER BY F2_EMISSAO

EndSql

_cQuery:=GetLastQuery()

_aStru:=DBSTRUCT()

DBGOTOP()

IF!Eof()

    HTMLMAIL()

    _nDemiss:=0
    _cEmissD    :=F2_EMISSAO
    _cEmissA    :=F2_EMISSAO
    _cEmissAn   :=F2_EMISSAO

    Whil!Eof()

        If F2_EMISSAO<>_cEmissA
            _nDemiss    ++
            _cEmissAn   :=_cEmissA
            _cEmissA    :=F2_EMISSAO
        END

        IF _nDemiss==0 .Or. _nDemiss>_nNfdias

            If _nDemiss>_nNfdias

                _cNarquivo:=_cTabela+"_"+_cEmissD+"_"+_cEmissAn+".CSV"

                //ENVARQS(_cNarquivo,_cHtml,"DW - QFTNOTASSAIDA")
                ENVFARQS(_cNarquivo)

                _cEmissD:=F2_EMISSAO
                _cEmissA:=F2_EMISSAO

            END

            _nHandle    :=FCREATE(_cArquivo)

            If _nHandle = -1
                conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
            END
            
            _nDemiss    :=1
        End

        For x:=1 To Len(_aStru)
    
            If _aStru[x,2]=="C"

                MONTACAMPO()

                //FWrite(_nHandle, &(_aStru[x,1])+';')
                FWrite(_nHandle, _cCampo)
            Else
                FWrite(_nHandle, Str(&(_aStru[x,1])))
                FWrite(_nHandle, ';')
            END
        NEXT

        FWrite(_nHandle, CRLF)

        DBSKIP()
    END

    _cNarquivo:=_cTabela+"_"+_cEmissD+"_"+_cEmissA+".CSV"

    ENVFARQS(_cNarquivo)

else
    GERLOG(_cTabela,_cOrig,"",0)
END

RETURN

/*/{Protheus.doc} QCCCLIENTE
    Extração de dados de clientes
    @type  Static Function
    @author user
    Edson Bella Gonçalves - MRC
    @since 08/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function QCCCLIENTE

Private _cAlias     :=  GetNextAlias()
Private _nHandle
Private _cTabela    :=  "QCCCLIENTE"
Private _cArquivo   :=  _cPasta+_cTabela
Private _cCampo

If !_lNUser
    If MessageBox("Confirma início?","Geração de Clientes",4)==7
        AtuConou('2')
        Return
    END

    MsAguarde({|| PQCCCLIENTE()}, "Aguarde...", "Processando Registros "+_cTabela+"...")
else
    PQCCCLIENTE()
END

AtuConou('4')

Return

//
Static Function PQCCCLIENTE

AtuConou('3')

BeginSql Alias _cAlias

SELECT
    A1_FILIAL ,
    A1_COD    ,
    A1_LOJA   ,
    A1_PESSOA ,
    A1_CGC    ,
    A1_TIPO   ,
    A1_NOME   ,
    A1_NREDUZ ,
    A1_END    ,
    A1_BAIRRO ,
    A1_CEP    ,
    A1_EST    ,
    A1_ESTADO ,
    A1_COD_MUN,
    A1_MUN    ,
    A1_XZONA  ,
    A1_XDESZON,
    A1_DDD    ,
    A1_XSETOR ,
    A1_XDESSET,
    A1_COMPLEM,
    A1_NATUREZ,
    A1_PAIS   ,
    A1_CODPAIS,
    A1_IBGE   ,
    A1_TEL    ,
    A1_XTEL2  ,
    A1_XTEL3  ,
    A1_FAX    ,
    A1_DDI    ,
    A1_TELEX  ,
    A1_VEND   ,
    A1_XNVEND ,
    A1_COMIS  ,
    A1_TABELA ,
    A1_GRPVEN ,
    A1_REGIAO ,
    A1_TRANSP ,
    A1_COND   ,
    A1_DESC   ,
    A1_ENDCOB ,
    A1_BAIRROC,
    A1_CEPC   ,
    A1_MUNC   ,
    A1_ESTC   ,
    A1_ENDREC ,
    A1_ENDENT ,
    A1_CONTATO,
    A1_INSCR  ,
    A1_INSCRM ,
    A1_PFISICA,
    A1_CONTA  ,
    A1_MSBLQL ,
    A1_BCO1   ,
    A1_BCO2   ,
    A1_BCO3   ,
    A1_BCO4   ,
    A1_BCO5   ,
    A1_TPFRET ,
    A1_PRIOR  ,
    A1_RISCO  ,
    A1_LC     ,
    A1_XLCCIME,
    A1_VENCLC ,
    A1_CLASSE ,
    A1_LCFIN  ,
    A1_MOEDALC,
    A1_MSALDO ,
    A1_MCOMPRA,
    A1_METR   ,
    A1_PRICOM ,
    A1_ULTCOM ,
    A1_NROCOM ,
    A1_FORMVIS,
    A1_TEMVIS ,
    A1_ULTVIS ,
    A1_TMPVIS ,
    A1_TMPSTD ,
    A1_CLASVEN,
    A1_MENSAGE,
    A1_SALDUP ,
    A1_RECISS ,
    A1_CXPOSTA,
    A1_SALPEDL,
    A1_NROPAG ,
    A1_TRANSF ,
    A1_SUFRAMA,
    A1_ATR    ,
    A1_VACUM  ,
    A1_SALPED ,
    A1_TITPROT,
    A1_DTULTIT,
    A1_CHQDEVO,
    A1_MATR   ,
    A1_DTULCHQ,
    A1_MAIDUPL,
    A1_INCISS ,
    A1_SALDUPM,
    A1_PAGATR ,
    A1_ATIVIDA,
    A1_CARGO1 ,
    A1_CARGO2 ,
    A1_CARGO3 ,
    A1_ALIQIR ,
    A1_SUPER  ,
    A1_RTEC   ,
    A1_OBSERV ,
    A1_RG     ,
    A1_CALCSUF,
    A1_DTNASC ,
    A1_XDTCADA,
    A1_CODLOC ,
    A1_SALPEDB,
    A1_CLIFAT ,
    A1_GRPTRIB,
    A1_CEPE   ,
    A1_BAIRROE,
    A1_MUNE   ,
    A1_ESTE   ,
    A1_SATIV1 ,
    A1_SATIV2 ,
    A1_TPESSOA,
    A1_TPISSRS,
    A1_SATIV3 ,
    A1_CODAGE ,
    A1_CODMARC,
    A1_SATIV4 ,
    A1_SATIV5 ,
    A1_CODMUN ,
    A1_SATIV6 ,
    A1_SATIV7 ,
    A1_SATIV8 ,
    A1_OBS    ,
    A1_CODHIST,
    A1_COMAGE ,
    A1_TIPCLI ,
    A1_EMAIL  ,
    A1_DEST_1 ,
    A1_DEST_2 ,
    A1_HPAGE  ,
    A1_DEST_3 ,
    A1_CBO    ,
    A1_CNAE   ,
    A1_CONDPAG,
    A1_CLICNV ,
    A1_DIASPAG,
    A1_AGREG  ,
    A1_SITUA  ,
    A1_RECINSS,
    A1_RECCOFI,
    A1_RECCSLL,
    A1_RECPIS ,
    A1_TIPPER ,
    A1_SALFIN ,
    A1_CONTAB ,
    A1_BLEMAIL,
    A1_SALFINM,
    A1_B2B    ,
    A1_INSCRUR,
    A1_NUMRA  ,
    A1_LOCCONS,
    A1_SUBCOD ,
    A1_CODMUNE,
    A1_PERFIL ,
    A1_CBAIRRE,
    A1_CDRDES ,
    A1_FILDEB ,
    A1_PRF_COD,
    A1_CODFOR ,
    REGEXP_REPLACE (TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(A1_PRF_OBS,550,1))) ,'[[:cntrl:];]') A1_PRF_OBS,
    A1_ABICS  ,
    A1_SIMPLES,
    A1_IPWEB  ,
    A1_TIPOCLI,
    A1_VINCULO,
    A1_REGESIM,
    A1_DTINIV ,
    A1_PERCATM,
    A1_DTFIMV ,
    A1_HRTRANS,
    A1_UNIDVEN,
    A1_TIPPRFL,
    A1_PRF_VLD,
    A1_REGPB  ,
    A1_SIMPNAC,
    A1_USADDA ,
    A1_CODFID ,
    A1_ENDNOT ,
    A1_FRETISS,
    A1_CODSIAF,
    A1_CTARE  ,
    A1_INCULT ,
    A1_CEINSS ,
    A1_ORIGEM ,
    A1_ABATIMP,
    A1_FOMEZER,
    A1_TIMEKEE,
    A1_TDA    ,
    A1_FILTRF ,
    A1_RECFET ,
    A1_MINIRF ,
    A1_CONTRIB,
    A1_RECIRRF,
    A1_CRDMA  ,
    A1_PERFECP,
    A1_PRSTSER,
    A1_ALIFIXA,
    A1_RFACS  ,
    A1_RFABOV ,
    A1_TPDP   ,
    A1_OUTRMUN,
    A1_ENTID  ,
    A1_IRBAX  ,
    A1_INDRET ,
    A1_SIGLA  ,
    A1_TBENQUA,
    A1_TRIBFAV,
    A1_MUNSC  ,
    A1_IENCONT,
    A1_XTPCOM ,
    A1_XCANAL ,
    A1_XLISER ,
    A1_USERLGI,
    A1_XDTSER ,
    A1_USERLGA,
    A1_XINTER ,
    A1_XCONTA ,
    A1_XWFID  ,
    A1_XSTWF  ,
    A1_XPEFIN ,
    A1_XGERCOM,
    A1_XCOND1 ,
    A1_XCOND2 ,
    A1_XCOND3 ,
    A1_XTAB1  ,
    A1_XTAB2  ,
    A1_XTAB3  ,
    A1_XCNDSUG,
    A1_XLCSUGE,
    A1_XDESCE1,
    A1_XDESCE2,
    A1_XDESCE3,
    A1_XTPDSC1,
    A1_XTPDSC2,
    A1_XTPDSC3,
    A1_XVIGEN1,
    A1_XVIGEN2,
    A1_XVIGEN3,
    A1_XPROGRJ,
    A1_XPROCRJ,
    A1_IDHIST ,
    A1_MATFUN ,
    A1_TPNFSE ,
    A1_XVEND2 ,
    A1_TPJ    ,
    A1_NIF    ,
    A1_INOVAUT,
    REGEXP_REPLACE (TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(A1_XOBSLOG,550,1))) ,'[[:cntrl:];]') A1_XOBSLOG,
    A1_XTORPED,
    A1_XPARECE,
    A1_XTPCOMC,
    A1_XTRUCK ,
    A1_XEMPIL ,
    A1_XCDTIP ,
    A1_XCDPRC ,
    A1_XCDPRZ ,
    A1_XCLIPAI,
    A1_XLOJPAI,
    REGEXP_REPLACE (TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(A1_XOBSFIN,550,1))) ,'[[:cntrl:];]') A1_XOBSFIN,
    A1_XOCFIN ,
    A1_XBLQFIN,
    A1_XFLUXO ,
    A1_XPGANTE,
    A1_XADIANT,
    A1_KACESSO,
    A1_KNOTIFY,
    A1_KNOTIF2,
    A1_KNOTIF3,
    A1_RECFMD ,
    A1_XPRICOM,
    A1_XCARBAN,
    A1_XEMBALA,
    A1_XTPCAMI,
    A1_INCLTMG,
    A1_XBANK  ,
    A1_XOBSPED,
    A1_XPALETE,
    A1_XDTCAD ,
    A1_XFILORI,
    A1_XNVGER ,
    A1_XSTPORT,
    A1_XHRST1 ,
    A1_XDTST1 ,
    A1_XHRST2 ,
    A1_XDTST2 ,
    A1_XHRST3 ,
    A1_XDTST3 ,
    A1_RFUNDES,
    A1_RIMAMT ,
    A1_RFASEMT,
    A1_MSIDENT,
    A1_MSEXP  ,
    A1_XCLASSI,
    A1_XFATMED,
    //REGEXP_REPLACE (TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(A1_XPARCOM,250,1))) ,'[[:cntrl:];]') A1_XPARCOM,
    A1_XPARCOM,
    A1_XNRJCOM,
    A1_XMAILSE,
    A1_XSOCIO1,
    A1_XSC1CPF,
    A1_XSC1CRG,
    A1_XSOCIO2,
    A1_XSC2CPF,
    A1_XSC2CRG,
    A1_XSOCIO3,
    A1_XSC3CPF,
    A1_XSC3CRG,
    A1_XSOCIO4,
    A1_XSC4CPF,
    A1_XSC4CRG,
    A1_XSOCIO5,
    A1_XSC5CPF,
    A1_XSC5CRG,
    A1_XREGTRB,
    A1_XTEMFIL,
    A1_XFILLOC,
    A1_XPREDPR,
    A1_XPRODFA,
    A1_XCOMOBR,
    A1_XCIMENT,
    A1_XCAPSOC,
    A1_XBANCO1,
    A1_XAGREF1,
    A1_XRFTEL1,
    A1_XBANCO2,
    A1_XAGREF2,
    A1_XRFTEL2,
    A1_XRFCOM1,
    A1_XRFCOM2,
    A1_XRFCOM3,
    REGEXP_REPLACE (TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(A1_XMENNOT,550,1))) ,'[[:cntrl:];]') A1_XMENNOT,
    A1_MSRESP ,
    A1_DSCREG ,
    A1_HRCAD  ,
    A1_TPREG  ,
    A1_RESERVE,
    A1_IMGUMOV,
    A1_RESFAT ,
    A1_IDESTN ,
    A1_NVESTN ,
    A1_ORIGCT ,
    A1_ENTORI ,
    A1_TPCAMP ,
    A1_CHVCAM ,
    A1_HREXPO ,
    A1_CODTER ,
    A1_CODMEMB,
    A1_TPMEMB ,
    A1_ISSRSLC,
    A1_COMPENT,
    A1_XADMFRE,
    A1_DTCAD  ,
    A1_CLIPRI ,
    A1_LOJPRI ,
    A1_CODSEG,
    ACY_DESCRI,
    REGEXP_REPLACE (TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(AI0_XPAREC,550,1))) ,'[[:cntrl:];]') AI0_XPAREC,
    REGEXP_REPLACE (TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(AI0_XINFCL,550,1))) ,'[[:cntrl:];]') AI0_XINFCL,
    REGEXP_REPLACE (TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(AI0_XPARME,550,1))) ,'[[:cntrl:];]') AI0_XPARME,
    CCH_PAIS  ,
    A3_NOME   ,
    A4_NOME   ,
    E4_DESCRI ,
    ED_DESCRIC,
    YA_DESCR

    FROM %table:SA1% A1
    LEFT JOIN %table:SYA% SYA ON A1_PAIS = YA_CODGI AND sya.%notdel%
    LEFT JOIN %table:CCH% CCH ON A1_CODPAIS = CCH_CODIGO AND cch.%notdel%
    LEFT JOIN %table:ACY% ACY ON A1_GRPVEN = ACY_GRPVEN AND ACY.%notdel%
    LEFT JOIN %table:SED% SED ON A1_NATUREZ = ED_CODIGO AND sed.%notdel%
    LEFT JOIN %table:SA3% SA3 ON A1_VEND = A3_COD AND SA3.%notdel% and a3_filial = '020201'
    LEFT JOIN %table:SA4% SA4 ON A1_TRANSP = A4_NOME and SA4.%notdel%
    LEFT JOIN %table:SE4% SE4 ON A1_COND = E4_CODIGO AND se4.%notdel% AND E4_FILIAL = '02'
    LEFT JOIN %table:AI0% AI0 ON A1_COD = AI0_CODCLI AND A1_LOJA = ai0.ai0_loja AND ai0.%notdel%

    WHERE A1.%notdel%
    //and a1_Cod='041090'
    //and rownum<101

EndSql

_cQuery:=GetLastQuery()

_aStru:=DBSTRUCT()

DBGOTOP()

_nHandle    :=FCREATE(_cArquivo)

IF!EOF()

    HTMLMAIL()

    Whil!Eof()

        For x:=1 To Len(_aStru)
            If _aStru[x,2]=="C"

                MONTACAMPO()

                //FWrite(_nHandle, &(_aStru[x,1])+';')
                FWrite(_nHandle, _cCampo)
            Else
                FWrite(_nHandle, ';')
            END
        NEXT

        FWrite(_nHandle, CRLF)

        DBSKIP()
    END

    //_cNarquivo:=_cArquivo+"_"+Dtos(dDatabase)+".CSV"
    //ENVARQS(_cNarquivo,_cHtml,"DW - QCCCLIENTE")

    _cNarquivo:=_cTabela+"_"+Dtos(dDatabase)+".CSV"

    ENVFARQS(_cNarquivo)

else
    GERLOG(_cTabela,_cOrig,"",0)
END

RETURN

/*/{Protheus.doc} QEPITEM
    Extração de dados de produtos
    @type  Static Function
    @author user
    Edson Bella Gonçalves - MRC
    @since 10/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function QEPITEM
    
Private _nRegsIt      := GetMv("EL_DWRGSIT")
Private _cAlias     :=  GetNextAlias()
Private _nHandle
Private _cTabela    :=  "QEPITEM"
Private _cArquivo   :=  _cPasta+_cTabela
Private _cCampo

If !_lNUser
    If MessageBox("Confirma início?","Geração de Produtos",4)==7
        AtuConou('2')
        Return
    END

    MsAguarde({|| PQEPITEM()}, "Aguarde...", "Processando Registros "+_cTabela+"...")
else
    PQEPITEM()
END

AtuConou('4')

Return

//
Static Function PQEPITEM

Local _nReg :=1
Local _nSeq :=1

AtuConou('3')

BeginSql Alias _cAlias

SELECT
    B1_FILIAL ,
    B1_TIPO   ,
    B1_GRUPO  ,
    B1_XSBGRP ,
    B1_CODITE ,
    B1_XFAMILI,
    B1_XCODRED,
    B1_COD    ,
    B1_XDESC  ,
    B1_XDIMEN ,
    B1_POSIPI ,
    B1_ESPECIE,
    B1_EX_NCM ,
    B1_EX_NBM ,
    B1_XREF1  ,
    B1_DESC   ,
    B1_XDESCOM,
    B1_XLINHA ,
    B1_UM     ,
    B1_LOCPAD ,
    B1_BITMAP ,
    B1_SEGUM  ,
    B1_PICM   ,
    B1_IPI    ,
    B1_ALIQISS,
    B1_CODISS ,
    B1_CONV   ,
    B1_TIPCONV,
    B1_XESTOQ ,
    B1_TE     ,
    B1_TS     ,
    B1_PICMRET,
    B1_UCOM   ,
    B1_PICMENT,
    B1_IMPZFRC,
    B1_ESTFOR ,
    B1_ALTER  ,
    B1_QE     ,
    B1_PRV1   ,
    B1_EMIN   ,
    B1_CUSTD  ,
    B1_UCALSTD,
    B1_UPRC   ,
    B1_MCUSTD ,
    B1_PESO   ,
    B1_PESBRU ,
    B1_ESTSEG ,
    B1_FORPRZ ,
    B1_LOJPROC,
    B1_PE     ,
    B1_TIPE   ,
    B1_LE     ,
    B1_LM     ,
    B1_PROC   ,
    B1_CONTA  ,
    B1_UREV   ,
    B1_DATREF ,
    B1_TOLER  ,
    B1_CC     ,
    B1_ITEMCC ,
    B1_DTREFP1,
    B1_FAMILIA,
    B1_QB     ,
    B1_APROPRI,
    B1_TIPODEC,
    B1_ORIGEM ,
    B1_CLASFIS,
    B1_CONINI ,
    B1_CONTSOC,
    B1_FANTASM,
    B1_CODBAR ,
    B1_GRADE  ,
    B1_FORMLOT,
    B1_FPCOD  ,
    B1_RASTRO ,
    B1_XCODBAR,
    B1_CONTRAT,
    B1_DESC_P ,
    B1_DESC_I ,
    B1_DESC_GI,
    B1_FORAEST,
    B1_COMIS  ,
    B1_ANUENTE,
    B1_OPC    ,
    B1_CODOBS ,
    B1_MONO   ,
    B1_PERINV ,
    B1_FABRIC ,
    B1_GRTRIB ,
    B1_MRP    ,
    B1_NOTAMIN,
    B1_PRVALID,
    B1_PRODPAI,
    B1_NUMCOP ,
    B1_IRRF   ,
    B1_DESPIMP,
    B1_LOCALIZ,
    B1_OPERPAD,
    B1_VLREFUS,
    B1_IMPORT ,
    B1_SITPROD,
    B1_MODELO ,
    B1_SETOR  ,
    B1_BALANCA,
    B1_TECLA  ,
    B1_TIPOCQ ,
    B1_SOLICIT,
    B1_DESBSE3,
    B1_NALNCCA,
    B1_NALSH  ,
    B1_BASE3  ,
    B1_GRUPCOM,
    B1_AGREGCU,
    B1_QUADPRO,
    B1_NUMCQPR,
    B1_CONTCQP,
    B1_DATASUB,
    B1_REVATU ,
    B1_INSS   ,
    B1_CODEMB ,
    B1_ESPECIF,
    B1_MAT_PRI,
    B1_REDINSS,
    B1_REDIRRF,
    B1_ALADI  ,
    B1_TAB_IPI,
    B1_GRUDES ,
    B1_REDPIS ,
    B1_QTDSER ,
    B1_REDCOF ,
    B1_PCSLL  ,
    B1_PCOFINS,
    B1_PPIS   ,
    B1_MTBF   ,
    B1_MTTR   ,
    B1_FLAGSUG,
    B1_CLASSVE,
    B1_MIDIA  ,
    B1_VLR_IPI,
    B1_QTMIDIA,
    B1_ENVOBR ,
    B1_SERIE  ,
    B1_FAIXAS ,
    B1_NROPAG ,
    B1_ISBN   ,
    B1_TITORIG,
    B1_LINGUA ,
    B1_CORPRI ,
    B1_CORSEC ,
    B1_NICONE ,
    B1_ATRIB1 ,
    B1_ATRIB2 ,
    B1_ATRIB3 ,
    B1_REGSEQ ,
    B1_EDICAO ,
    B1_OBSISBN,
    B1_CLVL   ,
    B1_ATIVO  ,
    B1_REQUIS ,
    B1_SELO   ,
    B1_LOTVEN ,
    B1_OK     ,
    B1_USAFEFO,
    B1_EMAX   ,
    B1_TIPCAR ,
    B1_FRACPER,
    B1_CNATREC,
    B1_TNATREC,
    B1_CLASSE ,
    B1_INT_ICM,
    B1_VLR_ICM,
    B1_VLRSELO,
    B1_CODNOR ,
    B1_CPOTENC,
    B1_DCR    ,
    B1_DIFCNAE,
    B1_POTENCI,
    B1_QTDACUM,
    B1_MSBLQL ,
    B1_QTDINIC,
    B1_DCI    ,
    B1_SITTRIB,
    B1_IAT    ,
    B1_IPPT   ,
    B1_VLR_PIS,
    B1_PMACNUT,
    B1_UMOEC  ,
    B1_QBP    ,
    B1_CCCUSTO,
    B1_ESCRIPI,
    B1_COEFDCR,
    B1_TALLA  ,
    B1_CODPROC,
    B1_CODQAD ,
    B1_FECP   ,
    B1_PARCEI ,
    B1_GDODIF ,
    B1_VLCIF  ,
    B1_TPPROD ,
    B1_DTCORTE,
    B1_DCRII  ,
    B1_DCRE   ,
    B1_REFBAS ,
    B1_GCCUSTO,
    B1_CRICMS ,
    B1_DTFIMNT,
    B1_FRETISS,
    B1_PMICNUT,
    B1_MARKUP ,
    B1_GRPNATR,
    B1_FUSTF  ,
    B1_PRODSBP,
    B1_PIS    ,
    B1_VALEPRE,
    B1_LOTESBP,
    B1_PRINCMG,
    B1_CARGAE ,
    B1_TIPOBN ,
    B1_UVLRC  ,
    B1_PRODREC,
    B1_CALCFET,
    B1_ALFUMAC,
    B1_RICM65 ,
    B1_CODLAN ,
    B1_REGRISS,
    B1_CSLL   ,
    B1_PR43080,
    B1_IVAAJU ,
    B1_COFINS ,
    B1_DESBSE2,
    B1_FETHAB ,
    B1_SELOEN ,
    B1_PRN944I,
    B1_ADMIN  ,
    B1_BASE2  ,
    B1_CRDEST ,
    B1_PRFDSUL,
    B1_RETOPER,
    B1_GARANT ,
    B1_PAUTFET,
    B1_TIPVEC ,
    B1_VLR_COF,
    B1_BASE   ,
    B1_PERGART,
    B1_ESTRORI,
    B1_COLOR  ,
    B1_CNAE   ,
    B1_CRICMST,
    B1_ALFECOP,
    B1_ALFECST,
    B1_FECOP  ,
    B1_VIGENC ,
    B1_CRDPRES,
    B1_PRDORI ,
    B1_AFETHAB,
    B1_AFACS  ,
    B1_AFABOV ,
    B1_TFETHAB,
    B1_REGESIM,
    B1_AJUDIF ,
    B1_ALFECRN,
    B1_TPREG  ,
    B1_VEREAN ,
    B1_RSATIVO,
    B1_TRIBMUN,
    B1_CFEM   ,
    B1_CFEMS  ,
    B1_CFEMA  ,
    B1_TPDP   ,
    B1_FECPBA ,
    B1_MEPLES ,
    B1_CODANT ,
    B1_RPRODEP,
    B1_CHASSI ,
    B1_XPALETE,
    B1_XFORLIN,
    B1_XFILFAB,
    B1_IMPNCM ,
    B1_IDHIST ,
    B1_MSEXP  ,
    B1_PAFMD5 ,
    B1_USERLGI,
    B1_USERLGA,
    B1_PORCPRL,
    B1_AFAMAD ,
    B1_XMARCA ,
    B1_GRPTI  ,
    B1_GRPCST ,
    B1_CEST   ,
    B1_MSIDENT,
    B1_XCOMPRI,
    B1_XLARGUR,
    B1_XALTURA,
    B1_XPESBRU,
    B1_XPESLIQ,
    B1_XCODOUT,
    B1_AFUNDES,
    B1_AIMAMT ,
    B1_AFASEMT,
    B1_XCUSTP ,
    B1_MSRESP ,
    B1_TERUM  ,
    B1_MSFIL  ,
    B1_HREXPO ,
    B1_INTEG  ,
    B1_CODGTIN,
    B1_REVIS  ,
    B1_XACABAM,
    B1_XDFAMIL,
    B1_XDGRUPO,
    B1_XAPLICA,
    B1_XDSUBGR,
    B1_XTEXTUR,
    B1_APOPRO ,
    B1_XFOCO  ,
    B1_XAGRUP ,
    B1_XMAILSO,
    B5_FILIAL ,
    B5_COD    ,
    B5_PRV2   ,
    B5_PRV3   ,
    B5_PRV4   ,
    B5_PRV5   ,
    B5_PRV6   ,
    B5_PRV7   ,
    B5_CEME   ,
    B5_CODCLI ,
    B5_CERT   ,
    B5_COMPR  ,
    B5_DES    ,
    B5_EMB1   ,
    B5_EMB2   ,
    B5_ESPESS ,
    B5_ESTMAT ,
    B5_LARG   ,
    B5_QE1    ,
    B5_QE2    ,
    B5_QUAL   ,
    B5_CONVDIP,
    B5_UMDIPI ,
    B5_DTREFP2,
    B5_CARPER ,
    B5_IDADEM ,
    B5_DTREFP3,
    B5_DTREFP4,
    B5_DTREFP5,
    B5_DTREFP6,
    B5_DTREFP7,
    B5_COMPRLC,
    B5_LARGLC ,
    B5_ALTURLC,
    B5_FATARMA,
    B5_EMPMAX ,
    B5_ROTACAO,
    B5_CODCAI ,
    B5_LOCALIZ,
    B5_CODZON ,
    B5_UMIND  ,
    B5_LVLEMB ,
    B5_LPSEMB ,
    B5_PERCUB ,
    B5_IMPGRUP,
    B5_BENDL  ,
    B5_PINSUMO,
    B5_PORTMS ,
    B5_NPULMAO,
    B5_PRODDNF,
    B5_INSUMO ,
    B5_VOLRECI,
    B5_CODISRF,
    B5_USOITE ,
    B5_LOCALI2,
    B5_CONCENT,
    B5_DENSID ,
    B5_FTIN   ,
    B5_FTIF   ,
    B5_PROPOR1,
    B5_PROPOR2,
    B5_CRDEST1,
    B5_CRDEST2,
    B5_CALORIA,
    B5_PESO   ,
    B5_TOTGOR ,
    B5_TOTGORS,
    B5_TOTGORT,
    REGEXP_REPLACE (TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(B5_DESCNFE,550,1))) ,'[[:cntrl:];]') B5_DESCNFE,
    B5_COR    ,
    B5_ALTURA ,
    B5_MODELO ,
    B5_ESPECIE,
    B5_QUALIDA,
    B5_ONU    ,
    B5_ITEM   ,
    B5_CODTP  ,
    B5_CMPEXTR,
    B5_EAN141 ,
    B5_EAN142 ,
    B5_EAN143 ,
    B5_EAN144 ,
    B5_EAN145 ,
    B5_EAN146 ,
    B5_EAN147 ,
    B5_EAN148 ,
    B5_TIPUNIT,
    B5_QTDVAR ,
    B5_IMPETI ,
    B5_VLDOPER,
    B5_VLDREQ ,
    B5_DTINV  ,
    B5_PERIOT ,
    B5_NSERIE ,
    B5_QEI    ,
    B5_QEL    ,
    B5_CDDMDBA,
    B5_SITDIEF,
    B5_CODTRAM,
    B5_CODSERC,
    B5_ISEN   ,
    B5_TABINC ,
    B5_CODGRU ,
    B5_MARCA  ,
    B5_CODGNRE,
    B5_NRECAGR,
    B5_INGATV ,
    B5_FORCAO ,
    B5_CLASSE ,
    B5_CONCEN ,
    B5_PROJDES,
    B5_REGMAPA,
    B5_EMBAGRO,
    REGEXP_REPLACE (TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(B5_DESCSER,550,1))) ,'[[:cntrl:];]') B5_DESCSER,
    B5_CTDACON,
    B5_PROTCON,
    B5_INSPAT ,
    B5_CODATIV,
    B5_VERIND ,
    B5_INDPETR,
    B5_REDALIQ,
    B5_FCIPRV ,
    B5_DIASHL ,
    B5_DIASHF ,
    B5_REVPROD,
    B5_TPSERV ,
    B5_SEMENTE,
    B5_CULTRA ,
    B5_CTVAR  ,
    B5_CATEG  ,
    B5_PENE   ,
    B5_FORMMRP,
    B5_PRZCQ  ,
    B5_IDHIST ,
    B5_AMMULTO,
    B5_AMMULTS,
    B5_ZFMULTO,
    B5_ZFMULTS,
    B5_AGLUMRP,
    B5_BLQINVD,
    B5_VERSAO ,
    B5_BLQINVA,
    B5_DIASES ,
    B5_MONTA  ,
    B5_GRPIVA ,
    B5_FPRZCQ ,
    B5_ALTTRIB,
    B5_CATMAT ,
    B5_PROTOTI,
    B5_AM4PORC,
    B5_WMSEMB ,
    B5_ZF4PORC,
    B5_ANOBEN ,
    B5_NATBEN ,
    B5_NUMBEN ,
    B5_DTDECRE,
    B5_NATALBE,
    B5_NUMBEAL,
    B5_DTDECAL,
    B5_TBEBIDA,
    B5_SERVENT,
    B5_EMBLG  ,
    B5_VOL    ,
    B5_ENDENT ,
    B5_SERVINT,
    B5_VLRCID ,
    B5_SERVSAI,
    B5_SERVEMB,
    B5_ENDSAI ,
    B5_SERVREQ,
    B5_ENDREQ ,
    B5_SERVDEV,
    B5_ENDDEV ,
    REGEXP_REPLACE (TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(B5_ECDESCR,550,1))) ,'[[:cntrl:];]') B5_ECDESCR,
    B5_ECENQUA,
    B5_ECPESOE,
    B5_ECALTEM,
    B5_INTDI  ,
    B5_INSSPAT,
    B5_COMPEND,
    B5_FUNCEP ,
    B5_TPESOC ,
    B5_MARGPRE,
    B5_ISDSHIP,
    B5_VLZERO ,
    B5_ECDESF ,
    B5_ENDECD ,
    B5_ENDSCD ,
    B5_SERECD ,
    B5_SERSCD ,
    B5_SERVTDV,
    B5_INDCPRB,
    B5_ARREQTD,
    B5_ISIDUNI,
    B5_ECEAN1 ,
    B5_ECSUBT ,
    B5_ECSEQ  ,
    B5_CDFATD ,
    B5_ECLARGE,
    B5_NBS    ,
    REGEXP_REPLACE (TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(B5_ECINDIC,550,1))) ,'[[:cntrl:];]') B5_ECINDIC,
    B5_GSLE   ,
    B5_GSMC   ,
    B5_GSMI   ,
    B5_CTRWMS ,
    B5_TPISERV,
    B5_FORSER ,
    B5_TIPO   ,
    B5_DEC7174,
    B5_ECSEQ2 ,
    B5_ENVMKT ,
    B5_LEADTR ,
    REGEXP_REPLACE (TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(B5_ECCARAC,550,1))) ,'[[:cntrl:];]') B5_ECCARAC,
    B5_ECFLAG ,
    B5_ECTITU ,
    B5_UMPRC  ,
    B5_ECCUBAG,
    REGEXP_REPLACE (TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(B5_ECAPRES,550,1))) ,'[[:cntrl:];]') B5_ECAPRES,
    REGEXP_REPLACE (TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(B5_ECBENFI,550,1))) ,'[[:cntrl:];]') B5_ECBENFI,
    B5_ECDTEX2,
    B5_ECIMGFI,
    B5_ECPCHAV,
    B5_ECDTLAN,
    B5_ECDTEX ,
    B5_CLAUBA ,
    B5_TRATAM ,
    B5_ECPROFU,
    B5_TPAPUR ,
    B5_CODFAM ,
    B5_MARPEC ,
    B5_CODLIN ,
    B5_ECCOMP ,
    B5_ECLARGU,
    B5_2CODBAR,
    B5_TAKEUP ,
    B5_TPCOMMO,
    B5_XDIMFAB,
    B5_XJUNTA ,
    B5_XACALAT,
    B5_XCORREJ,
    B5_XFACES ,
    B5_XSUPEFI,
    B5_XESPESS,
    B5_XPCCAIX,
    B5_XGRPABS,
    B5_XGRAGUA,
    B5_XAPLICA,
    B5_XTIPOPR,
    B5_XCOF   ,
    B5_XCLSUSO,
    B5_XVRTON ,
    B5_XCORPRE,
    B5_XPAREDE,
    B5_XPISO  ,
    B5_XEXTER ,
    B5_XCALCA ,
    B5_XRAMPA ,
    B5_XTALTIS,
    B5_XTALTO ,
    B5_XTMEDI ,
    B5_XTLEVE ,
    B5_XBANHE ,
    B5_XBOXBAN,
    B5_XCOZIN ,
    B5_XAREASR,
    B5_XQUARTO,
    B5_XSALA  ,
    B5_XHALL  ,
    B5_XTERRAC,
    B5_XGARAGE,
    B5_XPINTER,
    B5_XPBANHE,
    B5_XPCOZIN,
    B5_XPMURO ,
    B5_XPARESR,
    B5_XFACHAD,
    B5_XPISCIN,
    B5_XACABAM,
    B5_XTELAGE,
    B5_XQTEMB ,
    B5_XPEI   ,
    BM_DESC    GRUPO,  
    CT1_DESC01 DESC_CONTA,
    X5_DESCRI TIPO_PRODUTO,
    Z0_DESCR  SUBGRUPO,
    Z2_DESCRI FAMILIA,
    M0_NOMECOM EMPRESA

    FROM %table:SB1% B1
    LEFT JOIN %table:SB5% SB5 ON B1_COD = B5_COD AND SB5.%notdel%
    LEFT JOIN %table:SX5% SX5 ON B1_TIPO = X5_CHAVE AND X5_TABELA = '02' AND SX5.%notdel%
    LEFT JOIN %table:SBM% SBM ON B1_GRUPO = BM_GRUPO AND SBM.%notdel%
    LEFT JOIN %table:SZ0% SZ0 ON B1_TIPO = Z0_TIPO AND SUBSTR(B1_GRUPO,3,3) = Z0_XGRUPO AND B1_XSBGRP = Z0_CODIGO  AND SZ0.%notdel%
    LEFT JOIN %table:SZ2% SZ2 ON B1_TIPO = Z2_XTIPO AND SUBSTR(B1_GRUPO,3,3) = Z2_XGRUPO AND B1_XSBGRP = Z2_SBGRP AND B1_XFAMILI = Z2_FAMILIA  
        AND SZ2.%notdel%
    LEFT JOIN %table:CT1% CT1 ON B1_CONTA = CT1_CONTA AND ct1.%notdel%
    LEFT join sys_company M0 on B1_XFILFAB = M0_CODFIL and M0.%notdel%

    WHERE B1.%notdel%
    //and rownum<1001

EndSql

_cQuery:=GetLastQuery()

_aStru:=DBSTRUCT()

DBGOTOP()

_nHandle    :=FCREATE(_cArquivo)

IF!EOF()

    HTMLMAIL()

    Whil!Eof()

        If _nReg>_nRegsIt
            //_cNarquivo:=_cArquivo+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
            //ENVARQS(_cNarquivo,_cHtml,"DW - QEPITEM")

            _cNarquivo:=_cTabela+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
            ENVFARQS(_cNarquivo)


            _nSeq   ++
            _nReg   :=1
            _nHandle    :=FCREATE(_cArquivo)
        END

        For x:=1 To Len(_aStru)
    
            If _aStru[x,2]=="C"

                MONTACAMPO()

                FWrite(_nHandle, _cCampo)
            Else
                FWrite(_nHandle, Str(&(_aStru[x,1])))
                FWrite(_nHandle, ';')
            END
        NEXT

        FWrite(_nHandle, CRLF)

        DBSKIP()

        _nReg++

    END

//    _cNarquivo:=_cArquivo+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
//    ENVARQS(_cNarquivo,_cHtml,"DW - QEPITEM")
      
      _cNarquivo:=_cTabela+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
      ENVFARQS(_cNarquivo)

else
    GERLOG(_cTabela,_cOrig,"",0)
END

RETURN

/*/{Protheus.doc} QLOSOLCOMPRA
    Extração de dados de Solicitação de Compras
    @type  Static Function
    @author user
    Edson Bella Gonçalves - MRC
    @since 20/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function QLOSOLCOMPRA

Private _nRegsIt      := GetMv("EL_DWRGSSC")
Private _cAlias     :=  GetNextAlias()
Private _nHandle
Private _cTabela    :=  "QLOSOLCOMPRA"
Private _cArquivo   :=  _cPasta+_cTabela
Private _cCampo

If !_lNUser
    If MessageBox("Confirma início?","Geração de Solicitação de Compras",4)==7
        AtuConou('2')
        Return
    END

    MsAguarde({|| PQLOSOLCOM()}, "Aguarde...", "Processando Registros "+_cTabela+"...")
else
    PQLOSOLCOM()
END

AtuConou('4')

Return

//
Static Function PQLOSOLCOM

Local _nReg :=1
Local _nSeq :=1

AtuConou('3')

BeginSql Alias _cAlias

    SELECT
        REGEXP_REPLACE (TRIM(C1_FILIAL ) ,'[[:cntrl:];]') as filial,
        REGEXP_REPLACE (TRIM(C1_PRODUTO) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_DESCRI ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_UM     ) ,'[[:cntrl:];]'),
        C1_QUANT  ,
        REGEXP_REPLACE (TRIM(C1_SEGUM  ) ,'[[:cntrl:];]'),
        C1_QTSEGUM,
        REGEXP_REPLACE (TRIM(C1_XAPLIC ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XGESTOR) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XEVENT ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_CC     ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XORCAME) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XVERSAO) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_OP     ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XURGEN ) ,'[[:cntrl:];]'),
        C1_EMISSAO,
        C1_DATPRF ,
        REGEXP_REPLACE (TRIM(C1_OBS    ) ,'[[:cntrl:];]'),
        replace(regexp_replace(TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(C1_XOBSUSE,250,1))),'[[:cntrl:];"]'),chr(13)),
        REGEXP_REPLACE (TRIM(C1_XOBSCOM) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_ITEM   ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_SOLICIT) ,'[[:cntrl:];]'),
        C1_QUJE   ,
        REGEXP_REPLACE (TRIM(C1_TX     ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_NUM    ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_OK     ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_IMPORT ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_UNIDREQ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_LOCAL  ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_CLASS  ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_CODCOMP) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_FABR   ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_CONTA  ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_NUM_SI ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_ITEMCTA) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_COTACAO) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_FORNECE) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_LOJA   ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_ITEMPED) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_PEDIDO ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_IDENT  ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_OS     ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_FABRLOJ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_TPOP   ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_SEQMRP ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_GRUPCOM) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_USER   ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_RESIDUO) ,'[[:cntrl:];]'),
        C1_QUJE2  ,
        C1_QTDORIG,
        REGEXP_REPLACE (TRIM(C1_ORIGEM ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_TIPOEMP) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_CLVL   ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_PROJETO) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_FILENT ) ,'[[:cntrl:];]'),
        C1_VUNIT  ,
        REGEXP_REPLACE (TRIM(C1_CONDPAG) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_CODORCA) ,'[[:cntrl:];]'),
        C1_PRECO  ,
        REGEXP_REPLACE (TRIM(C1_ESPEMP ) ,'[[:cntrl:];]'),
        C1_TOTAL  ,
        REGEXP_REPLACE (TRIM(C1_APROV  ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_ITEMGRD) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_GRADE  ) ,'[[:cntrl:];]'),
        C1_TIPO   ,
        REGEXP_REPLACE (TRIM(C1_NOMAPRO) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_GERACTR) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_TPSC   ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_MODAL  ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_TPMOD  ) ,'[[:cntrl:];]'),
        C1_MOEDA  ,
        C1_QTDREEM,
        REGEXP_REPLACE (TRIM(C1_ORCAM  ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_SIGLA  ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_FABRICA) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_LOJFABR) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_USRCODE) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_FLAGGCT) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_CODED  ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_NUMPR  ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_PROGRAM) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_ACCNUM ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_ACCPROC) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_RATEIO ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_RATFIN ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_ACCITEM) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XDESCOM) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_USERLGI) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_USERLGA) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_REVISAO) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_IDAPS  ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_ITSCORI) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_SCORI  ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_FISCORI) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_ESTOQUE) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_COMPRAC) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XHORAIN) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XJSTPCO) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_MSEXP  ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_MSIDENT) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XOBSDIR) ,'[[:cntrl:];]'),
        C1_XDATA  ,
        REGEXP_REPLACE (TRIM(C1_XHORA  ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XTPSOL ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XPROD  ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XDESCRI) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XESTORI) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XCIDORI) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XBAIRRO) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XCOTMER) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_PRDREF ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_TIPCOM ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_NRBPIMS) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_PEDRES ) ,'[[:cntrl:];]'),
        C1_XDTAPRO,
        REGEXP_REPLACE (TRIM(C1_XHRAPRO) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_GRPRD  ) ,'[[:cntrl:];]'),
        C1_XDTFIM ,
        C1_XDTINI ,
        REGEXP_REPLACE (TRIM(C1_XHRFIM ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XHRINI ) ,'[[:cntrl:];]'),
        C1_XCLASSI,
        REGEXP_REPLACE (TRIM(C1_XCONTFI) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_PREFIX ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XSTGCT ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XCONTPR) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XGRPAPR) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XNUMCT ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XNUMREV) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XCTADT ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XSOL   ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XTIPOSC) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XCONTPL) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XCONTIT) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(C1_XDIAS  ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(CT1_DESC01) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(CTT_DESC01) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(NNR_DESCRI) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(A2_NOME   ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(E4_DESCRI ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(Y1_NOME   ) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(USR_NOME) ,'[[:cntrl:];]')

    FROM %table:SC1% C1
        
            LEFT JOIN %table:CTT% CTT ON C1_FILIAL = CTT_FILIAL AND C1_CC = CTT_CUSTO AND CTT.%notdel%
            LEFT JOIN %table:NNR% NNR ON TRIM(SUBSTR(C1_FILIAL,1,4)) = TRIM(NNR_FILIAL) AND C1_LOCAL = NNR_CODIGO AND NNR.%notdel%
            LEFT JOIN %table:SY1% SY1 ON C1_CODCOMP = Y1_COD AND sy1.%notdel%
            LEFT JOIN %table:CT1% CT1 ON C1_CONTA = CT1.CT1_CONTA AND CT1.%notdel%
            LEFT JOIN %table:SA2% A2 ON C1_FORNECE = A2_COD AND C1_LOJA = A2_LOJA AND a2.%notdel%
            LEFT join %table:SE4% E4 on substr(c1_FILIAL,1,2) = trim(E4_filial) and c1_CONDpag = E4_CODIGO and E4.%notdel%
            LEFT join sys_usr      USR on c1_xsol = usr_id and usr.%notdel%

    WHERE C1.%notdel%
    //and rownum<50001

EndSql

_cQuery:=GetLastQuery()

_aStru:=DBSTRUCT()

DBGOTOP()

_nHandle    :=FCREATE(_cArquivo)

IF!EOF()

    HTMLMAIL()

    Whil!Eof()

        If _nReg>_nRegsIt
            //_cNarquivo:=_cArquivo+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
            //ENVARQS(_cNarquivo,_cHtml,"DW - QEPITEM")

            _cNarquivo:=_cTabela+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
            ENVFARQS(_cNarquivo)


            _nSeq   ++
            _nReg   :=1
            _nHandle    :=FCREATE(_cArquivo)
        END

        For x:=1 To Len(_aStru)
    
            If _aStru[x,2]=="C"

                MONTACAMPO()

                FWrite(_nHandle, _cCampo)
            Else
                FWrite(_nHandle, Str(&(_aStru[x,1])))
                FWrite(_nHandle, ';')
            END
        NEXT

        FWrite(_nHandle, CRLF)

        DBSKIP()

        _nReg++

    END

//    _cNarquivo:=_cArquivo+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
//    ENVARQS(_cNarquivo,_cHtml,"DW - QEPITEM")
      
      _cNarquivo:=_cTabela+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
      ENVFARQS(_cNarquivo)

else
    GERLOG(_cTabela,_cOrig,"",0)
END

RETURN

/*/{Protheus.doc} QVEOBRAS
    Extração de dados de Solicitação de Compras
    @type  Static Function
    @author user
    Edson Bella Gonçalves - MRC
    @since 22/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function QVEOBRAS

Private _nRegsIt      := GetMv("EL_DWRGOBR")
Private _cAlias     :=  GetNextAlias()
Private _nHandle
Private _cTabela    :=  "QVEOBRAS"
Private _cArquivo   :=  _cPasta+_cTabela
Private _cCampo

If !_lNUser
    If MessageBox("Confirma início?","Geração de Obras",4)==7
        AtuConou('2')
        Return
    END

    MsAguarde({|| PQVEOBRAS()}, "Aguarde...", "Processando Registros "+_cTabela+"...")
else
    PQVEOBRAS()
END

AtuConou('4')

Return

//
Static Function PQVEOBRAS

Local _nReg :=1
Local _nSeq :=1

AtuConou('3')

BeginSql Alias _cAlias

    SELECT 
        REGEXP_REPLACE (TRIM(	ZB0_FILIAL	) ,'[[:cntrl:];"]')	ZB0_FILIAL,
        REGEXP_REPLACE (TRIM(	ZB0_VISAGE	) ,'[[:cntrl:];"]')	ZB0_VISAGE,
        case when ZB0_STNEGO = '1' then 'Sem Registro' when ZB0_STNEGO = '2' then 'Em Negociacao'	when ZB0_STNEGO = '3' then 'Perdida'	when ZB0_STNEGO = '4' then 'Ganha'	end ZB0_STNEGO,			
        REGEXP_REPLACE (TRIM(	ZB0_MODAL8	) ,'[[:cntrl:];"]')	ZB0_MODAL8,
        case	when ZB0_POTFEC = '1' then 'Sem Contato'	when ZB0_POTFEC = '2' then 'Baixo'	when ZB0_POTFEC = '3' then 'Medio' when ZB0_POTFEC = '4' then 'Alto' end ZB0_POTFEC,			
        ZB0_DTPRCP,			
        ZB0_DTCAD ,			
        case when ZB0_STAOBR = '1' then 'Sem Contato'	when ZB0_STAOBR = '2' then 'Licitacao' when ZB0_STAOBR = '3' then 'Parada'	when ZB0_STAOBR = '4' then 'Suspensa' when ZB0_STAOBR = '5' then 'Cotacao' end ZB0_STAOBR,			
        REGEXP_REPLACE (TRIM(	ZB0_APMODE	) ,'[[:cntrl:];"]')	ZB0_APMODE,
        REGEXP_REPLACE (TRIM(	ZB0_CNPJCO	) ,'[[:cntrl:];"]')	ZB0_CNPJCO,
        REGEXP_REPLACE (TRIM(	ZB0_CODOBR	) ,'[[:cntrl:];"]')	ZB0_CODOBR,
        REGEXP_REPLACE (TRIM(	ZB0_CONSTR	) ,'[[:cntrl:];"]')	ZB0_CONSTR,
        REGEXP_REPLACE (TRIM(	ZB0_UFCO  	) ,'[[:cntrl:];"]')	ZB0_UFCO  ,
        REGEXP_REPLACE (TRIM(	ZB0_CIDCON	) ,'[[:cntrl:];"]')	ZB0_CIDCON,
        REGEXP_REPLACE (TRIM(	ZB0_BAICON	) ,'[[:cntrl:];"]')	ZB0_BAICON,
        REGEXP_REPLACE (TRIM(	ZB0_ENDCON	) ,'[[:cntrl:];"]')	ZB0_ENDCON,
        REGEXP_REPLACE (TRIM(	ZB0_CEPCON	) ,'[[:cntrl:];"]')	ZB0_CEPCON,
        case when ZB0_REGIAO = '1' then 'Sem Regiao' when ZB0_REGIAO = '2' then 'RNE' when ZB0_REGIAO = '3' then 'RNO'	when ZB0_REGIAO = '4' then 'RCO' when ZB0_REGIAO = '5' then 'RSE'	when ZB0_REGIAO = '6' then 'RSL'	end ZB0_REGIAO,			
        REGEXP_REPLACE (TRIM(	ZB0_CLIENT	) ,'[[:cntrl:];"]')	ZB0_CLIENT,
        REGEXP_REPLACE (TRIM(	ZB0_LOJACL	) ,'[[:cntrl:];"]')	ZB0_LOJACL,
        ZB0_DTULTA,			
        ZB0_ESTCOM,			
        REGEXP_REPLACE (TRIM(	ZB0_NREVIS	) ,'[[:cntrl:];"]')	ZB0_NREVIS,
        ZB0_ESTCOV,			
        REGEXP_REPLACE (TRIM(	ZB0_CNPJOB	) ,'[[:cntrl:];"]')	ZB0_CNPJOB,
        REGEXP_REPLACE (TRIM(	ZB0_NOMEOB	) ,'[[:cntrl:];"]')	ZB0_NOMEOB,
        REGEXP_REPLACE (TRIM(	ZB0_VEND  	) ,'[[:cntrl:];"]')	ZB0_VEND  ,
        REGEXP_REPLACE (TRIM(	ZB0_CODIN 	) ,'[[:cntrl:];"]')	ZB0_CODIN ,
        ZB0_VALINV,			
        REGEXP_REPLACE (TRIM(	ZB0_PADINV	) ,'[[:cntrl:];"]')	ZB0_PADINV,
        REGEXP_REPLACE (TRIM(	ZB0_XFILIA	) ,'[[:cntrl:];"]')	ZB0_XFILIA,
        REGEXP_REPLACE (TRIM(	ZB0_PEDIDO	) ,'[[:cntrl:];"]')	ZB0_PEDIDO,
        ZB0_ARTOCO,			
        REGEXP_REPLACE (TRIM(	ZB0_UF    	) ,'[[:cntrl:];"]')	ZB0_UF    ,
        REGEXP_REPLACE (TRIM(	ZB0_CIDADE	) ,'[[:cntrl:];"]')	ZB0_CIDADE,
        REGEXP_REPLACE (TRIM(	ZB0_BAIRRO	) ,'[[:cntrl:];"]')	ZB0_BAIRRO,
        REGEXP_REPLACE (TRIM(	ZB0_ENDERE	) ,'[[:cntrl:];"]')	ZB0_ENDERE,
        REGEXP_REPLACE (TRIM(	ZB0_CEP   	) ,'[[:cntrl:];"]')	ZB0_CEP   ,
        ZB0_INIOBR,			
        ZB0_FIMOBR,			
        REGEXP_REPLACE (TRIM(	ZB0_INIFIM	) ,'[[:cntrl:];"]')	ZB0_INIFIM,
        REGEXP_REPLACE (TRIM(	ZB0_ESTATU	) ,'[[:cntrl:];"]')	ZB0_ESTATU,
        case when ZB0_FASE = '1' then 'Sem Contato'	when ZB0_FASE = '2' then 'Projeto/Lancamento'	when ZB0_FASE = '3' then 'Fundacao'	when ZB0_FASE = '4' then 'Estrutura' when ZB0_FASE = '5' then 'Alvenaria'	when ZB0_FASE = '6' then 'Acabamento'	when ZB0_FASE = '7' then 'Reforma' end ZB0_FASE  ,			
        REGEXP_REPLACE (TRIM(	ZB0_SEGATU	) ,'[[:cntrl:];"]')	ZB0_SEGATU,
        REGEXP_REPLACE (TRIM(	ZB0_SUBTIP	) ,'[[:cntrl:];"]')	ZB0_SUBTIP,
        REGEXP_REPLACE (TRIM(	ZB0_NEDIFI	) ,'[[:cntrl:];"]')	ZB0_NEDIFI,
        REGEXP_REPLACE (TRIM(	ZB0_CASAS 	) ,'[[:cntrl:];"]')	ZB0_CASAS ,
        ZB0_CONCAS,			
        REGEXP_REPLACE (TRIM(	ZB0_NPAVIM	) ,'[[:cntrl:];"]')	ZB0_NPAVIM,
        REGEXP_REPLACE (TRIM(	ZB0_APSAAN	) ,'[[:cntrl:];"]')	ZB0_APSAAN,
        REGEXP_REPLACE (TRIM(	ZB0_DORMIT	) ,'[[:cntrl:];"]')	ZB0_DORMIT,
        REGEXP_REPLACE (TRIM(	ZB0_SUITES	) ,'[[:cntrl:];"]')	ZB0_SUITES,
        REGEXP_REPLACE (TRIM(	ZB0_BANHEI	) ,'[[:cntrl:];"]')	ZB0_BANHEI,
        REGEXP_REPLACE (TRIM(	ZB0_LAVABO	) ,'[[:cntrl:];"]')	ZB0_LAVABO,
        REGEXP_REPLACE (TRIM(	ZB0_SAJAES	) ,'[[:cntrl:];"]')	ZB0_SAJAES,
        REGEXP_REPLACE (TRIM(	ZB0_ARSETE	) ,'[[:cntrl:];"]')	ZB0_ARSETE,
        REGEXP_REPLACE (TRIM(	ZB0_COPCOZ	) ,'[[:cntrl:];"]')	ZB0_COPCOZ,
        REGEXP_REPLACE (TRIM(	ZB0_DEPEMP	) ,'[[:cntrl:];"]')	ZB0_DEPEMP,
        REGEXP_REPLACE (TRIM(	ZB0_OUTROS	) ,'[[:cntrl:];"]')	ZB0_OUTROS,
        REGEXP_REPLACE (TRIM(	ZB0_TOTUNI	) ,'[[:cntrl:];"]')	ZB0_TOTUNI,
        REGEXP_REPLACE (TRIM(	ZB0_AREUTI	) ,'[[:cntrl:];"]')	ZB0_AREUTI,
        REGEXP_REPLACE (TRIM(	ZB0_ARETER	) ,'[[:cntrl:];"]')	ZB0_ARETER,
        REGEXP_REPLACE (TRIM(	ZB0_ELEVAD	) ,'[[:cntrl:];"]')	ZB0_ELEVAD,
        REGEXP_REPLACE (TRIM(	ZB0_VAGAS 	) ,'[[:cntrl:];"]')	ZB0_VAGAS ,
        REGEXP_REPLACE (TRIM(	ZB0_COBERT	) ,'[[:cntrl:];"]')	ZB0_COBERT,
        REGEXP_REPLACE (TRIM(	ZB0_ARCOND	) ,'[[:cntrl:];"]')	ZB0_ARCOND,
        REGEXP_REPLACE (TRIM(	ZB0_AQUECI	) ,'[[:cntrl:];"]')	ZB0_AQUECI,
        REGEXP_REPLACE (TRIM(	ZB0_FUNDAC	) ,'[[:cntrl:];"]')	ZB0_FUNDAC,
        REGEXP_REPLACE (TRIM(	ZB0_ESTRUT	) ,'[[:cntrl:];"]')	ZB0_ESTRUT,
        REGEXP_REPLACE (TRIM(	ZB0_ACABAM	) ,'[[:cntrl:];"]')	ZB0_ACABAM,
        REGEXP_REPLACE (TRIM(	ZB0_FACHAD	) ,'[[:cntrl:];"]')	ZB0_FACHAD,
        REGEXP_REPLACE (TRIM(	ZB0_ARELAZ	) ,'[[:cntrl:];"]')	ZB0_ARELAZ,
        REGEXP_REPLACE (TRIM(	ZB0_OUTLAZ	) ,'[[:cntrl:];"]')	ZB0_OUTLAZ,
        REGEXP_REPLACE(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(ZB0_DETALH,250,1)),'[[:cntrl:];"]')ZB0_DETALH,			
        REGEXP_REPLACE (TRIM(	ZB0_NOMCON	) ,'[[:cntrl:];"]')	ZB0_NOMCON,
        REGEXP_REPLACE (TRIM(	ZB0_CARGO 	) ,'[[:cntrl:];"]')	ZB0_CARGO ,
        REGEXP_REPLACE (TRIM(	ZB0_NOFAEM	) ,'[[:cntrl:];"]')	ZB0_NOFAEM,
        REGEXP_REPLACE (TRIM(	ZB0_TELEFO	) ,'[[:cntrl:];"]')	ZB0_TELEFO,
        REGEXP_REPLACE (TRIM(	ZB0_FAX   	) ,'[[:cntrl:];"]')	ZB0_FAX   ,
        REGEXP_REPLACE (TRIM(	ZB0_EMAIL 	) ,'[[:cntrl:];"]')	ZB0_EMAIL ,
        REGEXP_REPLACE (TRIM(	ZB0_NOMCO2	) ,'[[:cntrl:];"]')	ZB0_NOMCO2,
        REGEXP_REPLACE (TRIM(	ZB0_CARGO2	) ,'[[:cntrl:];"]')	ZB0_CARGO2,
        REGEXP_REPLACE (TRIM(	ZB0_NOFAE2	) ,'[[:cntrl:];"]')	ZB0_NOFAE2,
        REGEXP_REPLACE (TRIM(	ZB0_TELEF2	) ,'[[:cntrl:];"]')	ZB0_TELEF2,
        REGEXP_REPLACE (TRIM(	ZB0_FAX2  	) ,'[[:cntrl:];"]')	ZB0_FAX2  ,
        REGEXP_REPLACE (TRIM(	ZB0_EMAIL2	) ,'[[:cntrl:];"]')	ZB0_EMAIL2,
        REGEXP_REPLACE (TRIM(	ZB0_NOMCO3	) ,'[[:cntrl:];"]')	ZB0_NOMCO3,
        REGEXP_REPLACE (TRIM(	ZB0_CARGO3	) ,'[[:cntrl:];"]')	ZB0_CARGO3,
        REGEXP_REPLACE (TRIM(	ZB0_NOFAE3	) ,'[[:cntrl:];"]')	ZB0_NOFAE3,
        REGEXP_REPLACE (TRIM(	ZB0_TELEF3	) ,'[[:cntrl:];"]')	ZB0_TELEF3,
        REGEXP_REPLACE (TRIM(	ZB0_FAX3  	) ,'[[:cntrl:];"]')	ZB0_FAX3  ,
        REGEXP_REPLACE (TRIM(	ZB0_EMAIL3	) ,'[[:cntrl:];"]')	ZB0_EMAIL3,
        REGEXP_REPLACE (TRIM(	ZB0_NOMCO4	) ,'[[:cntrl:];"]')	ZB0_NOMCO4,
        REGEXP_REPLACE (TRIM(	ZB0_CARGO4	) ,'[[:cntrl:];"]')	ZB0_CARGO4,
        REGEXP_REPLACE (TRIM(	ZB0_NOFAE4	) ,'[[:cntrl:];"]')	ZB0_NOFAE4,
        REGEXP_REPLACE (TRIM(	ZB0_TELEF4	) ,'[[:cntrl:];"]')	ZB0_TELEF4,
        REGEXP_REPLACE (TRIM(	ZB0_FAX4  	) ,'[[:cntrl:];"]')	ZB0_FAX4  ,
        REGEXP_REPLACE (TRIM(	ZB0_EMAIL4	) ,'[[:cntrl:];"]')	ZB0_EMAIL4,
        REGEXP_REPLACE (TRIM(	ZB0_NOMCO5	) ,'[[:cntrl:];"]')	ZB0_NOMCO5,
        REGEXP_REPLACE (TRIM(	ZB0_CARGO5	) ,'[[:cntrl:];"]')	ZB0_CARGO5,
        REGEXP_REPLACE (TRIM(	ZB0_NOFAE5	) ,'[[:cntrl:];"]')	ZB0_NOFAE5,
        REGEXP_REPLACE (TRIM(	ZB0_TELEF5	) ,'[[:cntrl:];"]')	ZB0_TELEF5,
        REGEXP_REPLACE (TRIM(	ZB0_FAX5  	) ,'[[:cntrl:];"]')	ZB0_FAX5  ,
        REGEXP_REPLACE (TRIM(	ZB0_EMIAL5	) ,'[[:cntrl:];"]')	ZB0_EMIAL5,
        REGEXP_REPLACE (TRIM(	ZB0_NOMCO6	) ,'[[:cntrl:];"]')	ZB0_NOMCO6,
        REGEXP_REPLACE (TRIM(	ZB0_CARGO6	) ,'[[:cntrl:];"]')	ZB0_CARGO6,
        REGEXP_REPLACE (TRIM(	ZB0_NOFAE6	) ,'[[:cntrl:];"]')	ZB0_NOFAE6,
        REGEXP_REPLACE (TRIM(	ZB0_TELEF6	) ,'[[:cntrl:];"]')	ZB0_TELEF6,
        REGEXP_REPLACE (TRIM(	ZB0_FAX6  	) ,'[[:cntrl:];"]')	ZB0_FAX6  ,
        REGEXP_REPLACE (TRIM(	ZB0_EMAIL6	) ,'[[:cntrl:];"]')	ZB0_EMAIL6,
        REGEXP_REPLACE (TRIM(	ZB0_NOMCO7	) ,'[[:cntrl:];"]')	ZB0_NOMCO7,
        REGEXP_REPLACE (TRIM(	ZB0_CARGO7	) ,'[[:cntrl:];"]')	ZB0_CARGO7,
        REGEXP_REPLACE (TRIM(	ZB0_NOFAE7	) ,'[[:cntrl:];"]')	ZB0_NOFAE7,
        REGEXP_REPLACE (TRIM(	ZB0_TELEF7	) ,'[[:cntrl:];"]')	ZB0_TELEF7,
        REGEXP_REPLACE (TRIM(	ZB0_FAX7  	) ,'[[:cntrl:];"]')	ZB0_FAX7  ,
        REGEXP_REPLACE (TRIM(	ZB0_EMAIL7	) ,'[[:cntrl:];"]')	ZB0_EMAIL7,
        REGEXP_REPLACE (TRIM(	ZB0_NOMCO8	) ,'[[:cntrl:];"]')	ZB0_NOMCO8,
        REGEXP_REPLACE (TRIM(	ZB0_CARGO8	) ,'[[:cntrl:];"]')	ZB0_CARGO8,
        REGEXP_REPLACE (TRIM(	ZB0_NOFAE8	) ,'[[:cntrl:];"]')	ZB0_NOFAE8,
        REGEXP_REPLACE (TRIM(	ZB0_TELEF8	) ,'[[:cntrl:];"]')	ZB0_TELEF8,
        REGEXP_REPLACE (TRIM(	ZB0_FAX8  	) ,'[[:cntrl:];"]')	ZB0_FAX8  ,
        REGEXP_REPLACE (TRIM(	ZB0_EMAIL8	) ,'[[:cntrl:];"]')	ZB0_EMAIL8,
        REGEXP_REPLACE (TRIM(	ZB0_NFAEMP	) ,'[[:cntrl:];"]')	ZB0_NFAEMP,
        REGEXP_REPLACE (TRIM(	ZB0_MODALI	) ,'[[:cntrl:];"]')	ZB0_MODALI,
        REGEXP_REPLACE (TRIM(	ZB0_NFAEP2	) ,'[[:cntrl:];"]')	ZB0_NFAEP2,
        REGEXP_REPLACE (TRIM(	ZB0_MODAL2	) ,'[[:cntrl:];"]')	ZB0_MODAL2,
        REGEXP_REPLACE (TRIM(	ZB0_NFAEP3	) ,'[[:cntrl:];"]')	ZB0_NFAEP3,
        REGEXP_REPLACE (TRIM(	ZB0_MODAL3	) ,'[[:cntrl:];"]')	ZB0_MODAL3,
        REGEXP_REPLACE (TRIM(	ZB0_NFAEP4	) ,'[[:cntrl:];"]')	ZB0_NFAEP4,
        REGEXP_REPLACE (TRIM(	ZB0_MODAL4	) ,'[[:cntrl:];"]')	ZB0_MODAL4,
        REGEXP_REPLACE (TRIM(	ZB0_NFAEP5	) ,'[[:cntrl:];"]')	ZB0_NFAEP5,
        REGEXP_REPLACE (TRIM(	ZB0_MODAL5	) ,'[[:cntrl:];"]')	ZB0_MODAL5,
        REGEXP_REPLACE (TRIM(	ZB0_NFAEP6	) ,'[[:cntrl:];"]')	ZB0_NFAEP6,
        REGEXP_REPLACE (TRIM(	ZB0_MODAL6	) ,'[[:cntrl:];"]')	ZB0_MODAL6,
        REGEXP_REPLACE (TRIM(	ZB0_NFAEP7	) ,'[[:cntrl:];"]')	ZB0_NFAEP7,
        REGEXP_REPLACE (TRIM(	ZB0_MODAL7	) ,'[[:cntrl:];"]')	ZB0_MODAL7,
        REGEXP_REPLACE (TRIM(	ZB0_NFAEP8	) ,'[[:cntrl:];"]')	ZB0_NFAEP8,
        REGEXP_REPLACE (TRIM(	ZB0_MSEXP 	) ,'[[:cntrl:];"]')	ZB0_MSEXP,
        REGEXP_REPLACE (TRIM(	A1_NOME	) ,'[[:cntrl:];"]')	A1_NOME,
        REGEXP_REPLACE (TRIM(	A3_NOME	) ,'[[:cntrl:];"]')	A3_NOME

    FROM %table:ZB0% ZB0
    LEFT JOIN %table:sa1% SA1 ON ZB0_CLIENT = A1_COD AND ZB0_LOJACL = A1_LOJA and sa1.%notdel%
    left join %table:sa3% sa3 on ZB0_VEND = a3_cod and a3_filial = '020201' and sa3.%notdel%
 
    WHERE ZB0.%notdel%
    //and rownum<50001

EndSql

_cQuery:=GetLastQuery()

_aStru:=DBSTRUCT()

DBGOTOP()

_nHandle    :=FCREATE(_cArquivo)

IF!EOF()

    HTMLMAIL()

    Whil!Eof()

        If _nReg>_nRegsIt
            //_cNarquivo:=_cArquivo+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
            //ENVARQS(_cNarquivo,_cHtml,"DW - QEPITEM")

            _cNarquivo:=_cTabela+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
            ENVFARQS(_cNarquivo)


            _nSeq   ++
            _nReg   :=1
            _nHandle    :=FCREATE(_cArquivo)
        END

        For x:=1 To Len(_aStru)
    
            If _aStru[x,2]=="C"

                MONTACAMPO()

                FWrite(_nHandle, _cCampo)
            Else
                FWrite(_nHandle, Str(&(_aStru[x,1])))
                FWrite(_nHandle, ';')
            END
        NEXT

        FWrite(_nHandle, CRLF)

        DBSKIP()

        _nReg++

    END

//    _cNarquivo:=_cArquivo+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
//    ENVARQS(_cNarquivo,_cHtml,"DW - QEPITEM")
      
      _cNarquivo:=_cTabela+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
      ENVFARQS(_cNarquivo)

else
    GERLOG(_cTabela,_cOrig,"",0)
END

RETURN

/*/{Protheus.doc} QVEAGENTE
    Extração de dados de Solicitação de Compras
    @type  Static Function
    @author user
    Edson Bella Gonçalves - MRC
    @since 22/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function QVEAGENTE

Private _nRegsIt      := GetMv("EL_DWRGVEN")
Private _cAlias     :=  GetNextAlias()
Private _nHandle
Private _cTabela    :=  "QVEAGENTE"
Private _cArquivo   :=  _cPasta+_cTabela
Private _cCampo

If !_lNUser
    If MessageBox("Confirma início?","Geração de Obras",4)==7
        AtuConou('2')
        Return
    END

    MsAguarde({|| PQVEVENDE()}, "Aguarde...", "Processando Registros "+_cTabela+"...")
else
    PQVEVENDE()
END

AtuConou('4')

Return

//
Static Function PQVEVENDE

Local _nReg :=1
Local _nSeq :=1

AtuConou('3')

BeginSql Alias _cAlias

    SELECT 
        REGEXP_REPLACE (TRIM(A3_FILIAL ) ,'[[:cntrl:];]')A3_FILIAL ,
        REGEXP_REPLACE (TRIM(A3_COD    ) ,'[[:cntrl:];]')A3_COD    ,
        REGEXP_REPLACE (TRIM(A3_NOME   ) ,'[[:cntrl:];]')A3_NOME   ,
        REGEXP_REPLACE (TRIM(A3_NREDUZ ) ,'[[:cntrl:];]')A3_NREDUZ ,
        REGEXP_REPLACE (TRIM(A3_END    ) ,'[[:cntrl:];]')A3_END    ,
        REGEXP_REPLACE (TRIM(A3_BAIRRO ) ,'[[:cntrl:];]')A3_BAIRRO ,
        REGEXP_REPLACE (TRIM(A3_MUN    ) ,'[[:cntrl:];]')A3_MUN    ,
        REGEXP_REPLACE (TRIM(A3_EST    ) ,'[[:cntrl:];]')A3_EST    ,
        REGEXP_REPLACE (TRIM(A3_CGC    ) ,'[[:cntrl:];]')A3_CGC    ,
        REGEXP_REPLACE (TRIM(A3_CEP    ) ,'[[:cntrl:];]')A3_CEP    ,
        REGEXP_REPLACE (TRIM(A3_XCOMPLE) ,'[[:cntrl:];]')A3_XCOMPLE,
        REGEXP_REPLACE (TRIM(A3_XCONTAT) ,'[[:cntrl:];]')A3_XCONTAT,
        REGEXP_REPLACE (TRIM(A3_DDDTEL ) ,'[[:cntrl:];]')A3_DDDTEL ,
        REGEXP_REPLACE (TRIM(A3_TIPO   ) ,'[[:cntrl:];]')A3_TIPO   ,
        REGEXP_REPLACE (TRIM(A3_TEL    ) ,'[[:cntrl:];]')A3_TEL    ,
        REGEXP_REPLACE (TRIM(A3_TEL2   ) ,'[[:cntrl:];]')A3_TEL2   ,
        REGEXP_REPLACE (TRIM(A3_TEL3   ) ,'[[:cntrl:];]')A3_TEL3   ,
        REGEXP_REPLACE (TRIM(A3_EMAIL  ) ,'[[:cntrl:];]')A3_EMAIL  ,
        REGEXP_REPLACE (TRIM(A3_HPAGE  ) ,'[[:cntrl:];]')A3_HPAGE  ,
        REGEXP_REPLACE (TRIM(A3_CEL    ) ,'[[:cntrl:];]')A3_CEL    ,
        REGEXP_REPLACE (TRIM(A3_FAX    ) ,'[[:cntrl:];]')A3_FAX    ,
        REGEXP_REPLACE (TRIM(A3_XARATUA) ,'[[:cntrl:];]')A3_XARATUA,
        case
        when a3_xtipo = '1' then 'Revenda'
        when a3_xtipo = '2' then 'Engenharia'
        when a3_xtipo = '3' then 'Ambos'
        when a3_xtipo = '4' then 'Esportacao'
        end a3_xtipo,
        REGEXP_REPLACE (TRIM(A3_TELEX  ) ,'[[:cntrl:];]')A3_TELEX  ,
        REGEXP_REPLACE (TRIM(A3_INSCR  ) ,'[[:cntrl:];]')A3_INSCR  ,
        REGEXP_REPLACE (TRIM(A3_INSCRM ) ,'[[:cntrl:];]')A3_INSCRM ,
        REGEXP_REPLACE (TRIM(A3_CODUSR ) ,'[[:cntrl:];]')A3_CODUSR ,
        REGEXP_REPLACE (TRIM(A3_SUPER  ) ,'[[:cntrl:];]')A3_SUPER  ,
        REGEXP_REPLACE (TRIM(A3_GEREN  ) ,'[[:cntrl:];]')A3_GEREN  ,
        REGEXP_REPLACE (TRIM(A3_FORNECE) ,'[[:cntrl:];]')A3_FORNECE,
        REGEXP_REPLACE (TRIM(A3_LOJA   ) ,'[[:cntrl:];]')A3_LOJA   ,
        REGEXP_REPLACE (TRIM(A3_GERASE2) ,'[[:cntrl:];]')A3_GERASE2,
        REGEXP_REPLACE (TRIM(A3_BCO1   ) ,'[[:cntrl:];]')A3_BCO1   ,
        REGEXP_REPLACE (TRIM(A3_REGIAO ) ,'[[:cntrl:];]')A3_REGIAO ,
        A3_COMIS  ,
        A3_ALEMISS,
        A3_ALBAIXA,
        REGEXP_REPLACE (TRIM(A3_ICM    ) ,'[[:cntrl:];]')A3_ICM    ,
        REGEXP_REPLACE (TRIM(A3_ICMSRET) ,'[[:cntrl:];]')A3_ICMSRET,
        A3_PERDESC,
        A3_DIARESE,
        REGEXP_REPLACE (TRIM(A3_ISS    ) ,'[[:cntrl:];]')A3_ISS    ,
        REGEXP_REPLACE (TRIM(A3_IPI    ) ,'[[:cntrl:];]')A3_IPI    ,
        REGEXP_REPLACE (TRIM(A3_FRETE  ) ,'[[:cntrl:];]')A3_FRETE  ,
        REGEXP_REPLACE (TRIM(A3_ACREFIN) ,'[[:cntrl:];]')A3_ACREFIN,
        A3_DIA    ,
        REGEXP_REPLACE (TRIM(A3_DDD    ) ,'[[:cntrl:];]')A3_DDD    ,
        REGEXP_REPLACE (TRIM(A3_TIPSUP ) ,'[[:cntrl:];]')A3_TIPSUP ,
        REGEXP_REPLACE (TRIM(A3_SENHA  ) ,'[[:cntrl:];]')A3_SENHA  ,
        REGEXP_REPLACE (TRIM(A3_UNIDAD ) ,'[[:cntrl:];]')A3_UNIDAD ,
        REGEXP_REPLACE (TRIM(A3_HAND   ) ,'[[:cntrl:];]')A3_HAND   ,
        REGEXP_REPLACE (TRIM(A3_PEDINI ) ,'[[:cntrl:];]')A3_PEDINI ,
        A3_QTCONTA,
        REGEXP_REPLACE (TRIM(A3_PEDFIM ) ,'[[:cntrl:];]')A3_PEDFIM ,
        REGEXP_REPLACE (TRIM(A3_REGSLA ) ,'[[:cntrl:];]')A3_REGSLA ,
        REGEXP_REPLACE (TRIM(A3_CLIINI ) ,'[[:cntrl:];]')A3_CLIINI ,
        REGEXP_REPLACE (TRIM(A3_CARGO  ) ,'[[:cntrl:];]')A3_CARGO  ,
        REGEXP_REPLACE (TRIM(A3_CLIFIM ) ,'[[:cntrl:];]')A3_CLIFIM ,
        REGEXP_REPLACE (TRIM(A3_PROXPED) ,'[[:cntrl:];]')A3_PROXPED,
        REGEXP_REPLACE (TRIM(A3_URLEXG ) ,'[[:cntrl:];]')A3_URLEXG ,
        REGEXP_REPLACE (TRIM(A3_PROXCLI) ,'[[:cntrl:];]')A3_PROXCLI,
        REGEXP_REPLACE (TRIM(A3_GRPREP ) ,'[[:cntrl:];]')A3_GRPREP ,
        REGEXP_REPLACE (TRIM(A3_FAT_RH ) ,'[[:cntrl:];]')A3_FAT_RH ,
        REGEXP_REPLACE (TRIM(A3_GRUPSAN) ,'[[:cntrl:];]')A3_GRUPSAN,
        A3_ADMISS ,
        REGEXP_REPLACE (TRIM(A3_NVLSTR ) ,'[[:cntrl:];]')A3_NVLSTR ,
        A3_NIVEL  ,
        REGEXP_REPLACE (TRIM(A3_DEPEND ) ,'[[:cntrl:];]')A3_DEPEND ,
        A3_PEN_ALI,
        REGEXP_REPLACE (TRIM(A3_TIPVEND) ,'[[:cntrl:];]')A3_TIPVEND,
        REGEXP_REPLACE (TRIM(A3_NUMRA  ) ,'[[:cntrl:];]')A3_NUMRA  ,
        REGEXP_REPLACE (TRIM(A3_PAIS   ) ,'[[:cntrl:];]')A3_PAIS   ,
        REGEXP_REPLACE (TRIM(A3_DDI    ) ,'[[:cntrl:];]')A3_DDI    ,
        REGEXP_REPLACE (TRIM(A3_LANEXG ) ,'[[:cntrl:];]')A3_LANEXG ,
        REGEXP_REPLACE (TRIM(A3_PISCOF ) ,'[[:cntrl:];]')A3_PISCOF ,
        A3_XDTCAD ,
        A3_XDTNASC,
        REGEXP_REPLACE (TRIM(A3_XVEND  ) ,'[[:cntrl:];]')A3_XVEND  ,
        REGEXP_REPLACE (TRIM(A3_USERLGI) ,'[[:cntrl:];]')A3_USERLGI,
        REGEXP_REPLACE (TRIM(A3_USERLGA) ,'[[:cntrl:];]')A3_USERLGA,
        REGEXP_REPLACE (TRIM(A3_SINCTAF) ,'[[:cntrl:];]')A3_SINCTAF,
        REGEXP_REPLACE (TRIM(A3_SINCAGE) ,'[[:cntrl:];]')A3_SINCAGE,
        REGEXP_REPLACE (TRIM(A3_SINCCON) ,'[[:cntrl:];]')A3_SINCCON,
        REGEXP_REPLACE (TRIM(A3_PERAGE ) ,'[[:cntrl:];]')A3_PERAGE ,
        REGEXP_REPLACE (TRIM(A3_PERTAF ) ,'[[:cntrl:];]')A3_PERTAF ,
        REGEXP_REPLACE (TRIM(A3_TIMEMIN) ,'[[:cntrl:];]')A3_TIMEMIN,
        REGEXP_REPLACE (TRIM(A3_USUCORP) ,'[[:cntrl:];]')A3_USUCORP,
        REGEXP_REPLACE (TRIM(A3_HABSINC) ,'[[:cntrl:];]')A3_HABSINC,
        REGEXP_REPLACE (TRIM(A3_MSBLQL ) ,'[[:cntrl:];]')A3_MSBLQL ,
        replace(regexp_replace(TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(A3_OBSVEND,250,1))),'[[:cntrl:];"]'),chr(13))A3_OBSVEND,
        REGEXP_REPLACE (TRIM(A3_MSIDENT) ,'[[:cntrl:];]')A3_MSIDENT,
        REGEXP_REPLACE (TRIM(A3_BASEIR ) ,'[[:cntrl:];]')A3_BASEIR ,
        REGEXP_REPLACE (TRIM(A3_MSEXP  ) ,'[[:cntrl:];]')A3_MSEXP  ,
        REGEXP_REPLACE (TRIM(A3_EMACORP) ,'[[:cntrl:];]')A3_EMACORP,
        REGEXP_REPLACE (TRIM(A3_BIAGEND) ,'[[:cntrl:];]')A3_BIAGEND,
        REGEXP_REPLACE (TRIM(A3_BITAREF) ,'[[:cntrl:];]')A3_BITAREF,
        REGEXP_REPLACE (TRIM(A3_BICONT ) ,'[[:cntrl:];]')A3_BICONT ,
        A3_DTUMOV ,
        REGEXP_REPLACE (TRIM(A3_HRUMOV ) ,'[[:cntrl:];]')A3_HRUMOV ,
        REGEXP_REPLACE (TRIM(A3_HREXPO ) ,'[[:cntrl:];]')A3_HREXPO ,
        REGEXP_REPLACE (TRIM(A3_MODTRF ) ,'[[:cntrl:];]')A3_MODTRF ,
        REGEXP_REPLACE (TRIM(A3_SNAEXG ) ,'[[:cntrl:];]')A3_SNAEXG ,
        REGEXP_REPLACE (TRIM(A3_MSRESP ) ,'[[:cntrl:];]')A3_MSRESP ,
        REGEXP_REPLACE (TRIM(A3_CODISS ) ,'[[:cntrl:];]')A3_CODISS ,
        REGEXP_REPLACE (TRIM(A3_FILFUN ) ,'[[:cntrl:];]')A3_FILFUN ,
        A3_XDTINAT,

        A2_NOME,
        SX5R.X5_DESCRI,
        SX5E.X5_DESCRI

    FROM %table:SA3% A3
         LEFT JOIN protheus.sa2010 SA2 ON A3_FORNECE = A2_COD AND A3_LOJA = A2_LOJA
         LEFT JOIN PROTHEUS.SX5010 SX5E ON A3_EST = SX5E.X5_CHAVE AND SX5E.X5_TABELA = '12'
         LEFT JOIN PROTHEUS.SX5010 SX5R ON A3_REGIAO = SX5R.X5_CHAVE AND SX5R.X5_TABELA = 'X1'

     WHERE A3.%notdel%
   //and rownum<50001

EndSql

_cQuery:=GetLastQuery()

_aStru:=DBSTRUCT()

DBGOTOP()

_nHandle    :=FCREATE(_cArquivo)

IF!EOF()

    HTMLMAIL()

    Whil!Eof()

        If _nReg>_nRegsIt
            //_cNarquivo:=_cArquivo+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
            //ENVARQS(_cNarquivo,_cHtml,"DW - QEPITEM")

            _cNarquivo:=_cTabela+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
            ENVFARQS(_cNarquivo)

            _nSeq   ++
            _nReg   :=1
            _nHandle    :=FCREATE(_cArquivo)
        END

        For x:=1 To Len(_aStru)
    
            If _aStru[x,2]=="C"

                MONTACAMPO()

                FWrite(_nHandle, _cCampo)
            Else
                FWrite(_nHandle, Str(&(_aStru[x,1])))
                FWrite(_nHandle, ';')
            END
        NEXT

        FWrite(_nHandle, CRLF)

        DBSKIP()

        _nReg++

    END

//    _cNarquivo:=_cArquivo+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
//    ENVARQS(_cNarquivo,_cHtml,"DW - QEPITEM")
      
      _cNarquivo:=_cTabela+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
      ENVFARQS(_cNarquivo)

else
    GERLOG(_cTabela,_cOrig,"",0)
END

RETURN

/*/{Protheus.doc} NOTASENTR
    Extração de dados de nota de entrada
    @type  Static Function
    @author user
    Edson Bella Gonçalves - MRC
    @since 23/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)@see (links_or_references)
/*/

Static Function QLONFENTRA()
    
Local   _aPergs     := {}
Local   _cFilialDe  := Space(6)
Local   _cFilialAte := Space(6)
Local   _dEmissaoD  := Ctod('  /  /    ')
Local   _dEmissaoA  := Ctod('  /  /    ')

Private _nNfdias    := GetMv("EL_DWNEDIA")
Private _nNfdiasR   := GetMv("EL_DWNEQD")
Private _cAlias     :=  GetNextAlias()
Private _nHandle
Private _cTabela    :=  "QLONFENTRADA"
Private _cArquivo   :=  _cPasta+_cTabela

If _lNUser
    MV_PAR01    :=  ' '
    MV_PAR02    :=  'ZZZZZZ'
    MV_PAR03    :=  date()-_nNfdiasR //CtoD('01/10/2022') //
    MV_PAR04    :=  date() //CtoD('31/12/2022') //

else
    aAdd(_aPergs, {1, "Filial de",   _cFilialDe,    "", ".T.", "",".T.", 40,.T.})
    aAdd(_aPergs, {1, "Filial até",  _cFilialAte,   "", ".T.", "",".T.", 40,.F.})
    aAdd(_aPergs, {1, "Emissão de",  _dEmissaoD,    "", ".T.", "",".T.", 60,.T.})
    aAdd(_aPergs, {1, "Emissão até", _dEmissaoA,    "", ".T.", "",".T.", 60,.F.})

    If !ParamBox(_aPergs, "Informe os parâmetros")
        AtuConou('2')
        RETURN .t.
    End

END

MsAguarde({|| PNOTASENTR()}, "Aguarde...", "Processando Registros "+_cTabela+"...")

AtuConou('4')

Return

//
Static Function PNOTASENTR

AtuConou('3')

BeginSql Alias _cAlias

    SELECT 
        REGEXP_REPLACE (TRIM(D1_FILIAL ) ,'[[:cntrl:];"]')D1_FILIAL ,
        REGEXP_REPLACE (TRIM(D1_ITEM   ) ,'[[:cntrl:];"]')D1_ITEM   ,
        REGEXP_REPLACE (TRIM(D1_COD    ) ,'[[:cntrl:];"]')D1_COD    ,
        REGEXP_REPLACE (TRIM(D1_XDESCRI) ,'[[:cntrl:];"]')D1_XDESCRI,
        REGEXP_REPLACE (TRIM(D1_UM     ) ,'[[:cntrl:];"]')D1_UM     ,
        REGEXP_REPLACE (TRIM(D1_SEGUM  ) ,'[[:cntrl:];"]')D1_SEGUM  ,
        D1_QUANT  ,
        D1_VUNIT  ,
        D1_QTSEGUM,
        D1_TOTAL  ,
        REGEXP_REPLACE (TRIM(D1_XGESTOR) ,'[[:cntrl:];"]')D1_XGESTOR,
        REGEXP_REPLACE (TRIM(D1_XAPLIC ) ,'[[:cntrl:];"]')D1_XAPLIC ,
        REGEXP_REPLACE (TRIM(D1_XEVENT ) ,'[[:cntrl:];"]')D1_XEVENT ,
        REGEXP_REPLACE (TRIM(D1_CC     ) ,'[[:cntrl:];"]')D1_CC     ,
        REGEXP_REPLACE (TRIM(D1_XORCAME) ,'[[:cntrl:];"]')D1_XORCAME,
        REGEXP_REPLACE (TRIM(D1_XVERSAO) ,'[[:cntrl:];"]')D1_XVERSAO,
        D1_VALIPI ,
        D1_VALICM ,
        REGEXP_REPLACE (TRIM(D1_TES    ) ,'[[:cntrl:];"]')D1_TES    ,
        REGEXP_REPLACE (TRIM(D1_CF     ) ,'[[:cntrl:];"]')D1_CF     ,
        D1_DESC   ,
        D1_IPI    ,
        D1_PICM   ,
        D1_ALIQISS,
        D1_ALIQIRR,
        D1_ALIQINS,
        D1_EMISSAO,
        D1_ICMSRET,
        D1_PESO   ,
        REGEXP_REPLACE (TRIM(D1_CONTA  ) ,'[[:cntrl:];"]')D1_CONTA  ,
        REGEXP_REPLACE (TRIM(D1_ITEMCTA) ,'[[:cntrl:];"]')D1_ITEMCTA,
        REGEXP_REPLACE (TRIM(D1_OP     ) ,'[[:cntrl:];"]')D1_OP     ,
        REGEXP_REPLACE (TRIM(D1_PEDIDO ) ,'[[:cntrl:];"]')D1_PEDIDO ,
        REGEXP_REPLACE (TRIM(D1_ITEMPC ) ,'[[:cntrl:];"]')D1_ITEMPC ,
        REGEXP_REPLACE (TRIM(D1_FORNECE) ,'[[:cntrl:];"]')D1_FORNECE,
        REGEXP_REPLACE (TRIM(D1_LOJA   ) ,'[[:cntrl:];"]')D1_LOJA   ,
        REGEXP_REPLACE (TRIM(D1_LOCAL  ) ,'[[:cntrl:];"]')D1_LOCAL  ,
        REGEXP_REPLACE (TRIM(D1_NUMSEQ ) ,'[[:cntrl:];"]')D1_NUMSEQ ,
        REGEXP_REPLACE (TRIM(D1_DOC    ) ,'[[:cntrl:];"]')D1_DOC    ,
        D1_DTDIGIT,
        REGEXP_REPLACE (TRIM(D1_ITEMORI) ,'[[:cntrl:];"]')D1_ITEMORI,
        REGEXP_REPLACE (TRIM(D1_GRUPO  ) ,'[[:cntrl:];"]')D1_GRUPO  ,
        REGEXP_REPLACE (TRIM(D1_TIPO   ) ,'[[:cntrl:];"]')D1_TIPO   ,
        REGEXP_REPLACE (TRIM(D1_ORIGLAN) ,'[[:cntrl:];"]')D1_ORIGLAN,
        REGEXP_REPLACE (TRIM(D1_SERIE  ) ,'[[:cntrl:];"]')D1_SERIE  ,
        D1_CUSTO3 ,
        REGEXP_REPLACE (TRIM(D1_NUMCQ  ) ,'[[:cntrl:];"]')D1_NUMCQ  ,
        D1_CUSTO2 ,
        D1_CUSTO4 ,
        D1_CUSTO5 ,
        REGEXP_REPLACE (TRIM(D1_IDENTB6) ,'[[:cntrl:];"]')D1_IDENTB6,
        REGEXP_REPLACE (TRIM(D1_TP     ) ,'[[:cntrl:];"]')D1_TP     ,
        REGEXP_REPLACE (TRIM(D1_SKIPLOT) ,'[[:cntrl:];"]')D1_SKIPLOT,
        D1_DATACUS,
        REGEXP_REPLACE (TRIM(D1_SEQCALC) ,'[[:cntrl:];"]')D1_SEQCALC,
        REGEXP_REPLACE (TRIM(D1_NFORI  ) ,'[[:cntrl:];"]')D1_NFORI  ,
        REGEXP_REPLACE (TRIM(D1_SERIORI) ,'[[:cntrl:];"]')D1_SERIORI,
        D1_QTDEDEV,
        D1_VALDEV ,
        D1_BRICMS ,
        D1_DATORI ,
        D1_BASEICM,
        D1_VALDESC,
        REGEXP_REPLACE (TRIM(D1_LOTEFOR) ,'[[:cntrl:];"]')D1_LOTEFOR,
        D1_BASEIPI,
        REGEXP_REPLACE (TRIM(D1_LOTECTL) ,'[[:cntrl:];"]')D1_LOTECTL,
        REGEXP_REPLACE (TRIM(D1_FORMUL ) ,'[[:cntrl:];"]')D1_FORMUL ,
        REGEXP_REPLACE (TRIM(D1_NUMLOTE) ,'[[:cntrl:];"]')D1_NUMLOTE,
        D1_DTVALID,
        REGEXP_REPLACE (TRIM(D1_PLACA  ) ,'[[:cntrl:];"]')D1_PLACA  ,
        REGEXP_REPLACE (TRIM(D1_NUMPV  ) ,'[[:cntrl:];"]')D1_NUMPV  ,
        REGEXP_REPLACE (TRIM(D1_ITEMPV ) ,'[[:cntrl:];"]')D1_ITEMPV ,
        REGEXP_REPLACE (TRIM(D1_CHASSI ) ,'[[:cntrl:];"]')D1_CHASSI ,
        REGEXP_REPLACE (TRIM(D1_ANOFAB ) ,'[[:cntrl:];"]')D1_ANOFAB ,
        REGEXP_REPLACE (TRIM(D1_MODFAB ) ,'[[:cntrl:];"]')D1_MODFAB ,
        REGEXP_REPLACE (TRIM(D1_MODELO ) ,'[[:cntrl:];"]')D1_MODELO ,
        REGEXP_REPLACE (TRIM(D1_COMBUST) ,'[[:cntrl:];"]')D1_COMBUST,
        REGEXP_REPLACE (TRIM(D1_COR    ) ,'[[:cntrl:];"]')D1_COR    ,
        REGEXP_REPLACE (TRIM(D1_CLASFIS) ,'[[:cntrl:];"]')D1_CLASFIS,
        REGEXP_REPLACE (TRIM(D1_EQUIPS ) ,'[[:cntrl:];"]')D1_EQUIPS ,
        REGEXP_REPLACE (TRIM(D1_REMITO ) ,'[[:cntrl:];"]')D1_REMITO ,
        REGEXP_REPLACE (TRIM(D1_SERIREM) ,'[[:cntrl:];"]')D1_SERIREM,
        D1_II     ,
        REGEXP_REPLACE (TRIM(D1_TEC    ) ,'[[:cntrl:];"]')D1_TEC    ,
        REGEXP_REPLACE (TRIM(D1_CONHEC ) ,'[[:cntrl:];"]')D1_CONHEC ,
        D1_CUSFF1 ,
        D1_CUSFF2 ,
        D1_CUSFF3 ,
        D1_CUSFF4 ,
        D1_CUSFF5 ,
        REGEXP_REPLACE (TRIM(D1_CODCIAP) ,'[[:cntrl:];"]')D1_CODCIAP,
        D1_BASIMP1,
        D1_BASIMP4,
        D1_BASIMP3,
        D1_CUSTO  ,
        D1_CIF    ,
        REGEXP_REPLACE (TRIM(D1_ITEMREM) ,'[[:cntrl:];"]')D1_ITEMREM,
        D1_BASIMP5,
        REGEXP_REPLACE (TRIM(D1_TIPO_NF) ,'[[:cntrl:];"]')D1_TIPO_NF,
        D1_BASIMP6,
        D1_VALIMP1,
        D1_VALIMP2,
        D1_VALIMP3,
        D1_VALIMP4,
        D1_VALIMP5,
        D1_VALIMP6,
        REGEXP_REPLACE (TRIM(D1_CBASEAF) ,'[[:cntrl:];"]')D1_CBASEAF,
        D1_ICMSCOM,
        D1_BASIMP2,
        D1_ALQIMP1,
        D1_ALQIMP2,
        D1_ALQIMP3,
        D1_ALQIMP4,
        D1_ALQIMP5,
        D1_ALQIMP6,
        D1_VALFRE ,
        D1_QTDPEDI,
        REGEXP_REPLACE (TRIM(D1_RATEIO ) ,'[[:cntrl:];"]')D1_RATEIO ,
        D1_SEGURO ,
        D1_CUSORI ,
        D1_DESPESA,
        D1_BASEIRR,
        D1_VALIRR ,
        D1_BASEISS,
        D1_VALISS ,
        D1_BASEINS,
        D1_VALINS ,
        REGEXP_REPLACE (TRIM(D1_LOCPAD ) ,'[[:cntrl:];"]')D1_LOCPAD ,
        REGEXP_REPLACE (TRIM(D1_CLVL   ) ,'[[:cntrl:];"]')D1_CLVL   ,
        REGEXP_REPLACE (TRIM(D1_ORDEM  ) ,'[[:cntrl:];"]')D1_ORDEM  ,
        REGEXP_REPLACE (TRIM(D1_SERVIC ) ,'[[:cntrl:];"]')D1_SERVIC ,
        REGEXP_REPLACE (TRIM(D1_STSERV ) ,'[[:cntrl:];"]')D1_STSERV ,
        REGEXP_REPLACE (TRIM(D1_TIPODOC) ,'[[:cntrl:];"]')D1_TIPODOC,
        REGEXP_REPLACE (TRIM(D1_ENDER  ) ,'[[:cntrl:];"]')D1_ENDER  ,
        REGEXP_REPLACE (TRIM(D1_PCCENTR) ,'[[:cntrl:];"]')D1_PCCENTR,
        REGEXP_REPLACE (TRIM(D1_REGWMS ) ,'[[:cntrl:];"]')D1_REGWMS ,
        REGEXP_REPLACE (TRIM(D1_GRADE  ) ,'[[:cntrl:];"]')D1_GRADE  ,
        REGEXP_REPLACE (TRIM(D1_ITEMGRD) ,'[[:cntrl:];"]')D1_ITEMGRD,
        REGEXP_REPLACE (TRIM(D1_ITPCCEN) ,'[[:cntrl:];"]')D1_ITPCCEN,
        D1_QTPCCEN,
        D1_CRDZFM ,
        D1_VALFET ,
        D1_AVLINSS,
        D1_BASEFET,
        D1_POTENCI,
        REGEXP_REPLACE (TRIM(D1_CODISS ) ,'[[:cntrl:];"]')D1_CODISS ,
        D1_ALIQCF3,
        REGEXP_REPLACE (TRIM(D1_CFPS   ) ,'[[:cntrl:];"]')D1_CFPS   ,
        REGEXP_REPLACE (TRIM(D1_TRT    ) ,'[[:cntrl:];"]')D1_TRT    ,
        REGEXP_REPLACE (TRIM(D1_TESACLA) ,'[[:cntrl:];"]')D1_TESACLA,
        REGEXP_REPLACE (TRIM(D1_NUMDESP) ,'[[:cntrl:];"]')D1_NUMDESP,
        D1_ALIQFAB,
        REGEXP_REPLACE (TRIM(D1_ORIGEM ) ,'[[:cntrl:];"]')D1_ORIGEM ,
        D1_DESCICM,
        REGEXP_REPLACE (TRIM(D1_ITMVINC) ,'[[:cntrl:];"]')D1_ITMVINC,
        D1_BASEPS3,
        D1_BASEFAC,
        D1_ALIQPS3,
        D1_BASECSL,
        REGEXP_REPLACE (TRIM(D1_GRUPONC) ,'[[:cntrl:];"]')D1_GRUPONC,
        D1_DFABRIC,
        D1_VALCF3 ,
        D1_ABATMAT,
        REGEXP_REPLACE (TRIM(D1_NFVINC ) ,'[[:cntrl:];"]')D1_NFVINC ,
        D1_VALFAB ,
        D1_BASEFAB,
        D1_ESTCRED,
        D1_VALCOF ,
        D1_VALACRS,
        D1_BASECF3,
        D1_PRUNDA ,
        D1_ALIQFAC,
        REGEXP_REPLACE (TRIM(D1_TNATREC) ,'[[:cntrl:];"]')D1_TNATREC,
        D1_BASECOF,
        D1_QTDCONF,
        D1_VALPS3 ,
        D1_ABATISS,
        D1_MARGEM ,
        D1_ICMSDIF,
        D1_SLDDEP ,
        D1_ALIQFET,
        D1_CRPRSIM,
        D1_VALFAC ,
        D1_VALANTI,
        D1_ALIQSOL,
        D1_BASEPIS,
        REGEXP_REPLACE (TRIM(D1_SERVINC) ,'[[:cntrl:];"]')D1_SERVINC,
        D1_DTFIMNT,
        REGEXP_REPLACE (TRIM(D1_CNATREC) ,'[[:cntrl:];"]')D1_CNATREC,
        REGEXP_REPLACE (TRIM(D1_CODLAN ) ,'[[:cntrl:];"]')D1_CODLAN ,
        REGEXP_REPLACE (TRIM(D1_CONBAR ) ,'[[:cntrl:];"]')D1_CONBAR ,
        D1_PRFDSUL,
        D1_CRPREPR,
        D1_ICMNDES,
        D1_VALFUN ,
        D1_ALIQII ,
        REGEXP_REPLACE (TRIM(D1_TRANSIT) ,'[[:cntrl:];"]')D1_TRANSIT,
        REGEXP_REPLACE (TRIM(D1_GARANTI) ,'[[:cntrl:];"]')D1_GARANTI,
        D1_BASEFUN,
        D1_CUSRP4 ,
        D1_BASESES,
        D1_ALQCSL ,
        D1_CRPRESC,
        D1_VALPIS ,
        D1_CUSRP1 ,
        D1_ALQPIS ,
        REGEXP_REPLACE (TRIM(D1_CODBAIX) ,'[[:cntrl:];"]')D1_CODBAIX,
        REGEXP_REPLACE (TRIM(D1_OPERADO) ,'[[:cntrl:];"]')D1_OPERADO,
        D1_VALCSL ,
        D1_BASNDES,
        D1_CUSRP5 ,
        REGEXP_REPLACE (TRIM(D1_RGESPST) ,'[[:cntrl:];"]')D1_RGESPST,
        D1_VALSES ,
        D1_ALQCOF ,
        D1_VALFDS ,
        D1_VLINCMG,
        D1_PRINCMG,
        D1_ABATINS,
        D1_VALINA ,
        D1_VALCMAJ,
        REGEXP_REPLACE (TRIM(D1_OKISS  ) ,'[[:cntrl:];"]')D1_OKISS  ,
        D1_BASEINA,
        D1_ALIQINA,
        D1_ALIQFUN,
        D1_CUSRP2 ,
        D1_UFERMS ,
        D1_ALIQSES,
        D1_CUSRP3 ,
        D1_VALPMAJ,
        D1_CONIMP ,
        REGEXP_REPLACE (TRIM(D1_XQUALIF) ,'[[:cntrl:];"]')D1_XQUALIF,
        REGEXP_REPLACE (TRIM(D1_XTONAL ) ,'[[:cntrl:];"]')D1_XTONAL ,
        REGEXP_REPLACE (TRIM(D1_XBITOLA) ,'[[:cntrl:];"]')D1_XBITOLA,
        REGEXP_REPLACE (TRIM(D1_PROJ   ) ,'[[:cntrl:];"]')D1_PROJ   ,
        D1_XCONFER,
        REGEXP_REPLACE (TRIM(D1_CODFIS ) ,'[[:cntrl:];"]')D1_CODFIS ,
        REGEXP_REPLACE (TRIM(D1_IDSB5  ) ,'[[:cntrl:];"]')D1_IDSB5  ,
        REGEXP_REPLACE (TRIM(D1_IDSB1  ) ,'[[:cntrl:];"]')D1_IDSB1  ,
        REGEXP_REPLACE (TRIM(D1_IDSBZ  ) ,'[[:cntrl:];"]')D1_IDSBZ  ,
        D1_ALSENAR,
        D1_BSSENAR,
        REGEXP_REPLACE (TRIM(D1_FCICOD ) ,'[[:cntrl:];"]')D1_FCICOD ,
        D1_VLSENAR,
        REGEXP_REPLACE (TRIM(D1_IDSF7  ) ,'[[:cntrl:];"]')D1_IDSF7  ,
        REGEXP_REPLACE (TRIM(D1_IDSF4  ) ,'[[:cntrl:];"]')D1_IDSF4  ,
        REGEXP_REPLACE (TRIM(D1_FILORI ) ,'[[:cntrl:];"]')D1_FILORI ,
        REGEXP_REPLACE (TRIM(D1_USERLGI) ,'[[:cntrl:];"]')D1_USERLGI,
        REGEXP_REPLACE (TRIM(D1_USERLGA) ,'[[:cntrl:];"]')D1_USERLGA,
        REGEXP_REPLACE (TRIM(D1_IDCFC  ) ,'[[:cntrl:];"]')D1_IDCFC  ,
        REGEXP_REPLACE (TRIM(D1_REVISAO) ,'[[:cntrl:];"]')D1_REVISAO,
        REGEXP_REPLACE (TRIM(D1_XURGEN ) ,'[[:cntrl:];"]')D1_XURGEN ,
        D1_VLCIDE ,
        D1_BASECID,
        D1_ALQCIDE,
        D1_VALCPM ,
        D1_BASECPM,
        D1_ALQCPM ,
        D1_ALQFMD ,
        D1_VALFMP ,
        D1_BASEFMP,
        D1_ALQFMP ,
        D1_BASEFMD,
        D1_VALFMD ,
        REGEXP_REPLACE (TRIM(D1_DCIPSC ) ,'[[:cntrl:];"]')D1_DCIPSC ,
        REGEXP_REPLACE (TRIM(D1_XDIGIMP) ,'[[:cntrl:];"]')D1_XDIGIMP,
        D1_DESCZFR,
        D1_DESCZFP,
        D1_DESCZFC,
        REGEXP_REPLACE (TRIM(D1_GRPCST ) ,'[[:cntrl:];"]')D1_GRPCST ,
        D1_BASECPB,
        D1_VALCPB ,
        D1_ALIQCPB,
        D1_DIFAL  ,
        D1_PDORI  ,
        D1_PDDES  ,
        D1_ALFCCMP,
        D1_ALIQCMP,
        D1_BASEDES,
        D1_VFCPDIF,
        REGEXP_REPLACE (TRIM(D1_XJSTPCO) ,'[[:cntrl:];"]')D1_XJSTPCO,
        D1_FTRICMS,
        D1_VRDICMS,
        D1_VALFUND,
        D1_BASFUND,
        D1_ALIFUND,
        D1_VALIMA ,
        D1_BASIMA ,
        D1_ALIIMA ,
        D1_VALFASE,
        D1_BASFASE,
        D1_ALIFASE,
        D1_VLSLXML,
        REGEXP_REPLACE (TRIM(D1_CSOSN  ) ,'[[:cntrl:];"]')D1_CSOSN  ,
        D1_CP0101 ,
        D1_CP0201 ,
        D1_CP0301 ,
        D1_CP0401 ,
        D1_CP0501 ,
        D1_CP0601 ,
        D1_CP0701 ,
        D1_CP0801 ,
        D1_CP0901 ,
        D1_CP1001 ,
        D1_CP1101 ,
        D1_CP1201 ,
        D1_CP1301 ,
        D1_CP1401 ,
        D1_CP1501 ,
        D1_CP1601 ,
        D1_CP1701 ,
        D1_CP1801 ,
        D1_CP1901 ,
        D1_CP2001 ,
        D1_CP2101 ,
        D1_CP2201 ,
        D1_CP2301 ,
        D1_CP2401 ,
        D1_CP2501 ,
        D1_CP2601 ,
        D1_CP2701 ,
        D1_CP2801 ,
        D1_CP2901 ,
        D1_BASEINP,
        D1_PERCINP,
        D1_VALINP ,
        D1_ALQFECP,
        D1_VALFECP,
        D1_VFECPST,
        REGEXP_REPLACE (TRIM(D1_CODNOR ) ,'[[:cntrl:];"]')D1_CODNOR ,
        D1_XZDDSLD,
        D1_ALFCPST,
        D1_VOPDIF ,
        D1_AFCPANT,
        D1_ALQNDES,
        D1_BFCPANT,
        D1_VFCPANT,
        REGEXP_REPLACE (TRIM(D1_CNO    ) ,'[[:cntrl:];"]')D1_CNO    ,
        REGEXP_REPLACE (TRIM(D1_ORDDIA ) ,'[[:cntrl:];"]')D1_ORDDIA ,
        REGEXP_REPLACE (TRIM(D1_NRECAGR) ,'[[:cntrl:];"]')D1_NRECAGR,
        REGEXP_REPLACE (TRIM(D1_FILEDT ) ,'[[:cntrl:];"]')D1_FILEDT ,
        REGEXP_REPLACE (TRIM(D1_TESDES ) ,'[[:cntrl:];"]')D1_TESDES ,
        REGEXP_REPLACE (TRIM(D1_TPESTR ) ,'[[:cntrl:];"]')D1_TPESTR ,
        REGEXP_REPLACE (TRIM(D1_TRIBMUN) ,'[[:cntrl:];"]')D1_TRIBMUN,
        D1_ABATALM,
        D1_ABATTRA,
        REGEXP_REPLACE (TRIM(D1_CODDIS ) ,'[[:cntrl:];"]')D1_CODDIS ,
        REGEXP_REPLACE (TRIM(D1_IDDCF  ) ,'[[:cntrl:];"]')D1_IDDCF  ,
        D1_ALQFEEF,
        REGEXP_REPLACE (TRIM(D1_CODNE  ) ,'[[:cntrl:];"]')D1_CODNE  ,
        REGEXP_REPLACE (TRIM(D1_ITEMNE ) ,'[[:cntrl:];"]')D1_ITEMNE ,
        D1_EXPSOP ,
        D1_VALPRO ,
        REGEXP_REPLACE (TRIM(D1_ALMTERC) ,'[[:cntrl:];"]')D1_ALMTERC,
        REGEXP_REPLACE (TRIM(D1_SDOCVNC) ,'[[:cntrl:];"]')D1_SDOCVNC,
        REGEXP_REPLACE (TRIM(D1_SDOCREM) ,'[[:cntrl:];"]')D1_SDOCREM,
        REGEXP_REPLACE (TRIM(D1_SDOC   ) ,'[[:cntrl:];"]')D1_SDOC   ,
        REGEXP_REPLACE (TRIM(D1_SDOCORI) ,'[[:cntrl:];"]')D1_SDOCORI,
        D1_BASEPRO,
        D1_ALIQPRO,
        REGEXP_REPLACE (TRIM(D1_NUMPED ) ,'[[:cntrl:];"]')D1_NUMPED ,
        D1_SLDEXP ,
        REGEXP_REPLACE (TRIM(D1_CODROM ) ,'[[:cntrl:];"]')D1_CODROM ,
        REGEXP_REPLACE (TRIM(D1_NFPNUM ) ,'[[:cntrl:];"]')D1_NFPNUM ,
        REGEXP_REPLACE (TRIM(D1_CTROG  ) ,'[[:cntrl:];"]')D1_CTROG  ,
        REGEXP_REPLACE (TRIM(D1_CODSAF ) ,'[[:cntrl:];"]')D1_CODSAF ,
        REGEXP_REPLACE (TRIM(D1_NFPSER ) ,'[[:cntrl:];"]')D1_NFPSER ,
        REGEXP_REPLACE (TRIM(D1_ITEROM ) ,'[[:cntrl:];"]')D1_ITEROM ,
        D1_BASFECP,
        D1_BSFCCMP,
        D1_FCPAUX ,
        D1_BSFCPST,
        REGEXP_REPLACE (TRIM(D1_IDTRIB ) ,'[[:cntrl:];"]')D1_IDTRIB ,
        D1_FATDIRE,
        D1_DEDUCAO,
        D1_RETENCA,
        REGEXP_REPLACE (TRIM(D1_CTAREC ) ,'[[:cntrl:];"]')D1_CTAREC ,
        REGEXP_REPLACE (TRIM(D1_MSEXP  ) ,'[[:cntrl:];"]')D1_MSEXP  ,
        REGEXP_REPLACE (TRIM(D1_HREXPO ) ,'[[:cntrl:];"]')D1_HREXPO ,
        D1_VRETSUB,
        D1_BASFEEF,
        D1_VALFEEF,
        REGEXP_REPLACE (TRIM(D1_TPREPAS) ,'[[:cntrl:];"]')D1_TPREPAS,
        REGEXP_REPLACE (TRIM(F1_FILIAL ) ,'[[:cntrl:];"]')F1_FILIAL ,
        REGEXP_REPLACE (TRIM(F1_DOC    ) ,'[[:cntrl:];"]')F1_DOC    ,
        REGEXP_REPLACE (TRIM(F1_SERIE  ) ,'[[:cntrl:];"]')F1_SERIE  ,
        REGEXP_REPLACE (TRIM(F1_FORNECE) ,'[[:cntrl:];"]')F1_FORNECE,
        REGEXP_REPLACE (TRIM(F1_LOJA   ) ,'[[:cntrl:];"]')F1_LOJA   ,
        REGEXP_REPLACE (TRIM(F1_COND   ) ,'[[:cntrl:];"]')F1_COND   ,
        REGEXP_REPLACE (TRIM(F1_DUPL   ) ,'[[:cntrl:];"]')F1_DUPL   ,
        F1_EMISSAO,
        REGEXP_REPLACE (TRIM(F1_EST    ) ,'[[:cntrl:];"]')F1_EST    ,
        F1_FRETE  ,
        F1_DESPESA,
        F1_BASEICM,
        F1_VALICM ,
        F1_BASEIPI,
        F1_VALIPI ,
        F1_VALMERC,
        F1_VALBRUT,
        REGEXP_REPLACE (TRIM(F1_TIPO   ) ,'[[:cntrl:];"]')F1_TIPO   ,
        F1_DESCONT,
        F1_DTDIGIT,
        REGEXP_REPLACE (TRIM(F1_XNOMEFO) ,'[[:cntrl:];"]')F1_XNOMEFO,
        REGEXP_REPLACE (TRIM(F1_XNOMFOR) ,'[[:cntrl:];"]')F1_XNOMFOR,
        REGEXP_REPLACE (TRIM(F1_CPROVA ) ,'[[:cntrl:];"]')F1_CPROVA ,
        F1_BRICMS ,
        F1_ICMSRET,
        F1_BASEFD ,
        F1_DTLANC ,
        F1_CONTSOC,
        REGEXP_REPLACE (TRIM(F1_OK     ) ,'[[:cntrl:];"]')F1_OK     ,
        REGEXP_REPLACE (TRIM(F1_FORMUL ) ,'[[:cntrl:];"]')F1_FORMUL ,
        REGEXP_REPLACE (TRIM(F1_NFORIG ) ,'[[:cntrl:];"]')F1_NFORIG ,
        REGEXP_REPLACE (TRIM(F1_SERORIG) ,'[[:cntrl:];"]')F1_SERORIG,
        REGEXP_REPLACE (TRIM(F1_ORIGLAN) ,'[[:cntrl:];"]')F1_ORIGLAN,
        REGEXP_REPLACE (TRIM(F1_TX     ) ,'[[:cntrl:];"]')F1_TX     ,
        F1_II     ,
        REGEXP_REPLACE (TRIM(F1_REMITO ) ,'[[:cntrl:];"]')F1_REMITO ,
        F1_BASIMP2,
        F1_BASIMP3,
        F1_BASIMP4,
        F1_BASIMP5,
        F1_BASIMP6,
        F1_VALIMP1,
        F1_VALIMP2,
        F1_VALIMP3,
        F1_VALIMP4,
        F1_VALIMP5,
        F1_VALIMP6,
        REGEXP_REPLACE (TRIM(F1_ORDPAGO) ,'[[:cntrl:];"]')F1_ORDPAGO,
        F1_IRRF   ,
        REGEXP_REPLACE (TRIM(F1_ESPECIE) ,'[[:cntrl:];"]')F1_ESPECIE,
        REGEXP_REPLACE (TRIM(F1_IMPORT ) ,'[[:cntrl:];"]')F1_IMPORT ,
        F1_BASIMP1,
        REGEXP_REPLACE (TRIM(F1_HORA   ) ,'[[:cntrl:];"]')F1_HORA   ,
        REGEXP_REPLACE (TRIM(F1_TIPO_NF) ,'[[:cntrl:];"]')F1_TIPO_NF,
        F1_INSS   ,
        F1_ISS    ,
        REGEXP_REPLACE (TRIM(F1_HAWB   ) ,'[[:cntrl:];"]')F1_HAWB   ,
        F1_FOB_R  ,
        F1_SEGURO ,
        F1_CIF    ,
        F1_IPI    ,
        F1_ICMS   ,
        F1_PESOL  ,
        F1_VALEMB ,
        F1_MOEDA  ,
        REGEXP_REPLACE (TRIM(F1_CTR_NFC) ,'[[:cntrl:];"]')F1_CTR_NFC,
        REGEXP_REPLACE (TRIM(F1_PREFIXO) ,'[[:cntrl:];"]')F1_PREFIXO,
        F1_TXMOEDA,
        REGEXP_REPLACE (TRIM(F1_PEDVEND) ,'[[:cntrl:];"]')F1_PEDVEND,
        REGEXP_REPLACE (TRIM(F1_TIPODOC) ,'[[:cntrl:];"]')F1_TIPODOC,
        REGEXP_REPLACE (TRIM(F1_STATUS ) ,'[[:cntrl:];"]')F1_STATUS ,
        F1_RECBMTO,
        REGEXP_REPLACE (TRIM(F1_APROV  ) ,'[[:cntrl:];"]')F1_APROV  ,
        REGEXP_REPLACE (TRIM(F1_TIPOREM) ,'[[:cntrl:];"]')F1_TIPOREM,
        REGEXP_REPLACE (TRIM(F1_GNR    ) ,'[[:cntrl:];"]')F1_GNR    ,
        REGEXP_REPLACE (TRIM(F1_PLACA  ) ,'[[:cntrl:];"]')F1_PLACA  ,
        F1_BASEPS3,
        F1_VALPS3 ,
        F1_BASECF3,
        F1_VALCF3 ,
        F1_VALPIS ,
        F1_EMINFE ,
        REGEXP_REPLACE (TRIM(F1_HORNFE ) ,'[[:cntrl:];"]')F1_HORNFE ,
        REGEXP_REPLACE (TRIM(F1_CODNFE ) ,'[[:cntrl:];"]')F1_CODNFE ,
        F1_CREDNFE,
        F1_VNAGREG,
        REGEXP_REPLACE (TRIM(F1_NUMRPS ) ,'[[:cntrl:];"]')F1_NUMRPS ,
        F1_VALCOFI,
        F1_VALCSLL,
        REGEXP_REPLACE (TRIM(F1_NFELETR) ,'[[:cntrl:];"]')F1_NFELETR,
        F1_VALIRF ,
        REGEXP_REPLACE (TRIM(F1_FILORIG) ,'[[:cntrl:];"]')F1_FILORIG,
        REGEXP_REPLACE (TRIM(F1_NUMMOV ) ,'[[:cntrl:];"]')F1_NUMMOV ,
        REGEXP_REPLACE (TRIM(F1_NODIA  ) ,'[[:cntrl:];"]')F1_NODIA  ,
        REGEXP_REPLACE (TRIM(F1_DIACTB ) ,'[[:cntrl:];"]')F1_DIACTB ,
        REGEXP_REPLACE (TRIM(F1_CHVNFE ) ,'[[:cntrl:];"]')F1_CHVNFE ,
        REGEXP_REPLACE (TRIM(F1_RECISS ) ,'[[:cntrl:];"]')F1_RECISS ,
        F1_VALFDS ,
        F1_ESTCRED,
        REGEXP_REPLACE (TRIM(F1_NUMRA  ) ,'[[:cntrl:];"]')F1_NUMRA  ,
        F1_BASEINS,
        REGEXP_REPLACE (TRIM(F1_TRANSP ) ,'[[:cntrl:];"]')F1_TRANSP ,
        F1_PLIQUI ,
        F1_PBRUTO ,
        REGEXP_REPLACE (TRIM(F1_ESPECI1) ,'[[:cntrl:];"]')F1_ESPECI1,
        F1_VOLUME1,
        REGEXP_REPLACE (TRIM(F1_ESPECI2) ,'[[:cntrl:];"]')F1_ESPECI2,
        F1_VOLUME2,
        REGEXP_REPLACE (TRIM(F1_ESPECI3) ,'[[:cntrl:];"]')F1_ESPECI3,
        F1_VALFAC ,
        REGEXP_REPLACE (TRIM(F1_RECOPI ) ,'[[:cntrl:];"]')F1_RECOPI ,
        F1_VALPEDG,
        REGEXP_REPLACE (TRIM(F1_FORRET ) ,'[[:cntrl:];"]')F1_FORRET ,
        F1_VALFET ,
        F1_VOLUME3,
        REGEXP_REPLACE (TRIM(F1_ESPECI4) ,'[[:cntrl:];"]')F1_ESPECI4,
        F1_VALFAB ,
        REGEXP_REPLACE (TRIM(F1_LOJARET) ,'[[:cntrl:];"]')F1_LOJARET,
        F1_BASCSLL,
        F1_BASPIS ,
        F1_VOLUME4,
        REGEXP_REPLACE (TRIM(F1_DOCFOL ) ,'[[:cntrl:];"]')F1_DOCFOL ,
        REGEXP_REPLACE (TRIM(F1_MENNOTA) ,'[[:cntrl:];"]')F1_MENNOTA,
        REGEXP_REPLACE (TRIM(F1_FIMP   ) ,'[[:cntrl:];"]')F1_FIMP   ,
        REGEXP_REPLACE (TRIM(F1_STATCON) ,'[[:cntrl:];"]')F1_STATCON,
        REGEXP_REPLACE (TRIM(F1_MSIDENT) ,'[[:cntrl:];"]')F1_MSIDENT,
        F1_BASCOFI,
        REGEXP_REPLACE (TRIM(F1_VERBAFO) ,'[[:cntrl:];"]')F1_VERBAFO,
        F1_BASEFUN,
        REGEXP_REPLACE (TRIM(F1_NUMTRIB) ,'[[:cntrl:];"]')F1_NUMTRIB,
        REGEXP_REPLACE (TRIM(F1_TPCTE  ) ,'[[:cntrl:];"]')F1_TPCTE  ,
        F1_VALINA ,
        F1_BASEINA,
        REGEXP_REPLACE (TRIM(F1_EVENFLG) ,'[[:cntrl:];"]')F1_EVENFLG,
        REGEXP_REPLACE (TRIM(F1_IDCCE  ) ,'[[:cntrl:];"]')F1_IDCCE  ,
        REGEXP_REPLACE (TRIM(F1_FLAGRGS) ,'[[:cntrl:];"]')F1_FLAGRGS,
        REGEXP_REPLACE (TRIM(F1_IDRGS  ) ,'[[:cntrl:];"]')F1_IDRGS  ,
        REGEXP_REPLACE (TRIM(F1_CODRGS ) ,'[[:cntrl:];"]')F1_CODRGS ,
        F1_DAUTNFE,
        REGEXP_REPLACE (TRIM(F1_HAUTNFE) ,'[[:cntrl:];"]')F1_HAUTNFE,
        REGEXP_REPLACE (TRIM(F1_MENPAD ) ,'[[:cntrl:];"]')F1_MENPAD ,
        REGEXP_REPLACE (TRIM(F1_FORENT ) ,'[[:cntrl:];"]')F1_FORENT ,
        REGEXP_REPLACE (TRIM(F1_LOJAENT) ,'[[:cntrl:];"]')F1_LOJAENT,
        REGEXP_REPLACE (TRIM(F1_TPFRETE) ,'[[:cntrl:];"]')F1_TPFRETE,
        F1_QTDCONF,
        REGEXP_REPLACE (TRIM(F1_TPNFEXP) ,'[[:cntrl:];"]')F1_TPNFEXP,
        REGEXP_REPLACE (TRIM(F1_INCISS ) ,'[[:cntrl:];"]')F1_INCISS ,
        REGEXP_REPLACE (TRIM(F1_ESTPRES) ,'[[:cntrl:];"]')F1_ESTPRES,
        REGEXP_REPLACE (TRIM(F1_LOJAORI) ,'[[:cntrl:];"]')F1_LOJAORI,
        REGEXP_REPLACE (TRIM(F1_CLIORI ) ,'[[:cntrl:];"]')F1_CLIORI ,
        REGEXP_REPLACE (TRIM(F1_ANOAIDF) ,'[[:cntrl:];"]')F1_ANOAIDF,
        REGEXP_REPLACE (TRIM(F1_NUMAIDF) ,'[[:cntrl:];"]')F1_NUMAIDF,
        F1_VLSENAR,
        REGEXP_REPLACE (TRIM(F1_IDSED  ) ,'[[:cntrl:];"]')F1_IDSED  ,
        REGEXP_REPLACE (TRIM(F1_IDSA2  ) ,'[[:cntrl:];"]')F1_IDSA2  ,
        REGEXP_REPLACE (TRIM(F1_IDSA1  ) ,'[[:cntrl:];"]')F1_IDSA1  ,
        REGEXP_REPLACE (TRIM(F1_XSTCONF) ,'[[:cntrl:];"]')F1_XSTCONF,
        F1_VLCIDE ,
        F1_BASECID,
        REGEXP_REPLACE (TRIM(F1_USERLGI) ,'[[:cntrl:];"]')F1_USERLGI,
        REGEXP_REPLACE (TRIM(F1_USERLGA) ,'[[:cntrl:];"]')F1_USERLGA,
        REGEXP_REPLACE (TRIM(F1_IDRECOP) ,'[[:cntrl:];"]')F1_IDRECOP,
        F1_VLCPM  ,
        F1_BASECPM,
        F1_VALFMP ,
        F1_BASEFMP,
        F1_VALFMD ,
        REGEXP_REPLACE (TRIM(F1_MODAL  ) ,'[[:cntrl:];"]')F1_MODAL  ,
        REGEXP_REPLACE (TRIM(F1_XDIGIMP) ,'[[:cntrl:];"]')F1_XDIGIMP,
        REGEXP_REPLACE (TRIM(F1_VEICUL1) ,'[[:cntrl:];"]')F1_VEICUL1,
        REGEXP_REPLACE (TRIM(F1_VEICUL2) ,'[[:cntrl:];"]')F1_VEICUL2,
        REGEXP_REPLACE (TRIM(F1_VEICUL3) ,'[[:cntrl:];"]')F1_VEICUL3,
        REGEXP_REPLACE (TRIM(F1_SERMDF ) ,'[[:cntrl:];"]')F1_SERMDF ,
        REGEXP_REPLACE (TRIM(F1_NUMMDF ) ,'[[:cntrl:];"]')F1_NUMMDF ,
        F1_DTCPISS,
        REGEXP_REPLACE (TRIM(F1_XBONMES) ,'[[:cntrl:];"]')F1_XBONMES,
        REGEXP_REPLACE (TRIM(F1_CLIDEST) ,'[[:cntrl:];"]')F1_CLIDEST,
        REGEXP_REPLACE (TRIM(F1_LOJDEST) ,'[[:cntrl:];"]')F1_LOJDEST,
        REGEXP_REPLACE (TRIM(F1_ESTDES ) ,'[[:cntrl:];"]')F1_ESTDES ,
        F1_VALFUND,
        F1_VALIMA ,
        F1_VALFASE,
        REGEXP_REPLACE (TRIM(F1_XBONTRI) ,'[[:cntrl:];"]')F1_XBONTRI,
        F1_XFRTEN ,
        REGEXP_REPLACE (TRIM(F1_XNRROM ) ,'[[:cntrl:];"]')F1_XNRROM ,
        REGEXP_REPLACE (TRIM(F1_DOCISEN) ,'[[:cntrl:];"]')F1_DOCISEN,
        REGEXP_REPLACE (TRIM(F1_ORIGEM ) ,'[[:cntrl:];"]')F1_ORIGEM ,
        REGEXP_REPLACE (TRIM(F1_MOTIVO ) ,'[[:cntrl:];"]')F1_MOTIVO ,
        REGEXP_REPLACE (TRIM(F1_VERBAIS) ,'[[:cntrl:];"]')F1_VERBAIS,
        REGEXP_REPLACE (TRIM(F1_SIMPNAC) ,'[[:cntrl:];"]')F1_SIMPNAC,
        REGEXP_REPLACE (TRIM(F1_TPCOMPL) ,'[[:cntrl:];"]')F1_TPCOMPL,
        REGEXP_REPLACE (TRIM(F1_BOMDES ) ,'[[:cntrl:];"]')F1_BOMDES ,
        REGEXP_REPLACE (TRIM(F1_DEVMERC) ,'[[:cntrl:];"]')F1_DEVMERC,
        REGEXP_REPLACE (TRIM(F1_MOTRET ) ,'[[:cntrl:];"]')F1_MOTRET ,
        REGEXP_REPLACE (TRIM(F1_SDOC   ) ,'[[:cntrl:];"]')F1_SDOC   ,
        REGEXP_REPLACE (TRIM(F1_SDOCORI) ,'[[:cntrl:];"]')F1_SDOCORI,
        replace(regexp_replace(TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(F1_HISTRET,250,1))),'[[:cntrl:];"]'),chr(13))F1_HISTRET,
        REGEXP_REPLACE (TRIM(F1_MUORITR) ,'[[:cntrl:];"]')F1_MUORITR,
        REGEXP_REPLACE (TRIM(F1_MUDESTR) ,'[[:cntrl:];"]')F1_MUDESTR,
        REGEXP_REPLACE (TRIM(F1_UFDESTR) ,'[[:cntrl:];"]')F1_UFDESTR,
        REGEXP_REPLACE (TRIM(F1_UFORITR) ,'[[:cntrl:];"]')F1_UFORITR,
        REGEXP_REPLACE (TRIM(F1_SDOCMAN) ,'[[:cntrl:];"]')F1_SDOCMAN,
        REGEXP_REPLACE (TRIM(F1_CODROM ) ,'[[:cntrl:];"]')F1_CODROM ,
        F1_BFCPANT,
        F1_VFCPANT,
        F1_BASFECP,
        F1_BSFCPST,
        F1_BSFCCMP,
        REGEXP_REPLACE (TRIM(F1_SUBSERI) ,'[[:cntrl:];"]')F1_SUBSERI,
        REGEXP_REPLACE (TRIM(F1_IDNF   ) ,'[[:cntrl:];"]')F1_IDNF   ,
        REGEXP_REPLACE (TRIM(F1_CODA1U ) ,'[[:cntrl:];"]')F1_CODA1U ,
        REGEXP_REPLACE (TRIM(F1_INDPRES) ,'[[:cntrl:];"]')F1_INDPRES,
        REGEXP_REPLACE (TRIM(F1_IDDES  ) ,'[[:cntrl:];"]')F1_IDDES  ,
        replace(regexp_replace(TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(F1_OBSDES ,250,1))),'[[:cntrl:];"]'),chr(13)) F1_OBSDES ,
        REGEXP_REPLACE (TRIM(F1_CLIPROP) ,'[[:cntrl:];"]')F1_CLIPROP,
        REGEXP_REPLACE (TRIM(F1_LJCLIPR) ,'[[:cntrl:];"]')F1_LJCLIPR,
        REGEXP_REPLACE (TRIM(F1_XCXNFE ) ,'[[:cntrl:];"]')F1_XCXNFE ,
        CT1_DESC01,
        CTT_DESC01,
        NNR_DESCRI,
        A1_NOME   ,
        A2_NOME   ,
        A4_NOME   ,
        BM_DESC   ,
        E4_DESCRI ,
        F4_DUPLIC ,
        F4_ESTOQUE,
        F4_FINALID,
        X5_DESCRI 

    from %table:SF1% F1
    left join %table:sd1% SD1 ON F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND F1_SERIE = D1_SERIE AND F1_EMISSAO = D1_EMISSAO AND sd1.%notdel%
    left join %table:ctt% ctt on d1_filial = ctt_filial and d1_cc = ctt_custo AND ctt.%notdel%
    left join %table:sf4% sf4 on d1_filial = f4_filial and d1_tes = f4_codigo AND sf4.%notdel%
    left join %table:sa2% sa2 on f1_fornece = a2_cod and f1_loja = a2_loja AND sa2.%notdel%
    left join %table:ct1% ct1 on d1_conta = ct1_conta AND ct1.%notdel%
    left join %table:nnr% nnr on d1_local = nnr_codigo and trim(substr(d1_filial,1,4)) = trim(nnr_filial) AND nnr.%notdel%
    left join %table:sbm% sbm on d1_grupo = bm_grupo AND sbm.%notdel%
    left join %table:se4% se4 on TRIM(SUBSTR(F1_FILIAL,1,2)) = TRIM(E4_FILIAL) AND F1_COND = E4_CODIGO AND se4.%notdel%
    LEFT JOIN %table:SX5% SX5 ON F1_ESPECIE = X5_CHAVE AND X5_TABELA = '42' AND sx5.%notdel%
    left join %table:sa4% sa4 on f1_transp = a4_cod AND sa4.%notdel%
    left join %table:sa1% sa1 on f1_clidest = a1_cod and F1_LOJDEST = a1_loja and sa1.%notdel%

    WHERE F1_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND F1_DTDIGIT BETWEEN %Exp:DTOS(MV_PAR03)% AND %Exp:DTOS(MV_PAR04)% AND F1.%notdel%
        AND F1.%notdel%
    
    //and rownum<101

    ORDER BY F1_DTDIGIT

EndSql

_cQuery:=GetLastQuery()

_aStru:=DBSTRUCT()

DBGOTOP()

IF!Eof()

    HTMLMAIL()

    _nDemiss:=0
    _cEmissD    :=F1_DTDIGIT
    _cEmissA    :=F1_DTDIGIT
    _cEmissAn   :=F1_DTDIGIT

    Whil!Eof()

        If F1_DTDIGIT<>_cEmissA
            _nDemiss    ++
            _cEmissAn   :=_cEmissA
            _cEmissA    :=F1_DTDIGIT
        END

        IF _nDemiss==0 .Or. _nDemiss>_nNfdias

            If _nDemiss>_nNfdias

                _cNarquivo:=_cTabela+"_"+_cEmissD+"_"+_cEmissAn+".CSV"

                //ENVARQS(_cNarquivo,_cHtml,"DW - QFTNOTASSAIDA")
                ENVFARQS(_cNarquivo)

                _cEmissD:=F1_DTDIGIT
                _cEmissA:=F1_DTDIGIT

            END

            _nHandle    :=FCREATE(_cArquivo)

            If _nHandle = -1
                conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
            END
            
            _nDemiss    :=1
        End

        For x:=1 To Len(_aStru)
    
            If _aStru[x,2]=="C"

                MONTACAMPO()

                //FWrite(_nHandle, &(_aStru[x,1])+';')
                FWrite(_nHandle, _cCampo)
            Else
                FWrite(_nHandle, Str(&(_aStru[x,1])))
                FWrite(_nHandle, ';')
            END
        NEXT

        FWrite(_nHandle, CRLF)

        DBSKIP()
    END

    _cNarquivo:=_cTabela+"_"+_cEmissD+"_"+_cEmissA+".CSV"

    ENVFARQS(_cNarquivo)

else
    GERLOG(_cTabela,_cOrig,"",0)
END

RETURN

/*/{Protheus.doc} QEPESTRUTU
    Extração de dados de Estrutura de Produto
    @type  Static Function
    @author user
    Edson Bella Gonçalves - MRC
    @since 27/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function QEPESTRUTU

Private _nRegsIt      := GetMv("EL_DWRGEPR")
Private _cAlias     :=  GetNextAlias()
Private _nHandle
Private _cTabela    :=  "QEPESTRUTURAITEM"
Private _cArquivo   :=  _cPasta+_cTabela
Private _cCampo

If !_lNUser
    If MessageBox("Confirma início?","Estrutura de Produto",4)==7
        AtuConou('2')
        Return
    END

    MsAguarde({|| PQEPESTRUT()}, "Aguarde...", "Processando Registros "+_cTabela+"...")
else
    PQEPESTRUT()
END

AtuConou('4')

Return

//
Static Function PQEPESTRUT

Local _nReg :=1
Local _nSeq :=1

AtuConou('3')

BeginSql Alias _cAlias

    SELECT 
        G1_FILIAL ,
        G1_COD    ,
        SB1.B1_DESC,
        G1_TRT    ,
        G1_COMP   ,
        SB1_2.B1_DESC DESG1,
        G1_QUANT  ,
        G1_PERDA  ,
        G1_INI    ,
        G1_FIM    ,
        G1_OBSERV ,
        G1_FIXVAR ,
        G1_GROPC  ,
        G1_OPC    ,
        G1_REVINI ,
        G1_NIV    ,
        G1_NIVINV ,
        G1_REVFIM ,
        G1_POTENCI,
        G1_VECTOR ,
        G1_VLCOMPE,
        G1_OK     ,
        G1_TIPVEC ,
        G1_USAALT ,
        G1_LOCCONS,
        G1_FANTASM,
        G1_LISTA

    FROM %table:SG1% G1
        LEFT JOIN %table:SB1% SB1 ON G1_COD = B1_COD AND SB1.%notdel%
        LEFT JOIN %table:SB1% SB1_2 ON G1_COMP = SB1_2.B1_COD AND SB1_2.%notdel%
    WHERE G1.%notdel%
   //and rownum<50001

EndSql

_cQuery:=GetLastQuery()

_aStru:=DBSTRUCT()

DBGOTOP()

_nHandle    :=FCREATE(_cArquivo)

IF!EOF()

    HTMLMAIL()

    Whil!Eof()

        If _nReg>_nRegsIt
            //_cNarquivo:=_cArquivo+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
            //ENVARQS(_cNarquivo,_cHtml,"DW - QEPITEM")

            _cNarquivo:=_cTabela+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
            ENVFARQS(_cNarquivo)

            _nSeq   ++
            _nReg   :=1
            _nHandle    :=FCREATE(_cArquivo)
        END

        For x:=1 To Len(_aStru)
    
            If _aStru[x,2]=="C"

                MONTACAMPO()

                FWrite(_nHandle, _cCampo)
            Else
                FWrite(_nHandle, Str(&(_aStru[x,1])))
                FWrite(_nHandle, ';')
            END
        NEXT

        FWrite(_nHandle, CRLF)

        DBSKIP()

        _nReg++

    END

//    _cNarquivo:=_cArquivo+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
//    ENVARQS(_cNarquivo,_cHtml,"DW - QEPITEM")
      
      _cNarquivo:=_cTabela+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
      ENVFARQS(_cNarquivo)

else
    GERLOG(_cTabela,_cOrig,"",0)
END

RETURN

/*/{Protheus.doc} QPFOF
    Extração de dados de Estrutura de Produto
    @type  Static Function
    @author user
    Edson Bella Gonçalves - MRC
    @since 27/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function QPFOF

Private _nRegsIt      := GetMv("EL_DWRGOF")
Private _cAlias     :=  GetNextAlias()
Private _nHandle
Private _cTabela    :=  "QPFOF"
Private _cArquivo   :=  _cPasta+_cTabela
Private _cCampo

If !_lNUser
    If MessageBox("Confirma início?","Ordem de Produção",4)==7
        AtuConou('2')
        Return
    END

    MsAguarde({|| PQPFOF()}, "Aguarde...", "Processando Registros "+_cTabela+"...")
else
    PQPFOF()
END

AtuConou('4')

Return

//
Static Function PQPFOF

Local _nReg :=1
Local _nSeq :=1

AtuConou('3')

BeginSql Alias _cAlias


    SELECT 

        REGEXP_REPLACE (TRIM(C2_FILIAL ) ,'[[:cntrl:];"]')C2_FILIAL ,
        REGEXP_REPLACE (TRIM(C2_NUM    ) ,'[[:cntrl:];"]')C2_NUM    ,
        REGEXP_REPLACE (TRIM(C2_ITEM   ) ,'[[:cntrl:];"]')C2_ITEM   ,
        REGEXP_REPLACE (TRIM(C2_SEQUEN ) ,'[[:cntrl:];"]')C2_SEQUEN ,
        REGEXP_REPLACE (TRIM(C2_PRODUTO) ,'[[:cntrl:];"]')C2_PRODUTO,
        REGEXP_REPLACE (TRIM(C2_LOCAL  ) ,'[[:cntrl:];"]')C2_LOCAL  ,
        REGEXP_REPLACE (TRIM(C2_LINHA  ) ,'[[:cntrl:];"]')C2_LINHA  ,
        C2_QUANT  ,
        REGEXP_REPLACE (TRIM(C2_XDIMEN ) ,'[[:cntrl:];"]')C2_XDIMEN ,
        C2_QUJE   ,
        REGEXP_REPLACE (TRIM(C2_UM     ) ,'[[:cntrl:];"]')C2_UM     ,
        C2_DATPRI ,
        C2_DATPRF ,
        REGEXP_REPLACE (TRIM(C2_OBS    ) ,'[[:cntrl:];"]')C2_OBS    ,
        C2_DATRF  ,
        C2_EMISSAO,
        REGEXP_REPLACE (TRIM(C2_PRIOR  ) ,'[[:cntrl:];"]')C2_PRIOR  ,
        CASE    WHEN C2_STATUS = 'U' THEN 'SUSPENSA'    WHEN C2_STATUS = 'S' THEN 'SACRAMENTADA'    WHEN C2_STATUS = 'N' THEN 'NORMAL' END C2_STATUS ,
        CASE     WHEN C2_DESTINA = 'P' THEN 'PEDIDO'    WHEN C2_DESTINA = 'E' THEN 'ESTOQUE'    WHEN C2_DESTINA = 'C' THEN 'CONSUMO' END C2_DESTINA,
        C2_VATU1  ,
        C2_VINI1  ,
        C2_VFIM1  ,
        C2_VATU2  ,
        C2_VINI2  ,
        C2_VFIM2  ,
        C2_VATU3  ,
        C2_VINI3  ,
        C2_VFIM3  ,
        C2_VATU4  ,
        C2_VINI4  ,
        C2_VFIM4  ,
        C2_VATU5  ,
        C2_VINI5  ,
        C2_VFIM5  ,
        C2_APRATU1,
        C2_APRINI1,
        C2_APRFIM1,
        C2_APRATU2,
        C2_APRINI2,
        C2_APRFIM2,
        C2_APRATU3,
        C2_APRINI3,
        C2_APRFIM3,
        C2_APRATU4,
        C2_APRINI4,
        C2_APRFIM4,
        C2_APRATU5,
        REGEXP_REPLACE (TRIM(C2_NIVEL  ) ,'[[:cntrl:];"]')C2_NIVEL  ,
        C2_DATAJI ,
        C2_DATAJF ,
        C2_APRINI5,
        C2_APRFIM5,
        REGEXP_REPLACE (TRIM(C2_AGLUT  ) ,'[[:cntrl:];"]')C2_AGLUT  ,
        REGEXP_REPLACE (TRIM(C2_SEGUM  ) ,'[[:cntrl:];"]')C2_SEGUM  ,
        C2_PERDA  ,
        REGEXP_REPLACE (TRIM(C2_OK     ) ,'[[:cntrl:];"]')C2_OK     ,
        C2_DTUPROG,
        REGEXP_REPLACE (TRIM(C2_HORAJI ) ,'[[:cntrl:];"]')C2_HORAJI ,
        REGEXP_REPLACE (TRIM(C2_HORAJF ) ,'[[:cntrl:];"]')C2_HORAJF ,
        C2_QTUPROG,
        CASE  WHEN C2_IDENT = 'P' THEN 'PROJECAO 'END C2_IDENT  ,
        REGEXP_REPLACE (TRIM(C2_RECURSO) ,'[[:cntrl:];"]')C2_RECURSO,
        REGEXP_REPLACE (TRIM(C2_PEDIDO ) ,'[[:cntrl:];"]')C2_PEDIDO ,
        REGEXP_REPLACE (TRIM(C2_ITEMPV ) ,'[[:cntrl:];"]')C2_ITEMPV ,
        REGEXP_REPLACE (TRIM(C2_OPC    ) ,'[[:cntrl:];"]')C2_OPC    ,
        REGEXP_REPLACE (TRIM(C2_SEQPAI ) ,'[[:cntrl:];"]')C2_SEQPAI ,
        REGEXP_REPLACE (TRIM(C2_ROTEIRO) ,'[[:cntrl:];"]')C2_ROTEIRO,
        C2_QTSEGUM,
        C2_VINIFF1,
        C2_VINIFF2,
        C2_VINIFF3,
        C2_VINIFF4,
        C2_VINIFF5,
        C2_VFIMFF1,
        C2_VFIMFF2,
        C2_VFIMFF3,
        C2_VFIMFF4,
        C2_VFIMFF5,
        C2_APINFF1,
        C2_APINFF2,
        C2_APINFF3,
        C2_APINFF4,
        C2_APINFF5,
        C2_APFIFF1,
        C2_APFIFF2,
        C2_APFIFF3,
        C2_APFIFF4,
        C2_APFIFF5,
        CASE WHEN C2_TPOP = 'F' THEN 'FIRME' WHEN C2_TPOP = 'P' THEN 'PREVISTA' END C2_TPOP   ,
        REGEXP_REPLACE (TRIM(C2_REVI   ) ,'[[:cntrl:];"]')C2_REVI   ,
        REGEXP_REPLACE (TRIM(C2_CHAVE  ) ,'[[:cntrl:];"]')C2_CHAVE  ,
        REGEXP_REPLACE (TRIM(C2_CERQUA ) ,'[[:cntrl:];"]')C2_CERQUA ,
        REGEXP_REPLACE (TRIM(C2_GRADE  ) ,'[[:cntrl:];"]')C2_GRADE  ,
        REGEXP_REPLACE (TRIM(C2_REVISAO) ,'[[:cntrl:];"]')C2_REVISAO,
        REGEXP_REPLACE (TRIM(C2_OPERAC ) ,'[[:cntrl:];"]')C2_OPERAC ,
        REGEXP_REPLACE (TRIM(C2_ITEMGRD) ,'[[:cntrl:];"]')C2_ITEMGRD,
        REGEXP_REPLACE (TRIM(C2_LAUDO  ) ,'[[:cntrl:];"]')C2_LAUDO  ,
        REGEXP_REPLACE (TRIM(C2_ITEMCTA) ,'[[:cntrl:];"]')C2_ITEMCTA,
        REGEXP_REPLACE (TRIM(C2_CLVL   ) ,'[[:cntrl:];"]')C2_CLVL   ,
        REGEXP_REPLACE (TRIM(C2_GRUPO  ) ,'[[:cntrl:];"]')C2_GRUPO  ,
        REGEXP_REPLACE (TRIM(C2_IDEINV ) ,'[[:cntrl:];"]')C2_IDEINV ,
        C2_VERIFI ,
        REGEXP_REPLACE (TRIM(C2_SEQMRP ) ,'[[:cntrl:];"]')C2_SEQMRP ,
        replace(regexp_replace(TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(C2_MOPC   ,250,1))),'[[:cntrl:];"]'),chr(13))C2_MOPC   ,
        REGEXP_REPLACE (TRIM(C2_CHVQIP ) ,'[[:cntrl:];"]')C2_CHVQIP ,
        REGEXP_REPLACE (TRIM(C2_CC     ) ,'[[:cntrl:];"]')C2_CC     ,
        C2_VFIMRP1,
        C2_VFIMRP2,
        C2_VFIMRP3,
        C2_VFIMRP4,
        C2_VFIMRP5,
        C2_VINIRP1,
        C2_VINIRP2,
        C2_VINIRP3,
        C2_VINIRP4,
        C2_VINIRP5,
        C2_APRIRP1,
        C2_APRIRP2,
        C2_APRIRP3,
        C2_APRIRP4,
        C2_APRIRP5,
        C2_APRFRP1,
        C2_APRFRP2,
        C2_APRFRP3,
        REGEXP_REPLACE (TRIM(C2_BATROT ) ,'[[:cntrl:];"]')C2_BATROT ,
        C2_APRFRP4,
        REGEXP_REPLACE (TRIM(C2_BATCH  ) ,'[[:cntrl:];"]')C2_BATCH  ,
        C2_APRFRP5,
        REGEXP_REPLACE (TRIM(C2_BATUSR ) ,'[[:cntrl:];"]')C2_BATUSR ,
        C2_PMICNUT,
        REGEXP_REPLACE (TRIM(C2_BATORCA) ,'[[:cntrl:];"]')C2_BATORCA,
        C2_PMACNUT,
        REGEXP_REPLACE (TRIM(C2_PROGRAM) ,'[[:cntrl:];"]')C2_PROGRAM,
        REGEXP_REPLACE (TRIM(C2_ORDSEP ) ,'[[:cntrl:];"]')C2_ORDSEP ,
        CASE    WHEN C2_XGEREMP = '1' THEN 'ESTRUTURA'   WHEN C2_XGEREMP = '2' THEN 'ALMOX.CORTE' END C2_XGEREMP,
        REGEXP_REPLACE (TRIM(C2_XCORTE ) ,'[[:cntrl:];"]')C2_XCORTE ,
        C2_DIASOCI,
        REGEXP_REPLACE (TRIM(C2_IDAPS  ) ,'[[:cntrl:];"]')C2_IDAPS  ,
        REGEXP_REPLACE (TRIM(C2_USERLGI) ,'[[:cntrl:];"]')C2_USERLGI,
        REGEXP_REPLACE (TRIM(C2_USERLGA) ,'[[:cntrl:];"]')C2_USERLGA,
        C2_CPF0101,
        C2_CPI0101,
        C2_APF0101,
        C2_API0101,
        C2_CPF0201,
        C2_CPI0201,
        C2_APF0201,
        C2_API0201,
        C2_CPF0301,
        C2_CPI0301,
        C2_APF0301,
        C2_API0301,
        C2_CPF0401,
        C2_CPI0401,
        C2_APF0401,
        C2_API0401,
        C2_CPF0501,
        C2_CPI0501,
        C2_APF0501,
        C2_API0501,
        C2_CPF0601,
        C2_CPI0601,
        C2_APF0601,
        C2_API0601,
        C2_CPF0701,
        C2_CPI0701,
        C2_APF0701,
        C2_API0701,
        C2_CPF0801,
        C2_CPI0801,
        C2_APF0801,
        C2_API0801,
        C2_CPF0901,
        C2_CPI0901,
        C2_APF0901,
        C2_API0901,
        C2_CPF1001,
        C2_CPI1001,
        C2_APF1001,
        C2_API1001,
        C2_CPF1101,
        C2_CPI1101,
        C2_APF1101,
        C2_API1101,
        C2_CPF1201,
        C2_CPI1201,
        C2_APF1201,
        C2_API1201,
        C2_CPF1301,
        C2_CPI1301,
        C2_APF1301,
        C2_API1301,
        C2_CPF1401,
        C2_CPI1401,
        C2_APF1401,
        C2_API1401,
        C2_CPF1501,
        C2_CPI1501,
        C2_APF1501,
        C2_API1501,
        C2_CPF1601,
        C2_CPI1601,
        C2_APF1601,
        C2_API1601,
        C2_CPF1701,
        C2_CPI1701,
        C2_APF1701,
        C2_API1701,
        C2_CPF1801,
        C2_CPI1801,
        C2_APF1801,
        C2_API1801,
        C2_CPF1901,
        C2_CPI1901,
        C2_APF1901,
        C2_API1901,
        C2_CPF2001,
        C2_CPI2001,
        C2_APF2001,
        C2_API2001,
        C2_CPF2101,
        C2_CPI2101,
        C2_APF2101,
        C2_API2101,
        C2_CPF2201,
        C2_CPI2201,
        C2_APF2201,
        C2_API2201,
        C2_CPF2301,
        C2_CPI2301,
        C2_APF2301,
        C2_API2301,
        C2_CPF2401,
        C2_CPI2401,
        C2_APF2401,
        C2_API2401,
        C2_CPF2501,
        C2_CPI2501,
        C2_APF2501,
        C2_API2501,
        C2_CPF2601,
        C2_CPI2601,
        C2_APF2601,
        C2_API2601,
        C2_CPF2701,
        C2_CPI2701,
        C2_APF2701,
        C2_API2701,
        C2_CPF2801,
        C2_CPI2801,
        C2_APF2801,
        C2_API2801,
        C2_CPF2901,
        C2_CPI2901,
        C2_APF2901,
        CASE     WHEN C2_TPPR = 'I' THEN 'INTERNA'    WHEN C2_TPPR = 'E' THEN 'EXTERNA'    WHEN C2_TPPR = 'R' THEN 'RETRABALHO'    WHEN C2_TPPR = 'O' THEN 'OUTROS' END C2_TPPR   ,
        C2_API2901,
        REGEXP_REPLACE (TRIM(C2_BLQAPON) ,'[[:cntrl:];"]')C2_BLQAPON,
        REGEXP_REPLACE (TRIM(C2_XHRINI ) ,'[[:cntrl:];"]')C2_XHRINI ,
        REGEXP_REPLACE (TRIM(C2_STTERCE) ,'[[:cntrl:];"]')C2_STTERCE,
        REGEXP_REPLACE (TRIM(C2_OPTERCE) ,'[[:cntrl:];"]')C2_OPTERCE,
        REGEXP_REPLACE (TRIM(C2_CODSAF ) ,'[[:cntrl:];"]')C2_CODSAF ,
        REGEXP_REPLACE (TRIM(C2_OP     ) ,'[[:cntrl:];"]')C2_OP     ,

        B1_DESC,
        nnr_descri,
        z6_desc,
        CTT_DESC01
    FROM %table:SC2% C2
        LEFT JOIN %table:SB1% Sb1 ON C2_PRODUTO = b1_cod and sb1.%notdel%
        left join %table:NNR% NNR on C2_LOCAL = NNR_codIGO and TRIM(SUBSTR(C2_FILIAL,1,4)) = SUBSTR(NNR_FILIAL,1,4)  and NNR.%notdel%
        left join %table:SZ6% SZ6 on C2_LINHA = Z6_cod and C2_filial =Z6_FILIAL and SZ6.%notdel%
        left join %table:CTT% CTT ON C2_CC = CTT_CUSTO AND C2_FILIAL = CTT_FILIAL AND CTT.%notdel%
 
    WHERE C2.%notdel%;
   //and rownum<50001

EndSql

_cQuery:=GetLastQuery()

_aStru:=DBSTRUCT()

DBGOTOP()

_nHandle    :=FCREATE(_cArquivo)

IF!EOF()

    HTMLMAIL()

    Whil!Eof()

        If _nReg>_nRegsIt
            //_cNarquivo:=_cArquivo+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
            //ENVARQS(_cNarquivo,_cHtml,"DW - QEPITEM")

            _cNarquivo:=_cTabela+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
            ENVFARQS(_cNarquivo)

            _nSeq   ++
            _nReg   :=1
            _nHandle    :=FCREATE(_cArquivo)
        END

        For x:=1 To Len(_aStru)
    
            If _aStru[x,2]=="C"

                MONTACAMPO()

                FWrite(_nHandle, _cCampo)
            Else
                FWrite(_nHandle, Str(&(_aStru[x,1])))
                FWrite(_nHandle, ';')
            END
        NEXT

        FWrite(_nHandle, CRLF)

        DBSKIP()

        _nReg++

    END

//    _cNarquivo:=_cArquivo+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
//    ENVARQS(_cNarquivo,_cHtml,"DW - QEPITEM")
      
      _cNarquivo:=_cTabela+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
      ENVFARQS(_cNarquivo)

else
    GERLOG(_cTabela,_cOrig,"",0)
END

/*/{Protheus.doc} QVEPEDIDOS
    Extração de dados de Pedidos de Vendas
    @type  Static Function
    @author user
    Edson Bella Gonçalves - MRC
    @since 01/03/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function QVEPEDIDOS

Local   _aPergs     := {}

Private _nRegsIt    := GetMv("EL_DWRGPV")
Private _nPvdiasR   := GetMv("EL_DWNPVD")
Private _cAlias     :=  GetNextAlias()
Private _nHandle
Private _cTabela    :=  "QVEPEDIDOS"
Private _cArquivo   :=  _cPasta+_cTabela
Private _cCampo
Private _cFilialDe  := Space(6)
Private _cFilialAte := Space(6)
Private _dEmissaoD  := Ctod('  /  /    ')
Private _dEmissaoA  := Ctod('  /  /    ')

If _lNUser
    MV_PAR01    :=  ' '
    MV_PAR02    :=  'ZZZZZZ'
    MV_PAR03    :=  date()-_nPvdiasR //CtoD('01/10/2022') //
    MV_PAR04    :=  date() //CtoD('31/12/2022') //

else
    aAdd(_aPergs, {1, "Filial de",   _cFilialDe,    "", ".T.", "",".T.", 40,.T.})
    aAdd(_aPergs, {1, "Filial até",  _cFilialAte,   "", ".T.", "",".T.", 40,.F.})
    aAdd(_aPergs, {1, "Emissão de",  _dEmissaoD,    "", ".T.", "",".T.", 60,.T.})
    aAdd(_aPergs, {1, "Emissão até", _dEmissaoA,    "", ".T.", "",".T.", 60,.F.})

    If !ParamBox(_aPergs, "Informe os parâmetros")
        AtuConou('2')
        RETURN .t.
    End

END

MsAguarde({|| PQVEPEDIDOS()}, "Aguarde...", "Processando Registros "+_cTabela+"...")

AtuConou('4')

Return

//
Static Function PQVEPEDIDOS

Local _nReg :=1
Local _nSeq :=1

AtuConou('3')

BeginSql Alias _cAlias

    SELECT 
        REGEXP_REPLACE (TRIM(C5_FILIAL ) ,'[[:cntrl:];"]') C5_FILIAL ,
        REGEXP_REPLACE (TRIM(C5_NUM    ) ,'[[:cntrl:];"]') C5_NUM    ,
        REGEXP_REPLACE (TRIM(C5_TIPO   ) ,'[[:cntrl:];"]') C5_TIPO   ,
        REGEXP_REPLACE (TRIM(C5_CLIENTE) ,'[[:cntrl:];"]') C5_CLIENTE,
        REGEXP_REPLACE (TRIM(C5_LOJACLI) ,'[[:cntrl:];"]') C5_LOJACLI,
        REGEXP_REPLACE (TRIM(C5_CLIENT ) ,'[[:cntrl:];"]') C5_CLIENT ,
        REGEXP_REPLACE (TRIM(C5_LOJAENT) ,'[[:cntrl:];"]') C5_LOJAENT,
        REGEXP_REPLACE (TRIM(C5_XNORDEM) ,'[[:cntrl:];"]') C5_XNORDEM,
        REGEXP_REPLACE (TRIM(C5_TIPOCLI) ,'[[:cntrl:];"]') C5_TIPOCLI,
        REGEXP_REPLACE (TRIM(C5_XCARBAN) ,'[[:cntrl:];"]') C5_XCARBAN,
        REGEXP_REPLACE (TRIM(C5_XNOMECL) ,'[[:cntrl:];"]') C5_XNOMECL,
        REGEXP_REPLACE (TRIM(C5_CONDPAG) ,'[[:cntrl:];"]') C5_CONDPAG,
        REGEXP_REPLACE (TRIM(C5_TABELA ) ,'[[:cntrl:];"]') C5_TABELA ,
        C5_XDESCNF,
        REGEXP_REPLACE (TRIM(C5_VEND1  ) ,'[[:cntrl:];"]') C5_VEND1  ,
        REGEXP_REPLACE (TRIM(C5_XNOMERE) ,'[[:cntrl:];"]') C5_XNOMERE,
        C5_COMIS1 ,
        REGEXP_REPLACE (TRIM(C5_XDESCAR) ,'[[:cntrl:];"]') C5_XDESCAR,
        C5_VLR_FRT,
        C5_FRETE  ,
        REGEXP_REPLACE (TRIM(C5_TPCARGA) ,'[[:cntrl:];"]') C5_TPCARGA,
        REGEXP_REPLACE (TRIM(C5_TRANSP ) ,'[[:cntrl:];"]') C5_TRANSP ,
        REGEXP_REPLACE (TRIM(C5_XTPCOM ) ,'[[:cntrl:];"]') C5_XTPCOM ,
        REGEXP_REPLACE (TRIM(C5_VEND2  ) ,'[[:cntrl:];"]') C5_VEND2  ,
        C5_COMIS2 ,
        REGEXP_REPLACE (TRIM(C5_VEND3  ) ,'[[:cntrl:];"]') C5_VEND3  ,
        C5_COMIS3 ,
        REGEXP_REPLACE (TRIM(C5_VEND4  ) ,'[[:cntrl:];"]') C5_VEND4  ,
        C5_COMIS4 ,
        REGEXP_REPLACE (TRIM(C5_VEND5  ) ,'[[:cntrl:];"]') C5_VEND5  ,
        C5_COMIS5 ,
        C5_DESC1  ,
        C5_DESC2  ,
        C5_DESC3  ,
        C5_DESPESA,
        C5_FRETAUT,
        REGEXP_REPLACE (TRIM(C5_REAJUST) ,'[[:cntrl:];"]') C5_REAJUST,
        C5_MOEDA  ,
        C5_DESC4  ,
        REGEXP_REPLACE (TRIM(C5_BANCO  ) ,'[[:cntrl:];"]') C5_BANCO  ,
        C5_DESCFI ,
        C5_EMISSAO,
        REGEXP_REPLACE (TRIM(C5_COTACAO) ,'[[:cntrl:];"]') C5_COTACAO,
        C5_PARC1  ,
        C5_DATA1  ,
        C5_PARC2  ,
        C5_DATA2  ,
        C5_PARC3  ,
        C5_DATA3  ,
        C5_PARC4  ,
        C5_DATA4  ,
        C5_PARC5  ,
        C5_DATA5  ,
        REGEXP_REPLACE (TRIM(C5_INCISS ) ,'[[:cntrl:];"]') C5_INCISS ,
        REGEXP_REPLACE (TRIM(C5_LIBEROK) ,'[[:cntrl:];"]') C5_LIBEROK,
        REGEXP_REPLACE (TRIM(C5_OK     ) ,'[[:cntrl:];"]') C5_OK     ,
        REGEXP_REPLACE (TRIM(C5_NOTA   ) ,'[[:cntrl:];"]') C5_NOTA   ,
        REGEXP_REPLACE (TRIM(C5_SERIE  ) ,'[[:cntrl:];"]') C5_SERIE  ,
        C5_PARC6  ,
        REGEXP_REPLACE (TRIM(C5_OS     ) ,'[[:cntrl:];"]') C5_OS     ,
        C5_DATA6  ,
        C5_PARC7  ,
        C5_DATA7  ,
        C5_TXMOEDA,
        C5_PARC8  ,
        C5_DATA8  ,
        C5_PARC9  ,
        C5_DATA9  ,
        C5_PARCA  ,
        C5_DATAA  ,
        C5_PARCB  ,
        C5_DATAB  ,
        C5_PARCC  ,
        C5_DATAC  ,
        REGEXP_REPLACE (TRIM(C5_TPFRETE) ,'[[:cntrl:];"]') C5_TPFRETE,
        C5_SEGURO ,
        C5_PESOL  ,
        C5_PBRUTO ,
        C5_REIMP  ,
        REGEXP_REPLACE (TRIM(C5_ESTPRES) ,'[[:cntrl:];"]') C5_ESTPRES,
        REGEXP_REPLACE (TRIM(C5_REDESP ) ,'[[:cntrl:];"]') C5_REDESP ,
        C5_VOLUME1,
        REGEXP_REPLACE (TRIM(C5_ORCRES ) ,'[[:cntrl:];"]') C5_ORCRES ,
        C5_VOLUME2,
        C5_VOLUME3,
        C5_VOLUME4,
        REGEXP_REPLACE (TRIM(C5_ESPECI1) ,'[[:cntrl:];"]') C5_ESPECI1,
        REGEXP_REPLACE (TRIM(C5_ESPECI2) ,'[[:cntrl:];"]') C5_ESPECI2,
        REGEXP_REPLACE (TRIM(C5_SERSUBS) ,'[[:cntrl:];"]') C5_SERSUBS,
        REGEXP_REPLACE (TRIM(C5_NFSUBST) ,'[[:cntrl:];"]') C5_NFSUBST,
        REGEXP_REPLACE (TRIM(C5_ESPECI3) ,'[[:cntrl:];"]') C5_ESPECI3,
        REGEXP_REPLACE (TRIM(C5_ESPECI4) ,'[[:cntrl:];"]') C5_ESPECI4,
        C5_ACRSFIN,
        REGEXP_REPLACE (TRIM(C5_MENNOTA) ,'[[:cntrl:];"]') C5_MENNOTA,
        REGEXP_REPLACE (TRIM(C5_MENPAD ) ,'[[:cntrl:];"]') C5_MENPAD ,
        REGEXP_REPLACE (TRIM(C5_KITREP ) ,'[[:cntrl:];"]') C5_KITREP ,
        REGEXP_REPLACE (TRIM(C5_TIPLIB ) ,'[[:cntrl:];"]') C5_TIPLIB ,
        C5_DESCONT,
        REGEXP_REPLACE (TRIM(C5_MUNPRES) ,'[[:cntrl:];"]') C5_MUNPRES,
        REGEXP_REPLACE (TRIM(C5_PEDEXP ) ,'[[:cntrl:];"]') C5_PEDEXP ,
        REGEXP_REPLACE (TRIM(C5_DESCMUN) ,'[[:cntrl:];"]') C5_DESCMUN,
        C5_DTLANC ,
        REGEXP_REPLACE (TRIM(C5_OBRA   ) ,'[[:cntrl:];"]') C5_OBRA   ,
        C5_PDESCAB,
        REGEXP_REPLACE (TRIM(C5_BLQ    ) ,'[[:cntrl:];"]') C5_BLQ    ,
        REGEXP_REPLACE (TRIM(C5_FORNISS) ,'[[:cntrl:];"]') C5_FORNISS,
        REGEXP_REPLACE (TRIM(C5_CONTRA ) ,'[[:cntrl:];"]') C5_CONTRA ,
        REGEXP_REPLACE (TRIM(C5_MDCONTR) ,'[[:cntrl:];"]') C5_MDCONTR,
        REGEXP_REPLACE (TRIM(C5_MDNUMED) ,'[[:cntrl:];"]') C5_MDNUMED,
        REGEXP_REPLACE (TRIM(C5_YCDPALM) ,'[[:cntrl:];"]') C5_YCDPALM,
        REGEXP_REPLACE (TRIM(C5_GERAWMS) ,'[[:cntrl:];"]') C5_GERAWMS,
        C5_YDTIMPR,
        REGEXP_REPLACE (TRIM(C5_MDPLANI) ,'[[:cntrl:];"]') C5_MDPLANI,
        REGEXP_REPLACE (TRIM(C5_SOLFRE ) ,'[[:cntrl:];"]') C5_SOLFRE ,
        C5_FECENT ,
        REGEXP_REPLACE (TRIM(C5_SOLOPC ) ,'[[:cntrl:];"]') C5_SOLOPC ,
        C5_SUGENT ,
        REGEXP_REPLACE (TRIM(C5_CODED  ) ,'[[:cntrl:];"]') C5_CODED  ,
        REGEXP_REPLACE (TRIM(C5_NUMPR  ) ,'[[:cntrl:];"]') C5_NUMPR  ,
        REGEXP_REPLACE (TRIM(C5_RECISS ) ,'[[:cntrl:];"]') C5_RECISS ,
        REGEXP_REPLACE (TRIM(C5_RECFAUT) ,'[[:cntrl:];"]') C5_RECFAUT,
        REGEXP_REPLACE (TRIM(C5_VEICULO) ,'[[:cntrl:];"]') C5_VEICULO,
        REGEXP_REPLACE (TRIM(C5_PREPEMB) ,'[[:cntrl:];"]') C5_PREPEMB,
        REGEXP_REPLACE (TRIM(C5_XOBSPED) ,'[[:cntrl:];"]') C5_XOBSPED,
        REGEXP_REPLACE (TRIM(C5_ORIGEM ) ,'[[:cntrl:];"]') C5_ORIGEM ,
        REGEXP_REPLACE (TRIM(C5_NUMENT ) ,'[[:cntrl:];"]') C5_NUMENT ,
        REGEXP_REPLACE (TRIM(C5_XOBSTRA) ,'[[:cntrl:];"]') C5_XOBSTRA,
        C5_TXREF  ,
        C5_DTTXREF,
        C5_XDATALB,
        REGEXP_REPLACE (TRIM(C5_XTIMELB) ,'[[:cntrl:];"]') C5_XTIMELB,
        REGEXP_REPLACE (TRIM(C5_XOBRA  ) ,'[[:cntrl:];"]') C5_XOBRA  ,
        REGEXP_REPLACE (TRIM(C5_XNVEN  ) ,'[[:cntrl:];"]') C5_XNVEN  ,
        REGEXP_REPLACE (TRIM(C5_XPROFO ) ,'[[:cntrl:];"]') C5_XPROFO ,
        REGEXP_REPLACE (TRIM(C5_XPOEXP ) ,'[[:cntrl:];"]') C5_XPOEXP ,
        REGEXP_REPLACE (TRIM(C5_XPROFOR) ,'[[:cntrl:];"]') C5_XPROFOR,
        REGEXP_REPLACE (TRIM(C5_XCPFMOT) ,'[[:cntrl:];"]') C5_XCPFMOT,
        REGEXP_REPLACE (TRIM(C5_XPLACA ) ,'[[:cntrl:];"]') C5_XPLACA ,
        REGEXP_REPLACE (TRIM(C5_XMOTORI) ,'[[:cntrl:];"]') C5_XMOTORI,
        REGEXP_REPLACE (TRIM(C5_XTPTRAN) ,'[[:cntrl:];"]') C5_XTPTRAN,
        REGEXP_REPLACE (TRIM(C5_XUFPLAC) ,'[[:cntrl:];"]') C5_XUFPLAC,
        //REGEXP_REPLACE (TRIM(C5_USERLGI) ,'[[:cntrl:];"]') C5_USERLGI,
        ' ' C5_USERLGI,
        //REGEXP_REPLACE (TRIM(C5_USERLGA) ,'[[:cntrl:];"]') C5_USERLGA,
        ' ' C5_USERLGA,
        REGEXP_REPLACE (TRIM(C5_XTABELA) ,'[[:cntrl:];"]') C5_XTABELA,
        REGEXP_REPLACE (TRIM(C5_XPEDREP) ,'[[:cntrl:];"]') C5_XPEDREP,
        REGEXP_REPLACE (TRIM(C5_XWFID  ) ,'[[:cntrl:];"]') C5_XWFID  ,
        REGEXP_REPLACE (TRIM(C5_XSTWF  ) ,'[[:cntrl:];"]') C5_XSTWF  ,
        C5_XDTRETI,
        C5_MOEDTIT,
        REGEXP_REPLACE (TRIM(C5_XCGC   ) ,'[[:cntrl:];"]') C5_XCGC   ,
        REGEXP_REPLACE (TRIM(C5_XATEND ) ,'[[:cntrl:];"]') C5_XATEND ,
        REGEXP_REPLACE (TRIM(C5_XTIPLIB) ,'[[:cntrl:];"]') C5_XTIPLIB,
        C5_XDATAAG,
        REGEXP_REPLACE (TRIM(C5_XHORAAG) ,'[[:cntrl:];"]') C5_XHORAAG,
        replace(regexp_replace(TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(C5_XOBSCRG,250,1))),'[[:cntrl:];"]'),chr(13)),
        C5_XFRETE ,
        REGEXP_REPLACE (TRIM(C5_XTRANSP) ,'[[:cntrl:];"]') C5_XTRANSP,
        C5_XSOLAGE,
        REGEXP_REPLACE (TRIM(C5_HRSOLAG) ,'[[:cntrl:];"]') C5_HRSOLAG,
        C5_XVDESCA,
        REGEXP_REPLACE (TRIM(C5_XIDDEP ) ,'[[:cntrl:];"]') C5_XIDDEP ,
        REGEXP_REPLACE (TRIM(C5_XRANDOM) ,'[[:cntrl:];"]') C5_XRANDOM,
        REGEXP_REPLACE (TRIM(C5_XORIGEM) ,'[[:cntrl:];"]') C5_XORIGEM,
        REGEXP_REPLACE (TRIM(C5_XMOTCAN) ,'[[:cntrl:];"]') C5_XMOTCAN,
        replace(regexp_replace(TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(C5_XOBSFIN,250,1))),'[[:cntrl:];"]'),chr(13)),
        C5_XPRZENT,
        C5_XDVAKM ,
        C5_XPRZEN ,
        REGEXP_REPLACE (TRIM(C5_XPAI   ) ,'[[:cntrl:];"]') C5_XPAI   ,
        REGEXP_REPLACE (TRIM(C5_INDPRES) ,'[[:cntrl:];"]') C5_INDPRES,
        REGEXP_REPLACE (TRIM(C5_XDECOM ) ,'[[:cntrl:];"]') C5_XDECOM ,
        REGEXP_REPLACE (TRIM(C5_XPGANTE) ,'[[:cntrl:];"]') C5_XPGANTE,
        REGEXP_REPLACE (TRIM(C5_XEND   ) ,'[[:cntrl:];"]') C5_XEND   ,
        REGEXP_REPLACE (TRIM(C5_XBAIRRO) ,'[[:cntrl:];"]') C5_XBAIRRO,
        REGEXP_REPLACE (TRIM(C5_XCEP   ) ,'[[:cntrl:];"]') C5_XCEP   ,
        REGEXP_REPLACE (TRIM(C5_XEST   ) ,'[[:cntrl:];"]') C5_XEST   ,
        REGEXP_REPLACE (TRIM(C5_XGEOLOC) ,'[[:cntrl:];"]') C5_XGEOLOC,
        REGEXP_REPLACE (TRIM(C5_XGRCAR ) ,'[[:cntrl:];"]') C5_XGRCAR ,
        REGEXP_REPLACE (TRIM(C5_XMUN   ) ,'[[:cntrl:];"]') C5_XMUN   ,
        REGEXP_REPLACE (TRIM(C5_XCOMPLE) ,'[[:cntrl:];"]') C5_XCOMPLE,
        REGEXP_REPLACE (TRIM(C5_XUFEMB ) ,'[[:cntrl:];"]') C5_XUFEMB ,
        REGEXP_REPLACE (TRIM(C5_XLOCEMB) ,'[[:cntrl:];"]') C5_XLOCEMB,
        REGEXP_REPLACE (TRIM(C5_XEMBALA) ,'[[:cntrl:];"]') C5_XEMBALA,
        REGEXP_REPLACE (TRIM(C5_XREFAT ) ,'[[:cntrl:];"]') C5_XREFAT ,
        C5_PEDIDOI,
        C5_DTESERV,
        REGEXP_REPLACE (TRIM(C5_MSIDENT) ,'[[:cntrl:];"]') C5_MSIDENT,
        REGEXP_REPLACE (TRIM(C5_MSEXP  ) ,'[[:cntrl:];"]') C5_MSEXP  ,
        C5_XKM    ,
        C5_XFXPT  ,
        C5_XDTCANC,
        REGEXP_REPLACE (TRIM(C5_XCODZF8) ,'[[:cntrl:];"]') C5_XCODZF8,
        REGEXP_REPLACE (TRIM(C5_XSTATUS) ,'[[:cntrl:];"]') C5_XSTATUS,
        C5_XFRETET,
        REGEXP_REPLACE (TRIM(C5_MSBLQL ) ,'[[:cntrl:];"]') C5_MSBLQL ,
        REGEXP_REPLACE (TRIM(C5_TABTRF ) ,'[[:cntrl:];"]') C5_TABTRF ,
        REGEXP_REPLACE (TRIM(C5_TPCOMPL) ,'[[:cntrl:];"]') C5_TPCOMPL,
        REGEXP_REPLACE (TRIM(C5_REMCTR ) ,'[[:cntrl:];"]') C5_REMCTR ,
        REGEXP_REPLACE (TRIM(C5_REMREV ) ,'[[:cntrl:];"]') C5_REMREV ,
        REGEXP_REPLACE (TRIM(C5_CODEMB ) ,'[[:cntrl:];"]') C5_CODEMB ,
        REGEXP_REPLACE (TRIM(C5_FILGCT ) ,'[[:cntrl:];"]') C5_FILGCT ,
        REGEXP_REPLACE (TRIM(C5_CNO    ) ,'[[:cntrl:];"]') C5_CNO    ,
        REGEXP_REPLACE (TRIM(C5_IMINT  ) ,'[[:cntrl:];"]') C5_IMINT  ,
        REGEXP_REPLACE (TRIM(C5_ARTOBRA) ,'[[:cntrl:];"]') C5_ARTOBRA,
        REGEXP_REPLACE (TRIM(C5_TIPOBRA) ,'[[:cntrl:];"]') C5_TIPOBRA,
        REGEXP_REPLACE (TRIM(C5_CGCINT ) ,'[[:cntrl:];"]') C5_CGCINT ,
        REGEXP_REPLACE (TRIM(C5_CLIINT ) ,'[[:cntrl:];"]') C5_CLIINT ,
        REGEXP_REPLACE (TRIM(C5_NTEMPEN) ,'[[:cntrl:];"]') C5_NTEMPEN,
        REGEXP_REPLACE (TRIM(C5_SLENVT ) ,'[[:cntrl:];"]') C5_SLENVT ,
        REGEXP_REPLACE (TRIM(C5_RET20G ) ,'[[:cntrl:];"]') C5_RET20G ,
        REGEXP_REPLACE (TRIM(C5_PLACA2 ) ,'[[:cntrl:];"]') C5_PLACA2 ,
        REGEXP_REPLACE (TRIM(C5_PLACA1 ) ,'[[:cntrl:];"]') C5_PLACA1 ,
        REGEXP_REPLACE (TRIM(C5_MODANP ) ,'[[:cntrl:];"]') C5_MODANP ,
        REGEXP_REPLACE (TRIM(C5_CODVGLP) ,'[[:cntrl:];"]') C5_CODVGLP,
        REGEXP_REPLACE (TRIM(C5_CODMOT ) ,'[[:cntrl:];"]') C5_CODMOT ,
        REGEXP_REPLACE (TRIM(C5_ECSEDEX) ,'[[:cntrl:];"]') C5_ECSEDEX,
        REGEXP_REPLACE (TRIM(C5_PEDECOM) ,'[[:cntrl:];"]') C5_PEDECOM,
        REGEXP_REPLACE (TRIM(C5_RASTR  ) ,'[[:cntrl:];"]') C5_RASTR  ,
        REGEXP_REPLACE (TRIM(C5_STATUS ) ,'[[:cntrl:];"]') C5_STATUS ,
        REGEXP_REPLACE (TRIM(C5_SDOC   ) ,'[[:cntrl:];"]') C5_SDOC   ,
        REGEXP_REPLACE (TRIM(C5_SDOCSUB) ,'[[:cntrl:];"]') C5_SDOCSUB,
        REGEXP_REPLACE (TRIM(C5_ECPRESN) ,'[[:cntrl:];"]') C5_ECPRESN,
        REGEXP_REPLACE (TRIM(C5_VOLTAPS) ,'[[:cntrl:];"]') C5_VOLTAPS,
        REGEXP_REPLACE (TRIM(C5_ECVINCU) ,'[[:cntrl:];"]') C5_ECVINCU,
        C5_XVLRFRT,
        REGEXP_REPLACE (TRIM(C5_XCONDPG) ,'[[:cntrl:];"]') C5_XCONDPG,
        REGEXP_REPLACE (TRIM(C5_MSRESP ) ,'[[:cntrl:];"]') C5_MSRESP ,
        REGEXP_REPLACE (TRIM(C5_XTRAORI) ,'[[:cntrl:];"]') C5_XTRAORI,
        REGEXP_REPLACE (TRIM(C5_NATUREZ) ,'[[:cntrl:];"]') C5_NATUREZ,
        REGEXP_REPLACE (TRIM(C5_TRCNUM ) ,'[[:cntrl:];"]') C5_TRCNUM ,
        REGEXP_REPLACE (TRIM(C5_CODSAF ) ,'[[:cntrl:];"]') C5_CODSAF ,
        REGEXP_REPLACE (TRIM(C5_CLIRET ) ,'[[:cntrl:];"]') C5_CLIRET ,
        REGEXP_REPLACE (TRIM(C5_LOJARET) ,'[[:cntrl:];"]') C5_LOJARET,
        C5_XIDPORT,
        REGEXP_REPLACE (TRIM(C5_XCODREG) ,'[[:cntrl:];"]') C5_XCODREG,
        REGEXP_REPLACE (TRIM(C5_XWF    ) ,'[[:cntrl:];"]') C5_XWF    ,
        replace(regexp_replace(TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(C5_XWFOBS ,250,1))),'[[:cntrl:];"]'),chr(13)),
        REGEXP_REPLACE (TRIM(C5_XUPLOAD) ,'[[:cntrl:];"]') C5_XUPLOAD,
        REGEXP_REPLACE (TRIM(C5_XMODIFI) ,'[[:cntrl:];"]') C5_XMODIFI,
        REGEXP_REPLACE (TRIM(C5_FRTCFOP) ,'[[:cntrl:];"]') C5_FRTCFOP,
        REGEXP_REPLACE (TRIM(C5_CMUNOR ) ,'[[:cntrl:];"]') C5_CMUNOR ,
        REGEXP_REPLACE (TRIM(C5_UFDEST ) ,'[[:cntrl:];"]') C5_UFDEST ,
        REGEXP_REPLACE (TRIM(C5_CMUNDE ) ,'[[:cntrl:];"]') C5_CMUNDE ,
        REGEXP_REPLACE (TRIM(C5_UFORIG ) ,'[[:cntrl:];"]') C5_UFORIG ,
        REGEXP_REPLACE (TRIM(C5_APROCLI) ,'[[:cntrl:];"]') C5_APROCLI,
        REGEXP_REPLACE (TRIM(C5_CLIREM ) ,'[[:cntrl:];"]') C5_CLIREM ,
        REGEXP_REPLACE (TRIM(C5_LOJAREM) ,'[[:cntrl:];"]') C5_LOJAREM,
        REGEXP_REPLACE (TRIM(C5_XPEDMER) ,'[[:cntrl:];"]') C5_XPEDMER,
        REGEXP_REPLACE (TRIM(C5_XUSRCAN) ,'[[:cntrl:];"]') C5_XUSRCAN,
        REGEXP_REPLACE (TRIM(C5_CODA1U ) ,'[[:cntrl:];"]') C5_CODA1U ,
        REGEXP_REPLACE (TRIM(C5_NUMEXT ) ,'[[:cntrl:];"]') C5_NUMEXT ,
        REGEXP_REPLACE (TRIM(C6_FILIAL ) ,'[[:cntrl:];"]') C6_FILIAL ,
        REGEXP_REPLACE (TRIM(C6_ITEM   ) ,'[[:cntrl:];"]') C6_ITEM   ,
        REGEXP_REPLACE (TRIM(C6_PRODUTO) ,'[[:cntrl:];"]') C6_PRODUTO,
        REGEXP_REPLACE (TRIM(C6_DESCRI ) ,'[[:cntrl:];"]') C6_DESCRI ,
        C6_QTDVEN ,
        REGEXP_REPLACE (TRIM(C6_XQUALIO) ,'[[:cntrl:];"]') C6_XQUALIO,
        REGEXP_REPLACE (TRIM(C6_UM     ) ,'[[:cntrl:];"]') C6_UM     ,
        C6_PRCVEN ,
        C6_XVLORIG,
        REGEXP_REPLACE (TRIM(C6_SEGUM  ) ,'[[:cntrl:];"]') C6_SEGUM  ,
        REGEXP_REPLACE (TRIM(C6_TES    ) ,'[[:cntrl:];"]') C6_TES    ,
        REGEXP_REPLACE (TRIM(C6_OPER   ) ,'[[:cntrl:];"]') C6_OPER   ,
        C6_DESCONT,
        C6_XDESC2 ,
        C6_XDESC1 ,
        C6_XDESC3 ,
        C6_QTDENT2,
        C6_QTDENT ,
        C6_XDESC4 ,
        C6_VALDESC,
        C6_XDESCON,
        REGEXP_REPLACE (TRIM(C6_CF     ) ,'[[:cntrl:];"]') C6_CF     ,
        REGEXP_REPLACE (TRIM(C6_LA     ) ,'[[:cntrl:];"]') C6_LA     ,
        C6_ENTREG ,
        C6_SUGENTR,
        C6_VALOR  ,
        C6_DATFAT ,
        REGEXP_REPLACE (TRIM(C6_LOCAL  ) ,'[[:cntrl:];"]') C6_LOCAL  ,
        C6_QTDLIB ,
        C6_QTDLIB2,
        C6_UNSVEN ,
        REGEXP_REPLACE (TRIM(C6_CLI    ) ,'[[:cntrl:];"]') C6_CLI    ,
        REGEXP_REPLACE (TRIM(C6_LOJA   ) ,'[[:cntrl:];"]') C6_LOJA   ,
        REGEXP_REPLACE (TRIM(C6_NOTA   ) ,'[[:cntrl:];"]') C6_NOTA   ,
        REGEXP_REPLACE (TRIM(C6_SERIE  ) ,'[[:cntrl:];"]') C6_SERIE  ,
        REGEXP_REPLACE (TRIM(C6_NUM    ) ,'[[:cntrl:];"]') C6_NUM    ,
        C6_COMIS1 ,
        C6_COMIS2 ,
        C6_COMIS3 ,
        REGEXP_REPLACE (TRIM(C6_NFORI  ) ,'[[:cntrl:];"]') C6_NFORI  ,
        C6_COMIS4 ,
        C6_COMIS5 ,
        C6_IPIDEV ,
        REGEXP_REPLACE (TRIM(C6_IDENTB6) ,'[[:cntrl:];"]') C6_IDENTB6,
        REGEXP_REPLACE (TRIM(C6_BLQ    ) ,'[[:cntrl:];"]') C6_BLQ    ,
        REGEXP_REPLACE (TRIM(C6_XQUALIP) ,'[[:cntrl:];"]') C6_XQUALIP,
        REGEXP_REPLACE (TRIM(C6_XTONALP) ,'[[:cntrl:];"]') C6_XTONALP,
        REGEXP_REPLACE (TRIM(C6_GRADE  ) ,'[[:cntrl:];"]') C6_GRADE  ,
        REGEXP_REPLACE (TRIM(C6_ITEMGRD) ,'[[:cntrl:];"]') C6_ITEMGRD,
        REGEXP_REPLACE (TRIM(C6_LOTECTL) ,'[[:cntrl:];"]') C6_LOTECTL,
        REGEXP_REPLACE (TRIM(C6_NUMLOTE) ,'[[:cntrl:];"]') C6_NUMLOTE,
        REGEXP_REPLACE (TRIM(C6_XBITOLP) ,'[[:cntrl:];"]') C6_XBITOLP,
        REGEXP_REPLACE (TRIM(C6_NUMORC ) ,'[[:cntrl:];"]') C6_NUMORC ,
        REGEXP_REPLACE (TRIM(C6_PEDCLI ) ,'[[:cntrl:];"]') C6_PEDCLI ,
        REGEXP_REPLACE (TRIM(C6_OPC    ) ,'[[:cntrl:];"]') C6_OPC    ,
        C6_PRUNIT ,
        REGEXP_REPLACE (TRIM(C6_NUMSERI) ,'[[:cntrl:];"]') C6_NUMSERI,
        REGEXP_REPLACE (TRIM(C6_NUMOP  ) ,'[[:cntrl:];"]') C6_NUMOP  ,
        REGEXP_REPLACE (TRIM(C6_ITEMOP ) ,'[[:cntrl:];"]') C6_ITEMOP ,
        REGEXP_REPLACE (TRIM(C6_CLASFIS) ,'[[:cntrl:];"]') C6_CLASFIS,
        REGEXP_REPLACE (TRIM(C6_BLOQUEI) ,'[[:cntrl:];"]') C6_BLOQUEI,
        REGEXP_REPLACE (TRIM(C6_RESERVA) ,'[[:cntrl:];"]') C6_RESERVA,
        REGEXP_REPLACE (TRIM(C6_LOCALIZ) ,'[[:cntrl:];"]') C6_LOCALIZ,
        REGEXP_REPLACE (TRIM(C6_OP     ) ,'[[:cntrl:];"]') C6_OP     ,
        REGEXP_REPLACE (TRIM(C6_OK     ) ,'[[:cntrl:];"]') C6_OK     ,
        REGEXP_REPLACE (TRIM(C6_SERIORI) ,'[[:cntrl:];"]') C6_SERIORI,
        REGEXP_REPLACE (TRIM(C6_ITEMORI) ,'[[:cntrl:];"]') C6_ITEMORI,
        C6_PICMRET,
        REGEXP_REPLACE (TRIM(C6_CODISS ) ,'[[:cntrl:];"]') C6_CODISS ,
        C6_DTVALID,
        REGEXP_REPLACE (TRIM(C6_CHASSI ) ,'[[:cntrl:];"]') C6_CHASSI ,
        REGEXP_REPLACE (TRIM(C6_XTONALO) ,'[[:cntrl:];"]') C6_XTONALO,
        C6_QTDRESE,
        REGEXP_REPLACE (TRIM(C6_CONTRAT) ,'[[:cntrl:];"]') C6_CONTRAT,
        REGEXP_REPLACE (TRIM(C6_NUMOS  ) ,'[[:cntrl:];"]') C6_NUMOS  ,
        REGEXP_REPLACE (TRIM(C6_NUMOSFA) ,'[[:cntrl:];"]') C6_NUMOSFA,
        REGEXP_REPLACE (TRIM(C6_CODFAB ) ,'[[:cntrl:];"]') C6_CODFAB ,
        REGEXP_REPLACE (TRIM(C6_LOJAFA ) ,'[[:cntrl:];"]') C6_LOJAFA ,
        REGEXP_REPLACE (TRIM(C6_ITEMCON) ,'[[:cntrl:];"]') C6_ITEMCON,
        C6_QTDEMP ,
        C6_QTDEMP2,
        REGEXP_REPLACE (TRIM(C6_TPOP   ) ,'[[:cntrl:];"]') C6_TPOP   ,
        REGEXP_REPLACE (TRIM(C6_REVISAO) ,'[[:cntrl:];"]') C6_REVISAO,
        REGEXP_REPLACE (TRIM(C6_SERVIC ) ,'[[:cntrl:];"]') C6_SERVIC ,
        REGEXP_REPLACE (TRIM(C6_ENDPAD ) ,'[[:cntrl:];"]') C6_ENDPAD ,
        REGEXP_REPLACE (TRIM(C6_CONTRT ) ,'[[:cntrl:];"]') C6_CONTRT ,
        replace(regexp_replace(TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(C6_MOPC   ,250,1))),'[[:cntrl:];"]'),chr(13)),
        REGEXP_REPLACE (TRIM(C6_TPCONTR) ,'[[:cntrl:];"]') C6_TPCONTR,
        REGEXP_REPLACE (TRIM(C6_NUMSC  ) ,'[[:cntrl:];"]') C6_NUMSC  ,
        REGEXP_REPLACE (TRIM(C6_ITEMSC ) ,'[[:cntrl:];"]') C6_ITEMSC ,
        REGEXP_REPLACE (TRIM(C6_ITCONTR) ,'[[:cntrl:];"]') C6_ITCONTR,
        REGEXP_REPLACE (TRIM(C6_GEROUPV) ,'[[:cntrl:];"]') C6_GEROUPV,
        REGEXP_REPLACE (TRIM(C6_PROJPMS) ,'[[:cntrl:];"]') C6_PROJPMS,
        REGEXP_REPLACE (TRIM(C6_EDTPMS ) ,'[[:cntrl:];"]') C6_EDTPMS ,
        REGEXP_REPLACE (TRIM(C6_TASKPMS) ,'[[:cntrl:];"]') C6_TASKPMS,
        C6_FUNRURA,
        C6_FETAB  ,
        REGEXP_REPLACE (TRIM(C6_CODROM ) ,'[[:cntrl:];"]') C6_CODROM ,
        REGEXP_REPLACE (TRIM(C6_TRT    ) ,'[[:cntrl:];"]') C6_TRT    ,
        REGEXP_REPLACE (TRIM(C6_PROJET ) ,'[[:cntrl:];"]') C6_PROJET ,
        REGEXP_REPLACE (TRIM(C6_ITPROJ ) ,'[[:cntrl:];"]') C6_ITPROJ ,
        C6_POTENCI,
        REGEXP_REPLACE (TRIM(C6_LICITA ) ,'[[:cntrl:];"]') C6_LICITA ,
        REGEXP_REPLACE (TRIM(C6_REGWMS ) ,'[[:cntrl:];"]') C6_REGWMS ,
        REGEXP_REPLACE (TRIM(C6_NUMCP  ) ,'[[:cntrl:];"]') C6_NUMCP  ,
        REGEXP_REPLACE (TRIM(C6_TURNO  ) ,'[[:cntrl:];"]') C6_TURNO  ,
        REGEXP_REPLACE (TRIM(C6_ITEMED ) ,'[[:cntrl:];"]') C6_ITEMED ,
        REGEXP_REPLACE (TRIM(C6_LOJDED ) ,'[[:cntrl:];"]') C6_LOJDED ,
        C6_ABSCINS,
        C6_ABATISS,
        REGEXP_REPLACE (TRIM(C6_FORDED ) ,'[[:cntrl:];"]') C6_FORDED ,
        C6_ABATMAT,
        REGEXP_REPLACE (TRIM(C6_ITPC   ) ,'[[:cntrl:];"]') C6_ITPC   ,
        REGEXP_REPLACE (TRIM(C6_PROGRAM) ,'[[:cntrl:];"]') C6_PROGRAM,
        REGEXP_REPLACE (TRIM(C6_PVCOMOP) ,'[[:cntrl:];"]') C6_PVCOMOP,
        REGEXP_REPLACE (TRIM(C6_FCICOD ) ,'[[:cntrl:];"]') C6_FCICOD ,
        REGEXP_REPLACE (TRIM(C6_VDMOST ) ,'[[:cntrl:];"]') C6_VDMOST ,
        REGEXP_REPLACE (TRIM(C6_FILPED ) ,'[[:cntrl:];"]') C6_FILPED ,
        REGEXP_REPLACE (TRIM(C6_PEDCOM ) ,'[[:cntrl:];"]') C6_PEDCOM ,
        REGEXP_REPLACE (TRIM(C6_CODLAN ) ,'[[:cntrl:];"]') C6_CODLAN ,
        REGEXP_REPLACE (TRIM(C6_YITPPAL) ,'[[:cntrl:];"]') C6_YITPPAL,
        C6_VLIMPOR,
        //replace(regexp_replace(TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(C6_VDOBS  ,250,1))),'[[:cntrl:];"]'),chr(13)),
        REGEXP_REPLACE (TRIM(C6_XTPENT ) ,'[[:cntrl:];"]') C6_XTPENT ,
        REGEXP_REPLACE (TRIM(C6_XTONAL ) ,'[[:cntrl:];"]') C6_XTONAL ,
        REGEXP_REPLACE (TRIM(C6_XQUALIF) ,'[[:cntrl:];"]') C6_XQUALIF,
        REGEXP_REPLACE (TRIM(C6_XBITOLA) ,'[[:cntrl:];"]') C6_XBITOLA,
        //REGEXP_REPLACE (TRIM(C6_USERLGI) ,'[[:cntrl:];"]') C6_USERLGI,
        ' ' C6_USERLGI,
        //REGEXP_REPLACE (TRIM(C6_USERLGA) ,'[[:cntrl:];"]') C6_USERLGA,
        ' ' C6_USERLGA,
        C6_XPRCTAB,
        REGEXP_REPLACE (TRIM(C6_XHORAAG) ,'[[:cntrl:];"]') C6_XHORAAG,
        REGEXP_REPLACE (TRIM(C6_PEDVINC) ,'[[:cntrl:];"]') C6_PEDVINC,
        REGEXP_REPLACE (TRIM(C6_PRODFIN) ,'[[:cntrl:];"]') C6_PRODFIN,
        REGEXP_REPLACE (TRIM(C6_REVPROD) ,'[[:cntrl:];"]') C6_REVPROD,
        C6_XVALTAB,
        REGEXP_REPLACE (TRIM(C6_TPDEDUZ) ,'[[:cntrl:];"]') C6_TPDEDUZ,
        C6_XIPI   ,
        REGEXP_REPLACE (TRIM(C6_MOTDED ) ,'[[:cntrl:];"]') C6_MOTDED ,
        C6_XICMSST,
        C6_VLDED  ,
        C6_XFRETE ,
        C6_VLNFD  ,
        C6_XDESCCE,
        REGEXP_REPLACE (TRIM(C6_RATEIO ) ,'[[:cntrl:];"]') C6_RATEIO ,
        C6_XDESCAR,
        REGEXP_REPLACE (TRIM(C6_SERDED ) ,'[[:cntrl:];"]') C6_SERDED ,
        REGEXP_REPLACE (TRIM(C6_XHRDESC) ,'[[:cntrl:];"]') C6_XHRDESC,
        C6_PCDED  ,
        REGEXP_REPLACE (TRIM(C6_XRESERV) ,'[[:cntrl:];"]') C6_XRESERV,
        REGEXP_REPLACE (TRIM(C6_NFDED  ) ,'[[:cntrl:];"]') C6_NFDED  ,
        C6_ICMSRET,
        REGEXP_REPLACE (TRIM(C6_ITLPRE ) ,'[[:cntrl:];"]') C6_ITLPRE ,
        REGEXP_REPLACE (TRIM(C6_XCODREG) ,'[[:cntrl:];"]') C6_XCODREG,
        REGEXP_REPLACE (TRIM(C6_XNUMPLT) ,'[[:cntrl:];"]') C6_XNUMPLT,
        REGEXP_REPLACE (TRIM(C6_MSIDENT) ,'[[:cntrl:];"]') C6_MSIDENT,
        REGEXP_REPLACE (TRIM(C6_MSEXP  ) ,'[[:cntrl:];"]') C6_MSEXP  ,
        C6_XDATA  ,
        REGEXP_REPLACE (TRIM(C6_XHORA  ) ,'[[:cntrl:];"]') C6_XHORA  ,
        REGEXP_REPLACE (TRIM(C6_MSRESP ) ,'[[:cntrl:];"]') C6_MSRESP ,
        REGEXP_REPLACE (TRIM(C6_XFILEST) ,'[[:cntrl:];"]') C6_XFILEST,
        REGEXP_REPLACE (TRIM(C6_TPESTR ) ,'[[:cntrl:];"]') C6_TPESTR ,
        REGEXP_REPLACE (TRIM(C6_ITEMGAR) ,'[[:cntrl:];"]') C6_ITEMGAR,
        REGEXP_REPLACE (TRIM(C6_ORCGAR ) ,'[[:cntrl:];"]') C6_ORCGAR ,
        REGEXP_REPLACE (TRIM(C6_NRSEQCQ) ,'[[:cntrl:];"]') C6_NRSEQCQ,
        REGEXP_REPLACE (TRIM(C6_SDOCORI) ,'[[:cntrl:];"]') C6_SDOCORI,
        REGEXP_REPLACE (TRIM(C6_D1SERIE) ,'[[:cntrl:];"]') C6_D1SERIE,
        REGEXP_REPLACE (TRIM(C6_SDOC   ) ,'[[:cntrl:];"]') C6_SDOC   ,
        REGEXP_REPLACE (TRIM(C6_D1DOC  ) ,'[[:cntrl:];"]') C6_D1DOC  ,
        REGEXP_REPLACE (TRIM(C6_SDOCDED) ,'[[:cntrl:];"]') C6_SDOCDED,
        REGEXP_REPLACE (TRIM(C6_CODLPRE) ,'[[:cntrl:];"]') C6_CODLPRE,
        REGEXP_REPLACE (TRIM(C6_SDOCSD1) ,'[[:cntrl:];"]') C6_SDOCSD1,
        REGEXP_REPLACE (TRIM(C6_D1ITEM ) ,'[[:cntrl:];"]') C6_D1ITEM ,
        REGEXP_REPLACE (TRIM(C6_XBITOLO) ,'[[:cntrl:];"]') C6_XBITOLO,
        C6_DATAEMB,
        REGEXP_REPLACE (TRIM(C6_PENE   ) ,'[[:cntrl:];"]') C6_PENE   ,
        REGEXP_REPLACE (TRIM(C6_CATEG  ) ,'[[:cntrl:];"]') C6_CATEG  ,
        REGEXP_REPLACE (TRIM(C6_CTVAR  ) ,'[[:cntrl:];"]') C6_CTVAR  ,
        REGEXP_REPLACE (TRIM(C6_CULTRA ) ,'[[:cntrl:];"]') C6_CULTRA ,
        REGEXP_REPLACE (TRIM(C6_TPREPAS) ,'[[:cntrl:];"]') C6_TPREPAS,
        REGEXP_REPLACE (TRIM(C6_XREGDES) ,'[[:cntrl:];"]') C6_XREGDES,
        C6_XQTDMIN,
        C6_XPMAXR ,
        C6_XPMAXP ,
        C6_XPMAXG ,
        C6_XPMAXD ,
        REGEXP_REPLACE (TRIM(C6_XREGNEG) ,'[[:cntrl:];"]') C6_XREGNEG,
        C6_XQTDMAX,
        REGEXP_REPLACE (TRIM(C6_XUPLOAD) ,'[[:cntrl:];"]') C6_XUPLOAD,
        REGEXP_REPLACE (TRIM(C6_XMODIFI) ,'[[:cntrl:];"]') C6_XMODIFI,
        REGEXP_REPLACE (TRIM(C6_XPLSOLT) ,'[[:cntrl:];"]') C6_XPLSOLT,
        REGEXP_REPLACE (TRIM(C6_XALOCA ) ,'[[:cntrl:];"]') C6_XALOCA ,
        REGEXP_REPLACE (TRIM(C6_XOALOC ) ,'[[:cntrl:];"]') C6_XOALOC ,
        REGEXP_REPLACE (TRIM(C6_XRESLOT) ,'[[:cntrl:];"]') C6_XRESLOT,
        C6_BASVEIC,
        C6_ABATINS,
        REGEXP_REPLACE (TRIM(C6_ITEMPC ) ,'[[:cntrl:];"]') C6_ITEMPC ,
        REGEXP_REPLACE (TRIM(C6_NUMPCOM) ,'[[:cntrl:];"]') C6_NUMPCOM,
        C6_DTFIMNT,
        REGEXP_REPLACE (TRIM(C6_TNATREC) ,'[[:cntrl:];"]') C6_TNATREC,
        REGEXP_REPLACE (TRIM(C6_HORENT ) ,'[[:cntrl:];"]') C6_HORENT ,
        REGEXP_REPLACE (TRIM(C6_PMSID  ) ,'[[:cntrl:];"]') C6_PMSID  ,
        REGEXP_REPLACE (TRIM(C6_CODINF ) ,'[[:cntrl:];"]') C6_CODINF ,
        REGEXP_REPLACE (TRIM(C6_GRPNATR) ,'[[:cntrl:];"]') C6_GRPNATR,
        REGEXP_REPLACE (TRIM(C6_CNATREC) ,'[[:cntrl:];"]') C6_CNATREC,
        REGEXP_REPLACE (TRIM(C6_SOLCOM ) ,'[[:cntrl:];"]') C6_SOLCOM ,
        REGEXP_REPLACE (TRIM(C6_ALMTERC) ,'[[:cntrl:];"]') C6_ALMTERC,
        REGEXP_REPLACE (TRIM(C6_CCUSTO ) ,'[[:cntrl:];"]') C6_CCUSTO ,
        C6_DATCPL ,
        REGEXP_REPLACE (TRIM(C6_HORCPL ) ,'[[:cntrl:];"]') C6_HORCPL ,
        REGEXP_REPLACE (TRIM(C6_INTROT ) ,'[[:cntrl:];"]') C6_INTROT ,
        REGEXP_REPLACE (TRIM(C6_CC     ) ,'[[:cntrl:];"]') C6_CC     ,
        REGEXP_REPLACE (TRIM(C6_CONTA  ) ,'[[:cntrl:];"]') C6_CONTA  ,
        REGEXP_REPLACE (TRIM(C6_ITEMCTA) ,'[[:cntrl:];"]') C6_ITEMCTA,
        REGEXP_REPLACE (TRIM(C6_CLVL   ) ,'[[:cntrl:];"]') C6_CLVL   ,
        REGEXP_REPLACE (TRIM(C6_GCPIT  ) ,'[[:cntrl:];"]') C6_GCPIT  ,
        REGEXP_REPLACE (TRIM(C6_GCPLT  ) ,'[[:cntrl:];"]') C6_GCPLT  ,
        C6_IPITRF ,
        REGEXP_REPLACE (TRIM(C6_TPPROD ) ,'[[:cntrl:];"]') C6_TPPROD ,
        REGEXP_REPLACE (TRIM(C6_CSTPIS ) ,'[[:cntrl:];"]') C6_CSTPIS ,
        C6_XDTCANC,
        C6_XQTDRES,
        REGEXP_REPLACE (TRIM(C6_XMOTCAN) ,'[[:cntrl:];"]') C6_XMOTCAN,
        C6_XQTDVEN,
        REGEXP_REPLACE (TRIM(C6_XNLOT  ) ,'[[:cntrl:];"]') C6_XNLOT  ,
        REGEXP_REPLACE (TRIM(C6_GERMINA) ,'[[:cntrl:];"]') C6_GERMINA,

        A1_NOME,
        e4_descri,
        A3_V1.A3_NOME VEND1,
        A3_V2.A3_NOME VEND2,
        A3_V3.A3_NOME VEND3,
        CASE WHEN F4_DUPLIC = 'S' THEN 'SIM' ELSE 'NAO'END f4_DUPLIC,
        CASE WHEN F4_ESTOQUE = 'S' THEN 'SIM' ELSE 'NAO'END F4_ESTOQUE,
        F4_FINALID TIPO_MOVI,
        X5_CFOP.X5_DESCRI NAT_OPERACAO,
        SAH_UM.ah_descpo AS AH_DESC_UM1,
        SAH_SEGUN.ah_descpo AS AH_DESC_UM2,
        CT1_DESC01,
        CTT_DESC01,
        NNR_DESCRI,
        M0_NOMECOM

    from %table:sc5% c5
        LEFT join %table:SC6% C6 on c5_FILIAL = C6_FILIAL and C5_NUM = C6_NUM and C5_CLIENTE = c6.c6_cli and C5_LOJACLI = c6.c6_loja AND c6.%notdel%
        LEFT join %table:SA1% A1 on c5_CLIENTE = A1_COD and c5_LOJAcli = A1_LOJA and A1.%notdel%
        LEFT join %table:SE4% E4 on substr(c5_FILIAL,1,2) = trim(E4_filial) and c5_CONDpag = E4_CODIGO and E4.%notdel%
        LEFT JOIN %table:SA3% A3_V1 ON C5_FILIAL = A3_V1.A3_FILIAL AND C5_VEND1 = A3_V1.A3_COD  AND a3_v1.%notdel%
        LEFT JOIN %table:SA3% A3_V2 ON C5_FILIAL = A3_V2.A3_FILIAL AND C5_VEND2 = A3_V2.A3_COD  AND a3_v2.%notdel%
        LEFT JOIN %table:SA3% A3_V3 ON C5_FILIAL = A3_V3.A3_FILIAL AND C5_VEND3 = A3_V3.A3_COD  AND a3_v3.%notdel%
        LEFT join %table:SA4% A4 on c5_TRANSP = A4_COD and A4.%notdel%
        LEFT join sys_company M0 on c5_FILIAL = M0_CODFIL and M0.%notdel%
        left join %table:SAH% SAH_UM ON C6_UM = SAH_UM.AH_UNIMED  AND sah_UM.%notdel%
        left join %table:SAH% SAH_SEGUN ON C6_SEGUM = SAH_SEGUN.AH_UNIMED  AND sah_segun.%notdel%
        LEFT JOIN %table:SF4% SF4  ON C6_FILIAL = F4_FILIAL AND C6_TES = SF4.F4_CODIGO AND SF4.%notdel%
        LEFT JOIN %table:SX5% X5_CFOP ON C6_CF = X5_CFOP.X5_CHAVE AND X5_TABELA = '13'
        LEFT JOIN %table:CT1% CT1 ON C6_CONTA = CT1.CT1_CONTA AND CT1.%notdel%
        LEFT JOIN %table:NNR% NNR ON TRIM(SUBSTR(C6_FILIAL,1,4)) = TRIM(NNR_FILIAL) AND C6_LOCAL = NNR_CODIGO AND NNR.%notdel%
        LEFT JOIN %table:CTT% CTT ON C6_FILIAL = CTT_FILIAL and C6_cCUSTO = ctt_custo AND CTT.%notdel%
 
    WHERE c5_FILIAL BETWEEN %Exp:MV_PAR01%  AND %Exp:MV_PAR02%
        AND C5_EMISSAO BETWEEN %Exp:DtoS(MV_PAR03)%  AND %Exp:DtoS(MV_PAR04)% AND C5.%notdel%
   //and rownum<50001

EndSql

_cQuery:=GetLastQuery()

_aStru:=DBSTRUCT()

DBGOTOP()

_nHandle    :=FCREATE(_cArquivo)

IF!EOF()

    HTMLMAIL()

    Whil!Eof()

        If _nReg>_nRegsIt
            //_cNarquivo:=_cArquivo+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
            //ENVARQS(_cNarquivo,_cHtml,"DW - QEPITEM")

            _cNarquivo:=_cTabela+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
            ENVFARQS(_cNarquivo)

            _nSeq   ++
            _nReg   :=1
            _nHandle    :=FCREATE(_cArquivo)
        END

        For x:=1 To Len(_aStru)
    
            If _aStru[x,2]=="C"

                MONTACAMPO()

                FWrite(_nHandle, _cCampo)
            Else
                FWrite(_nHandle, Str(&(_aStru[x,1])))
                FWrite(_nHandle, ';')
            END
        NEXT

        FWrite(_nHandle, CRLF)

        DBSKIP()

        _nReg++

    END

//    _cNarquivo:=_cArquivo+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
//    ENVARQS(_cNarquivo,_cHtml,"DW - QEPITEM")
      
      _cNarquivo:=_cTabela+"_"+Dtos(dDatabase)+"_"+StrZero(_nSeq,2)+".CSV"
      ENVFARQS(_cNarquivo)

else
    GERLOG(_cTabela,_cOrig,"",0)
END
//

/*/{Protheus.doc} QVEPROGCARGA
    Extração de dados de Cargas
    @type  Static Function
    @author user
    Edson Bella Gonçalves - MRC
    @since 03/03/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function QVEPROGCARGA()
    
Local   _aPergs     := {}
Local   _dEmissaoD  := Ctod('  /  /    ')
Local   _dEmissaoA  := Ctod('  /  /    ')

Private _nCadias    := GetMv("EL_DWCGDIA")
Private _nCadiasR   := GetMv("EL_DWCGQD")
Private _cAlias     := GetNextAlias()
Private _nHandle
Private _cTabela    :=  "QVEPROGCARGA"
Private _cArquivo   :=  _cPasta+_cTabela
//Private _cModifI    := ' '
//Private _cModifF    := ' '

If _lNUser
    //_cModifI    := DtoS(date()-_nCadiasR) //CtoD('01/10/2022') //
    //_cModifF    := DtoS(date())
    //MV_PAR01    := CtoD('  /  /    ')
    //MV_PAR02    := CtoD('31/12/2050') //CtoD('31/12/2022'
    MV_PAR01    := DtoS(date()-_nCadiasR) //CtoD('01/10/2022') //
    MV_PAR02    := DtoS(date())
    
else
    aAdd(_aPergs, {1, "Data de ", _dEmissaoD,    "", ".T.", "",".T.", 60,.T.})
    aAdd(_aPergs, {1, "Data até", _dEmissaoA,    "", ".T.", "",".T.", 60,.F.})

    If !ParamBox(_aPergs, "Informe os parâmetros")
        AtuConou('2')
        RETURN .t.
    End
    //_cModifI    := ' '
    //_cModifF    := '99999999'
END

MsAguarde({|| PQVEPROGCARGA()}, "Aguarde...", "Processando Registros "+_cTabela+"...")

AtuConou('4')

Return

//
Static Function PQVEPROGCARGA

AtuConou('3')

BeginSql Alias _cAlias

    SELECT 
        REGEXP_REPLACE (TRIM(DAI_FILIAL) ,'[[:cntrl:];"]')DAI_FILIAL,
        REGEXP_REPLACE (TRIM(DAI_COD   ) ,'[[:cntrl:];"]')DAI_COD   ,
        REGEXP_REPLACE (TRIM(DAI_SEQCAR) ,'[[:cntrl:];"]')DAI_SEQCAR,
        REGEXP_REPLACE (TRIM(DAI_SEQUEN) ,'[[:cntrl:];"]')DAI_SEQUEN,
        REGEXP_REPLACE (TRIM(DAI_CLIENT) ,'[[:cntrl:];"]')DAI_CLIENT,
        REGEXP_REPLACE (TRIM(DAI_LOJA  ) ,'[[:cntrl:];"]')DAI_LOJA  ,
        REGEXP_REPLACE (TRIM(DAI_PEDIDO) ,'[[:cntrl:];"]')DAI_PEDIDO,
        REGEXP_REPLACE (TRIM(DAI_NFISCA) ,'[[:cntrl:];"]')DAI_NFISCA,
        REGEXP_REPLACE (TRIM(DAI_SERIE ) ,'[[:cntrl:];"]')DAI_SERIE ,
        DAI_PESO  ,
        DAI_DATA  ,
        REGEXP_REPLACE (TRIM(DAI_HORA  ) ,'[[:cntrl:];"]')DAI_HORA  ,
        REGEXP_REPLACE (TRIM(DAI_VENDED) ,'[[:cntrl:];"]')DAI_VENDED,
        DAI_CAPVOL,
        REGEXP_REPLACE (TRIM(DAI_PERCUR) ,'[[:cntrl:];"]')DAI_PERCUR,
        REGEXP_REPLACE (TRIM(DAI_ROTA  ) ,'[[:cntrl:];"]')DAI_ROTA  ,
        REGEXP_REPLACE (TRIM(DAI_ROTEIR) ,'[[:cntrl:];"]')DAI_ROTEIR,
        REGEXP_REPLACE (TRIM(DAI_REMITO) ,'[[:cntrl:];"]')DAI_REMITO,
        REGEXP_REPLACE (TRIM(DAI_SERREM) ,'[[:cntrl:];"]')DAI_SERREM,
        DAI_DTCHEG,
        REGEXP_REPLACE (TRIM(DAI_SEQROT) ,'[[:cntrl:];"]')DAI_SEQROT,
        REGEXP_REPLACE (TRIM(DAI_CHEGAD) ,'[[:cntrl:];"]')DAI_CHEGAD,
        REGEXP_REPLACE (TRIM(DAI_CARORI) ,'[[:cntrl:];"]')DAI_CARORI,
        REGEXP_REPLACE (TRIM(DAI_TMSERV) ,'[[:cntrl:];"]')DAI_TMSERV,
        DAI_VALFRE,
        REGEXP_REPLACE (TRIM(DAI_HRSAID) ,'[[:cntrl:];"]')DAI_HRSAID,
        DAI_DTSAID,
        DAI_FREAUT,
        DAI_XDTEMB,
        REGEXP_REPLACE (TRIM(DAI_XHREMB) ,'[[:cntrl:];"]')DAI_XHREMB,
        REGEXP_REPLACE (TRIM(DAI_XUSER ) ,'[[:cntrl:];"]')DAI_XUSER ,
        REGEXP_REPLACE (TRIM(DAI_XTPCAR) ,'[[:cntrl:];"]')DAI_XTPCAR,
        REGEXP_REPLACE (TRIM(DAI_XTPFRE) ,'[[:cntrl:];"]')DAI_XTPFRE,
        REGEXP_REPLACE (TRIM(DAI_USERGI) ,'[[:cntrl:];"]')DAI_USERGI,
        REGEXP_REPLACE (TRIM(DAI_USERGA) ,'[[:cntrl:];"]')DAI_USERGA,
        REGEXP_REPLACE (TRIM(DAI_WSTATU) ,'[[:cntrl:];"]')DAI_WSTATU,
        REGEXP_REPLACE (TRIM(DAI_WMENSA) ,'[[:cntrl:];"]')DAI_WMENSA,
        DAI_WDTRET,
        REGEXP_REPLACE (TRIM(DAI_WMOTOR) ,'[[:cntrl:];"]')DAI_WMOTOR,
        REGEXP_REPLACE (TRIM(DAI_WPLACA) ,'[[:cntrl:];"]')DAI_WPLACA,
        REGEXP_REPLACE (TRIM(DAI_XLMARK) ,'[[:cntrl:];"]')DAI_XLMARK,
        REGEXP_REPLACE (TRIM(DAI_WIDAGE) ,'[[:cntrl:];"]')DAI_WIDAGE,
        REGEXP_REPLACE (TRIM(DAI_XCONFT) ,'[[:cntrl:];"]')DAI_XCONFT,
        DAI_XDTCON,
        REGEXP_REPLACE (TRIM(DAI_XREFAT) ,'[[:cntrl:];"]')DAI_XREFAT,
        DAI_XDESCA,
        REGEXP_REPLACE (TRIM(DAI_XCLFRT) ,'[[:cntrl:];"]')DAI_XCLFRT,
        REGEXP_REPLACE (TRIM(DAI_WTRANS) ,'[[:cntrl:];"]')DAI_WTRANS,
        DAI_XVFFC ,
        DAI_XVFCAL,
        DAI_XVFSIM,
        REGEXP_REPLACE (TRIM(DAI_XDEVOL) ,'[[:cntrl:];"]')DAI_XDEVOL,
        DAI_XDTDEV,
        REGEXP_REPLACE (TRIM(DAI_MSIDEN) ,'[[:cntrl:];"]')DAI_MSIDEN,
        REGEXP_REPLACE (TRIM(DAI_MSEXP ) ,'[[:cntrl:];"]')DAI_MSEXP ,
        REGEXP_REPLACE (TRIM(DAI_SDOC  ) ,'[[:cntrl:];"]')DAI_SDOC  ,
        REGEXP_REPLACE (TRIM(DAI_SDOCRM) ,'[[:cntrl:];"]')DAI_SDOCRM,
        REGEXP_REPLACE (TRIM(DAI_MODIFI) ,'[[:cntrl:];"]')DAI_MODIFI,
        REGEXP_REPLACE (TRIM(DAI_XCORI ) ,'[[:cntrl:];"]')DAI_XCORI ,
        REGEXP_REPLACE (TRIM(DAI_XSORI ) ,'[[:cntrl:];"]')DAI_XSORI ,
        REGEXP_REPLACE (TRIM(DAI_TIMEST) ,'[[:cntrl:];"]')DAI_TIMEST,
        REGEXP_REPLACE (TRIM(DAI_REDESP) ,'[[:cntrl:];"]')DAI_REDESP,
        REGEXP_REPLACE (TRIM(DAK_FILIAL) ,'[[:cntrl:];"]')DAK_FILIAL,
        REGEXP_REPLACE (TRIM(DAK_COD   ) ,'[[:cntrl:];"]')DAK_COD   ,
        REGEXP_REPLACE (TRIM(DAK_SEQCAR) ,'[[:cntrl:];"]')DAK_SEQCAR,
        REGEXP_REPLACE (TRIM(DAK_ROTEIR) ,'[[:cntrl:];"]')DAK_ROTEIR,
        REGEXP_REPLACE (TRIM(DAK_CAMINH) ,'[[:cntrl:];"]')DAK_CAMINH,
        REGEXP_REPLACE (TRIM(DAK_MOTORI) ,'[[:cntrl:];"]')DAK_MOTORI,
        DAK_PESO  ,
        REGEXP_REPLACE (TRIM(DAK_XNOMMO) ,'[[:cntrl:];"]')DAK_XNOMMO,
        DAK_CAPVOL,
        DAK_PTOENT,
        DAK_VALOR ,
        REGEXP_REPLACE (TRIM(DAK_FEZNF ) ,'[[:cntrl:];"]')DAK_FEZNF ,
        DAK_DATA  ,
        REGEXP_REPLACE (TRIM(DAK_HORA  ) ,'[[:cntrl:];"]')DAK_HORA  ,
        REGEXP_REPLACE (TRIM(DAK_JUNTOU) ,'[[:cntrl:];"]')DAK_JUNTOU,
        REGEXP_REPLACE (TRIM(DAK_ACECAR) ,'[[:cntrl:];"]')DAK_ACECAR,
        REGEXP_REPLACE (TRIM(DAK_ACEVAS) ,'[[:cntrl:];"]')DAK_ACEVAS,
        REGEXP_REPLACE (TRIM(DAK_ACEFIN) ,'[[:cntrl:];"]')DAK_ACEFIN,
        REGEXP_REPLACE (TRIM(DAK_AJUDA1) ,'[[:cntrl:];"]')DAK_AJUDA1,
        REGEXP_REPLACE (TRIM(DAK_AJUDA2) ,'[[:cntrl:];"]')DAK_AJUDA2,
        REGEXP_REPLACE (TRIM(DAK_AJUDA3) ,'[[:cntrl:];"]')DAK_AJUDA3,
        DAK_DTACCA,
        REGEXP_REPLACE (TRIM(DAK_OK    ) ,'[[:cntrl:];"]')DAK_OK    ,
        REGEXP_REPLACE (TRIM(DAK_FLGUNI) ,'[[:cntrl:];"]')DAK_FLGUNI,
        DAK_DATENT,
        REGEXP_REPLACE (TRIM(DAK_BLWMS ) ,'[[:cntrl:];"]')DAK_BLWMS ,
        REGEXP_REPLACE (TRIM(DAK_BLQCAR) ,'[[:cntrl:];"]')DAK_BLQCAR,
        REGEXP_REPLACE (TRIM(DAK_HRSTAR) ,'[[:cntrl:];"]')DAK_HRSTAR,
        REGEXP_REPLACE (TRIM(DAK_IDENT ) ,'[[:cntrl:];"]')DAK_IDENT ,
        REGEXP_REPLACE (TRIM(DAK_XOBS  ) ,'[[:cntrl:];"]')DAK_XOBS  ,
        REGEXP_REPLACE (TRIM(DAK_XHREMB) ,'[[:cntrl:];"]')DAK_XHREMB,
        REGEXP_REPLACE (TRIM(DAK_XUSER ) ,'[[:cntrl:];"]')DAK_XUSER ,
        DAK_XDTEMB,
        REGEXP_REPLACE (TRIM(DAK_XTPFRE) ,'[[:cntrl:];"]')DAK_XTPFRE,
        REGEXP_REPLACE (TRIM(DAK_XSENHA) ,'[[:cntrl:];"]')DAK_XSENHA,
        DAK_XDTMOT,
        REGEXP_REPLACE (TRIM(DAK_XHMOTO) ,'[[:cntrl:];"]')DAK_XHMOTO,
        DAK_XDTENT,
        REGEXP_REPLACE (TRIM(DAK_XFLAGC) ,'[[:cntrl:];"]')DAK_XFLAGC,
        DAK_XDAENT,
        REGEXP_REPLACE (TRIM(DAK_XHAENT) ,'[[:cntrl:];"]')DAK_XHAENT,
        REGEXP_REPLACE (TRIM(DAK_XHRENT) ,'[[:cntrl:];"]')DAK_XHRENT,
        DAK_XDTSAI,
        REGEXP_REPLACE (TRIM(DAK_XHRSAI) ,'[[:cntrl:];"]')DAK_XHRSAI,
        REGEXP_REPLACE (TRIM(DAK_XIMPRO) ,'[[:cntrl:];"]')DAK_XIMPRO,
        REGEXP_REPLACE (TRIM(DAK_XAGEND) ,'[[:cntrl:];"]')DAK_XAGEND,
        REGEXP_REPLACE (TRIM(DAK_XTRANS) ,'[[:cntrl:];"]')DAK_XTRANS,
        REGEXP_REPLACE (TRIM(DAK_USERGI) ,'[[:cntrl:];"]')DAK_USERGI,
        REGEXP_REPLACE (TRIM(DAK_USERGA) ,'[[:cntrl:];"]')DAK_USERGA,
        DAK_XPEDAG,
        REGEXP_REPLACE (TRIM(DAK_XCIOT ) ,'[[:cntrl:];"]')DAK_XCIOT ,
        REGEXP_REPLACE (TRIM(DAK_XSTWEB) ,'[[:cntrl:];"]')DAK_XSTWEB,
        DAK_WDTRET,
        REGEXP_REPLACE (TRIM(DAK_XGRCAR) ,'[[:cntrl:];"]')DAK_XGRCAR,
        REGEXP_REPLACE (TRIM(DAK_XLACRE) ,'[[:cntrl:];"]')DAK_XLACRE,
        DAK_XPESOI,
        DAK_XPESOO,
        DAK_XDTAGE,
        REGEXP_REPLACE (TRIM(DAK_XHRAGE) ,'[[:cntrl:];"]')DAK_XHRAGE,
        REGEXP_REPLACE (TRIM(DAK_XTPTRA) ,'[[:cntrl:];"]')DAK_XTPTRA,
        replace(regexp_replace(TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(DAK_XOBSPT,250,1))),'[[:cntrl:];"]'),chr(13))DAK_XOBSPT,
        REGEXP_REPLACE (TRIM(DAK_XSTPT ) ,'[[:cntrl:];"]')DAK_XSTPT ,
        REGEXP_REPLACE (TRIM(DAK_XLMARK) ,'[[:cntrl:];"]')DAK_XLMARK,
        REGEXP_REPLACE (TRIM(DAK_WIDAGE) ,'[[:cntrl:];"]')DAK_WIDAGE,
        DAK_XFRTCB,
        REGEXP_REPLACE (TRIM(DAK_XSTGFE) ,'[[:cntrl:];"]')DAK_XSTGFE,
        REGEXP_REPLACE (TRIM(DAK_XOBSAG) ,'[[:cntrl:];"]')DAK_XOBSAG,
        REGEXP_REPLACE (TRIM(DAK_XCONFT) ,'[[:cntrl:];"]')DAK_XCONFT,
        DAK_XDTCON,
        REGEXP_REPLACE (TRIM(DAK_XREFAT) ,'[[:cntrl:];"]')DAK_XREFAT,
        REGEXP_REPLACE (TRIM(DAK_XWFFC ) ,'[[:cntrl:];"]')DAK_XWFFC ,
        REGEXP_REPLACE (TRIM(DAK_XDIFPE) ,'[[:cntrl:];"]')DAK_XDIFPE,
        REGEXP_REPLACE (TRIM(DAK_XTOLED) ,'[[:cntrl:];"]')DAK_XTOLED,
        REGEXP_REPLACE (TRIM(DAK_XTPAP ) ,'[[:cntrl:];"]')DAK_XTPAP ,
        REGEXP_REPLACE (TRIM(DAK_XAPN1 ) ,'[[:cntrl:];"]')DAK_XAPN1 ,
        DAK_XDTN1 ,
        REGEXP_REPLACE (TRIM(DAK_XHRN1 ) ,'[[:cntrl:];"]')DAK_XHRN1 ,
        REGEXP_REPLACE (TRIM(DAK_XAPN2 ) ,'[[:cntrl:];"]')DAK_XAPN2 ,
        DAK_XDTN2 ,
        REGEXP_REPLACE (TRIM(DAK_XHRN2 ) ,'[[:cntrl:];"]')DAK_XHRN2 ,
        REGEXP_REPLACE (TRIM(DAK_XOBSCA) ,'[[:cntrl:];"]')DAK_XOBSCA,
        REGEXP_REPLACE (TRIM(DAK_XCGDEV) ,'[[:cntrl:];"]')DAK_XCGDEV,
        REGEXP_REPLACE (TRIM(DAK_MSIDEN) ,'[[:cntrl:];"]')DAK_MSIDEN,
        REGEXP_REPLACE (TRIM(DAK_MSEXP ) ,'[[:cntrl:];"]')DAK_MSEXP ,
        REGEXP_REPLACE (TRIM(DAK_XREJEI) ,'[[:cntrl:];"]')DAK_XREJEI,
        REGEXP_REPLACE (TRIM(DAK_XFRTFA) ,'[[:cntrl:];"]')DAK_XFRTFA,
        REGEXP_REPLACE (TRIM(DAK_TRANSP) ,'[[:cntrl:];"]')DAK_TRANSP,
        REGEXP_REPLACE (TRIM(DAK_VIAROT) ,'[[:cntrl:];"]')DAK_VIAROT,
        REGEXP_REPLACE (TRIM(DAK_CDTPOP) ,'[[:cntrl:];"]')DAK_CDTPOP,
        REGEXP_REPLACE (TRIM(DAK_CDCLFR) ,'[[:cntrl:];"]')DAK_CDCLFR,

        REGEXP_REPLACE (TRIM(DAK_MODIFI) ,'[[:cntrl:];"]')DAK_MODIFI,
        REGEXP_REPLACE (TRIM(DAK_XORIGE) ,'[[:cntrl:];"]')DAK_XORIGE,

        REGEXP_REPLACE (TRIM(DAK_XSTATR) ,'[[:cntrl:];"]')DAK_XSTATR,
        REGEXP_REPLACE (TRIM(DAK_VEIC2 ) ,'[[:cntrl:];"]')DAK_VEIC2 ,
        REGEXP_REPLACE (TRIM(DAK_VEIC3 ) ,'[[:cntrl:];"]')DAK_VEIC3 ,
        DAK_QTEIXI,
        DAK_QTEIXV,
        REGEXP_REPLACE (TRIM(DAK_XNUMPR) ,'[[:cntrl:];"]')DAK_XNUMPR,
        A1_NOME,
        A4_NOME

    from %table:DAK% DAK
        LEFT JOIN %table:DAI% DAI ON DAK_FILIAL = DAI_FILIAL AND DAK_COD = DAI_COD  and dai.%notdel%
        LEFT JOIN %table:SA1% SA1 ON DAI_CLIENT = A1_COD AND DAI_LOJA = A1_LOJA AND sa1.%notdel%
        LEFT JOIN %table:SA4% SA4 ON DAK_TRANSP = A4_COD and sa4.%notdel%
 
    where dak.%notdel% AND DAK_DATA BETWEEN %exp:DtoS(MV_PAR01)% AND %exp:Dtos(MV_PAR02)%
    //    AND DAK_MODIFI between %exp:_cModifI% and %exp:_cModifF%
    //and rownum<101
    ORDER BY DAK_MODIFI

EndSql

_cQuery:=GetLastQuery()

_aStru:=DBSTRUCT()

DBGOTOP()

IF!Eof()

    HTMLMAIL()

    _nDemiss    :=0
    _cEmissD    :=DAK_MODIFI
    _cEmissA    :=DAK_MODIFI
    _cEmissAn   :=DAK_MODIFI

    Whil!Eof()

        If DAK_MODIFI<>_cEmissA
            _nDemiss    ++
            _cEmissAn   :=DAK_MODIFI
            _cEmissA    :=DAK_MODIFI
        END

        IF _nDemiss==0 .Or. _nDemiss>_nCadias

            If _nDemiss>_nCadias

                _cNarquivo:=_cTabela+"_"+_cEmissD+"_"+_cEmissAn+".CSV"

                //ENVARQS(_cNarquivo,_cHtml,"DW - QFTNOTASSAIDA")
                ENVFARQS(_cNarquivo)

                _cEmissD:=DAK_MODIFI
                _cEmissA:=DAK_MODIFI

            END

            _nHandle    :=FCREATE(_cArquivo)

            If _nHandle = -1
                conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
            END
            
            _nDemiss    :=1
        End

        For x:=1 To Len(_aStru)
    
            If _aStru[x,2]=="C"

                MONTACAMPO()

                //FWrite(_nHandle, &(_aStru[x,1])+';')
                FWrite(_nHandle, _cCampo)
            Else
                FWrite(_nHandle, Str(&(_aStru[x,1])))
                FWrite(_nHandle, ';')
            END
        NEXT

        FWrite(_nHandle, CRLF)

        DBSKIP()
    END

    _cNarquivo:=_cTabela+"_"+_cEmissD+"_"+_cEmissA+".CSV"

    ENVFARQS(_cNarquivo)

else
    GERLOG(_cTabela,_cOrig,"",0)
END

RETURN

/*/{Protheus.doc} QCPTITPAG
    Extração de dados de ctas a pagar
    @type  Static Function
    @author user
    Edson Bella Gonçalves - MRC
    @since 08/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)@see (links_or_references)
/*/

Static Function QCPTITPAG()
    
Local   _aPergs     := {}
Local   _cFilialDe  := Space(6)
Local   _cFilialAte := Space(6)
Local   _dEmissaoD  := Ctod('  /  /    ')
Local   _dEmissaoA  := Ctod('  /  /    ')

Private _nNfdias    := GetMv("EL_DWCPDIA")
Private _nNfdiasR   := GetMv("EL_DWCPQD")
Private _cAlias     :=  GetNextAlias()
Private _nHandle
Private _cTabela    :=  "QCPTITPAG"
Private _cArquivo   :=  _cPasta+_cTabela
Private _cModifI    := ' '
Private _cModifF    := ' '
//Private _cCampoCom  := ' '

If _lNUser
    _cModifI    := date()-_nNfdiasR //CtoD('01/10/2022') //
    _cModifF    := date() //CtoD('31/12/2022') //

    MV_PAR01    :=  ' '
    MV_PAR02    :=  'ZZZZZZ'
    MV_PAR03    := CtoD('  /  /    ')
    MV_PAR04    := CtoD('31/12/2050')

    //_cCampoCom  := 'E2_XMODIFI'

else
    aAdd(_aPergs, {1, "Filial de",   _cFilialDe,    "", ".T.", "",".T.", 40,.T.})
    aAdd(_aPergs, {1, "Filial até",  _cFilialAte,   "", ".T.", "",".T.", 40,.F.})
    aAdd(_aPergs, {1, "Emissão de",  _dEmissaoD,    "", ".T.", "",".T.", 60,.T.})
    aAdd(_aPergs, {1, "Emissão até", _dEmissaoA,    "", ".T.", "",".T.", 60,.F.})

    If !ParamBox(_aPergs, "Informe os parâmetros")
        AtuConou('2')
        RETURN .t.
    End
    _cModifI    := CtoD('  /  /    ')
    _cModifF    := CtoD('31/12/2050')

    //_cCampoCom  := 'E2_EMISSAO'
END

MsAguarde({|| PQCPTITPAG()}, "Aguarde...", "Processando Registros "+_cTabela+"...")

AtuConou('4')

Return

//
Static Function PQCPTITPAG

AtuConou('3')

BeginSql Alias _cAlias

    SELECT

        REGEXP_REPLACE (TRIM(E2_FILIAL ) ,'[[:cntrl:];"]')E2_FILIAL ,
        REGEXP_REPLACE (TRIM(E2_PREFIXO) ,'[[:cntrl:];"]')E2_PREFIXO,
        REGEXP_REPLACE (TRIM(E2_NUM    ) ,'[[:cntrl:];"]')E2_NUM    ,
        REGEXP_REPLACE (TRIM(E2_PARCELA) ,'[[:cntrl:];"]')E2_PARCELA,
        REGEXP_REPLACE (TRIM(E2_TIPO   ) ,'[[:cntrl:];"]')E2_TIPO   ,
        REGEXP_REPLACE (TRIM(E2_XCODWK ) ,'[[:cntrl:];"]')E2_XCODWK ,
        REGEXP_REPLACE (TRIM(E2_NATUREZ) ,'[[:cntrl:];"]')E2_NATUREZ,
        case when E2_XAPLIC='1' then 'GASTO OPERACIONAL' when E2_XAPLIC='2' then 'ATIVO FIXO' end E2_XAPLIC,
        REGEXP_REPLACE (TRIM(E2_XGESTOR) ,'[[:cntrl:];"]')E2_XGESTOR,
        REGEXP_REPLACE (TRIM(E2_XEVENT ) ,'[[:cntrl:];"]')E2_XEVENT ,
        REGEXP_REPLACE (TRIM(E2_XCCUSTO) ,'[[:cntrl:];"]')E2_XCCUSTO,
        REGEXP_REPLACE (TRIM(E2_XORCAME) ,'[[:cntrl:];"]')E2_XORCAME,
        REGEXP_REPLACE (TRIM(E2_XVERSAO) ,'[[:cntrl:];"]')E2_XVERSAO,
        REGEXP_REPLACE (TRIM(E2_PORTADO) ,'[[:cntrl:];"]')E2_PORTADO,
        REGEXP_REPLACE (TRIM(E2_FORNECE) ,'[[:cntrl:];"]')E2_FORNECE,
        REGEXP_REPLACE (TRIM(E2_LOJA   ) ,'[[:cntrl:];"]')E2_LOJA   ,
        REGEXP_REPLACE (TRIM(E2_NOMFOR ) ,'[[:cntrl:];"]')E2_NOMFOR ,
        E2_EMISSAO,
        E2_VENCTO ,
        E2_VENCREA,
        E2_VALOR  ,
        REGEXP_REPLACE (TRIM(E2_XMODEPG) ,'[[:cntrl:];"]')E2_XMODEPG,
        REGEXP_REPLACE (TRIM(E2_XTIPOPG) ,'[[:cntrl:];"]')E2_XTIPOPG,
        E2_XAPURA ,
        REGEXP_REPLACE (TRIM(E2_XREFERE) ,'[[:cntrl:];"]')E2_XREFERE,
        REGEXP_REPLACE (TRIM(E2_XCOMPET) ,'[[:cntrl:];"]')E2_XCOMPET,
        REGEXP_REPLACE (TRIM(E2_XBANCO ) ,'[[:cntrl:];"]')E2_XBANCO ,
        REGEXP_REPLACE (TRIM(E2_OK     ) ,'[[:cntrl:];"]')E2_OK     ,
        REGEXP_REPLACE (TRIM(E2_NUMBCO ) ,'[[:cntrl:];"]')E2_NUMBCO ,
        REGEXP_REPLACE (TRIM(E2_NUMBOR ) ,'[[:cntrl:];"]')E2_NUMBOR ,
        REGEXP_REPLACE (TRIM(E2_CODBAR ) ,'[[:cntrl:];"]')E2_CODBAR ,
        REGEXP_REPLACE (TRIM(E2_XCODDIG) ,'[[:cntrl:];"]')E2_XCODDIG,
        E2_ISS    ,
        E2_IRRF   ,
        REGEXP_REPLACE (TRIM(E2_INDICE ) ,'[[:cntrl:];"]')E2_INDICE ,
        E2_BAIXA  ,
        REGEXP_REPLACE (TRIM(E2_BCOPAG ) ,'[[:cntrl:];"]')E2_BCOPAG ,
        E2_EMIS1  ,
        REGEXP_REPLACE (TRIM(E2_HIST   ) ,'[[:cntrl:];"]')E2_HIST   ,
        REGEXP_REPLACE (TRIM(E2_LA     ) ,'[[:cntrl:];"]')E2_LA     ,
        REGEXP_REPLACE (TRIM(E2_LOTE   ) ,'[[:cntrl:];"]')E2_LOTE   ,
        REGEXP_REPLACE (TRIM(E2_MOTIVO ) ,'[[:cntrl:];"]')E2_MOTIVO ,
        E2_MOVIMEN,
        REGEXP_REPLACE (TRIM(E2_OP     ) ,'[[:cntrl:];"]')E2_OP     ,
        E2_SALDO  ,
        E2_DESCONT,
        E2_MULTA  ,
        E2_JUROS  ,
        E2_CORREC ,
        E2_VALLIQ ,
        REGEXP_REPLACE (TRIM(E2_PARCIR ) ,'[[:cntrl:];"]')E2_PARCIR ,
        REGEXP_REPLACE (TRIM(E2_ARQRAT ) ,'[[:cntrl:];"]')E2_ARQRAT ,
        E2_VENCORI,
        E2_VALJUR ,
        REGEXP_REPLACE (TRIM(E2_IDENTEE) ,'[[:cntrl:];"]')E2_IDENTEE,
        E2_FLUXO  ,
        REGEXP_REPLACE (TRIM(E2_PARCISS) ,'[[:cntrl:];"]')E2_PARCISS,
        E2_PORCJUR,
        E2_MOEDA  ,
        REGEXP_REPLACE (TRIM(E2_FATPREF) ,'[[:cntrl:];"]')E2_FATPREF,
        REGEXP_REPLACE (TRIM(E2_PARCINS) ,'[[:cntrl:];"]')E2_PARCINS,
        REGEXP_REPLACE (TRIM(E2_FATURA ) ,'[[:cntrl:];"]')E2_FATURA ,
        REGEXP_REPLACE (TRIM(E2_PROJETO) ,'[[:cntrl:];"]')E2_PROJETO,
        REGEXP_REPLACE (TRIM(E2_CLASCON) ,'[[:cntrl:];"]')E2_CLASCON,
        E2_RATEIO ,
        E2_DTVARIA,
        E2_VARURV ,
        E2_VLCRUZ ,
        REGEXP_REPLACE (TRIM(E2_FLAGFAT) ,'[[:cntrl:];"]')E2_FLAGFAT,
        E2_DTFATUR,
        E2_ACRESC ,
        REGEXP_REPLACE (TRIM(E2_TITORIG) ,'[[:cntrl:];"]')E2_TITORIG,
        REGEXP_REPLACE (TRIM(E2_IMPCHEQ) ,'[[:cntrl:];"]')E2_IMPCHEQ,
        REGEXP_REPLACE (TRIM(E2_OCORREN) ,'[[:cntrl:];"]')E2_OCORREN,
        REGEXP_REPLACE (TRIM(E2_ORIGEM ) ,'[[:cntrl:];"]')E2_ORIGEM ,
        REGEXP_REPLACE (TRIM(E2_ORDPAGO) ,'[[:cntrl:];"]')E2_ORDPAGO,
        E2_DESDOBR,
        REGEXP_REPLACE (TRIM(E2_NUMTIT ) ,'[[:cntrl:];"]')E2_NUMTIT ,
        E2_INSS   ,
        REGEXP_REPLACE (TRIM(E2_NUMLIQ ) ,'[[:cntrl:];"]')E2_NUMLIQ ,
        REGEXP_REPLACE (TRIM(E2_BCOCHQ ) ,'[[:cntrl:];"]')E2_BCOCHQ ,
        REGEXP_REPLACE (TRIM(E2_AGECHQ ) ,'[[:cntrl:];"]')E2_AGECHQ ,
        REGEXP_REPLACE (TRIM(E2_CTACHQ ) ,'[[:cntrl:];"]')E2_CTACHQ ,
        E2_DATALIB,
        REGEXP_REPLACE (TRIM(E2_APROVA ) ,'[[:cntrl:];"]')E2_APROVA ,
        REGEXP_REPLACE (TRIM(E2_TIPOFAT) ,'[[:cntrl:];"]')E2_TIPOFAT,
        REGEXP_REPLACE (TRIM(E2_ANOBASE) ,'[[:cntrl:];"]')E2_ANOBASE,
        REGEXP_REPLACE (TRIM(E2_MESBASE) ,'[[:cntrl:];"]')E2_MESBASE,
        E2_TXMOEDA,
        E2_SDACRES,
        REGEXP_REPLACE (TRIM(E2_FILDEB ) ,'[[:cntrl:];"]')E2_FILDEB ,
        E2_DECRESC,
        REGEXP_REPLACE (TRIM(E2_FORNISS) ,'[[:cntrl:];"]')E2_FORNISS,
        REGEXP_REPLACE (TRIM(E2_LOJAISS) ,'[[:cntrl:];"]')E2_LOJAISS,
        E2_SDDECRE,
        REGEXP_REPLACE (TRIM(E2_USUALIB) ,'[[:cntrl:];"]')E2_USUALIB,
        E2_MULTNAT,
        E2_PROJPMS,
        REGEXP_REPLACE (TRIM(E2_PLLOTE ) ,'[[:cntrl:];"]')E2_PLLOTE ,
        E2_DIRF   ,
        REGEXP_REPLACE (TRIM(E2_CODRET ) ,'[[:cntrl:];"]')E2_CODRET ,
        case when E2_MODSPB='1' then 'TED' when E2_MODSPB='2' then 'CIP' when E2_MODSPB='3' then 'COMP' end E2_MODSPB,
        REGEXP_REPLACE (TRIM(E2_IDCNAB ) ,'[[:cntrl:];"]')E2_IDCNAB ,
        REGEXP_REPLACE (TRIM(E2_PARCCSS) ,'[[:cntrl:];"]')E2_PARCCSS,
        E2_RETENC ,
        REGEXP_REPLACE (TRIM(E2_PARCCOF) ,'[[:cntrl:];"]')E2_PARCCOF,
        REGEXP_REPLACE (TRIM(E2_PARCPIS) ,'[[:cntrl:];"]')E2_PARCPIS,
        REGEXP_REPLACE (TRIM(E2_PARCSLL) ,'[[:cntrl:];"]')E2_PARCSLL,
        REGEXP_REPLACE (TRIM(E2_CONTAD ) ,'[[:cntrl:];"]')E2_CONTAD ,
        REGEXP_REPLACE (TRIM(E2_CODORCA) ,'[[:cntrl:];"]')E2_CODORCA,
        E2_SEST   ,
        REGEXP_REPLACE (TRIM(E2_PARCSES) ,'[[:cntrl:];"]')E2_PARCSES,
        REGEXP_REPLACE (TRIM(E2_FILORIG) ,'[[:cntrl:];"]')E2_FILORIG,
        REGEXP_REPLACE (TRIM(E2_DEBITO ) ,'[[:cntrl:];"]')E2_DEBITO ,
        REGEXP_REPLACE (TRIM(E2_CCD    ) ,'[[:cntrl:];"]')E2_CCD    ,
        REGEXP_REPLACE (TRIM(E2_ITEMD  ) ,'[[:cntrl:];"]')E2_ITEMD  ,
        REGEXP_REPLACE (TRIM(E2_CLVLDB ) ,'[[:cntrl:];"]')E2_CLVLDB ,
        REGEXP_REPLACE (TRIM(E2_CREDIT ) ,'[[:cntrl:];"]')E2_CREDIT ,
        REGEXP_REPLACE (TRIM(E2_SEQBX  ) ,'[[:cntrl:];"]')E2_SEQBX  ,
        REGEXP_REPLACE (TRIM(E2_CCC    ) ,'[[:cntrl:];"]')E2_CCC    ,
        REGEXP_REPLACE (TRIM(E2_ITEMC  ) ,'[[:cntrl:];"]')E2_ITEMC  ,
        REGEXP_REPLACE (TRIM(E2_CLVLCR ) ,'[[:cntrl:];"]')E2_CLVLCR ,
        E2_COFINS ,
        E2_PIS    ,
        E2_CSLL   ,
        REGEXP_REPLACE (TRIM(E2_TITPIS ) ,'[[:cntrl:];"]')E2_TITPIS ,
        REGEXP_REPLACE (TRIM(E2_TITCOF ) ,'[[:cntrl:];"]')E2_TITCOF ,
        REGEXP_REPLACE (TRIM(E2_TITCSL ) ,'[[:cntrl:];"]')E2_TITCSL ,
        REGEXP_REPLACE (TRIM(E2_TITINS ) ,'[[:cntrl:];"]')E2_TITINS ,
        E2_VRETPIS,
        E2_VRETCOF,
        E2_VRETCSL,
        REGEXP_REPLACE (TRIM(E2_PRETPIS) ,'[[:cntrl:];"]')E2_PRETPIS,
        REGEXP_REPLACE (TRIM(E2_PRETCOF) ,'[[:cntrl:];"]')E2_PRETCOF,
        REGEXP_REPLACE (TRIM(E2_PRETCSL) ,'[[:cntrl:];"]')E2_PRETCSL,
        E2_BASECOF,
        E2_BASEPIS,
        E2_BASECSL,
        E2_VRETISS,
        E2_VENCISS,
        E2_VBASISS,
        case when E2_MDRTISS='1' then 'Normal' when E2_MDRTISS='2' then 'Por Base' end E2_MDRTISS,
        E2_VARIAC ,
        REGEXP_REPLACE (TRIM(E2_PERIOD ) ,'[[:cntrl:];"]')E2_PERIOD ,
        REGEXP_REPLACE (TRIM(E2_MDCONTR) ,'[[:cntrl:];"]')E2_MDCONTR,
        REGEXP_REPLACE (TRIM(E2_MDREVIS) ,'[[:cntrl:];"]')E2_MDREVIS,
        REGEXP_REPLACE (TRIM(E2_MDPLANI) ,'[[:cntrl:];"]')E2_MDPLANI,
        REGEXP_REPLACE (TRIM(E2_MDCRON ) ,'[[:cntrl:];"]')E2_MDCRON ,
        REGEXP_REPLACE (TRIM(E2_MDPARCE) ,'[[:cntrl:];"]')E2_MDPARCE,
        case when E2_FRETISS='1' then 'Cons.Vlr.Min.' when E2_FRETISS='2' then 'Sempre retém' end E2_FRETISS,
        E2_TXMDCOR,
        REGEXP_REPLACE (TRIM(E2_TITADT ) ,'[[:cntrl:];"]')E2_TITADT ,
        REGEXP_REPLACE (TRIM(E2_TITPAI ) ,'[[:cntrl:];"]')E2_TITPAI ,
        E2_APLVLMN,
        REGEXP_REPLACE (TRIM(E2_CLEARIN) ,'[[:cntrl:];"]')E2_CLEARIN,
        REGEXP_REPLACE (TRIM(E2_PROCPCC) ,'[[:cntrl:];"]')E2_PROCPCC,
        REGEXP_REPLACE (TRIM(E2_FORNPAI) ,'[[:cntrl:];"]')E2_FORNPAI,
        REGEXP_REPLACE (TRIM(E2_HORASPB) ,'[[:cntrl:];"]')E2_HORASPB,
        REGEXP_REPLACE (TRIM(E2_PRETIRF) ,'[[:cntrl:];"]')E2_PRETIRF,
        REGEXP_REPLACE (TRIM(E2_SEFIP  ) ,'[[:cntrl:];"]')E2_SEFIP  ,
        REGEXP_REPLACE (TRIM(E2_TRETISS) ,'[[:cntrl:];"]')E2_TRETISS,
        E2_VRETIRF,
        REGEXP_REPLACE (TRIM(E2_PLOPELT) ,'[[:cntrl:];"]')E2_PLOPELT,
        REGEXP_REPLACE (TRIM(E2_CODRDA ) ,'[[:cntrl:];"]')E2_CODRDA ,
        REGEXP_REPLACE (TRIM(E2_PARCFET) ,'[[:cntrl:];"]')E2_PARCFET,
        E2_FETHAB ,
        REGEXP_REPLACE (TRIM(E2_FORORI ) ,'[[:cntrl:];"]')E2_FORORI ,
        REGEXP_REPLACE (TRIM(E2_LOJORI ) ,'[[:cntrl:];"]')E2_LOJORI ,
        REGEXP_REPLACE (TRIM(E2_FATFOR ) ,'[[:cntrl:];"]')E2_FATFOR ,
        REGEXP_REPLACE (TRIM(E2_STATUS ) ,'[[:cntrl:];"]')E2_STATUS ,
        E2_VRETINS,
        E2_DTDIRF ,
        E2_INSSRET,
        REGEXP_REPLACE (TRIM(E2_CODAGL ) ,'[[:cntrl:];"]')E2_CODAGL ,
        REGEXP_REPLACE (TRIM(E2_CODISS ) ,'[[:cntrl:];"]')E2_CODISS ,
        REGEXP_REPLACE (TRIM(E2_PRETINS) ,'[[:cntrl:];"]')E2_PRETINS,
        REGEXP_REPLACE (TRIM(E2_USUASUS) ,'[[:cntrl:];"]')E2_USUASUS,
        REGEXP_REPLACE (TRIM(E2_USUACAN) ,'[[:cntrl:];"]')E2_USUACAN,
        REGEXP_REPLACE (TRIM(E2_FATLOJ ) ,'[[:cntrl:];"]')E2_FATLOJ ,
        E2_CIDE   ,
        E2_DATASUS,
        E2_DATACAN,
        E2_LIMCAN ,
        REGEXP_REPLACE (TRIM(E2_PARIMP5) ,'[[:cntrl:];"]')E2_PARIMP5,
        REGEXP_REPLACE (TRIM(E2_MSIDENT) ,'[[:cntrl:];"]')E2_MSIDENT,
        E2_BASEISS,
        REGEXP_REPLACE (TRIM(E2_PARIMP3) ,'[[:cntrl:];"]')E2_PARIMP3,
        E2_DTBORDE,
        REGEXP_REPLACE (TRIM(E2_CODINS ) ,'[[:cntrl:];"]')E2_CODINS ,
        REGEXP_REPLACE (TRIM(E2_PARCCID) ,'[[:cntrl:];"]')E2_PARCCID,
        E2_BASEIRF,
        REGEXP_REPLACE (TRIM(E2_PARIMP1) ,'[[:cntrl:];"]')E2_PARIMP1,
        REGEXP_REPLACE (TRIM(E2_PARIMP4) ,'[[:cntrl:];"]')E2_PARIMP4,
        E2_DATAAGE,
        REGEXP_REPLACE (TRIM(E2_PARIMP2) ,'[[:cntrl:];"]')E2_PARIMP2,
        REGEXP_REPLACE (TRIM(E2_NODIA  ) ,'[[:cntrl:];"]')E2_NODIA  ,
        E2_MDBONI ,
        REGEXP_REPLACE (TRIM(E2_CODAPRO) ,'[[:cntrl:];"]')E2_CODAPRO,
        E2_RETCNTR,
        E2_MDMULT ,
        REGEXP_REPLACE (TRIM(E2_PARCAGL) ,'[[:cntrl:];"]')E2_PARCAGL,
        E2_MDDESC ,
        E2_TEMDOCS,
        REGEXP_REPLACE (TRIM(E2_STATLIB) ,'[[:cntrl:];"]')E2_STATLIB,
        REGEXP_REPLACE (TRIM(E2_DIACTB ) ,'[[:cntrl:];"]')E2_DIACTB ,
        E2_BASEINS,
        REGEXP_REPLACE (TRIM(E2_PARCFAB) ,'[[:cntrl:];"]')E2_PARCFAB,
        REGEXP_REPLACE (TRIM(E2_TIPOLIQ) ,'[[:cntrl:];"]')E2_TIPOLIQ,
        REGEXP_REPLACE (TRIM(E2_CODRCSL) ,'[[:cntrl:];"]')E2_CODRCSL,
        REGEXP_REPLACE (TRIM(E2_CODRCOF) ,'[[:cntrl:];"]')E2_CODRCOF,
        REGEXP_REPLACE (TRIM(E2_IDDARF ) ,'[[:cntrl:];"]')E2_IDDARF ,
        REGEXP_REPLACE (TRIM(E2_CODRPIS) ,'[[:cntrl:];"]')E2_CODRPIS,
        REGEXP_REPLACE (TRIM(E2_FIMP   ) ,'[[:cntrl:];"]')E2_FIMP   ,
        REGEXP_REPLACE (TRIM(E2_NFELETR) ,'[[:cntrl:];"]')E2_NFELETR,
        E2_PRINSS ,
        E2_PRISS  ,
        REGEXP_REPLACE (TRIM(E2_NUMPRO ) ,'[[:cntrl:];"]')E2_NUMPRO ,
        case when E2_INDPRO='0' then 'Sefaz' when E2_INDPRO='1' then 'Justiça Federal' when E2_INDPRO='2' then 'Justiça Estadual' when E2_INDPRO='3' then 'Secex/SRF' when E2_INDPRO='9' then 'Outros' end E2_INDPRO,
        E2_FABOV  ,
        REGEXP_REPLACE (TRIM(E2_PREOP  ) ,'[[:cntrl:];"]')E2_PREOP  ,
        REGEXP_REPLACE (TRIM(E2_IDMOV  ) ,'[[:cntrl:];"]')E2_IDMOV  ,
        E2_RATFIN ,
        REGEXP_REPLACE (TRIM(E2_PARCFAC) ,'[[:cntrl:];"]')E2_PARCFAC,
        REGEXP_REPLACE (TRIM(E2_NUMSOL ) ,'[[:cntrl:];"]')E2_NUMSOL ,
        REGEXP_REPLACE (TRIM(E2_CODOPE ) ,'[[:cntrl:];"]')E2_CODOPE ,
        REGEXP_REPLACE (TRIM(E2_AGLIMP ) ,'[[:cntrl:];"]')E2_AGLIMP ,
        E2_FACS   ,
        REGEXP_REPLACE (TRIM(E2_WFID   ) ,'[[:cntrl:];"]')E2_WFID   ,
        REGEXP_REPLACE (TRIM(E2_XOBS   ) ,'[[:cntrl:];"]')E2_XOBS   ,
        REGEXP_REPLACE (TRIM(E2_XDOC   ) ,'[[:cntrl:];"]')E2_XDOC   ,
        REGEXP_REPLACE (TRIM(E2_XSERIE ) ,'[[:cntrl:];"]')E2_XSERIE ,
        REGEXP_REPLACE (TRIM(E2_PARCFAM) ,'[[:cntrl:];"]')E2_PARCFAM,
        REGEXP_REPLACE (TRIM(E2_USERLGI) ,'[[:cntrl:];"]')E2_USERLGI,
        REGEXP_REPLACE (TRIM(E2_USERLGA) ,'[[:cntrl:];"]')E2_USERLGA,
        REGEXP_REPLACE (TRIM(E2_PARCFMP) ,'[[:cntrl:];"]')E2_PARCFMP,
        REGEXP_REPLACE (TRIM(E2_XOBSTA ) ,'[[:cntrl:];"]')E2_XOBSTA ,
        E2_XDOCAPR,
        E2_FAMAD  ,
        E2_FMPEQ  ,
        REGEXP_REPLACE (TRIM(E2_XTPIR  ) ,'[[:cntrl:];"]')E2_XTPIR  ,
        REGEXP_REPLACE (TRIM(E2_XLIBSEN) ,'[[:cntrl:];"]')E2_XLIBSEN,
        REGEXP_REPLACE (TRIM(E2_XCTRSEN) ,'[[:cntrl:];"]')E2_XCTRSEN,
        REGEXP_REPLACE (TRIM(E2_XUSRSOL) ,'[[:cntrl:];"]')E2_XUSRSOL,
        REGEXP_REPLACE (TRIM(E2_XNOMSOL) ,'[[:cntrl:];"]')E2_XNOMSOL,
        REGEXP_REPLACE (TRIM(E2_XUSRAUT) ,'[[:cntrl:];"]')E2_XUSRAUT,
        REGEXP_REPLACE (TRIM(E2_XNOMAUT) ,'[[:cntrl:];"]')E2_XNOMAUT,
        E2_XDTAUTO,
        REGEXP_REPLACE (TRIM(E2_XCATEG ) ,'[[:cntrl:];"]')E2_XCATEG ,
        REGEXP_REPLACE (TRIM(E2_XJSTPCO) ,'[[:cntrl:];"]')E2_XJSTPCO,
        E2_FUNDESA,
        E2_IMAMT  ,
        E2_FASEMT ,
        REGEXP_REPLACE (TRIM(E2_PARFUND) ,'[[:cntrl:];"]')E2_PARFUND,
        REGEXP_REPLACE (TRIM(E2_PARIMA ) ,'[[:cntrl:];"]')E2_PARIMA ,
        REGEXP_REPLACE (TRIM(E2_PARFASE) ,'[[:cntrl:];"]')E2_PARFASE,
        E2_XDTDGCO,
        REGEXP_REPLACE (TRIM(E2_MSEXP  ) ,'[[:cntrl:];"]')E2_MSEXP  ,
        REGEXP_REPLACE (TRIM(E2_MSRESP ) ,'[[:cntrl:];"]')E2_MSRESP ,
        REGEXP_REPLACE (TRIM(E2_DOCHAB ) ,'[[:cntrl:];"]')E2_DOCHAB ,
        REGEXP_REPLACE (TRIM(E2_LINDIG ) ,'[[:cntrl:];"]')E2_LINDIG ,
        E2_DTAPUR ,
        REGEXP_REPLACE (TRIM(E2_NROREF ) ,'[[:cntrl:];"]')E2_NROREF ,
        REGEXP_REPLACE (TRIM(E2_NOMERET) ,'[[:cntrl:];"]')E2_NOMERET,
        REGEXP_REPLACE (TRIM(E2_TPINSC ) ,'[[:cntrl:];"]')E2_TPINSC ,
        REGEXP_REPLACE (TRIM(E2_FORBCO ) ,'[[:cntrl:];"]')E2_FORBCO ,
        REGEXP_REPLACE (TRIM(E2_FCTADV ) ,'[[:cntrl:];"]')E2_FCTADV ,
        REGEXP_REPLACE (TRIM(E2_FAGEDV ) ,'[[:cntrl:];"]')E2_FAGEDV ,
        REGEXP_REPLACE (TRIM(E2_FORAGE ) ,'[[:cntrl:];"]')E2_FORAGE ,
        REGEXP_REPLACE (TRIM(E2_FORCTA ) ,'[[:cntrl:];"]')E2_FORCTA ,
        REGEXP_REPLACE (TRIM(E2_CCUSTO ) ,'[[:cntrl:];"]')E2_CCUSTO ,
        REGEXP_REPLACE (TRIM(E2_FORMPAG) ,'[[:cntrl:];"]')E2_FORMPAG,
        REGEXP_REPLACE (TRIM(E2_RETINS ) ,'[[:cntrl:];"]')E2_RETINS ,
        REGEXP_REPLACE (TRIM(E2_TPESOC ) ,'[[:cntrl:];"]')E2_TPESOC ,
        REGEXP_REPLACE (TRIM(E2_CLVL   ) ,'[[:cntrl:];"]')E2_CLVL   ,
        REGEXP_REPLACE (TRIM(E2_ITEMCTA) ,'[[:cntrl:];"]')E2_ITEMCTA,
        REGEXP_REPLACE (TRIM(E2_CNPJRET) ,'[[:cntrl:];"]')E2_CNPJRET,
        REGEXP_REPLACE (TRIM(E2_CNO    ) ,'[[:cntrl:];"]')E2_CNO    ,
        REGEXP_REPLACE (TRIM(E2_TPDESC ) ,'[[:cntrl:];"]')E2_TPDESC ,
        E2_BTRISS ,
        REGEXP_REPLACE (TRIM(E2_CODSERV) ,'[[:cntrl:];"]')E2_CODSERV,
        E2_VRETBIS,
        REGEXP_REPLACE (TRIM(E2_XPROTES) ,'[[:cntrl:];"]')E2_XPROTES,
        REGEXP_REPLACE (TRIM(E2_XLJPROT) ,'[[:cntrl:];"]')E2_XLJPROT,
        REGEXP_REPLACE (TRIM(E2_MEDNUME) ,'[[:cntrl:];"]')E2_MEDNUME,
        REGEXP_REPLACE (TRIM(E2_PARCIMA) ,'[[:cntrl:];"]')E2_PARCIMA,
        E2_IMA    ,
        REGEXP_REPLACE (TRIM(E2_XIDEXPE) ,'[[:cntrl:];"]')E2_XIDEXPE,

        (select max(A6_NOME) from %table:SA6% A6 WHERE E2_BCOPAG = A6_COD and e2_filial=a6_filial and A6.%notdel%) A6_NOME,
        ccf_descju,
        ctd1.ctd_desc01 ctd_desc01_e2_itemd,
        ctd2.ctd_desc01 ctd_desc01_e2_itemcta,
        ctd3.ctd_desc01 ctd_desc01_e2_itemc,
        ctt1.ctt_desc01 ctt_desc01_e2_ccc,
        ctt2.ctt_desc01 ctt_desc01_e2_ccusto,
        ctt3.ctt_desc01 ctt_desc01_e2_ccd,
        ctt4.ctt_desc01 ctt_desc01_e2_xccusto,
        ct11.ct1_desc01 ctt_desc01_e2_contad,
        ct12.ct1_desc01 ctt_desc01_e2_debito,
        ct13.ct1_desc01 ctt_desc01_e2_credit,
        fim_codmun,
        sa21.A2_COD,


        sa22.A2_NOME,
        ed_descric,
        x5tipo.x5_descri,
        codret.x5_descri,
        codrcsl.x5_descri,
        codrcof.x5_descri,
        codrpis.x5_descri,
        codret.x5_descri,
        codrcsl.x5_descri,
        codrcof.x5_descri,
        codrpis.x5_descri,
        codins.x5_descri,
        clascon.x5_descri,
        projeto.x5_descri,
        xmodepg.x5_descri,
        formpag.x5_descri,
        xtipopg.x5_descri,
        codserv.x5_descri

        FROM %table:SE2% E2

        //left join %table:SA6% A6 on E2_BCOPAG = A6_COD and e2_filial=a6_filial and A6.%notdel% group by E2_BCOPAG
        left join %table:ccf% ccf on e2_numpro=ccf_numero and e2_filial=ccf_filial and ccf.%notdel%
        left join %table:ctd% ctd1 on e2_itemd=ctd1.ctd_item and ctd1.%notdel%
        left join %table:ctd% ctd2 on e2_itemcta=ctd2.ctd_item and ctd2.%notdel%
        left join %table:ctd% ctd3 on e2_itemc=ctd2.ctd_item and ctd3.%notdel%
        left join %table:ctt% ctt1 on e2_ccc=ctt1.ctt_custo and e2_filial=ctt1.ctt_filial and ctt1.%notdel%
        left join %table:ctt% ctt2 on e2_ccusto=ctt2.ctt_custo and e2_filial=ctt2.ctt_filial and ctt2.%notdel%
        left join %table:ctt% ctt3 on e2_ccd=ctt3.ctt_custo and e2_filial=ctt3.ctt_filial and ctt3.%notdel%
        left join %table:ctt% ctt4 on e2_xccusto=ctt4.ctt_custo and e2_filial=ctt3.ctt_filial and ctt4.%notdel%
        left join %table:ct1% ct11 on e2_contad=ct11.ct1_conta and ct11.%notdel%
        left join %table:ct1% ct12 on e2_debito=ct12.ct1_conta and ct11.%notdel%
        left join %table:ct1% ct13 on e2_credit=ct13.ct1_conta and ct11.%notdel%
        left join %table:fim% fim on e2_filial=fim_filial and e2_codiss=fim_codiss and fim.%notdel%
        left join %table:sa2% sa21 on e2_forniss=sa21.a2_cod and sa21.a2_loja =E2_LOJAISS and sa21.%notdel%
        left join %table:sa2% sa22 on e2_fornece=sa22.a2_cod and e2_loja=sa22.a2_loja and sa22.%notdel%
        left join %table:sed% sed on e2_naturez=ed_codigo and sed.%notdel%
        left join %table:sx5% x5tipo on e2_tipo=x5tipo.x5_chave and x5tipo.x5_tabela='05' and x5tipo.%notdel%
        left join %table:sx5% codret on e2_codret=codret.x5_chave and codret.x5_tabela='37' and codret.%notdel%
        left join %table:sx5% codrcsl on e2_codrcsl=codrcsl.x5_chave and codrcsl.x5_tabela='37' and codrcsl.%notdel%
        left join %table:sx5% codrcof on e2_codrcof=codrcof.x5_chave and codrcof.x5_tabela='37' and codrcof.%notdel%
        left join %table:sx5% codrpis on e2_codrpis=codrpis.x5_chave and codrpis.x5_tabela='37' and codrpis.%notdel%
        left join %table:sx5% codins on e2_codins=codins.x5_chave and codins.x5_tabela='38' and codins.%notdel%
        left join %table:sx5% clascon on e2_clascon=clascon.x5_chave and clascon.x5_tabela='51' and clascon.%notdel%
        left join %table:sx5% projeto on e2_projeto=projeto.x5_chave and projeto.x5_tabela='52' and codrpis.%notdel%
        left join %table:sx5% xmodepg on e2_xmodepg=xmodepg.x5_chave and xmodepg.x5_tabela='58' and xmodepg.%notdel%
        left join %table:sx5% formpag on e2_formpag=formpag.x5_chave and formpag.x5_tabela='58' and codrpis.%notdel%
        left join %table:sx5% xtipopg on e2_xtipopg=xtipopg.x5_chave and xtipopg.x5_tabela='59' and xtipopg.%notdel%
        left join %table:sx5% codserv on e2_codserv=codserv.x5_chave and codserv.x5_tabela='60' and codserv.%notdel%

    WHERE E2.%notdel% and E2_FILIAL between %exp:MV_PAR01% and %exp:MV_PAR02%
        AND E2_EMISSAO between %exp:Dtos(MV_PAR03)% and %exp:DtoS(MV_PAR04)%
        AND E2_XMODIFI between %exp:_cModifI% and %exp:_cModifF%
        //and rownum<101

    ORDER BY E2_EMISSAO

EndSql

_cQuery:=GetLastQuery()

_aStru:=DBSTRUCT()

DBGOTOP()

IF!Eof()

    HTMLMAIL()

    _nDemiss:=0
    _cEmissD    :=E2_EMISSAO
    _cEmissA    :=E2_EMISSAO
    _cEmissAn   :=E2_EMISSAO

    Whil!Eof()

        If E2_EMISSAO<>_cEmissA
            _nDemiss    ++
            _cEmissAn   :=_cEmissA
            _cEmissA    :=E2_EMISSAO
        END

        IF _nDemiss==0 .Or. _nDemiss>_nNfdias

            If _nDemiss>_nNfdias

                _cNarquivo:=_cTabela+"_"+_cEmissD+"_"+_cEmissAn+".CSV"

                //ENVARQS(_cNarquivo,_cHtml,"DW - QFTNOTASSAIDA")
                ENVFARQS(_cNarquivo)

                _cEmissD:=E2_EMISSAO
                _cEmissA:=E2_EMISSAO

            END

            _nHandle    :=FCREATE(_cArquivo)

            If _nHandle = -1
                conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
            END
            
            _nDemiss    :=1
        End

        For x:=1 To Len(_aStru)
    
            If _aStru[x,2]=="C"

                MONTACAMPO()

                //FWrite(_nHandle, &(_aStru[x,1])+';')
                FWrite(_nHandle, _cCampo)
            Else
                FWrite(_nHandle, Str(&(_aStru[x,1])))
                FWrite(_nHandle, ';')
            END
        NEXT

        FWrite(_nHandle, CRLF)

        DBSKIP()
    END

    _cNarquivo:=_cTabela+"_"+_cEmissD+"_"+_cEmissA+".CSV"

    ENVFARQS(_cNarquivo)

else
    GERLOG(_cTabela,_cOrig,"",0)
END

RETURN

/*/{Protheus.doc} QLOPEDCOMPRA
    Extração de dados de pedidos de compras
    @type  Static Function
    @author user
    Edson Bella Gonçalves - MRC
    @since 09/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)@see (links_or_references)
/*/

Static Function QLOPEDCOMPRA()
    
Local   _aPergs     := {}
Local   _cFilialDe  := Space(6)
Local   _cFilialAte := Space(6)
Local   _dEmissaoD  := Ctod('  /  /    ')
Local   _dEmissaoA  := Ctod('  /  /    ')

Private _nNfdias    := GetMv("EL_DWPCDIA")
Private _nNfdiasR   := GetMv("EL_DWPCQD")
Private _cAlias     :=  GetNextAlias()
Private _nHandle
Private _cTabela    :=  "QLOPEDCOMPRA"
Private _cArquivo   :=  _cPasta+_cTabela

If _lNUser
    MV_PAR01    :=  ' '
    MV_PAR02    :=  'ZZZZZZ'
    MV_PAR03    :=  date()-_nNfdiasR //CtoD('01/10/2022') //
    MV_PAR04    :=  date() //CtoD('31/12/2022') //

else
    aAdd(_aPergs, {1, "Filial de",   _cFilialDe,    "", ".T.", "",".T.", 40,.T.})
    aAdd(_aPergs, {1, "Filial até",  _cFilialAte,   "", ".T.", "",".T.", 40,.F.})
    aAdd(_aPergs, {1, "Emissão de",  _dEmissaoD,    "", ".T.", "",".T.", 60,.T.})
    aAdd(_aPergs, {1, "Emissão até", _dEmissaoA,    "", ".T.", "",".T.", 60,.F.})

    If !ParamBox(_aPergs, "Informe os parâmetros")
        AtuConou('2')
        RETURN .t.
    End

END

MsAguarde({|| PQLOPEDCOMPRA()}, "Aguarde...", "Processando Registros "+_cTabela+"...")

AtuConou('4')

Return

//
Static Function PQLOPEDCOMPRA

AtuConou('3')

cQuery:="SELECT "
cQuery+="REGEXP_REPLACE (TRIM(C7_FILIAL ),'[[:cntrl:];"+'"'+"]')C7_FILIAL, "
cQuery+="C7_TIPO, "
cQuery+="REGEXP_REPLACE (TRIM(C7_XREGULA),'[[:cntrl:];"+'"'+"]')C7_XREGULA, "
cQuery+="REGEXP_REPLACE (TRIM(C7_ITEM   ),'[[:cntrl:];"+'"'+"]')C7_ITEM, "
cQuery+="REGEXP_REPLACE (TRIM(C7_PRODUTO),'[[:cntrl:];"+'"'+"]')C7_PRODUTO, "
cQuery+="REGEXP_REPLACE (TRIM(C7_DESCRI ),'[[:cntrl:];"+'"'+"]') C7_DESCRI, "
cQuery+="REGEXP_REPLACE (TRIM(C7_UM     ),'[[:cntrl:];"+'"'+"]') C7_UM, "
cQuery+="REGEXP_REPLACE (TRIM(C7_XMARCA ),'[[:cntrl:];"+'"'+"]') C7_XMARCA, "
cQuery+="REGEXP_REPLACE (TRIM(C7_CODTAB ),'[[:cntrl:];"+'"'+"]') C7_CODTAB, "
cQuery+="C7_QUANT, "
cQuery+="C7_PRECO, "
cQuery+="C7_TOTAL, "
cQuery+="REGEXP_REPLACE (TRIM(C7_SEGUM  ) ,'[[:cntrl:];"+'"'+"]') C7_SEGUM, "
cQuery+="C7_XDTORIG, "
cQuery+="C7_DATPRF, "
cQuery+="case when C7_XAPLIC = '1' THEN 'GASTO OPERACIONAL' when C7_XAPLIC = '2' THEN 'ATIVO FIXO' when C7_XAPLIC = '3' THEN 'VARIAVEL' end C7_XAPLIC, "
cQuery+="REGEXP_REPLACE (TRIM(C7_XGESTOR) ,'[[:cntrl:];"+'"'+"]') C7_XGESTOR, "
cQuery+="REGEXP_REPLACE (TRIM(C7_XEVENT ) ,'[[:cntrl:];"+'"'+"]') C7_XEVENT, "
cQuery+="REGEXP_REPLACE (TRIM(C7_CC     ) ,'[[:cntrl:];"+'"'+"]') C7_CC, "
cQuery+="C7_QTSEGUM, "
cQuery+="REGEXP_REPLACE (TRIM(C7_COND   ) ,'[[:cntrl:];"+'"'+"]') C7_COND, "
cQuery+="REGEXP_REPLACE (TRIM(C7_CONTATO) ,'[[:cntrl:];"+'"'+"]') C7_CONTATO, "
cQuery+="REGEXP_REPLACE (TRIM(C7_XVERSAO) ,'[[:cntrl:];"+'"'+"]') C7_XVERSAO, "
cQuery+="C7_DESC, "
cQuery+="C7_VLDESC, "
cQuery+="C7_EMISSAO, "
cQuery+="REGEXP_REPLACE (TRIM(C7_NUM    ) ,'[[:cntrl:];"+'"'+"]') C7_NUM, "
cQuery+="REGEXP_REPLACE (TRIM(C7_XORCAME) ,'[[:cntrl:];"+'"'+"]') C7_XORCAME, "
cQuery+="C7_IPI, "
cQuery+="CASE WHEN C7_XURGEN = '1' THEN 'BAIXA' WHEN C7_XURGEN = '1' THEN 'MEDIA' WHEN C7_XURGEN = '1' THEN 'ALTA' END C7_XURGEN , "
cQuery+="REGEXP_REPLACE (TRIM(C7_COMPRA) ,'[[:cntrl:];"+'"'+"]') C7_COMPRA, "
cQuery+="REGEXP_REPLACE (TRIM(C7_LOCAL) ,'[[:cntrl:];"+'"'+"]') C7_LOCAL, "
cQuery+="REGEXP_REPLACE (TRIM(C7_OBS) ,'[[:cntrl:];"+'"'+"]') C7_OBS, "
cQuery+="REGEXP_REPLACE (TRIM(C7_NUMSC) ,'[[:cntrl:];"+'"'+"]') C7_NUMSC, "
cQuery+="REGEXP_REPLACE (TRIM(C7_ITEMSC) ,'[[:cntrl:];"+'"'+"]') C7_ITEMSC, "
cQuery+="REGEXP_REPLACE (TRIM(C7_NUMCOT) ,'[[:cntrl:];"+'"'+"]') C7_NUMCOT, "
cQuery+="REGEXP_REPLACE (TRIM(C7_FORNECE) ,'[[:cntrl:];"+'"'+"]') C7_FORNECE, "
cQuery+="REGEXP_REPLACE (TRIM(C7_TX) ,'[[:cntrl:];"+'"'+"]') C7_TX, "
cQuery+="REGEXP_REPLACE (TRIM(C7_CONTA) ,'[[:cntrl:];"+'"'+"]') C7_CONTA, "
cQuery+="REGEXP_REPLACE (TRIM(C7_ENCER) ,'[[:cntrl:];"+'"'+"]') C7_ENCER, "
cQuery+="REGEXP_REPLACE (TRIM(C7_OP) ,'[[:cntrl:];"+'"'+"]') C7_OP, "
cQuery+="REGEXP_REPLACE (TRIM(C7_ITEMCTA) ,'[[:cntrl:];"+'"'+"]') C7_ITEMCTA, "
cQuery+="REGEXP_REPLACE (TRIM(C7_LOJA) ,'[[:cntrl:];"+'"'+"]') C7_LOJA, "
cQuery+="REGEXP_REPLACE (TRIM(C7_FILENT) ,'[[:cntrl:];"+'"'+"]') C7_FILENT, "
cQuery+="C7_DESC1 , "
cQuery+="C7_DESC2 , "
cQuery+="C7_DESC3 , "
cQuery+="C7_QUJE  , "
cQuery+="REGEXP_REPLACE (TRIM(C7_REAJUST) ,'[[:cntrl:];"+'"'+"]') C7_REAJUST, "
cQuery+="C7_FRETE , "
cQuery+="REGEXP_REPLACE (TRIM(C7_EMITIDO) ,'[[:cntrl:];"+'"'+"]') C7_EMITIDO, "
cQuery+="REGEXP_REPLACE (TRIM(C7_TPFRETE) ,'[[:cntrl:];"+'"'+"]') C7_TPFRETE, "
cQuery+="C7_QTDREEM, "
cQuery+="REGEXP_REPLACE (TRIM(C7_CODLIB ) ,'[[:cntrl:];"+'"'+"]') C7_CODLIB , "
cQuery+="REGEXP_REPLACE (TRIM(C7_RESIDUO) ,'[[:cntrl:];"+'"'+"]') C7_RESIDUO, "
cQuery+="REGEXP_REPLACE (TRIM(C7_MSG) ,'[[:cntrl:];"+'"'+"]') C7_MSG, "
cQuery+="REGEXP_REPLACE (TRIM(C7_CONTROL) ,'[[:cntrl:];"+'"'+"]') C7_CONTROL, "
cQuery+="REGEXP_REPLACE (TRIM(C7_IPIBRUT) ,'[[:cntrl:];"+'"'+"]') C7_IPIBRUT, "
cQuery+="REGEXP_REPLACE (TRIM(C7_SEQUEN ) ,'[[:cntrl:];"+'"'+"]') C7_SEQUEN , "
cQuery+="REGEXP_REPLACE (TRIM(C7_NUMIMP ) ,'[[:cntrl:];"+'"'+"]') C7_NUMIMP , "
cQuery+="REGEXP_REPLACE (TRIM(C7_ORIGEM ) ,'[[:cntrl:];"+'"'+"]') C7_ORIGEM , "
cQuery+="C7_QTDACLA, "
cQuery+="C7_VALEMB, "
cQuery+="REGEXP_REPLACE (TRIM(C7_FLUXO) ,'[[:cntrl:];"+'"'+"]') C7_FLUXO, "
cQuery+="REGEXP_REPLACE (TRIM(C7_TPOP) ,'[[:cntrl:];"+'"'+"]') C7_TPOP, "
cQuery+="REGEXP_REPLACE (TRIM(C7_APROV) ,'[[:cntrl:];"+'"'+"]') C7_APROV, "
cQuery+="REGEXP_REPLACE (TRIM(C7_CONAPRO) ,'[[:cntrl:];"+'"'+"]') C7_CONAPRO, "
cQuery+="C7_TXMOEDA, "
cQuery+="REGEXP_REPLACE (TRIM(C7_GRUPCOM) ,'[[:cntrl:];"+'"'+"]') C7_GRUPCOM, "
cQuery+="REGEXP_REPLACE (TRIM(C7_USER) ,'[[:cntrl:];"+'"'+"]') C7_USER, "
cQuery+="REGEXP_REPLACE (TRIM(C7_STATME) ,'[[:cntrl:];"+'"'+"]') C7_STATME , "
cQuery+="REGEXP_REPLACE (TRIM(C7_OK) ,'[[:cntrl:];"+'"'+"]') C7_OK, "
cQuery+="C7_QTDSOL, "
cQuery+="C7_VALIPI, "
cQuery+="C7_VALICM, "
cQuery+="REGEXP_REPLACE (TRIM(C7_TES) ,'[[:cntrl:];"+'"'+"]') C7_TES, "
cQuery+="C7_PICM, "
cQuery+="REGEXP_REPLACE (TRIM(C7_ESTOQUE) ,'[[:cntrl:];"+'"'+"]') C7_ESTOQUE, "
cQuery+="C7_VALSOL, "
cQuery+="REGEXP_REPLACE (TRIM(C7_SEQMRP) ,'[[:cntrl:];"+'"'+"]') C7_SEQMRP, "
cQuery+="C7_BASEICM, "
cQuery+="C7_BASEIPI, "
cQuery+="C7_SEGURO , "
cQuery+="C7_DESPESA, "
cQuery+="C7_VALFRE, "
cQuery+="REGEXP_REPLACE (TRIM(C7_CONTRA) ,'[[:cntrl:];"+'"'+"]') C7_CONTRA, "
cQuery+="REGEXP_REPLACE (TRIM(C7_CONTREV) ,'[[:cntrl:];"+'"'+"]') C7_CONTREV, "
cQuery+="REGEXP_REPLACE (TRIM(C7_PLANILH) ,'[[:cntrl:];"+'"'+"]') C7_PLANILH, "
cQuery+="REGEXP_REPLACE (TRIM(C7_MEDICAO) ,'[[:cntrl:];"+'"'+"]') C7_MEDICAO, "
cQuery+="REGEXP_REPLACE (TRIM(C7_ITEMED) ,'[[:cntrl:];"+'"'+"]') C7_ITEMED , "
cQuery+="C7_MOEDA  , "
cQuery+="case when C7_POLREPR = 'N' THEN 'MANUAL' when C7_POLREPR = 'S' THEN 'C/PERIODO FIRME' when C7_POLREPR = 'E' THEN 'S/PERIODO FIRME' when C7_POLREPR = 'M' THEN 'CUSTOMIZADA' end C7_POLREPR, "
cQuery+="REGEXP_REPLACE (TRIM(C7_PENDEN) ,'[[:cntrl:];"+'"'+"]') C7_PENDEN, "
cQuery+="REGEXP_REPLACE (TRIM(C7_CLVL) ,'[[:cntrl:];"+'"'+"]') C7_CLVL, "
cQuery+="C7_BASEIR, "
cQuery+="REGEXP_REPLACE (TRIM(C7_GRADE) ,'[[:cntrl:];"+'"'+"]') C7_GRADE, "
cQuery+="REGEXP_REPLACE (TRIM(C7_ITEMGRD) ,'[[:cntrl:];"+'"'+"]') C7_ITEMGRD, "
cQuery+="C7_ALIQIR, "
cQuery+="C7_VALIR, "
cQuery+="C7_ICMCOMP, "
cQuery+="C7_ICMSRET, "
cQuery+="REGEXP_REPLACE (TRIM(C7_CODORCA) ,'[[:cntrl:];"+'"'+"]') C7_CODORCA, "
cQuery+="C7_DTLANC , "
cQuery+="REGEXP_REPLACE (TRIM(C7_CODCRED) ,'[[:cntrl:];"+'"'+"]') C7_CODCRED, "
cQuery+="CASE WHEN C7_TIPOEMP = '1' THEN 'DISPENSADA' WHEN C7_TIPOEMP = '2' THEN 'TOMADA DE PRECO' WHEN C7_TIPOEMP = '3' THEN 'CONCORRENCIA' WHEN C7_TIPOEMP = '4' THEN 'CARTA CONVITE' WHEN C7_TIPOEMP = '5' THEN 'OUTRA' END C7_TIPOEMP, "
cQuery+="REGEXP_REPLACE (TRIM(C7_ESPEMP ) ,'[[:cntrl:];"+'"'+"]') C7_ESPEMP , "
cQuery+="case when C7_FREPPCC = 'PP' then 'COLLECT' when C7_FREPPCC = 'PP' then 'PREPAID' end C7_FREPPCC, "
cQuery+="C7_PERREPR, "
cQuery+="C7_DT_IMP , "
cQuery+="REGEXP_REPLACE (TRIM(C7_AGENTE ) ,'[[:cntrl:];"+'"'+"]') C7_AGENTE , "
cQuery+="REGEXP_REPLACE (TRIM(C7_FORWARD) ,'[[:cntrl:];"+'"'+"]') C7_FORWARD, "
cQuery+="REGEXP_REPLACE (TRIM(C7_TIPO_EM) ,'[[:cntrl:];"+'"'+"]') C7_TIPO_EM, "
cQuery+="REGEXP_REPLACE (TRIM(C7_ORIGIMP) ,'[[:cntrl:];"+'"'+"]') C7_ORIGIMP, "
cQuery+="REGEXP_REPLACE (TRIM(C7_DEST   ) ,'[[:cntrl:];"+'"'+"]') C7_DEST   , "
cQuery+="C7_PESO_B , "
cQuery+="REGEXP_REPLACE (TRIM(C7_INCOTER) ,'[[:cntrl:];"+'"'+"]') C7_INCOTER, "
cQuery+="REGEXP_REPLACE (TRIM(C7_IMPORT ) ,'[[:cntrl:];"+'"'+"]') C7_IMPORT , "
cQuery+="REGEXP_REPLACE (TRIM(C7_CONSIG ) ,'[[:cntrl:];"+'"'+"]') C7_CONSIG , "
cQuery+="C7_CONF_PE, "
cQuery+="REGEXP_REPLACE (TRIM(C7_DESP   ) ,'[[:cntrl:];"+'"'+"]') C7_DESP   , "
cQuery+="C7_BASESOL, "
cQuery+="REGEXP_REPLACE (TRIM(C7_DIACTB ) ,'[[:cntrl:];"+'"'+"]') C7_DIACTB , "
cQuery+="REGEXP_REPLACE (TRIM(C7_NODIA  ) ,'[[:cntrl:];"+'"'+"]') C7_NODIA  , "
cQuery+="REGEXP_REPLACE (TRIM(C7_CODED  ) ,'[[:cntrl:];"+'"'+"]') C7_CODED  , "
cQuery+="REGEXP_REPLACE (TRIM(C7_EXPORTA) ,'[[:cntrl:];"+'"'+"]') C7_EXPORTA, "
cQuery+="REGEXP_REPLACE (TRIM(C7_NUMPR  ) ,'[[:cntrl:];"+'"'+"]') C7_NUMPR  , "
cQuery+="REGEXP_REPLACE (TRIM(C7_LOJAEXP) ,'[[:cntrl:];"+'"'+"]') C7_LOJAEXP, "
cQuery+="REGEXP_REPLACE (TRIM(C7_FILCEN ) ,'[[:cntrl:];"+'"'+"]') C7_FILCEN , "
cQuery+="CASE WHEN C7_RATEIO = '1' THEN 'SIM' WHEN C7_RATEIO = '2' THEN 'NAO' END C7_RATEIO , "
cQuery+="REGEXP_REPLACE (TRIM(C7_CONTAIN) ,'[[:cntrl:];"+'"'+"]') C7_CONTAIN, "
cQuery+="C7_MT3    , "
cQuery+="C7_CONTA20, "
cQuery+="C7_CONTA40, "
cQuery+="C7_CON40HC, "
cQuery+="REGEXP_REPLACE (TRIM(C7_ARMAZEM) ,'[[:cntrl:];"+'"'+"]') C7_ARMAZEM, "
cQuery+="REGEXP_REPLACE (TRIM(C7_FABRICA) ,'[[:cntrl:];"+'"'+"]') C7_FABRICA, "
cQuery+="REGEXP_REPLACE (TRIM(C7_LOJFABR) ,'[[:cntrl:];"+'"'+"]') C7_LOJFABR, "
cQuery+="C7_DT_EMB , "
cQuery+="REGEXP_REPLACE (TRIM(C7_TEC    ) ,'[[:cntrl:];"+'"'+"]') C7_TEC    , "
cQuery+="REGEXP_REPLACE (TRIM(C7_EX_NCM ) ,'[[:cntrl:];"+'"'+"]') C7_EX_NCM , "
cQuery+="REGEXP_REPLACE (TRIM(C7_EX_NBM ) ,'[[:cntrl:];"+'"'+"]') C7_EX_NBM , "
cQuery+="REGEXP_REPLACE (TRIM(C7_IDTSS  ) ,'[[:cntrl:];"+'"'+"]') C7_IDTSS  , "
cQuery+="REGEXP_REPLACE (TRIM(C7_TPCOLAB) ,'[[:cntrl:];"+'"'+"]') C7_TPCOLAB, "
cQuery+="REGEXP_REPLACE (TRIM(C7_PO_EIC ) ,'[[:cntrl:];"+'"'+"]') C7_PO_EIC , "
cQuery+="REGEXP_REPLACE (TRIM(C7_NUMSA  ) ,'[[:cntrl:];"+'"'+"]') C7_NUMSA  , "
cQuery+="REGEXP_REPLACE (TRIM(C7_ACCPROC) ,'[[:cntrl:];"+'"'+"]') C7_ACCPROC, "
cQuery+="C7_ALIQISS, "
cQuery+="C7_VALISS , "
cQuery+="C7_BASECSL, "
cQuery+="C7_ALQCSL , "
cQuery+="C7_VALINS , "
cQuery+="C7_ALIQINS, "
cQuery+="REGEXP_REPLACE (TRIM(C7_CODRDA ) ,'[[:cntrl:];"+'"'+"]') C7_CODRDA , "
cQuery+="REGEXP_REPLACE (TRIM(C7_LOTPLS ) ,'[[:cntrl:];"+'"'+"]') C7_LOTPLS , "
cQuery+="C7_VALCSL , "
cQuery+="C7_BASEISS, "
cQuery+="REGEXP_REPLACE (TRIM(C7_ACCNUM ) ,'[[:cntrl:];"+'"'+"]') C7_ACCNUM , "
cQuery+="CASE when C7_RATFIN = '1' THEN 'SIM' when C7_RATFIN = '2' THEN 'NAO' END C7_RATFIN , "
cQuery+="C7_BASEINS, "
cQuery+="REGEXP_REPLACE (TRIM(C7_ACCITEM) ,'[[:cntrl:];"+'"'+"]') C7_ACCITEM, "
cQuery+="REGEXP_REPLACE (TRIM(C7_USERLGI) ,'[[:cntrl:];"+'"'+"]') C7_USERLGI, "
cQuery+="REGEXP_REPLACE (TRIM(C7_USERLGA) ,'[[:cntrl:];"+'"'+"]') C7_USERLGA, "
cQuery+="REGEXP_REPLACE (TRIM(C7_XOBSUSE) ,'[[:cntrl:];"+'"'+"]')  c7_obsuse, "
cQuery+="C7_DINICQ , "
cQuery+="C7_DINITRA, "
cQuery+="C7_DINICOM, "
cQuery+="REGEXP_REPLACE (TRIM(C7_RESREM ) ,'[[:cntrl:];"+'"'+"]') C7_RESREM , "
cQuery+="REGEXP_REPLACE (TRIM(C7_REVISAO) ,'[[:cntrl:];"+'"'+"]') C7_REVISAO, "
cQuery+="REGEXP_REPLACE (TRIM(C7_FISCORI) ,'[[:cntrl:];"+'"'+"]') C7_FISCORI, "
cQuery+="REGEXP_REPLACE (TRIM(C7_XUAPROV) ,'[[:cntrl:];"+'"'+"]') C7_XUAPROV, "
cQuery+="REGEXP_REPLACE (TRIM(C7_XDHAPRO) ,'[[:cntrl:];"+'"'+"]') C7_XDHAPRO, "
cQuery+="REGEXP_REPLACE (TRIM(C7_XJSTPCO) ,'[[:cntrl:];"+'"'+"]') C7_XJSTPCO, "
cQuery+="REGEXP_REPLACE (TRIM(C7_XOBSDIR) ,'[[:cntrl:];"+'"'+"]') C7_XOBSDIR, "
cQuery+="REGEXP_REPLACE (TRIM(C7_XBLQAPR) ,'[[:cntrl:];"+'"'+"]') C7_XBLQAPR, "
cQuery+="REGEXP_REPLACE (TRIM(C7_XBLQUSR) ,'[[:cntrl:];"+'"'+"]') C7_XBLQUSR, "
cQuery+="REGEXP_REPLACE (TRIM(C7_MSEXP  ) ,'[[:cntrl:];"+'"'+"]') C7_MSEXP  , "
cQuery+="REGEXP_REPLACE (TRIM(C7_MSRESP ) ,'[[:cntrl:];"+'"'+"]') C7_MSRESP , "
cQuery+="REGEXP_REPLACE (TRIM(C7_XTRANS ) ,'[[:cntrl:];"+'"'+"]') C7_XTRANS , "
cQuery+="REGEXP_REPLACE (TRIM(C7_XNOMTR ) ,'[[:cntrl:];"+'"'+"]') C7_XNOMTR , "
cQuery+="REGEXP_REPLACE (TRIM(C7_OBSM) ,'[[:cntrl:];"+'"'+"]')  c7_OBSM   , "
cQuery+="case when C7_XANEXO = '1' then 'SIM' WHEN C7_XANEXO = '2' THEN 'NAO' end C7_XANEXO , "
cQuery+="REGEXP_REPLACE (TRIM(C7_XPCMAIL) ,'[[:cntrl:];"+'"'+"]') C7_XPCMAIL, "
cQuery+="REGEXP_REPLACE (TRIM(C7_SOLICIT) ,'[[:cntrl:];"+'"'+"]') C7_SOLICIT, "
cQuery+="REGEXP_REPLACE (TRIM(C7_XPCMAI2) ,'[[:cntrl:];"+'"'+"]') C7_XPCMAI2, "
cQuery+="C7_XPCDTMA, "
cQuery+="REGEXP_REPLACE (TRIM(C7_FILEDT ) ,'[[:cntrl:];"+'"'+"]') C7_FILEDT , "
cQuery+="REGEXP_REPLACE (TRIM(C7_CODNE  ) ,'[[:cntrl:];"+'"'+"]') C7_CODNE  , "
cQuery+="REGEXP_REPLACE (TRIM(C7_ITEMNE ) ,'[[:cntrl:];"+'"'+"]') C7_ITEMNE , "
cQuery+="REGEXP_REPLACE (TRIM(C7_GCPIT  ) ,'[[:cntrl:];"+'"'+"]') C7_GCPIT  , "
cQuery+="REGEXP_REPLACE (TRIM(C7_GCPLT  ) ,'[[:cntrl:];"+'"'+"]') C7_GCPLT  , "
cQuery+="REGEXP_REPLACE (TRIM(C7_TIPCOM ) ,'[[:cntrl:];"+'"'+"]') C7_TIPCOM , "
cQuery+="REGEXP_REPLACE (TRIM(C7_PLOPELT) ,'[[:cntrl:];"+'"'+"]') C7_PLOPELT, "
cQuery+="C7_BASIMP5, "
cQuery+="C7_BASIMP6, "
cQuery+="C7_VALIMP5, "
cQuery+="C7_VALIMP6, "
cQuery+="REGEXP_REPLACE (TRIM(C7_XACOMPA) ,'[[:cntrl:];"+'"'+"]') C7_XACOMPA, "
cQuery+="C7_DEDUCAO, "
cQuery+="C7_QUJERET, "
cQuery+="REGEXP_REPLACE (TRIM(C7_XOBS) ,'[[:cntrl:];"+'"'+"]') c7_xobs   , "
cQuery+="C7_QUJEDED, "
cQuery+="REGEXP_REPLACE (TRIM(C7_TRANSP ) ,'[[:cntrl:];"+'"'+"]') C7_TRANSP , "
cQuery+="C7_FATDIRE, "
cQuery+="C7_FRETCON, "
cQuery+="C7_RETENCA, "
cQuery+="C7_QUJEFAT, "
cQuery+="REGEXP_REPLACE (TRIM(C7_IDTRIB ) ,'[[:cntrl:];"+'"'+"]') C7_IDTRIB , "
cQuery+="REGEXP_REPLACE (TRIM(C7_TRANSLJ) ,'[[:cntrl:];"+'"'+"]') C7_TRANSLJ, "
cQuery+="C7_ALQPS2,  "
cQuery+="C7_ALQCF2 , "
cQuery+="C7_BASCOF , "
cQuery+="C7_ALQPIS , "
cQuery+="C7_ALQCOF ,  "
cQuery+="C7_VALPIS , "
cQuery+="C7_VALCOF,  "
cQuery+="C7_BASPIS, "
cQuery+="REGEXP_REPLACE (TRIM(B1_DESC ) ,'[[:cntrl:];"+'"'+"]') B1_DESC, "
cQuery+="ctt_desc01,  "
cQuery+="E4_DESCRI,  "
cQuery+="Y1_NOME,  "
cQuery+="A2_NOME,  "
cQuery+="CT1_DESC01,  "
cQuery+="F4_FINALID, "
cQuery+="A4_NOME "

cQuery+="FROM SC7010 SC7 "
cQuery+="LEFT JOIN SB1010 SB1 ON C7_PRODUTO = B1_COD AND sb1.D_E_L_E_T_=' ' "
cQuery+="LEFT JOIN CTT010 CTT ON C7_CC = CTT_CUSTO AND C7_FILIAL = CTT_FILIAL AND ctt.D_E_L_E_T_=' ' "
cQuery+="LEFT JOIN SE4010 SE4 ON C7_COND = E4_CODIGO AND TRIM(SUBSTR(C7_FILIAL,1,2)) = TRIM(E4_FILIAL) AND se4.D_E_L_E_T_=' ' "
cQuery+="LEFT JOIN SY1010 SY1 ON C7_COMPRA = Y1_COD AND SY1.D_E_L_E_T_=' ' "
cQuery+="LEFT JOIN SA2010 SA2 ON C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA AND sa2.D_E_L_E_T_=' ' "
cQuery+="LEFT JOIN CT1010 CT1 ON C7_CONTA = CT1_CONTA AND C7_FILIAL = CT1_FILIAL AND ct1.D_E_L_E_T_=' ' "
cQuery+="LEFT JOIN SF4010 SF4 ON C7_FILIAL = F4_FILIAL AND C7_TES = F4_CODIGO AND sf4.D_E_L_E_T_=' ' "
cQuery+="LEFT JOIN SA4010 SA4 ON C7_TRANSP = A4_COD AND sa4.D_E_L_E_T_=' ' "
 
cQuery+="WHERE SC7.D_E_L_E_T_=' ' and C7_FILIAL between '"+MV_PAR01+"' and '"+ MV_PAR02+"' "
cQuery+="AND C7_EMISSAO between '"+Dtos(MV_PAR03)+ "' and '"+DtoS(MV_PAR04)+"' "
cQuery+="ORDER BY C7_EMISSAO"
        //and rownum<101

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),_cAlias,.T.,.T.)

_aStru:=DBSTRUCT()

DBGOTOP()

IF!Eof()

    HTMLMAIL()

    _nDemiss:=0
    _cEmissD    :=C7_EMISSAO
    _cEmissA    :=C7_EMISSAO
    _cEmissAn   :=C7_EMISSAO

    Whil!Eof()

        If C7_EMISSAO<>_cEmissA
            _nDemiss    ++
            _cEmissAn   :=_cEmissA
            _cEmissA    :=C7_EMISSAO
        END

        IF _nDemiss==0 .Or. _nDemiss>_nNfdias

            If _nDemiss>_nNfdias

                _cNarquivo:=_cTabela+"_"+_cEmissD+"_"+_cEmissAn+".CSV"

                //ENVARQS(_cNarquivo,_cHtml,"DW - QFTNOTASSAIDA")
                ENVFARQS(_cNarquivo)

                _cEmissD:=C7_EMISSAO
                _cEmissA:=C7_EMISSAO

            END

            _nHandle    :=FCREATE(_cArquivo)

            If _nHandle = -1
                conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
            END
            
            _nDemiss    :=1
        End

        For x:=1 To Len(_aStru)
    
            If _aStru[x,2]=="C"

                MONTACAMPO()

                //FWrite(_nHandle, &(_aStru[x,1])+';')
                FWrite(_nHandle, _cCampo)
            Else
                FWrite(_nHandle, Str(&(_aStru[x,1])))
                FWrite(_nHandle, ';')
            END
        NEXT

        FWrite(_nHandle, CRLF)

        DBSKIP()
    END

    _cNarquivo:=_cTabela+"_"+_cEmissD+"_"+_cEmissA+".CSV"

    ENVFARQS(_cNarquivo)

else
    GERLOG(_cTabela,_cOrig,"",0)
END

RETURN

/*/{Protheus.doc} QCRTITREC
    Extração de dados de ctas a receber
    @type  Static Function
    @author user
    Edson Bella Gonçalves - MRC
    @since 14/03/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)@see (links_or_references)
/*/

Static Function QCRTITREC()
    
Local   _aPergs     := {}
Local   _cFilialDe  := Space(6)
Local   _cFilialAte := Space(6)
Local   _dEmissaoD  := Ctod('  /  /    ')
Local   _dEmissaoA  := Ctod('  /  /    ')

Private _nNfdias    := GetMv("EL_DWCRDIA")
Private _nNfdiasR   := GetMv("EL_DWCRQD")
Private _cAlias     :=  GetNextAlias()
Private _nHandle
Private _cTabela    :=  "QCRTITREC"
Private _cArquivo   :=  _cPasta+_cTabela
Private _cModifI    := ' '
Private _cModifF    := ' '

If _lNUser
    MV_PAR01    :=  ' '
    MV_PAR02    :=  'ZZZZZZ'
    MV_PAR03    := CtoD('  /  /    ')
    MV_PAR04    := CtoD('31/12/2050')
    _cModifI    :=  date()-_nNfdiasR //CtoD('01/10/2022') //
    _cModifF    :=  date() //CtoD('31/12/2022') //

else
    aAdd(_aPergs, {1, "Filial de",   _cFilialDe,    "", ".T.", "",".T.", 40,.T.})
    aAdd(_aPergs, {1, "Filial até",  _cFilialAte,   "", ".T.", "",".T.", 40,.F.})
    aAdd(_aPergs, {1, "Emissão de",  _dEmissaoD,    "", ".T.", "",".T.", 60,.T.})
    aAdd(_aPergs, {1, "Emissão até", _dEmissaoA,    "", ".T.", "",".T.", 60,.F.})

    If !ParamBox(_aPergs, "Informe os parâmetros")
        AtuConou('2')
        RETURN .t.
    End
    _cModifI    := CtoD('  /  /    ')
    _cModifF    := CtoD('31/12/2050')
END

MsAguarde({|| PQCRTITREC()}, "Aguarde...", "Processando Registros "+_cTabela+"...")

AtuConou('4')

Return

//
Static Function PQCRTITREC

AtuConou('3')

BeginSql Alias _cAlias

    SELECT

        REGEXP_REPLACE (TRIM(E1_FILIAL ) ,'[[:cntrl:];"]')E1_FILIAL ,
        REGEXP_REPLACE (TRIM(E1_PREFIXO) ,'[[:cntrl:];"]')E1_PREFIXO,
        REGEXP_REPLACE (TRIM(E1_NUM    ) ,'[[:cntrl:];"]')E1_NUM    ,
        REGEXP_REPLACE (TRIM(E1_PARCELA) ,'[[:cntrl:];"]')E1_PARCELA,
        REGEXP_REPLACE (TRIM(E1_TIPO   ) ,'[[:cntrl:];"]')E1_TIPO   ,
        CASE 
        WHEN E1_XCARBAN = 'C' THEN 'CARTEIRA'
        WHEN E1_XCARBAN = 'B' THEN 'BANCO'
        WHEN E1_XCARBAN = 'D' THEN 'BNDES'
        END E1_XCARBAN,
        REGEXP_REPLACE (TRIM(E1_NATUREZ) ,'[[:cntrl:];"]')E1_NATUREZ,
        REGEXP_REPLACE (TRIM(E1_PORTADO) ,'[[:cntrl:];"]')E1_PORTADO,
        REGEXP_REPLACE (TRIM(E1_AGEDEP ) ,'[[:cntrl:];"]')E1_AGEDEP ,
        REGEXP_REPLACE (TRIM(E1_CLIENTE) ,'[[:cntrl:];"]')E1_CLIENTE,
        REGEXP_REPLACE (TRIM(E1_LOJA   ) ,'[[:cntrl:];"]')E1_LOJA   ,
        REGEXP_REPLACE (TRIM(E1_NOMCLI ) ,'[[:cntrl:];"]')E1_NOMCLI ,
        E1_EMISSAO,
        E1_VENCTO ,
        E1_VENCREA,
        E1_VALOR  ,
        REGEXP_REPLACE (TRIM(E1_XDEVOLV) ,'[[:cntrl:];"]')E1_XDEVOLV,
        E1_BASEIRF,
        E1_ISS    ,
        E1_IRRF   ,
        REGEXP_REPLACE (TRIM(E1_NUMBCO ) ,'[[:cntrl:];"]')E1_NUMBCO ,
        REGEXP_REPLACE (TRIM(E1_INDICE ) ,'[[:cntrl:];"]')E1_INDICE ,
        E1_BAIXA  ,
        REGEXP_REPLACE (TRIM(E1_NUMBOR ) ,'[[:cntrl:];"]')E1_NUMBOR ,
        E1_DATABOR,
        E1_EMIS1  ,
        REGEXP_REPLACE (TRIM(E1_HIST   ) ,'[[:cntrl:];"]')E1_HIST   ,
        REGEXP_REPLACE (TRIM(E1_LA     ) ,'[[:cntrl:];"]')E1_LA     ,
        REGEXP_REPLACE (TRIM(E1_LOTE   ) ,'[[:cntrl:];"]')E1_LOTE   ,
        REGEXP_REPLACE (TRIM(E1_MOTIVO ) ,'[[:cntrl:];"]')E1_MOTIVO ,
        E1_MOVIMEN,
        REGEXP_REPLACE (TRIM(E1_OP     ) ,'[[:cntrl:];"]')E1_OP     ,
        REGEXP_REPLACE (TRIM(E1_SITUACA) ,'[[:cntrl:];"]')E1_SITUACA,
        REGEXP_REPLACE (TRIM(E1_CONTRAT) ,'[[:cntrl:];"]')E1_CONTRAT,
        E1_SALDO  ,
        REGEXP_REPLACE (TRIM(E1_SUPERVI) ,'[[:cntrl:];"]')E1_SUPERVI,
        REGEXP_REPLACE (TRIM(E1_VEND1  ) ,'[[:cntrl:];"]')E1_VEND1  ,
        REGEXP_REPLACE (TRIM(E1_VEND2  ) ,'[[:cntrl:];"]')E1_VEND2  ,
        REGEXP_REPLACE (TRIM(E1_VEND3  ) ,'[[:cntrl:];"]')E1_VEND3  ,
        REGEXP_REPLACE (TRIM(E1_VEND4  ) ,'[[:cntrl:];"]')E1_VEND4  ,
        REGEXP_REPLACE (TRIM(E1_VEND5  ) ,'[[:cntrl:];"]')E1_VEND5  ,
        E1_COMIS1 ,
        E1_COMIS2 ,
        E1_COMIS3 ,
        E1_COMIS4 ,
        E1_DESCONT,
        E1_COMIS5 ,
        E1_MULTA  ,
        E1_JUROS  ,
        E1_CORREC ,
        E1_VALLIQ ,
        E1_VENCORI,
        REGEXP_REPLACE (TRIM(E1_CONTA  ) ,'[[:cntrl:];"]')E1_CONTA  ,
        E1_VALJUR ,
        E1_PORCJUR,
        E1_MOEDA  ,
        E1_BASCOM1,
        E1_BASCOM2,
        E1_BASCOM3,
        REGEXP_REPLACE (TRIM(E1_OK     ) ,'[[:cntrl:];"]')E1_OK     ,
        E1_BASCOM4,
        E1_BASCOM5,
        REGEXP_REPLACE (TRIM(E1_FATPREF) ,'[[:cntrl:];"]')E1_FATPREF,
        REGEXP_REPLACE (TRIM(E1_FATURA ) ,'[[:cntrl:];"]')E1_FATURA ,
        REGEXP_REPLACE (TRIM(E1_PROJETO) ,'[[:cntrl:];"]')E1_PROJETO,
        REGEXP_REPLACE (TRIM(E1_CLASCON) ,'[[:cntrl:];"]')E1_CLASCON,
        E1_VALCOM1,
        E1_VALCOM2,
        E1_VALCOM3,
        E1_VALCOM4,
        E1_VALCOM5,
        REGEXP_REPLACE (TRIM(E1_OCORREN) ,'[[:cntrl:];"]')E1_OCORREN,
        REGEXP_REPLACE (TRIM(E1_INSTR1 ) ,'[[:cntrl:];"]')E1_INSTR1 ,
        REGEXP_REPLACE (TRIM(E1_INSTR2 ) ,'[[:cntrl:];"]')E1_INSTR2 ,
        REGEXP_REPLACE (TRIM(E1_PEDIDO ) ,'[[:cntrl:];"]')E1_PEDIDO ,
        REGEXP_REPLACE (TRIM(E1_NUMNOTA) ,'[[:cntrl:];"]')E1_NUMNOTA,
        REGEXP_REPLACE (TRIM(E1_SERIE  ) ,'[[:cntrl:];"]')E1_SERIE  ,
        E1_DTVARIA,
        E1_VARURV ,
        REGEXP_REPLACE (TRIM(E1_IDENTEE) ,'[[:cntrl:];"]')E1_IDENTEE,
        E1_VLCRUZ ,
        E1_DTFATUR,
        REGEXP_REPLACE (TRIM(E1_STATUS ) ,'[[:cntrl:];"]')E1_STATUS ,
        REGEXP_REPLACE (TRIM(E1_ORIGEM ) ,'[[:cntrl:];"]')E1_ORIGEM ,
        REGEXP_REPLACE (TRIM(E1_NUMCART) ,'[[:cntrl:];"]')E1_NUMCART,
        REGEXP_REPLACE (TRIM(E1_FLUXO  ) ,'[[:cntrl:];"]')E1_FLUXO  ,
        E1_DESCFIN,
        E1_DIADESC,
        case
        when e1_tipodes = '1' then 'FIXO'
        ELSE  'PROPORCIONAL'
        end E1_TIPODES,
        E1_VLRREAL,
        REGEXP_REPLACE (TRIM(E1_CARTAO ) ,'[[:cntrl:];"]')E1_CARTAO ,
        E1_CARTVAL,
        REGEXP_REPLACE (TRIM(E1_CARTAUT) ,'[[:cntrl:];"]')E1_CARTAUT,
        REGEXP_REPLACE (TRIM(E1_ADM    ) ,'[[:cntrl:];"]')E1_ADM    ,
        REGEXP_REPLACE (TRIM(E1_TRANSF ) ,'[[:cntrl:];"]')E1_TRANSF ,
        REGEXP_REPLACE (TRIM(E1_ORDPAGO) ,'[[:cntrl:];"]')E1_ORDPAGO,
        REGEXP_REPLACE (TRIM(E1_BCOCHQ ) ,'[[:cntrl:];"]')E1_BCOCHQ ,
        REGEXP_REPLACE (TRIM(E1_AGECHQ ) ,'[[:cntrl:];"]')E1_AGECHQ ,
        REGEXP_REPLACE (TRIM(E1_CTACHQ ) ,'[[:cntrl:];"]')E1_CTACHQ ,
        REGEXP_REPLACE (TRIM(E1_NUMLIQ ) ,'[[:cntrl:];"]')E1_NUMLIQ ,
        REGEXP_REPLACE (TRIM(E1_RECIBO ) ,'[[:cntrl:];"]')E1_RECIBO ,
        E1_INSS   ,
        REGEXP_REPLACE (TRIM(E1_FILORIG) ,'[[:cntrl:];"]')E1_FILORIG,
        E1_DTACRED,
        REGEXP_REPLACE (TRIM(E1_TIPOFAT) ,'[[:cntrl:];"]')E1_TIPOFAT,
        REGEXP_REPLACE (TRIM(E1_FLAGFAT) ,'[[:cntrl:];"]')E1_FLAGFAT,
        REGEXP_REPLACE (TRIM(E1_TIPOLIQ) ,'[[:cntrl:];"]')E1_TIPOLIQ,
        E1_CSLL   ,
        E1_COFINS ,
        E1_PIS    ,
        REGEXP_REPLACE (TRIM(E1_MESBASE) ,'[[:cntrl:];"]')E1_MESBASE,
        REGEXP_REPLACE (TRIM(E1_ANOBASE) ,'[[:cntrl:];"]')E1_ANOBASE,
        REGEXP_REPLACE (TRIM(E1_PLNUCOB) ,'[[:cntrl:];"]')E1_PLNUCOB,
        REGEXP_REPLACE (TRIM(E1_CODEMP ) ,'[[:cntrl:];"]')E1_CODEMP ,
        REGEXP_REPLACE (TRIM(E1_CODINT ) ,'[[:cntrl:];"]')E1_CODINT ,
        REGEXP_REPLACE (TRIM(E1_MATRIC ) ,'[[:cntrl:];"]')E1_MATRIC ,
        E1_TXMOEDA,
        E1_ACRESC ,
        E1_SDACRES,
        E1_DECRESC,
        E1_SDDECRE,
        case
        when E1_MULTNAT = '1' then 'SIM' ELSE 'NAO'
        end E1_MULTNAT,
        REGEXP_REPLACE (TRIM(E1_MSFIL  ) ,'[[:cntrl:];"]')E1_MSFIL  ,
        REGEXP_REPLACE (TRIM(E1_MSEMP  ) ,'[[:cntrl:];"]')E1_MSEMP  ,
        CASE
        WHEN E1_PROJPMS = '1' THEN 'SIM' ELSE 'NAO'
        END E1_PROJPMS,
        CASE
        WHEN E1_DESDOBR = '1' THEN 'SIM' ELSE 'NAO'
        END E1_DESDOBR,
        REGEXP_REPLACE (TRIM(E1_NRDOC  ) ,'[[:cntrl:];"]')E1_NRDOC  ,
        CASE
        WHEN E1_MODSPB = '1' THEN 'TED'
        WHEN E1_MODSPB = '2' THEN 'CIP'
        WHEN E1_MODSPB = '3' THEN 'COMP'
        END E1_MODSPB ,
        REGEXP_REPLACE (TRIM(E1_EMITCHQ) ,'[[:cntrl:];"]')E1_EMITCHQ,
        REGEXP_REPLACE (TRIM(E1_IDCNAB ) ,'[[:cntrl:];"]')E1_IDCNAB ,
        REGEXP_REPLACE (TRIM(E1_PLCOEMP) ,'[[:cntrl:];"]')E1_PLCOEMP,
        REGEXP_REPLACE (TRIM(E1_PLTPCOE) ,'[[:cntrl:];"]')E1_PLTPCOE,
        REGEXP_REPLACE (TRIM(E1_CODCOR ) ,'[[:cntrl:];"]')E1_CODCOR ,
        REGEXP_REPLACE (TRIM(E1_PARCCSS) ,'[[:cntrl:];"]')E1_PARCCSS,
        REGEXP_REPLACE (TRIM(E1_CODORCA) ,'[[:cntrl:];"]')E1_CODORCA,
        REGEXP_REPLACE (TRIM(E1_CODIMOV) ,'[[:cntrl:];"]')E1_CODIMOV,
        REGEXP_REPLACE (TRIM(E1_FILDEB ) ,'[[:cntrl:];"]')E1_FILDEB ,
        REGEXP_REPLACE (TRIM(E1_NUMRA  ) ,'[[:cntrl:];"]')E1_NUMRA  ,
        E1_DATAEDI,
        REGEXP_REPLACE (TRIM(E1_NUMSOL ) ,'[[:cntrl:];"]')E1_NUMSOL ,
        REGEXP_REPLACE (TRIM(E1_INSCRIC) ,'[[:cntrl:];"]')E1_INSCRIC,
        REGEXP_REPLACE (TRIM(E1_SERREC ) ,'[[:cntrl:];"]')E1_SERREC ,
        REGEXP_REPLACE (TRIM(E1_CODBAR ) ,'[[:cntrl:];"]')E1_CODBAR ,
        REGEXP_REPLACE (TRIM(E1_CODDIG ) ,'[[:cntrl:];"]')E1_CODDIG ,
        REGEXP_REPLACE (TRIM(E1_CHQDEV ) ,'[[:cntrl:];"]')E1_CHQDEV ,
        E1_LIDESCF,
        E1_VLBOLSA,
        REGEXP_REPLACE (TRIM(E1_NUMCRD ) ,'[[:cntrl:];"]')E1_NUMCRD ,
        E1_VLFIES ,
        REGEXP_REPLACE (TRIM(E1_DEBITO ) ,'[[:cntrl:];"]')E1_DEBITO ,
        REGEXP_REPLACE (TRIM(E1_CCD    ) ,'[[:cntrl:];"]')E1_CCD    ,
        REGEXP_REPLACE (TRIM(E1_ITEMD  ) ,'[[:cntrl:];"]')E1_ITEMD  ,
        REGEXP_REPLACE (TRIM(E1_CLVLDB ) ,'[[:cntrl:];"]')E1_CLVLDB ,
        REGEXP_REPLACE (TRIM(E1_CREDIT ) ,'[[:cntrl:];"]')E1_CREDIT ,
        REGEXP_REPLACE (TRIM(E1_CCC    ) ,'[[:cntrl:];"]')E1_CCC    ,
        REGEXP_REPLACE (TRIM(E1_ITEMC  ) ,'[[:cntrl:];"]')E1_ITEMC  ,
        REGEXP_REPLACE (TRIM(E1_CLVLCR ) ,'[[:cntrl:];"]')E1_CLVLCR ,
        E1_DESCON1,
        E1_DESCON2,
        E1_DTDESC3,
        E1_DTDESC1,
        E1_DTDESC2,
        E1_VLMULTA,
        E1_DESCON3,
        REGEXP_REPLACE (TRIM(E1_MOTNEG ) ,'[[:cntrl:];"]')E1_MOTNEG , 
        E1_SABTPIS,
        E1_SABTCOF,
        E1_SABTCSL,
        REGEXP_REPLACE (TRIM(E1_FORNISS) ,'[[:cntrl:];"]')E1_FORNISS,
        REGEXP_REPLACE (TRIM(E1_PARTOT ) ,'[[:cntrl:];"]')E1_PARTOT ,
        CASE 
        WHEN E1_SITFAT = '1' THEN 'FATURA NAO IMPRESSA'
        WHEN E1_SITFAT = '2' THEN 'FATURA IMPRESSA'
        WHEN E1_SITFAT = '3' THEN 'FATURA CANCELADA'
        END E1_SITFAT ,
        REGEXP_REPLACE (TRIM(E1_PARCIRF) ,'[[:cntrl:];"]')E1_PARCIRF,
        E1_BASEPIS,
        E1_BASECOF,
        E1_BASECSL,
        E1_VRETISS,
        CASE 
        WHEN E1_SCORGP = '1' THEN 'SIM'
        ELSE 'NAO'
        END E1_SCORGP ,
        CASE
        WHEN E1_FRETISS = '1' THEN 'CONS.VLR.MIN'
        WHEN E1_FRETISS = '2' THEN 'SEMPRE RETEM'
        END E1_FRETISS,
        E1_TXMDCOR,
        E1_SATBIRF,
        REGEXP_REPLACE (TRIM(E1_TIPREG ) ,'[[:cntrl:];"]')E1_TIPREG ,
        REGEXP_REPLACE (TRIM(E1_CONEMP ) ,'[[:cntrl:];"]')E1_CONEMP ,
        REGEXP_REPLACE (TRIM(E1_VERCON ) ,'[[:cntrl:];"]')E1_VERCON ,
        REGEXP_REPLACE (TRIM(E1_SUBCON ) ,'[[:cntrl:];"]')E1_SUBCON ,
        REGEXP_REPLACE (TRIM(E1_VERSUB ) ,'[[:cntrl:];"]')E1_VERSUB ,
        REGEXP_REPLACE (TRIM(E1_PLLOTE ) ,'[[:cntrl:];"]')E1_PLLOTE ,
        REGEXP_REPLACE (TRIM(E1_PLOPELT) ,'[[:cntrl:];"]')E1_PLOPELT,
        REGEXP_REPLACE (TRIM(E1_CODRDA ) ,'[[:cntrl:];"]')E1_CODRDA ,
        REGEXP_REPLACE (TRIM(E1_FORMREC) ,'[[:cntrl:];"]')E1_FORMREC,
        REGEXP_REPLACE (TRIM(E1_BCOCLI ) ,'[[:cntrl:];"]')E1_BCOCLI ,
        REGEXP_REPLACE (TRIM(E1_AGECLI ) ,'[[:cntrl:];"]')E1_AGECLI ,
        REGEXP_REPLACE (TRIM(E1_CTACLI ) ,'[[:cntrl:];"]')E1_CTACLI ,
        REGEXP_REPLACE (TRIM(E1_PARCFET) ,'[[:cntrl:];"]')E1_PARCFET,
        E1_FETHAB ,
        REGEXP_REPLACE (TRIM(E1_MDCRON ) ,'[[:cntrl:];"]')E1_MDCRON ,
        REGEXP_REPLACE (TRIM(E1_MDCONTR) ,'[[:cntrl:];"]')E1_MDCONTR,
        REGEXP_REPLACE (TRIM(E1_MEDNUME) ,'[[:cntrl:];"]')E1_MEDNUME,
        REGEXP_REPLACE (TRIM(E1_MDPLANI) ,'[[:cntrl:];"]')E1_MDPLANI,
        REGEXP_REPLACE (TRIM(E1_MDPARCE) ,'[[:cntrl:];"]')E1_MDPARCE,
        REGEXP_REPLACE (TRIM(E1_TITPAI ) ,'[[:cntrl:];"]')E1_TITPAI ,
        REGEXP_REPLACE (TRIM(E1_DOCTEF ) ,'[[:cntrl:];"]')E1_DOCTEF ,
        REGEXP_REPLACE (TRIM(E1_MDREVIS) ,'[[:cntrl:];"]')E1_MDREVIS,
        REGEXP_REPLACE (TRIM(E1_NUMMOV ) ,'[[:cntrl:];"]')E1_NUMMOV ,
        REGEXP_REPLACE (TRIM(E1_PREFORI) ,'[[:cntrl:];"]')E1_PREFORI,
        REGEXP_REPLACE (TRIM(E1_NODIA  ) ,'[[:cntrl:];"]')E1_NODIA  ,
        CASE
        WHEN E1_RELATO = '1' THEN 'SIM'
        ELSE 'NAO'
        END E1_RELATO ,
        E1_MDMULT ,
        E1_MULTDIA,
        REGEXP_REPLACE (TRIM(E1_JURFAT ) ,'[[:cntrl:];"]')E1_JURFAT ,
        E1_MDBONI ,
        REGEXP_REPLACE (TRIM(E1_NUMCON ) ,'[[:cntrl:];"]')E1_NUMCON ,
        REGEXP_REPLACE (TRIM(E1_TURMA  ) ,'[[:cntrl:];"]')E1_TURMA  ,
        E1_IDLAN  ,
        E1_MDDESC ,
        E1_BASEINS,
        E1_IDAPLIC,
        E1_PROCEL ,
        E1_NOPER  ,
        REGEXP_REPLACE (TRIM(E1_SERVICO) ,'[[:cntrl:];"]')E1_SERVICO,
        REGEXP_REPLACE (TRIM(E1_NFELETR) ,'[[:cntrl:];"]')E1_NFELETR,
        E1_IDBOLET,
        E1_VRETIRF,
        E1_RETCNTR,
        E1_VLBOLP ,
        REGEXP_REPLACE (TRIM(E1_NSUTEF ) ,'[[:cntrl:];"]')E1_NSUTEF ,
        REGEXP_REPLACE (TRIM(E1_LTCXA  ) ,'[[:cntrl:];"]')E1_LTCXA  ,
        E1_NUMINSC,
        E1_SABTIRF,
        REGEXP_REPLACE (TRIM(E1_SEQBX  ) ,'[[:cntrl:];"]')E1_SEQBX  ,
        REGEXP_REPLACE (TRIM(E1_DIACTB ) ,'[[:cntrl:];"]')E1_DIACTB ,
        E1_TPDP   ,
        REGEXP_REPLACE (TRIM(E1_PARTPDP) ,'[[:cntrl:];"]')E1_PARTPDP,
        E1_BASEISS,
        CASE
        WHEN E1_APLVLMN = '1' then 'SIM'
        ELSE 'NAO'
        END E1_APLVLMN,
        REGEXP_REPLACE (TRIM(E1_VLMINIS) ,'[[:cntrl:];"]')E1_VLMINIS,
        REGEXP_REPLACE (TRIM(E1_CODISS ) ,'[[:cntrl:];"]')E1_CODISS ,
        REGEXP_REPLACE (TRIM(E1_NUMPRO ) ,'[[:cntrl:];"]')E1_NUMPRO ,
        CASE
        WHEN E1_INDPRO = '0' THEN 'SEFAZ'
        WHEN E1_INDPRO = '1' THEN 'JUSTICA FEDERAL'
        WHEN E1_INDPRO = '2' THEN 'JUSTIVA ESTADUAL'
        WHEN E1_INDPRO = '3' THEN 'SECEX/SRF'
        WHEN E1_INDPRO = '9' THEN 'OUTROS'
        END E1_INDPRO ,
        REGEXP_REPLACE (TRIM(E1_PARCFAB) ,'[[:cntrl:];"]')E1_PARCFAB,
        E1_FABOV  ,
        REGEXP_REPLACE (TRIM(E1_PARCFAC) ,'[[:cntrl:];"]')E1_PARCFAC,
        REGEXP_REPLACE (TRIM(E1_TPDESC ) ,'[[:cntrl:];"]')E1_TPDESC ,
        E1_FACS   ,
        REGEXP_REPLACE (TRIM(E1_CODIRRF) ,'[[:cntrl:];"]')E1_CODIRRF,
        E1_PRISS  ,
        E1_PRINSS ,
        REGEXP_REPLACE (TRIM(E1_XOBS   ) ,'[[:cntrl:];"]')E1_XOBS   ,
        REGEXP_REPLACE (TRIM(E1_USERLGI) ,'[[:cntrl:];"]')E1_USERLGI,
        REGEXP_REPLACE (TRIM(E1_USERLGA) ,'[[:cntrl:];"]')E1_USERLGA,
        REGEXP_REPLACE (TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(E1_XHSTCOB,250,1))) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(E1_IDMOV  ) ,'[[:cntrl:];"]')E1_IDMOV  ,
        CASE
        WHEN E1_RATFIN = '1' THEN 'SIM'
        ELSE 'NAO'
        END E1_RATFIN ,
        REGEXP_REPLACE (TRIM(E1_XSERASA) ,'[[:cntrl:];"]')E1_XSERASA,
        REGEXP_REPLACE (TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(E1_XOBSTA ,250,1))) ,'[[:cntrl:];]'),
        REGEXP_REPLACE (TRIM(E1_XINDSEE) ,'[[:cntrl:];"]')E1_XINDSEE,
        REGEXP_REPLACE (TRIM(E1_XDVNBCO) ,'[[:cntrl:];"]')E1_XDVNBCO,
        REGEXP_REPLACE (TRIM(E1_XOCCOB ) ,'[[:cntrl:];"]')E1_XOCCOB ,
        CASE
        WHEN E1_XELEG = '1' THEN 'ELEGIVEL PARA COBRANCA'
        WHEN E1_XELEG = '2' THEN 'INELEGIVEL PARA COBRANCA'
        END E1_XELEG  ,
        REGEXP_REPLACE (TRIM(E1_XALIN1 ) ,'[[:cntrl:];"]')E1_XALIN1 ,
        REGEXP_REPLACE (TRIM(E1_XDESAL1) ,'[[:cntrl:];"]')E1_XDESAL1,
        E1_XDTDV1 ,
        E1_XDTREA1,
        REGEXP_REPLACE (TRIM(E1_XALIN2 ) ,'[[:cntrl:];"]')E1_XALIN2 ,
        REGEXP_REPLACE (TRIM(E1_XDESAL2) ,'[[:cntrl:];"]')E1_XDESAL2,
        E1_XDTDV2 ,
        E1_XDTREA2,
        REGEXP_REPLACE (TRIM(E1_XOBSCHE) ,'[[:cntrl:];"]')E1_XOBSCHE,
        REGEXP_REPLACE (TRIM(E1_XCARTEI) ,'[[:cntrl:];"]')E1_XCARTEI,
        REGEXP_REPLACE (TRIM(E1_PARCFAM) ,'[[:cntrl:];"]')E1_PARCFAM,
        E1_FAMAD  ,
        REGEXP_REPLACE (TRIM(E1_PARCFMP) ,'[[:cntrl:];"]')E1_PARCFMP,
        E1_FMPEQ  ,
        REGEXP_REPLACE (TRIM(E1_XLIBSEN) ,'[[:cntrl:];"]')E1_XLIBSEN,
        REGEXP_REPLACE (TRIM(E1_XCTRSEN) ,'[[:cntrl:];"]')E1_XCTRSEN,
        REGEXP_REPLACE (TRIM(E1_XUSRSOL) ,'[[:cntrl:];"]')E1_XUSRSOL,
        REGEXP_REPLACE (TRIM(E1_XNOMSOL) ,'[[:cntrl:];"]')E1_XNOMSOL,
        REGEXP_REPLACE (TRIM(E1_XUSRAUT) ,'[[:cntrl:];"]')E1_XUSRAUT,
        REGEXP_REPLACE (TRIM(E1_XNOMAUT) ,'[[:cntrl:];"]')E1_XNOMAUT,
        E1_XDTAUTO,
        E1_XDTSANF,
        E1_DTDESC ,
        E1_XALTOCO,
        REGEXP_REPLACE (TRIM(E1_BONIFIC) ,'[[:cntrl:];"]')E1_BONIFIC,
        E1_FUNDESA,
        E1_IMAMT  ,
        E1_FASEMT ,
        REGEXP_REPLACE (TRIM(E1_PARFUND) ,'[[:cntrl:];"]')E1_PARFUND,
        REGEXP_REPLACE (TRIM(E1_PARIMA ) ,'[[:cntrl:];"]')E1_PARIMA ,
        REGEXP_REPLACE (TRIM(E1_PARFASE) ,'[[:cntrl:];"]')E1_PARFASE,
        REGEXP_REPLACE (TRIM(E1_PRODUTO) ,'[[:cntrl:];"]')E1_PRODUTO,
        REGEXP_REPLACE (TRIM(E1_PERLET ) ,'[[:cntrl:];"]')E1_PERLET ,
        REGEXP_REPLACE (TRIM(E1_CHAVENF) ,'[[:cntrl:];"]')E1_CHAVENF,
        REGEXP_REPLACE (TRIM(E1_MSIDENT) ,'[[:cntrl:];"]')E1_MSIDENT,
        REGEXP_REPLACE (TRIM(E1_MSEXP  ) ,'[[:cntrl:];"]')E1_MSEXP  ,
        REGEXP_REPLACE (TRIM(E1_XNUMCOB) ,'[[:cntrl:];"]')E1_XNUMCOB,
        E1_XDTENVC,
        REGEXP_REPLACE (TRIM(E1_CODRET ) ,'[[:cntrl:];"]')E1_CODRET ,
        CASE
        WHEN E1_XSTATUS = 'AG' THEN 'AGUARDANDO APROVACAO'
        WHEN E1_XSTATUS = 'AP' THEN 'APROVADO'
        WHEN E1_XSTATUS = 'RJ' THEN 'REJEITADA A APROVACAO'
        END E1_XSTATUS,
        REGEXP_REPLACE (TRIM(E1_XDESAPR) ,'[[:cntrl:];"]')E1_XDESAPR,
        REGEXP_REPLACE (TRIM(E1_MSRESP ) ,'[[:cntrl:];"]')E1_MSRESP ,
        E1_DESCJUR,
        REGEXP_REPLACE (TRIM(E1_CCUSTO ) ,'[[:cntrl:];"]')E1_CCUSTO ,
        REGEXP_REPLACE (TRIM(E1_CLVL   ) ,'[[:cntrl:];"]')E1_CLVL   ,
        REGEXP_REPLACE (TRIM(E1_ITEMCTA) ,'[[:cntrl:];"]')E1_ITEMCTA,
        REGEXP_REPLACE (TRIM(E1_CDRETCS) ,'[[:cntrl:];"]')E1_CDRETCS,
        REGEXP_REPLACE (TRIM(E1_CDRETIR) ,'[[:cntrl:];"]')E1_CDRETIR,
        REGEXP_REPLACE (TRIM(E1_TPESOC ) ,'[[:cntrl:];"]')E1_TPESOC ,
        REGEXP_REPLACE (TRIM(E1_CNO    ) ,'[[:cntrl:];"]')E1_CNO    ,
        REGEXP_REPLACE (TRIM(E1_SDOC   ) ,'[[:cntrl:];"]')E1_SDOC   ,
        REGEXP_REPLACE (TRIM(E1_SDOCREC) ,'[[:cntrl:];"]')E1_SDOCREC,
        REGEXP_REPLACE (TRIM(E1_CTRBCO ) ,'[[:cntrl:];"]')E1_CTRBCO ,
        E1_XDTALTE,
        REGEXP_REPLACE (TRIM(E1_XIDDEP ) ,'[[:cntrl:];"]')E1_XIDDEP ,
        CASE
        WHEN E1_BOLETO = '1' THEN 'SIM' ELSE 'NAO'
        END E1_BOLETO ,
        REGEXP_REPLACE (TRIM(E1_CONHTL ) ,'[[:cntrl:];"]')E1_CONHTL ,
        REGEXP_REPLACE (TRIM(E1_TCONHTL) ,'[[:cntrl:];"]')E1_TCONHTL,
        REGEXP_REPLACE (TRIM(E1_CODSERV) ,'[[:cntrl:];"]')E1_CODSERV,
        E1_VRETBIS,
        E1_BTRISS ,
        REGEXP_REPLACE (TRIM(E1_XUPLOAD) ,'[[:cntrl:];"]')E1_XUPLOAD,
        REGEXP_REPLACE (TRIM(E1_XMODIFI) ,'[[:cntrl:];"]')E1_XMODIFI,
        REGEXP_REPLACE (TRIM(E1_PARCIMA) ,'[[:cntrl:];"]')E1_PARCIMA,
        E1_IMA ,
        X5TIPO.X5_DESCRI X5_E2_DESCTIPO,
        SED.ED_DESCRIC ED_DESCRIC,
        A1_NOME,
        FRV_DESCRI,
        SA3_1.A3_NOME,
        SA3_2.A3_NOME,
        SA3_3.A3_NOME,
        SA3_4.A3_NOME,
        SA3_5.A3_NOME,
        X5CLESCON.X5_DESCRI,
        CT1_DESC01,
        ZZ8_DESC

    FROM %table:SE1% E1

        LEFT JOIN %table:SX5% X5TIPO ON X5TIPO.x5_TABELA = '05' AND E1_TIPO = X5_CHAVE AND X5TIPO.%notdel%
        left join %table:sed% sed on e1_naturez=ed_codigo and sed.%notdel%
        LEFT JOIN %table:SA1% SA1 ON E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA AND SA1.%notdel%
        LEFT JOIN %table:FRV% FRV ON E1_SITUACA = FRV_CODIGO AND FRV.%notdel%
        LEFT JOIN %table:SA3% SA3_1 ON SA3_1.A3_FILIAL = '020201' AND E1_VEND1 = SA3_1.A3_COD AND SA3_1.%notdel%
        LEFT JOIN %table:SA3% SA3_2 ON SA3_2.A3_FILIAL = '020201' AND E1_VEND2 = SA3_2.A3_COD AND SA3_2.%notdel%
        LEFT JOIN %table:SA3% SA3_3 ON SA3_3.A3_FILIAL = '020201' AND E1_VEND3 = SA3_3.A3_COD AND SA3_3.%notdel%
        LEFT JOIN %table:SA3% SA3_4 ON SA3_4.A3_FILIAL = '020201' AND E1_VEND4 = SA3_4.A3_COD AND SA3_4.%notdel%
        LEFT JOIN %table:SA3% SA3_5 ON SA3_5.A3_FILIAL = '020201' AND E1_VEND5 = SA3_5.A3_COD AND SA3_5.%notdel%
        LEFT JOIN %table:SX5% X5CLESCON ON X5CLESCON.X5_TABELA = '51' AND E1_CLASCON = X5CLESCON.X5_CHAVE AND X5CLESCON.%notdel%
        LEFT JOIN %table:CT1% CT1 ON E1_FILIAL = CT1_FILIAL AND E1_DEBITO = CT1_CONTA AND CT1.%notdel%
        LEFT JOIN %table:ZZ8% ZZ8 ON E1_XOCCOB = ZZ8_COD AND ZZ8.%notdel%

    WHERE E1.%notdel% and E1_FILIAL between %exp:MV_PAR01% and %exp:MV_PAR02%
        AND E1_EMISSAO between %exp:Dtos(MV_PAR03)% and %exp:DtoS(MV_PAR04)%
        AND E1_XMODIFI between %exp:_cModifI% and %exp:_cModifF%
        //and rownum<101

    ORDER BY E1_EMISSAO

EndSql

_cQuery:=GetLastQuery()

_aStru:=DBSTRUCT()

DBGOTOP()

IF!Eof()

    HTMLMAIL()

    _nDemiss:=0
    _cEmissD    :=E1_EMISSAO
    _cEmissA    :=E1_EMISSAO
    _cEmissAn   :=E1_EMISSAO

    Whil!Eof()

        If E1_EMISSAO<>_cEmissA
            _nDemiss    ++
            _cEmissAn   :=_cEmissA
            _cEmissA    :=E1_EMISSAO
        END

        IF _nDemiss==0 .Or. _nDemiss>_nNfdias

            If _nDemiss>_nNfdias

                _cNarquivo:=_cTabela+"_"+_cEmissD+"_"+_cEmissAn+".CSV"

                ENVFARQS(_cNarquivo)

                _cEmissD:=E1_EMISSAO
                _cEmissA:=E1_EMISSAO

            END

            _nHandle    :=FCREATE(_cArquivo)

            If _nHandle = -1
                conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
            END
            
            _nDemiss    :=1
        End

        For x:=1 To Len(_aStru)
    
            If _aStru[x,2]=="C"

                MONTACAMPO()

                //FWrite(_nHandle, &(_aStru[x,1])+';')
                FWrite(_nHandle, _cCampo)
            Else
                FWrite(_nHandle, Str(&(_aStru[x,1])))
                FWrite(_nHandle, ';')
            END
        NEXT

        FWrite(_nHandle, CRLF)

        DBSKIP()
    END

    _cNarquivo:=_cTabela+"_"+_cEmissD+"_"+_cEmissA+".CSV"

    ENVFARQS(_cNarquivo)

else
    GERLOG(_cTabela,_cOrig,"",0)
END

RETURN

/*/{Protheus.doc} QLOFORNECEDOR
    Extração de dados de fornecedores
    @type  Static Function
    @author user
    Edson Bella Gonçalves - MRC
    @since 15/03/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function QLOFORNECEDOR

Private _cAlias     :=  GetNextAlias()
Private _nHandle
Private _cTabela    :=  "QLOFORNECEDOR"
Private _cArquivo   :=  _cPasta+_cTabela
Private _cCampo

If !_lNUser
    If MessageBox("Confirma início?","Geração de Fornecedores",4)==7
        AtuConou('2')
        Return
    END

    MsAguarde({|| PQLOFORNECEDOR()}, "Aguarde...", "Processando Registros "+_cTabela+"...")
else
    PQLOFORNECEDOR()
END

AtuConou('4')

Return

//
Static Function PQLOFORNECEDOR

AtuConou('3')

BeginSql Alias _cAlias

    SELECT 
        REGEXP_REPLACE (TRIM(A2_FILIAL ),'[[:cntrl:];"]')A2_FILIAL ,
        REGEXP_REPLACE (TRIM(A2_COD    ),'[[:cntrl:];"]')A2_COD    ,
        REGEXP_REPLACE (TRIM(A2_LOJA   ),'[[:cntrl:];"]')A2_LOJA   ,
        REGEXP_REPLACE (TRIM(A2_XCODWK ),'[[:cntrl:];"]')A2_XCODWK ,
        case
        WHEN A2_TIPO = 'F' THEN 'FISICO'
        WHEN A2_TIPO = 'J' THEN 'JURIDICO'
        WHEN A2_TIPO = 'X' THEN 'OUTROS'
        end A2_TIPO   ,                                                                                                  
        REGEXP_REPLACE (TRIM(A2_CGC    ),'[[:cntrl:];"]')A2_CGC    ,
        REGEXP_REPLACE (TRIM(A2_NOME   ),'[[:cntrl:];"]')A2_NOME   ,
        REGEXP_REPLACE (TRIM(A2_NREDUZ ),'[[:cntrl:];"]')A2_NREDUZ ,
        REGEXP_REPLACE (TRIM(A2_END    ),'[[:cntrl:];"]')A2_END    ,
        CASE WHEN A2_CONTPRE= '1' THEN 'SIM' ELSE 'NAO' END A2_CONTPRE,
        REGEXP_REPLACE (TRIM(A2_NR_END ),'[[:cntrl:];"]')A2_NR_END ,
        REGEXP_REPLACE (TRIM(A2_BAIRRO ),'[[:cntrl:];"]')A2_BAIRRO ,
        REGEXP_REPLACE (TRIM(A2_EST    ),'[[:cntrl:];"]')A2_EST    ,
        REGEXP_REPLACE (TRIM(A2_ESTADO ),'[[:cntrl:];"]')A2_ESTADO ,
        REGEXP_REPLACE (TRIM(A2_COD_MUN),'[[:cntrl:];"]')A2_COD_MUN,
        REGEXP_REPLACE (TRIM(A2_MUN    ),'[[:cntrl:];"]')A2_MUN    ,
        REGEXP_REPLACE (TRIM(A2_IBGE   ),'[[:cntrl:];"]')A2_IBGE   ,
        REGEXP_REPLACE (TRIM(A2_CEP    ),'[[:cntrl:];"]')A2_CEP    ,
        REGEXP_REPLACE (TRIM(A2_CX_POST),'[[:cntrl:];"]')A2_CX_POST,
        REGEXP_REPLACE (TRIM(A2_PFISICA),'[[:cntrl:];"]')A2_PFISICA,
        REGEXP_REPLACE (TRIM(A2_DDD    ),'[[:cntrl:];"]')A2_DDD    ,
        REGEXP_REPLACE (TRIM(A2_DDI    ),'[[:cntrl:];"]')A2_DDI    ,
        REGEXP_REPLACE (TRIM(A2_TEL    ),'[[:cntrl:];"]')A2_TEL    ,
        REGEXP_REPLACE (TRIM(A2_INSCR  ),'[[:cntrl:];"]')A2_INSCR  ,
        REGEXP_REPLACE (TRIM(A2_TELEX  ),'[[:cntrl:];"]')A2_TELEX  ,
        REGEXP_REPLACE (TRIM(A2_FAX    ),'[[:cntrl:];"]')A2_FAX    ,
        REGEXP_REPLACE (TRIM(A2_INSCRM ),'[[:cntrl:];"]')A2_INSCRM ,
        REGEXP_REPLACE (TRIM(A2_CONTATO),'[[:cntrl:];"]')A2_CONTATO,
        CASE WHEN A2_PAGGFE = '1' THEN 'SIM' ELSE 'NAO' END A2_PAGGFE ,
        REGEXP_REPLACE (TRIM(A2_BANCO  ),'[[:cntrl:];"]')A2_BANCO  ,
        REGEXP_REPLACE (TRIM(A2_AGENCIA),'[[:cntrl:];"]')A2_AGENCIA,
        A2_DVAGE  , //TRATAR CAMPO com conteudo:                                                                                                                                 
        REGEXP_REPLACE (TRIM(A2_NUMCON ),'[[:cntrl:];"]')A2_NUMCON ,
        REGEXP_REPLACE (TRIM(A2_DVCTA  ),'[[:cntrl:];"]')A2_DVCTA  ,
        REGEXP_REPLACE (TRIM(A2_NATUREZ),'[[:cntrl:];"]')A2_NATUREZ,
        REGEXP_REPLACE (TRIM(A2_XDVAGE ),'[[:cntrl:];"]')A2_XDVAGE ,
        REGEXP_REPLACE (TRIM(A2_SWIFT  ),'[[:cntrl:];"]')A2_SWIFT  ,
        CASE WHEN A2_MSBLQL = '1' THEN 'SIM' ELSE 'NAO' END A2_MSBLQL ,
        REGEXP_REPLACE (TRIM(A2_XDVCTA ),'[[:cntrl:];"]')A2_XDVCTA ,
        REGEXP_REPLACE (TRIM(A2_RISCO  ),'[[:cntrl:];"]')A2_RISCO  ,
        REGEXP_REPLACE (TRIM(A2_TRANSP ),'[[:cntrl:];"]')A2_TRANSP ,
        A2_PRIOR  , //TRATAR CAMPO com conteudo:                                                                                                                                 
        REGEXP_REPLACE (TRIM(A2_COND   ),'[[:cntrl:];"]')A2_COND   ,
        REGEXP_REPLACE (TRIM(A2_LC     ),'[[:cntrl:];"]')A2_LC     ,
        A2_MATR   ,
        A2_ULTCOM ,
        A2_MCOMPRA,
        A2_METR   ,
        A2_MSALDO ,
        REGEXP_REPLACE (TRIM(A2_CONTA  ),'[[:cntrl:];"]')A2_CONTA  ,
        CASE
        WHEN A2_TIPORUR = 'J' THEN 'JURIDICO'
        WHEN A2_TIPORUR = 'F' THEN 'PESSOA FISICA'
        WHEN A2_TIPORUR = 'L' THEN 'FAMILAR'
        END A2_TIPORUR,                                                                                          
        A2_NROCOM ,
        A2_PRICOM ,
        A2_SALDUP ,
        A2_SALDUPM,
        REGEXP_REPLACE (TRIM(A2_ID_FBFN),'[[:cntrl:];"]')A2_ID_FBFN,
        case
        when a2_status = '1' THEN 'HOMOLOGADO'
        ELSE 'NAO HOMOLOGADO'
        end A2_STATUS ,                                                                                                  
        REGEXP_REPLACE (TRIM(A2_GRUPO  ),'[[:cntrl:];"]')A2_GRUPO  ,
        REGEXP_REPLACE (TRIM(A2_ATIVIDA),'[[:cntrl:];"]')A2_ATIVIDA,
        A2_DESVIO ,
        CASE WHEN A2_RECISS = 'S' THEN 'SIM' ELSE 'NAO' END A2_RECISS ,
        REGEXP_REPLACE (TRIM(A2_CODPAIS),'[[:cntrl:];"]')A2_CODPAIS,
        REGEXP_REPLACE (TRIM(A2_PAIS   ),'[[:cntrl:];"]')A2_PAIS   ,
        REGEXP_REPLACE (TRIM(A2_REPRES ),'[[:cntrl:];"]')A2_REPRES ,
        REGEXP_REPLACE (TRIM(A2_REPCONT),'[[:cntrl:];"]')A2_REPCONT,
        REGEXP_REPLACE (TRIM(A2_REPRTEL),'[[:cntrl:];"]')A2_REPRTEL,
        REGEXP_REPLACE (TRIM(A2_REPRFAX),'[[:cntrl:];"]')A2_REPRFAX,
        REGEXP_REPLACE (TRIM(A2_DEPTO  ),'[[:cntrl:];"]')A2_DEPTO  ,
        REGEXP_REPLACE (TRIM(A2_ORIG_1 ),'[[:cntrl:];"]')A2_ORIG_1 ,
        REGEXP_REPLACE (TRIM(A2_REPRMUN),'[[:cntrl:];"]')A2_REPRMUN,
        REGEXP_REPLACE (TRIM(A2_REPREST),'[[:cntrl:];"]')A2_REPREST,
        REGEXP_REPLACE (TRIM(A2_REPRCEP),'[[:cntrl:];"]')A2_REPRCEP,
        REGEXP_REPLACE (TRIM(A2_REPPAIS),'[[:cntrl:];"]')A2_REPPAIS,
        REGEXP_REPLACE (TRIM(A2_ORIG_2 ),'[[:cntrl:];"]')A2_ORIG_2 ,
        REGEXP_REPLACE (TRIM(A2_REPR_BA),'[[:cntrl:];"]')A2_REPR_BA,
        REGEXP_REPLACE (TRIM(A2_ORIG_3 ),'[[:cntrl:];"]')A2_ORIG_3 ,
        CASE
        WHEN A2_VINCULA = '1' THEN 'SEM VINCULACAO'
        WHEN A2_VINCULA = '2' THEN 'COM/SEM INFLUENCIA DE PRECO'
        WHEN A2_VINCULA = '3' THEN 'COM/COM INFLUENCIA DE PRECO'
        END A2_VINCULA,                                                
        REGEXP_REPLACE (TRIM(A2_REPR_EM),'[[:cntrl:];"]')A2_REPR_EM,
        REGEXP_REPLACE (TRIM(A2_REPR_EN),'[[:cntrl:];"]')A2_REPR_EN,
        CASE
        WHEN A2_COMI_SO = '1' THEN 'FOB'
        WHEN A2_COMI_SO = '2' THEN 'CFR'
        WHEN A2_COMI_SO = '3' THEN 'WORKS'
        WHEN A2_COMI_SO = '4' THEN 'F.A.S.'
        END A2_COMI_SO,                                                                                              
        REGEXP_REPLACE (TRIM(A2_REPBAIR),'[[:cntrl:];"]')A2_REPBAIR,
        CASE WHEN A2_ID_REPR= '1' THEN 'SIM' ELSE 'NAO' END A2_ID_REPR,
        REGEXP_REPLACE (TRIM(A2_CODMUN ),'[[:cntrl:];"]')A2_CODMUN ,
        REGEXP_REPLACE (TRIM(A2_REPR_AG),'[[:cntrl:];"]')A2_REPR_AG,
        A2_FABRICA, //TRATAR CAMPO com conteudo:                                                                                                                                 
        REGEXP_REPLACE (TRIM(A2_REPR_CO),'[[:cntrl:];"]')A2_REPR_CO,
        REGEXP_REPLACE (TRIM(A2_REPRCGC),'[[:cntrl:];"]')A2_REPRCGC,
        CASE WHEN A2_RET_PAI= '1' THEN 'SIM' ELSE 'NAO' END A2_RET_PAI,
        REGEXP_REPLACE (TRIM(A2_OK     ),'[[:cntrl:];"]')A2_OK     ,
        REGEXP_REPLACE (TRIM(A2_EMAIL  ),'[[:cntrl:];"]')A2_EMAIL  ,
        REGEXP_REPLACE (TRIM(A2_HPAGE  ),'[[:cntrl:];"]')A2_HPAGE  ,
        REGEXP_REPLACE (TRIM(A2_CONTCOM),'[[:cntrl:];"]')A2_CONTCOM,
        A2_FATAVA ,
        REGEXP_REPLACE (TRIM(A2_TPESSOA),'[[:cntrl:];"]')A2_TPESSOA,
        A2_DTAVA  ,
        A2_DTVAL  ,
        CASE WHEN A2_RECCIDE= '1' THEN 'SIM' ELSE 'NAO' END A2_RECCIDE,
        CASE WHEN A2_RECINSS= 'S' THEN 'SIM' ELSE 'NAO' END A2_RECINSS,
        REGEXP_REPLACE (TRIM(A2_UNFEDRP),'[[:cntrl:];"]')A2_UNFEDRP,
        REGEXP_REPLACE (TRIM(A2_CONTAB ),'[[:cntrl:];"]')A2_CONTAB ,
        A2_MNOTA  ,
        REGEXP_REPLACE (TRIM(A2_TPISSRS),'[[:cntrl:];"]')A2_TPISSRS,
        REGEXP_REPLACE (TRIM(A2_CODLOC ),'[[:cntrl:];"]')A2_CODLOC ,
        REGEXP_REPLACE (TRIM(A2_GRPTRIB),'[[:cntrl:];"]')A2_GRPTRIB,
        REGEXP_REPLACE (TRIM(A2_CLIQF  ),'[[:cntrl:];"]')A2_CLIQF  ,
        REGEXP_REPLACE (TRIM(A2_PLGRUPO),'[[:cntrl:];"]')A2_PLGRUPO,
        REGEXP_REPLACE (TRIM(A2_CODBLO ),'[[:cntrl:];"]')A2_CODBLO ,
        REGEXP_REPLACE (TRIM(A2_PAISORI),'[[:cntrl:];"]')A2_PAISORI,
        A2_ROYALTY, //TRATAR CAMPO com conteudo:                                                                                                                                 
        A2_TXTRIBU,
        CASE WHEN A2_B2B    = '1' THEN 'SIM' ELSE 'NAO' END A2_B2B    ,
        CASE WHEN A2_PLCRRES= 'S' THEN 'SIM' ELSE 'NAO' END A2_PLCRRES,
        CASE WHEN A2_PLFIL  = 'S' THEN 'SIM' ELSE 'NAO' END A2_PLFIL  ,
        REGEXP_REPLACE (TRIM(A2_SIGLCR ),'[[:cntrl:];"]')A2_SIGLCR ,
        REGEXP_REPLACE (TRIM(A2_CONREG ),'[[:cntrl:];"]')A2_CONREG ,
        A2_DATBLO ,
        A2_PLPEDES,
        REGEXP_REPLACE (TRIM(A2_CBO    ),'[[:cntrl:];"]')A2_CBO    ,
        REGEXP_REPLACE (TRIM(A2_CNAE   ),'[[:cntrl:];"]')A2_CNAE   ,
        REGEXP_REPLACE (TRIM(A2_ENDCOMP),'[[:cntrl:];"]')A2_ENDCOMP,
        CASE 
        WHEN A2_CIVIL = '1' THEN 'SOLTEIRO' 
        WHEN A2_CIVIL = '2' THEN 'CASADO'
        WHEN A2_CIVIL = '3' THEN 'DIVORCIADO'
        WHEN A2_CIVIL = '4' THEN 'VIUVO'
        WHEN A2_CIVIL = '5' THEN 'CONPANHEIRO(A)'
        END A2_CIVIL, //TRATAR CAMPO com conteudo: 1=Solteiro;2=Casado;3=Divorciado;4=Viuvo;5=Companheiro(a);                                                                      
        REGEXP_REPLACE (TRIM(A2_GRPDEP ),'[[:cntrl:];"]')A2_GRPDEP ,
        A2_ROYMIN ,
        REGEXP_REPLACE (TRIM(A2_SATIV1 ),'[[:cntrl:];"]')A2_SATIV1 ,
        CASE
        WHEN A2_PAGAMEN = '1' THEN 'NAO'
        ELSE 'SIM'
        END A2_PAGAMEN, //TRATAR CAMPO com conteudo: 1=Nao;2=Sim                                                                                                                     
        A2_SUBCOD , //TRATAR CAMPO com conteudo:                                                                                                                                 
        A2_TIPAWB , //TRATAR CAMPO com conteudo:                                                                                                                                 
        CASE WHEN A2_RECSEST= '1' THEN 'SIM' ELSE 'NAO' END A2_RECSEST,
        REGEXP_REPLACE (TRIM(A2_FILDEB ),'[[:cntrl:];"]')A2_FILDEB ,
        CASE WHEN A2_RECPIS = '1' THEN 'SIM' ELSE 'NAO' END A2_RECPIS ,
        CASE WHEN A2_RECCSLL= '1' THEN 'SIM' ELSE 'NAO' END A2_RECCSLL,
        CASE WHEN A2_RECCOFI= '1' THEN 'SIM' ELSE 'NAO' END A2_RECCOFI,
        REGEXP_REPLACE (TRIM(A2_ABICS  ),'[[:cntrl:];"]')A2_ABICS  ,
        REGEXP_REPLACE (TRIM(A2_CODFAV ),'[[:cntrl:];"]')A2_CODFAV ,
        REGEXP_REPLACE (TRIM(A2_LOJFAV ),'[[:cntrl:];"]')A2_LOJFAV ,
        A2_NUMDEP ,
        case
        when A2_CALCIRF = '1' THEN 'NORMAL'
        when A2_CALCIRF = '2' THEN 'IRRF BAIXA'
        when A2_CALCIRF = '3' THEN 'SIMPLES'
        when A2_CALCIRF = '4' THEN 'EMPRESA INDIVIDUAL'
        end A2_CALCIRF, //TRATAR CAMPO com conteudo: 1=Normal;2=IRRF Baixa;3=Simples;4=Empresa Individual                                                                            
        REGEXP_REPLACE (TRIM(A2_CODADM ),'[[:cntrl:];"]')A2_CODADM ,
        REGEXP_REPLACE (TRIM(A2_VINCULO),'[[:cntrl:];"]')A2_VINCULO,
        A2_DTINIV ,
        A2_DTFIMV ,
        REGEXP_REPLACE (TRIM(A2_NIFEX  ),'[[:cntrl:];"]')A2_NIFEX  ,
        REGEXP_REPLACE (TRIM(A2_NUMRA  ),'[[:cntrl:];"]')A2_NUMRA  ,
        REGEXP_REPLACE (TRIM(A2_TPCON  ),'[[:cntrl:];"]')A2_TPCON  ,
        CASE 
        WHEN A2_IMPIP = '1' THEN 'PEDIDO COMPRA'
        WHEN A2_IMPIP = '2' THEN 'RECEBIMENTO'
        WHEN A2_IMPIP = '3' THEN 'NAO IMPRIME'
        WHEN A2_IMPIP = '4' THEN 'DOCUMENTO ENTRADA'
        END A2_IMPIP  , //TRATAR CAMPO com conteudo: 1=Pedido Compra;2=Recebimento;3=Nao Imprime;4=Documento Entrada                                                                 
        A2_PRSTSER, //TRATAR CAMPO com conteudo:                                                                                                                                 
        REGEXP_REPLACE (TRIM(A2_PAISEX ),'[[:cntrl:];"]')A2_PAISEX ,
        CASE WHEN A2_RFABOV = '1' THEN 'SIM' ELSE 'NAO' END A2_RFABOV ,
        CASE WHEN A2_RECFET = '1' THEN 'SIM' ELSE 'NAO' END A2_RECFET ,
        CASE WHEN A2_REGESIM= '1' THEN 'SIM' ELSE 'NAO' END A2_REGESIM,
        REGEXP_REPLACE (TRIM(A2_CODINSS),'[[:cntrl:];"]')A2_CODINSS,
        CASE WHEN A2_INSCMU = '1' THEN 'SIM' ELSE 'NAO' END A2_INSCMU ,
        CASE WHEN A2_SIMPNAC= '1' THEN 'SIM' ELSE 'NAO' END A2_SIMPNAC,
        CASE WHEN A2_RFACS  = '1' THEN 'SIM' ELSE 'NAO' END A2_RFACS  ,
        CASE WHEN A2_CTARE  = '1' THEN 'SIM' ELSE 'NAO' END A2_CTARE  ,
        CASE WHEN A2_MJURIDI= '1' THEN 'SIM' ELSE 'NAO' END A2_MJURIDI,
        REGEXP_REPLACE (TRIM(A2_CPFIRP ),'[[:cntrl:];"]')A2_CPFIRP ,
        REGEXP_REPLACE (TRIM(A2_NEMPR  ),'[[:cntrl:];"]')A2_NEMPR  ,
        REGEXP_REPLACE (TRIM(A2_NUMEX  ),'[[:cntrl:];"]')A2_NUMEX  ,
        REGEXP_REPLACE (TRIM(A2_RNTRC  ),'[[:cntrl:];"]')A2_RNTRC  ,
        REGEXP_REPLACE (TRIM(A2_ESTEX  ),'[[:cntrl:];"]')A2_ESTEX  ,
        REGEXP_REPLACE (TRIM(A2_POSEX  ),'[[:cntrl:];"]')A2_POSEX  ,
        REGEXP_REPLACE (TRIM(A2_TRBEX  ),'[[:cntrl:];"]')A2_TRBEX  ,
        CASE
        WHEN A2_CONFFIS = '0' THEN 'PARAMETRO'
        WHEN A2_CONFFIS = '1' THEN 'PRE-NOTA'
        WHEN A2_CONFFIS = '2' THEN 'NOTA FISCAL'
        WHEN A2_CONFFIS = '3' THEN 'NAO UTILIZA'
        END A2_CONFFIS, //TRATAR CAMPO com conteudo: 0=Parâmetro;1=Pré-Nota;2=Nota Fiscal;3=Não utiliza                                                                              
        REGEXP_REPLACE (TRIM(A2_TPREX  ),'[[:cntrl:];"]')A2_TPREX  ,
        A2_DTFIMR ,
        REGEXP_REPLACE (TRIM(A2_FILTRF ),'[[:cntrl:];"]')A2_FILTRF ,
        A2_DTRNTRC,
        A2_DTINIR ,
        CASE
        WHEN A2_TIPCTA = '1' THEN 'CONTA CORRENTE'
        WHEN A2_TIPCTA = '2' THEN 'CONTA POUPANCA'
        END A2_TIPCTA , //TRATAR CAMPO com conteudo: 1=Conta Corrente;2=Conta poupança                                                                                               
        CASE WHEN A2_ENDNOT = '1' THEN 'SIM' ELSE 'NAO' END A2_ENDNOT ,
        REGEXP_REPLACE (TRIM(A2_MUNSC  ),'[[:cntrl:];"]')A2_MUNSC  ,
        REGEXP_REPLACE (TRIM(A2_COMPLEM),'[[:cntrl:];"]')A2_COMPLEM,
        REGEXP_REPLACE (TRIM(A2_CIDEX  ),'[[:cntrl:];"]')A2_CIDEX  ,
        CASE WHEN A2_INCLTMG= '1' THEN 'SIM' ELSE 'NAO' END A2_INCLTMG,
        CASE WHEN A2_FOMEZER= '1' THEN 'SIM' ELSE 'NAO' END A2_FOMEZER,
        REGEXP_REPLACE (TRIM(A2_COMPLR ),'[[:cntrl:];"]')A2_COMPLR ,
        CASE
        WHEN A2_FRETISS = '1' THEN 'VALOR MINIMO'
        WHEN A2_FRETISS = '2' THEN 'SEMPRE RETEM'
        END A2_FRETISS, //TRATAR CAMPO com conteudo: 1=Valor mínimo;2=Sempre retém                                                                                                   
        REGEXP_REPLACE (TRIM(A2_LOGEX  ),'[[:cntrl:];"]')A2_LOGEX  ,
        REGEXP_REPLACE (TRIM(A2_TELRE  ),'[[:cntrl:];"]')A2_TELRE  ,
        REGEXP_REPLACE (TRIM(A2_CGCEX  ),'[[:cntrl:];"]')A2_CGCEX  ,
        REGEXP_REPLACE (TRIM(A2_CODSIAF),'[[:cntrl:];"]')A2_CODSIAF,
        CASE WHEN A2_MINIRF = '1' THEN 'SIM' ELSE 'NAO' END A2_MINIRF ,
        CASE WHEN A2_IRPROG = '1' THEN 'SIM' ELSE 'NAO' END A2_IRPROG ,
        REGEXP_REPLACE (TRIM(A2_BREEX  ),'[[:cntrl:];"]')A2_BREEX  ,
        REGEXP_REPLACE (TRIM(A2_BAIEX  ),'[[:cntrl:];"]')A2_BAIEX  ,
        CASE WHEN A2_INCULT = '1' THEN 'SIM' ELSE 'NAO' END A2_INCULT ,
        CASE WHEN A2_CPOMSP = '1' THEN 'SIM' ELSE 'NAO' END A2_CPOMSP ,
        REGEXP_REPLACE (TRIM(A2_TPLOGR ),'[[:cntrl:];"]')A2_TPLOGR ,
        REGEXP_REPLACE (TRIM(A2_SIGLA  ),'[[:cntrl:];"]')A2_SIGLA  ,
        CASE WHEN A2_TRIBFAV= '1' THEN 'SIM' ELSE 'NAO' END A2_TRIBFAV,
        REGEXP_REPLACE (TRIM(A2_XCONTAT),'[[:cntrl:];"]')A2_XCONTAT,
        CASE WHEN A2_CCICMS = '1' THEN 'SIM' ELSE 'NAO' END A2_CCICMS ,
        REGEXP_REPLACE (TRIM(A2_USERLGI),'[[:cntrl:];"]')A2_USERLGI,
        REGEXP_REPLACE (TRIM(A2_USERLGA),'[[:cntrl:];"]')A2_USERLGA,
        case
        when A2_XINTER = 'S' THEN 'SIM'
        WHEN A2_XINTER = 'N' THEN 'NAO'
        end A2_XINTER , //TRATAR CAMPO com conteudo: S=SIM;N=NAO                                                                                                                     
        REGEXP_REPLACE (TRIM(A2_XNUMPIS),'[[:cntrl:];"]')A2_XNUMPIS,
        REGEXP_REPLACE (TRIM(A2_XRGANTT),'[[:cntrl:];"]')A2_XRGANTT,
        REGEXP_REPLACE (TRIM(A2_XCTFRET),'[[:cntrl:];"]')A2_XCTFRET,
        REGEXP_REPLACE (TRIM(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(A2_XOBSERV,250,1))) ,'[[:cntrl:];"]')A2_XOBSERV,
        CASE WHEN A2_RETISI = '1' THEN 'SIM' ELSE 'NAO' END A2_RETISI ,
        A2_ISICM  , //TRATAR CAMPO com conteudo:                                                                                                                                 
        CASE WHEN A2_XTRNS  = '1' THEN 'SIM' ELSE 'NAO' END A2_XTRNS  ,
        A2_XDTVALI,
        CASE
        WHEN A2_TPCONTA = '1' THEN 'CONTA CORRENTE'
        WHEN A2_TPCONTA= '2' THEN 'POUPANCA'
        END A2_TPCONTA, //TRATAR CAMPO com conteudo: 1=Conta Corrente;2=Poupanca                                                                                                     
        CASE
        WHEN A2_TPRNTRC = '1' THEN 'TAC'
        WHEN A2_TPRNTRC = '2' THEN 'ETC'
        WHEN A2_TPRNTRC = '3' THEN 'CTC'
        END A2_TPRNTRC, //TRATAR CAMPO com conteudo: 1=TAC;2=ETC;3=CTC                                                                                                               
        REGEXP_REPLACE (TRIM(A2_IDHIST ),'[[:cntrl:];"]')A2_IDHIST ,
        CASE
        WHEN A2_STRNTRC = '1' THEN 'ATIVO'
        WHEN A2_STRNTRC = '2' THEN 'INATIVO'
        END A2_STRNTRC, //TRATAR CAMPO com conteudo: 1=Ativo;2=Inativo                                                                                                               
        CASE
        WHEN A2_SITESBH = '1' THEN 'EX PR BDE'
        WHEN A2_SITESBH = '2' THEN 'PR DE SER C/DED'
        WHEN A2_SITESBH = '3' THEN 'CON CIV'
        WHEN A2_SITESBH = '4' THEN 'AG DE TU/ADM FUN'
        WHEN A2_SITESBH = '5' THEN 'PRO E PUB/INT'
        WHEN A2_SITESBH = '6' THEN 'PRO E PUB/INT IS'
        WHEN A2_SITESBH = '7' THEN 'NAO IN/RE/REP'
        END A2_SITESBH, //TRATAR CAMPO com conteudo: 1=Ex Pr bde Ser;2=Pr de Ser c/ Ded;3=Con Civ;4=Ag de Tu/Adm Fun;5=Pro e Pub/Int;6=Pro e Pub/Int Is;7=Não In/Re/Rep              
        CASE
        WHEN A2_TPJ = '1' THEN 'ME-MICRO EMPRESA'
        WHEN A2_TPJ = '2' THEN 'EPP - EMP. PEQUENO PORTE'
        WHEN A2_TPJ = '3' THEN 'MEI - MICROEMPREENDEDOR INDIVIDUAL'
        WHEN A2_TPJ = '4' THEN 'COOPERATIVA'
        WHEN A2_TPJ = '5' THEN 'NAO OPTANTE'
        END A2_TPJ    , //TRATAR CAMPO com conteudo: 1=ME - Micro Empresa;2=EPP - Empresas de Pequeno Porte;3=MEI - Microempreendedor Individual;4=Cooperativa;5=Não optante         
        CASE
        WHEN A2_LOCQUIT = '0' THEN 'FILIAL'
        WHEN A2_LOCQUIT = '1' THEN 'POSTO'
        END A2_LOCQUIT, //TRATAR CAMPO com conteudo: 0=Filial;1=Posto                                                                                                                
        CASE WHEN A2_EQPTAC = '1' THEN 'SIM' ELSE 'NAO' END A2_EQPTAC ,
        REGEXP_REPLACE (TRIM(A2_APOLICE),'[[:cntrl:];"]')A2_APOLICE,
        REGEXP_REPLACE (TRIM(A2_XCONTA ),'[[:cntrl:];"]')A2_XCONTA ,
        REGEXP_REPLACE (TRIM(A2_RESPTRI),'[[:cntrl:];"]')A2_RESPTRI,
        CASE WHEN A2_RECFMD = '1' THEN 'SIM' ELSE 'NAO' END A2_RECFMD ,
        REGEXP_REPLACE (TRIM(A2_XADIANT),'[[:cntrl:];"]')A2_XADIANT,
        CASE
        WHEN A2_INOVAUT = '1' THEN 'PARTICIPA'
        WHEN A2_INOVAUT = '2' THEN 'NAO PARTICIPA'
        WHEN A2_INOVAUT = '3' THEN 'CONVIDAR'
        END A2_INOVAUT, //TRATAR CAMPO com conteudo: 1=Participa;2=Não Participa;3=Convidar                                                                                          
        A2_DTCONV ,
        REGEXP_REPLACE (TRIM(A2_NOMRESP),'[[:cntrl:];"]')A2_NOMRESP,
        REGEXP_REPLACE (TRIM(A2_CARGO  ),'[[:cntrl:];"]')A2_CARGO  ,
        CASE WHEN A2_CONTRIB= '1' THEN 'SIM' ELSE 'NAO' END A2_CONTRIB,
        CASE WHEN A2_RFUNDES= '1' THEN 'SIM' ELSE 'NAO' END A2_RFUNDES,
        CASE WHEN A2_RIMAMT = '1' THEN 'SIM' ELSE 'NAO' END A2_RIMAMT ,
        CASE WHEN A2_RFASEMT= '1' THEN 'SIM' ELSE 'NAO' END A2_RFASEMT,
        REGEXP_REPLACE (TRIM(A2_MSEXP  ),'[[:cntrl:];"]')A2_MSEXP  ,
        REGEXP_REPLACE (TRIM(A2_MSIDENT),'[[:cntrl:];"]')A2_MSIDENT,
        CASE WHEN A2_CALCINP= '1' THEN 'SIM' ELSE 'NAO' END A2_CALCINP,
        CASE WHEN A2_MINPUB = '1' THEN 'SIM' ELSE 'NAO' END A2_MINPUB ,
        A2_MSRESP , //TRATAR CAMPO com conteudo:                                                                                                                                 
        REGEXP_REPLACE (TRIM(A2_XOBSBLQ),'[[:cntrl:];"]')A2_XOBSBLQ,
        A2_XDTBLOQ,
        CASE
        WHEN A2_DEDBSPC = '1' THEN 'LEGADO'
        WHEN A2_DEDBSPC = '2' THEN 'ICMS E IPI'
        WHEN A2_DEDBSPC = '3' THEN 'ICMS'
        WHEN A2_DEDBSPC = '4' THEN 'IPI'
        WHEN A2_DEDBSPC = '5' THEN 'NENHUM'
        WHEN A2_DEDBSPC = '6' THEN 'SOMA IPI'
        END A2_DEDBSPC, //TRATAR CAMPO com conteudo: 1=Legado;2=ICMS e IPI;3=ICMS;4=IPI;5=Nenhum;6=Soma IPI                                                                          
        CASE
        WHEN A2_INDRUR = '0' THEN 'NAO E PROD.RURAL'
        WHEN A2_INDRUR = '1' THEN 'SEG.ESPECI.ENT.PAA'
        END A2_INDRUR , //TRATAR CAMPO com conteudo: 0=Não é prod.rural;1=Seg.Espec.Geral PF;2=Seg.Espec.Ent.PAA PF;3=Ent.PAA PJ                                                     
        REGEXP_REPLACE (TRIM(A2_UFFIC  ),'[[:cntrl:];"]')A2_UFFIC  ,
        CASE WHEN A2_ISSRSLC= '1' THEN 'SIM' ELSE 'NAO' END A2_ISSRSLC,
        CASE
        WHEN A2_TPREG = '1' THEN 'NAO CUMULATIVO'
        WHEN A2_TPREG = '2' THEN 'CUMULATIVO'
        END A2_TPREG  , //TRATAR CAMPO com conteudo: 1=Não Cumulativo;2=Cumulativo                                                                                                   
        CASE
        WHEN A2_SUBCON = '1' THEN 'SUB CONTRATISTA'
        WHEN A2_SUBCON = '2' THEN 'NAO SUB CONTRATISTA'
        END A2_SUBCON , //TRATAR CAMPO com conteudo: 1=Sub Contratista;2=Não Sub Contratista                                                                                         
        REGEXP_REPLACE (TRIM(A2_CATEG  ),'[[:cntrl:];"]')A2_CATEG  ,
        REGEXP_REPLACE (TRIM(A2_CODNIT ),'[[:cntrl:];"]')A2_CODNIT ,
        A2_DTNASC ,
        REGEXP_REPLACE (TRIM(A2_OCORREN),'[[:cntrl:];"]')A2_OCORREN,
        CASE
        WHEN A2_DESPORT = '0' THEN 'NAO'
        WHEN A2_DESPORT = '1' THEN 'SIM'
        END A2_DESPORT, //TRATAR CAMPO com conteudo: 0=Não;1=Sim                                                                                                                     
        REGEXP_REPLACE (TRIM(A2_FORMPAG),'[[:cntrl:];"]')A2_FORMPAG,
        REGEXP_REPLACE (TRIM(A2_CODFI  ),'[[:cntrl:];"]')A2_CODFI  ,
        A2_MSBLQD ,
        CASE WHEN A2_FORNEMA= '1' THEN 'SIM' ELSE 'NAO' END A2_FORNEMA,
        CASE WHEN A2_REGPB  = '1' THEN 'SIM' ELSE 'NAO' END A2_REGPB  ,
        CASE
        WHEN A2_MOTNIF = '1' THEN 'DISPENSADO DO NIF'
        WHEN A2_MOTNIF = '2' THEN 'PAIS NAO EXIGE NIF'
        END A2_MOTNIF , //TRATAR CAMPO com conteudo: 1=Dispensado do NIF;2=País não exige NIF                                                                                        
        REGEXP_REPLACE (TRIM(A2_CLIENTE),'[[:cntrl:];"]')A2_CLIENTE,
        REGEXP_REPLACE (TRIM(A2_DRPEXP ),'[[:cntrl:];"]')A2_DRPEXP ,
        CASE WHEN A2_CPRB   = '1' THEN 'SIM' ELSE 'NAO' END A2_CPRB   ,
        REGEXP_REPLACE (TRIM(A2_LOJCLI ),'[[:cntrl:];"]')A2_LOJCLI ,
        CASE
        WHEN A2_GROSSIR = '1' THEN 'IMP.SERV. IRRF'
        WHEN A2_GROSSIR = '2' THEN 'IMP.SERV. IRRF + CIDE'
        WHEN A2_GROSSIR = '3' THEN 'IMP.SERV. + VAL. SERVICO'
        END A2_GROSSIR, //TRATAR CAMPO com conteudo: 0=Sem Gross UP;1=Imp. Serv. IRRF;2=Imp. Serv. IRRF + CIDE;3=Imp. Serv. IRRF + Val. Serviço                                      
        CASE
        WHEN A2_INDCP = '1' THEN 'SOBRE A COMERCIALIZACAO DA SUA PRODUCAO'
        WHEN A2_INDCP = '2' THEN 'SOBRE A FOLHA DE PAGAMENTO'
        END A2_INDCP  , //TRATAR CAMPO com conteudo: 1=Sobre a comercializacao da sua producao;2=Sobre a folha de pagamento                                                          
        CASE
        WHEN A2_TPENT = '1' THEN 'IMUNE' 
        WHEN A2_TPENT = '2' THEN 'ISENTO'
        END A2_TPENT  , //TRATAR CAMPO com conteudo: 1=Imune;2=Isento                                                                                                                
        REGEXP_REPLACE (TRIM(A2_CPFRUR ),'[[:cntrl:];"]')A2_CPFRUR ,
        REGEXP_REPLACE (TRIM(A2_PAISSUB),'[[:cntrl:];"]')A2_PAISSUB,
        REGEXP_REPLACE (TRIM(A2_XCGCMTR),'[[:cntrl:];"]')A2_XCGCMTR,
        REGEXP_REPLACE (TRIM(A2_XFILFUN),'[[:cntrl:];"]')A2_XFILFUN,
        REGEXP_REPLACE (TRIM(A2_CATEFD ),'[[:cntrl:];"]')A2_CATEFD ,
        CC2_MUN ,  
        CT1_DESC01,
        A4_NOME,   
        E4_DESCRI ,
        ED_DESCRIC,
        YA_DESCR  
    FROM %table:SA2% A2
        LEFT JOIN %table:CC2% CC2 ON A2_COD_MUN = CC2_CODMUN and a2_est = cc2_est AND cc2.%notdel%
        LEFT JOIN %table:SED% SED ON A2_NATUREZ = ED_CODIGO AND sed.%notdel%
        LEFT JOIN %table:SA4% SA4 ON A2_TRANSP = A4_COD AND sa4.%notdel%
        LEFT JOIN %table:SE4% SE4 ON E4_FILIAL = '02' AND A2_COND = E4_CODIGO AND se4.%notdel%
        LEFT JOIN %table:CT1% CT1 ON A2_CONTA = CT1_CONTA AND ct1.%notdel%
        LEFT JOIN %table:SYA% SYA ON A2_PAIS = YA_CODGI AND sya.%notdel%
    WHERE A2.%notdel%
    //and rownum<101

EndSql

_cQuery:=GetLastQuery()

_aStru:=DBSTRUCT()

DBGOTOP()

_nHandle    :=FCREATE(_cArquivo)

IF!EOF()

    HTMLMAIL()

    Whil!Eof()

        For x:=1 To Len(_aStru)
            If _aStru[x,2]=="C"

                MONTACAMPO()

                //FWrite(_nHandle, &(_aStru[x,1])+';')
                FWrite(_nHandle, _cCampo)
            Else
                FWrite(_nHandle, ';')
            END
        NEXT

        FWrite(_nHandle, CRLF)

        DBSKIP()
    END

    //_cNarquivo:=_cArquivo+"_"+Dtos(dDatabase)+".CSV"
    //ENVARQS(_cNarquivo,_cHtml,"DW - QCCCLIENTE")

    _cNarquivo:=_cTabela+"_"+Dtos(dDatabase)+".CSV"

    ENVFARQS(_cNarquivo)

else
    GERLOG(_cTabela,_cOrig,"",0)
END

RETURN

/*/{Protheus.doc} QMOVTIT
    Extração de dados de movimentos bancários
    @type  Static Function
    @author user
    Edson Bella Gonçalves - MRC
    @since 21/03/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)@see (links_or_references)
/*/

Static Function QMOVTIT()

Local   _aPergs     := {}
Local   _cFilialDe  := Space(6)
Local   _cFilialAte := Space(6)
Local   _dEmissaoD  := Ctod('  /  /    ')
Local   _dEmissaoA  := Ctod('  /  /    ')

Private _nNfdias    := GetMv("EL_DWMBDIA")
Private _nNfdiasR   := GetMv("EL_DWMBQD")
Private _cAlias     :=  GetNextAlias()
Private _nHandle
Private _cTabela    :=  "QMOVTIT"
Private _cArquivo   :=  _cPasta+_cTabela

If _lNUser
    MV_PAR01    :=  ' '
    MV_PAR02    :=  'ZZZZZZ'
    MV_PAR03    := CtoD('  /  /    ')
    MV_PAR04    := CtoD('31/12/2050')

else
    aAdd(_aPergs, {1, "Filial de",   _cFilialDe,    "", ".T.", "",".T.", 40,.T.})
    aAdd(_aPergs, {1, "Filial até",  _cFilialAte,   "", ".T.", "",".T.", 40,.F.})
    aAdd(_aPergs, {1, "Emissão de",  _dEmissaoD,    "", ".T.", "",".T.", 60,.T.})
    aAdd(_aPergs, {1, "Emissão até", _dEmissaoA,    "", ".T.", "",".T.", 60,.F.})

    If !ParamBox(_aPergs, "Informe os parâmetros")
        AtuConou('2')
        RETURN .t.
    End

END

MsAguarde({|| PQMOVTIT()}, "Aguarde...", "Processando Registros "+_cTabela+"...")

AtuConou('4')

Return

//
Static Function PQMOVTIT

AtuConou('3')

BeginSql Alias _cAlias

    SELECT
        REGEXP_REPLACE (TRIM(E5_FILIAL ),'[[:cntrl:];"]')E5_FILIAL ,
        E5_DATA   ,
        REGEXP_REPLACE (TRIM(E5_TIPO   ),'[[:cntrl:];"]')E5_TIPO   ,
        REGEXP_REPLACE (TRIM(E5_MOEDA  ),'[[:cntrl:];"]')E5_MOEDA  ,
        E5_VALOR  ,
        REGEXP_REPLACE (TRIM(E5_NATUREZ),'[[:cntrl:];"]')E5_NATUREZ,
        REGEXP_REPLACE (TRIM(E5_BANCO  ),'[[:cntrl:];"]')E5_BANCO  ,
        REGEXP_REPLACE (TRIM(E5_AGENCIA),'[[:cntrl:];"]')E5_AGENCIA,
        REGEXP_REPLACE (TRIM(E5_CONTA  ),'[[:cntrl:];"]')E5_CONTA  ,
        REGEXP_REPLACE (TRIM(E5_XCCUSTO),'[[:cntrl:];"]')E5_XCCUSTO,
        REGEXP_REPLACE (TRIM(E5_NUMCHEQ),'[[:cntrl:];"]')E5_NUMCHEQ,
        REGEXP_REPLACE (TRIM(E5_DOCUMEN),'[[:cntrl:];"]')E5_DOCUMEN,
        E5_VENCTO ,
        E5_RECPAG ,                                                                                                                                 
        REGEXP_REPLACE (TRIM(E5_BENEF  ),'[[:cntrl:];"]')E5_BENEF  ,
        REGEXP_REPLACE (TRIM(E5_HISTOR ),'[[:cntrl:];"]')E5_HISTOR ,
        REGEXP_REPLACE (TRIM(E5_TIPODOC),'[[:cntrl:];"]')E5_TIPODOC,
        E5_VLMOED2,
        REGEXP_REPLACE (TRIM(E5_LA     ),'[[:cntrl:];"]')E5_LA     ,
        E5_SITUACA,
        REGEXP_REPLACE (TRIM(E5_LOTE   ),'[[:cntrl:];"]')E5_LOTE   ,
        REGEXP_REPLACE (TRIM(E5_PREFIXO),'[[:cntrl:];"]')E5_PREFIXO,
        REGEXP_REPLACE (TRIM(E5_NUMERO ),'[[:cntrl:];"]')E5_NUMERO ,
        REGEXP_REPLACE (TRIM(E5_PARCELA),'[[:cntrl:];"]')E5_PARCELA,
        REGEXP_REPLACE (TRIM(E5_CLIFOR ),'[[:cntrl:];"]')E5_CLIFOR ,
        REGEXP_REPLACE (TRIM(E5_LOJA   ),'[[:cntrl:];"]')E5_LOJA   ,
        E5_DTDIGIT,
        CASE
        WHEN E5_TIPOLAN = 'D' THEN 'DEBITO'
        WHEN E5_TIPOLAN = 'C' THEN 'CREDITO'
        WHEN E5_TIPOLAN = 'X' THEN 'PARTIDA DOBRADA'
        END E5_TIPOLAN,                                                                                        
        REGEXP_REPLACE (TRIM(E5_DEBITO ),'[[:cntrl:];"]')E5_DEBITO ,
        REGEXP_REPLACE (TRIM(E5_CREDITO),'[[:cntrl:];"]')E5_CREDITO,
        REGEXP_REPLACE (TRIM(E5_MOTBX  ),'[[:cntrl:];"]')E5_MOTBX  ,
        CASE WHEN E5_RATEIO = 'S' THEN 'SIM' ELSE 'NAO' END E5_RATEIO ,
        E5_RECONC ,                                                                                                                             
        REGEXP_REPLACE (TRIM(E5_SEQ    ),'[[:cntrl:];"]')E5_SEQ    ,
        E5_DTDISPO,
        REGEXP_REPLACE (TRIM(E5_CCD    ),'[[:cntrl:];"]')E5_CCD    ,
        REGEXP_REPLACE (TRIM(E5_CCC    ),'[[:cntrl:];"]')E5_CCC    ,
        REGEXP_REPLACE (TRIM(E5_ARQRAT ),'[[:cntrl:];"]')E5_ARQRAT ,
        REGEXP_REPLACE (TRIM(E5_OK     ),'[[:cntrl:];"]')E5_OK     ,
        REGEXP_REPLACE (TRIM(E5_IDENTEE),'[[:cntrl:];"]')E5_IDENTEE,
        REGEXP_REPLACE (TRIM(E5_ORDREC ),'[[:cntrl:];"]')E5_ORDREC ,
        REGEXP_REPLACE (TRIM(E5_FILORIG),'[[:cntrl:];"]')E5_FILORIG,
        REGEXP_REPLACE (TRIM(E5_ARQCNAB),'[[:cntrl:];"]')E5_ARQCNAB,
        E5_VLJUROS,
        E5_VLMULTA,
        E5_VLCORRE,
        E5_VLDESCO,
        REGEXP_REPLACE (TRIM(E5_SITUA  ),'[[:cntrl:];"]')E5_SITUA  ,
        REGEXP_REPLACE (TRIM(E5_CNABOC ),'[[:cntrl:];"]')E5_CNABOC ,
        REGEXP_REPLACE (TRIM(E5_ITEMD  ),'[[:cntrl:];"]')E5_ITEMD  ,
        REGEXP_REPLACE (TRIM(E5_ITEMC  ),'[[:cntrl:];"]')E5_ITEMC  ,
        REGEXP_REPLACE (TRIM(E5_CLVLDB ),'[[:cntrl:];"]')E5_CLVLDB ,
        REGEXP_REPLACE (TRIM(E5_CLVLCR ),'[[:cntrl:];"]')E5_CLVLCR ,
        REGEXP_REPLACE (TRIM(E5_PROJPMS),'[[:cntrl:];"]')E5_PROJPMS,
        REGEXP_REPLACE (TRIM(E5_EDTPMS ),'[[:cntrl:];"]')E5_EDTPMS ,
        REGEXP_REPLACE (TRIM(E5_TASKPMS),'[[:cntrl:];"]')E5_TASKPMS,
        CASE 
        WHEN E5_MODSPB = '1' THEN 'TED'
        WHEN E5_MODSPB = '2' THEN 'CIP'
        WHEN E5_MODSPB = '3' THEN 'COMP'
        END E5_MODSPB ,                                                                                                            
        REGEXP_REPLACE (TRIM(E5_FATURA ),'[[:cntrl:];"]')E5_FATURA ,
        E5_TXMOEDA,
        REGEXP_REPLACE (TRIM(E5_FATPREF),'[[:cntrl:];"]')E5_FATPREF,
        E5_SITCOB ,                                                                                                                              
        REGEXP_REPLACE (TRIM(E5_CODORCA),'[[:cntrl:];"]')E5_CODORCA,
        REGEXP_REPLACE (TRIM(E5_FORNADT),'[[:cntrl:];"]')E5_FORNADT,
        REGEXP_REPLACE (TRIM(E5_LOJAADT),'[[:cntrl:];"]')E5_LOJAADT,
        REGEXP_REPLACE (TRIM(E5_CLIENTE),'[[:cntrl:];"]')E5_CLIENTE,
        REGEXP_REPLACE (TRIM(E5_FORNECE),'[[:cntrl:];"]')E5_FORNECE,
        REGEXP_REPLACE (TRIM(E5_SERREC ),'[[:cntrl:];"]')E5_SERREC ,
        E5_MOVCX  ,
        REGEXP_REPLACE (TRIM(E5_OPERAD ),'[[:cntrl:];"]')E5_OPERAD ,
        REGEXP_REPLACE (TRIM(E5_KEY    ),'[[:cntrl:];"]')E5_KEY    ,
        E5_MULTNAT,

        REGEXP_REPLACE (TRIM(E5_AGLIMP ),'[[:cntrl:];"]')E5_AGLIMP ,
        E5_VLACRES,
        E5_VRETPIS,
        E5_VRETCOF,
        E5_VRETCSL,
        E5_PRETPIS,                                                                                                                                 
        E5_PRETCOF,                                                                                                                                 
        E5_PRETCSL,                                                                                                                                 
        E5_VLDECRE,
        REGEXP_REPLACE (TRIM(E5_AUTBCO ),'[[:cntrl:];"]')E5_AUTBCO ,
        E5_PRETIRF,
        E5_VRETIRF,
        E5_VRETISS,
        REGEXP_REPLACE (TRIM(E5_NUMMOV ),'[[:cntrl:];"]')E5_NUMMOV ,
        E5_BASEIRF,
        REGEXP_REPLACE (TRIM(E5_PROCTRA),'[[:cntrl:];"]')E5_PROCTRA,
        REGEXP_REPLACE (TRIM(E5_NODIA  ),'[[:cntrl:];"]')E5_NODIA  ,
        REGEXP_REPLACE (TRIM(E5_ORIGEM ),'[[:cntrl:];"]')E5_ORIGEM ,
        REGEXP_REPLACE (TRIM(E5_DIACTB ),'[[:cntrl:];"]')E5_DIACTB ,
        REGEXP_REPLACE (TRIM(E5_FORMAPG),'[[:cntrl:];"]')E5_FORMAPG,
        CASE 
        WHEN E5_TPDESC = 'C' THEN 'CONDICIONAL'
        WHEN E5_TPDESC = 'I' THEN 'INCONDICIONAL'
        END E5_TPDESC ,                                                                                           
        E5_PRISS  ,
        E5_PRINSS ,
        REGEXP_REPLACE (TRIM(E5_USERLGI),'[[:cntrl:];"]')E5_USERLGI,
        E5_FLDMED ,
        REGEXP_REPLACE (TRIM(E5_CGC    ),'[[:cntrl:];"]')E5_CGC    ,
        REGEXP_REPLACE (TRIM(E5_IDMOVI ),'[[:cntrl:];"]')E5_IDMOVI ,
        REGEXP_REPLACE (TRIM(E5_USERLGA),'[[:cntrl:];"]')E5_USERLGA,
        E5_DTCANBX,
        REGEXP_REPLACE (TRIM(E5_XFILORI),'[[:cntrl:];"]')E5_XFILORI,
        REGEXP_REPLACE (TRIM(E5_CCUSTO ),'[[:cntrl:];"]')E5_CCUSTO ,
        REGEXP_REPLACE (TRIM(E5_SEQCON ),'[[:cntrl:];"]')E5_SEQCON ,
        REGEXP_REPLACE (TRIM(E5_SDOCREC),'[[:cntrl:];"]')E5_SDOCREC,
        E5_MOVFKS ,
        REGEXP_REPLACE (TRIM(E5_IDORIG ),'[[:cntrl:];"]')E5_IDORIG ,
        E5_PRETINS,
        E5_VRETINS,
        REGEXP_REPLACE (TRIM(E5_TABORI ),'[[:cntrl:];"]')E5_TABORI ,

        ED_DESCRIC,
        case
        when e5_recpag='P' then a2_nome 
        when e5_recpag='R' then a1_nome 
        end E5_NOMCLIFOR,

        ct1.ctt_desc01 dE5_CCUSTO,
        ct2.ctt_desc01 dE5_XCCUSTO, 
        ct11.ct1_desc01 dct1_credito, 
        ct12.ct1_desc01 dct1_debito,
        CASE
        WHEN E5_MOEDA = '01' THEN 'REAL '                                                                                                                                                                                                                                                     
        WHEN E5_MOEDA = '02' THEN 'DOLAR'                                                                                                                                                                                                                                                     
        WHEN E5_MOEDA = '03' THEN 'UFIR '                                                                                                                                                                                                                                                     
        WHEN E5_MOEDA = '04' THEN 'Euro '                                                                                                                                                                                                                                                     
        WHEN E5_MOEDA = '05' THEN 'IENE '
        END E5_desMOEDA,
        E5.R_E_C_N_O_

        from %table:SE5% e5

        LEFT JOIN %table:SED% SED ON E5_NATUREZ = ED_CODIGO AND SED.%notdel%
        left join %table:sa2% a2 on e5_clifor=a2_cod and e5_loja=a2_loja and a2.%notdel%
        left join %table:sa1% a1 on e5_clifor=a1_cod and e5_loja=a1_loja and a1.%notdel%
        left join %table:ctt% ct1 on e5_filial=ct1.ctt_filial and e5_ccusto=ct1.ctt_custo and ct1.%notdel%
        left join %table:ctt% ct2 on e5_filial=ct2.ctt_filial and e5_xccusto=ct2.ctt_custo and ct2.%notdel%
        left join %table:ct1% ct11 on e5_filial=ct11.ct1_filial and e5_credito=ct11.ct1_conta and ct11.%notdel%
        left join %table:ct1% ct12 on e5_filial=ct12.ct1_filial and e5_debito=ct12.ct1_conta and ct12.%notdel%

        WHERE E5.%notdel% and E5_FILIAL between %exp:MV_PAR01% and %exp:MV_PAR02%
            AND E5_DATA between %exp:Dtos(MV_PAR03)% and %exp:DtoS(MV_PAR04)%

        ORDER BY E5_DATA

EndSql

_cQuery:=GetLastQuery()

_aStru:=DBSTRUCT()

DBGOTOP()

IF!Eof()

    HTMLMAIL()

    _nDemiss:=0
    _cEmissD    :=E5_DATA
    _cEmissA    :=E5_DATA
    _cEmissAn   :=E5_DATA

    Whil!Eof()

        If E5_DATA<>_cEmissA
            _nDemiss    ++
            _cEmissAn   :=_cEmissA
            _cEmissA    :=E5_DATA
        END

        IF _nDemiss==0 .Or. _nDemiss>_nNfdias

            If _nDemiss>_nNfdias

                _cNarquivo:=_cTabela+"_"+_cEmissD+"_"+_cEmissAn+".CSV"

                ENVFARQS(_cNarquivo)

                _cEmissD:=E5_DATA
                _cEmissA:=E5_DATA

            END

            _nHandle    :=FCREATE(_cArquivo)

            If _nHandle = -1
                conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
            END
            
            _nDemiss    :=1
        End

        For x:=1 To Len(_aStru)
    
            If _aStru[x,2]=="C"

                MONTACAMPO()

                //FWrite(_nHandle, &(_aStru[x,1])+';')
                FWrite(_nHandle, _cCampo)
            Else
                FWrite(_nHandle, Str(&(_aStru[x,1])))
                FWrite(_nHandle, ';')
            END
        NEXT

        FWrite(_nHandle, CRLF)

        DBSKIP()
    END

    _cNarquivo:=_cTabela+"_"+_cEmissD+"_"+_cEmissA+".CSV"

    ENVFARQS(_cNarquivo)

else
    GERLOG(_cTabela,_cOrig,"",0)
END

RETURN

/*/{Protheus.doc} ENVARQS
    (long_description)
    Envia o arquivo por email
    @type  Static Function
    @author user
    Edson Bella Gonçalves
    @since 08/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ENVARQS(_cNarquivo,_cHtml,_cSubject)

Private lOk //RETORNO A RECEBER DO ENVIO DE EMAIL

FClose(_nHandle)
    
FErase(_cNarquivo)

FRename(_cArquivo, _cNarquivo )

U_DrillEmail(_cCtaEmail,_cEmailRet,"","",_cSubject,_cHtml,.t.,_cNarquivo)

If lOk
    GERLOG(_cTabela,_cOrig,_cNarquivo,1)
else
    GERLOG(_cTabela,_cOrig,_cNarquivo,2)
End

Return


/*/{Protheus.doc} ENVFARQS
    (long_description)
    Envia o arquivo por ftp
    @type  Static Function
    @author user
    Edson Bella Gonçalves
    @since 16/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ENVFARQS(_cNarquivo)

Local cErrorMsg

Private lOk //RETORNO A RECEBER DO ENVIO DE EMAIL

FClose(_nHandle)
    
FErase(_cPasta+_cNarquivo)

FRename(_cArquivo, _cPasta+_cNarquivo )

//U_DrillEmail("erp@grupoelizabeth.com.br",_cEmailRet,"","",_cSubject,_cHtml,.t.,_cNarquivo)

//Private _cArquivo   :=  _cPasta+_cTabela

nStatus := SFTPUpld1(_cPasta+_cNarquivo, cDest+_cNarquivo, cServer1, cUser1, cPasswd1, @cErrorMsg)


//nStatus := SFTPUpld1(cDirFile+cArq, cDirDest+cArq, cFTPUrl, cFTPUser, cFTPPaswd ,@cError)
 
lOk:=nStatus==0

/*lOk := FTPCONNECT( cServer1 , nPorta ,cUser1, cPasswd1 )
alert(If(lOK,'1','2'))
If lOk
    lOk := FTPUPLOAD(_cNarquivo, cDest )
    FTPDISCONNECT()
EndIf
*/	
If lOk
    GERLOG(_cTabela,_cOrig,_cNarquivo,1)
else
    GERLOG(_cTabela,_cOrig,_cNarquivo,2)
End

Return

/*/{Protheus.doc} MONTACAMPO
    (long_description)
    Envia o arquivo por email
    @type  Static Function
    @author user
    Edson Bella Gonçalves
    @since 08/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function MONTACAMPO()

_cCampo :=StrTran(&(_aStru[x,1]),CHR(13)+CHR(10),' ')
_cCampo :=StrTran(_cCampo,CHR(10),' ')
_cCampo :=StrTran(_cCampo,CHR(13),' ')
_cCampo :=StrTran(_cCampo,";",' ')
_cCampo :=StrTran(_cCampo,"'",'')
_cCampo :=StrTran(_cCampo,'"','')
_cCampo +=";"

RETURN

/*/{Protheus.doc} GERLOG
    (long_description)
    @type  Static Function
    @author user
    Edson Bella
    @since 09/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
*/

Static Function GERLOG(_cTabela,_cOrig,_cArq,_nStatus)

/*
Status:
0 -> não tem dados para enviar
1 -> gerado e enviado com sucesso
2 -> gerado e erro ao enviar
*/

_cAlias:=Alias()

dbSelectArea("ZZ9")
Reclock("ZZ9",.t.)

ZZ9->ZZ9_TABELA :=  _cTabela
ZZ9->ZZ9_DATA   :=  DATE()
ZZ9->ZZ9_HRIN   :=  _cHrIn
ZZ9->ZZ9_HRFIM  :=  TIME()
ZZ9->ZZ9_ORIGEM :=  _cOrig
ZZ9->ZZ9_ARQGER :=  _cArq
ZZ9->ZZ9_STATUS :=  _nStatus

DBUNLOCK()

DBSELECTAREA( _CALIAS )

Return

/*/{Protheus.doc} HTMLMAIL
    (long_description)
    @type  Static Function
    @author user
    Edson Bella
    @since 09/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
*/

Static Function HTMLMAIL()

Local _cTitulo  :="Extração Protheus "+_cTabela

//Monta o corpo do e-Mail que será enviado
_cHTML:= ''
_cHTML+= '     <title>' + _cTitulo + '</title>' + CRLF
_cHTML+= ' </head>' + CRLF
_cHTML+= ' <body>' + CRLF
_cHTML+= '     <center><h1>' + _cTitulo + '</h1></center>' + CRLF
_cHTML+= '     Segue a carga de dados' + CRLF
_cHTML+= '     --<br>' + CRLF
_cHTML+= '     <font size="1">e-Mail gerado automaticamente pelo Protheus - '+ALLTRIM( ProcName() )+' - ' + dToC(Date()) + ' - ' + Time() + '</font><br>' + CRLF
_cHTML+= ' </body>' + CRLF
_cHTML+= ' </html>' + CRLF

RETURN

/*/{Protheus.doc} PARAMSX6
    (long_description)
    Atualização dos parâmetros SX6
    @type  Static Function
    @author user
    Edson Bella
    @since 27/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
*/

User Function PARAMSX6

Local oSButton1
Local oSButton2

Private cCEL_DWRGOF := GetMV('EL_DWRGOF')
Private cDEL_DWRGOF := X6Descric()
Private cCEL_DWRGPV := GetMV('EL_DWRGPV')
Private cDEL_DWRGPV := X6Descric()
Private cCEL_DWNPVD := GetMV('EL_DWNPVD')
Private cDEL_DWNPVD := X6Descric()
Private cCEL_DWMAIL := GetMV('EL_DWMAIL')
Private cDEL_DWMAIL := X6Descric()
Private cCEL_DWPASTA:= GetMV('EL_DWPASTA')
Private cDEL_DWPASTA:= X6Descric()
Private cCEL_DWNSDIA:= GetMV('EL_DWNSDIA')
Private cDEL_DWNSDIA:= X6Descric()
Private cCEL_DWRGSIT:= GetMV('EL_DWRGSIT')
Private cDEL_DWRGSIT:= X6Descric()
Private cCEL_DWCEMAI:= GetMV('EL_DWCEMAI')
Private cDEL_DWCEMAI:= X6Descric()
Private cCEL_DWSFTP := GetMV('EL_DWSFTP')
Private cDEL_DWSFTP := X6Descric()
Private cCEL_DWUSFTP:= GetMV('EL_DWUSFTP')
Private cDEL_DWUSFTP:= X6Descric()
Private cCEL_DWPSFTP:= GetMV('EL_DWPSFTP')
Private cDEL_DWPSFTP:= X6Descric()
Private cCEL_DWDEST := GetMV('EL_DWDEST')
Private cDEL_DWDEST := X6Descric()
Private cCEL_DWRGSSC:= GetMV('EL_DWRGSSC')
Private cDEL_DWRGSSC:= X6Descric()
Private cCEL_DWRGVEN:= GetMV('EL_DWRGVEN')
Private cDEL_DWRGVEN:= X6Descric()
Private cCEL_DWNEQD := GetMV('EL_DWNEQD')
Private cDEL_DWNEQD := X6Descric()
Private cCEL_DWNSQD := GetMV('EL_DWNSQD')
Private cDEL_DWNSQD := X6Descric()
Private cCEL_DWRGEPR:= GetMV('EL_DWRGEPR')
Private cDEL_DWRGEPR:= X6Descric()
Private cCEL_DWRGOBR:= GetMV('EL_DWRGOBR')
Private cDEL_DWRGOBR:= X6Descric()
Private cCEL_DWNEDIA:= GetMV('EL_DWNEDIA')
Private cDEL_DWNEDIA:= X6Descric()
Private cCEL_DWCGDIA:= GetMV('EL_DWCGDIA')
Private cDEL_DWCGDIA:= X6Descric()
Private cCEL_DWCGQD := GetMV('EL_DWCGQD')
Private cDEL_DWCGQD:= X6Descric()
Private cCEL_DWCPDIA:= GetMV('EL_DWCPDIA')
Private cDEL_DWCPDIA:= X6Descric()
Private cCEL_DWCPQD := GetMV('EL_DWCPQD')
Private cDEL_DWCPQD := X6Descric()
Private cCEL_DWPCDIA:= GetMV('EL_DWPCDIA')
Private cDEL_DWPCDIA:= X6Descric()
Private cCEL_DWPCQD := GetMV('EL_DWPCQD')
Private cDEL_DWPCQD := X6Descric()
Private cCEL_DWCRDIA:= GetMV('EL_DWCRDIA')
Private cDEL_DWCRDIA:= X6Descric()
Private cCEL_DWCRQD := GetMV('EL_DWCRQD')
Private cDEL_DWCRQD := X6Descric()
Private cCEL_DWCPQD := GetMV('EL_DWCPQD')
Private cDEL_DWCPQD := X6Descric()
Private cCEL_DWMBDIA:= GetMV('EL_DWMBDIA')
Private cDEL_DWMBDIA:= X6Descric()
Private cCEL_DWMBQD := GetMV('EL_DWMBQD')
Private cDEL_DWMBQD := X6Descric()

//Local bOk := {|| }
//Local bCancel:= {|| }
/*
Local oSay1, oSay2, oSay3, oSay4, oSay5, oSay6, oSay7, oSay8, oSay9, oSay10, oSay11, oSay12, oSay13, oSay14, oSay15,;
    oSay16, oSay17, oSay18, oSay19, oSay20 
Local oGet1, oSay2, oGet3, oGet4, oGet5, oGet6, oGet7, oGet8, oGet9, oGet10, oGet11, oGet12, oGet13, oGet14, oGe1t5,;
    oGet16, oGet17, oGet18, oGet19, oGet20 
*/
Static oDlg

  DEFINE MSDIALOG oDlg TITLE "Parâmetros SX6" FROM 000, 000  TO 400, 1100 COLORS 0, 16777215 PIXEL

    @ 016, 011 SAY oSay1 PROMPT "EL_DWRGOF" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 016, 050 SAY oSay2 PROMPT ' - '+cDEL_DWRGOF SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 014, 215 MSGET oGet1 VAR cCEL_DWRGOF SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 016, 281 SAY oSay3 PROMPT "EL_DWRGPV" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 016, 320 SAY oSay4 PROMPT ' - '+cDEL_DWRGPV SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 014, 485 MSGET oGet2 VAR cCEL_DWRGPV SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 027, 011 SAY oSay5 PROMPT "EL_DWNPVD" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 027, 050 SAY oSay6 PROMPT ' - '+cDEL_DWNPVD SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 025, 215 MSGET oGet3 VAR cCEL_DWNPVD SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 027, 281 SAY oSay7 PROMPT "EL_DWMAIL" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 027, 320 SAY oSay8 PROMPT ' - '+cDEL_DWMAIL SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 025, 485 MSGET oGet4 VAR cCEL_DWMAIL SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 038, 011 SAY oSay9 PROMPT "EL_DWPASTA" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 038, 050 SAY oSay10 PROMPT ' - '+cDEL_DWPASTA SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 036, 215 MSGET oGet5 VAR cCEL_DWPASTA SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 038, 281 SAY oSay11 PROMPT "EL_DWNSDIA" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 038, 320 SAY oSay12 PROMPT ' - '+cDEL_DWNSDIA SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 036, 485 MSGET oGet6 VAR cCEL_DWNSDIA SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 049, 011 SAY oSay13 PROMPT "EL_DWRGSIT" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 049, 050 SAY oSay14 PROMPT ' - '+cDEL_DWRGSIT SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 047, 215 MSGET oGet7 VAR cCEL_DWRGSIT SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 049, 281 SAY oSay15 PROMPT "EL_DWCEMAI" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 049, 320 SAY oSay16 PROMPT ' - '+cDEL_DWCEMAI SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 047, 485 MSGET oGet8 VAR cCEL_DWCEMAI SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 060, 011 SAY oSay17 PROMPT "EL_DWSFTP" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 060, 050 SAY oSay18 PROMPT ' - '+cDEL_DWSFTP SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 058, 215 MSGET oGet9 VAR cCEL_DWSFTP SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 060, 281 SAY oSay19 PROMPT "EL_DWUSFTP" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 060, 320 SAY oSay20 PROMPT ' - '+cDEL_DWUSFTP SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 058, 485 MSGET oGet10 VAR cCEL_DWUSFTP SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 071, 011 SAY oSay21 PROMPT "EL_DWPSFTP" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 071, 050 SAY oSay22 PROMPT ' - '+cDEL_DWPSFTP SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 069, 215 MSGET oGet11 VAR cCEL_DWPSFTP SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 071, 281 SAY oSay23 PROMPT "EL_DWDEST" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 071, 320 SAY oSay24 PROMPT ' - '+cDEL_DWDEST SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 069, 485 MSGET oGet12 VAR cCEL_DWDEST SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 082, 011 SAY oSay25 PROMPT "EL_DWRGSSC" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 082, 050 SAY oSay26 PROMPT ' - '+cDEL_DWRGSSC SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 080, 215 MSGET oGet13 VAR cCEL_DWRGSSC SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 082, 281 SAY oSay27 PROMPT "EL_DWNEQD" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 082, 320 SAY oSay28 PROMPT ' - '+cDEL_DWNEQD SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 080, 485 MSGET oGet14 VAR cCEL_DWNEQD SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 093, 011 SAY oSay29 PROMPT "EL_DWNSQD" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 093, 050 SAY oSay30 PROMPT ' - '+cDEL_DWNSQD SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 091, 215 MSGET oGet15 VAR cCEL_DWNSQD SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 093, 281 SAY oSay31 PROMPT "EL_DWRGEPR" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 093, 320 SAY oSay32 PROMPT ' - '+cDEL_DWRGEPR SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 091, 485 MSGET oGet16 VAR cCEL_DWRGEPR SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 104, 011 SAY oSay33 PROMPT "EL_DWRGOBR" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 104, 050 SAY oSay34 PROMPT ' - '+cDEL_DWRGOBR SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 102, 215 MSGET oGet17 VAR cCEL_DWRGOBR SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 104, 281 SAY oSay35 PROMPT "EL_DWNEDIA" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 104, 320 SAY oSay36 PROMPT ' - '+cDEL_DWNEDIA SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 102, 485 MSGET oGet18 VAR cCEL_DWNEDIA SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 115, 011 SAY oSay37 PROMPT "EL_DWRGVEN" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 115, 050 SAY oSay38 PROMPT ' - '+cDEL_DWRGVEN SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 113, 215 MSGET oGet19 VAR cCEL_DWRGVEN SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 115, 281 SAY oSay39 PROMPT "EL_DWCGDIA" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 115, 320 SAY oSay40 PROMPT ' - '+cDEL_DWCGDIA SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 113, 485 MSGET oGet20 VAR cCEL_DWCGDIA SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 126, 011 SAY oSay39 PROMPT "EL_DWCGQD" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 126, 050 SAY oSay40 PROMPT ' - '+cDEL_DWCGQD SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 124, 215 MSGET oGet21 VAR cCEL_DWCGQD SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 126, 281 SAY oSay41 PROMPT "EL_DWCPDIA" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 126, 320 SAY oSay42 PROMPT ' - '+cDEL_DWCPDIA SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 124, 485 MSGET oGet22 VAR cCEL_DWCPDIA SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 137, 011 SAY oSay41 PROMPT "EL_DWCPQD" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 137, 050 SAY oSay42 PROMPT ' - '+cDEL_DWCPQD SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 136, 215 MSGET oGet23 VAR cCEL_DWCPQD SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 137, 281 SAY oSay41 PROMPT "EL_DWPCDIA" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 137, 320 SAY oSay42 PROMPT ' - '+cDEL_DWPCDIA SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 136, 485 MSGET oGet24 VAR cCEL_DWPCDIA SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 148, 011 SAY oSay41 PROMPT "EL_DWPCQD" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 148, 050 SAY oSay42 PROMPT ' - '+cDEL_DWPCQD SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 147, 215 MSGET oGet25 VAR cCEL_DWPCQD SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 148, 281 SAY oSay41 PROMPT "EL_DWCRDIA" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 148, 320 SAY oSay42 PROMPT ' - '+cDEL_DWCRDIA SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 148, 485 MSGET oGet26 VAR cCEL_DWCRDIA SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 159, 011 SAY oSay41 PROMPT "EL_DWCRQD" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 159, 050 SAY oSay42 PROMPT ' - '+cDEL_DWCRQD SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 158, 215 MSGET oGet27 VAR cCEL_DWCRQD SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 159, 281 SAY oSay43 PROMPT "EL_DWMBDIA" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 159, 320 SAY oSay44 PROMPT ' - '+cDEL_DWMBDIA SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 158, 485 MSGET oGet28 VAR cCEL_DWMBDIA SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    @ 170, 011 SAY oSay45 PROMPT "EL_DWMBQD" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 170, 050 SAY oSay46 PROMPT ' - '+cDEL_DWMBQD SIZE 155, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 170, 215 MSGET oGet29 VAR cCEL_DWMBQD SIZE 045, 010 OF oDlg PICTURE "999999999" COLORS 0, 16777215 PIXEL

    DEFINE SBUTTON oSButton1 FROM 180, 240 TYPE 01 OF oDlg ENABLE ACTION ATUSX6()
    DEFINE SBUTTON oSButton2 FROM 180, 270 TYPE 02 OF oDlg ENABLE ACTION (oDlg:End())

    //@ 003, 124 SPLITTER oSplitte1 SIZE 001, 248 OF oDlg ORIENTATION 1

  //ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOk , bCancel) CENTERED
    ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} ATUSX6
    (long_description)
    Atualiza o SX6
    @type  Static Function
    @author user
    Edson Bella
    @since 02/03/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ATUSX6()

PUTMV('EL_DWRGOF ',cCEL_DWRGOF )
PUTMV('EL_DWRGPV ',cCEL_DWRGPV )
PUTMV('EL_DWNPVD ',cCEL_DWNPVD )
PUTMV('EL_DWMAIL ',cCEL_DWMAIL )
PUTMV('EL_DWPASTA',cCEL_DWPASTA)
PUTMV('EL_DWNSDIA',cCEL_DWNSDIA)
PUTMV('EL_DWRGSIT',cCEL_DWRGSIT)
PUTMV('EL_DWCEMAI',cCEL_DWCEMAI)
PUTMV('EL_DWSFTP ',cCEL_DWSFTP )
PUTMV('EL_DWUSFTP',cCEL_DWUSFTP)
PUTMV('EL_DWPSFTP',cCEL_DWPSFTP)
PUTMV('EL_DWDEST ',cCEL_DWDEST )
PUTMV('EL_DWRGSSC',cCEL_DWRGSSC)
PUTMV('EL_DWRGVEN',cCEL_DWRGVEN)
PUTMV('EL_DWNEQD ',cCEL_DWNEQD )
PUTMV('EL_DWNSQD ',cCEL_DWNSQD )
PUTMV('EL_DWRGEPR',cCEL_DWRGEPR)
PUTMV('EL_DWRGOBR',cCEL_DWRGOBR)
PUTMV('EL_DWNEDIA',cCEL_DWNEDIA)
PUTMV('EL_DWCGDIA',cCEL_DWCGDIA)
PUTMV('EL_DWCGQD' ,cCEL_DWCGQD)
PUTMV('EL_DWCPDIA',cCEL_DWCPDIA)
PUTMV('EL_DWCPQD ',cCEL_DWCPQD)
PUTMV('EL_DWPCDIA',cCEL_DWPCDIA)
PUTMV('EL_DWPCQD ',cCEL_DWPCQD)
PUTMV('EL_DWCRDIA',cCEL_DWCRDIA)
PUTMV('EL_DWCRQD',cCEL_DWCRQD)
PUTMV('EL_DWMBDIA',cCEL_DWMBDIA)
PUTMV('EL_DWMBQD' ,cCEL_DWMBQD)

oDlg:End()

Return

/*/{Protheus.doc} AtuConou
    Mensagem Conout
    @type  Static Function
    @author user
    Edson Bella - MRC
    @since 22/03/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function AtuConou(_cTipo)

_cTstConout:=If(_cTipo=='1', 'Início DW',;
            If(_cTipo=='2', 'Não confirmado início DW - '+_cTabela,;
            If(_cTipo=='3', 'Início processamento DW - '+_cTabela,;
            If(_cTipo=='4', 'Fim processamento DW - '+_cTabela,''))))

Conout(_cTstConout)

Return

/*User Functions para chamadas em JOB
DWNFS() - Nota Fiscal de Saída
DWCLI() - Clientes
DWITE() - Produtos
DWCOM() - Sol.Compras
DWOBR() - Obras
DWAGE() - Vendedores
DWNFE() - Nota Fiscal de Entrada
DWEST() - Estrutura de Produtos
DWOFP() - Ordem de Produção
DWPVE() - Pedidos de Vendas
DWCAR() - Cargas
DWPAG() - Titulos a Pagar
DWPCO() - Pedidos de Compras
DWREC() - Contas a Receber
DWFOR() - Fornecedores
DWMVB() - Movimentação Bancária
*/
User Function DWNFS()

U_PROCDW('N','1')

RETURN

//--------------------------------
User Function DWCLI()

U_PROCDW('N','2')

RETURN

//--------------------------------
User Function DWITE()

U_PROCDW('N','3')

RETURN

//--------------------------------
User Function DWCOM()

U_PROCDW('N','4')

RETURN

//--------------------------------
User Function DWOBR()

U_PROCDW('N','5')

RETURN

//--------------------------------
User Function DWAGE()

U_PROCDW('N','6')

RETURN

//--------------------------------
User Function DWNFE()

U_PROCDW('N','7')

RETURN

//--------------------------------
User Function DWEST()

U_PROCDW('N','8')

RETURN

//--------------------------------
User Function DWOFP()

U_PROCDW('N','9')

RETURN

//--------------------------------
User Function DWPVE()

U_PROCDW('N','10')

RETURN

//--------------------------------
User Function DWCAR()

U_PROCDW('N','11')

RETURN

//--------------------------------
User Function DWPAG()

U_PROCDW('N','12')

RETURN

//--------------------------------
User Function DWPCO()

U_PROCDW('N','13')

RETURN

//--------------------------------
User Function DWREC()

U_PROCDW('N','14')

RETURN

//--------------------------------
User Function DWFOR()

U_PROCDW('N','15')

RETURN

//--------------------------------
User Function DWMVB()

U_PROCDW('N','16')

RETURN
