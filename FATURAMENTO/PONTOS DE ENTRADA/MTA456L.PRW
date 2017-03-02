#Include 'Protheus.ch'

/************************************************************
Ponto de entrada executado após a gravação de todas as 
liberações do pedido de vendas (Liberação Manual) tabela SC9.
*************************************************************/

User Function MTA456L()

	If SC5->C5_TIPO == 'N' // Raphael F. Aráujo 25/11/2016
		U_CAMBR01("SC5")
	Endif

Return

