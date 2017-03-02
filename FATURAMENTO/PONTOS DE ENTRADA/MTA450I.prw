#include 'protheus.ch'

/*/{Protheus.doc} MTA450I
@author Raphael Araújo
@since 27/10/2016
@version 1.0

@OBS PONTO DE ENTRADA APOS ATUALIZACAO DA LIBERACAO DO PEDIDO 
Executado apos atualizacao da liberacao de pedido.

/*/

User function MTA450I 

	Local _lOk := .T.
	
	// TRATAMENTO PARA SÓ IMPRIMIR O ROMANEIO NO ÚLTIMO ITEM DA SC9 - DJALMA BORGES 04/01/2017 - INÍCIO
	
	Local lUltItem := .F.
	
	Local aAreaSC9 := SC9->(GetArea())
	
	SC9->(dbSkip(-1)) // Utilizando SC9->(dbSkip()), SC9->(dbSkip(1)) e SC9->(dbSkip(+1)) o registro não avançou
	SC9->(dbSkip(+2)) // Esta foi a única forma encontrada de mandar para o próximo registro
	If SC9->(C9_FILIAL + C9_PEDIDO) <> SC5->(C5_FILIAL + C5_NUM) .or. SC9->(EOF())
		lUltItem := .T.
	EndIf
	SC9->(dbSkip(-1))
	
	RestArea(aAreaSC9)
	
	// TRATAMENTO PARA SÓ IMPRIMIR O ROMANEIO NO ÚLTIMO ITEM DA SC9 - DJALMA BORGES 04/01/2017 - FIM
	                    
	If _lOk
		IF SC5->C5_TIPO == 'N' .and. lUltItem == .T. // Raphael F. Aráujo 25/11/2016
			U_CAMBR01("SC5")
		ENDIF // ---
	Endif 

return