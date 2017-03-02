#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include 'rwmake.ch'

/*/{Protheus.doc} TelaEst
//Tela de consulta MAPA DE PRODUTO
//       Devem ser criados os seguintes campos :
//						ZZA_XCODR2 - C - 20
@author totvsremote
@since 05/01/2016
@version 1.0 

@type function
/*/
User Function TelaEst()   

	// DJALMA BORGES 08/12/2016 - INÍCIO
	Private _cEmpPrcFI := "" 
	Private _cFilTela := ""
	Private _cLocTela := ""
	Private _nMsgSBZ := 0
	// DJALMA BORGES 08/12/2016 - FIM
	
	// Vitor Ribeiro - Consultoria Global - 12/01/2017
	Private _bF05 := {|| _fTeclasF(.F.), VisualX(), oGet1:SetFocus(), _fTeclasF() }
	Private _bF06 := {|| _fTeclasF(.F.), U_TELAESTA(_cEmpPrcFI, cProd), oGet1:SetFocus(), _fTeclasF() }

	_fTeclasF()

	Processa({|| TelaEstx()},"Filtrando Produtos ...")

	_fTeclasF(.F.)
	
Return	

/*/{Protheus.doc} TelaEstx
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 

@type function
/*/
Static Function TelaEstx()

	//____________________ VARIAVEIS OPERACIONAIS 

	//	Local nOpc := GD_INSERT+GD_DELETE+GD_UPDATE
	Local nOpc := 0
	Local _aAbas := {}
	Local _aDiags := {}
	Local _aHeadCols := {}

	Local _cDesc := CriaVar("B1_DESC")
	Local _aPosGetD := {}
	Local _cAliasCI := GetNextAlias()

//	Private dDataFim   := dDataBase
//	Private dDataIni   := ctod("01/01/2000") DJALMA BORGES 15/12/2016

	Private _lSBZ		:= .f. // ALTEREI PARA .F. PARA NÃO TRAZER A SBZ DESPOSICIONADA AO ABRIR A TELA - DJALMA BORGES 20/12/2016
	Private cCarteira  	:= ""
	Private cCustoMed  	:= ""
	Private cPrecoVen	:= ""
	Private cDisp      := ""
	Private cDispVenda := ""
	Private cEstMax    := ""
	Private cEstMin    := ""
	Private cLocal     := ""
	Private cLoteEco   := ""
	Private cMedia     := ""
	Private cMes1      := ""
	Private cMes2      := ""
	Private cMes3      := ""
	Private cMes4      := ""
	Private cMes5      := ""
	Private cMes6      := ""
//	Private cMesAtu    := ""
	Private cPrazoRep  := ""
	Private cReceber   := ""
	Private cReservas  := ""
	Private cSldFisico := ""
//	Private cTransito  := ""
	Private cUltPreco  := ""
	Private cBmpRep	   := "600019"

	Private cProd 		:= CriaVar("B1_COD")
	Private _lVldBox	:= .f.
	Private _cLocTran	:= GETNEWPAR("MV_LOCTRAN","95")
	Private cFile 		:= ""

	Private cDesc		:= ""
	Private _aLocais 	:= {}
	Private nLocal 		:= 1

	Private _aFiliais 	:= {}
	Private nFilial 	:= 1
	Private _aBloq		:= {}
	Private nBloq 		:= 1

	Private nSelMes	    := 100
//	Private dMesIni		:= dDataIni
	Private dMesIni		:= ctod("01/01/2000") // DJALMA BORGES 15/12/2016

	Private oDlg1
	Private _oGetDRES, _oGetDREC, _oGetDCAR, _oGetDENT, _oGetDSAI, _oGetDCON, _oGetDSLE, _oGetDREF, _oGetDFOR
	Private cDescTab := ''

	Private _cBloqueados := ' .1.2'
	
	// DJALMA BORGES 21/12/2016 - INÍCIO
	
	Private _cNCM
	Private _nIPI1
	Private _nIPI2
	Private _nIPI3
	Private _nIPI4
	Private _nPesoLiq
	Private _nPesoBru
	Private _cSoma
	
	// DJALMA BORGES 21/12/2016 - FIM
	
	ProcRegua(SB1->(Reccount()))

	//_______________________MONTA VETOR DE ARMAZENS

	NNR->(dbSetOrder(1))
	NNR->(dbSeek(xfilial()))
	While ! NNR->(eof()) .and. NNR->NNR_FILIAL == xfilial("NNR")

		aadd(_aLocais, NNR->NNR_CODIGO + '  -  ' + NNR->NNR_DESCRI)

		NNR->(dbSkip())
	End

	if len(_aLocais) > 1

		aadd(_aLocais, "TODOS")

	Endif

	if len(_aLocais) == 0
		aadd(_aLocais , "01" )
	Endif	

	_cLocais := substr(_aLocais[1],1,2)
	Vld_Local(.t.) //substitui a opção TODOS pela string de locais separada por ponto

	//______________________________ MONTA VETOR DE FILIAIS

	SM0->(dbSetOrder(1))
	SM0->(dbGoTop())
	While ! SM0->(eof()) 

		If ! ALLTRIM(SM0->M0_CODFIL) $ GETMV("ES_FILCONS") 
		
			aadd(_aFiliais, SM0->M0_CODFIL + '  -  ' + SM0->M0_FILIAL)
		
		EndIf

		SM0->(dbSkip())
	End

	if len(_aFiliais) > 1

		aadd(_aFiliais, "TODAS")

	Endif

	_cFiliais := substr(_aFiliais[1],1,len(cFilAnt))	
	Vld_Filial(.t.)  //substitui a opção TODAS pela string de filiais separadas por ponto
	

	//______________________________ MONTA VETOR EXIBE PRODUTOS BLOQUEADOS

	aadd(_aBloq, 'Exibe produtos bloqueados')
	aadd(_aBloq, 'Não exibe produtos bloqueados')

	//_______________________________________________________


	//______________________________ FIM DAS DEFINIÇÕES DE VARIAVEIS ________________________________
	
	
	// ________________CARREGA VETORES UTILIZADOS PELO TLISTBOX
	
	SZC->(dbSetOrder(1))
	if SZC->(dbSeek(xfilial()+__cUserId))

		cProd 		:= SZC->ZC_CPROD 		
		nBloq 		:= SZC->ZC_NBLOQ 		
		nFilial 	:= SZC->ZC_NFILIAL 		
