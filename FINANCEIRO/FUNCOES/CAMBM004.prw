#INCLUDE "TOPCONN.CH"
#include "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM004

Rotina para visualiza��o do e-mail enviado. Utilizado no ponto de entrada FI040ROT

@author  Allan Bonfim

@since   14/11/2014

@version P11
 
@param

@obs

@return

/*/
//------------------------------------------------------------------- 

User function CAMBM004(cAlias, nReg, nOpcA)

Local aArea		:= GetArea()
Local cNomArq	:= ""
Local cTmpPath	:= GetTempPath (.T.)
Local cPstSrv	:= ALLTRIM(SUPERGETMV("ES_PSTWFFT",, "\workflow\Html\Faturas"))

Default cAlias	:= "SE1"
Default nReg	:= Nil
Default nOpcA 	:= 2

If EMPTY(SE1->E1_PROCWFF)

//	MSGSTOP("O E-mail da fatura do t�tulo N� "+ALLTRIM(SE1->E1_NUM)+" n�o existe. Selecione um t�tulo v�lido.", "E-mail")
	MSGSTOP("N�o foi gerado um Workflow de renegocia��o para este t�tulo.")
//	DJALMA BORGES 23/12/2016	
		
Else

	cNomArq :=	ALLTRIM(SE1->E1_PROCWFF)+".HTM"
		
	If FILE (cPstSrv+"\"+cNomArq)	
		If FILE (cTmpPath+cNomArq)
        	FERASE(cTmpPath+cNomArq)
  		EndIf
        
		If AT("\", cPstSrv) <= 3
			If CPYS2T (cPstSrv+"\"+cNomArq, cTmpPath, .T.)
				SHELLEXECUTE("open",cTmpPath+cNomArq,"","",1)
			EndIf
		Else
			If CPYS2T ("\"+cPstSrv+"\"+cNomArq, cTmpPath, .T.)
				SHELLEXECUTE("open",cTmpPath+cNomArq,"","",1)
			EndIf
		EndIf	
	Else

   		MSGSTOP("O arquivo do workflow da fatura do t�tulo N� "+ALLTRIM(SE1->E1_NUM)+" n�o foi encontrado. Favor verificar com o TI.", "E-mail")
	EndIf

EndIf	

RestArea(aArea)
 
Return