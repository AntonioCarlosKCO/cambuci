#INCLUDE 'totvs.ch'
/*
@DOC
Funcao: U_CTMK001
Titulo: //Tela apresentação da CONSULTA REFERENCIAS
Parametros:
1 - caracter -> codigo do produto
2 - caracter -> opção para apresentar o botão de confirmação
3 - caracter -> codigo do cliente
4 - caracter -> codigo da loja
5 - caracter -> tipo de operação fiscal (tes inteligente)
Retorno: Logico
@DOC
*/
Function U_CTMK001(cProd,cOpc,cCli,cLoj,cOper)

	Local aCoors  := FWGetDialogSize( oMainWnd )

	//mark 1  - referencias
	Local lInverte_1 	:= .F.
	Local aCampos_1 	:= {}
	Local aColors_1 	:= {}

	Default cOpc  := "A"
	Default cCli  := M->UA_CLIENTE
	Default cLoj  := M->UA_LOJA
	Default cOper := IIF(Inclui,M->UA_XTPOPER, SUA->UA_XTPOPER)

	Private cMark_1 	:= GetMark()
	Private cProduto 	:= AllTrim(cProd)
	Private cOpcao   	:= cOpc
	Private cCliente 	:= cCli
	Private cLoja    	:= cLoj
	Private cOperacao	:= cOper
	Private oMark_1 	:= GetMarkBrow()
	Private lCancela	:= .F.

	Private oDlg, oButton1, oButton2, oButton3, oButton4, oGet1, oSay1, oMark_1, oMsNGD_2, oMsNGD_3
	Private cTrb1  := GetNextAlias()

	//definicao dos campos no marbrow_1
	AADD( aCampos_1 ,{"OK"          ,""," "         ," "})
	AADD( aCampos_1 ,{"REFERENCIA"  ,"","Referencia",PesqPict("SUB","UB_XCODREF")})
	AADD( aCampos_1 ,{"PRECO"       ,"","Preco"     ,PesqPict("SUB","UB_VRUNIT")})
	AADD( aCampos_1 ,{"DESCRICAO"   ,"","Descricao" ,"@S50"})
	AADD( aCampos_1 ,{"MARCA"       ,"","Marca"     ,PesqPict("SB1","B1_XMARCA")})
	AADD( aCampos_1 ,{"APLICACAO"   ,"","Aplicacao" ,"@S50"})
	AADD( aCampos_1 ,{"FILIAL"      ,"","Filial"    ,PesqPict("SUB","UB_FILIAL")})
	AADD( aCampos_1 ,{"PRODUTO"     ,"","Produto"   ,PesqPict("SUB","UB_PRODUTO")})

	//dados dos caracteres da referencia digitada
	MsgRun("Pesquisando dados da referencia...",, {|| fReferencias(cProduto) })

	cMark_1 := GetMark()

	Define MsDialog oDlg Title "Consulta Referencias" From aCoors[1]-100, aCoors[2]-100 To aCoors[3]-200, aCoors[4]-200 COLORS 0, 16777215 Pixel

	//MsSelect(): New ( <cAlias>,[cCampo],[cCpo],[aCampos],[lInv],[cMar],<aCord>,[cTopFun],[cBotFun],<oWnd>,[uPar11],[aColors] )
	oMark_1 := MsSelect():New(cTrb1,"OK","",aCampos_1,@lInverte_1,@cMark_1,{005, 011, 170, 610},,,oDlg,,aColors_1)
	oMark_1:bMark := {|| fMarca(cMark_1)}
	oMark_1:oBrowse:bChange  := {|| fSaldos()}

	@ 210, 540 BUTTON oButton3 PROMPT "&Impostos"  SIZE 030, 010 OF oDlg ACTION { || fImpostos() } PIXEL
	@ 210, 580 BUTTON oButton4 PROMPT "&Mark"  SIZE 030, 010 OF oDlg ACTION { || U_MarkAll(cMark_1) } PIXEL

	If cOpcao = 'A'
		@ 230, 540 BUTTON oButton1 PROMPT "C&onfirmar" SIZE 030, 010 OF oDlg ACTION { || fExportOrca(), oDlg:End() } PIXEL
	EndIf
	@ 230, 580 BUTTON oButton2 PROMPT "&Cancelar"  SIZE 030, 010 OF oDlg ACTION { || lCancela := .T., oDlg:End() } PIXEL

	/*
	DEFINE SBUTTON oButton3 FROM 210, 560 TYPE 14 OF oDlg ENABLE ACTION { || fImpostos() } //detalhe dos impostos
	If nOpc = 'A'
	DEFINE SBUTTON oButton1 FROM 230, 560 TYPE 01 OF oDlg ENABLE ACTION { || fExportOrca(), oDlg:End() } //gravar dados marcados no orçamento
	EndIf
	DEFINE SBUTTON oButton2 FROM 230, 590 TYPE 02 OF oDlg ENABLE ACTION { || oDlg:End() } //cancelar
	*/

	ACTIVATE MSDIALOG oDlg CENTERED
    
	If lCancela
		Cancela()
	EndIf
	(cTrb1)->(DbCloseArea())

