#include 'protheus.ch'

/*/{Protheus.doc} MA450PED
@author Raphael Araújo
@since 27/10/2016
@version 1.0

@OBS Este ponto pertence à rotina de liberação de crédito, MATA450(). 
Está localizado no processamento da avaliação automática de crédito por pedido, MA450PROCES(). 
É executado, quando o tipo de liberação é '2' (por pedido), quando o pedido é liberado, após sua liberação.

/*/
User function MA450PED()

	Local _lOk := .T.
	                    
	If _lOk
		
		IF SC5->C5_TIPO == 'N' // Raphael F. Aráujo 25/11/2016
			U_CAMBR01("SC5")
		ENDIF
		
	Endif 

return