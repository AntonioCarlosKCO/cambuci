#INCLUDE "protheus.ch"
#include "topconn.ch"


/*/{Protheus.doc} CAMBR02
//TODO Descrição auto-gerada.
@author henrique
@since 15/12/2015
@version 
@param xAlias, , descricao
@type function
/*/
User Function CAMBR02(xAlias)

	Local cDesc1         := "Este programa tem como objetivo imprimir etiquetas "
	Local cDesc2         := "para expedição. Somente produtos com liberação de estoque."
	Local cDesc3         := ""
	Local cPict          := ""
	Local titulo       := ""
	Local nLin         := 4

	Local Cabec1       := ""
	Local Cabec2       := ""
	Local imprime      := .T.
	Local aOrd := {}
	Local aSeq		:= GetSeqs()
	Local aPergs	:= {}
	Local aParam	:= {}	

	Default xAlias := ""

	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 220
	Private tamanho          := "G"
	Private nomeprog         := "CAMBR02" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 15
	Private aReturn          := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "CBETIQ" // Coloque aqui o nome do arquivo usado para impressao em disco

	Private cString := "SC9"

	Private _lPag    := .T.
	Private _cAlias := GetNextAlias()
	Private _lViaLib := .t.

	
	aAdd(aPergs, {2, "Sequencia"	   				, "Todas", aSeq, 80, , .T.})
	If ParamBox(aPergs, "Parametros ", @aParam)
		cSeqImp := If(aParam[1] = "Todas", "%'%'%", aParam[1])
	Else
		Return
	EndIf

	
	if xAlias <> ""
		_cPedido := (xAlias)->C5_NUM
		_nOpca := 4       
		_lviaLib := .f.
	Else		
		_nOpca := ParamIxb[1]		
	Endif

	if _nOpca == 4  //LIB TODOS

		BeginSql Alias _cAlias

		column C9_QTDLIB as numeric(14,2)
		column C9_PRCVEN as numeric(14,2)

		%noparser%

		SELECT * 
		FROM ( 
		SELECT *, R_E_C_N_O_ REC_SC9 
		FROM %Table:SC9%
		WHERE %NotDel%
		AND C9_PEDIDO = %Exp:_cPedido%
		AND C9_BLEST = ''
		AND C9_BLCRED = ''
		) SC9

		INNER JOIN (
		SELECT UB_FILIAL, UB_NUMPV, UB_ITEMPV, UB_XSEQ
		FROM %Table:SUB%
		WHERE %NotDel%
		AND UB_FILIAL = %xfilial:SUB%
		AND UB_XSEQ LIKE %Exp:cSeqImp%
		) SUB			                    

		ON C9_FILIAL = UB_FILIAL AND C9_PEDIDO = UB_NUMPV AND C9_ITEM = UB_ITEMPV

		INNER JOIN (
		SELECT B1_COD, B1_DESC, B1_PROC
		FROM %Table:SB1%
		WHERE %NotDel%
		) SB1

		ON C9_PRODUTO = B1_COD


		LEFT JOIN (
		SELECT * 
		FROM %Table:SDC%
		WHERE %NotDel%
		) SDC

		ON C9_FILIAL = DC_FILIAL 
		AND C9_PEDIDO 	= DC_PEDIDO 		
		AND C9_ITEM		= DC_ITEM
		AND C9_PRODUTO	= DC_PRODUTO


		LEFT JOIN (
		SELECT A5_PRODUTO, A5_CODPRF, A5_FORNECE
		FROM %Table:SA5%
		WHERE %NotDel%
		AND A5_FILIAL = %xFilial:SA5%
		) SA5

		ON B1_PROC = A5_FORNECE 
		AND B1_COD = A5_PRODUTO

		INNER JOIN (
		SELECT C6_FILIAL, C6_PRODUTO, C6_XCODREF, C6_NUM, C6_ITEM
		FROM %Table:SC6%
		WHERE %NotDel%
		AND C6_FILIAL = %xfilial:SC6%
		) SC6			                    

		ON C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM	

		ORDER BY DC_LOCALIZ

		EndSql

	Else
		Return()
	Endif	


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)


	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return



