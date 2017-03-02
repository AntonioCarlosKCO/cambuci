#include 'protheus.ch'
#include 'parmtype.ch'

// ROTINA PARA CRIAR SALDO INICIAL NA SB9 E SBK DA FILIAL LOGADA PARA TODOS OS PRODUTOS DA SB1
// DJALMA BORGES - 17/02/2017

user function CRIASDEN()

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	SB1->(dbGoTop())
	While SB1->(!EOF()) .and. SB1->B1_FILIAL = xFilial("SB1")
	
		If ! SB9->(dbSeek(xFilial("SB9") + SB1->B1_COD + "01"))
		
			RECLOCK("SB9", .T.)
			
				SB9->B9_FILIAL := xFilial("SB9")
				SB9->B9_COD := SB1->B1_COD
				SB9->B9_LOCAL := "01"
				SB9->B9_DATA := CTOD("31/12/2016")
				SB9->B9_QINI := 10000 
			
			SB9->(MSUNLOCK())
		
		EndIf
		
		SB1->(dbSkip())
	EndDo 
	
	dbSelectArea("SB9")
	SB9->(dbSetOrder(1))
	
	dbSelectArea("SBZ")
	SBZ->(dbSetOrder(1))
	
	SB9->(dbSeek(xFilial("SB9")))
	While SB9->(!EOF()) .and. SB9->B9_FILIAL = xFilial("SB9")
	
		If ! SBK->(dbSeek(xFilial("SBK") + SB9->B9_COD + "01"))
		
			If SBZ->(dbSeek(xFilial("SBZ") + SB9->B9_COD))
			
				RECLOCK("SBK", .T.)
				
					SBK->BK_FILIAL := xFilial("SBK")
					SBK->BK_COD := SB9->B9_COD
					SBK->BK_LOCAL := SB9->B9_LOCAL
					SBK->BK_DATA := SB9->B9_DATA
					SBK->BK_QINI := SB9->B9_QINI
					If !Empty(SBZ->BZ_X_ENDER)
						SBK->BK_LOCALIZ := SBZ->BZ_X_ENDER
					Else
						SBK->BK_LOCALIZ := "S/LOCACAO"
					EndIf
					SBK->BK_PRIOR := "ZZZ"
				
				SBK->(MSUNLOCK())
				
			Else
			
				RECLOCK("SBK", .T.)
				
					SBK->BK_FILIAL := xFilial("SBK")
					SBK->BK_COD := SB9->B9_COD
					SBK->BK_LOCAL := SB9->B9_LOCAL
					SBK->BK_DATA := SB9->B9_DATA
					SBK->BK_QINI := SB9->B9_QINI
					SBK->BK_LOCALIZ := "S/LOCACAO"
					SBK->BK_PRIOR := "ZZZ"
				
				SBK->(MSUNLOCK())
			
			EndIf
		
		EndIf
	
		SB9->(dbSkip())
	EndDo
	
	MsgInfo("SALDOS INICIAIS CRIADOS NA SB9 E SBK.")
	
return