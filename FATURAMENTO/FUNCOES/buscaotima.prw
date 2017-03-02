#include 'protheus.ch'
#include 'parmtype.ch'

user function BuscaOtima()
	
	
SetPrvt("oDlg1","oSay1","oGet1","oCBox1")

oDlg1      := MSDialog():New( 092,232,616,927,"Busca Otimizada",,,.F.,,,,,,.T.,,,.T. )

oDlg1:bInit := {||EnchoiceBar(oDlg1,,,.F.,{})}

oSay1      	:= TSay():New( 032,012,{||"Pesquisar"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGet1      	:= TGet():New( 032,056,{|u| If(PCount()>0,cProd:=u,cProd)},oDlg1,060,008,'',{|x| u_VldPrd2()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cProd",,)

oCBox1  	:= TComboBox():New( 056,056,{|u| If(PCount()>0,cDesc:=u,cDesc)},_aB1_COD,268,010,oDlg1,,{|| u_chglst()}, {|| u_chglst()}				,CLR_BLACK	,CLR_WHITE, .T.					, oFont1, , , /*[ bWhen]*/, , , , , "cDesc", "Descrição" ,1, /*[oLabelFont]*/, /*[nLabelColor]*/  )

oDlg1:Activate(,,,.T.)	
	
return




/*/{Protheus.doc} VldProd
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 

@type function
/*/
User Function VldPrd2()
	Local _aArea := getArea()
	Local _lRet := .f.     
	Local _nPos := 0
	Local _cAlias := GetNextAlias()
	Local _cProd := alltrim(cProd)
	aItens := {}


	if empty(_cProd)
		MsgAlert("Codigo de produto não preenchido.")
		_lRet := .f.
	Else	

		BeginSql Alias _cAlias

		SELECT  DISTINCT(B1_COD), B1_DESC, B1_GRUPO, B1_BITMAP, ZZA_XCOD, ZZA_XCODRF	
		FROM (
		SELECT B1_COD, B1_DESC, B1_GRUPO, B1_BITMAP	
		FROM %Table:SB1%(NOLOCK)
		WHERE %NotDel%	
		AND  charindex(B1_MSBLQL,%Exp:_cBloqueados%) > 0
		AND NOT B1_GRUPO IN ('XXX','FIS','OLD','NDF')	
		) SB1


		INNER JOIN(
		SELECT * 
		FROM %Table:SBM% (Nolock)
		WHERE %NotDel%
		//	AND BM_CLASGRU <> '1'
		) SBM

		ON B1_GRUPO = BM_GRUPO


		LEFT JOIN (
		SELECT A5_PRODUTO, A5_CODPRF
		FROM %Table:SA5% (NOLOCK)	
		WHERE %NotDel%
		) SA5

		ON B1_COD = A5_PRODUTO

		LEFT JOIN (
		SELECT ZZA_XCOD, ZZA_XCODRF
		FROM %Table:ZZA% (NOLOCK)
		WHERE %NotDel%
		) ZZA

		ON B1_COD = ZZA_XCOD

		WHERE B1_COD 	LIKE RTRIM(%Exp:_cProd%)+'%'
		OR A5_CODPRF 	LIKE RTRIM(%Exp:_cProd%)+'%'
		OR ZZA_XCODRF 	LIKE RTRIM(%Exp:_cProd%)+'%'
		OR ZZA_XCOD 	LIKE RTRIM(%Exp:_cProd%)+'%'
		OR B1_DESC		LIKE RTRIM(%Exp:_cProd%)+'%'

		ORDER BY B1_COD		

		EndSql

		(_cAlias)->(dbGotop())
		if (_cAlias)->(eof())
			MsgAlert("Codigo não encontrado.")
		Endif	

		_aB1_DESC 	:= {}
		_aB1_COD 	:= {}

		While ! (_cAlias)->(eof())

			_cCod1 := alltrim((_cAlias)->B1_COD)
			_cCod2 := alltrim((_cAlias)->ZZA_XCODRF) 

			_space1 := space(  (15 - len( _cCod1 )) * 2.2 )
			_space2 := space(  (15 - len( _cCod2 )) * 2.0 )

			_cCod1 += _space1
			_cCod2 += _space2

			aadd(aItens		, _cCod1 + '  |  '+ _cCod2 +' | '+(_cAlias)->B1_DESC )
			AADD(_aB1_DESC	,(_cAlias)->B1_DESC)
			AADD(_aB1_COD	,(_cAlias)->B1_COD)

			(_cAlias)->(dbSkip())
		End	

	Endif

	oCBox1:aItems := aClone(aItens)
	oCBox1:refresh()

	RestArea(_aArea)
Return(_lRet)