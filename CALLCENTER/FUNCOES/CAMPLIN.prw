#Include 'Protheus.ch'
#Include "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SANPLIN  �SYMM Consultoria           �  14/01/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza o pulo automatico da linha conforme informado o     ���
���          �produto                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � Santil                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CAMPLIN()

	Local aArea		:= GetArea()
	Local cCpo		:= ReadVar()
	Local nPosQtd 	:= GdFieldPos('UB_QUANT')
	Local nPosProd 	:= GdFieldPos('UB_XCODREF')
	Local nLin		:= oGetTlv:oBrowse:nAt
	Local cProduto	:= IIF(cCpo == "M->UB_PRODUTO", M->UB_PRODUTO, GdFieldGet('UB_PRODUTO'))

	//��������������������Ŀ
	//�Se campo quantidade �
	//����������������������
	If cCpo == "M->UB_QUANT"

		//������������������������������������������Ŀ
		//�Se conter quantidade preenchida pula linha�
		//��������������������������������������������
		If !Empty(M->UB_QUANT) .AND. !IsInCallStack("U_CTMK001")
			oGetTlv:oBrowse:bEditCol := {|| U_MAG01ADDL() }
		EndIf

		//����������������Ŀ
		//�Se campo produto�
		//������������������
	ElseIf (cCpo == "M->UB_XCODREF" .OR. cCpo == "M->UB_PRODUTO") .AND. !IsInCallStack("U_CTMK001")

		//��������������������������Ŀ
		//�Edita coluna da qunatidade�
		//����������������������������
		oGetTlv:oBrowse:bEditCol := {|| MalFatEdit(nLin,nPosQtd) }
	EndIf

	//�����������������������������������������Ŀ
	//�Atualiza dados da tela de pedido de venda�
	//�������������������������������������������
	oGetTlv:oBrowse:Refresh()
	//oGetTlv:ForceRefresh()

	RestArea(aArea)
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MAG01ADDL �Autor  �SYMM Consultoria           �  14/01/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza o pulo automatico da linha conforme informado o     ���
���          �produto                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � Santil                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MAG01ADDL()

	Local nPosQtd 	:= GdFieldPos('UB_QUANT')
	Local nPosProd 	:= GdFieldPos('UB_XCODREF')
	Local nPosCod 	:= GdFieldPos('UB_PRODUTO')
	Local nLin		:= oGetTlv:oBrowse:nAt
	Local aLoc		:= {}
	Local nQtdSel	:= 0

	oGetTlv:AddLine()
	oGetTlv:oBrowse:ColPos 	:= nPosProd
	oGetTlv:oBrowse:nColPos := nPosProd

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MalFatEdit�Autor  �SYMM Consultoria           �  14/01/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �Edita celula de quantidade apos informar o produto          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Santil                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MalFatEdit(nLin,nPosQtd)

	oGetTlv:oBrowse:ColPos := nPosQtd
	oGetTlv:oBrowse:nColPos := nPosQtd

	oGetTlv:oBrowse:bEditCol := {|| }

	//oGetTlv:EditCell(oGetTlv:oBrowse,nLin,oGetTlv:oBrowse:ColPos)

Return .T.