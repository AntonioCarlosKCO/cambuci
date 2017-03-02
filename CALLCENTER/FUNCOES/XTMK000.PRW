#INCLUDE 'TOTVS.CH'
#INCLUDE 'topconn.ch'

/*
@DOC
Funcao: U_XTMKPreco
Titulo: Preço final de venda dos produtos
Parametros:
1 - caracter -> codigo filial
2 - caracter -> codigo Produto
3 - caracter -> codigo do cliente
4 - caracter -> loja do cliente
Retorno: Numerico -> Preço final de venda com as regras aplicadas
@DOC
*/
Function U_XTMKPreco(cFil,cProd,cCli,cLoj)

	Local aAreaSM0	:= SM0->(GetArea())
	Local aArea   	:= GetArea()
	Local aTabPrc 	:= {}
	Local aPercent	:= {}
	Local nFator  	:= 0
	Local nPrcTb  	:= 0
	Local nx      	:= 0
	Local cFilBkp 	:= CFILANT	
		
	CFILANT := cFil

	aTabPrc := U_XTMKTbPreco(cProd) //->{ cod tabela , preco }

	For nx := 1 To Len(aTabPrc)

		aPercent := U_XTMKPercVenda(cProd,aTabPrc[nx,1],cCli,cLoj) //->{ percentual, tipo desconto, registro }

		nFator := 1 + (aPercent[1] / 100)
		If aPercent[2] == 'D' //desconto
			nFator := 1 - (aPercent[1] / 100)
		EndIf

		// comparar preco tabela com o percentual aplicado regra
		If nx == 1
			nPrcTb :=  (aTabPrc[nx,2] * nFator)
		Else
			If nPrcTb > (aTabPrc[nx,2] * nFator)
				nPrcTb := (aTabPrc[nx,2] * nFator)
			EndIf
		EndIf
		
		nPrcTb := Round(nPrcTb, 2)
	Next nx
	
	If ReadVar() == "M->UB_QUANT"
		M->UB_VRUNIT := nPrcTb
		U_XTMKEnterCpo("UB_VRUNIT", M->UB_VRUNIT, n)
	EndIf
	
	CFILANT := cFilBkp
	RestArea(aAreaSM0)
	RestArea(aArea)
			
Return nPrcTb


/*
@DOC
Funcao: U_XTMKTbPreco
Titulo: Tabela de precos
Parametros:
1 - codigo produto
Retorno: Array -> {codigo da tabela ; preco base ; registro}
@DOC
*/
Function U_XTMKTbPreco(cProd)

	Local aArea     := GetArea()
	Local cQryDA1   := GetNextAlias()
	Local aRet      := {}

	//identificar as tabelas de preço do produto
	BeginSql Alias cQryDA1

	SELECT
	DA1_CODTAB, DA1_PRCVEN, R_E_C_N_O_
	FROM
	%table:DA1%
	WHERE
	DA1_FILIAL = %xFilial:DA1%
	AND %NotDel%
	AND DA1_CODPRO = %Exp:cProd%
	AND DA1_ATIVO = '1'
	ORDER BY DA1_CODTAB

	EndSql

	//gravar a query para analise dos dados
	//aQuery := GetLastQuery()
	//cQry := aQuery[2]
	//makedir("C:\TEMP\QRYEXEC\")
	//MemoWrite( "C:\TEMP\QRYEXEC\" + AllTrim(FunName()) + DTOS(Date()) + StrTran(Time(),":","") + "_3.sql" , cQry )

	(cQryDA1)->(DbGoTop())
	While (cQryDA1)->(!EOF())
		If aScan( aRet, { |x| x[1] == (cQryDA1)->DA1_CODTAB } ) == 0
			AAdd(aRet,{(cQryDA1)->DA1_CODTAB,(cQryDA1)->DA1_PRCVEN,(cQryDA1)->R_E_C_N_O_})
		EndIf
		(cQryDA1)->(DbSkip())
	EndDo

	If Len(aRet) <= 0
		AAdd(aRet,{Space(TamSX3("DA1_CODTAB")[1]),0,0})
	EndIf

	RestArea(aArea)
	
	If Select(cQryDA1)
		(cQryDA1)->(DbCloseArea())
	EndIf

