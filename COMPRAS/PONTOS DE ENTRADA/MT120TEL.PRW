#Include "RwMake.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} MT120TEL
Ponto de Entrada p/ incluir campo no cabecalho do Pedido de Compra
Chamada padrao para programas em RDMake

@author Raphael F. Araújo - Consultoria Global
@since 21/11/2016

@Return logico, se realizou a transferencia ou não.

@Obs
	PARAMIXB[1] - Dialogo
	PARAMIXB[2] - Array com as Coordenadas dos Gets
	PARAMIXB[3] - aObj(?)
	PARAMIXB[4] - nOpcx  // 02 Visualizar / 03 Inclusao / 04 Cópia / 06 Alteração
/*/

User Function MT120TEL()

	Local _aArea := GetArea()
	Local _aAreaSX3 := SX3->(GetArea())
	Local _aPosGet := PARAMIXB[2]
		
	Local _oNewDlg := PARAMIXB[1]
	
	Local _nOpcx := PARAMIXB[4]
	
	Local _cTXOper := ""
	Local _cTXPrVent := ""
	
	Public _cOper := CriaVar("C7_XOPER")  
	Public _dPrevEnt := CriaVar("C7_XPRVENT") 
	Public _cXOper := CriaVar("C7_XOPER")  
	Public _dXPrevEnt := CriaVar("C7_XPRVENT") 
		
	SX3->(DbSetOrder(2))	// X3_CAMPO
	
	If _nOpcx = 3 // Inclusão
		_cOper := Space(TamSx3("C7_XOPER")[1])
		_dPrevEnt := CToD("")
	Else
		_cOper := SC7->C7_XOPER
		_dPrevEnt := SC7->C7_XPRVENT
	EndIf
	
	_cXOper := _cOper
	_dXPrevEnt := _dPrevEnt
	
	_cTXOper := Posicione("SX3",2,"C7_XOPER","AllTrim(X3Titulo())")
	
	@ 062,_aPosGet[2,5]-12 SAY _cTXOper OF _oNewDlg PIXEL SIZE 050,08
	@ 061,_aPosGet[2,6]-25 MSGET oOper Var _cOper PICTURE PesqPict("SC7","C7_XOPER") F3 CpoRetF3("C7_XOPER","DJ") OF _oNewDlg PIXEL SIZE 020, 006
	
	// Quando ganha o foco, guarda a informação do campo
	oOper:bGotFocus := {|| _cXOper := _cOper }
	
	// Quando perde o foco, verifica se houve alteração, se sim, preenche o campo C7_OPER e executa o gatilho para todos os itens
	oOper:bLostFocus := {|| If(_cXOper<>_cOper,U_GatiTpOp(.T.),) }
	
	_cTXPrVent := Posicione("SX3",2,"C7_XPRVENT","AllTrim(X3Titulo())")
	
	// Raphael Araújo - Global 06/01/2017 
	@ 062, _aPosGet[1,12]-20 SAY _cTXPrVent OF _oNewDlg PIXEL SIZE 060,08
	@ 061, _aPosGet[1,12]+24 MSGET oPrevEnt VAR _dPrevEnt PICTURE "99/99/9999" OF _oNewDlg PIXEL SIZE 040, 010
	
	// Quando ganha o focu, guarda a informação do campo
	oPrevEnt:bGotFocus := {|| _dXPrevEnt := _dPrevEnt }
	
	// Quando perde o focu, verifica se houve alteração, se sim, preenche o campo C7_XPRVENT e executa o gatilho para todos os itens
	oPrevEnt:bLostFocus := {|| If(_dXPrevEnt<>_dPrevEnt,U_GatiPrev(.T.),) }
	
	RestArea(_aAreaSX3)
	RestArea(_aArea)
	
Return .T.

/*/{Protheus.doc} MTA120G3
LOCALIZAÇÃO : Function A120GRAVA - Função responsável pela gravação do Pedido de Compras e Autorização de Entrega.
EM QUE PONTO : Na função A120GRAVA executado após a gravação de cada item do pedido de compras recebe como parametro o Array 
manipulado pelo ponto de entrada MTA120G1 e pode ser usado para gravar as informações deste array no item do pedido posicionado.

@author Raphael F. Araújo - Consultoria Global
@since 21/11/2016
/*/

User Function MTA120G3()

	SC7->C7_XOPER := Alltrim(_cOper)
	SC7->C7_XPRVENT := _dPrevEnt		// Raphael - Global 06/01/2017
	
Return

/*/{Protheus.doc} GatiTpOp
Gatilho para replicação do tipo de operação do Cabeçalho para os itens do Pedido de Compra

