#include 'protheus.ch'
#include 'parmtype.ch'

// DJALMA BORGES 02/12/2016
// FUN��O CHAMADA NA VALIDA��O DO CAMPO C5_XTOTPV1 PARA MOSTRAR O TOTAL DO PEDIDO COM IMPOSTOS

User Function CALCTPIM()
	
	Local nDesconto 	:= 0 
	Local nTotalNF		:= 0
	Local nItem 		:= 0
	Local nTotPed2		:= 0
	Local aAreaSC6 := SC6->(GetArea())
	Local cNumPed := ""
	
	// FUN��O INTERNA MAFIS() DA TOTVS
	// PODE PRECISAR DE AJUSTE NO C�DIGO CASO HAJA MUDAN�A DE LEGISLA��O QUE OCASIONE EM NOVOS PAR�METROS A SEREM PASSADOS NA FUN��O
	// UTILIZAR A PLANILHA FINANCEIRA NAS A��ES RELACIONADAS DO PEDIDO DE VENDA (PADR�O DO PROTHEUS) PARA COMPARAR OS VALORES EM CASO DE D�VIDA
	
	If IsInCallStack('U_CAMBC002')
		SC5->(dbSetOrder(1))
		SC5->(dbSeek(xFilial("SC5") + TRB->C5_NUM))
		cNumPed := TRB->C5_NUM
	Else
		cNumPed := SC5->C5_NUM
	EndIf
	
	MaFisIni(SC5->C5_CLIENTE,; 	// 1-Codigo Cliente/Fornecedor
	SC5->C5_LOJACLI,; 			// 2-Loja do Cliente/Fornecedor
	"C",; 						// 3-C:Cliente , F:Fornecedor
	SC5->C5_TIPO,; 				// 4-Tipo da NF
	SC5->C5_TIPOCLI,; 			// 5-Tipo do Cliente/Fornecedor
	nil,; 						// 6-Relacao de Impostos que suportados no arquivo
	,; 							// 7-Tipo de complemento
	,; 							// 8-Permite Incluir Impostos no Rodape .T./.F.
	"SB1",; 					// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
	"U_CAMBC002") 				// 10-Nome da rotina que esta utilizando a funcao 
	
	aAreaSC6 := SC6->(GetArea())
	
	//dbSelectArea("SC6")
	SC6->(dbSetOrder(1))
	SC6->(dbSeek(xFilial("SC6") + cNumPed))
	While SC6->(C6_FILIAL + C6_NUM) == xFilial("SC6") + cNumPed .and. SC6->(!EOF())
	
		nItem ++
		
		MaFisAdd(SC6->C6_PRODUTO,; 	// 1-Codigo do Produto ( Obrigatorio )
		SC6->C6_TES,;				// 2-Codigo do TES ( Opcional )
		SC6->C6_QTDVEN,;			// 3-Quantidade ( Obrigatorio )
		SC6->C6_PRCVEN,;			// 4-Preco Unitario ( Obrigatorio )
		nDesconto,; 				// 5-Valor do Desconto ( Opcional )
		nil,;						// 6-Numero da NF Original ( Devolucao/Benef )
		nil,;						// 7-Serie da NF Original ( Devolucao/Benef )
		nil,;						// 8-RecNo da NF Original no arq SD1/SD2
		0,;							// 9-Valor do Frete do Item ( Opcional )
		0,; 						// 10-Valor da Despesa do item ( Opcional )
		0,; 						// 11-Valor do Seguro do item ( Opcional )
		0,;							// 12-Valor do Frete Autonomo ( Opcional )
		SC6->C6_VALOR+ nDesconto,;	// 13-Valor da Mercadoria ( Obrigatorio )
		0,;							// 14-Valor da Embalagem ( Opcional )
		0,;							// 15-RecNo do SB1
		0) 							// 16-RecNo do SF4 
		
		nTotPed2 := MaFisRet(,'NF_TOTAL') 						 // VALOR DO PEDIDO COM IMPOSTOS
		
		SC6->(dbSkip())
	
	EndDo
	
	MaFisEnd()
	
	RestArea(aAreaSC6)
	
Return nTotPed2