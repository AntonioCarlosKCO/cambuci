#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

User Function TelaEstb()

	Private cB1_VLCIF  := space(1)
	Private cB1_FABRIC := Space(1)
	Private cB1_PESBRU := Space(1)
	Private cB1_QE     := Space(1)
	Private cB1_XPESOB := Space(1)
	Private cB5_COMPR  := Space(1)
	Private cB5_EMB2   := Space(1)
	Private cB5_ESPESS := Space(1)
	Private cB5_LARG   := Space(1)
	Private cB5_VOLUME := Space(1)
	Private cB5_XALTUR := Space(1)
	Private cB5_XCOMPR := Space(1)
	Private cB5_XLARGL := Space(1)
	Private cCubagem	:= space(1)
	Private _aFornec := {}
	Private _aFabric := {}
	Private nQuant 		:= 0

	if empty(cProd)

		MsgAlert("Codigo de Produto não preenchido.")
	
	Else

		oDlgAdic      := MSDialog():New( 192,374,640,1116,"Dados Adicionais",,,.F.,,,,,,.T.,,,.T. )
		oSay9      := TSay():New( 151,025,{||"Fornecedor"},oDlgAdic,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
		oSay10     := TSay():New( 141,025,{||"Fabricante"},oDlgAdic,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
		oSay19     := TSay():New( 169,025,{||"CIF"},oDlgAdic,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
		oSay20     := TSay():New( 179,025,{||"Custo Rep. R$"},oDlgAdic,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
		oSay21     := TSay():New( 189,025,{||"Custo Rep. U$"},oDlgAdic,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)

		oGet6      := TGet():New( 151,080,,oDlgAdic,027,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
		oGet7      := TGet():New( 141,080,{|u| If(PCount()>0,cB1_FABRIC:=u,cB1_FABRIC)},oDlgAdic,027,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cB1_FABRIC",,)
		oGet11     := TGet():New( 189,083,,oDlgAdic,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
		oGet12     := TGet():New( 169,083,{|u| If(PCount()>0,cB1_VLCIF:=u,cB1_VLCIF)},oDlgAdic,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cB1_VLCIF",,)
		oGet13     := TGet():New( 179,083,,oDlgAdic,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)

		oCBox1     := TComboBox():New( 152,112,,,156,010,oDlgAdic,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )
		oCBox2     := TComboBox():New( 141,112,,,156,010,oDlgAdic,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )

		oGrp1      := TGroup():New( 015,021,127,176,"Dados do Item",oDlgAdic,CLR_BLACK,CLR_WHITE,.T.,.F. )

		oSay8      := TSay():New( 104,041,{||"Peso"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
		oSay6      := TSay():New( 068,041,{||"Altura do Item"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
		oSay5      := TSay():New( 050,041,{||"Largura do Item"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
		oSay4      := TSay():New( 032,041,{||"Comprimento do Item"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
		oSay1      := TSay():New( 086,041,{||"Cubagem"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)

		oGet8      := TGet():New( 068,101,{|u| If(PCount()>0,cB5_ESPESS:=u,cB5_ESPESS)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cB5_ESPESS",,)
		oGet5      := TGet():New( 104,101,{|u| If(PCount()>0,cB1_PESBRU:=u,cB1_PESBRU)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cB1_PESBRU",,)
		oGet3      := TGet():New( 050,101,{|u| If(PCount()>0,cB5_LARG:=u,cB5_LARG)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cB5_LARG",,)
		oGet2      := TGet():New( 032,101,{|u| If(PCount()>0,cB5_COMPR:=u,cB5_COMPR)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cB5_COMPR",,)
		oGet1      := TGet():New( 086,101,{|u| If(PCount()>0,cB5_VOLUME:=u,cB5_VOLUME)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cB5_VOLUME",,)

		oGrp2      := TGroup():New( 015,188,127,344,"Dados da Embalagem",oDlgAdic,CLR_BLACK,CLR_WHITE,.T.,.F. )

		oSay11     := TSay():New( 032,208,{||"Caixa Master"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
		oSay3      := TSay():New( 042,208,{||"Sub Caixa"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
		oSay14     := TSay():New( 052,208,{||"Quantidade"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
		oSay12     := TSay():New( 062,208,{||"Comprimento"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
		oSay13     := TSay():New( 072,208,{||"Largura"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
		oSay15     := TSay():New( 082,208,{||"Altura"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
		oSay18     := TSay():New( 092,208,{||"Cubagem"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
		oSay16     := TSay():New( 102,208,{||"Peso"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)

		oGet15     := TGet():New( 032,268,{|u| If(PCount()>0,cB1_QE:=u,cB1_QE)},oGrp2,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cB1_QE",,)
		oGet9      := TGet():New( 042,268,{|u| If(PCount()>0,cB5_EMB2:=u,cB5_EMB2)},oGrp2,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cB5_EMB2",,)
		oGet17     := TGet():New( 052,268,{|u| If(PCount()>0,nquant:=u,nquant)},oGrp2,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nquant",,)
		oGet21     := TGet():New( 062,268,{|u| If(PCount()>0,cB5_XCOMPRL:=u,cB5_XCOMPRL)},oGrp2,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cB5_XCOMPRL",,)
		oGet16     := TGet():New( 072,268,{|u| If(PCount()>0,cB5_XLARGLC:=u,cB5_XLARGLC)},oGrp2,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cB5_XLARGLC",,)
		oGet20     := TGet():New( 082,268,{|u| If(PCount()>0,cB5_XALTURL:=u,cB5_XALTURL)},oGrp2,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cB5_XALTURL",,)
		oGet18     := TGet():New( 092,268,{|u| If(PCount()>0,cCubagem:=u,cCubagem)},oGrp2,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cCubagem",,)
		oGet19     := TGet():New( 102,268,{|u| If(PCount()>0,cB1_XPESOB:=u,cB1_XPESOB)},oGrp2,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cB1_XPESOB",,)

		CarregaVar()

		oDlgAdic:Activate(,,,.T.)

	Endif

Return

//__________________________________________
Static Function CarregaVar()
	Local _aArea := GetArea()

	dbSelectArea("SB5")
	dbSetOrder(1)
	if dbSeek(xfilial("SB5")+cProd)
		cB5_COMPR  := SB5->B5_COMPR
		cB5_EMB2   := SB5->B5_EMB2
		cB5_ESPRES := SB5->B5_ESPESS
		cB5_LARG   := SB5->B5_LARG
		cB5_VOLUME := SB5->B5_ESPESS*SB5->B5_COMPR*SB5->B5_LARG
		cB5_XALTUR := SB5->B5_XALTURL
		cB5_XCOMPR := SB5->B5_XCOMPRL
		cB5_XLARGL := SB5->B5_XLARGLC
		cCubagem	:= cB5_XALTUR * cB5_XCOMPR * cB5_XLARGL
	Endif

	cB1_VLCIF  := SB1->B1_VLCIF
	cB1_FABRIC := SB1->B1_FABRIC
	cB1_PESBRU := SB1->B1_PESBRU
	cB1_QE     := SB1->B1_QE
	cB1_XPESOB := SB1->B1_XPESOB


	dbSelectArea("SA5")
	dbSetOrder(2)
	dbSeek(xfilial("SA5")+cProd)
	While ! SA5->(eof()) .and. SA5->A5_PRODUTO == cProd
		                                      
		SA5->(dbSkip())
	End

	oDlgAdic:refresh()

	RestArea(_aArea)
Return
