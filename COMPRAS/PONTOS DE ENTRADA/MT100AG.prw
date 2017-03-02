#include 'protheus.ch'

/*
+===========================================================================+ 
|===========================================================================|
|Programa: MT100AG     | Tipo: Ponto de Entrada      |  Data: 03/11/2016    | 
|===========================================================================|
|Programador: Raphael F. Ara�jo - Global                                    |
|===========================================================================|
| Localiza��o:																|
| Function A103NFiscal - Programa de inclus�o, altera��o, exclus�o e 		|	
| visualiza��o de Nota Fiscal de Entrada. 									|
|																			|
| Finalidade:																|
| Ponto de entrada utilizado para realizar um procedimento de execu��o 		|
| complementar ap�s a confirma��o de "Inclus�o, Classifica��o ou exclus�o"	| 
| de um Documento de Entrada.												|
|===========================================================================|
+===========================================================================+
*/ 

User function MT100AG()
	
	Local aArea := getArea() // Raphael F. Ara�jo 10/11/2016
	Private _lImp := .T.
	//Public _aNFEntrEX := {SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_TIPO}
	
	If SF1->F1_EST =="EX" .and. SF1->F1_TIPO =="N" 
	
		U_fDadosImp(_lImp)
			
	EndIf
	
	restArea(aArea) // Raphael F. Ara�jo 10/11/2016
	
return