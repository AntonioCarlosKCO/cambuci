#include "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#Include "PROTHEUS.CH"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} MT103FIM

Ponto de Entrada após a Gravação da Nota de Entrada

@author  Allan Bonfim
@since   07/11/2014
@version P11
@param
@obs
@return

/*/
//-------------------------------------------------------------------

//****************************************************************************************
// REMOVIDO PONTO DE ENTRADA CONFORME SOLICITAÇÃO MONALISA - Raphael F. Araújo 17/11/2016
//****************************************************************************************

User Function MT103FIM()
/*
Local _aArea		:= Getarea()
Local _nOpcao 		:= PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina
Local _nConfirma	:= PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO
Local _cLocPad		:= SUPERGETMV("ES_XLOCPAD",, "01")
Local _cSeekSD1		:= SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
Local _aAreaSD1
Local _aAreaSD1A

If _nOpcao == 3 .OR. _nOpcao == 4
	If _nConfirma == 1
		_aAreaSD1 := SD1->(Getarea())
			SD1->(DbSetOrder(1)) //D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM, R_E_C_N_O_, D_E_L_E_T_
			If SD1->(DbSeek(xFilial("SD1")+_cSeekSD1))
	 			While !SD1->(EOF()) .AND. SD1->D1_FILIAL == xFilial("SD1") .AND. SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == _cSeekSD1
					If SD1->D1_LOCAL == _cLocPad .AND. GETADVFVAL("SBZ", "BZ_LOCALIZ", xFilial("SBZ")+SD1->D1_COD, 1) == "S" .AND. GETADVFVAL("SF4", "F4_ESTOQUE", xFilial("SF4")+SD1->D1_TES, 1) == "S"
						_aAreaSD1A := SD1->(Getarea())
							U_CAMBM002()
							//Voltar Ordenação correta
							SD1->(DbSetOrder(1))
						RestArea(_aAreaSD1A)
					EndIf
					SD1->(DbSkip())
				EndDo
			EndIf
		RestArea(_aAreaSD1)
    EndIf
EndIf

RestArea(_aArea)
*/
Return