@author Raphael F. Araújo - Consultoria Global
@since 21/11/2016
/*/

User Function GatiTpOp(l_AllItem)
	
//	Local _nCount := 0
//	Local _nPProduto := GdFieldPos("C7_PRODUTO")
	Local _nPOper := GdFieldPos("C7_OPER")
	Local _nPXOper := GdFieldPos("C7_XOPER")
	
//	Local _oProcessa := Nil
	
	Default l_AllItem := .F.
	
	// Se altera para todos os itens do pedido de compra
	If l_AllItem
		FWMsgRun(,{|| TPOPITEM()}, "Tp. Operação X Tes Inteligente", "Replicando e atualizando para todos os itens ...") // DJALMA BORGES 27/01/2017
//		FWMsgRun(,{|| AEval(aCols,{|x| _nCount++, If(!Empty(x[_nPProduto]),(x[_nPOper] := _cOper,RunTrigger(2,_nCount,Nil,,"C7_OPER"),x[_nPXOper] := _cOper,RunTrigger(2,n,Nil,,"C7_XOPER")),) }) },"C7_OPER","Atualizando operação...")
	Else	// Se ajusta somente o item
		aCols[n][_nPOper] := _cOper
		U_XTMKEnterCpo("C7_OPER", aCols[n][_nPOper], n)
		aCols[n][_nPXOper] := _cOper

	EndIf
	
	GETDREFRESH()
	
Return _cOper

/*/{Protheus.doc} GatiPrev
Gatilho para replicação da Previsão de entrega do Cabeçalho para os itens do Pedido de Compra
 
@author Raphael F. Araújo - Consultoria Global
@since 03/01/2017
/*/

User Function GatiPrev(l_AllItem)
	
//	Local _nCount := 0
//	Local _nPProduto := GdFieldPos("C7_PRODUTO")
	Local _nPPrevEnt := GdFieldPos("C7_XPRVENT")
	Local _nPDatPrF := GdFieldPos("C7_DATPRF")
	
	Default l_AllItem := .F.
	
	// Se altera para todos os itens do pedido de compra
	If l_AllItem
//		FWMsgRun(,{|| AEval(aCols,{|x| _nCount++, If(!Empty(x[_nPProduto]),(x[_nPPrevEnt] := _dPrevEnt,RunTrigger(2,_nCount,Nil,,"C7_XPRVENT")),) }) },"C7_XPRVENT","Atualizando operação...")
		FWMsgRun(,{|| DTPRITEM()}, "Data Prev. Entrega", "Replicando para todos os itens ...") // DJALMA BORGES 27/01/2017
	Else
		aCols[n][_nPPrevEnt] := _dPrevEnt
		U_XTMKEnterCpo("C7_DATPRF", aCols[n][_nPPrevEnt], n)
		aCols[n][_nPDatPrF] := _dPrevEnt
	EndIf
	
	GETDREFRESH()
	
Return _dPrevEnt

// FUNÇÃO PARA ATUALIZAR TP.OPER X TES INTELIGENTE NO ACOLS
// DJALMA BORGES 27/01/2017
Static Function TPOPITEM()

	Local nCount := 0
	Local nPOper := GdFieldPos("C7_OPER")
	Local nPXOper := GdFieldPos("C7_XOPER")
	Local nPProduto := GdFieldPos("C7_PRODUTO")
		
	For nCount := 1 to Len(aCols)
	
		If !Empty(aCols[nCount][nPProduto])
			aCols[nCount][nPOper] := _cOper
			U_XTMKEnterCpo("C7_OPER", aCols[nCount][nPOper], nCount)
			aCols[nCount][nPXOper] := _cOper
		EndIf
	
	Next

Return

// FUNÇÃO PARA ATUALIZAR DATA PREV. ENTREGA NO ACOLS
// DJALMA BORGES 27/01/2017
Static Function DTPRITEM()

	Local nCount := 0
	Local nPPrevEnt := GdFieldPos("C7_XPRVENT")
	Local nPDatPrF := GdFieldPos("C7_DATPRF")
	Local nPDIniCQ := GdFieldPos("C7_DINICQ")
	Local nPDIniTra := GdFieldPos("C7_DINITRA")
	Local nPDIniCom := GdFieldPos("C7_DINICOM")
	Local nPProduto := GdFieldPos("C7_PRODUTO")
		
	For nCount := 1 to Len(aCols)
	
		If !Empty(aCols[nCount][nPProduto])
			aCols[nCount][nPPrevEnt] := _dPrevEnt
			aCols[nCount][nPDatPrF]  := _dPrevEnt
			//U_XTMKEnterCpo("C7_DATPRF", aCols[nCount][nPDatPrF], nCount)
			aCols[nCount][nPDIniCQ]   := _dPrevEnt
			aCols[nCount][nPDIniTra]  := _dPrevEnt
			aCols[nCount][nPDIniCom]  := _dPrevEnt
		EndIf
	
	Next

Return