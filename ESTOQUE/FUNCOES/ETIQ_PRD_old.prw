#Include 'Protheus.ch'
#Include 'Totvs.ch'

/*/{Protheus.doc} ETIQ_PRD
IMPRESSAO DE ETIQUETAS DE PRODUTOS (ESTOQUE) 
@author Raphael Fernandes
@since 03/02/2017
/*/
User Function ETIQ_PRD()

	Local _cPerg 	:= 'CA_IMPETIQ'
	Private cMV_PAR01 := MV_PAR01
	Private cMV_PAR02 := MV_PAR02
	Private nMV_PAR03 := MV_PAR03
	
	CriaSx1(_cPerg)

	Pergunte(_cPerg,.t.)

	ExecQry()

Return


/*/{Protheus.doc} ExecQry
@author Raphael Araújo
@since 03/02/2017
/*/
Static Function ExecQry()
	Private _cAlias 	:= GetNextAlias()

	BeginSql Alias _cAlias

		SELECT B1_COD, B1_DESC, B1_QE
		FROM %Table:SB1% SB1
		WHERE SB1.%NotDel%   
		AND SB1.B1_FILIAL = %xFilial:SB1%
		AND B1_COD BETWEEN %Exp:cMV_PAR01% AND %Exp:cMV_PAR02%
		
		ORDER BY B1_COD
		 
	EndSql
	
	CA_IMPETIQ()

	(_cAlias)->(dbCloseArea())
	
Return

/*/{Protheus.doc} CA_IMPETIQ
//TODO Descrição auto-gerada.
@author RaphaelFernandes
@since 03/02/2017
@version undefined

@type function
/*/
Static Function CA_IMPETIQ()

	Local _ny, _nx, _nw
	Local _nCol		:= 0
	Local _nLin 	:= 0
	Local _nQuebra 	:= 45
	Local _cModelo 	:= 'DATAMAX'
	Local _cPorta 	:= 'LPT1'
	
	MSCBPRINTER(_cModelo,_cPorta,NIL ,NIL,.F.,NIL,NIL,NIL,256000)
	MSCBCHKStatus(.F.)

	If MsgYesNo("A impressora está pronta?")

		MSCBBEGIN(Val(nMV_PAR03),5)
		
		_nLin 	:= 12
		_nCol 	:= 5

		MSCBSay(_nLin, _nCol, Alltrim((_cAlias)->B1_COD),"N","0","8")
		_nLin += 5
		
		If SB1->B1_QE <> 0
			MSCBSay(_nLin, _nCol,cValToChar((_cAlias)->B1_QE),"N","0","8")
		Else
			MSCBSay(_nLin, _nCol,"1","N","0","8")
		Endif
		
		MSCBSay(_nLin, _nCol, UPPER(Alltrim((_cAlias)->B1_DESC)),"N","0","8")// NO LUGAR
		_nLin += 5
		
		MSCBSay(_nLin, _nCol, ' ' ,"N","0","8")		
		_nLin += 5
		
		MSCBSay(_nLin, _nCol, 'DTOC(dDataBase) + " " + conout(Time())',"N","0","8") // NO LUGAR
		_nLin += 5
		
		//------------------------
				
		MSCBEND()
		MSCBCLOSEPRINTER()
		MS_FLUSH()

	Endif

Return


/*/{Protheus.doc} CriaSX1
@author Raphael
@since 03/02/2017
@param _aPerg, _aArea, i
/*/
Static Function CriaSX1(_cPerg)

	Local _aArea := GetArea()
	Local _aPerg := {}
	Local i
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	_cPerg := padr(_cPerg,len(SX1->X1_GRUPO))
	
	Aadd(_aPerg, {_cPerg, "01",	"Produto De   	", "mv_ch1",	"C", 15		, 0	, "G"	, "MV_PAR01", "SB1" ,"" ,"" ,""})
	Aadd(_aPerg, {_cPerg, "02",	"Produto Ate    ", "mv_ch2",	"C", 15		, 0	, "G"	, "MV_PAR02", "SB1" ,"" ,"" ,""})
	Aadd(_aPerg, {_cPerg, "03",	"Qtd Etiquetas 	", "mv_ch3",	"N", 04		, 0	, "G"	, "MV_PAR03", "" 	,"" ,"" ,""})
	
	For i := 1 To Len(_aPerg)
		IF  !DbSeek(_aPerg[i,1]+_aPerg[i,2])
			RecLock("SX1",.T.)
			Replace X1_GRUPO   with _aPerg[i,01]
			Replace X1_ORDEM   with _aPerg[i,02]
			Replace X1_PERGUNT with _aPerg[i,03]
			Replace X1_VARIAVL with _aPerg[i,04]
			Replace X1_TIPO	   with _aPerg[i,05]
			Replace X1_TAMANHO with _aPerg[i,06]
			Replace X1_DECIMAL with _aPerg[i,07]
			Replace X1_GSC	   with _aPerg[i,08]
			Replace X1_VAR01   with _aPerg[i,09]
			Replace X1_F3	   with _aPerg[i,10]
			Replace X1_CNT01   with _aPerg[i,11]
			MsUnlock()
		EndIF
	Next i
	
	RestArea(_aArea)

Return