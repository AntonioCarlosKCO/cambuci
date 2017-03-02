#include "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#Include "PROTHEUS.CH"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} F040CPO

Ponto de Entrada para permitir alterações em campos do Contas a Receber (SE1) - FINA040

@author  Allan Bonfim

@since   07/11/2014

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------

User Function F040CPO()

Local _aArea		:= Getarea()
Local _aCpos		:= {}
Local _lSpbInUse 	:= SpbInUse()
Local _lPode 		:= .F.
Local _nX         	:= 0
Local _cTpAPort		:= ALLTRIM(SUPERGETMV("ES_ALTPORT",,"NF/FT"))

//Função Padrão fa040MCpo()
If !Empty(SE1->E1_BAIXA) .OR. "S" $ SE1->E1_LA .OR. Upper(Trim(SE1->E1_ORIGEM)) $ "LOJA/FINA460" .OR. SE1->E1_FATURA = "NOTFAT" // Nao permite alterar alguns campos da fatura.

	If SE1->E1_SALDO = 0
		Help(" ",1,"FA040BAIXA")
		Return
	Endif

	AADD(_aCpos,"E1_VENCTO")
	AADD(_aCpos,"E1_VENCREA")
	AADD(_aCpos,"E1_HIST")
	AADD(_aCpos,"E1_INDICE")
	AADD(_aCpos,"E1_OP")
	AADD(_aCpos,"E1_OCORREN")
	AADD(_aCpos,"E1_INSTR1")
	AADD(_aCpos,"E1_INSTR2")
	AADD(_aCpos,"E1_NUMBCO")
	AADD(_aCpos,"E1_FLUXO")
	AADD(_aCpos,"E1_ACRESC")
	AADD(_aCpos,"E1_DECRESC")
	AADD(_aCpos,"E1_DIADESC")
	AADD(_aCpos,"E1_DESCFIN")
	AADD(_aCpos,"E1_VALJUR")
	AADD(_aCpos,"E1_PORCJUR")

	If _lSpbInUse
		AADD(_aCpos,"E1_MODSPB")
	Endif

	// So permite alterar a natureza, depois de contabilizado o titulo, se ela nao estiver  preenchida
	If SED->(MsSeek(xFilial("SED")+SE1->E1_NATUREZ))
		For _nX := 1 To SED->(FCount())
			If "_CALC" $ SED->(FieldName(_nX))
				_lPode := !SED->(FieldGet(_nX)) $ "1S" // So permite alterar se nao calcular impostos
				If !_lPode // No primeiro campo que calcula impostos, nao permite alterar
					Exit
				Endif	
			Endif
		Next
	Endif	

	If ExistBlock("F040ALN")
		_lPode := .T.
	Endif

	// So permite alterar a natureza, depois de contabilizado o titulo, se ela nao estiver preenchida
	If Empty(SE1->E1_NATUREZ) .Or.;
		_lPode
		AADD(_aCpos,"E1_NATUREZ")
	Endif
	
Else

	AADD(_aCpos,"E1_NATUREZ")
	AADD(_aCpos,"E1_VENCTO")
	AADD(_aCpos,"E1_VENCREA")
	AADD(_aCpos,"E1_HIST")
	AADD(_aCpos,"E1_INDICE")
	AADD(_aCpos,"E1_OP")
	AADD(_aCpos,"E1_VALJUR")
	AADD(_aCpos,"E1_PORCJUR")
	AADD(_aCpos,"E1_VALOR")
	AADD(_aCpos,"E1_VALCOM1")
	AADD(_aCpos,"E1_VALCOM2")
	AADD(_aCpos,"E1_VALCOM3")
	AADD(_aCpos,"E1_VALCOM4")
	AADD(_aCpos,"E1_VALCOM5")
	AADD(_aCpos,"E1_OCORREN")
	AADD(_aCpos,"E1_INSTR1")
	AADD(_aCpos,"E1_INSTR2")
	AADD(_aCpos,"E1_NUMBCO")
	AADD(_aCpos,"E1_IRRF")
	AADD(_aCpos,"E1_ISS")
	AADD(_aCpos,"E1_FLUXO")
	AADD(_aCpos,"E1_INSS")
	AADD(_aCpos,"E1_PIS")
	AADD(_aCpos,"E1_COFINS")
	AADD(_aCpos,"E1_CSLL")
	AADD(_aCpos,"E1_ACRESC")
	AADD(_aCpos,"E1_DECRESC")
	AADD(_aCpos,"E1_DIADESC")
	AADD(_aCpos,"E1_DESCFIN")

	If _lSpbInUse
		AADD(_aCpos,"E1_MODSPB")
	Endif
	
Endif

If SE1->E1_SITUACA == "0" .AND. ALLTRIM(SE1->E1_TIPO) $ _cTpAPort
	AADD(_aCpos, "E1_PORTADO")
EndIf

RestArea(_aArea)

Return _aCpos