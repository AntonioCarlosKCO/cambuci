#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MTA930F2

Ponto de Entrada para criar uma condição que não deva ser processada no reprocessamento dos livros fiscais de saída.

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