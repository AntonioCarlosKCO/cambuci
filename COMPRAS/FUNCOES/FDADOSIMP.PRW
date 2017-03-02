/*
OBSERVACAO IMPORTANTE:
ACRESCENTADO NA CHAVE UNICA DA TABELA CD5 NO SX2 O CAMPO CD5_SQADIC
*/
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.CH"
#include "tbiconn.ch"

/*
+===========================================================================+ 
|===========================================================================|
|Programa: fDadosImp    | Tipo: Função                |  Data: 14/08/2014   | 
|===========================================================================|
|Programador: Caio Garcia - Global Gcs                                      |
|===========================================================================|
|Utilidade: Carrega tela para preenchimento das informações complementares  |
|da nota de importação.                                                     |
|===========================================================================|
|--------------------------------Alterações---------------------------------|
|===========================================================================|
|                                                                           |
+===========================================================================+
*/  

User Function fDADOSIMP(_lImp)

Local cTitulo        := OemToAnsi("Complemento de Importação")
Local cAliasEnchoice := "CD5"
Local cAliasGetD     := "CD5"
Local cLinOk         := "AllwaysTrue()"
Local cTudOk         := "AllwaysTrue()"
Local cFieldOk       := "AllwaysTrue()"

Local aArea          := GetArea()
Local aCpoEnchoice   := {}
Local _aCols 	     := {}
Local _aHeader    	 := {}

Local lRet

Local nUsado         := 0
Local nOpcE          := 3
Local nOpcG          := 3

Private _nPos        := 0
Private _ns          := 1

Private _aNcm        := {}

If _lImp
	
	If (IsInCallStack("MATA119") .And. IsInCallStack("U_MT119AGR")) .And. INCLUI
		SF1->(dbSetOrder(1))
		If SF1->(dbSeek(xFilial("SF1")+_aNFEntrEX[2]+_aNFEntrEX[3]+_aNFEntrEX[4]+_aNFEntrEX[5]+_aNFEntrEX[6]))
			TcSqlExec( "DELETE FROM " + RetSqlName("CD5") + " WHERE CD5_FILIAL = '" + xFilial("CD5") + "' AND CD5_DOC = '" + SF1->F1_DOC + "' AND CD5_SERIE = '" + SF1->F1_SERIE + "' AND CD5_FORNEC = '" + SF1->F1_FORNECE + "' AND CD5_LOJA = '" + SF1->F1_LOJA + "'" )
		Else
			Return
		EndIf            
		
	ElseIf !IsInCallStack("MATA103")
		Return
	EndIf
	
EndIf

//===============================================================+
//         Campos que serão apresentados na Enchoice             |
//===============================================================+

aCpoEnchoice   := {	"CD5_FILIAL" ,;
					"CD5_DOC"    ,;
					"CD5_SERIE"  ,;
					"CD5_ESPEC"  ,;
					"CD5_FORNEC" ,;
					"CD5_LOJA"   ,;
					"CD5_TPIMP"  ,;
					"CD5_DOCIMP" ,;
					"CD5_DTDI"   ,;
					"CD5_LOCAL"  ,;
					"CD5_LOCDES" ,;
					"CD5_UFDES"  ,;
					"CD5_DTDES"  ,;
					"CD5_CODEXP" ,;
					"CD5_LOJEXP" ,;
					"CD5_DTPPIS" ,;
					"CD5_DTPCOF" ,;
					"CD5_NDI"    ,;
					"CD5_DTDI"   ,;
					"CD5_XMARCA" ,;
					"CD5_XNUMER" ,;					
					"CD5_CODFAB" ,;
					"CD5_INTERM" ,;
					"CD5_VTRANS" ,;					
					"CD5_LOJFAB" }   
					
//===============================================================+
//        Cria variaveis M->????? da Enchoice                    |
//===============================================================+

RegToMemory("CD5",.T.)

//===============================================================+
//           Cria aHeader e aCols da GetDados                    |
//===============================================================+