Return .T.


//marcar o item do grid
//------------------------------------------------
Static Function fMarca(cMrk)
	//------------------------------------------------

	RecLock(cTrb1,.F.)
	If Marked("OK")
		(cTrb1)->OK := cMrk
	Else
		(cTrb1)->OK := ""
	Endif
	(cTrb1)->(MSUNLOCK())
	oMark_1:oBrowse:Refresh()

Return Nil


//dados do grid de referencias
//------------------------------------------------
Static Function fReferencias(cProduto)
	//------------------------------------------------
	Local cQrySB1  := GetNextAlias()
	Local cQryZZA  := GetNextAlias()
	Local cWhrProd
	Local cWhrRef
	Local cArq
	Local aStru := {}

	//criar arquivo de trabalho
	aStru := {}
	AADD(aStru,{"OK"        ,"C",2,0})
	AADD(aStru,{"REFERENCIA",TamSX3("UB_XCODREF")[3],TamSX3("UB_XCODREF")[1],TamSX3("UB_XCODREF")[2]})
	AADD(aStru,{"DESCRICAO" ,TamSX3("B1_DESC")[3]   ,TamSX3("B1_DESC")[1]   ,TamSX3("B1_DESC")[2]})
	AADD(aStru,{"APLICACAO" ,TamSX3("B1_XAPLICA")[3],TamSX3("B1_XAPLICA")[1],TamSX3("B1_XAPLICA")[2]})
	AADD(aStru,{"MARCA"     ,TamSX3("B1_XMARCA")[3] ,TamSX3("B1_XMARCA")[1] ,TamSX3("B1_XMARCA")[2]})
	AADD(aStru,{"PRODUTO"   ,TamSX3("UB_PRODUTO")[3],TamSX3("UB_PRODUTO")[1],TamSX3("UB_PRODUTO")[2]})
	AADD(aStru,{"FILIAL"    ,TamSX3("UB_FILIAL")[3] ,TamSX3("UB_FILIAL")[1] ,TamSX3("UB_FILIAL")[2]})
	AADD(aStru,{"PRECO"     ,TamSX3("UB_VRUNIT")[3] ,TamSX3("UB_VRUNIT")[1] ,TamSX3("UB_VRUNIT")[2]})
	AADD(aStru,{"QTDMIN"    ,TamSX3("UB_QUANT")[3]  ,TamSX3("UB_QUANT")[1] ,TamSX3("UB_QUANT")[2]})

	cArq := CriaTrab(aStru,.T.)
	DbUseArea(.T.,,cArq,cTrb1,.F.,.F.)
	IndRegua(cTrb1,CriaTrab(NIL,.F.),"REFERENCIA",,,"Indice Temporario...")

	cWhrProd := "%"
	cWhrProd += " B1_TIPO = 'ME' AND B1_COD LIKE '"+cProduto+"%' "
	cWhrProd += "%"

	cWhrRef := "%"
	cWhrRef += " ZZA_XCODRF LIKE '"+cProduto+"%' "
	cWhrREf += "%"

	//FWTemporaryTable():New( [<cAlias>], [<aFields>] )

	//QUERY DOS DADOS
	BeginSql Alias cQrySB1

	SELECT
	B1_COD REFERENCIA,
	B1_DESC DESCRICAO,
	B1_XAPLICA APLICACAO,
	B1_XMARCA MARCA,
	B1_COD PRODUTO,
	B1_QE QTDMIN
	FROM
	%table:SB1% SB1
	WHERE
	SB1.B1_FILIAL = %xFilial:SB1%
	AND SB1.%NotDel%
	AND %Exp:cWhrProd%
	ORDER BY B1_COD

	EndSql

	//gravar a query para analise dos dados
	//aQuery := GetLastQuery()
	//cQry := aQuery[2]
	//makedir("C:\TEMP\QRYEXEC\")
	//MemoWrite( "C:\TEMP\QRYEXEC\" + AllTrim(FunName()) + DTOS(Date()) + StrTran(Time(),":","") + "_1.sql" , cQry )

	fGravaTrb(cQrySB1)
	
	BeginSql Alias cQryZZA

	SELECT
	ZZA_XCODRF REFERENCIA,
	B1_DESC DESCRICAO,
	ZZA_XAPLIC APLICACAO,
	B1_XMARCA MARCA,
	ZZA_XCOD PRODUTO,
	B1_QE QTDMIN
	FROM
	%table:ZZA% ZZA
	INNER JOIN
	%table:SB1% SB1
	ON
	B1_FILIAL = %xFilial:SB1%
	AND SB1.%NotDel%
	AND ZZA.ZZA_XCOD = SB1.B1_COD
	AND B1_TIPO = 'ME'
	WHERE
	ZZA.ZZA_FILIAL = %xFilial:ZZA%
	AND ZZA.%NotDel%
	AND %Exp:cWhrRef%
	ORDER BY ZZA_XCODRF

	EndSql

	//gravar a query para analise dos dados
	//aQuery := GetLastQuery()
	//cQry := aQuery[2]
	//makedir("C:\TEMP\QRYEXEC\")
	//MemoWrite( "C:\TEMP\QRYEXEC\" + AllTrim(FunName()) + DTOS(Date()) + StrTran(Time(),":","") + "_2.sql" , cQry )

	fGravaTrb(cQryZZA)
	
