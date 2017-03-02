#Include 'protheus.ch'

/*/{Protheus.doc} MT410INC
@author totvs
@since   
@version P12
@param
@obs
@Este ponto de entrada pertence � rotina de pedidos de venda, MATA410(). 
@Est� localizado na rotina de altera��o do pedido, A410INCLUI(). 
@� executado ap�s a grava��o das informa��es.
@return
/*/

User Function MT410INC()
	Local _aArea := GetArea()
	                
	U_ENVROMA()
	
	RestArea(_aArea)
Return

/*/{Protheus.doc} EnvRoma
//VERIFICA SE TEM LIBERA��O PARA ENVIAR ROMANEIO
@author totvsremote
@since 11/01/2016
@version 

@type function
/*/

User Function EnvRoma()
	Local _lOk := .F.
	
	SC9->(dbSetOrder(1))
	SC9->(dbSeek(xfilial('SC9')+SC5->C5_NUM))
	
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(dbSeek(xfilial('SC5')+SC5->C5_NUM))
	
	While ! SC9->(eof()) .and. SC9->(C9_FILIAL + C9_PEDIDO) == SC5->(C5_FILIAL + C5_NUM)
	                  
		if empty(SC9->C9_BLEST) .and. empty(SC9->C9_BLCRED)
			_lOk := .t.
			exit
		Endif	
	
		SC9->(dbSkip())
	
	End
	                    
	If _lOk
		IF SC5->C5_TIPO == 'N' // Raphael F. Ara�jo 25/11/2016 
			U_CAMBR01("SC5")
		ENDIF
	Endif

Return