Return aRet

/*
@DOC
Funcao: U_XTMKPercVenda
Titulo: Regra de preço final de venda dos produtos
Parametros:
1 - caracter -> codigo produto
2 - caracter -> codigo tabela preço
3 - caracter -> codigo do cliente
4 - caracter -> loja do cliente
Retorno: Array -> {percentual,tipo de calculo,registro}
@DOC
*/
Function U_XTMKPercVenda(cProd,cTabela,cCli,cLoj)

	Local aArea    := GetArea()
	Local aAreaSB1 := SB1->(GetArea())
	Local aAreaSA1 := SA1->(GetArea())
	Local cWhere   := ""
	Local cQryZZE  := GetNextAlias()
	Local aRet     := {}
	
	// DJALMA BORGES 14/02/2017 - INÍCIO
	Local cEstFilLog := ""
	Local _aAreaSM0 := SM0->(GetArea())
		SM0->(dbGoTop())
		While SM0->(!EOF())
			If ALLTRIM(SM0->M0_CODFIL) == xFilial("SUB")
				cEstFilLog := SM0->M0_ESTENT
				EXIT
			EndIf
			SM0->(dbSkip())
		EndDo
	RestArea(_aAreaSM0)
	// DJALMA BORGES 14/02/2017 - FIM

	//tabelas e indices
	SB1->(DbSetOrder(1))
	SA1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial('SB1')+cProd))
	SA1->(DbSeek(XFilial('SA1')+cCli+cLoj))

	cWhere := "%"
	cWhere += "     ( ZZE_XMARCA = '"+SB1->B1_XMARCA  +"' OR ZZE_XMARCA = ' ') "
	cWhere += " AND ( ZZE_XSUBGR = '"+SB1->B1_XSUBGRU +"' OR ZZE_XSUBGR = ' ') "
	cWhere += " AND ( ZZE_XTABEL = '"+cTabela         +"' OR ZZE_XTABEL = ' ') "
	cWhere += " AND ( ZZE_NCM    = '"+SB1->B1_POSIPI  +"' OR ZZE_NCM    = ' ') "
	cWhere += " AND ( ZZE_XDESTC = '"+SA1->A1_EST     +"' OR ZZE_XDESTC = ' ') "
	cWhere += " AND ( ZZE_XORIGC = '"+cEstFilLog      +"' OR ZZE_XORIGC = ' ') " // DJALMA BORGES 14/02/2017
	cWhere += " AND ( ZZE_XPRODU = '"+cProd           +"' OR ZZE_XPRODU = ' ') "
	cWhere += " AND ( ZZE_XGRPCL = '"+SA1->A1_GRPVEN  +"' OR ZZE_XGRPCL = ' ') "
	cWhere += " AND ( ZZE_XCODCL = '"+SA1->A1_COD     +"' OR ZZE_XCODCL = ' ') "
	cWhere += " AND ( ZZE_XGRUPO = '"+SB1->B1_GRUPO   +"' OR ZZE_XGRUPO = ' ') "
	cWhere += " AND ( ZZE_XLINHA = '"+SB1->B1_XLINHA  +"' OR ZZE_XLINHA = ' ') "
	cWhere += "%"

	BeginSql Alias cQryZZE

	SELECT TOP 1 *
	FROM
	%table:ZZE%
	WHERE
	ZZE_FILIAL = %xFilial:ZZE%
	AND %Exp:cWhere%
	AND %NotDel%
	ORDER BY ZZE_XORDEM DESC, ZZE_XPDESC

	EndSql

	//gravar a query para analise dos dados
	//aQuery := GetLastQuery()
	//cQry := aQuery[2]
	//makedir("C:\TEMP\QRYEXEC\")
	//MemoWrite( "C:\TEMP\QRYEXEC\" + AllTrim(FunName()) + DTOS(Date()) + StrTran(Time(),":","") + "_4.sql" , cQry )

	(cQryZZE)->(DbGoTop())
	aRet := {0,'',0}
	If (cQryZZE)->(!EOF())
		aRet := {(cQryZZE)->ZZE_XPDESC,(cQryZZE)->ZZE_XTPCAL,(cQryZZE)->R_E_C_N_O_}
	EndIf

	RestArea(aArea)
	RestArea(aAreaSB1)
	RestArea(aAreaSA1)
	
	(cQryZZE)->(dbCloseArea()) // DJALMA BORGES 24/01/2017

