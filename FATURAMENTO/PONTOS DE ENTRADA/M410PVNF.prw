#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �M410PVNF � Autor � Raphael Ara�jo 	  � Data � 17.10.2016 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Ponto de entrada para valida��o.							  ���
���			   Executado antes da rotina de gera��o de NF's (MA410PVNFS). ���
�������������������������������������������������������������������������Ĵ��
/*/

User Function M410PVNF()

	//Local cDtSrv	:= Date()
	//Local cDtUsr	:= dDatabase
	//Local aArea := {}
	Local lCont	:= .T.
	
	/*
	If cDtUsr <> cDtSrv
		Alert("A data-base de seu sistema difere da data-base do servidor, por isso a NF n�o poder� ser gerada! Saia do sistema ou ajuste sua data-base! Data-base do Servidor "+DTOC(cDtSrv))
		lCont	:= .F.
	EndIf		
	*/
 	
 	dbselectarea("SC6")
	DbSetOrder(1)
	dbSeek(xfilial('SC6')+C6_ITEM+SC6->C6_NUM)
     
    If SC6->C6_QTDVEN <> SC6->C6_QTDLIB
    	alert("N�o � permitido libera��o parcial. Favor liberar quantidade total! - M410PVNF")
    	lCont := .F. 
    Endif
      	
Return lCont