#INCLUDE "RWMAKE.CH"                         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � C7PROD   � Autor � JOSMAR CASTIGLIONI    � Data � 10/02/16 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � confirma��o do item do pedido de compras, verifica         ���
���Descri��o � se o produto j� n�o foi digitado em outro item             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Compras - Cambuci                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
					IF MSGYESNO("O PRODUTO J� EXISTE NO PEDIDO, DESEJA ACUMULAR ?")
						MSGALERT("POSICIONE N0 ITEM "+ACOLS[nZ,nPosIte]+" DO PEDIDO PARA AS ALTERA��ES DESEJADAS")
						aCols[len(aCols)][ len(aHeader)+1 ] := .T.
					ELSE
						MSGALERT("LIBERADA A INCLUS�O DO PRODUTO")
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
					IF MSGYESNO("O PRODUTO J� EXISTE NO PEDIDO, DESEJA ACUMULAR ?")
						MSGALERT("POSICIONE N0 ITEM "+aCols[nZ,nPosIte]+" DO PEDIDO PARA AS ALTERA��ES DESEJADAS")
						IF N == Len(aCols)
							aCols[len(aCols)][ len(aHeader)+1 ] := .T.
						ELSE
							lRet := .F.
						ENDIF
					ELSE
						MSGALERT("LIBERADA A INCLUS�O DO PRODUTO")
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	Next nZ
ENDIF

RESTAREA(aAREA)

Return(lRet)                                   