Return Nil


//preenchimento dos dados arquivo de tabalho
//------------------------------------------------
Static Function fGravaTrb(cQry)
	//------------------------------------------------
	Local nPreco := 0
	Local nQuant := 0
	Local aSld := {}
	Local nx := 0
	Local cArmazem := SuperGetMV("ES_ARMAZEM",.F.,'01/02')

	(cQry)->(DbGotop())
	While (cQry)->(!EOF())

		If  ! (cTrb1)->(DbSeek((cQry)->REFERENCIA))

			nPreco := U_XTMKPreco(XFilial('SUB'),(cQry)->PRODUTO,cCliente,cLoja)

			RecLock(cTrb1,.T.)
			(cTrb1)->REFERENCIA   := (cQry)->REFERENCIA
			(cTrb1)->DESCRICAO    := (cQry)->DESCRICAO
			(cTrb1)->APLICACAO    := (cQry)->APLICACAO
			(cTrb1)->MARCA        := (cQry)->MARCA
			(cTrb1)->PRODUTO      := (cQry)->PRODUTO
			(cTrb1)->FILIAL       := XFilial('SUB')
			(cTrb1)->PRECO        := nPreco
			(cTrb1)->QTDMIN       := (cQry)->QTDMIN

			(cTrb1)->(MsUnLock())
		EndIf

		(cQry)->(DbSkip())

	EndDo

	(cTrb1)->(DbGoTop())

	(cQry)->(DbCloseArea())

Return Nil


