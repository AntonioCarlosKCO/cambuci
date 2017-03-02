#Include 'Protheus.ch'

User Function MTA410T()

	Local _aArea := GetArea()
	Local _cTabela := ""
	Local _aComiss := {}

	//__________________________ TRATATIVA DE CALCULO DE PESO LIQUIDO E BRUTO /  LUIS HENRIQUE - GLOBAL / 07/12/15
	Local _nPLiq := 0
	Local _nPBru := 0
	Local _nTotal := 0
	
	// DJALMA BORGES 29/11/2016 - INÍCIO
	
	Default _cConPgAnt := "" 
	Default _aComisFat := {}
	
	If _cConPgAnt <> "" .and. _cConPgAnt <> SC5->C5_CONDPAG // SE CONDPAG FOI ALTERADO PELA ROTINA PADRÃO
		RECLOCK("SC5", .F.)
			SC5->C5_XCPAMPL := "N"
		SC5->(MSUNLOCK())
	EndIf
	
	_cConPgAnt := nil
	
	// DJALMA BORGES 29/11/2016 - FIM

	//VERIFICA SE TEM LIBERAÇÃO PARA IMPRESSAO DO ROMANEIO
	U_EnvRoma()
	//______________________________________

	dbSelectArea("SC6")
	dbSetOrder(1)
	dbSeek(xfilial("SC6")+SC5->C5_NUM)
	While !SC6->(eof()) .and. xfilial("SC6")+SC5->C5_NUM  == SC6->C6_FILIAL+SC6->C6_NUM

		SB1->(dbSetorder(1))
		SB1->(dbSeek(xfilial('SB1')+SC6->C6_PRODUTO))

		_nPLiq += SB1->B1_PESO * SC6->C6_QTDVEN
		_nPBru += SB1->B1_PESBRU * SC6->C6_QTDVEN
		_nTotal += SC6->C6_VALOR

		SC6->(dbSkip())

	End

	Reclock('SC5',.F.)
	SC5->C5_PESOL 	:= _nPLiq 
	SC5->C5_PBRUTO 	:= _nPBru
	//SC5->C5_XTOTPV1 := _ntotal COMENTADO POR DJALMA BORGES 05/12/2016
	SC5->(MsUnlock())                                                    

	//_____________________________________________________________________

	If  SC5->C5_TIPO <> "N"
		RestArea(_aArea)
		Return
	Endif		

	dbSelectArea("SZ1")
	dbSetOrder(1)
	dbGotop()
	While ! SZ1->(eof())

		if SZ1->Z1_DATADE < SC5->C5_EMISSAO .and. SZ1->Z1_DATAATE > SC5->C5_EMISSAO
			_cTabela := SZ1->Z1_CODIGO
			exit
		Endif

		SZ1->(dbskip())
	End

	If !empty(_cTabela)

		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xfilial("SC6")+SC5->C5_NUM)

		While ! SC6->(EOF()) .and. SC6->C6_NUM == SC5->C5_NUM

			POSICIONE("SB1", 1, xFilial("SB1") + SC6->C6_PRODUTO, "B1_GRUPO")

			_aComiss := U_RegraCom(_cTabela)

			if len(_aComiss) == 0

				AADD(_aComiss, 0)
				AADD(_aComiss, 0)
				AADD(_aComiss, space(4))
				AADD(_aComiss, space(4))

			Endif	

			Reclock("SC6",.F.)
			if !empty(SC5->C5_VEND1)
				SC6->C6_COMIS1 	:= _aComiss[1]
			Else
				SC6->C6_COMIS1 	:= 0
			Endif
			if !empty(SC5->C5_VEND2)
				SC6->C6_COMIS2 	:= _aComiss[2]
			Else
				SC6->C6_COMIS2 	:= 0
				SC6->C6_XSEQCA2 := _aComiss[4]
			Endif
			SC6->C6_XSEQCAL		:= _aComiss[3]
			SC6->(MsUnlock())

			SC6->(dbSkip())
		End
		
		// DJALMA BORGES 29/12/2016 - INÍCIO
		Aadd(_aComisFat, SC5->C5_VEND1) // [1]
		Aadd(_aComisFat, _aComiss[1])   // [2]
		Aadd(_aComisFat, SC5->C5_VEND2) // [3]
		Aadd(_aComisFat, _aComiss[2])   // [4]
		// DJALMA BORGES 29/12/2016 - FIM

	ENDIF

	RestArea(_aArea)
	