DbSelectArea("SX3")
DbSeek("CD5")
While !Eof() .And. (X3_ARQUIVO == "CD5")
	//--> Exclui da GetDados os campos existentes na Enchoice
	If AScan( aCpoEnchoice , AllTrim(X3_CAMPO) ) > 0
		DbSkip()
		Loop
	EndIf
	If X3USO(X3_USADO) .And. cNivel >= X3_NIVEL
		nUsado ++
		Aadd(_aHeader,{ 	TRIM(X3_TITULO)	,;
							X3_CAMPO		,;
							X3_PICTURE		,;
							X3_TAMANHO		,;
							X3_DECIMAL		,;
							X3_VALID		,;
							X3_USADO		,;
							X3_TIPO			,;
							X3_ARQUIVO		,;
							X3_CONTEXT 		})
	EndIf
	DbSkip()
EndDo

//===============================================================+
//            Carrega variaveis da GetDados...                   |
//===============================================================+

If _lImp
	
	SD1->(DbSetOrder(1))
	SD1->(DbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
	While !SD1->(Eof()) .And. xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
		aAdd( _aCols, Array(Len(_aHeader)+1) )
		For nX := 1 To Len(_aHeader)
			If AllTrim(_aHeader[nX,2]) == "CD5_FILIAL"
				_aCols[Len(_aCols)][nX] := xFilial('CD5')
			ElseIf AllTrim(_aHeader[nX,2]) == "CD5_ITEM"
				_aCols[Len(_aCols)][nX] := SD1->D1_ITEM
			ElseIf AllTrim(_aHeader[nX,2]) == "CD5_BSPIS" .And. SD1->(FieldPos("D1_BASIMP6")) > 0
				_aCols[Len(_aCols)][nX] := SD1->D1_BASIMP6
			Elseif AllTrim(_aHeader[nX,2]) == "CD5_ALPIS" .And. SD1->(FieldPos("D1_ALQIMP6")) > 0 // (FieldPos("D1_ALQPIS")) > 0 //Raphael F. Araújo 03/11/2016
				_aCols[Len(_aCols)][nX] := SD1->D1_ALQIMP6 //SD1->D1_ALQPIS //Raphael F. Araújo 03/11/2016
			Elseif AllTrim(_aHeader[nX,2]) == "CD5_VLPIS" .And. SD1->(FieldPos("D1_VALIMP6")) > 0
				_aCols[Len(_aCols)][nX] := SD1->D1_VALIMP6
			Elseif AllTrim(_aHeader[nX,2]) == "CD5_BSCOF" .And. SD1->(FieldPos("D1_BASIMP5")) > 0
				_aCols[Len(_aCols)][nX] := SD1->D1_BASIMP5
			Elseif AllTrim(_aHeader[nX,2]) == "CD5_ALCOF" .And. SD1->(FieldPos("D1_ALQIMP5")) > 0 //(FieldPos("D1_ALQCOF")) > 0 //Raphael F. Araújo 03/11/2016
				_aCols[Len(_aCols)][nX] := SD1->D1_ALQIMP5 //SD1->D1_ALQCOF //Raphael F. Araújo 03/11/2016
			Elseif AllTrim(_aHeader[nX,2]) == "CD5_VLCOF" .And. SD1->(FieldPos("D1_VALIMP5")) > 0
				_aCols[Len(_aCols)][nX] := SD1->D1_VALIMP5
			Elseif AllTrim(_aHeader[nX,2]) == "CD5_VLRII" .And. SD1->(FieldPos("D1_II")) > 0
				_aCols[Len(_aCols)][nX] := SD1->D1_II
			Elseif AllTrim(_aHeader[nX,2]) == "CD5_VDESDI" .And. SD1->(FieldPos("D1_DESC")) > 0
				_aCols[Len(_aCols)][nX] := SD1->D1_DESC
			Elseif AllTrim(_aHeader[nX,2]) == "CD5_BCIMP"
				_aCols[Len(_aCols)][nX] := SD1->D1_TOTAL
			ElseIf AllTrim(_aHeader[nX,2]) == "CD5_NADIC"
				fVerAdc()
				_aCols[Len(_aCols)][nX] := Padr(cValToChar(_aNcm[_nPos,2]),Tamsx3("CD5_NADIC")[1])
			ElseIf AllTrim(_aHeader[nX,2]) == "CD5_SQADIC"
				_aCols[Len(_aCols)][nX] := Padr(cValToChar(_aNcm[_nPos,3]),Tamsx3("CD5_SQADIC")[1])
			Else
				_aCols[Len(_aCols)][nX] := CriaVar(_aHeader[nX][2])
			Endif
		Next nX
		_aCols[Len(_aCols)][Len(_aHeader)+1] := .F.
		
		SD1->(DbSkip())
	Enddo
	
EndIf
      
If Len(_aCols) > 0
	 
	If .F.
	
		IF Select("CD5") <> 0
			CD5->(DbCloseArea())
		EndIF
		
		BeginSql Alias "CD5"
			%noParser%
			
			Select CD5_TPIMP,CD5_DOCIMP,CD5_DTDI,CD5_LOCAL,CD5_LOCDES,CD5_UFDES,CD5_DTDES,CD5_CODEXP,CD5_LOJEXP,CD5_DTPPIS
			,CD5_DTPCOF,CD5_NDI,CD5_DTDI,CD5_CODFAB,CD5_LOJFAB
			From CD5010 As CD5
			Where CD5.D_E_L_E_T_ = ''
			And CD5_FILIAL = %exp:SF1->F1_FILIAL%
			And CD5_DOC    = %exp:SF1->F1_DOC%
			And CD5_SERIE  = %exp:SF1->F1_SERIE%
			And CD5_FORNEC = %exp:SF1->F1_FORNECE%
			And CD5_LOJA   = %exp:SF1->F1_LOJA%
		EndSql
		
		MemoWrite("\query\CD5IMP.txt",GetLastQuery()[2])
		
		CD5->(DbSelectArea("CD5"))
		CD5->(DbGoTop())
		
		
		M->CD5_FILIAL := xFilial('CD5')
		M->CD5_DOC    := SF8->F8_NFDIFRE
		M->CD5_SERIE  := SF8->F8_SEDIFRE
		M->CD5_FORNEC := SF8->F8_FORNECE
		M->CD5_LOJA   := SF8->F8_LOJA
		M->CD5_ESPEC  := SF1->F1_ESPECIE
		M->CD5_TPIMP  := CD5->CD5_TPIMP
		M->CD5_DOCIMP := CD5->CD5_DOCIMP
		M->CD5_LOCAL  := CD5->CD5_LOCAL
		M->CD5_LOCDES := CD5->CD5_LOCDES
		M->CD5_UFDES  := CD5->CD5_UFDES
		M->CD5_DTDES  := StoD(CD5->CD5_DTDES)
		M->CD5_CODEXP := CD5->CD5_CODEXP
		M->CD5_LOJEXP := CD5->CD5_LOJEXP
		M->CD5_DTPPIS := StoD(CD5->CD5_DTPPIS)
		M->CD5_DTPCOF := StoD(CD5->CD5_DTPCOF)
		M->CD5_NDI    := CD5->CD5_NDI
		M->CD5_DTDI   := StoD(CD5->CD5_DTDI)
		M->CD5_CODFAB := CD5->CD5_CODFAB
		M->CD5_LOJFAB := CD5->CD5_LOJFAB
		
		CD5->(DbCloseArea())
		
	Else
		
		M->CD5_FILIAL := xFilial('CD5')
		M->CD5_DOC    := SF1->F1_DOC
		M->CD5_SERIE  := SF1->F1_SERIE
		M->CD5_FORNEC := SF1->F1_FORNECE
		M->CD5_LOJA   := SF1->F1_LOJA
		M->CD5_ESPEC  := SF1->F1_ESPECIE
		
	EndIf
	
	Do While .T.
		lRet := AktModelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,.T.,Len(_aCols),,1,,,,@_aCols,_aHeader)
		
		If !lRet
			Exit
		EndIf
		If VldDadImp(_aCols,_aHeader)
			Exit
		Else
			MsgAlert("Existem adicoes e sequencias de adicoes que se coincidem na digitacao.")
		EndIf
	EndDo
	
	If lRet
		//===============================================================+
		//                Grava registros na tabela...                   |
		//===============================================================+
		For nx := 1 To Len(_aCols)
			If !JaExiste(M->CD5_FILIAL,M->CD5_DOC,M->CD5_SERIE,M->CD5_FORNEC,M->CD5_LOJA,M->CD5_DOCIMP,;
				_aCols[nx,Ascan(_aHeader,{|x| Alltrim(x[2])=="CD5_ALPIS"})],;
				_aCols[nx,Ascan(_aHeader,{|x| Alltrim(x[2])=="CD5_ALCOF"})],;
				_aCols[nx,Ascan(_aHeader,{|x| Alltrim(x[2])=="CD5_NADIC"})],;
				_aCols[nx,Ascan(_aHeader,{|x| Alltrim(x[2])=="CD5_ITEM"})],;
				_aCols[nx,Ascan(_aHeader,{|x| Alltrim(x[2])=="CD5_SQADIC"})])
				
				RecLock("CD5",.T.)
			Else
				RecLock("CD5",.F.)
			EndIf
			
			//===============================================================+
			//                Grava campos da Enchoice...                    |
			//===============================================================+
			For nz := 1 To Len(aCpoEnchoice)
				CD5->&(aCpoEnchoice[nz]) := M->&(aCpoEnchoice[nz])
			Next nz
			//===============================================================+
			//                 Grava campos da GetDados...                   |
			//===============================================================+
			For ny := 1 To Len(_aHeader)
				CD5->&(_aHeader[nY][2]) := _aCols[nx,ny]
			Next ny
			CD5->(MsUnLock())
		Next nx
		
	EndIf

