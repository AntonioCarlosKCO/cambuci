#Include 'Protheus.ch'

/************************************************************
Ponto de entrada executado ap�s a grava��o de todas as 
libera��es do pedido de vendas (Libera��o Manual) tabela SC9.
*************************************************************/

User Function MTA456L()

	If SC5->C5_TIPO == 'N' // Raphael F. Ar�ujo 25/11/2016
		U_CAMBR01("SC5")
	Endif

Return

