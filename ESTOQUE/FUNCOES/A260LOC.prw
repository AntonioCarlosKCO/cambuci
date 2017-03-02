#include "totvs.ch"

/*
+===========================================================================+
|===========================================================================|
|Programa: A260LOC         | Tipo: Ponto de Entrada   |  Data: 12/12/2014   |
|===========================================================================|
|Programador: Caio Garcia - Global Gcs                                      |
|===========================================================================|
|Utilidade: Criar saldo inicial na transferência.                           |
|                                                                           |
|===========================================================================|
+===========================================================================+
*/                                                                
User Function A260LOC()

DbSelectArea("SB2")
SB2->(dbSetOrder(1))
If !(lRet:=SB2->(dbSeek(xFilial("SB2")+cCodDest+cLocDest)))
	If MsgYesNo("Não existe saldo inicial do produto "+AllTrim(cCodDest)+" no armazem "+AllTrim(cLocDest)+", deseja criar agora?","Atenção!!!!")
	
		Processa({|| fGerSalIni(cCodDest,cLocDest)},"Aguarde, criando saldo no armazém " + cLocDest + "...")
		
	EndIf
		
EndIf

Return Nil

/*
+===========================================================================+
|===========================================================================|
|Programa: fGerSalIni   | Tipo: Função                |  Data: 23/10/2014   |
|===========================================================================|
|Programador: Caio Garcia - Global Gcs                                      |
|===========================================================================|
|Utilidade: Gera o saldo inicial.                                           |
|                                                                           |
|===========================================================================|
|                                                                           |
+===========================================================================+
*/

Static Function fGerSalIni(_cCod,_cLoc)

Local aSaldoIni := {}
Private lMsErroAuto 	:= .F.
Private lMsHelpAuto 	:= .T. //.F. - mostra msg de erro

	aSaldoIni := {}
	aSaldoIni := {{"B9_FILIAL"  ,xFilial("SB9")			    ,NIL},;
	              {"B9_COD"		,_cCod      				,NIL},;
   			      {"B9_LOCAL"	,_cLoc   					,NIL},;
	              {"B9_QUANT"	,0							,NIL}}
	
	MSExecAuto({|x,y| MATA220(x,y)}, aSaldoIni, 3)
	
	If lMsErroAuto
		lMsErroAuto := .F.
		MostraErro()
	EndIf

Return