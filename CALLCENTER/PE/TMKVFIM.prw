#Include 'rwmake.ch'

#DEFINE _CRLF CHR(13) + CHR(10)

/*/{Protheus.doc} TMKVFIM
Atualização de informacoes especificas na gravacao do Televendas para o Faturamento 

/*/

User Function TMKVFIM(cNumSUA, cNumSC5)

	Local lBloqCre	:= .F. 		 	// Bloqueio de Credito            
	Local lBloqEst	:= .F.			// Bloqueio de Estoque            
	Local lAvalCre 	:= .T.			// Avaliacao de Credito                              
	Local lAvalEst	:= .T.			// Avaliacao de Estoque    
	Local lEstBlq	:= .F.			// Controle para verificar se estoque foi liberado ou está bloqueado.
	Local lCredBlq	:= .F.			// Controle para verificar bloqueio de crédito foi liberado ou está bloqueado.
	Local cBlCred	:= ""			// Tipo de bloqueio de Crédito
	Local aEmpenho	:= {}
	Local nVlrCred	:= 0 
	Local cSeqOrc	:= "000"
	Local lImpRomAnt := .F. // DJALMA BORGES 18/01/2017
	Local cSeqAnt := ""
	
	DbSelectArea("SUB")
	SUB->(DbSetOrder(1))

	If SUB->(DbSeek(xFilial("SUB")+cNumSUA))

		BEGIN TRANSACTION
			While SUB->UB_FILIAL	==	xFilial("SUB")	.AND.;
			SUB->UB_NUM		==	cNumSua			.And. 	SUB->(!Eof())

				DbSelectArea("SC6")
				SC6->(DbSetOrder(1))
				If SC6->(DbSeek(xFilial("SC6") + cNumSC5 + SUB->UB_ITEMPV + SUB->UB_PRODUTO))
					RecLock("SC6",.F.)
					SC6->C6_PRCVEN		:=  SUB->UB_VRUNIT
					SC6->C6_PRUNIT		:=  SUB->UB_VRUNIT
					SC6->C6_QTDLIB		:= 	SC6->C6_QTDVEN
					SC6->C6_VALOR		:=  (SUB->UB_VRUNIT*SC6->C6_QTDVEN)
					SC6->C6_XCODREF		:=	SUB->UB_XCODREF
					SC6->(MsUnlock())
					SC6->(DbCommit())

					MaLibDoFat(SC6->(RecNo()), SC6->C6_QTDLIB , lBloqCre , lBloqEst,lAvalCre	,lAvalEst	,.F.	,.F.,NIL,NIL,NIL,NIL,NIL,0)

					If SC9->C9_FILIAL == SC6->C6_FILIAL .AND. SC9->C9_PEDIDO == SC6->C6_NUM .AND. SC9->C9_ITEM == SC6->C6_ITEM 
						lLiberado	:= .T.

						If SC9->C9_BLEST == "02"
							lEstBlq	:= .T.
							ConOut("[TMKVFIM] ERRO - NAO FOI POSSIVEL EFETUAR RESERVA DE MATERIAL:"+xFilial("SC6")+"/"+cNumSC5)
						EndIf
						If ALLTRIM(SC9->C9_BLCRED) <> ""
							lCredBlq	:= .T.
							ConOut("[TMKVFIM] ERRO - NAO FOI POSSIVEL EFETUAR RESERVA DE MATERIAL:"+xFilial("SC6")+"/"+cNumSC5)
						EndIf

		                If !Empty(SUB->UB_XSEQ)
		                	cSeqOrc := AllTrim(SUB->UB_XSEQ)
		                Else
							RecLock("SUB", .F.)
								If lImpRomAnt == .F. // DJALMA BORGES 18/01/2017
									If Empty(cSeqAnt) // DJALMA BORGES 20/01/2017
										SUB->UB_XSEQ := cSeqOrc
									Else
										SUB->UB_XSEQ := cSeqAnt // DJALMA BORGES 20/01/2017
									EndIf
								Else
									SUB->UB_XSEQ := Soma1(cSeqOrc) 
									cSeqAnt := SUB->UB_XSEQ // DJALMA BORGES 20/01/2017
								EndIf	
							MsUnlock()
						EndIf
					Else
						ConOut("[TMKVFIM] ERRO - NAO FOI POSSIVEL ENCONTRAR SC9")
					EndIf

				Endif
				lImpRomAnt := SC6->C6_XROMANE // DJALMA BORGES 18/01/2017
				SUB->(DbSkip())
			Enddo

			//lCredBlq := !MaAvalCred(SUA->UA_CLIENTE, SUA->UA_LOJA , SUA->UA_VLRLIQ, SUA->UA_MOEDA, .T. ,@cBlCred,@aEmpenho,@nVlrCred)

			//Apresenta na tela o número do pedido de vendas gerado.
			MsUnlockAll()

			DbSelectArea("SC5")
			dbsetorder(1)
			
			If SC5->(DbSeek(xFilial("SC5")+cNumSC5))

				RECLOCK("SC5",.F.)
				SC5->C5_XOPER 		:= SUA->UA_XTPOPER
				SC5->C5_XTIPOPV		:= SUA->UA_XTIPOPV
				SC5->C5_VEND2		:= SUA->UA_VEND2

				If !Empty(SUA->UA_CODOBS)
					SC5->C5_ZZOBS		:= MSMM(SUA->UA_CODOBS,TamSx3("UA_OBS")[1])
				EndIf

				If lLiberado
					SC5->C5_LIBEROK	:= "S"
				EndIf
				/*			If lCredBlq
				SC5->C5_BLQ	:= "1"
				ENDIF
				*/			
				
				MSUNLOCK()
				/*
				//Realiza imrpessão do romaneio automatico, caso o estoque e credito estejam liberados
				IF !lEstBlq .and. !lCredBlq 
					IF SC5->C5_TIPO == 'N' // Raphael F. Araújo 25/11/2016 
						U_CAMBR01("SC5")
					ENDIF
				ENDIF
                */
                U_MTA410T() //Chamada do P.E. para gravar as mesmas informações de quando se altera o pedido no faturamento
			ENDIF

		END TRANSACTION
	endif
    
    If !Empty(cNumSC5)
	    MsgInfo("Pedido " + cNumSC5 + " gerado.", "Pedido")
	EndIf
	
Return