EndIf

RestArea(aArea)

Return

/*
+===========================================================================+ 
|===========================================================================|
|Programa: VldDadImp    | Tipo: Função                |  Data: 14/08/2014   | 
|===========================================================================|
|Programador: Caio Garcia - Global Gcs                                      |
|===========================================================================|
|Utilidade: Valida a digitação do aCols no Modelo3.                         |
|                                                                           |
|===========================================================================|
+===========================================================================+
*/  

Static Function VldDadImp(_aAKCols,_aAKHeader)

Local lRet 		:= .T.
Local nPosNadic	:= Ascan(_aAKHeader,{|x| Alltrim(x[2])=="CD5_NADIC"})
Local nPosSqAdic:= Ascan(_aAKHeader,{|x| Alltrim(x[2])=="CD5_SQADIC"})
Local _aCols 	:= _aAKCols

_aCols := aSort(_aCols,,,{|x,y|  x[nPosNadic]+y[nPosSqAdic] > y[nPosNadic]+y[nPosSqAdic] })

For nX:=1 to Len(_aCols)-1
	If _aCols[nX,nPosNadic]+_aCols[nX,nPosSqAdic] == _aCols[nX+1,nPosNadic]+_aCols[nX+1,nPosSqAdic]
		lRet := .F.
	EndIf