//		dDataIni 	:= SZC->ZC_DTINI DJALMA BORGES 15/12/2016
//		dDataFim	:= SZC->ZC_DTFIM 				
		nSelMes		:= SZC->ZC_NSELMES
		nLocal 		:= SZC->ZC_NLOCAL

		cDesc := GETADVFVAL('SB1','B1_DESC',xfilial('SB1')+cProd,1,'') 
		
		_cNCM     := GETADVFVAL('SB1','B1_POSIPI',xfilial('SB1')+cProd,1,'')
		_nIPI1    := GETADVFVAL('SBZ','BZ_IPI',"0101"+cProd,1,'')
		_nIPI2    := GETADVFVAL('SBZ','BZ_IPI',"0102"+cProd,1,'')
		_nIPI3    := GETADVFVAL('SBZ','BZ_IPI',"0201"+cProd,1,'')
		_nIPI4    := GETADVFVAL('SBZ','BZ_IPI',"0202"+cProd,1,'')
		_nPesoLiq := GETADVFVAL('SB1','B1_PESO',xfilial('SB1')+cProd,1,'')
		_nPesoBru := GETADVFVAL('SB1','B1_PESBRU',xfilial('SB1')+cProd,1,'')

		CarregaVar(.f.)

	Else	

		cProd 		:= space(len('B1_COD')) 		

	Endif

	if nBloq == 2
		_cBloqueados := ' .2'
	Endif

	CargaIni(_cAliasCI)

	(_cAliasCI)->(dbGoTop())

	cBmpRep	   := (_cAliasCI)->B1_BITMAP
	(_cAliasCI)->(dbCloseArea())      

	//___________________________________________________________

	oFont1     := TFont():New( "MS Sans Serif",0,-12,,.F.,0,,400,.F.,.F.,,,,,, )
	oDlg1      := MSDialog():New( 073,116,708,1191,"Histórico do Material",,,.F.,,,,,,.T.,,,.T. )

	//oBmp1      := TBitmap():New( 064,408,112,096,,,.F.,oDlg1,,,.F.,.T.,,"",.T.,,.T.,,.F. )

	oSay27      := TSay():New( 178,408,{||"Meses a Selecionar"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oGet27      := TGet():New( 175,460,{|u| If(PCount()>0,nSelMes:=u,nSelMes)},oDlg1,050,008,'999',{|x| Vld_SelMes()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.f.,.F.,"","nSelMes",,)

	//oBmp1:bValid := {|| Allwaystrue() }

	// DJALMA BORGES 14/12/2016
	oSayAtalho := TSay():New( 002,016,{||" || F5 = CONSULTA ABAS || F6 = PREÇO DE VENDA ||"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008)

	oSay13     	:= TSay():New( 020,016,{||"Pesquisar "},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGet1      	:= TGet():New( 017,050,{|u| If(PCount()>0,cProd:=u,cProd)},oDlg1,060,008,'',{|x| u_VldPrd1()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,/*"XSB101"*/,"cProd",,)

	oSay26     	:= TSay():New( 020,134,{||"Filial"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oCBox3     	:= TComboBox():New( 017,150,{|u| If(PCount()>0,nFilial:=u,nFilial)},_aFiliais ,100,010, oDlg1,,{|| Vld_Filial()}, {|| Vld_Filial()}				, CLR_BLACK, CLR_WHITE, .T.                ,        ,"",            , , , , , "nFilial"       , )

	oCBox4     	:= TComboBox():New( 030,150,{|u| If(PCount()>0,nBloq:=u,nBloq)},_aBloq ,100,010, oDlg1,,{|| Vld_Bloq()}, {|| Vld_Bloq()}				, CLR_BLACK, CLR_WHITE, .T.                ,        ,"",            , , , , , "nBloq"       , )

	// DJALMA BORGES 20/12/2016
	oSay1      := TSay():New( 020,270,{||"Armazem"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oCBox2     := TComboBox():New( 017,300,{|u| If(PCount()>0,nLocal:=u,nLocal)},_aLocais ,100,010, oDlg1,,{|| Vld_Local()}, {|| Vld_Local()}				, CLR_BLACK, CLR_WHITE, .T.                ,        ,"",            , , , , , "nLocal"       , )
	
	oGet27      := TGet():New( 045,016,{|u| If(PCount()>0,cDesc:=u,cDesc)},oDlg1,240,008,'', /*vld*/ ,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,/*consulta padrao*/,"cDesc",,)
	oGet27:lReadOnly := .t.

//	oGrp5      := TGroup():New( 012,260,052,400,"Período de Movimentações",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
//	oSay7      := TSay():New( 028,324,{||"a"},oGrp5,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,004,008)
//	oGet7      := TGet():New( 028,272,{|u| If(PCount()>0,dDataIni:=u,dDataIni)},oGrp5,045,008,'',{|| Vld_Data()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dDataIni",,)
//	oGet8      := TGet():New( 028,336,{|u| If(PCount()>0,dDataFim:=u,dDataFim)},oGrp5,045,008,'',{|| Vld_Data()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dDataFim",,)
// COMENTADO POR DJALMA BORGES 15/12/2016

	oGrp1      := TGroup():New( 060,016,136,156,"Dados do Material",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
//	oSay1      := TSay():New( 080,028,{||"Armazem"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008) // COMENTADO POR DJALMA 20/12/2016
	oSay2      := TSay():New( 090,028,{||"Estoque Minimo"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oSay3      := TSay():New( 100,028,{||"Estoque Máximo"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oSay4      := TSay():New( 110,028,{||"Lote Econômico"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oSay5      := TSay():New( 120,028,{||"Prazo Abastecimento"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)

	//oCBox2     := TComboBox():New( 077,091,{|u| If(PCount()>0,nLocal:=u,nLocal)},_aLocais ,050,010, oGrp1,,{|| Vld_Local()}, {|| Vld_Local()}				, CLR_BLACK, CLR_WHITE, .T.                ,        ,"",            , , , , , "nLocal"       , )

//	oGet2      := TGet():New( 077,091,{|u| If(PCount()>0,cLocal:=u,cLocal)},oGrp1,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cLocal",,) // COMENTADO POR DJALMA BORGES 20/12/2016 
	oGet3      := TGet():New( 087,091,{|u| If(PCount()>0,cEstMin:=u,cEstMin)},oGrp1,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cEstMin",,)
	oGet4      := TGet():New( 097,091,{|u| If(PCount()>0,cEstMax:=u,cEstMax)},oGrp1,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cEstMax",,)
	oGet5      := TGet():New( 107,091,{|u| If(PCount()>0,cLoteEco:=u,cLoteEco)},oGrp1,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cLoteEco",,)
	oGet6      := TGet():New( 117,091,{|u| If(PCount()>0,cPrazoRep:=u,cPrazoRep)},oGrp1,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cPrazoRep",,)

	//oGet2:disable()
	oGet3:disable()
	oGet4:disable()
	oGet5:disable()
	oGet6:disable()

	oGrp2      := TGroup():New( 060,164,136,400,"Consumo de Material",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSayM1     := TSay():New( 080,176,{||""},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008)
	oSayM2     := TSay():New( 090,176,{||""},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008)
	oSayM3     := TSay():New( 100,176,{||""},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008)
	oSayMD     := TSay():New( 118,276,{||"Média"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008)
	oSayMA     := TSay():New( 120,176,{||"Soma"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008)
	oSayM4     := TSay():New( 080,276,{||""},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSayM5     := TSay():New( 090,276,{||""},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSayM6     := TSay():New( 100,276,{||""},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

	oGet9      := TGet():New( 077,215,{|u| If(PCount()>0,cMes1:=u,cMes1)},oGrp2,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cMes1",,)
	oGet10     := TGet():New( 087,215,{|u| If(PCount()>0,cMes2:=u,cMes2)},oGrp2,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cMes2",,)
	oGet11     := TGet():New( 097,215,{|u| If(PCount()>0,cMes3:=u,cMes3)},oGrp2,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cMes3",,)
	oGet12     := TGet():New( 115,316,{|u| If(PCount()>0,cMedia:=u,cMedia)},oGrp2,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cMedia",,)
//	oGet13     := TGet():New( 117,215,{|u| If(PCount()>0,cMesAtu:=u,cMesAtu)},oGrp2,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cMesAtu",,)
	oGet13     := TGet():New( 117,215,{|u| If(PCount()>0,_cSoma:=u,_cSoma)},oGrp2,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","_cSoma",,)
	oGet23     := TGet():New( 077,316,{|u| If(PCount()>0,cMes4:=u,cMes4)},oGrp2,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cMes4",,)
	oGet24     := TGet():New( 087,316,{|u| If(PCount()>0,cMes5:=u,cMes5)},oGrp2,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cMes5",,)
	oGet25     := TGet():New( 097,316,{|u| If(PCount()>0,cMes6:=u,cMes6)},oGrp2,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cMes6",,)

	oGet9:disable()
	oGet10:disable()
	oGet11:disable()
	oGet12:disable()
	oGet13:disable()
	oGet23:disable()
	oGet24:disable()
	oGet25:disable()

	oGrp3      := TGroup():New( 140,016,208,280,"Saldos do Material",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay15     := TSay():New( 160,028,{||"Saldo Físico"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oSay16     := TSay():New( 170,028,{||"Reservas"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oSay17     := TSay():New( 180,028,{||"Disponivel"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oSay18     := TSay():New( 190,028,{||"Em Carteira"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)

	oSay19     := TSay():New( 160,151,{||"Disponivel para Venda"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oSay20     := TSay():New( 170,151,{||"A Receber"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
//	oSay21     := TSay():New( 180,151,{||"Em Trânsito"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)

	oGet14     := TGet():New( 157,091,{|u| If(PCount()>0,cSldFisico:=u,cSldFisico)},oGrp3,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cSldFisico",,)
	oGet15     := TGet():New( 167,091,{|u| If(PCount()>0,cReservas:=u,cReservas)},oGrp3,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cReservas",,)
	oGet16     := TGet():New( 177,091,{|u| If(PCount()>0,cDisp:=u,cDisp)},oGrp3,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cDisp",,)
	oGet17     := TGet():New( 187,091,{|u| If(PCount()>0,cCarteira:=u,cCarteira)},oGrp3,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cCarteira",,)
	oGet18     := TGet():New( 157,216,{|u| If(PCount()>0,cDispVenda:=u,cDispVenda)},oGrp3,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cDispVenda",,)
	oGet19     := TGet():New( 167,216,{|u| If(PCount()>0,cReceber:=u,cReceber)},oGrp3,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cReceber",,)
//	oGet20     := TGet():New( 177,216,{|u| If(PCount()>0,cTransito:=u,cTransito)},oGrp3,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cTransito",,)

	oGet14:disable()
	oGet15:disable()
	oGet16:disable()
	oGet17:disable()
	oGet18:disable()
	oGet19:disable()
//	oGet20:disable()

	oGrp4      := TGroup():New( 140,288,208,400,"Custos do Material",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay22     := TSay():New( 160,300,{||"Custo Médio"},oGrp4,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,037,008)
	oSay23     := TSay():New( 170,300,{||"Último Preço"},oGrp4,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,037,008)
	oSay24     := TSay():New( 180,300,{||"Preço Venda"},oGrp4,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,037,008)
	oSay24     := TSay():New( 190,337,{|| cDescTab },oGrp4,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,037,008)

	oGet21     := TGet():New( 157,337,{|u| If(PCount()>0,cCustoMed:=u,cCustoMed)},oGrp4,050,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cCustoMed",,)
	oGet22     := TGet():New( 167,337,{|u| If(PCount()>0,cUltPreco:=u,cUltPreco)},oGrp4,050,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cUltPreco",,)
	oGet26     := TGet():New( 177,337,{|u| If(PCount()>0,cPrecoVen:=u,cPrecoVen)},oGrp3,050,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cPrecoVen",,)

	oGet21:Disable()
	oGet22:Disable()
	oGet26:Disable()
	
	// DJALMA BORGES 21/12/2016 - INÍCIO
	
	oSayNCM	 := TSay():New(066,428,{||"Pos.IPI/NCM"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,037,008)
	oGetNCM	 := TGet():New(065,470,{|u| If(PCount()>0,_cNCM:=u,_cNCM)},oDlg1,050,008,'@R 9999.99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"_cNCM",,)
	
	oSayIPI1 := TSay():New(077,428,{||"Aliq. IPI 0101"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,037,008)
	oGetIPI1 := TGet():New(076,470,{|u| If(PCount()>0,_nIPI1:=u,_nIPI1)},oDlg1,050,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"_nIPI1",,)
	
	oSayIPI2 := TSay():New(088,428,{||"Aliq. IPI 0102"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,037,008)
	oGetIPI2 := TGet():New(087,470,{|u| If(PCount()>0,_nIPI2:=u,_nIPI2)},oDlg1,050,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"_nIPI2",,)
	
	oSayIPI3 := TSay():New(099,428,{||"Aliq. IPI 0201"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,037,008)
	oGetIPI3 := TGet():New(098,470,{|u| If(PCount()>0,_nIPI3:=u,_nIPI3)},oDlg1,050,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"_nIPI3",,)
	
	oSayIPI4 := TSay():New(110,428,{||"Aliq. IPI 0202"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,037,008)
	oGetIPI4 := TGet():New(109,470,{|u| If(PCount()>0,_nIPI4:=u,_nIPI4)},oDlg1,050,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"_nIPI4",,)
	
	oSayPLiq := TSay():New(121,428,{||"Peso Liquido"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,037,008)
	oGetPLiq := TGet():New(120,470,{|u| If(PCount()>0,_nPesoLiq:=u,_nPesoLiq)},oDlg1,050,008,'@E 999,999.9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"_nPesoLiq",,)
	
	oSayPBru := TSay():New(132,428,{||"Peso Bruto"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,037,008)
	oGetPBru := TGet():New(131,470,{|u| If(PCount()>0,_nPesoBru:=u,_nPesoBru)},oDlg1,050,008,'@E 999,999.9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"_nPesoBru",,)
	
	oGetNCM:Disable()
	oGetIPI1:Disable()
	oGetIPI2:Disable()
	oGetIPI3:Disable()
	oGetIPI4:Disable()
	oGetPLiq:Disable()
	oGetPBru:Disable()
	
	// DJALMA BORGES 21/12/2016 - FIM

	oBtn1      := TButton():New( 020,428,"Preço de Venda",oDlg1,{|| u_TelaEstA(_cEmpPrcFI, cProd) },092,012,,,,.T.,,"",,,,.F. )
//	oBtn3      := TButton():New( 036,428,"Dados Adicionais",oDlg1,{|| u_TelaEstB() },092,012,,,,.T.,,"",,,,.F. )

	_aAbas := {"Reservas","A Receber","Carteira","Movto. Entradas","Movto. Saídas","Consumo","Saldo Endereço","Referência","Fornecedor" }
	_oFolder := TFolder():New( 212,016          ,_aAbas ,_aDiags,oDlg1,,,,.T.,.F.,508,084,)

	_oFldRES := _oFolder:aDialogs[1]
	_oFldREC := _oFolder:aDialogs[2]
	_oFldCAR := _oFolder:aDialogs[3]
	_oFldENT := _oFolder:aDialogs[4]
	_oFldSAI := _oFolder:aDialogs[5]
	_oFldCON := _oFolder:aDialogs[6]
	_oFldSLE := _oFolder:aDialogs[7]
	_oFldREF := _oFolder:aDialogs[8]
	_oFldFOR := _oFolder:aDialogs[9]

	aadd(_aPosGetD , { 000,000,068,504 })

	//______________________MONTA AHEADER E ACOLS ______________________________
	_aHeadCols := U_MtHdCols("SC9","RESERVA")
	_oGetDRES      := MsNewGetDados():New(_aPosGetD[1,1],_aPosGetD[1,2],_aPosGetD[1,3],_aPosGetD[1,4],nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',_oFldRES,_aHeadCols[1],_aHeadCols[2] )

	_aHeadCols := U_MtHdCols("SC7","RECEBER")
	_oGetDREC      := MsNewGetDados():New(_aPosGetD[1,1],_aPosGetD[1,2],_aPosGetD[1,3],_aPosGetD[1,4],nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',_oFldREC,_aHeadCols[1],_aHeadCols[2] )

	_aHeadCols := U_MtHdCols("SC6","CARTEIRA")
	_oGetDCAR      := MsNewGetDados():New(_aPosGetD[1,1],_aPosGetD[1,2],_aPosGetD[1,3],_aPosGetD[1,4],nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',_oFldCAR,_aHeadCols[1],_aHeadCols[2] )

	_aHeadCols := U_MtHdCols("SD1","ENTRADAS")
	_oGetDENT      := MsNewGetDados():New(_aPosGetD[1,1],_aPosGetD[1,2],_aPosGetD[1,3],_aPosGetD[1,4],nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',_oFldENT,_aHeadCols[1],_aHeadCols[2] )

	_aHeadCols := U_MtHdCols("SD2","SAIDAS")
	_oGetDSAI      := MsNewGetDados():New(_aPosGetD[1,1],_aPosGetD[1,2],_aPosGetD[1,3],_aPosGetD[1,4],nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',_oFldSAI,_aHeadCols[1],_aHeadCols[2] )

	_aHeadCols := U_MtHdCols("SB3","CONSUMO")
	_oGetDCON      := MsNewGetDados():New(_aPosGetD[1,1],_aPosGetD[1,2],_aPosGetD[1,3],_aPosGetD[1,4],nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',_oFldCON,_aHeadCols[1],_aHeadCols[2] )

	_aHeadCols := U_MtHdCols("SBF","ENDERECO")
	_oGetDSLE      := MsNewGetDados():New(_aPosGetD[1,1],_aPosGetD[1,2],_aPosGetD[1,3],_aPosGetD[1,4],nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',_oFldSLE,_aHeadCols[1],_aHeadCols[2] )

	_aHeadCols := U_MtHdCols("ZZA","REFERENCIA")
	_oGetDREF      := MsNewGetDados():New(_aPosGetD[1,1],_aPosGetD[1,2],_aPosGetD[1,3],_aPosGetD[1,4],nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',_oFldREF,_aHeadCols[1],_aHeadCols[2] )

	_aHeadCols := U_MtHdCols("SB5","FORNECEDOR")
	_oGetDFOR      := MsNewGetDados():New(_aPosGetD[1,1],_aPosGetD[1,2],_aPosGetD[1,3],_aPosGetD[1,4],nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',_oFldFOR,_aHeadCols[1],_aHeadCols[2] )

	//____________________________________________________
	bInit := {|| CarregaVar() }

	oDlg1:Activate(,,,.T.,,,bInit)

Return


/*/{Protheus.doc} VldBox1
//ATUALIZA TODAS AS INFORMAÇÕES DA TELA AO CLICAR NA DESCRIÇÃO DO PRODUTO ESCOLHIDA PELO TLISTBOX
@author totvsremote
@since 05/01/2016
@version 1.0 
@param _cOp, undefined, descricao
@type function
/*/
User Function VldBox1(  _cOp)

	Local _lRet := .t.

Return(_lRet)


/*/{Protheus.doc} ChgLst
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 

@type function
/*/
/* FUNÇÃO COMENTADA POR DJALMA BORGES 15/12/2016
User Function ChgLst(  )

	if ! _lVldBox
		_lVldBox := .t.
		Return(.t.)
	Endif

	if empty(dDataIni) .or. empty(dDataFim) .and.  _lVldBox
		MsgAlert("Preencha os parametros de pesquisa por período")
	Else

		AtuaBmp(cProd)
		CarregaVar()
		oDlg1:refresh(.t.)

	Endif


Return(.t.)
*/

/*/{Protheus.doc} VldLst
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 

@type function
/*/
User Function VldLst()

	AtuaBmP(cProd)
	CarregaVar()
	oDlg1:Refresh(.t.)

Return


/*/{Protheus.doc} ExtraiBMP
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 
@param cNomeRep, undefined, descricao
@type function
/*/
Static  function ExtraiBMP(cNomeRep)

	Local cFile
	Local _lRet := .t.

	cFile := '\SYSTEM\IMAGENS\'+cNomeRep+'.bmp'
	if ! file(cFile)

		If ! RepExtract(cNomeRep,cFile,,.T.)
			_lRet := .f.
		Endif

	Endif

Return(_lRet)

/*/{Protheus.doc} AtuaBMP
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 
@param cProdTmp, undefined, descricao
@type function
/*/
Static Function AtuaBMP(cProdTmp)
	Default cProdTmp := ""

	cProd := cProdTmp

	dbSelectArea("SB2")
	dbSetOrder(1)
	dbSeek(xfilial("SB2")+cProd)

	dbSelectArea("SB1")
	dbSetOrder(1)
	if dbSeek(xfilial("SB1")+cProd) 

		cBmpRep := alltrim(SB1->B1_BITMAP)

	Endif

	cFile := "\SYSTEM\IMAGENS\"+cBmpRep+".BMP"
	_lBmp := ExtraiBMP(cBmpRep)

	if ! _lBmp
		cFile :=   "\SYSTEM\IMAGENS\SEMIMAGEM.BMP"                        
	Endif
	//	oBmp1:SetEmpty()
	//oBmp1:Load(cBmpRep,cFile)

Return

/*/{Protheus.doc} MtHdCols
//Montagem de aHeader e aCols
// Utilizado vetor _aExibe com as seguintes informações :

//		aadd(_aExibe, {	Alias,;
Campo base para x3_relação e x3_valida,;
Campo real utilizado,;
Descrição real utilizada,;
'ZZA_TPREF2',;
Inicializador padrão alternativo,;
Logico - .f. = Inibe validação do campo base})
@author totvsremote
@since 05/01/2016
@version 1.0 
@param _cAlias, undefined, descricao
@param _cOp, undefined, descricao
@type function
/*/
User Function MtHdCols(_cAlias, _cOp)

	Local _aHeadCols := {{},{}}
	Local aHeader := {}
	Local aCols := {}
	Local _cBlEst := CriaVar("C9_BLEST")
	Local _cBlCred := CriaVar("C9_BLCRED") // DJALMA BORGES 24/01/2017
	Local _cAliasSQL := GetNextAlias()
	Local csDataIni := dtos(dMesIni)
	Local csDataFim := dtos(dDataBase)

	Local _nTamFil	:= len(xfilial('SC9'))
	Local _nTamLoc  := len(SC9->C9_LOCAL)
	
	Private  _aExibe := {}
	
	if _cOP == "RESERVA"

		aadd(_aExibe, {"SC9","C9_FILIAL",,,,,,})
		aadd(_aExibe, {"SC9","C9_PEDIDO",,,,,,})
		aadd(_aExibe, {"SC9","C9_ITEM",,,,,,})
		aadd(_aExibe, {"SC9","C9_SEQUEN",,,,,,})
		aadd(_aExibe, {"SC9","C9_QTDLIB",,,,,,})
		aadd(_aExibe, {"SA1","A1_COD",,,,,,})
		aadd(_aExibe, {"SA1","A1_LOJA",,,,,,})
		aadd(_aExibe, {"SA1","A1_NOME",,,,,,})
		aadd(_aExibe, {"SC9","REC_SC9",,,,,,})

		BeginSql Alias _cAliasSQL

		column C9_QTDLIB as numeric(14,2)
		column C9_DATALIB as Date

		SELECT *
		FROM (
		SELECT *, R_E_C_N_O_ as REC_SC9
		FROM %Table:SC9% (Nolock)
		WHERE %NotDel%
		AND C9_PRODUTO 	= %Exp:cProd%
		AND C9_BLEST 	= %Exp:_cBlEst%
		AND C9_BLCRED 	= %Exp:_cBlCred% // DJALMA BORGES 24/01/2017
		AND C9_DATALIB >= %Exp:csDataIni%
		AND C9_DATALIB <= %Exp:csDataFim%

		AND  (
		len(%Exp:_cLocais%) > ( CASE WHEN ( C9_PRODUTO <> '' ) THEN %Exp:_nTamLoc% END )
		OR
		len(%Exp:_cLocais%) = ( CASE WHEN ( charindex(C9_LOCAL,%Exp:_cLocais%) > 0 ) THEN %Exp:_nTamLoc% END )
		)

		AND  (
		len(%Exp:_cFiliais%) > ( CASE WHEN ( C9_PRODUTO <> '' ) THEN %Exp:_nTamFil% END )
		OR
		len(%Exp:_cFiliais%) = ( CASE WHEN ( charindex(C9_FILIAL,%Exp:_cFiliais%) > 0 ) THEN %Exp:_nTamFil% END )
		)

		) SC9

		INNER JOIN (
		SELECT A1_FILIAL, A1_NOME, A1_COD, A1_LOJA
		FROM %Table:SA1% (Nolock)
		WHERE %NotDel%
		) SA1

		ON C9_CLIENTE+C9_LOJA = A1_COD+A1_LOJA

		EndSql

	Elseif _cOP == "RECEBER"

		aadd(_aExibe, {"SC7","C7_FILIAL",,,,,,})
		aadd(_aExibe, {"SC7","C7_EMISSAO",,,,,,})
		aadd(_aExibe, {"SC7","C7_NUM",,,,,,})
		aadd(_aExibe, {"SC7","C7_QUANT",,,,,,})
		aadd(_aExibe, {"SC7","C7_PRECO",,,,,,})
		aadd(_aExibe, {"SA2","A2_NOME",,,,,,})
		aadd(_aExibe, {"SC7","C7_FORNECE",,,,,,})
		aadd(_aExibe, {"SC7","C7_LOJA",,,,,,})
		aadd(_aExibe, {"SC7","C7_ITEM",,,,,,})

		BeginSql Alias _cAliasSQL

		column C7_QUANT as numeric(14,2)
		column C7_DINICQ as date
		column C7_DINICOM as date
		column C7_DATPRF as date
		column C7_EMISSAO as date

		SELECT *
		FROM (
//		SELECT *, R_E_C_N_O_ as REC_SC7
		SELECT C7_FILIAL,C7_EMISSAO, C7_NUM,  (C7_QUANT - C7_QUJE) AS C7_QUANT, C7_PRECO, C7_FORNECE, C7_LOJA, C7_ITEM, R_E_C_N_O_ as REC_SC7 // DJALMA BORGES 15/12/2016
		FROM %Table:SC7% (Nolock)
		WHERE %NotDel%
		AND C7_PRODUTO 	= %Exp:cProd%
		AND C7_CONAPRO 	= 'L'
		AND C7_QUJE < C7_QUANT
		AND C7_EMISSAO >= %Exp:csDataIni%
		AND C7_EMISSAO <= %Exp:csDataFim%

		AND  (
		len(%Exp:_cLocais%) > ( CASE WHEN ( C7_PRODUTO <> '' ) THEN %Exp:_nTamLoc% END )
		OR
		len(%Exp:_cLocais%) = ( CASE WHEN ( charindex(C7_LOCAL,%Exp:_cLocais%) > 0 ) THEN %Exp:_nTamLoc% END )
		)

		AND  (
		len(%Exp:_cFiliais%) > ( CASE WHEN ( C7_PRODUTO <> '' ) THEN %Exp:_nTamFil% END )
		OR
		len(%Exp:_cFiliais%) = ( CASE WHEN ( charindex(C7_FILIAL,%Exp:_cFiliais%) > 0 ) THEN %Exp:_nTamFil% END )
		)

		) SC7

		INNER JOIN (
		SELECT A2_FILIAL, A2_NOME, A2_COD, A2_LOJA
		FROM %Table:SA2% (Nolock)
		WHERE %NotDel%
		) SA2

		ON C7_FORNECE+C7_LOJA = A2_COD+A2_LOJA

		EndSql

	Elseif _cOP == "CARTEIRA"

		aadd(_aExibe, {"SC6","C6_FILIAL",,,,,,})
		aadd(_aExibe, {"SC6","C6_NUM",,,,,,})
		aadd(_aExibe, {"SC6","C6_ITEM",,,,,,})
		aadd(_aExibe, {"SC6","C6_QTDVEN",,,,,,})
		aadd(_aExibe, {"SC6","C6_PRCVEN",,,,,,})
		aadd(_aExibe, {"SC6","C6_VALOR",,,,,,})
		aadd(_aExibe, {"SC5","C5_EMISSAO",,,,,,})
		aadd(_aExibe, {"SC5","C5_CLIENTE",,,,,,})
		aadd(_aExibe, {"SC5","C5_LOJACLI",,,,,,})

		BeginSql Alias _cAliasSQL

		column C6_QTDVEN as numeric(14,2)
		column C5_EMISSAO as date
		
//		SELECT C6_NUM, C6_ITEM, C6_QTDVEN, C5_EMISSAO, C6_FILIAL, C9_PEDIDO, REC_SC6
		
		// DJALMA BORGES 24/01/2017 - INÍIO
		SELECT C6_NUM,C6_ITEM, 
		CASE WHEN C9_PEDIDO IS NULL OR C9_BLCRED <> '' OR C9_BLEST <> '' THEN C6_QTDVEN ELSE C6_QTDVEN - C9_QTDLIB END AS C6_QTDVEN,   
		C5_EMISSAO,C6_FILIAL,C9_PEDIDO,REC_SC6 
		// DJALMA BORGES 24/01/2017 - FIM 
		FROM (
		SELECT *, R_E_C_N_O_ as REC_SC6
		FROM %Table:SC6% (Nolock)
		WHERE %NotDel%
		AND C6_PRODUTO 	= %Exp:cProd%

		AND  (
		len(%Exp:_cLocais%) > ( CASE WHEN ( C6_PRODUTO <> '' ) THEN %Exp:_nTamLoc% END )
		OR
		len(%Exp:_cLocais%) = ( CASE WHEN ( charindex(C6_LOCAL,%Exp:_cLocais%) > 0 ) THEN %Exp:_nTamLoc% END )
		)

		AND  (
		len(%Exp:_cFiliais%) > ( CASE WHEN ( C6_PRODUTO <> '' ) THEN %Exp:_nTamFil% END )
		OR
		len(%Exp:_cFiliais%) = ( CASE WHEN ( charindex(C6_FILIAL,%Exp:_cFiliais%) > 0 ) THEN %Exp:_nTamFil% END )
		)

		) SC6

		INNER JOIN (
		SELECT C5_FILIAL, C5_NUM, C5_EMISSAO
		FROM %Table:SC5% (Nolock)
		WHERE %NotDel%
		AND C5_EMISSAO >= %Exp:csDataIni%
		AND C5_EMISSAO <= %Exp:csDataFim%

		) SC5

		ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM

		LEFT JOIN (
		SELECT *
		FROM %Table:SC9% (Nolock)
		WHERE %NotDel%
		) SC9

		ON C6_FILIAL = C9_FILIAL AND C6_NUM = C9_PEDIDO AND C6_PRODUTO = C9_PRODUTO AND C6_ITEM = C9_ITEM

//		WHERE C9_PEDIDO IS NULL

		// DJALMA BORGES 24/01/2017 - INÍCIO
		WHERE
		CASE WHEN C9_PEDIDO IS NULL OR C9_BLCRED <> '' OR C9_BLEST <> '' THEN C6_QTDVEN ELSE C6_QTDVEN - C9_QTDLIB END
		<> 0
		// DJALMA BORGES 24/01/2017 - FIM

		EndSql

	Elseif _cOP == "ENTRADAS"
		// CAMPO D1_CHASSI UTILIZADO APENAS PARA PREENCHIMENTO DE AHEADER
		aadd(_aExibe, {"SD1","D1_FILIAL",,,,,,})
		aadd(_aExibe, {"SD1","D1_DTDIGIT",,,,,,})
		aadd(_aExibe, {"SD1","D1_QUANT",,,,,,})
		aadd(_aExibe, {"SD1","D1_VUNIT",,,,,,})
		aadd(_aExibe, {"SA2","A2_NOME",,,,,,})
		aadd(_aExibe, {"SD1","D1_DOC",,,,,,})
		aadd(_aExibe, {"SD1","D1_TIPO",,,,,,})
		aadd(_aExibe, {"SD1","D1_FORNECE",,,,,,})
		aadd(_aExibe, {"SD1","D1_LOJA",,,,,,})
		aadd(_aExibe, {"SD1","D1_SERIE",,,,,,})
		aadd(_aExibe, {"SD1","D1_TES",,,,,,})

		BeginSql Alias _cAliasSQL

		column D1_DTDIGIT as date

		SELECT *
		FROM (
		SELECT D1_FILIAL 
		, D1_TES
		, D1_TIPO
		, D1_SERIE
		, D1_DOC
		, D1_DTDIGIT
		, D1_EMISSAO
		, D1_FORNECE
		, D1_LOJA
		, D1_QUANT
		, D1_VUNIT
		, R_E_C_N_O_ as REC_SD1

		FROM %Table:SD1% (NOLOCK)
		WHERE %NotDel%
		AND D1_TIPO IN('N','D')
		AND D1_DTDIGIT >= %Exp:csDataIni%
		AND D1_DTDIGIT <= %Exp:csDataFim%
		AND D1_COD = %Exp:cProd%

		AND  (
		len(%Exp:_cLocais%) > ( CASE WHEN ( D1_COD <> '' ) THEN %Exp:_nTamLoc% END )
		OR
		len(%Exp:_cLocais%) = ( CASE WHEN ( charindex(D1_LOCAL,%Exp:_cLocais%) > 0 ) THEN %Exp:_nTamLoc% END )
		)

		AND  (
		len(%Exp:_cFiliais%) > ( CASE WHEN ( D1_COD <> '' ) THEN %Exp:_nTamFil% END )
		OR
		len(%Exp:_cFiliais%) = ( CASE WHEN ( charindex(D1_FILIAL,%Exp:_cFiliais%) > 0 ) THEN %Exp:_nTamFil% END )
		)

		) SD1

		INNER JOIN (
		SELECT A2_COD, A2_LOJA, A2_NOME
		FROM %Table:SA2%
		WHERE %NotDel%
		) SA2 ON D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA

		ORDER BY D1_DTDIGIT

		EndSql

	Elseif _cOP == "SAIDAS"

		aadd(_aExibe, {"SD2","D2_FILIAL",,,,,,})
		aadd(_aExibe, {"SD2","D2_EMISSAO",,,,,,})
		aadd(_aExibe, {"SD2","D2_QUANT",,,,,,})
		aadd(_aExibe, {"SD2","D2_PRCVEN",,,,,,})
		aadd(_aExibe, {"SA1","A1_NOME",,,,,,})
		aadd(_aExibe, {"SD2","D2_DOC",,,,,,})
		aadd(_aExibe, {"SD2","D2_TIPO",,,,,,})
		aadd(_aExibe, {"SD2","D2_CLIENTE",,,,,,})
		aadd(_aExibe, {"SD2","D2_LOJA",,,,,,})
		aadd(_aExibe, {"SD2","D2_SERIE",,,,,,})
		aadd(_aExibe, {"SD2","D2_TES",,,,,,})

		BeginSql Alias _cAliasSQL

		column D2_EMISSAO as date

		SELECT *
		FROM (
		SELECT D2_FILIAL
		, D2_TES
		, D2_TIPO
		, D2_SERIE 
		, D2_DOC
		, D2_EMISSAO
		, D2_CLIENTE
		, D2_LOJA
		, D2_QUANT
		, D2_PRCVEN
		, R_E_C_N_O_ as REC_SD2

		FROM %Table:SD2% (NOLOCK)
		WHERE %NotDel%
		AND D2_TIPO IN('N','D')
		AND D2_EMISSAO >= %Exp:csDataIni%
		AND D2_EMISSAO <= %Exp:csDataFim%
		AND D2_COD = %Exp:cProd%

		AND  (
		len(%Exp:_cLocais%) > ( CASE WHEN ( D2_COD <> '' ) THEN %Exp:_nTamLoc% END )
		OR
		len(%Exp:_cLocais%) = ( CASE WHEN ( charindex(D2_LOCAL,%Exp:_cLocais%) > 0 ) THEN %Exp:_nTamLoc% END )
		)

		AND  (
		len(%Exp:_cFiliais%) > ( CASE WHEN ( D2_COD <> '' ) THEN %Exp:_nTamFil% END )
		OR
		len(%Exp:_cFiliais%) = ( CASE WHEN ( charindex(D2_FILIAL,%Exp:_cFiliais%) > 0 ) THEN %Exp:_nTamFil% END )
		)

		) SD2

		INNER JOIN (
		SELECT A1_COD, A1_LOJA, A1_NOME
		FROM %Table:SA1% (NOLOCK)
		WHERE %NotDel%
		) SA1 ON D2_CLIENTE = A1_COD AND D2_LOJA = A1_LOJA

		ORDER BY D2_EMISSAO		

		EndSql

	Elseif _cOP == "CONSUMO"

		// Montagem dos dados do cabecalho do relatorio                
		//__________________________________________________
		_aMeses := {'JAN','FEV','MAR','ABR','MAI','JUN','JUL','AGO','SET','OUT','NOV','DEZ'}
		_aDispMes := {,,,,,,,,,,,}

		nAno := Year(dDataBase)
		If month(dDatabase) < 12
			nAno--
		EndIf

		nMes := Month(dDataBase)+1
		If nMes = 13 
			nMes := 1
		EndIf

		cMes := StrZero(nMes,2)

		For nX := 1 To 12
			If _aMeses[nMes] == 'JAN' .And. nX != 1	//"JAN"
				nAno++
			EndIf

			_aDispMes[nMes] :=  _aMeses[nMes]+"/"+StrZero(nAno,4)

			nMes++
			If nMes > 12
				nMes := 1
			EndIf
		Next nX
		//______________________________________

		nAno := Year(dDataBase)
		If month(dDatabase) < 12
			nAno--
		EndIf

		nMes := Month(dDataBase)+1
		If nMes = 13 
			nMes := 1
		EndIf

		//___________________________________
		aadd(_aExibe, {"SB3","B3_FILIAL",,,,,,})

		For Nx := 1 to 12
			If _aMeses[nMes] == 'JAN' .And. nX != 1	//"JAN"
				nAno++
			EndIf

			_cCampo := 'B3_Q'+strzero(nMes,2)
			aadd(_aExibe, {'SB3',_cCampo,,_aDispMes[nMes] ,,, ,})

			nMes++
			If nMes > 12
				nMes := 1
			EndIf

		Next Nx	

		aadd(_aExibe, {"SB3","B3_QMES",,,,,,})

		BeginSql Alias _cAliasSQL

		column B3_Q01 as numeric(11,0)
		column B3_Q02 as numeric(11,0)
		column B3_Q03 as numeric(11,0)
		column B3_Q04 as numeric(11,0)
		column B3_Q05 as numeric(11,0)
		column B3_Q06 as numeric(11,0)
		column B3_Q07 as numeric(11,0)
		column B3_Q08 as numeric(11,0)
		column B3_Q09 as numeric(11,0)
		column B3_Q10 as numeric(11,0)
		column B3_Q11 as numeric(11,0)
		column B3_Q12 as numeric(11,0)
		column B3_MES as date

		SELECT *
		FROM %Table:SB3% (NOLOCK)
		WHERE %NotDel%
		AND B3_COD = %Exp:cProd%
		AND  charindex(B3_FILIAL,%Exp:_cFiliais%) > 0
		AND B3_MES BETWEEN %Exp:csDataIni% AND %Exp:csDataFim% // DJALMA BORGES 15/12/2016

		EndSql

	Elseif _cOP == "REFERENCIA"

		//1=Opcional;2=Similar;3=Montadora;4=Tecnica                                                                                      

		aadd(_aExibe, {"ZZA","ZZA_FILIAL",,,,,,})
		aadd(_aExibe, {"ZZA","ZZA_XCODRF",,,,,,})
		aadd(_aExibe, {"ZZA","ZZA_XAPLIC",,,,,,})
		aadd(_aExibe, {"ZZA","ZZA_XLINHA",,,,,,})
		aadd(_aExibe, {"ZZA","ZZA_XCODRF",'ZZA_TPREF2','Tipo Referencia','ZZA_TPREF2','',,})

		//  ZZA_TPREF    1=Opcional;2=Similar;3=Montadora;4=Tecnica;5=Fornecedor                                                                                      

		BeginSql Alias _cAliasSQL

		SELECT *,
		case ZZA_XTPREF
		when '1' then 'Opcional'
		when '2' then 'Similar'
		when '3' then 'Montadora'
		when '4' then 'Tecnica'
		when '5' then 'Fornecedor' // DJALMA BORGES 22/02/2017
	end as ZZA_TPREF2

	FROM %Table:ZZA% (NOLOCK)
	WHERE %NotDel%
	AND ZZA_XCOD = %Exp:cProd%

	EndSql

	Elseif _cOP == "FORNECEDOR"

		aadd(_aExibe, {"SA5","A5_FILIAL",,,,,,})
		aadd(_aExibe, {"SA5","A5_CODPRF",,,,,,})
		aadd(_aExibe, {"SA5","A5_FORNECE",,,,,,})
		aadd(_aExibe, {"SA5","A5_LOJA",,,,,,})
		aadd(_aExibe, {"SA5","A5_NOMEFOR",,,,,,})

		BeginSql Alias _cAliasSQL

		SELECT *
		FROM %Table:SA5% (NOLOCK)
		WHERE %NotDel%
		AND A5_PRODUTO = %Exp:cProd%

		EndSql

	Elseif _cOP == "PRECO"  // EM U_TelaEstA()	

		aadd(_aExibe, {"DA0","DA0_FILIAL",,"Empresa",,,,"û"}) // DJALMA BORGES 13/12/2016 "Empresa"
		aadd(_aExibe, {"DA0","DA0_CODTAB",,,,,,"û"})
		aadd(_aExibe, {"DA0","DA0_DESCRI",,,,,,"û"})

		//aadd(_aExibe, {"SB1","B1_PRV1","B1_PRV1","Preco Base","B1_PRV1",0,,"û"}) // CAMPOS RETIRADOS

		aadd(_aExibe, {"DA1","DA1_FRETE","DA1_PRCVEN","Preço de Venda","DA1_PRCVEN",0,,})

		aadd(_aExibe, {"SB1","B1_IPI",,,,,,"û"})
		//aadd(_aExibe, {"DA1","DA1_VALIPI","DA1_VALIPI","Valor IPI","DA1_VALIPI" , 0,,"û"} ) // POR SOLICITAÇÃO

		//aadd(_aExibe, {"SB1","B1_IPI","DA1_ST","ST","DA1_ST" , 0,,"û"} )
		//aadd(_aExibe, {"DA1","DA1_DA1_VALST","DA1_VALST","Valor ST","DA1_VALST" , 0,,"û"} ) // DO NIVALDO

		//aadd(_aExibe, {"DA1","DA1_PRCIMP","DA1_PRCIMP","Valor com Impostos","DA1_PRCIMP", 0,,}) // DJALMA BORGES 08/12/2016
		
		// TRATAR A STRING PARA UTILIZAR IN NA QUERY - DJALMA BORGES 08/12/2016
		
		If "TODAS"$ _aFiliais[oCBox3:nAt]
			For _nx := 1 to len(_aFiliais)
				if ! ("TODAS"$ _aFiliais[_nx])
					If _nx == 1
						_cEmpPrcFI += substr(_aFiliais[_nx],1,2) + "'" + ","
					ElseIf _nx < len(_aFiliais)-1 .and. _nx > 1 
						_cEmpPrcFI += "'" + substr(_aFiliais[_nx],1,2) + "'" + ","
					Else
						_cEmpPrcFI += "'" + substr(_aFiliais[_nx],1,2) 
					EndIf 
				Endif			
			Next	
		Else
			_cEmpPrcFI := substr(_aFiliais[oCBox3:nAt],1,2)
		EndIf
		
		// FIM - DJALMA BORGES 08/12/2016

		BeginSql Alias _cAliasSQL

		SELECT *	
		FROM (
		SELECT *
		FROM ( 
		SELECT DA1_CODTAB, DA1_PRCVEN, DA1_FILIAL, DA1_CODPRO
		FROM %Table:DA1% (Nolock)
		WHERE %NotDel%
		AND DA1_CODPRO = %Exp:cProd%
		AND DA1_FILIAL IN (%Exp:_cEmpPrcFI%)
		) DA1_0

		INNER JOIN (
		SELECT B1_IPI, B1_COD
		FROM %Table:SB1% (NOLOCK)
		WHERE %NotDel% AND B1_FILIAL = %xfilial:SB1%
		)	SB1

		ON DA1_CODPRO = B1_COD

		) DA1

		INNER JOIN (
		SELECT DA0_ATIVO, DA0_DESCRI, DA0_DATDE, DA0_DATATE, DA0_CODTAB, DA0_FILIAL
		FROM %Table:DA0% (NOLOCK)
		WHERE %NotDel%
		AND DA0_FILIAL IN (%Exp:_cEmpPrcFI%) // DJALMA BORGES 08/12/2016
		AND DA0_ATIVO = 1
		) DA0

		ON DA1_CODTAB = DA0_CODTAB AND DA1_FILIAL = DA0_FILIAL
		
		ORDER BY DA1_CODTAB

		EndSql           

	Elseif _cOP == "ENDERECO"

		aadd(_aExibe, {"SBF","BF_FILIAL",,,,,,})
		aadd(_aExibe, {"SBF","BF_LOCAL",,,,,,})
		aadd(_aExibe, {"SBF","BF_LOCALIZ",,,,,,})
		aadd(_aExibe, {"SBF","BF_PRIOR",,,,,,})
		aadd(_aExibe, {"SBF","BF_QUANT",,,,,,})
		aadd(_aExibe, {"SBF","BF_EMPENHO",,,,,,})

		BeginSql Alias _cAliasSQL

		SELECT * 
		FROM %Table:SBF% (NOLOCK)
		WHERE %NotDel%
		AND BF_PRODUTO = %Exp:cProd%

		AND  (
		len(%Exp:_cLocais%) > ( CASE WHEN ( BF_PRODUTO <> '' ) THEN %Exp:_nTamLoc% END )
		OR
		len(%Exp:_cLocais%) = ( CASE WHEN ( charindex(BF_LOCAL,%Exp:_cLocais%) > 0 ) THEN %Exp:_nTamLoc% END )
		)

		AND  (
		len(%Exp:_cFiliais%) > ( CASE WHEN ( BF_PRODUTO <> '' ) THEN %Exp:_nTamFil% END )
		OR
		len(%Exp:_cFiliais%) = ( CASE WHEN ( charindex(BF_FILIAL,%Exp:_cFiliais%) > 0 ) THEN %Exp:_nTamFil% END )
		)

		ORDER BY BF_FILIAL, BF_LOCAL, BF_LOCALIZ	

		EndSql

	Elseif _cOP == "TELABUSC"

		aadd(_aExibe, {"SB1","B1_GRUPO"		,'TIPO'			,'TIPO'				,'TIPO',,,})
		aadd(_aExibe, {"ZZA",'ZZA_XCODRF'	,'REFERENCIA'	,'REFERENCIA'		,'REFERENCIA',,,})
		aadd(_aExibe, {"SB1","B1_COD"		,'ORIGINAL'		,'ORIGINAL'			,'ORIGINAL',,,})
		aadd(_aExibe, {"SB1","B1_DESC"		,'DESCRICAO'	,'DESCRIÇÃO'		,'DESCRICAO',,,})
		aadd(_aExibe, {"SB1",'B1_XAPLICA'	,'APLICACAO'	,'APLICAÇÃO'		,'APLICACAO',,,})
		_cAliasSQL := _cAlias

	Endif

	aHeader := MtHeader(_cAlias)
	aCols := MtCols(_cAliasSQL, aHeader)

	_aHeadCols[1] := aClone(aHeader)
	_aHeadCols[2] := aClone(acols)

	(_cAliasSQL)->(dbCloseArea())

Return(_aHeadCols)

/*/{Protheus.doc} MtHeader
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 
@param cAlias, undefined, descricao
@type function
/*/
Static Function MtHeader(cAlias)

	Local aHeader := {}
	Local _cContexto

	if len(_aExibe) == 0

		DbSelectArea("SX3")
		DbSetorder(1)

		dbSeek(cAlias)
		While !SX3->(Eof()) .And. (X3_ARQUIVO == cAlias )

			If  (cNivel >= X3_NIVEL) .and. X3USO(X3_USADO)
				aadd(_aExibe, {calias,SX3->X3_CAMPO,,,,,,})
			Endif

			SX3->(dbSkip())
		End

	Endif

	For _nx := 1 to len(_aExibe)

		DbSelectArea("SX3")
		DbSetorder(2)

		if dbSeek(_aExibe[_nx][2])

			If  (cNivel >= X3_NIVEL)

				Aadd(aHeader,{	iif(_aExibe[_nx][4]<> NIL , _aExibe[_nx][4] , X3TITULO()),;
				iif( _aExibe[_nx][3] <> NIL, _aExibe[_nx][3] ,X3_CAMPO),;
				X3_PICTURE,;
				X3_TAMANHO,;
				X3_DECIMAL,;
				iif(_aExibe[_nx][7] <> NIL, iif( _aExibe[_nx][7] == .f., '',If(X3_CAMPO == "DA0_CODTAB",'',X3_VALID)), If(X3_CAMPO == "DA0_CODTAB",'',X3_VALID)) ,;
				iif(_aExibe[_nx][8] <> NIL, _aExibe[_nx][8] , X3_USADO) ,;
				X3_TIPO,;
				If(X3_CAMPO == "DA0_CODTAB", "DA0", X3_F3),;
				X3_CONTEXT} )

			Endif

		Endif

	Next


Return(aHeader)

/*/{Protheus.doc} MtCols
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 
@param cAlias, undefined, descricao
@param aHeader, undefined, descricao
@type function
/*/
Static Function MtCols(_cAliasSQL, aHeader)

	Local aCols := {}
	Local _nPos
	Local _cMacro
	Local _aImp := {}

	DbSelectArea(_cAliasSQL)
	(_cAliasSQL)->(dbGoTop())
	While ! (_cAliasSQL)->(Eof())

		Aadd(aCols,Array(len(aHeader)+1))
		For nCntFor	:= 1 To len(aHeader)

			if ! SX3->(dbSeek(aHeader[nCntFor][2])  )	

				_nPos := ascan(_aExibe, {|x|  alltrim(x[3]) == alltrim(aHeader[nCntfor][2] ) } )

				if _nPos > 0

					if ! (alltrim(_aExibe[_nPos][5]) $ "DA1_ST.DA1_VALST") 					
						_cMacro := _aExibe[_nPos][5]
						aCols[Len(aCols)][nCntFor] := &_cMacro
					Else
						if (_cAliasSQL)->DA1_PRCVEN > 0
							//RETORNA ST DO PRODUTO / VALOR / ESTADO
							_aImp := U_ReturnST((_cAliasSQL)->DA1_PRCVEN, cProd, cUFST) 
							if alltrim(_aExibe[_nPos][5]) == "DA1_ST"
								aCols[Len(aCols)][nCntFor] := _aImp[15]
							elseif alltrim(_aExibe[_nPos][5]) == "DA1_VALST" 									
								aCols[Len(aCols)][nCntFor] := _aImp[16]
							Endif

						Else
							aCols[Len(aCols)][nCntFor] := _aExibe[_nPos][6]
						Endif
					Endif

				Endif

			Else

				If ( aHeader[nCntFor][10] != "V" )
					aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
				Else
					aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
				EndIf

			Endif				

		Next nCntFor
		aCols[Len(aCols)][len(aHeader)+1] := .F.

		DbSelectArea(_cAliasSQL)
		(_cAliasSQL)->(DbSkip())
	End

	if len(aCols) == 0

		Aadd(aCols,Array(len(aHeader)+1))

		For nCntFor	:= 1 To len(aHeader)

			if ! SX3->(dbSeek(aHeader[nCntFor][2])  )	

				_nPos := ascan(_aExibe, {|x|  alltrim(x[3]) == alltrim(aHeader[nCntfor][2] ) } )

				if _nPos > 0					
					aCols[Len(aCols)][nCntFor] := _aExibe[_nPos][6]
				Endif

			Else
				if aHeader[nCntFor][8] == 'C'
					aCols[Len(aCols)][nCntFor] := space(TamSx3(aHeader[nCntFor][2])[1] )
				Elseif aHeader[nCntFor][8] $ 'NM'
					aCols[Len(aCols)][nCntFor] := criavar(aHeader[nCntFor][2])
				Elseif aHeader[nCntFor][8] == 'D'
					aCols[Len(aCols)][nCntFor] := ctod('')
				Endif	
			Endif	

		Next nCntFor
		aCols[Len(aCols)][len(aHeader)+1] := .F.

	Endif

Return(aCols)

/*/{Protheus.doc} Refresh
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 
@type function
/*/
/* FUNÇÃO COMENTADA POR DJALMA BORGES 15/12/2016
User Function Refresh()

	if empty(dDataIni) .or. empty(dDataFim)
		MsgAlert("Preencha os parametros de pesquisa por período")
	Else

		AtuaBmp(cProd)
		CarregaVar()
		oDlg1:refresh(.t.)

	Endif

Return
*/

/*/{Protheus.doc} Queries
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 
@param _cTipo, undefined, descricao
@param _xParam, undefined, descricao
@type function
/*/
Static Function Queries(_cTipo, _xParam)

	Local _cAliasQ := GetNextAlias()
	Local _nReturn := 0
	Local _aArea := GetArea()

	if _cTipo == "A RECEBER"

		BeginSQL Alias _cAliasQ

		SELECT  isnull(C7_QUANT, 0) C7_QUANT
		FROM (
		SELECT SUM(C7_QUANT) C7_QUANT
		FROM %Table:SC7% (Nolock)
		WHERE %NotDel%
		AND C7_PRODUTO 	= %Exp:cProd%
		AND C7_CONAPRO 	= 'L'
		AND C7_QUJE < C7_QUANT
		AND  charindex(C7_LOCAL,%Exp:_cLocais%) > 0
		AND  charindex(C7_FILIAL,%Exp:_cFiliais%) > 0 // _cFiliais recebeu a primeira filiadl do array (chumbado)

		) SC7

		EndSql

		_nReturn := (_cAliasQ)->C7_QUANT

	/*
	Elseif _cTipo == "EM TRANSITO"

		BeginSQL Alias _cAliasQ

		SELECT  ISNULL(B2_QATU, 0) B2_QATU
		FROM (
		SELECT SUM(B2_QATU) B2_QATU
		FROM %Table:SB2% (Nolock)
		WHERE %NotDel%
		AND B2_COD 	= %Exp:cProd%
		AND B2_LOCAL = %Exp:_cLocTran%
		AND  charindex(B2_LOCAL,%Exp:_cLocais%) > 0
		AND  charindex(B2_FILIAL,%Exp:_cFiliais%) > 0 

		) SB2

		EndSql

		_nReturn := (_cAliasQ)->B2_QATU */

	Elseif _cTipo == "CONSUMO"

		_xParam := month(dDataBase) - _xParam
		if _xParam < 1
			_xParam := 12 + _xParam
		Endif

		_cCampo := "B3_Q"+strzero(_xParam,2)

		If _cFilTela <> ""
			dbSelectArea("SB3")
			dbSetOrder(1)
			if dbSeek(_cFiltela+cProd)
				_nReturn := SB3->&_cCampo
			Else
				_nReturn := 0
			EndIf
		Endif

	Endif

	if ! _cTipo $ "CONSUMO"
		(_cAliasQ)->(dbCloseArea())
	Endif

	RestArea(_aArea)
Return(_nReturn)

/*/{Protheus.doc} CarregaVar
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 
@param _lAbas, undefined, descricao
@type function
/*/
Static function CarregaVar(_lAbas)

	Local _aMeses := {}
	Local cAliasSldM := GetNextAlias() // DJALMA BORGES 16/12/2016
	
	Default oCBox3 := nil // DJALMA BORGES 16/12/2016
	Default oCBox2 := nil // DJALMA BORGES 20/12/2016
	
	Default _lAbas := .t.

	if _lAbas
		SZC->(dbSetOrder(1))
		if SZC->(dbSeek(xfilial()+__cUserId))

//			.or. SZC->ZC_DTINI 		<> dDataIni ; DJALMA BORGES 15/12/2016
//			.or. SZC->ZC_DTFIM 		<> dDataFim ;
			if SZC->ZC_NSELMES <> nSelMes ;
			.or. SZC->ZC_CPROD 		<> cProd ;
			.or. SZC->ZC_NBLOQ 		<> oCBox4:nAt ;
			.or. SZC->ZC_NFILIAL 	<> oCBox3:nAt ;
			.or. SZC->ZC_NLOCAL		<> oCBox2:nAt

				Reclock('SZC',.F.)

				SZC->ZC_CPROD 		:= cProd
				SZC->ZC_NBLOQ 		:= oCBox4:nAt
				SZC->ZC_NFILIAL 	:= oCBox3:nAt
//				SZC->ZC_DTINI 		:= dDataIni DJALMA BORGES 15/12/2016
//				SZC->ZC_DTFIM 		:= dDataFim		
				SZC->ZC_NSELMES		:= nSelMes
				SZC->ZC_NLOCAL		:= oCbox2:nAt

				SZC->(MsUnlock())

			Endif	

		Else	

			Reclock('SZC',.t.)

			SZC->ZC_FILIAL		:= xfilial('SZC')
			SZC->ZC_USERID		:= __cUserId
			SZC->ZC_CPROD 		:= cProd
			SZC->ZC_NBLOQ 		:= nBloq
			SZC->ZC_NFILIAL 	:= nFilial
//			SZC->ZC_DTINI 		:= dDataIni DJALMA BORGES 15/12/2016
//			SZC->ZC_DTFIM 		:= dDataFim		
			SZC->ZC_NSELMES		:= nSelMes
			SZC->ZC_NLOCAL		:= oCbox2:nAt

			SZC->(MsUnlock())

		Endif	

	Endif
	
	// TRATAR A STRING DOS COMBOS FILIAL/LOCAL PARA UTILIZAR NA RESPECTIVA QUERY - DJALMA BORGES 08/12/2016 - INÍCIO
	If oCBox3 <> nil
		if ! "TODAS" $ _aFiliais[oCBox3:nAt] .and. ! "TODOS" $ _aLocais[oCBox2:nAt] 
			_cFilTela := substr(_aFiliais[oCBox3:nAt],1,len(cFilAnt))
			_cLocTela := substr(_aLocais[oCBox2:nAt],1,TamSx3('NNR_CODIGO')[1])
			// FILTRA FILIAL E LOCAL
			BeginSql Alias cAliasSldM
				SELECT 
				SUM (B2_QATU) AS TTQTATU, 
				SUM (B2_RESERVA) AS TTRESERV, 
				SUM (B2_QATU) - SUM (B2_RESERVA) AS TTDISP, 
				SUM (B2_QPEDVEN) AS TTCART
				
				FROM %Table:SB2% (NOLOCK)
				
				WHERE %NotDel% 
				AND B2_FILIAL =%Exp:_cFilTela%
				AND B2_LOCAL = %Exp:_cLocTela%
				AND B2_COD = %Exp:cProd% 
			EndSql
		Endif
		
		if ! "TODAS" $ _aFiliais[oCBox3:nAt] .and. "TODOS" $ _aLocais[oCBox2:nAt]
			_cFilTela := substr(_aFiliais[oCBox3:nAt],1,len(cFilAnt))
			// FILTRA FILIAL E NÃO FILTRA LOCAL
			BeginSql Alias cAliasSldM
				SELECT 
				SUM (B2_QATU) AS TTQTATU, 
				SUM (B2_RESERVA) AS TTRESERV, 
				SUM (B2_QATU) - SUM (B2_RESERVA) AS TTDISP, 
				SUM (B2_QPEDVEN) AS TTCART
				
				FROM %Table:SB2% (NOLOCK)
				
				WHERE %NotDel% 
				AND B2_FILIAL =%Exp:_cFilTela%
				AND B2_COD = %Exp:cProd% 
			EndSql
		EndIf
		
		if "TODAS" $ _aFiliais[oCBox3:nAt] .and. ! "TODOS" $ _aLocais[oCBox2:nAt]
			_cLocTela := substr(_aLocais[oCBox2:nAt],1,TamSx3('NNR_CODIGO')[1])
			// FILTRA LOCAL E NÃO FILTRA FILIAL
			BeginSql Alias cAliasSldM
				SELECT 
				SUM (B2_QATU) AS TTQTATU, 
				SUM (B2_RESERVA) AS TTRESERV, 
				SUM (B2_QATU) - SUM (B2_RESERVA) AS TTDISP, 
				SUM (B2_QPEDVEN) AS TTCART
				
				FROM %Table:SB2% (NOLOCK)
				
				WHERE %NotDel% 
				AND B2_LOCAL = %Exp:_cLocTela%
				AND B2_COD = %Exp:cProd% 
			EndSql
		EndIf
		
		if "TODAS" $ _aFiliais[oCBox3:nAt] .and. "TODOS" $ _aLocais[oCBox2:nAt]
			// NÃO FILTRA FILIAL E NÃO FILTRA LOCAL
			BeginSql Alias cAliasSldM
				SELECT 
				SUM (B2_QATU) AS TTQTATU, 
				SUM (B2_RESERVA) AS TTRESERV, 
				SUM (B2_QATU) - SUM (B2_RESERVA) AS TTDISP, 
				SUM (B2_QPEDVEN) AS TTCART
				
				FROM %Table:SB2% (NOLOCK)
				
				WHERE %NotDel% 
				AND B2_COD = %Exp:cProd% 
			EndSql
		EndIf

		cSldFisico := (cAliasSldM)->TTQTATU
		cReservas  := (cAliasSldM)->TTRESERV
		cDisp      := (cAliasSldM)->TTDISP
		cCarteira  := (cAliasSldM)->TTCART
		
	EndIf
	// TRATAR A STRING DOS COMBOS FILIAL/LOCAL PARA UTILIZAR NA RESPECTIVA QUERY - DJALMA BORGES 08/12/2016 - FIM
	
	If _cFilTela <> ""
		SBZ->(dbSetOrder(1))	
		if  ! SBZ->(dbSeek(_cFilTela + cProd)) // DJALMA BORGES 20/12/2016
	
			If _nMsgSBZ < 2
				msgAlert('Produto não encontrado no indicador de produtos - SBZ')
				_lSBZ := .f.
				_nMsgSBZ += 1
			Else
				_nMsgSBZ := 0
			EndIf
	
		Else	
	
			_lSBZ := .T.
	
		Endif
	EndIf

	if _lSBZ
		cLocal 		:= SBZ->BZ_LOCPAD
		cPrazoRep 	:= SBZ->BZ_PE
		cEstMin		:= SBZ->BZ_EMIN
		cEstMax		:= SBZ->BZ_EMAX
		cLoteEco	:= SBZ->BZ_LE
		cUltPreco	:= SBZ->BZ_UPRC
	Else	
		cLocal 		:= 0
		cPrazoRep 	:= 0
		cEstMin		:= 0
		cEstMax		:= 0
		cLoteEco	:= 0		
		cUltPreco	:= 0
	Endif

	cCustoMed  := 0
	cPrecoVen  := 0
//	cSldFisico := 0
//	cReservas  := 0
//	cDisp      := 0
//	cCarteira  := 0

	// CALCULO DO CUSTO MÉDIO DO MATERIAL - INÍCIO
	If oCBox3 <> nil .and. oCBox2 <> nil
	
		If "TODAS" $ _aFiliais[oCBox3:nAt] // SE FILIAL SELECIONADA FOR "TODAS" CONSIDERA FILIAL LOGADA - DJALMA BORGES 20/12/2016
			_cFilTela := xFilial("SB2")
		EndIf
	
		dbSelectArea("SB2")
		dbSetOrder(1)
		//if _cLocais <> 'TODOS'
		If ! "TODOS" $ _aLocais[oCBox2:nAt] // ALTERADO PARA ! - DJALMA BORGES 22/12/2016
			dbSeek(_cFilTela+cProd+substr(_cLocais,1,2))
			_lLocal :=  'B2_LOCAL $ _cLocais'
		Else
			dbSeek(_cFilTela+cProd)
			_lLocal := '.t.'
		Endif	
	
		_nx := 0
		While ! SB2->(eof()) .and. SB2->B2_COD == cProd .and. &_lLocal      
	
			_nx += 1
			cCustoMed  += SB2->B2_CM1
//			cSldFisico += SB2->B2_QATU
//			cReservas  += SB2->B2_RESERVA
//			cDisp      += SB2->B2_QATU - SB2->B2_RESERVA
//			cCarteira  += SB2->B2_QPEDVEN
	
			SB2->(dbSkip())
	
		End
		cCustoMed /= _nx // SE LOCAL SELECIONADO FOR "TODOS" CALCULA MÉDIA ENTRE OS LOCAIS - DJALMA BORGES 20/12/2016
		
	EndIf	
	// CALCULO DO CUSTO MÉDIO DO MATERIAL - FIM 

	_aRet := MenorPreco()
	cPrecoVen := _aRet[1]
	cDescTab  := _aRet[2] 

	cDispVenda := cDisp - cCarteira
	cReceber   := Queries("A RECEBER")
//	cTransito  := Queries("EM TRANSITO")

	//PREPARA VETOR COM MES / ANO DOS N ULTIMOS MESES

//	cMesAtu    := Queries("CONSUMO",0)

	// ALTERADO POR DJALMA BORGES 26/12/2016 - INÍCIO
	
	cMes1      := Queries("CONSUMO",0)
	cMes2      := Queries("CONSUMO",1)
	cMes3      := Queries("CONSUMO",2)
	cMes4      := Queries("CONSUMO",3)
	cMes5      := Queries("CONSUMO",4)
	cMes6      := Queries("CONSUMO",5)
	
	_cSoma := cMes1 + cMes2 + cMes3 + cMes4 + cMes5 + cMes6
	
	// ALTERADO POR DJALMA BORGES 26/12/2016 - FIM
	
	/*
	cMes1      := Queries("CONSUMO",1)
	cMes2      := Queries("CONSUMO",2)
	cMes3      := Queries("CONSUMO",3)
	cMes4      := Queries("CONSUMO",4)
	cMes5      := Queries("CONSUMO",5)
	cMes6      := Queries("CONSUMO",6)
	*/

	cMedia := (cMes1 + cMes2 + cMes3 + cMes4 + cMes5 + cMes6)
	if cMedia <> 0
		cMedia := round(cMedia/6,2)
	Endif

	if _lAbas

		_aHeadCols := U_MtHdCols("SC9","RESERVA")
		_oGetDRES:aHeader   := _aHeadCols[1]
		_oGetDRES:aCols		:= _aHeadCols[2]
		_oGetDRES:ForceRefresh(.T.)
		_oFldRes:refresh()

		_aHeadCols := U_MtHdCols("SC7","RECEBER")
		_oGetDREC:aHeader   := _aHeadCols[1]
		_oGetDREC:aCols		:= _aHeadCols[2]
		_oGetDREC:ForceRefresh()

		_aHeadCols := U_MtHdCols("SC6","CARTEIRA")
		_oGetDCAR:aHeader   := _aHeadCols[1]
		_oGetDCAR:aCols		:= _aHeadCols[2]
		_oGetDCAR:ForceRefresh()

		_aHeadCols := U_MtHdCols("SD1","ENTRADAS")
		_oGetDENT:aHeader   := _aHeadCols[1]
		_oGetDENT:aCols		:= _aHeadCols[2]
		_oGetDENT:ForceRefresh()

		_aHeadCols := U_MtHdCols("SD2","SAIDAS")
		_oGetDSAI:aHeader   := _aHeadCols[1]
		_oGetDSAI:aCols		:= _aHeadCols[2]
		_oGetDSAI:ForceRefresh()

		_aHeadCols := U_MtHdCols("SB3","CONSUMO")
		_oGetDCON:aHeader   := _aHeadCols[1]
		_oGetDCON:aCols		:= _aHeadCols[2]
		_oGetDCON:ForceRefresh()

		_aHeadCols := U_MtHdCols("SBF","ENDERECO")
		_oGetDSLE:aHeader   := _aHeadCols[1]
		_oGetDSLE:aCols		:= _aHeadCols[2]
		_oGetDSLE:ForceRefresh()

		_aHeadCols := U_MtHdCols("ZZA","REFERENCIA")
		_oGetDREF:aHeader   := _aHeadCols[1]
		_oGetDREF:aCols		:= _aHeadCols[2]
		_oGetDREF:ForceRefresh()

		_aHeadCols := U_MtHdCols("SA5","FORNECEDOR")
		_oGetDFOR:aHeader   := _aHeadCols[1]
		_oGetDFOR:aCols		:= _aHeadCols[2]
		_oGetDFOR:ForceRefresh()


		_aMeses := PrepMeses(dDataBase)

		oSayM1:cCaption := _aMeses[1] 
		oSayM2:cCaption := _aMeses[2] 	
		oSayM3:cCaption := _aMeses[3] 	
		oSayM4:cCaption := _aMeses[4] 	
		oSayM5:cCaption := _aMeses[5] 	
		oSayM6:cCaption := _aMeses[6]	


	Endif



Return


/*/{Protheus.doc} PrepMeses
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 
@param _dData, undefined, descricao
@type function
/*/
Static Function PrepMeses(_dData)
	Local _nx
	Local _aRetMeses := {}
	Local _aMeses := {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro" }

//	_nMes := month(_dData)
	_nMes := month(_dData) // ALTERADO POR DJALMA BORGES 26/12/2016

	For _nx := 1 to  6

		_nMes -= 1
		if _nMes == 0
			_nMes := 12
		Endif

		AAdd(_aRetMeses, _aMeses[_nMes])
	Next

Return(_aRetMeses)

/*/{Protheus.doc} ReturnST
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 
@param nValor, undefined, descricao
@param cProd, undefined, descricao
@param _cUFST, undefined, descricao
@type function
/*/
User Function ReturnST(nValor, cProd, _cUFST)  //RETORNA ST DO PRODUTO / VALOR / ESTADO
	Local aImp := {}
	Local cTes := GETNEWPAR("LT_TESST","501")

	aImp := fCalcImp("ZZZZZZ",_cUFST,"S",cProd,cTes,1,nValor,nValor)


Return(aImp)



/*/{Protheus.doc} fCalcImp
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 
@param cCliente, undefined, descricao
@param cLoja, undefined, descricao
@param cTipo, undefined, descricao
@param cProduto, undefined, descricao
@param cTes, undefined, descricao
@param nQtd, undefined, descricao
@param nPrc, undefined, descricao
@param nValor, undefined, descricao
@type function
/*/
Static Function fCalcImp(cCliente,cLoja,cTipo,cProduto,cTes,nQtd,nPrc,nValor)   
	//_cTipoCli := Posicione("SA1",1,xFilial("SA1")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA,"A1_TIPO")    
	//fImpostos(SCJ->CJ_CLIENTE,SCJ->CJ_LOJA,_cTipoCli,SCK->CK_PRODUTO,SCK->CK_TES,SCK->CK_QTDVEN,SCK->CK_PRCVEN,SCK->CK_VALOR)

	Local aImp := {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

	// -------------------------------------------------------------------
	// Realiza os calculos necessários
	// -------------------------------------------------------------------
	MaFisIni(cCliente,;                             // 1-Codigo Cliente/Fornecedor
	cLoja,;                                // 2-Loja do Cliente/Fornecedor
	"C",;                                  // 3-C:Cliente , F:Fornecedor
	"N",;                                  // 4-Tipo da NF
	cTipo,;                                // 5-Tipo do Cliente/Fornecedor
	MaFisRelImp("MTR700",{"SC5","SC6"}),;  // 6-Relacao de Impostos que suportados no arquivo
	,;                                     // 7-Tipo de complemento
	,;                                     // 8-Permite Incluir Impostos no Rodape .T./.F.
	"SB1",;                                // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
	"MTR700")                              // 10-Nome da rotina que esta utilizando a funcao

	// -------------------------------------------------------------------
	// Monta o retorno para a MaFisRet
	// -------------------------------------------------------------------
	MaFisAdd(cProduto, cTes, nQtd, nPrc, 0, "", "",, 0, 0, 0, 0, nValor, 0)

	//Monta um array com os valores necessários

	aImp[1] := cProduto
	aImp[2] := cTes
	aImp[3] := MaFisRet(1,"IT_ALIQICM")  //Aliquota ICMS
	aImp[4] := MaFisRet(1,"IT_VALICM")  //Valor de ICMS
	aImp[5] := MaFisRet(1,"IT_VALIPI")  //Valor de IPI
	aImp[6] := MaFisRet(1,"IT_ALIQCOF") //Aliquota de calculo do COFINS
	aImp[7] := MaFisRet(1,"IT_ALIQPIS") //Aliquota de calculo do PIS
	aImp[8] := MaFisRet(1,"IT_ALIQPS2") //Aliquota de calculo do PIS 2
	aImp[9] := MaFisRet(1,"IT_ALIQCF2") //Aliquota de calculo do COFINS 2
	aImp[10]:= MaFisRet(1,"IT_DESCZF")  //Valor de Desconto da Zona Franca de Manaus
	aImp[11]:= MaFisRet(1,"IT_VALPIS")  //Valor do PIS
	aImp[12]:= MaFisRet(1,"IT_VALCOF")  //Valor do COFINS
	aImp[13]:= MaFisRet(1,"IT_BASEICM") //Valor da Base de ICMS
	aImp[14]:= MaFisRet(1,"IT_BASESOL") //Base do ICMS Solidario
	aImp[15]:= MaFisRet(1,"IT_ALIQSOL") //Aliquota do ICMS Solidario
	aImp[16]:= MaFisRet(1,"IT_VALSOL" ) //Valor Solidário
	aImp[17]:= MaFisRet(1,"IT_MARGEM")  //Margem de lucro para calculo da Base do ICMS Sol.

	//Não sei bem o uso dessas funções
	MaFisSave()
	MaFisEnd()

Return aImp


/*/{Protheus.doc} Vld_Local
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 

@type function
/*/
Static Function Vld_Local(_lPrime)
	_cLocais := ""

	if  ! _lPrime
		if "TODOS"$ _aLocais[oCBox2:nAt]
			For _nx := 1 to len(_aLocais)
				if ! ("TODOS"$ _aLocais[_nx])
					_cLocais += substr(_aLocais[_nx],1,TamSx3('NNR_CODIGO')[1])+"."
				Endif			
			Next	
		Else
			_cLocais := substr(_aLocais[oCBox2:nAt],1,TamSx3('NNR_CODIGO')[1])
		Endif

		Carregavar()
	Else	
		_cLocais := substr(_aLocais[1],1,TamSx3('NNR_CODIGO')[1])


	Endif


Return(.t.)


/*/{Protheus.doc} Vld_Filial
//TODO Descrição auto-gerada.
@author totvsremote
@since 25/04/2016
@version undefined

@type function
/*/
Static Function Vld_Filial(_lPrime)
	
	_cFiliais := ""

	if ! _lPrime
		if "TODAS"$ _aFiliais[oCBox3:nAt]
			For _nx := 1 to len(_aFiliais)
				if ! ("TODAS"$ _aFiliais[_nx])

					_cFiliais  += substr(_aFiliais[_nx],1,len(cFilAnt))+"."

				Endif			
			Next	
		Else
			_cFiliais := substr(_aFiliais[oCBox3:nAt],1,len(cFilAnt))
		Endif

		CarregaVar()
	Else	
		_cFiliais  := substr(_aFiliais[1],1,len(cFilAnt))

	Endif

Return(.t.)

/*/{Protheus.doc} Vld_Bloq
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 

@type function
/*/
Static Function Vld_Bloq()

	Processa({|| Vld_BloqA() },"Filtrando Produtos ...")

Return(.t.)

/*/{Protheus.doc} Vld_BloqA
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 

@type function
/*/
Static Function Vld_BloqA()
	Local _nBloq :=	oCBox4:nAt
	Local _cAliasCI := GetNextAlias()
	Local _cBloq := ' .1.2'

	if _nBloq == 2
		_cBloq := ' .2'
	Endif

	_cBloqueados := _cBloq

	ProcRegua(SB1->(Reccount()))
	CargaIni(_cAliasCI)

	(_cAliasCI)->(dbGoTop())
//	cBmpRep	   	:= (_cAliasCI)->B1_BITMAP
	cProd 		:= (_cAliasCI)->B1_COD

	(_cAliasCI)->(dbCloseArea())      


	CarregaVar()

Return(.t.)



/*/{Protheus.doc} Vld_Data
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 

@type function
/*/
Static Function Vld_Data()

	CarregaVar()

Return(.t.)

/*/{Protheus.doc} Vld_SelMes
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 

@type function
/*/
Static Function Vld_SelMes()

	dMesIni := dDataBase - (nSelMes * 30 )
	CarregaVar()

Return

/*/{Protheus.doc} CargaIni
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 
@param _cAliasCI, undefined, descricao
@param _cBloq, undefined, descricao
@type function
/*/
Static Function CargaIni(_cAliasCI)

	BeginSql Alias _cAliasCI

	%noparser%

	SELECT  DISTINCT(B1_COD), 
	B1_DESC, 
	B1_GRUPO, 
	B1_BITMAP, 
	ISNULL(ZZA_XCOD, '') AS ZZA_XCOD, 
	ISNULL(ZZA_XCODRF, '') AS ZZA_XCODRF

	FROM (
	SELECT B1_COD, B1_DESC, B1_GRUPO, B1_BITMAP	
	FROM %Table:SB1%(NOLOCK)
	WHERE %NotDel%	
	AND  charindex(B1_MSBLQL,%Exp:_cBloqueados%) > 0
	AND NOT B1_GRUPO IN ('XXX','FIS','OLD','NDF')	
	) SB1

	INNER JOIN(
	SELECT * 
	FROM %Table:SBM% (Nolock)
	WHERE %NotDel%
	//	AND BM_CLASGRU <> '1'
	) SBM

	ON B1_GRUPO = BM_GRUPO

	LEFT JOIN (
	SELECT A5_PRODUTO, A5_CODPRF
	FROM %Table:SA5% (NOLOCK)	
	WHERE %NotDel%
	) SA5

	ON B1_COD = A5_PRODUTO

	LEFT JOIN (
	SELECT ZZA_XCOD, ZZA_XCODRF
	FROM %Table:ZZA% (NOLOCK)
	WHERE %NotDel%
	) ZZA

	ON B1_COD = ZZA_XCOD

	WHERE B1_COD 	LIKE RTRIM(%Exp:cProd%)+'%'
	OR A5_CODPRF 	LIKE RTRIM(%Exp:cProd%)+'%'
	OR ZZA_XCODRF 	LIKE RTRIM(%Exp:cProd%)+'%'
	OR ZZA_XCOD 	LIKE RTRIM(%Exp:cProd%)+'%'
	OR B1_DESC		LIKE RTRIM(%Exp:cProd%)+'%'

	ORDER BY B1_COD		

	EndSql

Return


/*/{Protheus.doc} VisualX
//TODO Observação auto-gerada.
@author totvsremote
@since 07/01/2016
@version 

@type function
/*/
Static Function VisualX()
	
	Local _aAreaX := GetArea()
	Local nReg,cAlias,nOpc
	Local nOpc := 2
	Local nFolder := _oFolder:nOption
	Local _cFilAtu := cFilAnt
	
	Private aRotina	  := { 	{"Pesquisar" ,"AxPesqui"  ,    0 , 1,  0, .F.},;
							{"Visualizar","AxVisual",      0 , 2,  0, .F.}}

	if nFolder == 1

		_nPFil 		:= ascan(_oGetDRES:aHeader, {|x,y|  alltrim(x[2]) == 'C9_FILIAL' })
		_nPPV 		:= ascan(_oGetDRES:aHeader, {|x,y|  alltrim(x[2]) == 'C9_PEDIDO' })
		_nPItPv		:= ascan(_oGetDRES:aHeader, {|x,y|  alltrim(x[2]) == 'C9_ITEM' })
		_nPSeqPv	:= ascan(_oGetDRES:aHeader, {|x,y|  alltrim(x[2]) == 'C9_SEQUEN' })

		_cFilial	:=	_oGetDRES:aCols[_oGetDRES:nAt][_nPFil]
		_cPedido	:=	_oGetDRES:aCols[_oGetDRES:nAt][_nPPV]
		_cItem		:=  _oGetDRES:aCols[_oGetDRES:nAt][_nPItPv]
		_cSequen	:=	_oGetDRES:aCols[_oGetDRES:nAt][_nPSeqPv]

		if !empty(_cPedido)
			SC9->(dbSetOrder(1))
			SC9->(dbSeek(_cFilial + _cPedido + _cItem + _cSequen))

			nReg := SC9->(Recno())
			cAlias := 'SC9'
			cCadastro := 'Consulta de Reservas'
			INCLUI = .F.
			aRotina[2][2] := 'AXVISUAL'
			AXVISUAL(cAlias,nReg,nOpc)
		Endif

	elseif nFolder == 2

		_nPFil 		:= ascan(_oGetDREC:aHeader, {|x,y|  alltrim(x[2]) == 'C7_FILIAL' })
		_nPNum 		:= ascan(_oGetDREC:aHeader, {|x,y|  alltrim(x[2]) == 'C7_NUM' })

		_cFilial	:=	_oGetDREC:aCols[_oGetDRES:nAt][_nPFil]
		_cNum		:=	_oGetDREC:aCols[_oGetDRES:nAt][_nPNum]

		if ! empty(_cNum)
			SC7->(dbSetOrder(1))
			SC7->(dbSeek(_cFilial + _cNum ))

			nReg := SC7->(Recno())
			cAlias := 'SC7'
			NTIPOPED = 1
			INCLUI = .F.
			L120AUTO := .F.
			cCadastro := 'Consulta Pedido de Compra'
			aRotina[2][2] := 'A120PEDIDO'
			A120Pedido(cAlias,nReg,nOpc)
		Endif

	Elseif nFolder == 3

		_nPFil 		:= ascan(_oGetDCAR:aHeader, {|x,y|  alltrim(x[2]) == 'C6_FILIAL' })
		_nPNum 		:= ascan(_oGetDCAR:aHeader, {|x,y|  alltrim(x[2]) == 'C6_NUM' })

		_cFilial	:=	_oGetDCAR:aCols[_oGetDRES:nAt][_nPFil]
		_cNum		:=	_oGetDCAR:aCols[_oGetDRES:nAt][_nPNum]

		if ! empty(_cNum)
			SC5->(dbSetOrder(1))
			SC5->(dbSeek(_cFilial + _cNum ))

			nReg := SC5->(Recno())
			cAlias := 'SC5'
			aRotina[2][2] := 'A410VISUAL'
			cCadastro := 'Consulta de Pedidos em Carteira'
			A410Visual(cAlias,nReg,nOpc)
		Endif

	Elseif nFolder == 4

		_nPFil 		:= ascan(_oGetDENT:aHeader, {|x,y|  alltrim(x[2]) == 'D1_FILIAL' })
		_nPDOC 		:= ascan(_oGetDENT:aHeader, {|x,y|  alltrim(x[2]) == 'D1_DOC' })
		_nPSerie	:= ascan(_oGetDENT:aHeader, {|x,y|  alltrim(x[2]) == 'D1_SERIE' })
		_nPForn		:= ascan(_oGetDENT:aHeader, {|x,y|  alltrim(x[2]) == 'D1_FORNECE' })
		_nPLoja		:= ascan(_oGetDENT:aHeader, {|x,y|  alltrim(x[2]) == 'D1_LOJA' })

		_cFilial	:=	_oGetDENT:aCols[_oGetDRES:nAt][_nPFil]
		_cDOC		:=	_oGetDENT:aCols[_oGetDRES:nAt][_nPDOC]
		_cSerie		:=  _oGetDENT:aCols[_oGetDRES:nAt][_nPSerie]
		_cForn		:=	_oGetDENT:aCols[_oGetDRES:nAt][_nPForn]
		_cLoja		:=	_oGetDENT:aCols[_oGetDRES:nAt][_nPLoja]

		if ! empty(_cDOC)
			SF1->(dbSetOrder(1))
			SF1->(dbSeek(_cFilial + _cDOC + _cSerie + _cForn + _cLoja))

			nReg := SF1->(Recno())
			cAlias := 'SF1'
			aRotina[2][2] := 'A100VISUAL'
			LINTEGRACAO := .f.
			cCadastro := 'Consulta Documento de Entrada'
			//		A100Visual(cAlias,nReg,nOpc)
			A103NFiscal(cAlias,nReg,nOpc)
		Endif

	Elseif nFolder == 5

		_nPFil 		:= ascan(_oGetDSAI:aHeader, {|x,y|  alltrim(x[2]) == 'D2_FILIAL' })
		_nPDOC 		:= ascan(_oGetDSAI:aHeader, {|x,y|  alltrim(x[2]) == 'D2_DOC' })
		_nPSerie	:= ascan(_oGetDSAI:aHeader, {|x,y|  alltrim(x[2]) == 'D2_SERIE' })
		_nPCli		:= ascan(_oGetDSAI:aHeader, {|x,y|  alltrim(x[2]) == 'D2_CLIENTE' })
		_nPLoja		:= ascan(_oGetDSAI:aHeader, {|x,y|  alltrim(x[2]) == 'D2_LOJA' })

		_cFilial	:=	_oGetDSAI:aCols[_oGetDRES:nAt][_nPFil]
		_cDOC		:=	_oGetDSAI:aCols[_oGetDRES:nAt][_nPDOC]
		_cSerie		:=  _oGetDSAI:aCols[_oGetDRES:nAt][_nPSerie]
		_cCli		:=	_oGetDSAI:aCols[_oGetDRES:nAt][_nPCli]
		_cLoja		:=	_oGetDSAI:aCols[_oGetDRES:nAt][_nPLoja]

		if ! empty(_cDoc)
			SF2->(dbSetOrder(1))
			SF2->(dbSeek(_cFilial + _cDOC + _cSerie + _cCli + _cLoja))

			nReg := SF2->(Recno())
			cAlias := 'SF2'
			nReg := _oGetDSAI:nAt
			aRotina[2][2] := 'MC090VISUAL'
			cCadastro := 'Consulta Documento de Saida'

			Mc090Visual(cAlias,nReg,nOpc)
		Endif

	Endif
	
	cFilAnt := _cFilAtu
	
	RestARea(_aAreax)
Return



/*/{Protheus.doc} MenorPreco
//TODO Descrição auto-gerada.
@author totvsremote
@since 26/01/2016
@version undefined

@type function
/*/
Static Function MenorPreco()

	Local _cAliasPreco := GetNextAlias()
	Local _nTamFil := len(DA1->DA1_FILIAL)
	Local _cFilPrc := _cFiliais
//	Local _cTable := 'DA1' VARIÁVEL NÃO ESTÁ SENDO UTILIZADA - DJALMA BORGES 08/12/2016
	Local _aRet := {,}
	
	if len(_cFilPrc) > _nTamfil

		_cFilPrc := GetNewPar('CB_FILPRC', '01')

	Else

//		_cFilPrc := substr(_cFilPrc,3,2)
		_cFilPrc := substr(_cFilPrc,1,2) // DJALMA BORGES 23/12/2016

	Endif
	
//	_cTable += substr(_cFilPrc,1,2)+'0'
//	_cTable := '%'+_cTable+'%'

	BeginSql Alias _cAliasPreco

	SELECT *
	FROM (
	SELECT *
	FROM %Table:DA1% (NOLOCK)
	WHERE %NotDel%
	AND DA1_CODPRO = %Exp:cProd%
	AND DA1_FILIAL = %Exp:_cFilPrc%
	)DA1

	INNER JOIN (
	SELECT *
	FROM %Table:DA0% (NOLOCK)
	WHERE %NotDel%
	) DA0

	ON DA1_FILIAL = DA0_FILIAL AND DA1_CODTAB = DA0_CODTAB			


	ORDER BY DA1_PRCVEN

	EndSql

	(_cAliasPreco)->(dbGoTop())
	if !(_cAliasPreco)->(eof()) 
		_aRet[1] := (_cAliasPreco)->DA1_PRCVEN
		_aRet[2] := (_cAliasPreco)->DA0_DESCRI
	Endif

	(_cAliasPreco)->(dbCloseArea())

Return(_aRet)



/*/{Protheus.doc} VldProd
//TODO Observação auto-gerada.
@author totvsremote
@since 05/01/2016
@version 1.0 

@type function
/*/
User Function VldPrd1()
	Local _aArea := getArea()
	Local _lRet := .t.     
	Local _nPos := 0
	Local _cAlias := GetNextAlias()
	Local _cProd := alltrim(cProd)
	Local cQuery := ""
	Local cAliasDMat := GetNextAlias() // DJALMA BORGES 16/12/2016
	Local cProdNew := "" // DJALMA BORGES 26/12/2016
	aItens := {}

	if empty(_cProd)
		MsgAlert("Codigo de produto não preenchido.")
		_lRet := .f.
	Else	

		BeginSql Alias _cAlias
	
		SELECT TIPO
		,CASE 
			WHEN B1_COD <> ''
				THEN B1_COD
			WHEN ZZA_XCODRF <> ''
				THEN ZZA_XCODRF
			WHEN A5_CODPRF <> ''
				THEN A5_CODPRF
			END REFERENCIA
	
		,B1_COD1 AS ORIGINAL
		,B1_DESC AS DESCRICAO
		,ISNULL(APLICACAO, '') AS APLICACAO
		
		FROM (
		SELECT B1_FILIAL
			,CASE 
				WHEN B1_COD <> ''
					THEN 'ORI'
				END TIPO
			,B1_COD
			,'' AS ZZA_XCODRF
			,'' AS A5_CODPRF
			,B1_DESC
			,B1_COD AS B1_COD1
			,B1_XAPLICA AS APLICACAO
		
		FROM (
			SELECT *
			FROM %Table:SB1% (NOLOCK)
			WHERE %NotDel%
				AND charindex(B1_MSBLQL, %Exp:_cBloqueados%) > 0
				AND NOT B1_GRUPO IN (
					'XXX'
					,'FIS'
					,'OLD'
					,'NDF'
					)
				AND (B1_COD LIKE RTRIM(%Exp:_cProd%) + '%'
				OR B1_DESC LIKE RTRIM(%Exp:_cProd%) + '%')
			) SB1
		
		UNION
		
		(
			SELECT ZZA_FILIAL
				,CASE 
					WHEN ZZA_XCODRF <> ''
						THEN 'OPC'
					END TIPO
				,'' AS B1_COD
				,ZZA_XCODRF
				,'' AS A5_CODPRF
				,B1_DESC
				,B1_COD AS B1_COD1
				,ZZA_XAPLIC AS APLICACAO
	
			FROM (
				SELECT *
				FROM %Table:ZZA% (NOLOCK)
				WHERE %NotDel%
					AND ZZA_XCODRF LIKE RTRIM(%Exp:_cProd%) + '%'
				) ZZA
	
			INNER JOIN (
	
				SELECT B1_FILIAL
					,B1_COD
					,B1_DESC
				FROM %Table:SB1% (NOLOCK)
				WHERE %NotDel%
					AND charindex(B1_MSBLQL, %Exp:_cBloqueados%) > 0
					AND NOT B1_GRUPO IN (
						'XXX'
						,'FIS'
						,'OLD'
						,'NDF'
						)
				) SB1_ZZA ON ZZA_XCOD = B1_COD
			)
		
		UNION
		
		(
			SELECT A5_FILIAL
				,CASE 
					WHEN A5_CODPRF <> ''
						THEN 'FOR'
					END TIPO
				,'' AS B1_COD
				,'' AS ZZA_XCODRF
				,A5_CODPRF
				,B1_DESC
				,B1_COD AS B1_COD1
				,B1_XAPLICA AS APLICACAO
	
			FROM (
				SELECT *
				FROM %Table:SA5% (NOLOCK)
				WHERE %NotDel%
					AND A5_CODPRF LIKE RTRIM(%Exp:_cProd%) + '%'
				) SA5
	
			INNER JOIN (
				SELECT B1_FILIAL
					,B1_COD
					,B1_DESC
					,B1_XAPLICA
	
				FROM %Table:SB1% (NOLOCK)
				WHERE %NotDel%
					AND charindex(B1_MSBLQL, %Exp:_cBloqueados%) > 0
					AND NOT B1_GRUPO IN (
						'XXX'
						,'FIS'
						,'OLD'
						,'NDF'
						)
				) SB1_SA5 ON A5_PRODUTO = B1_COD
			)
		) TELAPRE
	
		ORDER BY REFERENCIA
	
		EndSql

		(_cAlias)->(dbGotop())
		if (_cAlias)->(eof())
			MsgAlert("Codigo não encontrado.")
			_lRet := .f.
		Endif	

	Endif

	if _lRet

		//VERIFICA SE SELEÇÃO TIVER MAIS QUE 1 ITEM, CHAMA TELABUSC PARA SELEÇÃO DAS REFERENCIAS
		_nCount := 0
		(_cAlias)->(dbGoTop())
		While ! (_cAlias)->(eof())

			_nCount += 1
			if _nCount > 1
				exit
			Endif	

			(_cAlias)->(dbSkip())
		End	

		if _nCount > 1
			_cProd := cProd
			cProd := u_telabusc(_cAlias)

			if empty(cProd)
				cProd := _cProd
			Endif	
		Else	
			(_cAlias)->(dbGotop())
//			cProd := (_cAlias)->B1_C0D	
			cProd := (_cAlias)->REFERENCIA // DJALMA BORGES 16/12/2016
		Endif

		SB1->(dbSetOrder(1))
		If ! SB1->(dbSeek(xfilial("SB1") + cProd))
			ZZA->(dbSetOrder(2))
			If ZZA->(dbSeek(xFilial("ZZA") + cProd ))
				cProd := ZZA->ZZA_XCOD
				SB1->(dbSeek(xfilial("SB1") + cProd))
			Else
				SA5->(dbSetOrder(2))
				If SA5->(dbSeek(xFilial("SA5") + cProd))
					cProd := SA5->A5_PRODUTO
					SB1->(dbSeek(xfilial("SB1") + cProd))
				EndIf
			EndIf
		Else
			cProd := SB1->B1_COD
		EndIf
		
		cDesc     := SB1->B1_DESC
		_cNCM     := SB1->B1_POSIPI
		_nPesoLiq := SB1->B1_PESO
		_nPesoBru := SB1->B1_PESBRU

		SBZ->(dbSetOrder(1))
		If SBZ->(dbSeek("0101" + cProd))
			_nIPI1    := SBZ->BZ_IPI
		Else
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + cProd))
			_nIPI1 := SB1->B1_IPI
		EndIf	
		If SBZ->(dbSeek("0102" + cProd))
			_nIPI2    := SBZ->BZ_IPI
		Else
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + cProd))
			_nIPI2 := SB1->B1_IPI	
		EndIf	
		If SBZ->(dbSeek("0201" + cProd))
			_nIPI3    := SBZ->BZ_IPI
		Else
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + cProd))
			_nIPI3 := SB1->B1_IPI	
		EndIf	
		If SBZ->(dbSeek("0202" + cProd))
			_nIPI4    := SBZ->BZ_IPI
		Else
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + cProd))
			_nIPI4 := SB1->B1_IPI	
		EndIf	
		
		// FILIAL SELECIONADA NA TELA OU FILIAL LOGADA SE ESTIVER SELECIONADA A OPÇÃO TODAS - DJALMA BORGES 20/12/2016
		if ! "TODAS" $ _aFiliais[oCBox3:nAt] 
			_cFilTela := substr(_aFiliais[oCBox3:nAt],1,len(cFilAnt))
		Else
			_cFilTela := xFilial("SBZ")
		EndIf
		
		SBZ->(dbSetOrder(1))	
		if  ! SBZ->(dbSeek(_cFilTela + cProd)) // DJALMA BORGES 20/12/2016

			If _nMsgSBZ < 2
				msgAlert('Produto não encontrado no indicador de produtos - SBZ')
				_lSBZ := .f.
				_nMsgSBZ += 1
			Else
				_nMsgSBZ := 0
			EndIf

		Else	
			
			_lSBZ := .T.

		Endif
		
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xfilial("SB1")+cProd))
		cDesc := SB1->B1_DESC

	Endif	
	//__________________________________________________________________________________________

	if _lRet
		AtuaBmp(cProd)
		CarregaVar()
		oDlg1:refresh(.t.)
	Endif


	RestArea(_aArea)
Return(_lRet)





/*/{Protheus.doc} TelaBusc
//Exibe getdados para seleção de produtos encontrados em query da função u_vldprd1.
@author totvsremote
@since 29/04/2016
@version undefined
@param _cAlias
@type function
/*/
User Function TelaBusc(_cAlias)

	Local aHeadCols := {}
	Local _aButtons := {}
	Local nOpc := GD_INSERT+GD_DELETE+GD_UPDATE

	Local cLinOk 	:= 'allwaystrue()'
	Local cTudoOk 	:= 'allwaystrue()'
	Local cFieldOk 	:= 'allwaystrue()'
	Local cDelOk 	:= 'allwaystrue()'

	Local aObjects := {}
	Local aInfo := {}
	Local aSizeAut := {}
	Local aPosObj := {}

	Private bOk 		:= {|| Seleprod(1), oDlgBusc:End() }
	Private bCancel 	:= {|| Seleprod(0), oDlgBusc:End() }
	Private cProduto 	:= cProd
//	Private _nRad 		:= 1

	//COORDENADAS 
	aSizeAut	:= MsAdvSize(.T.,.F.)
	AAdd( aObjects, { 100,  100, .t., .t. } )
//	AAdd( aObjects, { 100,   50, .t., .f. } )


	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }

	aPosObj := MsObjSize( aInfo, aObjects )
	//_______________________________________________

	oDlgBusc    := MSDialog():New(aSizeAut[7],0 , aSizeAut[6],aSizeAut[5],"Consulta Produto",,,.F.,,,,,,.T.,,,.T. )


	_aHeadCols := U_MtHdCols(_cAlias,"TELABUSC")

	_oGetDBusc      := MsNewGetDados():New(	aPosObj[1][1], aPosObj[1][2], aPosObj[1][3], aPosObj[1][4],; 
	nOpc		,; 
	cLinOk		,; 
	cTudoOk		,; 
	,;
	,;
	,;
	500			,;
	cFieldOk	,;
	''			,;
	cDelOk		,;
	oDlgBusc	,;
	_aHeadCols[1],;
	_aHeadCols[2] )


	_oGetDBusc:oBrowse:bLDblClick := bOk

//	GoRMenu1   := TGroup():New( aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],"Ordenar por :",oDlgBusc,CLR_BLACK,CLR_WHITE,.T.,.F. )
//	oRMenu1    := TRadMenu():New( aPosObj[2,1]+6,aPosObj[2,2]+6,{"Codigo","Referencia","Fornecedor","TODOS"},{|u| If(PCount()>0,_nRad:=u,_nRad)},oDlgBusc,,{|| TelaB_ord() },CLR_BLACK,CLR_WHITE,"",,,040,13,,.F.,.F.,.T. )




	oDlgBusc:Activate(,,,.T.,,,EnchoiceBar(ODLGBusc, {|| nOpca:=1,SeleProd(), ODLGBusc:End() }, {|| nOpca:=0 ,ODLGBusc:End()},,_aButtons))

Return(cProduto)




/*/{Protheus.doc} blDBLClik
//Retorna produto selecionado
@author totvsremote
@since 01/02/2016
@version undefined

@type function
/*/
Static Function  SeleProd()
	Local _nPProd := ascan(_oGetDBusc:aHeader, {|x,y|  alltrim(x[2]) == 'ORIGINAL' })

	cProduto := _oGetDBusc:aCols[_oGetDBusc:nAt][_nPProd]

Return(cProduto)

/*/{Protheus.doc} TelaB_Ord
//Ordenação da consulta iniciado por
@author totvsremote
@since 03/05/2016
@version undefined

@type function
/*/

/*
Static Function TelaB_Ord()
Local _cOrder := ''
Private _cAliasBusc := GetNextAlias()

if _nRad == 1 .or. _nRad == 4
	
	_cOrder := 'B1_COD'

Elseif _nRad == 2

	_cOrder := 'ZZA_XCODRF'

Elseif _nRad == 3

	_cOrder := 'A5_CODPRF'
	
Endif

QryBusc(_cOrder)

_aHeadCols := U_MtHdCols(_cAliasBusc,"TELABUSC")
_oGetDBusc:aCols := aClone(_aHeadCols[2])

_oGetDBusc:refresh()

Return
*/

/*/{Protheus.doc} QryBusc
//Query para ordenação do resultado da busca inicada por
@author totvsremote
@since 03/05/2016
@version undefined
@param _cOrdeer, , descricao
@type function
/*/
/*
Static Function QryBusc(_cOrder)
Local _cProd := cProd


		BeginSql Alias _cAliasBusc

		SELECT  DISTINCT(B1_COD), 
		B1_DESC, 
		B1_GRUPO, 
		B1_BITMAP, 
		ISNULL(ZZA_XCOD, '') AS ZZA_XCOD, 
		ISNULL(ZZA_XCODRF, '') AS ZZA_XCODRF,
		A5_CODPRF

		FROM (
		SELECT B1_COD, B1_DESC, B1_GRUPO, B1_BITMAP	
		FROM %Table:SB1%(NOLOCK)
		WHERE %NotDel%	
		AND  charindex(B1_MSBLQL,%Exp:_cBloqueados%) > 0
		AND NOT B1_GRUPO IN ('XXX','FIS','OLD','NDF')	
		) SB1


		INNER JOIN(
		SELECT * 
		FROM %Table:SBM% (Nolock)
		WHERE %NotDel%
		//	AND BM_CLASGRU <> '1'
		) SBM

		ON B1_GRUPO = BM_GRUPO


		LEFT JOIN (
		SELECT A5_PRODUTO, A5_CODPRF
		FROM %Table:SA5% (NOLOCK)	
		WHERE %NotDel%
		) SA5

		ON B1_COD = A5_PRODUTO

		LEFT JOIN (
		SELECT ZZA_XCOD, ZZA_XCODRF
		FROM %Table:ZZA% (NOLOCK)
		WHERE %NotDel%
		) ZZA

		ON B1_COD = ZZA_XCOD

		WHERE 
		
		(
		%Exp:_nRad% = ( CASE WHEN ( B1_COD LIKE RTRIM(%Exp:_cProd%)+'%'  ) THEN 1 END )
		OR
		%Exp:_nRad% = ( CASE WHEN ( ZZA_XCODRF LIKE RTRIM(%Exp:_cProd%)+'%'  ) THEN 2 END )
		OR
		%Exp:_nRad% = ( CASE WHEN ( A5_CODPRF LIKE RTRIM(%Exp:_cProd%)+'%'  ) THEN 3 END )
		OR
		%Exp:_nRad% = ( CASE WHEN ( B1_COD 	LIKE RTRIM(%Exp:_cProd%)+'%'
											OR A5_CODPRF 	LIKE RTRIM(%Exp:_cProd%)+'%'
											OR ZZA_XCODRF 	LIKE RTRIM(%Exp:_cProd%)+'%'
											OR B1_DESC		LIKE RTRIM(%Exp:_cProd%)+'%'  ) THEN 4 END )
		)


		Order By %Exp:_cOrder%	

		EndSql

Return

*/

/*/{Protheus.doc} _fTeclasF
Função para ativar ou desativar as teclas de atalhos F.

@author Vitor Ribeiro - Consultoria Global
@since 04/03/16

@param l_Ativa, logico, se deve ativar ou desativar as teclas de atalho.

@return null
/*/

Static Function _fTeclasF(l_Ativa)

	Default l_Ativa := .T.
	
	If l_Ativa
		SetKey(VK_F5,_bF05)
		SetKey(VK_F6,_bF06)
	Else
		SetKey(VK_F5)
		SetKey(VK_F6)
	EndIf
	
Return