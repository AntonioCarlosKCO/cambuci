#include "protheus.ch"
#include 'parmtype.ch'

/*/{Protheus.doc} FiltroTp
//TODO Descrição auto-gerada.
@author RaphaelFernandes
@since 09/02/2017
@param cFiltro, characters		
@type function
/*/
User Function FiltroTp(cTipo)

	Local _cAlias 	:= GetNextAlias()
	Local cFiltro 	:= ""
	
	BeginSql Alias _cAlias

		SELECT *
		FROM %Table:SED% SED
		WHERE SED.%NotDel%   
		AND SED.ED_FILIAL = %xFilial:SED%
		AND ED_XTIPO = %Exp:cTipo%
		 
	EndSql
	
	If 	! (_cAlias)->(Eof())
		cFiltro := 'SED->ED_XTIPO == M->E2_TIPO'
	Endif

	(_cAlias)->(dbCloseArea())
	
Return(cFiltro)