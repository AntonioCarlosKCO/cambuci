#INCLUDE 'RWMAKE.CH'
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M461VTOT � Autor � TI0607 - Almir Bandina� Data � 19.11.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida geracao de nota para cliente suspenso.              ���
�������������������������������������������������������������������������Ĵ��
���Solic.    � Rodrigo.                                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � M460MARK                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Sem parametros.                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Ponto de Entrada na geracao da nota fiscal.                ���
�������������������������������������������������������������������������Ĵ��
���UpDate    � Matricula-Nome-Data-Solicitante                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function  M461VTOT()

	_cArea:=GetArea()
	
	// Raphael F. Ara�jo 25/11/2016 - Inclu�do SelectArea SC5, e tratamento no campo C5_TIPO - �nicio
	dbselectarea("SC5")	
	SC5->(DbSetOrder(1))
	DbSeek(xFilial()+SC9->C9_PEDIDO)
          
	IF !(SC5->C5_TIPO $ 'DB')
		dbselectarea("SA1")	
		DbSetOrder(1)
		DbSeek(xFilial()+SC9->C9_CLIENTE+SC9->C9_LOJA)//.T.)
	ELSE
		dbselectarea("SA2")	
		DbSetOrder(1)
		DbSeek(xFilial()+SC9->C9_CLIENTE+SC9->C9_LOJA)//.T.)
	ENDIF
	// ------ T�rmino
    IF Found()
    	// REGRA DE DESCONTO ESPECIAL ADAPTADA PARA DESCONTO NOS ITENS DO PEDIDO - DJALMA BORGES 20/02/2017 - IN�CIO
    	If Posicione('SC5',1,xFilial('SC5')+SC9->C9_PEDIDO,'C5_DESC1') > 0
       	
     		IF !(SC5->C5_TIPO $ 'DB') // Raphael F. Ara�jo - Inclu�do IF para tratatamento Cliente/Fornecedor.
    			MsgBox("Cliente: " +AllTrim(SA1->A1_NREDUZ)+ " - Pedido: "+SC9->C9_PEDIDO+" com Desconto nos Itens de (" + Transform(SC5->C5_DESC1,'@E 999.99') + "). ","ATENCAO","ALERT")
    		ELSE
    			MsgBox("Fornecedor: " +AllTrim(SA2->A2_NREDUZ)+ " - Pedido: "+SC9->C9_PEDIDO+" com Desconto nos Itens de (" + Transform(SC5->C5_DESC1,'@E 999.99') + "). ","ATENCAO","ALERT")
    		ENDIF
         
    		_nTotBru:=0
			
			If SC6->(DbSeek(xFilial('SC6')+SC5->C5_NUM))
			   
			 	While SC6->(!EOF()) .and. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)
					RecLock('SC6',.F.) 
					SC6->C6_XDESITE := SC5->C5_DESC1
			        SC6->C6_XPRCITE := SC6->C6_PRUNIT
			        SC6->C6_XTOTITE := SC6->(C6_QTDVEN*C6_PRUNIT)
					SC6->C6_PRUNIT 	:= SC6->C6_PRCVEN
			        SC6->C6_VALOR   := SC6->(C6_QTDVEN*C6_PRCVEN)
					SC6->(MsUnlock())

			        _nTotBru += SC6->C6_XTOTITE
			        
				    SC6->(DbSkip())
			   Enddo
			   
			   Reclock('SC5',.F.)
			   SC5->C5_DESC1 := 0
	           SC5->C5_XTOTITE := _nTotBru
	           SC5->(MsUnlock())  
			Endif
            
            RecLock("SC9",.F.)
            SC9->C9_OK := Space(2) //Spac(2) Raphael Ara�jo 20/10/2016
            MsUnLock()
        EndIf
        // REGRA PARA DESCONTO ESPECIAL ADAPTADA PARA DESCONTO NOS ITENS DO PEDIDO - DJALMA BORGES 20/02/2017 - FIM
        
        // CAMPO PARA DESCONTO ESPECIAL SUBSTITU�DO DE C5_DESC1 PARA C5_DESC2 - DJALMA BORGES 20/02/2017 - IN�CIO
        If Posicione('SC5',1,xFilial('SC5')+SC9->C9_PEDIDO,'C5_DESC2') > 0
       	
     		IF !(SC5->C5_TIPO $ 'DB') // Raphael F. Ara�jo - Inclu�do IF para tratatamento Cliente/Fornecedor.
    			MsgBox("Cliente: " +AllTrim(SA1->A1_NREDUZ)+ " - Pedido: "+SC9->C9_PEDIDO+" com Desconto Especial (" + Transform(SC5->C5_DESC2,'@E 999.99') + "). ","ATENCAO","ALERT")
    		ELSE
    			MsgBox("Fornecedor: " +AllTrim(SA2->A2_NREDUZ)+ " - Pedido: "+SC9->C9_PEDIDO+" com Desconto Especial (" + Transform(SC5->C5_DESC2,'@E 999.99') + "). ","ATENCAO","ALERT")
    		ENDIF // ----- T�rmino
         
    		_nTotBru:=0
			
			If SC6->(DbSeek(xFilial('SC6')+SC5->C5_NUM))
			   
			 	While SC6->(!EOF()) .and. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)
					RecLock('SC6',.F.) 
					SC6->C6_XDESESP := SC5->C5_DESC2
			        SC6->C6_XPRCESP := SC6->C6_PRUNIT
			        SC6->C6_XTOTESP := SC6->(C6_QTDVEN*C6_PRUNIT)
					SC6->C6_PRUNIT 	:= SC6->C6_PRCVEN
			        SC6->C6_VALOR := SC6->(C6_QTDVEN*C6_PRCVEN)
					SC6->(MsUnlock())

			        _nTotBru += SC6->C6_XTOTESP
			        
				    SC6->(DbSkip())
			   Enddo
			   
			   Reclock('SC5',.F.)
			   SC5->C5_DESC2 := 0
	           SC5->C5_XTOTESP := _nTotBru
	           SC5->(MsUnlock())  
			Endif
            
            RecLock("SC9",.F.)
            SC9->C9_OK := Space(2) //Spac(2) Raphael Ara�jo 20/10/2016
            MsUnLock()
        EndIf
        // CAMPO PARA DESCONTO ESPECIAL SUBSTITU�DO DE C5_DESC1 PARA C5_DESC2 - DJALMA BORGES 20/02/2017 - FIM
      
    ELSE    	
    	MsgBox(" Cliente n�o encontrado!","ATENCAO","ALERT")
    ENDIF
      
      DbSelectArea("SC9")
      RestArea(_cArea) 
                           
Return(.T.)
