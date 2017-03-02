#include 'protheus.ch'
#include 'parmtype.ch'

User function VldLimCP()
	Local lRet 		:= .T.
	Local nValCond 	:= MaFisRet(,"NF_TOTAL") - MaFisRet(,"NF_VALSOL")
	
	If nValCond > SE4->E4_SUPER .AND. SE4->E4_SUPER <> 0
		Help(" ","1","LJLIMSUPER")
		lRet	:= .F.
	ElseIf nValCond < SE4->E4_INFER .AND. SE4->E4_INFER <> 0
		Help(" ","1","LJLIMINFER")
		lRet	:= .F.
	Endif
Return lRet