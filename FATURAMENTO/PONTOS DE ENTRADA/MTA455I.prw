#include 'protheus.ch'

/*/{Protheus.doc} MTA455I
@author Raphael Araújo
@since 27/10/2016
@version 1.0

@OBS PONTO DE ENTRADA APOS GRAVAR LIBERACAO DE ESTOQUE 
Executado apos atualizacao dos arquivos na liberacao de estoque

/*/
User function MTA455I()
	Local _lOk := .T.
	                    
	If _lOk
		If SC5->C5_TIPO == 'N' // Raphael F. Aráujo 25/11/2016
			U_CAMBR01("SC5")
		Endif
	Endif 

return