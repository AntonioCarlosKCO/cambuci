#Include "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � TITICMST �Autor � Julio Furlan Reis   � Data �  17/09/2012 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada utilizado na gera��o do titulo a pagar    ���
���          � do imposto.                                                ���
���          � utilizado para alterada a data de vencimento do Titulo     ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 10 - 			                 		          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function TITICMST()

Local	cOrigem	:= PARAMIXB[1]
Local	cTipoImp	:= PARAMIXB[2]
Local	_dDataVc	:= DataValida(dDataBase,.T.)

If AllTrim(cTipoImp) == '3' // ICMS ST	
  	  
	SE2->E2_VENCTO 	:= _dDataVc  
	SE2->E2_VENCREA := _dDataVc

EndIf

Return {SE2->E2_NUM,_dDataVc}

