#INCLUDE "RWMAKE.CH"                         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ C7PROD   ³ Autor ³ JOSMAR CASTIGLIONI    ³ Data ³ 10/02/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ confirmação do item do pedido de compras, verifica         ³±±
±±³Descri‡„o ³ se o produto já não foi digitado em outro item             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Compras - Cambuci                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function  C7PROD()

Local nZ      := 0
Local aAREA   := GETAREA()
Local nPosPrd := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PRODUTO'})
LocaL nPosIte := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_ITEM'})
Local lRet    := .T.
Local _cPed   := ""

IF INCLUI
	IF Len( aCols ) > 1
		_cProd  := ACOLS[N,nPosPrd]
		For nZ := 1 To (Len( aCols )-1)
			IF ( !aCols[nZ][Len(aCols[nZ])] .And. !Empty(aCols[nZ][nPosPrd]) )
				IF ACOLS[nZ,nPosPrd] == _cProd
					IF MSGYESNO("O PRODUTO JÁ EXISTE NO PEDIDO, DESEJA ACUMULAR ?")
						MSGALERT("POSICIONE N0 ITEM "+ACOLS[nZ,nPosIte]+" DO PEDIDO PARA AS ALTERAÇÕES DESEJADAS")
						aCols[len(aCols)][ len(aHeader)+1 ] := .T.
					ELSE
						MSGALERT("LIBERADA A INCLUSÃO DO PRODUTO")
					ENDIF
				ENDIF
			ENDIF
		Next nZ
	ENDIF
ELSEIF ALTERA
	_cProd  := ACOLS[N,nPosPrd]
	For nZ := 1 To Len( aCols )
		IF ( !aCols[nZ][Len(aCols[nZ])] .And. !Empty(aCols[nZ][nPosPrd]) )
			IF N<>nZ
				IF ACOLS[nZ,nPosPrd] == _cProd
					IF MSGYESNO("O PRODUTO JÁ EXISTE NO PEDIDO, DESEJA ACUMULAR ?")
						MSGALERT("POSICIONE N0 ITEM "+aCols[nZ,nPosIte]+" DO PEDIDO PARA AS ALTERAÇÕES DESEJADAS")
						IF N == Len(aCols)
							aCols[len(aCols)][ len(aHeader)+1 ] := .T.
						ELSE
							lRet := .F.
						ENDIF
					ELSE
						MSGALERT("LIBERADA A INCLUSÃO DO PRODUTO")
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	Next nZ
ENDIF

RESTAREA(aAREA)

Return(lRet)                                   