Next nX

Return lRet

/*
+===========================================================================+ 
|===========================================================================|
|Programa: AktModelo3   | Tipo: Função                |  Data: 14/08/2014   | 
|===========================================================================|
|Programador: Caio Garcia - Global Gcs                                      |
|===========================================================================|
|Utilidade: Cria Modelo3 com newgetdados.                                   |
|                                                                           |
|===========================================================================|
+===========================================================================+
*/  

Static Function AktModelo3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze,aButtons,aCordW,nSizeHeader,_aCols,_aHeader)

Local lRet, nOpca := 0,cSaveMenuh,nReg:=(cAlias1)->(Recno()),oDlg
Local oEnchoice
Local nDlgHeight
Local nDlgWidth
Local nDiffWidth := 0
Local lMDI := .F.
Local aAKCols 	:= _aCols
Local aAKHeader	:= _aHeader
Local aButtons  := {}

Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

nOpcE := If(nOpcE==Nil,3,nOpcE)
nOpcG := If(nOpcG==Nil,3,nOpcG)
lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
nLinhas:=Iif(nLinhas==Nil,99,nLinhas)

If SetMDIChild()
	oMainWnd:ReadClientCoors()
	nDlgHeight 	:= oMainWnd:nHeight
	nDlgWidth 	:= oMainWnd:nWidth
	lMdi 		:= .T.
	nDiffWidth 	:= 0
Else
	nDlgHeight 	:= 420
	nDlgWidth	:= 632
	nDiffWidth 	:= 1
EndIf

Default aCordW 		:= {135,000,nDlgHeight,nDlgWidth}
Default nSizeHeader := 240//110 Raphael F. Araújo 03/11/2016 - Alterado tamanho do cabeçalho.


DEFINE MSDIALOG oDlg TITLE cTitulo From aCordW[1],aCordW[2] to aCordW[3],aCordW[4] Pixel of oMainWnd
If lMdi
	oDlg:lMaximized := .T.
