#include 'protheus.ch'

/*
+===========================================================================+ 
|===========================================================================|
|Programa: MT100AG     | Tipo: Ponto de Entrada      |  Data: 03/11/2016    | 
|===========================================================================|
|Programador: Raphael F. Araújo - Global                                    |
|===========================================================================|
| Localização:																|
| Function A103NFiscal - Programa de inclusão, alteração, exclusão e 		|	
| visualização de Nota Fiscal de Entrada. 									|
|																			|
| Finalidade:																|
| Ponto de entrada utilizado para realizar um procedimento de execução 		|
| complementar após a confirmação de "Inclusão, Classificação ou exclusão"	| 
| de um Documento de Entrada.												|
|===========================================================================|
+===========================================================================+
*/ 

User function MT100AG()
	
	Local aArea := getArea() // Raphael F. Araújo 10/11/2016
	Private _lImp := .T.
	//Public _aNFEntrEX := {SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_TIPO}
	
	If SF1->F1_EST =="EX" .and. SF1->F1_TIPO =="N" 
	
		U_fDadosImp(_lImp)
			
	EndIf
	
	restArea(aArea) // Raphael F. Araújo 10/11/2016
	
return