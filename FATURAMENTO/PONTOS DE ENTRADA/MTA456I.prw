#include 'protheus.ch'

/*/{Protheus.doc} MTA456I
@author Raphael Araújo
@since 28/10/2016
@version 1.0

@OBS Ponto de entrada disparado na rotina FATURAMENTO > ATUALIZAÇÕES > PEDIDOS > LIBERAÇAO CRED/EST > MANUAL, 
no momento em que se clica em "Lib. Todos" de um pedido que ainda não foi liberado.

/*/
User function MTA456I

	Local lCont	:= .T. 
	Local aArea := getArea()
	   
    If SC6->C6_QTDVEN <> SC6->C6_QTDLIB
    	alert("ATENÇÃO! Não é permitido liberação parcial. Verifique a quantidade liberada! (M410PVNF)")
    	lCont := .F. 
    Endif
    
    restArea(aArea)

return lCont