Return aRet

/*
@DOC
Funcao: U_XTMKSldFiliais
Titulo: Saldos por filiais
Parametros:
1 - caracter -> codigo Produto
2 - caracter -> codigo armazem
3 - caracter -> codigo da filial
Retorno: Array -> Filial, nome da filial, quant atual, quant disponivel
@DOC
*/
Function U_XTMKSldFiliais(cProd,cArmazem)

	Local cQrySB2 := GetNextAlias()
	Local cWhere  := ""
	Local aRet := {}
	Local aArea := GetArea()
	Local aAreaSM0 := SM0->(GetArea())

	cWhere := "%"
	cWhere += " B2_LOCAL IN "+FormatIn(cArmazem,'/')+ " AND B2_COD = '"+cProd+"' AND B2_QATU > 0 "
	cWhere += "%"

	//QUERY DOS DADOS
	BeginSql Alias cQrySB2

	SELECT
	B2_FILIAL FILIAL,
	SUM(B2_QATU) QTDATU,
	SUM(B2_QATU-B2_QACLASS-B2_RESERVA) QTDISP
	FROM
	%table:SB2%
	WHERE %Exp:cWhere%
	AND %NotDel%
	GROUP BY B2_FILIAL
	ORDER BY B2_FILIAL

	EndSql

	//gravar a query para analise dos dados
	//aQuery := GetLastQuery()
	//cQry := aQuery[2]
	//makedir("C:\TEMP\QRYEXEC\")
	//MemoWrite( "C:\TEMP\QRYEXEC\" + AllTrim(FunName()) + DTOS(Date()) + StrTran(Time(),":","") + "_5.sql" , cQry )

	//preenchimento do vetor
	(cQrySB2)->(DbGotop())
	While (cQrySB2)->(!EOF())
		SM0->(DbSeek(CEMPANT+(cQrySB2)->FILIAL))
		AAdd(aRet,{(cQrySB2)->FILIAL,SM0->M0_FILIAL,(cQrySB2)->QTDATU, (cQrySB2)->QTDISP})
		(cQrySB2)->(DbSkip())
	EndDo
	(cQrySB2)->(DbCloseArea())
	If Len(aRet) <= 0
		AAdd(aRet,{Space(TamSX3("B2_FILIAL")[1]),Space(TamSX3("UB_XNFILIA")[1]),0,0})
	EndIf
	RestArea(aArea)
	RestArea(aAreaSM0)

Return aRet

