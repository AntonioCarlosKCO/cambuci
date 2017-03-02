#INCLUDE "TOTVS.CH"

/*
+===========================================================================+ 
|===========================================================================|
|Programa: MT100AGR     | Tipo: Ponto de Entrada      |  Data: 14/08/2014   | 
|===========================================================================|
|Programador: Caio Garcia - Global Gcs                                      |
|===========================================================================|
|Utilidade: Verifica se é nota de importação de chama a rotina de comple-   |
|mento da nota.                                                             |
|===========================================================================|
+===========================================================================+
*/  

User Function MT100AGR()

	Local _cTp := "N"
	Local aArea := getArea() // Raphael F. Araújo 10/11/2016
 	  
	Private _lImp := .T.
	
	
	If Inclui .and. SF1->F1_EST =="EX" .and. SF1->F1_TIPO =="N"  
	
		U_fDadosImp(_lImp)
	
	EndIf 
	
	restArea(aArea) // Raphael F. Araújo 10/11/2016

Return(.T.)