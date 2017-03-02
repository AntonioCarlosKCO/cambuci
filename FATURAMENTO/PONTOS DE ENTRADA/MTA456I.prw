#include 'protheus.ch'

/*/{Protheus.doc} MTA456I
@author Raphael Ara�jo
@since 28/10/2016
@version 1.0

@OBS Ponto de entrada disparado na rotina FATURAMENTO > ATUALIZA��ES > PEDIDOS > LIBERA�AO CRED/EST > MANUAL, 
no momento em que se clica em "Lib. Todos" de um pedido que ainda n�o foi liberado.

/*/
User function MTA456I

	Local lCont	:= .T. 
	Local aArea := getArea()
	   
    If SC6->C6_QTDVEN <> SC6->C6_QTDLIB
    	alert("ATEN��O! N�o � permitido libera��o parcial. Verifique a quantidade liberada! (M410PVNF)")
    	lCont := .F. 
    Endif
    
    restArea(aArea)

return lCont