/*
@DOC
Funcao: U_XTMKEnterCpo
Titulo: Executa gatilhos e validações do campo
Parametros:
1 - caracter -> nome do campo
2 - caracter -> conteudo do campo
3 - numerico -> linha da getdados
4 - numerico -> 1-Enchoice, 2-Getdados
5 - objeto   -> Nome do objeto
Retorno: Logico
@DOC
*/
Function U_XTMKEnterCpo(cCampo,ValorDoCampo,n,nTipo,oObj)

	Local aArea	   := GetArea()
	Local cVarAtu  	:= ReadVar()
	Local lRet     	:= .T.
	Local cPrefixo 	:= "M->"
	Local bValid
		
	DEFAULT nTipo := 2 // 1-Enchoice ; 2-GetDados ; 3-F3
	DEFAULT oObj  := NIL

	
	// A variavel __ReadVar e padrao do sistema, ela identifica o campo atualmente posicionado.
	// Mude o conteudo desta variavel para disparar as validacoes e gatilhos do novo campo.
	// Nao esquecer de voltar o conteudo original no final desta funcao.
	__ReadVar := cPrefixo+cCampo

	//Valoriza o campo atual Simulado.
	&(cPrefixo+cCampo) := ValorDoCampo
	
	//Carrega validacoes do campo.
	SX3->( dbSetOrder(2) )
	SX3->( dbSeek(cCampo) )
	bValid := IIF(!Empty(SX3->X3_VLDUSER),Rtrim(SX3->X3_VLDUSER)+IIF(!Empty(SX3->X3_VALID),".And.",""),"")+Rtrim(SX3->X3_VALID)
	bValid := "{|| "+IIF(EMPTY(bValid),".T.",bValid)+" }"

	//Evita recursivo da funcao.
	//bValid := StrTran(Upper(bValid),"U_MACOMA01()",".T.")
	bValid := StrTran(Upper(bValid),"U_XTMKEnterCpo()",".T.")

	//Executa validacoes do campo.
	lRet := Eval( &(bValid) )

	IF lRet
		//Executa gatilhos do campo.
		SX3->(DbSetOrder(2))
		SX3->(DbSeek(cCampo))
		IF ExistTrigger(cCampo)
			RunTrigger(nTipo,n,,oObj)
		EndIF
	EndIF

	//Retorna __ReadVar com o valor original.
	__ReadVar := cVarAtu

	RestArea(aArea)

Return(lRet)

/*
@DOC
Funcao: U_XTMKQtdMult
Titulo: Validar quantidade multipas do orcamento (B1_QE)
Parametros:
Retorno: Logico
@DOC
*/
Function U_XTMKQtdMult()

	Local aArea	   := GetArea()
	Local cVarAtu  := ReadVar()
	Local lRet     := .T.

	If ( M->UB_QTDE % SB1->B1_QE ) # 0

		lRet := .F.
		MsgBox("Valor informado na quantidade não é multiplo da quantidade minima do produto",FunName(),"STOP")
		//Retorna __ReadVar com o valor original.
		__ReadVar := cVarAtu

	EndIf

	RestArea(aArea)

Return(lRet)

