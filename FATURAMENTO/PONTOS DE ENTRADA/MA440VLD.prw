#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MA440VLD � Autor � Raphael Ara�jo 	  � Data � 17.10.2016 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Valida��o na liberacao do pedido de vendas	              ���
�������������������������������������������������������������������������Ĵ��
/*/

User Function MA440VLD()

	Local lCont := .T.
	//Local aArea := {}

	dbselectarea("SC6")
	DbSetOrder(1)
	dbSeek(xfilial('SC6')+C6_ITEM+SC6->C6_NUM)
	//aArea := getArea()
     
    If SC6->C6_QTDVEN <> M->C6_QTDLIB
    	alert('N�o � permitido libera��o parcial. Favor liberar quantidade total! - MA440VLD')
    	lCont := .F. 
    Endif
      
    //restArea(aArea)

Return lCont