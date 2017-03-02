#include 'protheus.ch'

/*/{Protheus.doc} MA450PED
@author Raphael Ara�jo
@since 27/10/2016
@version 1.0

@OBS Este ponto pertence � rotina de libera��o de cr�dito, MATA450(). 
Est� localizado no processamento da avalia��o autom�tica de cr�dito por pedido, MA450PROCES(). 
� executado, quando o tipo de libera��o � '2' (por pedido), quando o pedido � liberado, ap�s sua libera��o.

/*/
User function MA450PED()

	Local _lOk := .T.
	                    
	If _lOk
		
		IF SC5->C5_TIPO == 'N' // Raphael F. Ar�ujo 25/11/2016
			U_CAMBR01("SC5")
		ENDIF
		
	Endif 

return