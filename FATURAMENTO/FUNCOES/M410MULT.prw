#Include 'Protheus.ch'
#Include 'Totvs.ch'
/*--------------------------------------------------------------------
{Protheus.doc} M410MULT

Efetua o Cálculo de Quantidade de Vendas Múltiplas

@author 	Carlos Eduardo Saturnino - Alfa ERP
@since 	28/09/2016
@param		nQuant -> C6_QTDVEN
			nMult	-> B1_QE

			Criar gatilho
			Campo	C6_QTDVEN
			Cdom	C6_QTDVEN
			Regra	U_M410MULT(M->C6_QTDVEN, SB1->B1_QE)
@version 	1.0
------------------------------------------------------------------- */
User Function M410MULT(nQuant,nMult)

	Local nRet := nQuant
	
	// Colocado tratativa no Gatilho C6_QTDVEN 001 
	//IF M->C5_TIPO == 'N' .OR. ReadVar() == "M->UB_QUANT"// -- Raphael F. Araújo 18/11/2016 - Regra deve ser aplicada apenas para pedidos tipo 'Normal'.
	
	If !Empty(nMult) 
		// Verifico se existe resto
		If Mod(nQuant,nMult) > 0
			// Se a divisão for menor que 1
			If (nQuant / nMult) <=  1
				nRet := nMult
			//Se a divisão for maior que 1
			Else
				nRet := Int(nQuant/nMult) + 1
				nRet := (nRet * nMult)
			Endif
		Endif
	Endif

//	ELSE
//		nRet := M->C6_QTDVEN	
//	ENDIF // -- 

Return (nRet)