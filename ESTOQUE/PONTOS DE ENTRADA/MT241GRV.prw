#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MT241GRV ³ Autor ³ Raphael F. Araújo 	  ³ Data ³ 19.12.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ LOCALIZAÇÃO :  função A241GRAVA (Gravação do movimento) 			   ±±
±±³ EM QUE PONTO : Após a gravação dos dados (aCols) no SD3, e tem a 	   ±±
±±³ finalidade de atualizar algum arquivo ou campo.						   ±±
±±³ Envia vetor com os parâmetros:										   ±±
±±³ PARAMIXB[1] = Número do Documento									   ±±
±±³ PARAMIXB[2] = Vetor bidimensional com nome campo/valor do campo		   ±± 
±±³ (somente será enviado se o Ponto de Entrada MT241CAB for utilizado).   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
/*/

User Function MT241GRV()

	Local lRet 	:= .T.
	_aObs 		:= Nil
	
Return lRet
