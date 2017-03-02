#INCLUDE "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CONTAPAI  � Autor � WALDIR ARRUDA          DATA�  31/01/12   ���
�������������������������������������������������������������������������͹��
���Descricao �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BUSCA CGC DO T�TULO PAI DOS IMPOSTOS                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CONTAPAI()
Local aAreaA2	:= SE2->(GetArea())
Local nTamTit 	:= TamSX3("E2_PREFIXO")[01] + TamSX3("E2_NUM")[01] + TamSX3("E2_PARCELA")[01] + TamSX3("E2_TIPO")[01]
Local nTamFor	:= TamSx3("E2_FORNECE")[01] + TamSx3("E2_LOJA")[01]
Local cTitPai	:= SE2->E2_TITPAI
Local cChave	:= ""
Local cRetorno	:= ""


If !Empty(SE2->E2_TITPAI)
	
	cChave := xFilial("SA2") + Substr(cTitPai, nTamTit, nTamFor)
	
	DbSelectarea("SA2")
	SA2->(DbSetorder(1))
	If SA2->(DbSeek(cChave))
		cRetorno := SA2->A2_CONTA
	EndIf                        
	
Else
	
	DbSelectarea("SA2")
	SA2->(DbSetorder(1))
	If SA2->(DbSeek(cChave))
		cRetorno := SA2->A2_CONTA
	EndIf                        
	
EndIf

RestArea(aAreaA2)

Return cRetorno