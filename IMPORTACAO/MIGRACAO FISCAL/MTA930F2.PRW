#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MTA930F2

Ponto de Entrada para criar uma condi��o que n�o deva ser processada no reprocessamento dos livros fiscais de sa�da.

@author Allan Bonfim

@since 07/08/2015

@param

@obs  

@return

/*/
//-------------------------------------------------------------------
USER FUNCTION MTA930F2() 
     
Local lCondic := SF2->F2_XIMPORT <> 'S'
   
Return lCondic