/*
@DOC
Funcao: U_XTMKQtdMult
Titulo: Validar o valor unitario do preço venda do orcamento (B1_VRUNIT)
Parametros:
1 - numerico -> valor de tabela
Retorno: Logico
@DOC
*/
Function U_XTMKVlrUnit(nVlrTab)

	Local aArea	 := GetArea()
	Local cVarAtu  := ReadVar()
	Local lRet     := .T.
	Local nvlrDe   := 0
	Local nvlrAte  := 0

	ALERT(U7_COD)

	nVlrTab * (1 - (PercMinimo/100))
	nVlrTab * (1 + (PercMaximo/100))

	If ( M->UB_VRUNIT < nvlrDe .Or. M->UB_VRUNIT > nvlrAte )

		lRet := .F.
		MsgBox("Valor informado invalido para o percenntual do usuario",FunName(),"STOP")
		//Retorna __ReadVar com o valor original.
		__ReadVar := cVarAtu

	EndIf

	RestArea(aArea)

	Return(lRet)


	//------------------------------------------------------------------------
	/*/{Protheus.doc} User Function XTMKGrTr
	Validação de existência de Grupo de Tributação para o Produto
	@author 	Carlos Eduardo Saturnino
	@since 		05/10/2016
	@version 	1.0
	@param 		_cProduto	, ${param_type}, (Caminho para gravação do Arquivo)
	@return 	${return}, ${return_description}
	@example	

	@see 		(links_or_references)
	//------------------------------------------------------------------------
/*/ User Function XTMKGrTr(_cProduto, cCliente, cLoja)

	Local lRet 	:= .F.
	Local aArea	:= GetArea()
	
	dbSelectArea("SBZ") // DJALMA BORGES 14/02/2017
	SBZ->(dbSetOrder(1))
	If SBZ->(dbSeek(xFilial("SBZ") + _cProduto ))
		If ! Empty(SBZ->BZ_GRTRIB)
			lRet := VldSF7(SBZ->BZ_GRTRIB, cCliente, cLoja)
		Else
			Aviso("XTMKGrTr - Aviso","Não existe Grupo Tributário cadastrado para o Código de Produto " + Alltrim(_cProduto) + " - " + Alltrim(SB1->B1_DESC) + ". O item não será incluído no orçamento.",{"OK"},2)			
		Endif
	Endif

	/*
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1") + _cProduto ))
		If ! Empty(SB1->B1_GRTRIB)
			lRet := VldSF7(SB1->B1_GRTRIB, cCliente, cLoja)
		Else
			Aviso("XTMKGrTr - Aviso","Não existe Grupo Tributário cadastrado para o Código de Produto " + Alltrim(_cProduto) + " - " + Alltrim(SB1->B1_DESC) + ". O item não será incluído no orçamento.",{"OK"},2)			
		Endif
	Endif
	*/

	RestArea(aArea)

	Return(lRet)

	//------------------------------------------------------------------------
	/*/{Protheus.doc} User Function XTMKGrTr
	Validação de existência de Grupo de Tributação para o Produto
	@author 	Carlos Eduardo Saturnino
	@since 		05/10/2016
	@version 	1.0
	@param 		_cProduto	, ${param_type}, (Caminho para gravação do Arquivo)
	@return 	${return}, ${return_description}
	@example	

	@see 		(links_or_references)
	//------------------------------------------------------------------------
	/*/ 

User Function XTMKXTOp()

	Local _aArea	:= GetArea()
	Local _cRet	:= "" 

	dbSelectArea("SA3")
	dbSetOrder(1)				// A3_FILIAL + A3_COD
	dbGoTop()

	If MsSeek(xFilial("SA3")+ SU7->U7_CODVEN)
		If ! Empty(SA3->A3_XTIPOPV) 
			_cRet	:= SA3->A3_XTIPOPV
		Else
			// Incluido em 08/11/2016 por Carlos Eduardo Saturnino para não apresentar 
			// o aviso quando for inclusão por ExecAuto (Função AFAT001)
			If ! IsInCallStack("U_AFAT001") 		
				Aviso("XTMKXTOp - Tipo de Venda ","Não existe Origem da Venda cadastrado para o Vendedor." + CHR(13)+CHR(10) + "Favor alterar o campo Origem da Venda no cadastro de Vendedores",{"OK"},2)
			Endif
		Endif
	Endif

	RestArea(_aArea)

Return(_cRet)		

/*/------------------------------------
	Raphael - Global 02/12/2016
 	Validação do Campo M->UB_VRUNIT 
------------------------------------/*/
	
