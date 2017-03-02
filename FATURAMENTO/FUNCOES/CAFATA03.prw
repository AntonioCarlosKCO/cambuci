#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

// ALTERAÇÃO DOS VENDEDORES E SEUS RESPECTIVOS PERCENTUAIS PARA PEDIDOS NÃO FATURADOS
// DJALMA BORGES 03/01/2017

User Function CAFATA03(cFilSC5, cNumSC5)

	Private cCodVend1  := ""
	Private cCodVend2  := ""
	Private cNomeVend1 := ""
	Private cNomeVend2 := ""
	Private _aComisFat := {} 
	Private _aVendFat := {}  
	Private nPercDesc := 0       
	
	SetPrvt("oDlg1","oFld1","oSay1","oSay2","oSay3","oGet1","oGet2","oGet3","oGet4","oGet5","oCBox1")
	
	SC5->(dbSetOrder(1))
	SC5->(dbSeek(cFilSC5 + cNumSC5))
	
	If ! Empty(SC5->C5_NOTA)
		MsgAlert("Este pedido já foi faturado.")
		Return
	EndIf 
	
	cCodVend1  := SC5->C5_VEND1
	cCodVend2  := SC5->C5_VEND2
	cNomeVend1 := Space(TamSX3("A3_NREDUZ")[1])
	cNomeVend2 := Space(TamSX3("A3_NREDUZ")[1])
	
	oDlg1       := MSDialog():New( 194,326,532,902,"Recalculo de Comissões",,,.F.,,,,,,.T.,,,.T. )
	oDlg1:bInit := {||EnchoiceBar(oDlg1,{||RECALCOMIS(), oDlg1:End()},{||oDlg1:End()},.F.,{},,,,.F.,,,.F.)}
	oFld1       := TFolder():New( 008,004,{"Alteração de Vendedores","Recalculo por faixa"},{},oDlg1,,,,.T.,.F.,276,132,) 
	
	oSay1      := TSay():New( 015,005,{||"Pedido"}    			,oFld1:aDialogs[1],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay2      := TSay():New( 039,005,{||"Vendedor 1"}			,oFld1:aDialogs[1],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay3      := TSay():New( 039,180,{||"Perc. Desc. S/Comis."},oFld1:aDialogs[1],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,008)
	oSay4      := TSay():New( 052,005,{||"Vendedor 2"}			,oFld1:aDialogs[1],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	
	oGet1      := TGet():New( 015,040,{|u| If(PCount()>0,cNumSC5:=u,cNumSC5)}      ,oFld1:aDialogs[1],040,008,''		 ,				,CLR_BLACK,CLR_WHITE,,,,.T.,"",,			   ,.F.,.F.,			   ,.T.,.F.,""    ,"cNumSC5"   ,,)
	oGet2      := TGet():New( 039,040,{|u| If(PCount()>0,cCodVend1:=u,cCodVend1)}  ,oFld1:aDialogs[1],040,008,''		 ,{||NOMEVEND1()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,{||NOMEVEND1()},.F.,.F.,{||NOMEVEND1()},.F.,.F.,"SA31","cCodVend1" ,,)
	oGet2      := TGet():New( 039,085,{|u| If(PCount()>0,cNomeVend1:=u,cNomeVend1)},oFld1:aDialogs[1],090,008,''		 ,				,CLR_BLACK,CLR_WHITE,,,,.T.,"",,			   ,.F.,.F.,			   ,.T.,.F.,""    ,"cNomeVend1",,)
	oGet3      := TGet():New( 039,235,{|u| If(PCount()>0,nPercDesc:=u,nPercDesc)}  ,oFld1:aDialogs[1],030,008,'@E 999.99',				,CLR_BLACK,CLR_WHITE,,,,.T.,"",,			   ,.F.,.F.,			   ,.F.,.F.,""    ,"nPercDesc" ,,)
	oGet4      := TGet():New( 052,040,{|u| If(PCount()>0,cCodVend2:=u,cCodVend2)}  ,oFld1:aDialogs[1],040,008,''		 ,{||NOMEVEND2()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,{||NOMEVEND2()},.F.,.F.,{||NOMEVEND2()},.F.,.F.,"SA31","cCodVend2" ,,)
	oGet4      := TGet():New( 052,085,{|u| If(PCount()>0,cNomeVend2:=u,cNomeVend2)},oFld1:aDialogs[1],090,008,''		 ,				,CLR_BLACK,CLR_WHITE,,,,.T.,"",,			   ,.F.,.F.,			   ,.T.,.F.,""    ,"cNomeVend2",,)
	
	//oCBox1     := TCheckBox():New( 080,012,"Zera Comissão",,oFld1:aDialogs[1],048,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	
	oDlg1:Activate(,,,.T., {|| .t., oDlg1:End()  }  )

Return

Static Function RECALCOMIS()

	Local _aAreaSC6 := SC6->(GetArea())
	Local _cTabela := ""
	Local _aComiss := {}

	dbSelectArea("SZ1")
	SZ1->(dbSetOrder(1))
	SZ1->(dbGotop())
	While ! SZ1->(eof())

		if SZ1->Z1_DATADE < SC5->C5_EMISSAO .and. SZ1->Z1_DATAATE > SC5->C5_EMISSAO
			_cTabela := SZ1->Z1_CODIGO
			exit
		Endif

		SZ1->(dbskip())
	End

	If !empty(_cTabela)

		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xfilial("SC6")+SC5->C5_NUM)

		While ! SC6->(EOF()) .and. SC6->C6_NUM == SC5->C5_NUM

			POSICIONE("SB1", 1, xFilial("SB1") + SC6->C6_PRODUTO, "B1_GRUPO")

			_aComiss := U_RegraCom(_cTabela)

			if len(_aComiss) == 0

				AADD(_aComiss, 0)
				AADD(_aComiss, 0)
				AADD(_aComiss, space(4))
				AADD(_aComiss, space(4))

			Endif	

			Reclock("SC6",.F.)
			if !empty(SC5->C5_VEND1)
				SC6->C6_COMIS1 	:= _aComiss[1] - ( _aComiss[1] * nPercDesc / 100 )
			Else
				SC6->C6_COMIS1 	:= 0
			Endif
			if !empty(SC5->C5_VEND2)
				SC6->C6_COMIS2 	:= _aComiss[2]
			Else
				SC6->C6_COMIS2 	:= 0
				SC6->C6_XSEQCA2 := _aComiss[4]
			Endif
			SC6->C6_XSEQCAL		:= _aComiss[3]
			SC6->(MsUnlock())

			SC6->(dbSkip())
		End
		
		// DJALMA BORGES 29/12/2016 - INÍCIO
		Aadd(_aComisFat, SC5->C5_VEND1) // [1]
		Aadd(_aComisFat, _aComiss[1])   // [2]
		Aadd(_aComisFat, SC5->C5_VEND2) // [3]
		Aadd(_aComisFat, _aComiss[2])   // [4]
		// DJALMA BORGES 29/12/2016 - FIM

	ENDIF

	RestArea(_aAreaSC6)

Return

Static Function NOMEVEND1()

	SA3->(dbSetOrder(1))
	SA3->(dbSeek(xFilial("SA3") + cCodVend1))
	cNomeVend1 := SA3->A3_NREDUZ

Return .T.

Static Function NOMEVEND2()

	SA3->(dbSetOrder(1))
	SA3->(dbSeek(xFilial("SA3") + cCodVend2))
	cNomeVend2 := SA3->A3_NREDUZ

Return .T.

