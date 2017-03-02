#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MTA930F1

Ponto de Entrada para criar uma condição que não deva ser processada no reprocessamento dos livros fiscais de entrada.

@author Allan Bonfim

@since 02/09/2015

@param

@obs  

@return

/*/
//-------------------------------------------------------------------
USER FUNCTION MTA930F1() 
     
Local lCondic := SF1->F1_XIMPORT <> 'S'


Return lCondic