User Function AltPrcUn()
	
	Local lRet		:= .T.
	Local aAreaSU7 	:= SU7->(Getarea())
	Local aAreaSA3 	:= SA3->(Getarea())
	Local nQtd		:= GdFieldPos('UB_QUANT') 	// Raphael F. Araújo 13/12/2016
	Local cTipo		:= POSICIONE('SU7',1,xFilial('SU7')+M->UA_OPERADO,'U7_TIPO')
	Local cVendedor	:= POSICIONE('SU7',1,xFilial('SU7')+M->UA_OPERADO,'U7_CODVEN')
	Local nPercUni 	:= 0
	Local nPrc   	:= U_XTMKPreco(xFilial('SUB'),aCols[n][GdFieldPos('UB_PRODUTO')],M->UA_CLIENTE,M->UA_LOJA)
	
	nPercUni 		:= POSICIONE('SA3',1,xFilial('SA3')+Alltrim(cVendedor),'A3_XPRCUNI')
	nPrc 			:= Round(nPrc,2) * aCols[n][nQtd] //M->UB_QUANT
	
	If !INCLUI
		cTipo := POSICIONE("SU7",4,xFilial('SU7') + __cUserID,'U7_TIPO')
	Endif
	
	If cTipo == '1' 
		
		If !IsInCallStack("U_CTMK001")
	
			If (M->UB_VRUNIT*aCols[n][nQtd]) < nPrc
				MsgInfo("Usuário sem permissão para baixar o valor unitário.","PERMISSÃO VENDEDOR")
				lRet := .F.
				
			Elseif (M->UB_VRUNIT*aCols[n][nQtd]) > (nPrc+(nPrc*(nPercUni/100))) 
				MsgInfo("Valor informado superior ao percentual do usuário.","PERMISSÃO VENDEDOR")
				lRet := .F.
				
			Endif
		Endif
	Endif
	
	RestArea(aAreaSU7)
	RestArea(aAreaSA3)

Return(lRet)

/*/------------------------------------
	Raphael - Global 12/12/2016
 	Validação do Campo M->UA_OPERADO 
------------------------------------/*/

User Function AltOper()
	
	Local lRet 		:= .T.
	Local aAreaSU7 	:= SU7->(Getarea())
	Local cTipo		:= POSICIONE("SU7",1,xFilial('SU7')+ M->UA_OPERADO,'U7_TIPO')
	Local cTipoUser	:= POSICIONE("SU7",4,xFilial('SU7')+ __cUserId,'U7_TIPO')
	
	If cTipo == '2' 
		If cTipoUser <> '2'
			MsgInfo("VOCÊ NÃO TEM PERMISSÃO PARA INCLUIR UM SUPERVISOR!","PERMISSÕES VENDEDOR")
			lRet := .F.	
		Endif
	Endif
	
	RestArea(aAreaSU7)
	
Return lRet


Static Function VldSF7(cProd, cCli, cLoja)
	Local lRet 		:= .T.
	Local cQuery 	:= ""
	Local cAliasQry := GetNextAlias()
	
	cQuery := "SELECT 1 FROM " + RetSqlName("SF7") + " SF7" + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SA1") + " SA1" + CRLF
	cQuery += "ON A1_COD = '" + cCli + "'" + CRLF
	cQuery += "AND A1_LOJA = '" + cLoja + "'" + CRLF
	cQuery += "AND A1_EST = F7_EST" + CRLF
	cQuery += "AND A1_TIPO = F7_TIPOCLI" + CRLF // DJALMA BORGES 17/02/2017
	cQuery += "AND A1_GRPTRIB = F7_GRPCLI" + CRLF // DJALMA BORGES 17/02/2017
	cQuery += "AND SA1.D_E_L_E_T_ = ''" + CRLF // DJALMA BORGES 22/02/2017
	cQuery += "AND A1_FILIAL = '" + xFilial("SA1") + "'" + CRLF // DJALMA BORGES 22/02/2017
	cQuery += "WHERE F7_FILIAL = '" + xFilial("SF7") + "' AND SF7.D_E_L_E_T_ = ''" + CRLF // DJALMA BORGES 22/02/2017
	cQuery += "AND F7_GRTRIB = '" + cProd + "'" + CRLF
	
	TCQUERY cQuery NEW ALIAS (cAliasQry)
	
	
	If (cAliasQry)->(EoF())
		Aviso("XTMKGrTr - Aviso","Não existe exceção fiscal cadastrada para o estado do cliente. O item não será incluído no orçamento.",{"OK"},2)
		lRet := .F.
	EndIf
	
	//If Select(cAliasQry) > 0
		(cAliasQry)->(DbCloseArea())
	//EndIf
	
Return lRet