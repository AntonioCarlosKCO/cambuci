#include 'protheus.ch'
#include 'parmtype.ch'

// DJALMA BORGES 02/12/2016
// FUNÇÃO CHAMADA NA VALIDAÇÃO DO CAMPO C5_XTOTPV1 PARA MOSTRAR O TOTAL DO PEDIDO SEM IMPOSTOS

User Function CALCTPED()

	Local nTotPed1 := 0
	Local aAreaSC6 := SC6->(GetArea())
	Local cNumPed := ""
	
	If IsInCallStack('U_CAMBC002')
		SC5->(dbSetOrder(1))
		SC5->(dbSeek(xFilial("SC5") + TRB->C5_NUM))
		cNumPed := TRB->C5_NUM
	Else
		cNumPed := SC5->C5_NUM
	EndIf
	
	SC6->(dbSetOrder(1))
	SC6->(dbSeek(xFilial("SC6") + cNumPed))
	While SC6->(C6_FILIAL + C6_NUM) == xFilial("SC6") + cNumPed .and. SC6->(!EOF())
	
		nTotPed1 := nTotPed1 + (SC6->C6_PRCVEN * SC6->C6_QTDVEN) // VALOR DO PEDIDO SEM IMPOSTOS
		
		SC6->(dbSkip())
	
	EndDo
	
	RestArea(aAreaSC6)
	
Return nTotPed1