Return

User Function RegraCom(_cTabela)
	
	Local _aArea := GetArea()

	Local _aComiss0 := {0,0,"", ""}
	Local _aComiss1 := {}
	Local _aComiss2 := {}

	Local _aZ2_Vld 	:= {"Z2_VEND"		, "Z2_TIPOREP"	, "Z2_ITEMGRP"		, "Z2_TPED"			, "Z2_ITEMMAR"		, "Z2_LINHA"		,"Z2_GRUPOPE" } 
	Local _aZ2_Vld2 := {"SC5->C5_VEND1"	, "SA3->A3_TIPO", "SB1->B1_GRUPO"	, "SC5->C5_XTIPOPV" , "SB1->B1_XMARCA"	, "SB1->B1_XLINHA"	,"SA1->A1_XGRPPES" } 

	SA3->(dbSeek(xfilial()+SC5->C5_VEND1))
	SB1->(dbSeek(xfilial()+SC6->C6_PRODUTO))

	_aComiss1 := RegraCom_B(_cTabela, _aZ2_Vld, _aZ2_Vld2)

	If ! empty(SC5->C5_VEND2)

		SA3->(dbSeek(xfilial()+SC5->C5_VEND2))

		_aZ2_Vld2[1] := "SC5->C5_VEND2"
		_aComiss2 := RegraCom_B(_cTabela, _aZ2_Vld, _aZ2_Vld2)

		_aComiss0[1] := _aComiss1[2] //TAXA 2 DO VEND1
		_aComiss0[2] := _aComiss2[2] //TAXA 2 DO VEND2
		_aComiss0[3] := _aComiss1[3] //SEQ CALC VEND 1
		_aComiss0[4] := _aComiss2[3] //SEQ CALC VEND 2

	Else

		_aComiss0[1] := _aComiss1[1] //TAXA 2 DO VEND1
		_aComiss0[2] := 0 //TAXA 2 DO VEND2
		_aComiss0[3] := _aComiss1[3] //SEQ CALC VEND 1
		_aComiss0[4] := "" //SEQ CALC VEND 2

	Endif    

	RestArea(_aArea)

Return(_aComiss0)

Static Function RegraCom_B(_cTabela, _aZ2_Vld, _aZ2_Vld2)
	
	Local _aArea := GetArea()
	Local _cAlias := GetNextAlias()
	Local _cVld1 := ""
	Local _cVld2 := ""
	Local _aComiss := {}

	Local _aComiss := { 0 , 0, "" }

	BeginSql Alias _cAlias

	%noparser%

	SELECT *
	FROM %Table:SZ2%
	WHERE %NotDel%
	AND Z2_FILIAL = %xFilial:ZZ2%
	AND Z2_CODIGO = %Exp:_cTabela%

	ORDER BY Z2_ORDEM DESC

	EndSql

	dbSelectArea(_cAlias)

	While ! (_cAlias)->(eof())

		_cVld1 := ""
		_cVld2 := ""

		For _nx := 1 to len(_aZ2_Vld)

			_cCampo := _aZ2_Vld[_nx]
			_cCampo2 := _aZ2_Vld2[_nx]

			if ! empty(&_cCampo)

				_cVld1 += alltrim((_cAlias)->&_cCampo)
				_cVld2 += alltrim(&_cCampo2)
				
			Else

				_cVld1 += ""
				_cVld2 += ""

			Endif

		Next

		if _cVld1 == _cVld2

			_aComiss[1]	:= (_cAlias)->Z2_TX1
			_aComiss[2] := (_cAlias)->Z2_TX2
			_aComiss[3] := (_cAlias)->Z2_SEQUENC
			exit
		Endif

		(_cAlias)->(dbSkip())

	End

	(_cAlias)->(dbCloseArea())
	
	RestArea(_aArea)
	
Return(_aComiss)
