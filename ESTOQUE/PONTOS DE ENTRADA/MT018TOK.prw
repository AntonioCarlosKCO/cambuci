#INCLUDE "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MT018TOK

Ponto de Entrada para validar o cadastro de indicador do produto (TUDO OK).

@author  Allan Bonfim

@since   09/12/2014

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------

User Function MT018TOK()

Local _aArea	:= GetArea()
Local _lRet   	:= .T.
Local _cAlert	:= ""
Local _cTitulo	:= "HELP"
Local _aAreaSBE 
Local _aAreaNNR

If _lRet
	If !EMPTY(GETMEMVAR("BZ_LOCPAD"))
		_aAreaNNR	:= NNR->(GetArea())
			DbSelectArea("NNR")
			NNR->(DbSetOrder(1)) //NNR_FILIAL, NNR_CODIGO
			If !NNR->(DbSeek(xFilial("NNR")+BZ_LOCPAD))
				_lRet 	:= .F. 
				_cAlert := "O local informado não existe. Favor verificar o preenchimento do campo "+ALLTRIM(GETNAMEFIELD("BZ_LOCPAD"))+"."
			EndIf
		RestArea(_aAreaNNR)
	EndIf
EndIf

If _lRet
	If !EMPTY(GETMEMVAR("BZ_LOCPAD")) .AND. !EMPTY(GETMEMVAR("BZ_X_ENDER"))
		_aAreaSBE	:= SBE->(GetArea())
			DbSelectArea("SBE")
			SBE->(DbSetOrder(1)) //BE_FILIAL, BE_LOCAL, BE_LOCALIZ
			If !SBE->(DbSeek(xFilial("SBE")+BZ_LOCPAD+BZ_X_ENDER))
				_lRet 	:= .F. 
				_cAlert := "O endereço informado não existe. Favor verificar o preenchimento do campo "+ALLTRIM(GETNAMEFIELD("BZ_X_ENDER"))+"."
			EndIf
		RestArea(_aAreaSBE)
	EndIf
EndIf

If !_lRet
	Help("",1, _cTitulo,, _cAlert, 3, 1)
EndIf

RestArea(_aArea)

Return _lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GETNAMEFIELD

Retorna o nome do campo

@author  Allan Bonfim

@since 09/12/2014

@version P11 

@param	[cField], caracter, Nome do campo no dicionário de dados
		
@return caracter, Retorna o nome do campo

/*/
//------------------------------------------------------------------- 

STATIC FUNCTION GETNAMEFIELD(_cField)

Local _cRet    	:= ""
Local _aArea    := GetArea()
Local _aAreaSX3 := SX3->(GetArea())

Default _cField	:= ""

If !Empty(_cField)
	SX3->(dbSetOrder(2))
	If SX3->(dbSeek(_cField))
		_cRet := AllTrim(X3Titulo())
	EndIf
EndIf	
SX3->(RestArea(_aArea))

RestArea(_aArea)

Return _cRet