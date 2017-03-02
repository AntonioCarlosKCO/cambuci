#include 'protheus.ch'

/*/{Protheus.doc} MTA455P
@author Raphael Araújo
@since 28/10/2016
@version 1.0

@OBS VALIDA LIBERACAO DE ESTOQUE 
Executado apos liberacao do estoque, e impede a liberacao dependendo do retorno. Veja retorno.

/*/
User function MTA455P 

	Local _lOk := .T.
	Local aArea := {}	
	
	aArea := getArea()
		
    If SC6->C6_QTDVEN <> SC6->C6_QTDLIB
    	alert("Não é permitido liberação parcial. Favor liberar quantidade total! - M410PVNF")
    	_lOk := .F. 
    Endif
                            
	If _lOk
		If SC5->C5_TIPO == 'N' // Raphael F. Aráujo 25/11/2016
			U_CAMBR01("SC5")
		Endif
	Endif 

return _lOk