
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PRODFOR   �Autor  �Microsiga           � Data �  05/02/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function ProdFor()
	
	Local aArea := GetArea()
	
	SA2->(dbSetOrder(1))
	//SA2->(dbSeek(xFilial("SA2")+cA120Forn))
	SA2->(dbSeek(xFilial("SA2")+cA100For+cLoja)) // DJALMA BORGES 11/01/2017
	
	//aCols[1,GDFieldPos("C7_PRODUTO")] := SA2->A2_PRODUTO
	//M->C7_PRODUTO := aCols[1,GDFieldPos("C7_PRODUTO")]
	
	aCols[1,GDFieldPos("D1_COD")] := SA2->A2_PRODUTO
	M->D1_COD := aCols[1,GDFieldPos("D1_COD")]
	
	_oDlgDefault := GetWndDefault()
	aEval(_oDlgDefault:aControls,{|x| x:Refresh()})
	
	__ReadVar := "M->D1_COD"
		
	RunTrigger(2,1)
	
	RestArea(aArea)

Return .T.
