#INCLUDE "PROTHEUS.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � VALSF1   �Autor  �Ricardo Bessa       � Data �  18/04/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Gatilho para preencher zeros a esquerda no Documento de   ���
���          �  Entrada.                                                  ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function VALSF1()

Local nDoc := 0

If INCLUI
	nDoc := Val(M->F1_DOC)
	CNFISCAL := StrZero(nDoc,9)
EndIf
                          
Return (.T.)