/*/{Protheus.doc} RunReport
//TODO Descrição auto-gerada.
@author henrique
@since 15/12/2015
@version 
@param Cabec1, , descricao
@param Cabec2, , descricao
@param Titulo, , descricao
@param nLin, numeric, descricao
@type function
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Local _nCol1 := 1          
	Local _ncol2 := 36
	Local _ncol3 := 72
	Local _ncol4 := 108
	Local _aPrint := {}
	Local _nx

	dbSelectArea(_cAlias)
	SetRegua(RecCount())

	if _lPrint
		nLin := 2
	Else	
		setprc(0,0) 
		@ 00, 00 PSAY CHR(27)+CHR(15)
		setprc(0,0)
		_lPrint := .t.
	Endif	


	(_cAlias)->(dbGoTop())
	While ! (_cAlias)->(EOF())

		aadd(_aPrint, {(_cAlias)->C6_XCODREF,;
		"Qt="+alltrim(str((_cAlias)->C9_QTDLIB)),;
		substr((_cAlias)->B1_DESC,1,23),;
		(_cAlias)->DC_LOCALIZ})


		(_cAlias)->(dbSkip())
	End	

	_nTam := len(_aPrint)	
	For _nx := 1 to len(_aPrint) step(4)	

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif


		//   @nLin,_nCol1 PSAY (_cAlias)->C9_PEDIDO+"/"+(_cAlias)->C9_ITEM
		//   @nLin,_nCol2 PSAY (_cAlias)->C9_PEDIDO+"/"+(_cAlias)->C9_ITEM
		//   @nLin,_nCol3 PSAY (_cAlias)->C9_PEDIDO+"/"+(_cAlias)->C9_ITEM
		//   @nLin,_nCol4 PSAY (_cAlias)->C9_PEDIDO+"/"+(_cAlias)->C9_ITEM

		//______________________________________
		@nLin,_nCol1 PSAY _aPrint[_nx][1]

		if _nx+1 <= _nTam
			@nLin,_nCol2 PSAY _aPrint[_nx+1][1]
		Endif
		if _nx+2 <= _nTam
			@nLin,_nCol3 PSAY _aPrint[_nx+2][1]
		Endif	

		if _nx+3 <= _nTam
			@nLin,_nCol4 PSAY _aPrint[_nx+3][1]
		Endif	
		//______________________________________

		//______________________________________
		@nLin+1,_nCol1 PSAY _aPrint[_nx][2]

		if _nx+1 <= _nTam
			@nLin+1,_nCol2 PSAY _aPrint[_nx+1][2]
		Endif	

		if _nx+2 <= _nTam
			@nLin+1,_nCol3 PSAY _aPrint[_nx+2][2]
		Endif	

		if _nx+3 <= _nTam
			@nLin+1,_nCol4 PSAY _aPrint[_nx+3][2]
		Endif	
		//______________________________________

		//______________________________________
		@nLin+2,_nCol1 PSAY _aPrint[_nx][3]
		
		if _nx+1 <= _nTam
			@nLin+2,_nCol2 PSAY _aPrint[_nx+1][3]
		Endif	
		if _nx+2 <= _nTam
			@nLin+2,_nCol3 PSAY _aPrint[_nx+2][3]
		Endif	
		if _nx+3 <= _nTam
			@nLin+2,_nCol4 PSAY _aPrint[_nx+3][3]
		Endif	
		//______________________________________

		//______________________________________
		@nLin+2,_nCol1+25 PSAY _aPrint[_nx][4]
		
		if _nx+1 <= _nTam
			@nLin+2,_nCol2+25 PSAY _aPrint[_nx+1][4]
		Endif	
		if _nx+2 <= _nTam
			@nLin+2,_nCol3+25 PSAY _aPrint[_nx+2][4]
		Endif	
		if _nx+3 <= _nTam
			@nLin+2,_nCol4+25 PSAY _aPrint[_nx+3][4]
		Endif	
		//______________________________________

		nLin := nLin + 4 // Avanca a linha de impressao

	Next


	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	SetPgEject(.F.)
	Ms_Flush()
Return


Static Function GetSeqs()
	Local cAliasTmp := GetNextAlias()
	Local cQuery	:= ""
	Local aSeq		:= {}
	
	cQuery := "SELECT UB_XSEQ FROM " + RetSqlName("SUB") + " SUB" + CRLF
	cQuery += " WHERE UB_FILIAL = '" + TRB->C5_FILIAL + "'" + CRLF
	cQuery += " AND UB_NUMPV = '" + TRB->C5_NUM + "'" + CRLF
	cQuery += " AND D_E_L_E_T_ = ' '" + CRLF
	cQuery += " GROUP BY UB_XSEQ" + CRLF
	cQuery += " ORDER BY UB_XSEQ" + CRLF
	
	TCQUERY cQuery NEW ALIAS (cAliasTmp)
	
	aAdd(aSeq, "Todas")
	
	While !Eof()
		aAdd(aSeq, UB_XSEQ)
		DbSkip()
	EndDo
	
	If Select(cAliasTmp) > 0
		(cAliasTmp)->(DbCloseArea())
	EndIf
	
Return aSeq