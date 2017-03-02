#Include 'Protheus.ch'


User Function Tk271bOk( nOpc )

	Local lRet 		:= .F.
	Local cGrpCon	:= SA1->A1_XGRPCON
	Local cCondPg	:= SA1->A1_COND
	Local cCpagto	:= ''
	Local aValImp	:= {}
	Local nTotT		:= 0
	Local nValSol	:= 0
	Local _xFilRef	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "UB_XFILREF"})	
	Local _x, _y  

	If !Empty(M->UA_CLIENTE)
		aValImp := MaFisNFCab()
		nTotT	:= MaFisRet(,"NF_TOTAL")
	Else
		Return .T.
	EndIf

	// Se for Inclusão ou alteração 		
	If ( nOpc >= 3 .And. nOpc <= 4 )
		If ! Empty(cCondPG) 
			M->UA_CONDPG := cCondPg
			lRet := .T.
		Else
			// Soma Valor da ST 
			For _x := 1 To Len(aValImp)
				If aValImp[_x][6] == "SOL"
					nValSol += aValImp[_x][5] 
				Endif
			Next _x
			
			cCondPg := U_CONDPAG(nTotT, nValSol)
			
			If !Empty(cCondPg)
				M->UA_CONDPG := cCondPg
			EndIf
			
			lRet := .T. 
		EndIf
	Else
		Return(.T.)	
	Endif 

	// Verifica se existem itens gravados no Acols para filiais diferentes da atual
	If M->UA_OPER == "1"

		For _y := 1 To Len(aCols)
			If alltrim(aCols[_y][_xFilRef ]) <> "" .and. aCols[_y][_xFilRef ] <> cFilAnt .And. aCols[_y][Len(aCols[_y])] == .F. 
				MsgAlert('Existem produtos gravados no atendimento para filial diferente da filial selecionada. Favor verificar os itens informados.','Cambuci')
				Return(.F.)
			Endif
		Next _Y

		//--------------------------------------------------
		// Andre Lanzieri 05/07/2016
		// Validações Estoque
		//--------------------------------------------------
		If !ValEst()
			Return(.F.)
		EndIf

	Endif

Return(lRet)

/*/{Protheus.doc} ValEst
Aglutina Produtos iguais no aCols e verifica se possui estoque
@author André Lanzieri
@since 05/07/2016
@version 1.0
/*/
Static Function ValEst()

	Local lRet 		:= .T.
	Local nX		:= 1
	Local aProds	:= {}

	Local _nPosProd		:= aScan( aHeader,{|x| Upper(Alltrim(x[2])) == "UB_PRODUTO"	})
	Local _nPosLocal	:= aScan( aHeader,{|x| Upper(Alltrim(x[2])) == "UB_LOCAL"	})
	Local _nPosQuant	:= aScan( aHeader,{|x| Upper(Alltrim(x[2])) == "UB_QUANT"	})
	Local _nPosItem		:= aScan( aHeader,{|x| Upper(Alltrim(x[2])) == "UB_ITEM"	})
	Local _nPosOper		:= aScan( aHeader,{|x| Upper(Alltrim(x[2])) == "UB_OPER"	})
	Local nTam			:= Len( aCols[1] )
	Local aProdEst		:= {}										// 	Produtos sem estoque 
	Local lValida		:= SuperGetMV("SY_ATVBLQ", Nil, .T.)		//	Valida Estoque.
	
	Default _aColsAnt := {} // VARIÁVEL DECLARADA NO FONTE TMKACTIVE.PRW - DJALMA BORGES 10/02/2017

	If lValida
		//--------------------------------------------------
		// Andre Lanzieri 05/07/2016
		// Aglutina FILIAL+PRODUTO+LOCAL iguais do aCols.
		//--------------------------------------------------
		For nX := 1 to Len(aCols)

			If !aCols[nX][nTam] 
				
				If Ascan(_aColsAnt, {|x,y| x[2] == aCols[nX][2]}) == 0 // DJALMA BORGES 10/02/2017

					nPos := aScan( aProds,{|x| Alltrim( x[2]+x[3] ) == AllTrim( aCols[nX][_nPosProd]+aCols[nX][_nPosLocal] )})
	
					If nPos > 0
	
						aProds[nPos][4] := aProds[nPos][4]+aCols[nX][_nPosQuant]
						aProds[nPos][5]	:= AllTrim(aProds[nPos][5])+";"+AllTrim(aCols[nX][_nPosItem])
	
					Else
	
						aadd(aProds,{;
						cFilAnt							,; 	// 1 Filial
						aCols[nX][_nPosProd]			,;	// 2 Produto
						aCols[nX][_nPosLocal]			,;	// 3 Local
						aCols[nX][_nPosQuant]			,;	// 4 Quantidade
						AllTrim(aCols[nX][_nPosItem])	;	// 5 Item
						})
	
					EndIf
				
				EndIf

			EndIf

		Next nX

		If Len(aProds) > 0

			DbSelectArea("SB2")
			SB2->(DbSetOrder(1))

			For nX := 1 To Len(aProds)

				// 				  Filial      Produto       Local
				If SB2->(DbSeek(aProds[nX][1]+aProds[nX][2]+aProds[nX][3]))

					If (SB2->B2_QATU-SB2->B2_RESERVA-SB2->B2_QACLASS) < aProds[nX][4]
						//					Filial		, Produto	   , Armazem	  , Qtd. Ped	 , Quantidade					,  Itens
						aadd( aProdEst , { aProds[nX][1], aProds[nX][2], aProds[nX][3], aProds[nX][4], SB2->B2_QATU-SB2->B2_RESERVA-SB2->B2_QACLASS , aProds[nX][5] } )
					EndIf

				Else

					//					Filial		, Produto	   , Armazem	  , Qtd. Ped		, Quantidade, Itens
					aadd( aProdEst , { aProds[nX][1], aProds[nX][2], aProds[nX][3], aProds[nX][4]	, 0			, aProds[nX][5]  } )
				EndIf

			Next nX

			If Len(aProdEst) > 0

				lRet	:= .F.

				DEFINE MSDIALOG oDlg2 FROM  51,58 TO 360,852 TITLE "Saldo Não disponivel" PIXEL
				@ 30,05 LISTBOX oLbx2 FIELDS HEADER "Filial","Produto","Armazem","Qtd. Pedido" ,"Saldo Disponível","Item(ns)" SIZE 392, 100 OF oDlg2 PIXEL 

				oLbx2:SetArray(aProdEst)
				oLbx2:bLine := { || {aProdEst[oLbx2:nAt,1], aProdEst[oLbx2:nAt,2],aProdEst[oLbx2:nAt,3],aProdEst[oLbx2:nAt,4],aProdEst[oLbx2:nAt,5], aProdEst[oLbx2:nAt,6]}}
				oLbx2:nFreeze  := 1

				DEFINE SBUTTON FROM 140, 190 TYPE 1 ENABLE OF oDlg2 ACTION (oDlg2:End())

				MsgInfo("Atenção, há itens sem estoque!")

				ACTIVATE MSDIALOG oDlg2 CENTERED

			EndIf

		EndIf
	EndIf
	
	 _aColsAnt := NIL // ANULAR VARIÁVEL PÚBLICA - DJALMA BORGES 13/02/2017

Return(lRet)