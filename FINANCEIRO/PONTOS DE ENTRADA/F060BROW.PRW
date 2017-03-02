#include "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} F060BROW

Ponto de Entrada para filtro dos títulos para geração do Borderô a Receber

@author  Allan Bonfim

@since   07/11/2014

@version P11 

@param

@return
/*/
//------------------------------------------------------------------- 

User Function F060BROW()

Local _aArea	:= GetArea()
Local _cFiltro	:= ""

DbSelectArea("SE1")
SE1->(DbSetOrder(1))

_cFiltro := "!EMPTY(SE1->E1_PORTADO) .AND. EMPTY(SE1->E1_NUMBOR)"

MsFilter(_cFiltro)

RestArea(_aArea)

Return