//dados dos saldos por filial
//------------------------------------------------
Static Function fSaldos()
	//------------------------------------------------
	Local nX := 0
	//SUPERGETMV( <nome do parâmetro>, <lHelp>, <cPadrão>, <Filial do sistema> )
	Local cArmazem := SuperGetMV("ES_ARMAZEM",.F.,'01/02')

	Local aFields := {"UB_XNFILIA","B2_QATU","B2_FILIAL","UB_PRODUTO"}
	Local aAlterFields := {}
	Local aAreaSX3 := SX3->(GetArea())
	Local nTamX3   := ""

	Private aHeader_2	:= {}
	Private aCols_2 	:= {}

	// Define field properties
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
		
			
			Aadd(aHeader_2, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	aSaldos := U_XTMKSldFiliais((cTrb1)->PRODUTO,cArmazem) //-> Filial, nome da filial, quant atual, quant disponivel

	For nx := 1 To Len(aSaldos)
		AAdd(aCols_2,{aSaldos[nx,2],aSaldos[nx,4],aSaldos[nx,1],(cTrb1)->PRODUTO,.F.})
	Next nx
	//{200, 011, 250, 250}

	oMsNGD_2 := MsNewGetDados():New( 170, 011, 250, 250, /*GD_INSERT+GD_DELETE+GD_UPDATE*/, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeader_2, aCols_2)
	oMsNGD_2:Refresh()

	RestArea(aAreaSX3)
Return

//preços e impostos por filial
//------------------------------------------------
Static Function fImpostos()
	//------------------------------------------------
	Local aFields := {"UB_XNFILIA","UB_VRUNIT","UB_XVLRIPI","UB_XVLRST","UB_FILIAL","UB_PRODUTO"}
	Local aAlterFields := {}
	Local aHeader_3 := {}
	Local aCols_3 := {}
	Local nPrc := nVlIpi := nVlSt := 0
	Local nX := 0
	Local aAreaSM0 	:= SM0->(GetArea())
	Local aAreaSX3 	:= SX3->(GetArea())
	Local _cEmpant	:= cEmpAnt
	Local _cFilAnt	:= cFilAnt
	Local nPosFil, nPosPrc := 0
	//Local _cTES		:= MaTesInt(2,"01",cCliente,cLoja,"C",(cTrb1)->PRODUTO,)                                    

	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeader_3, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	// Salvo os arrays da função fiscal do atendimento - CES 22/09/2016
	_nMaFisSv	:= MaFisSave()

	DbSelectArea("SB1")
	DbSetOrder(1)

	SM0->(DbSetOrder(1))
	SM0->(DbSeek(CEMPANT))
	While SM0->(!EOF()) .And. SM0->M0_CODIGO = CEMPANT

		If !(AllTrim(SM0->M0_CODFIL) $ (GetMv("SY_SELFIL",,"0202;0799;0899;0999")))

			//Troco as variáveis de empresa/filial do sistema
			cEmpAnt	:= SM0->M0_CODIGO
			cFilAnt	:= SM0->M0_CODFIL

			//Finaliza Funcao fiscal	- CES 22/09/2016
			//MaFisEnd()
			/*
			COMENTADO POR DJALMA BORGES 18/02/2017
			NÃO HÁ MAFISINI() PARA ESTE MAFISEND()
			TENTATIVA DE CORRIGIR ERRORLOG ESPORÁDICO DO PADRÃO NO CALL CENTER
			variable is not array - Type [U] on MAFISRET(MATXFIS.PRX)
			*/

			//Inicia Funcao Fiscal - CES 22/09/2016
			MaFisIni(	cCliente			,;	// 01 - Codigo Cliente
			cLoja				,;	// 02 - Loja do Cliente
			"C"					,;	// 03 - C:Cliente , F:Fornecedor
			"N"					,;	// 04 - Tipo da NF
			SA1->A1_TIPO		,;	// 05 - Tipo do Cliente
			Nil					,;	// 06 - Relacao de Impostos que suportados no arquivo
			Nil					,;	// 07 - Tipo de complemento
			Nil					,;	// 08 - Permite Incluir Impostos no Rodape .T./.F.
			"SB1"				)	// 09 - Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)

			nPrc   := U_XTMKPreco(SM0->M0_CODFIL,(cTrb1)->PRODUTO,cCliente,cLoja)

			SB1->(DbSeek(xFilial("SB1")+(cTrb1)->PRODUTO))

			If !Empty(M->UA_XTPOPER)
				cTes	:= MaTesInt( 2, M->UA_XTPOPER , cCliente , cLoja  , "C" , (cTrb1)->PRODUTO )
			ELse
				cTes	:= ""
			EndIf

			MaFisAdd( (cTrb1)->PRODUTO, cTes, 1, nPrc, 0, "", "",, 0, 0, 0, 0, Round(nPrc,2), 0, SB1->(RecNo()))

			nVlIpi 	:= MaFisRet(1,"IT_VALIPI") 
			nVlSt  	:= MaFisRet(1,"IT_VALSOL") 


			//preenchimento de dados
			AAdd(aCols_3,{SM0->M0_FILIAL,nPrc,nVlIpi,nVlSt,SM0->M0_CODFIL,(cTrb1)->PRODUTO,.F.})

			// Limpa todos os itens e zera todos totalizadores
			// do cabeçalho dos arrays internos da MATXFIS
			MaFisClear()
			MaFisEnd()

		EndIf

		SM0->(Dbskip())

	EndDo

	nPosFil	:= aScan(aHeader_3,{|x| Upper(Alltrim(x[2])) == "UB_FILIAL"})
	nPosPrc	:= aScan(aHeader_3,{|x| Upper(Alltrim(x[2])) == "UB_VRUNIT"})

	//{200, 280, 250, 550}
	oMsNGD_3 := MsNewGetDados():New( 170, 260, 250, 530, /*GD_INSERT+GD_DELETE+GD_UPDATE*/, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeader_3, aCols_3)
	oMsNGD_3:Refresh()
	oMsNGD_3:oBrowse:BlDblClick := {|| fAtuFilial(aCols_3[oMsNGD_3:oBrowse:nAT,nPosFil],aCols_3[oMsNGD_3:oBrowse:nAT,nPosPrc])} //->FILIAL;PRECO
	//oMsNGD_3:oBrowse:BlDblClick := {|| fAtuFilial(aCols_3)} //->FILIAL;PRECO

	// Restauro a Função Fiscal do Atendimento - CES 22/09/2016
	MaFisRestore(_nMaFisSv)

	// Restauro a variável com a Filial corrente - CES 22/09/2016
	cFilant := _cFilAnt
	cEmpAnt := _cEmpAnt

	RestArea(aAreaSM0)
	RestArea(aAreaSX3)
Return

//preenchimento do orcamento
//------------------------------------------------
Static Function fExportOrca()
	//------------------------------------------------
	Local aClean		:= {}
	Local aSaldos		:= {}
	Local nSaldo		:= 0
	Local cArmazem := SuperGetMV("ES_ARMAZEM",.F.,'01/02')
	Local _nY

	(cTrb1)->(DbGotop())
	While (cTrb1)->(!EOF())

		// Inicio <------------------------------------------------------------------------------------------------------
		aSaldos := U_XTMKSldFiliais((cTrb1)->PRODUTO,cArmazem) //-> Filial, nome da filial, quant atual, quant disponivel

		For _nY := 1 to Len(aSaldos)
			If aSaldos[_nY][3] > 0
				nSaldo += aSaldos[_nY][3]
			Endif
		Next _nY
		// Fim <---------------------------------------------------------------------------------------------------------

		If !Empty((cTrb1)->OK) 
			If nSaldo > 0
				AAdd(aClean,{(cTrb1)->PRODUTO,(cTrb1)->REFERENCIA,(cTrb1)->FILIAL,(cTrb1)->QTDMIN,(cTrb1)->PRECO}) //(cTrb1)->FILIAL
			Else
				Aviso("CMTK001 - Produto sem Saldo ","O Produto " + (cTrb1)->PRODUTO + " Não possui Saldo em Estoque. Esse produto não será incluído no atendimento",{"OK"},2)
			Endif
		EndIf
		(cTrb1)->(DbSkip())
		aSaldos 	:= {}
		nSaldo		:= 0
	EndDo

	fItens(aClean)

Return

//preenchimento do ACOLS orcamento
//------------------------------------------------
Static Function fItens(aClean)
	//------------------------------------------------

	Local aColsAux	:= {}
	Local nPosItem	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "UB_ITEM"})
	Local nPosProd	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "UB_PRODUTO"})
	Local nPosQuant	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "UB_QUANT"})
	Local nPosVrUni	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "UB_VRUNIT"})
	Local nPosVlrIt 	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "UB_VLRITEM"})
	Local nPosOper	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "UB_OPER"})
	Local nPosRef		:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "UB_XCODREF"})
	Local nPosFil		:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "UB_XFILREF"})
	Local nPosD		:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "UB_DESCRI"})
	Local nPosTES		:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "UB_TES"})
	Local ni := nx 	:= 0
	Local _y

	&&Bkp do aCols
	aColsAux:= aClone(aCols)

	For nX:=1 To Len(aClean)

		// Inserido por Carlos Eduardo Saturnino - Id 16 do Cronograma de desenvolvimentos ------------------------------------------------------------------> Inicio
		For _y := 1 To Len(aCols) 
			// Se a linha não estiver deletada e se ja houver sido digitado o produto no Atendimento 
			If aCols[_y][Len(aCols[_y])] == .F. .And. aCols[_y][nPosProd] == aClean[nX,1] 
				Aviso("CMTK001 - Produto Duplicado ","Ja existe esse produto digitado no item " + aCols[aScan(aCols,{|x| x[nPosProd] == aClean[nX,1]})][nPosItem] + " do atendimento aberto",{"OK"},2)
			Endif
		Next _y
		// Fim <-----------------------------------------------------------------------------------------------------------------------------------------------------


		// Caso não tenha Grupo Tributário cadastrado para o Produto, não 
		// preenche o aCols - Carlos Eduardo Saturnino 05/10/2016
		If U_XTMKGrTr(aClean[nX,1], cCliente, cLoja)

			//-------------------------------------------------------------
			// Andre Lanzieri 01/07/2016
			// Verifica Ultima Linha,se estiver preenchida, adiciona linha.
			// Obs: AddLine está com bug.
			//-------------------------------------------------------------
			If Len( aCols ) == 1 .And. Empty( aCols[ 1 ][ nPosProd ] )
				cItemNew	:= StrZero( 1, TamSx3("UB_ITEM")[1] )
			Else
				If !Empty( aCols[ Len(aCols) ][ nPosProd ] )

					Aadd( aCols, Array( Len(aHeader)+1 ) )
					cItemNew	:= SOMA1(aCols[Len(aCols)-1][nPosItem])//StrZero( Len( aCols ), TamSx3("UB_ITEM")[1] )

					//Carrega Inicializacao Padrao
					For nI := 1 To Len( aHeader )
						If !aHeader[nI][02] $ "UB_ALI_WT/UB_REC_WT"
							aCols[ Len(aCols) ][ nI ]	:= CriaVar( aHeader[nI, 2] )
						EndIf
					Next nI

					aCols[ Len(aCols) ][ Len(aHeader)+1 ]	:= .F.
					aCols[ Len(aCols) ][ nPosItem ]			:= cItemNew

				EndIf

			EndIf

			//--------------------------------------------------
			// Andre Lanzieri 01/07/2016
			// Posiciona objeto na linha correta
			//--------------------------------------------------
			n 					:= Len(aCols)
			oGetTlv:oBrowse:nAT := N

			//--------------------------------------------------
			// Andre Lanzieri 01/11/2016
			// Gatilha Produto
			//--------------------------------------------------
			aCols[ Len(aCols) ][ nPosProd  ]	:= aClean[nX,1]
			M->UB_PRODUTO						:= aCols[ N ][ nPosProd  ]
			U_XTMKEnterCpo("UB_PRODUTO"	, M->UB_PRODUTO	, N)

			//--------------------------------------------------
			// Andre Lanzieri 01/11/2016
			// Gatilho Quantidade
			//--------------------------------------------------
			aCols[ Len(aCols) ][ nPosQuant ]	:= aClean[nX,4]
			M->UB_QUANT							:= aClean[nX,4]
			U_XTMKEnterCpo("UB_QUANT"	, M->UB_QUANT	, N)

			aCols[ Len(aCols) ][ nPosRef   ]	:= aClean[nX,2]
			aCols[ Len(aCols) ][ nPosFil   ]	:= aClean[nX,3]

		Endif


	Next nX
	oGetTlv:oBrowse:nAT := Len( aCols )
	oGetTlv:oBrowse:Refresh(.T.)

