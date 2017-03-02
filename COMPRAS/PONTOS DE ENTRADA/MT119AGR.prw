#INCLUDE "TOTVS.CH"

/*
+===========================================================================+ 
|===========================================================================|
|Programa: MT119AGR     | Tipo: Ponto de Entrada      |  Data: 14/08/2014   | 
|===========================================================================|
|Programador: Caio Garcia - Global Gcs                                      |
|===========================================================================|
|Utilidade: Verifica se é nota de importação de chama a rotina de comple-   |
|mento da nota.                                                             |
|===========================================================================|
+===========================================================================+
*/  

User Function MT119AGR()

	Local  aArea := getArea() // Raphael F. Araújo 10/11/2016
	Private _lImp := .F.
 	Public _aNFEntrEX := {SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_TIPO}
	
	If Inclui .and. SF1->F1_EST =="EX" .and. SF1->F1_DOC == SF8->F8_NFORIG
		
		U_fDadosImp(_lImp)
		
	EndIf
	
	 restArea(aArea) // Raphael F. Araújo 10/11/2016

Return
