#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MT241GRV � Autor � Raphael F. Ara�jo 	  � Data � 19.12.2016 ���
�������������������������������������������������������������������������Ĵ��
��� LOCALIZA��O :  fun��o A241GRAVA (Grava��o do movimento) 			   ��
��� EM QUE PONTO : Ap�s a grava��o dos dados (aCols) no SD3, e tem a 	   ��
��� finalidade de atualizar algum arquivo ou campo.						   ��
��� Envia vetor com os par�metros:										   ��
��� PARAMIXB[1] = N�mero do Documento									   ��
��� PARAMIXB[2] = Vetor bidimensional com nome campo/valor do campo		   �� 
��� (somente ser� enviado se o Ponto de Entrada MT241CAB for utilizado).   ��
�������������������������������������������������������������������������Ĵ��
/*/

User Function MT241GRV()

	Local lRet 	:= .T.
	_aObs 		:= Nil
	
Return lRet