EndIf

oEnchoice := Msmget():New(cAlias1,nReg,nOpcE,,,,aMyEncho,{13,1,(nSizeHeader/2)+13,If(lMdi, (oMainWnd:nWidth/2)-2,__DlgWidth(oDlg)-nDiffWidth)},aAltEnchoice,3,,,,oDlg,,lVirtual,,,,,,,,.T.)
oGetDados := MsNewGetDados():New((nSizeHeader/2)+13+2,1,If(lMdi, (oMainWnd:nHeight/2)-13,__DlgHeight(oDlg)),If(lMdi, (oMainWnd:nWidth/2)-2,__DlgWidth(oDlg)-nDiffWidth),nOpcG,cLinOk,cTudoOk,,,,,,,,oDlg,aAKHeader,aAKCols)

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||nOpca:=0,oDlg:End()},,aButtons))

_aCols 		:= oGetDados:aCols
_aHeader 	:= oGetDados:aHeader

lRet:=(nOpca==1)
Return lRet

/*
+===========================================================================+ 
|===========================================================================|
|Programa: JaExiste     | Tipo: Função                |  Data: 14/08/2014   | 
|===========================================================================|
|Programador: Caio Garcia - Global Gcs                                      |
|===========================================================================|
|Utilidade: Retorna se movimento ja existe na base.                         |
|                                                                           |
|===========================================================================|
+===========================================================================+
*/  

Static Function JaExiste(_cFil,_cDoc,_cSer,_cFor,_cLoj,_cDocImp,_nAliqPis,_nAliqCof,_nAdic,_cItem,_cSQAdic)

Local cQuery := ""
Local lRet 	 := .F.

cQuery := "SELECT TOP 1 R_E_C_N_O_ AS RECCD5 FROM "+RetSqlName("CD5")+" CD5 "
cQuery += "WHERE CD5.D_E_L_E_T_ = ' ' "
cQuery += "	AND CD5.CD5_FILIAL 	= '"+_cFil+"' "
cQuery += "	AND CD5.CD5_DOC 	= '"+_cDoc+"' "
cQuery += "	AND CD5.CD5_SERIE 	= '"+_cSer+"' "
cQuery += "	AND CD5.CD5_FORNEC 	= '"+_cFor+"' "
cQuery += "	AND CD5.CD5_LOJA 	= '"+_cLoj+"' "
cQuery += "	AND CD5.CD5_DOCIMP 	= '"+_cDocImp+"' "
cQuery += "	AND CD5.CD5_ALPIS 	= '"+Str(_nAliqPis,5,2)+"' "
cQuery += "	AND CD5.CD5_ALCOF 	= '"+Str(_nAliqCof,5,2)+"' "
cQuery += "	AND CD5.CD5_NADIC 	= '"+_nAdic+"' "
cQuery += "	AND CD5.CD5_ITEM 	= '"+_cItem+"' "
cQuery += "	AND CD5.CD5_SQADIC	= '"+_cSQAdic+"' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"TRBCD5",.F.,.T.)
TRBCD5->(dbGotop())
If !TRBCD5->(Eof()) .And. !TRBCD5->(Bof())
	lRet := .T.
EndIf
TRBCD5->(dbCloseArea())

Return lRet

/*
+===========================================================================+ 
|===========================================================================|
|Programa: fVerAdc      | Tipo: Função                |  Data: 14/08/2014   | 
|===========================================================================|
|Programador: Caio Garcia - Global Gcs                                      |
|===========================================================================|
|Utilidade: Verifica o número da adição.                                    |
|                                                                           |
|===========================================================================|
+===========================================================================+
*/  

Static Function fVerAdc()

Local _cNcm := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_POSIPI")

If Len(_aNcm) == 0
	
	AADD(_aNcm,{_cNcm,_ns,1})
	
	_nPos := 1
	
Else
	
	_nPos:= AsCan(_aNcm,{|X|X[1]== _cNcm})
	
	If _nPos < 1
		
		_ns += 1
		
		AADD(_aNcm,{_cNcm,_ns,1})
		
		_nPos:= AsCan(_aNcm,{|X|X[1]== _cNcm})
		
	Else
		
		_aNcm[_nPos,3] := (_aNcm[_nPos,3]+1)
	EndIf
EndIf

Return(_nPos)