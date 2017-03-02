#Include 'Protheus.ch'
#Include "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VALIDPED   �SYMM Consultoria            �  14/01/16         ���
�������������������������������������������������������������������������͹��
���Desc.     �Fun��o para validar se j� existe pedido atrelado ao item do ���
���          �callcenter, para colocar na valida��o de campo              ���
�������������������������������������������������������������������������͹��
���Uso       � Cambuci                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function VALIDPED()
	local lRet 		:= .T.
	local nPosItem 	:= 0
	
	If Altera
		nPosItem 	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "UB_ITEM"})
		
		DBSELECTAREA("SUB")
		DBSETORDER(1)
	
		IF SUA->UA_OPER == "1" .AND. DBSEEK(XFILIAL("SUB") + SUA->UA_NUM + aCols[n][nPositem])
			IF ALLTRIM(SUB->UB_ITEMPV) <> ""
	    		lRet := .F.
	    	ENDIF
		ENDIF
	EndIf
RETURN lRet