Return Nil

//Atualizar filial no grride de referencias
//------------------------------------------------
Static Function fAtuFilial(cFil,nPrc)
	//------------------------------------------------

	RecLock(cTrb1,.F.)
	(cTrb1)->FILIAL := cFil
	(cTrb1)->PRECO  := nPrc
	(cTrb1)->(MsUnLock())
	oMark_1:oBrowse:Refresh()

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} MarkAll

Específico Cambuci - Programa com a finalidade de efetuar a marcação em todos os re
gistrs do Markbrowse 

@author 	Carlos Eduardo Saturnino - (11) 95425.55.92
@since 		18/10/2016
@version 	1.0
/*///---------------------------------------------------------------------------
User Function MarkAll(cMrk)

	dbSelectArea(cTrb1)
	dbGotop()
	While !Eof()
		RecLock(cTrb1,.F.)
		If Marked("OK")
			(cTrb1)->OK := Space(02) 
		Else
			(cTrb1)->OK := cMrk 
		Endif
		(cTrb1)->(MSUNLOCK())
		oMark_1:oBrowse:Refresh()
		dbSkip()
	End	

	oMark_1:oBrowse:Refresh()
	oMark_1:oBrowse:Gotop() 				// Força o posicionamento do browse no primeiro registro

Return(Nil)         


Static Function Cancela() 
	Local nPosProd 	:= GdFieldPos('UB_XCODREF')	
	
	If cOpcao == "A"
		oGetTlv:oBrowse:ColPos := nPosProd
		oGetTlv:oBrowse:nColPos := nPosProd
	
		oGetTlv:oBrowse:bEditCol := {|| }              
		
		oGetTlv:EditCell(oGetTlv:oBrowse,oGetTlv:oBrowse:nAt,oGetTlv:oBrowse:ColPos)
		
		oGetTlv:oBrowse:Refresh()   
	EndIf
	
	lCancela := .F.
Return