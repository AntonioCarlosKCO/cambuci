#INCLUDE "Totvs.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "APWIZARD.CH"
  
//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM001

Renegociação de Títulos a Receber
@author  Allan Bonfim
@since   27/10/2014
@version P11
@param
@obs
@return

/*/
//-------------------------------------------------------------------   

User Function CAMBM001()

Local aArea			:= GetArea()
Local aCampos1		:= {}
Local aCampos2		:= {}
Local cArqTmp1
Local cArqTmp2

Private oTcBrw1
Private oTcBrw2
Private oTcBrw3
Private aDadosT1	:= {}
Private aDadosT2	:= {}
Private aDadosT3	:= {}
Private aTotTit		:= {}
Private aParcelas	:= {}
Private aFaturas	:= {}
Private nTotT		:= 0
Private nTotF		:= 0
Private oGetTotF
Private oGetTotT

Public _cPeriDe  := "19000101" // DJALMA
Public _cPerAte  := "20991231" // BORGES
Public _dDataRef := dDataBase  // 01/02/2017

//TMP XXX
AADD(aCampos1,{"CLIEDE", "C", 6, 0})
AADD(aCampos1,{"CLIATE", "C", 6, 0})
AADD(aCampos1,{"PERIDE", "D", 8, 0})
AADD(aCampos1,{"PERATE", "D", 8, 0})
AADD(aCampos1,{"XTPFAT", "C", 1, 0})

cArqTmp1 := CriaTrab(aCampos1)
DbUseArea(.T., __LOCALDRIVER, cArqTmp1, "XXX", .F., .F.)
		
//TMP ZZZ
AADD(aCampos2,{"DTREFE", "D", 8	,0})
AADD(aCampos2,{"CONDPG", "C", 3	,0})

cArqTmp2 := CriaTrab(aCampos2)
DbUseArea(.T., __LOCALDRIVER, cArqTmp2, "ZZZ", .F., .F.)

FWExecView('Renegociação de Títulos a Receber', 'CAMBM001', 4)

XXX->(DbCloseArea())
ZZZ->(DbCloseArea())

RestArea(aArea)

Return           
   
//-------------------------------------------------------------------
/*/{Protheus.doc} MENUDEF

MenuDef - Padrão MVC
@author  Allan Bonfim
@since   24/10/2014
@version P11 
@param 
@return array, Funções da Rotina

/*/
//-------------------------------------------------------------------   

Static Function MENUDEF()

Local aRotina	:= {} 

ADD OPTION aRotina TITLE "Pesquisar" 	ACTION "PesqBrw"         	OPERATION 1 ACCESS 0 
ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.CAMBM001" 	OPERATION 2 ACCESS 0  
ADD OPTION aRotina TITLE "Incluir"	 	ACTION "VIEWDEF.CAMBM001" 	OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"	 	ACTION "VIEWDEF.CAMBM001" 	OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"	 	ACTION "VIEWDEF.CAMBM001" 	OPERATION 5 ACCESS 0

Return aRotina           

//-------------------------------------------------------------------
/*/{Protheus.doc} MODELDEF

ModelDef - Padrão MVC
@author  Allan Bonfim
@since   24/10/2014
@version P11 
@param 
@return objeto, Objeto do Model

/*/
//-------------------------------------------------------------------   

STATIC FUNCTION MODELDEF()

Local oStruct1 		:= CAMBM001S(1, "XXX") 
Local oStruct2 		:= CAMBM001S(1, "ZZZ")

oModel   := MPFormModel():New("CMBM01MOD",, {|oModel| CAMBM01TOK(oModel)}, {|oModel| CAMBM01GRV(oModel)})

oModel:AddFields("FILTROS", /*cOwner*/, oStruct1) 		//Adiciona um formulário de edição de campos ao modelo
oModel:GetModel("FILTROS"):SetDescription("Filtros")
oModel:SetPrimaryKey({})

oModel:AddFields("PARAMETROS", 'FILTROS', oStruct2)
oModel:GetModel("PARAMETROS"):SetDescription("Parâmetros")

oModel:lModify := .T.

Return oModel

     

//-------------------------------------------------------------------
/*/{Protheus.doc} VIEWDEF

ViewDef - Padrão MVC
@author  Allan Bonfim
@since   24/10/2014
@version P11 
@param
@return objeto, Objeto da View

/*/
//-------------------------------------------------------------------   

STATIC FUNCTION VIEWDEF()

Local oStruct1		:= CAMBM001S(2, "XXX") 
Local oStruct2 		:= CAMBM001S(2, "ZZZ")
Local oModel     	:= FWLoadModel("CAMBM001")
Local oView      	:= FWFormView():New() 		//View da MVC

oView:SetModel(oModel)                                        

oView:AddField("VIEW_FILTROS", oStruct1, "FILTROS")
oView:EnableTitleView("VIEW_FILTROS", "Filtros")

oView:AddOtherObject("VIEW_BFILTROS", {|oPanel1| CAMBM001B(oPanel1)})

oView:AddField("VIEW_PARAMETROS", oStruct2, "PARAMETROS")
oView:EnableTitleView("VIEW_PARAMETROS", "Parâmetros")
oView:AddOtherObject("VIEW_BPARAMETROS", {|oPanel6| CAMBM001A(oPanel6)})

oView:AddOtherObject("VIEW_CLIENTE" , {|oPanel| CGRIDCLI(oPanel)}) 
oView:EnableTitleView("VIEW_CLIENTE", 'Clientes')

oView:AddOtherObject("VIEW_TITULO", {|oPanel2| CGRIDTIT(oPanel2)}) 
oView:EnableTitleView("VIEW_TITULO", "Títulos")

oView:AddOtherObject('VIEW_TOTALTIT', {|oPanel4| TOTITULO(oPanel4)})

oView:AddOtherObject("VIEW_FATURA" , {|oPanel3| CGRIDFAT(oPanel3)}) 
oView:EnableTitleView("VIEW_FATURA", "Faturas")

oView:AddOtherObject('VIEW_TOTALFAT', {|oPanel5| TOTFATURA(oPanel5)}) 

//Divide a Tela no meio Verticalmente
oView:CreateVerticalBox("BOXLEFT"	,50)
oView:CreateVerticalBox("BOXRIGHT"	,50)

oView:CreateHorizontalBox("BOXCABL"	,26, "BOXLEFT")
oView:CreateHorizontalBox("BOXSA1L"	,27, "BOXLEFT")
oView:CreateHorizontalBox("BOXSE1L"	,40, "BOXLEFT")
oView:CreateHorizontalBox("BOXTOTL"	,07, "BOXLEFT")

oView:CreateVerticalBox("BOXCABL1"	,70, "BOXCABL")
oView:CreateVerticalBox("BOXCABL2"	,30, "BOXCABL")


oView:CreateHorizontalBox("BOXCABR"	,26, "BOXRIGHT")
oView:CreateHorizontalBox("BOXFAT"	,67, "BOXRIGHT")
oView:CreateHorizontalBox("BOXTOTR"	,07, "BOXRIGHT")

oView:CreateVerticalBox("BOXCABR1"	,70, "BOXCABR")
oView:CreateVerticalBox("BOXCABR2"	,30, "BOXCABR")

oView:SetOwnerView("VIEW_FILTROS"		,"BOXCABL1")
oView:SetOwnerView("VIEW_BFILTROS"		,"BOXCABL2")
oView:SetOwnerView("VIEW_CLIENTE"  		,"BOXSA1L")
oView:SetOwnerView("VIEW_TITULO"		,"BOXSE1L")
oView:SetOwnerView("VIEW_TOTALTIT"		,"BOXTOTL")
oView:SetOwnerView("VIEW_PARAMETROS"	,"BOXCABR1")
oView:SetOwnerView("VIEW_BPARAMETROS"	,"BOXCABR2")
oView:SetOwnerView("VIEW_FATURA"		,"BOXFAT")
oView:SetOwnerView("VIEW_TOTALFAT"		,"BOXTOTR")

oView:SetCloseOnOk({|| .F.})

Return oView  

//-------------------------------------------------------------------
/*/{Protheus.doc} CGRIDCLI

Grid Clientes
@author  Allan Bonfim
@since   24/10/2014
@version P11 
@param [oPanelPar], objeto, Objeto que vai receber o Grid
@param [lRecall], logico, Define se recarrega ou não o Grid
@return

/*/
//-------------------------------------------------------------------   

Static Function CGRIDCLI(oPanelPar, lRecall)

Local aArea		:= GetArea()
Local oModelAtu	:= FwModelActive()
Local oViewAtu	:= FwViewActive()
Local bColor

Default oPanelPar	:= NIL
Default lRecall		:= .F.

If oPanelPar == NIL

	If oViewAtu <> NIL
		If oViewAtu:lActivate
			aDadosT1	:= MONTACOLS(1) // Monta Acols do Grid Cursos 
			oTcBrw1:SetArray(aDadosT1)
   			oTcBrw1:GoTop()
			oTcBrw1:DrawSelect()
  		EndIf
  	EndIf

Else
	
	bColor 	:= &("{|| if(aCols[n,Len(aCols[n])],"+Str(CLR_LIGHTGRAY)+","+Str(CLR_WHITE)+")}")
	aDadosT1:= MONTACOLS(1) // Monta Acols do Grid Cursos
	
	oTcBrw1 := TwBrowse():New(0, 0, 0, 0,,,,oPanelPar,,,,,,,,,,,,,, .T.,,,, .T., .T.)
	oTcBrw1:Align 		:= 5
	oTcBrw1:bChange 	:= {|| (CGRIDTIT(,.T.), ATUCNDPG(), CGRIDFAT(,.T.))}
	oTcBrw1:nScrollType := 1
	oTcBrw1:SetArray(aDadosT1)
	oTcBrw1:SetBlkBackColor(bColor)
	oTcBrw1:lAutoEdit := .F.
	oTcBrw1:lReadOnly := .F.
	//Raphael
	If Len(aDadosT1) > 0
		oTcBrw1:AddColumn(TCColumn():New("Codigo"	,{||aDadosT1[oTcBrw1:nAt,1]}	,"@!"	,,,"LEFT",	,.F.,.F.))
		oTcBrw1:AddColumn(TCColumn():New("Loja"		,{||aDadosT1[oTcBrw1:nAt,2]}	,"@!"	,,,"LEFT",	,.F.,.F.))
		oTcBrw1:AddColumn(TCColumn():New("Nome"		,{||aDadosT1[oTcBrw1:nAt,3]}	,"@!"	,,,"LEFT",	,.F.,.F.))
	EndIf
	oTcBrw1:Refresh()	

EndIf
	
If lRecall

	If oViewAtu <> NIL
		If oViewAtu:lActivate
			oViewAtu:Refresh()
		EndIf
	EndIf

Endif
	
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CGRIDTIT

Grid Titulos

@author  Allan Bonfim

@since   24/10/2014

@version P11 

@param [oPanelPar], objeto, Objeto que vai receber o Grid
@param [lRecall], logico, Define se recarrega ou não o Grid

@return

/*/
//-------------------------------------------------------------------   

Static Function CGRIDTIT(oPanelPar, lRecall)

Local aArea			:= GetArea()
Local oOk			:= LoadBitMap(GetResources(), "LBOK")
Local oNo			:= LoadBitMap(GetResources(), "LBNO")
Local oModelAtu		:= FwModelActive()
Local oViewAtu		:= FwViewActive()

Default oPanelPar	:= NIL
Default lRecall		:= .F.

If oPanelPar == NIL 

	If oViewAtu <> NIL
		If oViewAtu:lActivate
			aDadosT2	:= MONTACOLS(2) // Monta Acols do Grid Cursos 
			oTcBrw2:SetArray(aDadosT2)
			oTcBrw2:GoTop()
			oTcBrw2:DrawSelect()
			oGetTotT:CtrlRefresh()
			ATUACOLS(1)
		EndIf
  	EndIf	

Else

	aDadosT2		:= MONTACOLS(2)
	
	oTcBrw2 := TwBrowse():New(0, 0, 0, 0,,,, oPanelPar,,,,,,,,,,,,,, .T.,{|| .T.},,{|| .T.}, .T., .T.)
	oTcBrw2:Align 			:= 5
//	oTcBrw2:bLDblClick 		:= {|| (aDadosT2[oTcBrw2:nAt,1]:= !aDadosT2[oTcBrw2:nAt,1], ATUACOLS(1), ATUCNDPG(), CAMBM001F(2, .F.))}/*, ATUACOLS(1)CGRIDFAT(,.T.)*/
	oTcBrw2:bLDblClick 		:= {|oBrowse| (SELNOTAINT(oBrowse), ATUACOLS(1), ATUCNDPG(), CAMBM001F(2, .F.))}/*, ATUACOLS(1)CGRIDFAT(,.T.)*/
	oTcBrw2:bHeaderClick 	:= {|oBrowse, nCol| (SELTUDO(oBrowse, nCol), ATUCNDPG(), CAMBM001F(2, .F.))}
	oTcBrw2:nScrollType 	:= 1
	oTcBrw2:lAutoEdit 		:= .T.
	oTcBrw2:lReadOnly 		:= .F.
 	oTcBrw2:bLine 	  		:= {||{aDadosT2[oTcBrw2:nAt,1], aDadosT2[oTcBrw2:nAt,2],aDadosT2[oTcBrw2:nAt,3],aDadosT2[oTcBrw2:nAt,4],aDadosT2[oTcBrw2:nAt,5],aDadosT2[oTcBrw2:nAt,6],aDadosT2[oTcBrw2:nAt,7],aDadosT2[oTcBrw2:nAt,8]}}
	oTcBrw2:SetArray(aDadosT2)
	
	//A marca não está funcionando visualmente. Devido a isso mantive o X	
	//oTcBrw2:AddColumn(TCColumn():New(" "	   		,{|| aDadosT2[oTcBrw2:nAt,1]}/* {|| If(aDadosT2[oTcBrw2:nAt,1], oOk, oNo)}*/,,,,,010,.F.,.F.,,,,,))
	//oTcBrw2:AddColumn(TCColumn():New(" "	   		,{||aDados[oTcBrw2:nAt,1]}								,							,,,"LEFT"	,10		,.F.,.F.))
	//oTcBrw2:AddColumn(TCColumn():New("  "			,{|| If(aDadosT2[oTcBrw2:nAt,1],oOk,oNo) }				,							,,,			,010	,.T.,.F.))
	oTcBrw2:AddColumn(TCColumn():New("  "			,{|| If(aDadosT2[oTcBrw2:nAt,1], "X", "") }				,							,,,"CENTER"	,010	,.F.,.F.))	
	oTcBrw2:AddColumn(TCColumn():New("Prefixo"		,{||aDadosT2[oTcBrw2:nAt,2]}							,"@!"						,,,"LEFT"	,		,.F.,.F.))
	oTcBrw2:AddColumn(TCColumn():New("Título"		,{||aDadosT2[oTcBrw2:nAt,3]}							,"@!"						,,,"LEFT"	,		,.F.,.F.))
	oTcBrw2:AddColumn(TCColumn():New("Parcela"		,{||aDadosT2[oTcBrw2:nAt,4]}							,"@!"						,,,"LEFT"	,		,.F.,.F.))      
	oTcBrw2:AddColumn(TCColumn():New("Tipo"			,{||aDadosT2[oTcBrw2:nAt,5]}							,"@!"						,,,"LEFT"	,		,.F.,.F.))
	oTcBrw2:AddColumn(TCColumn():New("Emissão"		,{||aDadosT2[oTcBrw2:nAt,9]}							,							,,,"CENTER"	,		,.F.,.F.))
	oTcBrw2:AddColumn(TCColumn():New("Saldo"		,{||aDadosT2[oTcBrw2:nAt,8]}							,"@E 9,999,999,999,999.99"	,,,"RIGHT"	,		,.F.,.F.))
	oTcBrw2:AddColumn(TCColumn():New("Valor"		,{||aDadosT2[oTcBrw2:nAt,7]}							,"@E 9,999,999,999,999.99"	,,,"RIGHT"	,		,.F.,.F.))
	oTcBrw2:AddColumn(TCColumn():New("Vencimento"	,{||aDadosT2[oTcBrw2:nAt,6]}							,							,,,"CENTER"	,		,.F.,.F.))
	oTcBrw2:Refresh()

EndIf

If lRecall

	If oViewAtu <> NIL
		If oViewAtu:lActivate
	  		oViewAtu:Refresh()
		EndIf
	EndIf

Endif
	
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CGRIDFAT

Grid Faturas

@author  Allan Bonfim

@since   24/10/2014

@version P11 

@param [oPanelPar], objeto, Objeto que vai receber o Grid
@param [lRecall], logico, Define se recarrega ou não o Grid

@return

/*/
//------------------------------------------------------------------- 

Static Function CGRIDFAT(oPanelPar, lRecall)

Local aArea		:= GetArea()
Local oModelAtu	:= FwModelActive()
Local oViewAtu	:= FwViewActive()

Default lRecall	:= .F.

If oPanelPar == NIL 

	If oViewAtu <> NIL
		If oViewAtu:lActivate
			aDadosT3	:= MONTACOLS(3) // Monta Acols do Grid Cursos 
			oTcBrw3:SetArray(aDadosT3)
			oTcBrw3:GoTop()
			oGetTotF:CtrlRefresh()
		EndIf
  	EndIf
  		
Else

	aDadosT3	:= MONTACOLS(3) // Monta Acols do Grid Cursos
	
	oTcBrw3 := TCBrowse():New(0, 0, 0, 0,,,,oPanelPar,,,,,,,,,,,,,, .T.,{|| .T.},,{|| .T.}, .T., .T.)
	oTcBrw3:bLDblClick 	:= {|| (EDITABRW(@aDadosT3), ATUACOLS(3))}
	oTcBrw3:Align 		:= 5
	oTcBrw3:nScrollType := 1
	oTcBrw3:lAutoEdit 	:= .T.
	oTcBrw3:lReadOnly 	:= .F.
	oTcBrw3:SetArray(aDadosT3)	

	oTcBrw3:AddColumn(TCColumn():New("Data"		,{||aDadosT3[oTcBrw3:nAt,1]}	,	  						,,,"CENTER"	, 50,.F.,.T.))
	oTcBrw3:AddColumn(TCColumn():New("Valor"	,{||aDadosT3[oTcBrw3:nAt,2]}	,  "@E 9,999,999,999,999.99",,,"RIGHT"	, 80,.F.,.T.))

EndIf

If lRecall

	If oViewAtu <> NIL
		If oViewAtu:lActivate
			oViewAtu:Refresh()
		EndIf
	EndIf

Endif
	
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MONTACOLS

Carregamento dos Grids

@author  Allan Bonfim

@since   24/10/2014

@version P11 

@param [nGrid], numerico, Define qual grid será carregado

@return array, Array com os dados do Grid (Acols)

/*/
//------------------------------------------------------------------- 

Static Function MONTACOLS(nGrid)

Local aArea		:= GetArea()
Local aACols	:= {}
Local oModelAtu	:= FwModelActive()
Local oViewAtu	:= FwViewActive()
Local cQueryTmp := ""
Local cTmpQuery	:= GetNextAlias()
Local nX		:= 0
Local nPosReg	:= 0
Local lSelTit	:= .F.
Local cTpTit	:= ""
Local aTpTit	:= {}      
Local cTPTITCR  := SuperGetMV("ES_TPTITCR" , , "NF")

Default nGrid	:= 0

If nGrid == 1 //Clientes

	cQueryTmp := "SELECT DISTINCT A1_COD, A1_LOJA, A1_NOME "+CHR(13)+CHR(10)
	cQueryTmp += "FROM "+RetSqlName("SA1")+" SA1 (NOLOCK) "+CHR(13)+CHR(10)
	cQueryTmp += "INNER JOIN "+RetSqlName("SE1")+" SE1 (NOLOCK) "+CHR(13)+CHR(10)
	cQueryTmp += "ON (E1_FILIAL = '" + xFilial("SE1") + "' AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA AND E1_SALDO > 0 AND E1_MSFIL = '"+ALLTRIM(SM0->M0_CODFIL)+"' AND SE1.D_E_L_E_T_ = '') "+CHR(13)+CHR(10)
	cQueryTmp += "WHERE SA1.D_E_L_E_T_ = '' "+CHR(13)+CHR(10)
	cQueryTmp += "AND (ISNULL(A1_COND,'') <> '' OR ISNULL(A1_XGRPCON,'') <> '') "+CHR(13)+CHR(10)
//	cQueryTmp += "AND ISNULL(E1_PORTADO,'') = '' "+CHR(13)+CHR(10)
	cQueryTmp += "AND ISNULL(E1_NUMBOR,'') = '' "+CHR(13)+CHR(10)
		
	aTpTit 	:= STRTOKARR(CTPTITCR, "/")
	cTpTit	:= ""		

	For nX:= 1 to Len (aTpTit)
		If nX > 1
			cTpTit += ',' 
		EndIf
		cTpTit += aTpTit[nX]
	Next nX
	
	If !EMPTY(cTpTit)
		cQueryTmp += "AND E1_TIPO IN " + FormatIn(cTpTit,",") + CHR(13) + CHR(10) // FORMATIN() DJALMA BORGES 20/12/2016
	EndIf
				
	If oViewAtu <> NIL .and. oModelAtu <> NIL
		If oViewAtu:lActivate
			If oModelAtu:GetModel("FILTROS") <> NIL
				If !oModelAtu:GetModel("FILTROS"):GetValue("XXX_XTPFAT") == "T"
					cQueryTmp += "AND A1_XTPFAT = '"+oModelAtu:GetModel("FILTROS"):GetValue("XXX_XTPFAT")+"' "+CHR(13)+CHR(10)		
				EndIf
				If !EMPTY(oModelAtu:GetModel("FILTROS"):GetValue("XXX_CLIEDE")) .AND. !EMPTY(oModelAtu:GetModel("FILTROS"):GetValue("XXX_CLIATE"))
					cQueryTmp += "AND A1_COD >=  '"+ALLTRIM(oModelAtu:GetModel("FILTROS"):GetValue("XXX_CLIEDE"))+"' AND A1_COD <=  '"+ALLTRIM(oModelAtu:GetModel("FILTROS"):GetValue("XXX_CLIATE"))+"'"+CHR(13)+CHR(10)
				ElseIf !EMPTY(oModelAtu:GetModel("FILTROS"):GetValue("XXX_CLIEDE")) .AND. EMPTY(oModelAtu:GetModel("FILTROS"):GetValue("XXX_CLIATE"))
					cQueryTmp += "AND A1_COD >=  '"+ALLTRIM(oModelAtu:GetModel("FILTROS"):GetValue("XXX_CLIEDE"))+"' "+CHR(13)+CHR(10)
				ElseIf EMPTY(oModelAtu:GetModel("FILTROS"):GetValue("XXX_CLIEDE")) .AND. !EMPTY(oModelAtu:GetModel("FILTROS"):GetValue("XXX_CLIATE"))
					cQueryTmp += "AND A1_COD <=  '"+ALLTRIM(oModelAtu:GetModel("FILTROS"):GetValue("XXX_CLIATE"))+"' "+CHR(13)+CHR(10)
				EndIf
				
				If !EMPTY(oModelAtu:GetValue("FILTROS","XXX_PERIDE")) .AND. !EMPTY(oModelAtu:GetValue("FILTROS","XXX_PERATE"))
					cQueryTmp += "AND E1_EMISSAO BETWEEN  '"+DTOS(oModelAtu:GetValue("FILTROS","XXX_PERIDE"))+"' AND '"+DTOS(oModelAtu:GetValue("FILTROS","XXX_PERATE"))+"'"+CHR(13)+CHR(10)
				ElseIf !EMPTY(oModelAtu:GetValue("FILTROS","XXX_PERIDE")) .AND. EMPTY(oModelAtu:GetValue("FILTROS","XXX_PERATE"))
					cQueryTmp += "AND E1_EMISSAO >=  '"+DTOS(oModelAtu:GetModel("FILTROS"):GetValue("XXX_PERIDE"))+"' "+CHR(13)+CHR(10)
				ElseIf EMPTY(oModelAtu:GetValue("FILTROS","XXX_PERIDE")) .AND. !EMPTY(oModelAtu:GetValue("FILTROS","XXX_PERATE"))
					cQueryTmp += "AND E1_EMISSAO <=  '"+DTOS(oModelAtu:GetValue("FILTROS","XXX_PERATE"))+"' "+CHR(13)+CHR(10)
				EndIf
			EndIf	
		EndIf
	EndIf
			
	cQueryTmp += "ORDER BY A1_COD "+CHR(13)+CHR(10)

	If (Select(cTmpQuery) > 0)
		(cTmpQuery)->(DbCloseArea())
	EndIf

	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQueryTmp), cTmpQuery, .T., .T.)
	
	While !(cTmpQuery)->(EOF())
		AADD(aACols, {(cTmpQuery)->A1_COD, (cTmpQuery)->A1_LOJA, (cTmpQuery)->A1_NOME})
			
		(cTmpQuery)->(DbSkip())
	EndDo

	If (Select(cTmpQuery) > 0)
		(cTmpQuery)->(DbCloseArea())
	EndIf
    		
ElseIf nGrid == 2 //Titulos

	If oViewAtu <> NIL
		If oViewAtu:lActivate
			If oTcBrw1 <> NIL
				If Len (oTcBrw1:aArray) > 0

					cQueryTmp := "SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VENCREA, E1_VALOR, E1_SALDO, E1_CLIENTE, E1_LOJA, E1_EMISSAO "+CHR(13)+CHR(10)
					cQueryTmp += "FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+CHR(13)+CHR(10)
					cQueryTmp += "WHERE SE1.D_E_L_E_T_ = '' "+CHR(13)+CHR(10)
					cQueryTmp += "AND E1_MSFIL = '"+ALLTRIM(SM0->M0_CODFIL)+"' "+CHR(13)+CHR(10)
					cQueryTmp += "AND E1_SALDO > 0 "+CHR(13)+CHR(10)
//					cQueryTmp += "AND ISNULL(E1_PORTADO,'') = '' "+CHR(13)+CHR(10)
					cQueryTmp += "AND ISNULL(E1_NUMBOR,'') = '' "+CHR(13)+CHR(10)
					
					aTpTit 	:= STRTOKARR(SuperGetMV("ES_TPTITCR" , , "NF"), "/")
					cTpTit	:= ""
			
					For nX:= 1 to Len (aTpTit)
						If nX > 1
							cTpTit += ','
						EndIf
						cTpTit += aTpTit[nX]
					Next nX
		
					If !EMPTY(cTpTit)
						cQueryTmp += "AND E1_TIPO IN " + FormatIn(cTpTit,",") + CHR(13) + CHR(10) // FORMATIN() DJALMA BORGES 20/12/2016
					EndIf			
		
					If oViewAtu <> NIL .and. oModelAtu <> NIL
						If oViewAtu:lActivate
							If oModelAtu:lActivate
								If !EMPTY(oModelAtu:GetValue("FILTROS","XXX_PERIDE")) .AND. !EMPTY(oModelAtu:GetValue("FILTROS","XXX_PERATE"))
									cQueryTmp += "AND E1_EMISSAO BETWEEN  '"+DTOS(oModelAtu:GetValue("FILTROS","XXX_PERIDE"))+"' AND '"+DTOS(oModelAtu:GetValue("FILTROS","XXX_PERATE"))+"'"+CHR(13)+CHR(10)
								ElseIf !EMPTY(oModelAtu:GetValue("FILTROS","XXX_PERIDE")) .AND. EMPTY(oModelAtu:GetValue("FILTROS","XXX_PERATE"))
									cQueryTmp += "AND E1_EMISSAO >=  '"+DTOS(oModelAtu:GetModel("FILTROS"):GetValue("XXX_PERIDE"))+"' "+CHR(13)+CHR(10)
								ElseIf EMPTY(oModelAtu:GetValue("FILTROS","XXX_PERIDE")) .AND. !EMPTY(oModelAtu:GetValue("FILTROS","XXX_PERATE"))
									cQueryTmp += "AND E1_EMISSAO <=  '"+DTOS(oModelAtu:GetValue("FILTROS","XXX_PERATE"))+"' "+CHR(13)+CHR(10)
								EndIf
							EndIf	
						EndIf			
					EndIf
					
					If oTcBrw1 <> NIL
						If Len (oTcBrw1:aArray) > 0
							cQueryTmp += "AND E1_CLIENTE = '"+ALLTRIM(oTcBrw1:aArray[oTcBrw1:nAt,1])+"' "+CHR(13)+CHR(10)
							cQueryTmp += "AND E1_LOJA = '"+ALLTRIM(oTcBrw1:aArray[oTcBrw1:nAt,2])+"' "+CHR(13)+CHR(10)
						EndIf
					EndIf
						
					cQueryTmp += "ORDER BY E1_EMISSAO, E1_NUM, E1_PARCELA, E1_TIPO, E1_PREFIXO "+CHR(13)+CHR(10)
				
					If (Select(cTmpQuery) > 0)
						(cTmpQuery)->(DbCloseArea())
					EndIf
				
					DbUseArea(.T., "TOPCONN", TcGenQry(,,cQueryTmp), cTmpQuery, .T., .T.)
				
					TCSetField(cTmpQuery,"E1_VENCREA","D",8,0)
					TCSetField(cTmpQuery,"E1_EMISSAO","D",8,0)
					
					If (cTmpQuery)->(EOF())
						AADD(aACols, {.F., SPACE(TAMSX3("E1_PREFIXO")[1]), SPACE(TAMSX3("E1_NUM")[1]), SPACE(TAMSX3("E1_PARCELA")[1]), SPACE(TAMSX3("E1_TIPO")[1]), CTOD(""), 0, 0, CTOD("")})
					Else
						While !(cTmpQuery)->(EOF())
						
							nPosReg := ASCAN(aTotTit, {|x| x[1] == (cTmpQuery)->E1_CLIENTE .AND. x[2] == (cTmpQuery)->E1_LOJA .AND. x[3] == (cTmpQuery)->E1_PREFIXO  .AND. x[4] == (cTmpQuery)->E1_NUM .AND. x[5] == (cTmpQuery)->E1_PARCELA .AND. x[6] == (cTmpQuery)->E1_TIPO .AND. x[7] == (cTmpQuery)->E1_VENCREA .AND. x[8] == (cTmpQuery)->E1_VALOR .AND. x[9] == (cTmpQuery)->E1_SALDO} )
							If nPosReg > 0
								lSelTit	:= .T.
							Else
								lSelTit	:= .F.
							EndIf
						
							AADD(aACols, {lSelTit, (cTmpQuery)->E1_PREFIXO, (cTmpQuery)->E1_NUM, (cTmpQuery)->E1_PARCELA, (cTmpQuery)->E1_TIPO, (cTmpQuery)->E1_VENCREA, (cTmpQuery)->E1_VALOR, (cTmpQuery)->E1_SALDO, (cTmpQuery)->E1_EMISSAO})
								
							(cTmpQuery)->(DbSkip())
						EndDo
					
						If (Select(cTmpQuery) > 0)
							(cTmpQuery)->(DbCloseArea())
						EndIf
					EndIf	
				//Else
			
				//	AADD(aACols, {.F., SPACE(TAMSX3("E1_PREFIXO")[1]), SPACE(TAMSX3("E1_NUM")[1]), SPACE(TAMSX3("E1_PARCELA")[1]), SPACE(TAMSX3("E1_TIPO")[1]), CTOD(""), 0, 0})	
			
				EndIf
					
			//Else
			
			//	AADD(aACols, {.F., SPACE(TAMSX3("E1_PREFIXO")[1]), SPACE(TAMSX3("E1_NUM")[1]), SPACE(TAMSX3("E1_PARCELA")[1]), SPACE(TAMSX3("E1_TIPO")[1]), CTOD(""), 0})	
			
			EndIf

		Else
			
			AADD(aACols, {.F., SPACE(TAMSX3("E1_PREFIXO")[1]), SPACE(TAMSX3("E1_NUM")[1]), SPACE(TAMSX3("E1_PARCELA")[1]), SPACE(TAMSX3("E1_TIPO")[1]), CTOD(""), 0, 0, CTOD("")})	
			
		EndIf
					
	Else
			
		AADD(aACols, {.F., SPACE(TAMSX3("E1_PREFIXO")[1]), SPACE(TAMSX3("E1_NUM")[1]), SPACE(TAMSX3("E1_PARCELA")[1]), SPACE(TAMSX3("E1_TIPO")[1]), CTOD(""), 0, 0, CTOD("")})	
			
	EndIf
		
ElseIf nGrid == 3 //Faturas

	If oViewAtu <> NIL

		If oViewAtu:lActivate

			If oTcBrw1 <> NIL
				If Len (oTcBrw1:aArray) > 0
					If Len(aFaturas) > 0
						For nX:=1 to Len (aFaturas)
					    	If aFaturas[nX][1] == oTcBrw1:aArray[oTcBrw1:nAt,1] .AND. aFaturas[nX][2] == oTcBrw1:aArray[oTcBrw1:nAt,2]
								AADD(aACols, {aFaturas[nX][3], aFaturas[nX][4]})
							EndIf
						Next nX 
					Else
						AADD(aACols, {CTOD(""), 0})
					EndIf
				EndIf
			Endif

			If !Len(aACols) > 0			
				AADD(aACols, {CTOD(""), 0})
			EndIf
			
		Else
	
			AADD(aACols, {CTOD(""), 0})

		EndIf
		
	Else
	
		AADD(aACols, {CTOD(""), 0})
		
	EndIf
		
EndIf
	
RestArea(aArea)
	
Return aACols

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM001S

Monta a estrutura fora do padrão do objeto (similar ao FwFormStruct)

@author  Allan Bonfim

@since   13/01/2013

@version P11 

@param [nTipo], numérico, Tipo do objeto (1= Model, 2= View)
@param [cAlias], caracter, Alias para montar a estrutura

@return objeto, Objeto com a estrutura

/*/
//-------------------------------------------------------------------   

Static Function CAMBM001S(nTipo, cAlias)

Local oObj

Default nTipo	:= 0
Default cAlias 	:= ""

If nTipo = 1
	
	If cAlias == "XXX"

		oObj := FWFormModelStruct():New() 
	
		oObj:AddTable("XXX", {""}, "Filtros")     
				
	    //   AddField(cTitulo	   , cTooltip							   ,cIdField	,cTipo	,nTamanho,nDecimal,bValid,bWhen,aValues							  ,lObrigat,bInit				 ,lKey,lNoUpd,lVirtual, cValid)                                           
		oObj:AddField("Cliente De" ,"Informe o Cliente Inicial dos Títulos","XXX_CLIEDE","C"	,6		 ,0	   	  ,NIL   ,NIL  ,NIL	   							  ,NIL	   ,NIL					 ,NIL ,NIL   ,.T.)
		oObj:AddField("Cliente Até","Informe o Período Final dos Títulos"  ,"XXX_CLIATE","C"	,6		 ,0	      ,NIL   ,NIL  ,NIL	   							  ,NIL	   ,{|| "ZZZZZZ"}		 ,NIL ,NIL   ,.T.)
		oObj:AddField("Período De" ,"Informe o Período Inicial dos Títulos","XXX_PERIDE","D"	,8	 	 ,0	      ,NIL   ,NIL  ,NIL	   							  ,NIL	   ,{|| STOD(_cPeriDe)},NIL ,NIL   ,.T.) // DJALMA BORGES
		oObj:AddField("Período Até","Informe o Período Final dos Títulos"  ,"XXX_PERATE","D"	,8		 ,0	      ,NIL   ,NIL  ,NIL	   							  ,NIL	   ,{|| STOD(_cPerAte)},NIL ,NIL   ,.T.) // 01/02/2017
//		oObj:AddField("Período De" ,"Informe o Período Inicial dos Títulos","XXX_PERIDE","D"	,8	 	 ,0	      ,NIL   ,NIL  ,NIL	   							  ,NIL	   ,{|| STOD("19000101")},NIL ,NIL   ,.T.)
//		oObj:AddField("Período Até","Informe o Período Final dos Títulos"  ,"XXX_PERATE","D"	,8		 ,0	      ,NIL   ,NIL  ,NIL	   							  ,NIL	   ,{|| STOD("20991231")},NIL ,NIL   ,.T.)
		oObj:AddField("Tipo Fatura","Informe o Tipo do Faturamento"		   ,"XXX_XTPFAT","C"	,1		 ,0	      ,NIL   ,NIL  ,{"D=Diario","S=Semanal","T=Todos"},NIL	   ,{|| "S"}			 ,NIL ,.F.   ,.T.)

	ElseIf cAlias == "ZZZ"

		oObj := FWFormModelStruct():New() 
	
		oObj:AddTable("ZZZ", {""}, "Parametros")
		
	    //AddField ( cTitulo, cTooltip, cIdField, cTipo, nTamanho, nDecimal, bValid, bWhen, aValues, lObrigat, bInit, lKey, lNoUpd, lVirtual, cValid)                                           
//		oObj:AddField("Dt. Referência"	,"Informe a Data de Referência para Simulação e Geração da Fatura" 		,"ZZZ_DTREFE"	,"D",8	,0, {|| VLDCPO("ZZZ_DTREFE")},NIL,NIL, .T., {|| dDataBase}	,NIL,NIL,.T.)
		oObj:AddField("Dt. Referência"	,"Informe a Data de Referência para Simulação e Geração da Fatura" 		,"ZZZ_DTREFE"	,"D",8	,0, {|| VLDCPO("ZZZ_DTREFE")},NIL,NIL, .T., {|| _dDataRef}	,NIL,NIL,.T.) // DJALMA BORGES 01/02/2017
		oObj:AddField("Cond. Pagto"		,"Informe a Condição de Pagamento para Simulação e Geração da Fatura"	,"ZZZ_CONDPG"	,"C",3	,0, {|| .T./*CONDPAG(GETMEMVAR("ZZZ_CONDPG"))*/}, {|| .T./*EMPTY(GETMEMVAR("ZZZ_CONDPG"))*/},NIL, .T., NIL			,NIL,NIL,.T.)
		
	EndIf
	
ElseIf nTipo = 2

	If cAlias == "XXX"

		oObj := FWFormViewStruct():New()  
		//AddField( cIdField, cOrdem, cTitulo, cDescric, aHelp, cType, cPicture, bPictVar, cLookUp, lCanChange, cFolder, cGroup, aComboValues, nMaxLenCombo, cIniBrow, lVirtual, cPictVar, lInsertLine )
		oObj:AddField("XXX_CLIEDE"	, "01", "Cliente De" 	, "Cliente De" 		, {} ,"C" , "@!" ,, "SA1001",.T.)
		oObj:AddField("XXX_CLIATE"	, "02", "Cliente Até" 	, "Cliente Até" 	, {} ,"C" , "@!" ,, "SA1001",.T.)	
		oObj:AddField("XXX_PERIDE"	, "03", "Período De" 	, "Período De" 		, {} ,"D" ,  	 ,,			,.T.)
		oObj:AddField("XXX_PERATE"	, "04", "Período Até"	, "Período Até"		, {} ,"D" , 	 ,,			,.T.)
//	   	oObj:AddField("XXX_XTPFAT"	, "05", "Tp Faturamento", "Tp Faturamento"	, {} ,"C" , "@!" ,,			,.T.)		
		oObj:AddField("XXX_XTPFAT" 	, "05", "Tp Faturamento", "Tp Faturamento"  , {} ,"C",       ,,			,.T.,,,{"D=Diario","S=Semanal","T=Todos"},1)

	ElseIf cAlias == "ZZZ"

		oObj := FWFormViewStruct():New()  
		//AddField( cIdField, cOrdem, cTitulo, cDescric, aHelp, cType, cPicture, bPictVar, cLookUp, lCanChange, cFolder, cGroup, aComboValues, nMaxLenCombo, cIniBrow, lVirtual, cPictVar, lInsertLine )
		oObj:AddField("ZZZ_CONDPG"	, "01", "Cond. Pagto" 		, "Cond. Pagto" 		, {} ,"C" , "@!" ,, "SE4FAT",.T.) 
		oObj:AddField("ZZZ_DTREFE"	, "02", "Dt. Referência" 	, "Dt. Referência" 		, {} ,"D" ,  	 ,,			,.T.)

	EndIf
		
EndIf

Return oObj                                    


//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM001B

Botão Filtrar

@author  Allan Bonfim

@since   14/11/2014

@version P11 

@param [oObj], objeto, Objeto que vai receber o botão

@return

/*/
//-------------------------------------------------------------------   

Static Function CAMBM001B(oPanelPar)

Local aSize			:= FwGetDialogSize(oPanelPar)
Local oModelF 		:= FWModelActive()
Local nOperation	:= oModelF:GetOperation()
Local oButFiltro   	:= NIL
Local lWhenPesq   	:= IIF (nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_INSERT, .T., .F.)
Local oPnlLeft   	:= NIL
Local nPosButton	:= 0
Local oFont18		:= TFont():New("Arial",,18,,.T.,,,,,.F.,.F.)
Local bExecFil		:= {|| FWMsgRun(, {|| CAMBM001F(1)}, "Aguarde...")}
Local bValidFil		:= {|| .T.}

oPnlLeft 	:= TPanel():New(0, 0, "", oPanelPar,,,,, RGB(255,255,255), 0, 0)
oPnlLeft:Align := 5

nPosButton := oPnlLeft:nClientHeight / 5

oButFiltro := TButton():New(nPosButton, 20, "Filtrar", oPnlLeft, bExecFil, 60, 15,, oFont18,, .T.,, "Executa o Filtro dos Clientes e Títulos",, {|| lWhenPesq}, bValidFil, .F.)

Return                    

//-------------------------------------------------------------------

Static Function CAMBM001F(nOpcA, lValida)

Local aArea 	:= GetArea()
Local oModelAtu	:= FwModelActive()
Local oViewAtu	:= FwViewActive()
Local nX		:= 0

Default nOpcA 	:= 1
Default lValida	:= .F.

If nOpcA == 1 //Filtro

	aTotTit := {}	
	CGRIDCLI(,.F.)
	CGRIDTIT(,.F.)
	aFaturas := {}	
	CGRIDFAT(,.T.)

ElseIf nOpcA == 2 //Simulação

	If lValida
		If EMPTY(oModelAtu:GetModel("PARAMETROS"):GetValue("ZZZ_CONDPG"))
			HELP("ERRO",,"ERRO",,"É obrigatório o preenchimento da Condição de Pagamento para a Simulação.",1,0)	
		ElseIf EMPTY(oModelAtu:GetModel("PARAMETROS"):GetValue("ZZZ_DTREFE"))
			HELP("ERRO",,"ERRO",,"É obrigatório o preenchimento da Data de Referência para a Simulação.",1,0)
		Else
			//ATUCNDPG()
			CALCPARC()
			ATUACOLS(2)
		EndIf
	Else
		//ATUCNDPG()
		CALCPARC()
		ATUACOLS(2)
	EndIf
	
ElseIf nOpcA == 3

	For nX:=1 to Len(oTcBrw1:aArray)
		oTcBrw1:GoPosition(nX)
		SELTUDO (oTcBrw2, 1, .T.)
		If !EMPTY(oModelAtu:GetModel("PARAMETROS"):GetValue("ZZZ_CONDPG")) .AND. !EMPTY(oModelAtu:GetModel("PARAMETROS"):GetValue("ZZZ_DTREFE"))
			//ATUCNDPG()
			CALCPARC()
			ATUACOLS(2)
		EndIf
	Next nX
	oTcBrw1:GoTop()

EndIf    

RestArea(aArea)

Return   

//-------------------------------------------------------------------
/*/{Protheus.doc} SELTUDO

Marca todos os itens do Grid

@author  Allan Bonfim

@since   14/11/2014

@version P11 

@param [oBrowse], Objeto, Objeto do Grid para selecionar tudo
@param [nColuna], Numerico, Numero da coluna que o usuário clicou
@param [lMTudo], Lógico, Marca todos os itens do grid. Por padrão ele inverte a marca

@return

/*/
//-------------------------------------------------------------------   

Static Function SELTUDO (oBrowse, nColuna, lMTudo)

Local aArea		:= GetArea()
Local nX		:= 0
Local oViewAtu	:= FwViewActive()

Default oBrowse	:= oTcBrw2
Default nColuna := 1
Default lMTudo	:= .F.

If nColuna == 1
	For nX := 1 to Len(oBrowse:aArray)
		If lMTudo
			oBrowse:aArray[nX,1]:= .T.
		Else
			oBrowse:aArray[nX,1]:= !oBrowse:aArray[nX,1]
		EndIf
		oBrowse:nAt := nX
		//oBrowse:DrawSelect()
		ATUCNDPG()
		ATUACOLS(1)
	Next nX
		
	oBrowse:GoTop()
	oBrowse:DrawSelect()
	
	If oViewAtu <> NIL
		If oViewAtu:lActivate
			oViewAtu:Refresh()
		EndIf
	EndIf

EndIf

RestArea(aArea)

Return

// FUNÇÃO PARA MARCAR/DESMARCAR TODOS OS TÍTULOS DE UMA MESMA NOTA
// DJALMA BORGES 25/01/2017
Static Function SELNOTAINT(oBrowse)

	Local nX		:= 0
	Local oViewAtu	:= FwViewActive()
	
	Local cNotaAtu := aDadosT2[oTcBrw2:nAt,3]
	Local lMark    := !aDadosT2[oTcBrw2:nAt,1]
	
	Default oBrowse	:= oTcBrw2

	For nX := 1 to Len(oBrowse:aArray)
		
		If cNotaAtu == aDadosT2[nX,3]
			aDadosT2[nX,1] := lMark
		EndIf
		
		oBrowse:nAt := nX
		//oBrowse:DrawSelect()
		ATUCNDPG()
		ATUACOLS(1)
	Next nX
		
	oBrowse:GoTop()
	oBrowse:DrawSelect()
	
	If oViewAtu <> NIL
		If oViewAtu:lActivate
			oViewAtu:Refresh()
		EndIf
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} EDITABRW

Edição do Grid Faturas

@author  Allan Bonfim

@since   13/01/2013

@version P11 

@param [aEdita], Array, Array com os campos para edição

@return logico, Validação da rotina

/*/
//-------------------------------------------------------------------   

Static Function EDITABRW (aEdita)

Local aArea		:= GetArea()

If oTcBrw2 <> NIL
	If Len (oTcBrw2:aArray) > 0
		lEditCell(@aEdita, oTcBrw3,, 1)
		lEditCell(@aEdita, oTcBrw3,, 2)
	EndIf
EndIf

RestArea(aArea)

Return .T.      

//-------------------------------------------------------------------
/*/{Protheus.doc} TOTITULO

Totalizador dos títulos

@author  Allan Bonfim

@since   14/11/2014

@version P11 

@param [oPanelPar], Objeto, Objeto para criação do totalizador

@return logico, Validação da rotina

/*/
//-------------------------------------------------------------------

Static Function TOTITULO(oPanelPar)

Local aArea		:= GetArea()
Local oFont25	:= TFont():New("Arial",,25,,.T.,,,,.T.,.F.)
Local oSayTotT

//TSay(): New ( [ nRow], [ nCol], [ bText], [ oWnd], [ cPicture], [ oFont], [ uParam7], [ uParam8], [ uParam9], [ lPixels], [ nClrText], [ nClrBack], [ nWidth], [ nHeight], [ uParam15], [ uParam16], [ uParam17], [ uParam18], [ uParam19], [ lHTML] ) --> oObjeto

oSayTotT := TSay():New(005,005, {|| "TOTAL TITULOS: "}, oPanelPar ,,oFont ,,,,.T.,CLR_BLACK,CLR_WHITE, 60, 10)
oGetTotT := TGet():New(005,055, {|u| ((nTotT := TOTALIZA(1)), (If(PCount()>0, nTotT:=u, nTotT)))}, oPanelPar, 80, 10, "@E 9,999,999,999,999.99",,,,,,,.T.)
oGetTotT:bWhen := {|| .F.}
		
RestArea(aArea)

Return .T.    

//-------------------------------------------------------------------
/*/{Protheus.doc} TOTFATURA

Totalizador das faturas

@author  Allan Bonfim

@since   14/11/2014

@version P11 

@param [oPanelPar], Objeto, Objeto para criação do totalizador

@return logico, Validação da rotina

/*/
//-------------------------------------------------------------------

Static Function TOTFATURA(oPanelPar)

Local aArea		:= GetArea()
Local oFont25	:= TFont():New("Arial",, 25,,.T.,,,,.T.,.F.)
Local oSayTotF

//TSay(): New ( [ nRow], [ nCol], [ bText], [ oWnd], [ cPicture], [ oFont], [ uParam7], [ uParam8], [ uParam9], [ lPixels], [ nClrText], [ nClrBack], [ nWidth], [ nHeight], [ uParam15], [ uParam16], [ uParam17], [ uParam18], [ uParam19], [ lHTML] ) --> oObjeto
oSayTotF := TSay():New(005,005, {|| "TOTAL FATURA: "}, oPanelPar ,,oFont ,,,,.T.,CLR_BLACK,CLR_WHITE, 60, 10)
oGetTotF := TGet():New(005,055, {|u| ((nTotF := TOTALIZA(2)), (If(PCount()>0, nTotF:=u, nTotF)))}, oPanelPar, 80, 10, "@E 9,999,999,999,999.99",,,,,,,.T.)
oGetTotF:bWhen := {|| .F.}

RestArea(aArea)

Return .T.                                           

//-------------------------------------------------------------------
/*/{Protheus.doc} TOTFATURA

Função para cálculo dos totalizadores

@author  Allan Bonfim

@since   14/11/2014

@version P11 

@param [nOpcTot], Numerico, Define o totalizador que será calculado

@return numerico, Valor do totalizador

/*/
//-------------------------------------------------------------------

Static Function TOTALIZA(nOpcTot)

Local aArea		:= GetArea()
Local nRet		:= 0
Local nX		:= 0

Default nOpcTot	:= 1

If nOpcTot == 1 //Totalizar Titulos

	For nX:= 1 to Len (oTcBrw2:aArray)
		If (oTcBrw2:aArray[nX][1])
			nRet += oTcBrw2:aArray[nX][8]
		EndIf
	Next nX

ElseIf nOpcTot == 2 //Totalizador Faturas

	For nX:= 1 to Len (oTcBrw3:aArray)
		nRet += oTcBrw3:aArray[nX][2]
	Next nX

EndIf

RestArea(aArea)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM001A

Botões Simular e Simular todos

@author  Allan Bonfim

@since   14/11/2014

@version P11 

@param [oPanelPar], Objeto, Objeto para criação dos botões

@return

/*/
//-------------------------------------------------------------------   

Static Function CAMBM001A(oPanelPar)

Local oModelF 		:= FWModelActive()
Local nOperation	:= oModelF:GetOperation()
Local oButSimu    	:= NIL
Local lWhenPesq   	:= IIF (nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_INSERT, .T., .F.)
Local oPnlRight   	:= NIL
Local nPosButton	:= 0
Local oFont18		:= TFont():New("Arial",,18,,.T.,,,,,.F.,.F.)
Local bExecSimu		:= {|| FWMsgRun(, {|| CAMBM001F(2)}, "Aguarde...")}
Local bExecSimuT	:= {|| FWMsgRun(, {|| CAMBM001F(3)}, "Aguarde...")}
Local bValidSimu	:= {|| .T.} 
Local oButSimuT    	:= NIL

oPnlRight 	:= TPanel():New(0, 0, "", oPanelPar,,,,, RGB(255,255,255), 0, 0)
oPnlRight:Align := 5

nPosButton := oPnlRight:nClientHeight / 5

oButSimu := TButton():New(nPosButton, 20, "Simular", oPnlRight, bExecSimu, 60, 15,, oFont18,, .T.,, "Executa a Simulação das Faturas do Cliente Selecionado",,  {|| lWhenPesq}, bValidSimu, .F.)
oButSimuT := TButton():New(nPosButton+20, 20, "Simular Todos", oPnlRight, bExecSimuT, 60, 15,, oFont18,, .T.,, "Executa a Simulação das Faturas de Todos os Clientes",,  {|| lWhenPesq}, bValidSimu, .F.)

Return
          



Static Function ATUACOLS(nAcols)

Local aArea		:= GetArea()
Local nPosReg	:= 0

Default nAcols 	:= 1

If nAcols == 1

	If oTcBrw2 <> NIL
		If Len (oTcBrw2:aArray) > 0
			If oTcBrw2:aArray[oTcBrw2:nAt,1]
				nPosReg := ASCAN(aTotTit, {|x| x[1] == oTcBrw1:aArray[oTcBrw1:nAt,1] .AND. x[2] == oTcBrw1:aArray[oTcBrw1:nAt,2] .AND. x[3] == oTcBrw2:aArray[oTcBrw2:nAt,2]  .AND. x[4] == oTcBrw2:aArray[oTcBrw2:nAt,3]  .AND. x[5] == oTcBrw2:aArray[oTcBrw2:nAt,4] .AND. x[6] == oTcBrw2:aArray[oTcBrw2:nAt,5] .AND. x[7] == oTcBrw2:aArray[oTcBrw2:nAt,6] .AND. x[8] == oTcBrw2:aArray[oTcBrw2:nAt,7] .AND. x[9] == oTcBrw2:aArray[oTcBrw2:nAt,8]} )
				If nPosReg == 0
					If !EMPTY(oTcBrw2:aArray[oTcBrw2:nAt,3]) .AND. !EMPTY(oTcBrw2:aArray[oTcBrw2:nAt,8])
					   AADD(aTotTit, {oTcBrw1:aArray[oTcBrw1:nAt,1], oTcBrw1:aArray[oTcBrw1:nAt,2], oTcBrw2:aArray[oTcBrw2:nAt,2], oTcBrw2:aArray[oTcBrw2:nAt,3], oTcBrw2:aArray[oTcBrw2:nAt,4], oTcBrw2:aArray[oTcBrw2:nAt,5], oTcBrw2:aArray[oTcBrw2:nAt,6], oTcBrw2:aArray[oTcBrw2:nAt,7], oTcBrw2:aArray[oTcBrw2:nAt,8]})
					EndIf
				EndIf
			Else			
				nPosReg := ASCAN(aTotTit, {|x| x[1] == oTcBrw1:aArray[oTcBrw1:nAt,1] .AND. x[2] == oTcBrw1:aArray[oTcBrw1:nAt,2] .AND. x[3] == oTcBrw2:aArray[oTcBrw2:nAt,2]  .AND. x[4] == oTcBrw2:aArray[oTcBrw2:nAt,3]  .AND. x[5] == oTcBrw2:aArray[oTcBrw2:nAt,4] .AND. x[6] == oTcBrw2:aArray[oTcBrw2:nAt,5] .AND. x[7] == oTcBrw2:aArray[oTcBrw2:nAt,6] .AND. x[8] == oTcBrw2:aArray[oTcBrw2:nAt,7] .AND. x[9] == oTcBrw2:aArray[oTcBrw2:nAt,8]} )
				If nPosReg > 0
					aDel(aTotTit, nPosReg)
					aSize(aTotTit, Len(aTotTit)-1)
				EndIf
			EndIf
		EndIf
	EndIf
	
ElseIf nAcols == 2
    
	If oTcBrw1 <> NIL
		If Len (oTcBrw1:aArray) > 0
			nPosReg := ASCAN(aFaturas, {|x| x[1] == oTcBrw1:aArray[oTcBrw1:nAt,1] .AND. x[2] == oTcBrw1:aArray[oTcBrw1:nAt,2]})
			If nPosReg > 0
				While nPosReg > 0
					aDel(aFaturas, nPosReg)
					aSize(aFaturas, Len(aFaturas)-1)
					nPosReg := ASCAN(aFaturas, {|x| x[1] == oTcBrw1:aArray[oTcBrw1:nAt,1] .AND. x[2] == oTcBrw1:aArray[oTcBrw1:nAt,2]})
				EndDo
			EndIf
			
			For nX:= 1 to Len(aParcelas)
				AADD(aFaturas, {oTcBrw1:aArray[oTcBrw1:nAt,1], oTcBrw1:aArray[oTcBrw1:nAt,2], aParcelas[nX][1], aParcelas[nX][2]})
			Next nX
			
			CGRIDFAT(,, .T.)
		EndIf
	EndIf

ElseIf nAcols == 3

	If oTcBrw1 <> NIL
		If Len (oTcBrw1:aArray) > 0	
			nPosReg := ASCAN(aFaturas, {|x| x[1] == oTcBrw1:aArray[oTcBrw1:nAt,1] .AND. x[2] == oTcBrw1:aArray[oTcBrw1:nAt,2]})
			If nPosReg > 0
				While nPosReg > 0
					aDel(aFaturas, nPosReg)
					aSize(aFaturas, Len(aFaturas)-1)
					nPosReg := ASCAN(aFaturas, {|x| x[1] == oTcBrw1:aArray[oTcBrw1:nAt,1] .AND. x[2] == oTcBrw1:aArray[oTcBrw1:nAt,2]})
				EndDo
			EndIf
			
			For nX:= 1 to Len(oTcBrw3:aArray)
				AADD(aFaturas, {oTcBrw1:aArray[oTcBrw1:nAt,1], oTcBrw1:aArray[oTcBrw1:nAt,2], oTcBrw3:aArray[nX,1], oTcBrw3:aArray[nX,2]})
			Next nX
			
			CGRIDFAT(,, .T.)
		EndIf	
	EndIf
	
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CALCPARC

Calcula as parcelas das faturas

@author  Allan Bonfim

@since   14/11/2014

@version P11 

@param

@return

/*/
//-------------------------------------------------------------------   

Static Function CALCPARC()

Local aArea		:= GetArea()
Local oModelAtu	:= FwModelActive()
Local oViewAtu	:= FwViewActive()
Local nValor	:= 0
Local nValSol	:= 0
Local nX		:= 0
Local cNotaAnt := ""

aParcelas := {}
nValor := nTotT 

If oTcBrw1 <> NIL
	If Len (oTcBrw1:aArray) > 0
		If oTcBrw2 <> NIL
			If Len (oTcBrw2:aArray) > 0
				For nX := 1 to Len(oTcBrw2:aArray)
					If oTcBrw2:aArray[nX,1]
//						nValSol += SD2->(GETADVFVAL("SD2", "D2_ICMSRET", xFilial("SD2")+oTcBrw2:aArray[nX,3]+oTcBrw2:aArray[nX,2]+oTcBrw1:aArray[oTcBrw1:nAt,1]+oTcBrw1:aArray[oTcBrw1:nAt,2],3))
						// DJALMA BORGES 25/01/2017 - INÍCIO
						If cNotaAnt <> oTcBrw2:aArray[nX,3]
							If SF2->(GETADVFVAL("SF2", "F2_ICMSRET", xFilial("SF2")+oTcBrw2:aArray[nX,3]+oTcBrw2:aArray[nX,2]+oTcBrw1:aArray[oTcBrw1:nAt,1]+oTcBrw1:aArray[oTcBrw1:nAt,2],1)) > 0
								nValSol += SF2->(GETADVFVAL("SF2", "F2_ICMSRET", xFilial("SF2")+oTcBrw2:aArray[nX,3]+oTcBrw2:aArray[nX,2]+oTcBrw1:aArray[oTcBrw1:nAt,1]+oTcBrw1:aArray[oTcBrw1:nAt,2],1)) // DJALMA BORGES 24/01/2017
							EndIf	
							cNotaAnt := oTcBrw2:aArray[nX,3]
						EndIf
						// DJALMA BORGES 25/01/2017 - FIM
					EndIf
				Next nX
			EndIf		
		EndIf
	EndIf
EndIf
					
aParcelas := Condicao(nValor, oModelAtu:GetModel("PARAMETROS"):GetValue("ZZZ_CONDPG"), 0, oModelAtu:GetModel("PARAMETROS"):GetValue("ZZZ_DTREFE"), nValSol)
		
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ATUCNDPG

Atualiza a Condição de Pagamento dos Parâmetros conforme faixa
@author  Allan Bonfim
@since   14/11/2014
@version P11 
@param
@return

/*/
//-------------------------------------------------------------------   

Static Function ATUCNDPG()

Local aArea		:= GetArea()
Local oModelAtu	:= FwModelActive()
Local oViewAtu	:= FwViewActive()
//Local cCondPg	:= SA1->(GETADVFVAL("SA1", "A1_COND", xFilial("SA1")+oTcBrw1:aArray[oTcBrw1:nAt,1]+oTcBrw1:aArray[oTcBrw1:nAt,2],1))
Local cCondPg	:= SA1->A1_COND
Local cQueryTmp := ""
Local cTmpQuery	:= GetNextAlias()
Local nValSol	:= 0
Local nValFaixa	:= 0
Local cNotaAnt := ""

nTotT := TOTALIZA(1)

If oTcBrw1 <> NIL
	If Len (oTcBrw1:aArray) > 0
		If oTcBrw2 <> NIL
			If Len (oTcBrw2:aArray) > 0
				For nX := 1 to Len(oTcBrw2:aArray)
					If oTcBrw2:aArray[nX,1]
//						If SF2->(GETADVFVAL("SF2", "F2_ICMSRET", xFilial("SF2")+oTcBrw2:aArray[nX,3]+oTcBrw2:aArray[nX,2]+oTcBrw1:aArray[oTcBrw1:nAt,1]+oTcBrw1:aArray[oTcBrw1:nAt,2],1)) > 0
//							nValSol += SD2->(GETADVFVAL("SD2", "D2_ICMSRET", xFilial("SD2")+oTcBrw2:aArray[nX,3]+oTcBrw2:aArray[nX,2]+oTcBrw1:aArray[oTcBrw1:nAt,1]+oTcBrw1:aArray[oTcBrw1:nAt,2],3))
//						EndIf
						// DJALMA BORGES 25/01/2017 - INÍCIO
						If cNotaAnt <> oTcBrw2:aArray[nX,3]
							If SF2->(GETADVFVAL("SF2", "F2_ICMSRET", xFilial("SF2")+oTcBrw2:aArray[nX,3]+oTcBrw2:aArray[nX,2]+oTcBrw1:aArray[oTcBrw1:nAt,1]+oTcBrw1:aArray[oTcBrw1:nAt,2],1)) > 0
								nValSol += SF2->(GETADVFVAL("SF2", "F2_ICMSRET", xFilial("SF2")+oTcBrw2:aArray[nX,3]+oTcBrw2:aArray[nX,2]+oTcBrw1:aArray[oTcBrw1:nAt,1]+oTcBrw1:aArray[oTcBrw1:nAt,2],1)) // DJALMA BORGES 24/01/2017
							EndIf	
							cNotaAnt := oTcBrw2:aArray[nX,3]
						EndIf
						// DJALMA BORGES 25/01/2017 - FIM
					EndIf
				Next nX
			EndIf		
		EndIf
	EndIf
EndIf

nValFaixa := nTotT - nValSol

If oTcBrw1 <> NIL
	If Len (oTcBrw1:aArray) > 0
		cQueryTmp := "SELECT A1_COD, A1_LOJA, E4_CODIGO "+CHR(13)+CHR(10)
		cQueryTmp += "FROM "+RetSqlName("SA1")+" SA1 (NOLOCK) "+CHR(13)+CHR(10)
		cQueryTmp += "INNER JOIN "+RetSqlName("ZZF")+" ZZF (NOLOCK) "+CHR(13)+CHR(10)
		cQueryTmp += "ON (ZZF_FILIAL = '"+xFilial("ZZF")+"' AND ZZF_CODIGO = A1_XGRPCON AND ZZF.D_E_L_E_T_ = '') "+CHR(13)+CHR(10)
		cQueryTmp += "INNER JOIN "+RetSqlName("ZZG")+" ZZG (NOLOCK) "+CHR(13)+CHR(10)
		cQueryTmp += "ON (ZZG_FILIAL = '"+xFilial("ZZG")+"' AND ZZG_CODGRP = ZZF_CODIGO AND ZZG.D_E_L_E_T_ = '') "+CHR(13)+CHR(10)
		cQueryTmp += "INNER JOIN "+RetSqlName("SE4")+" SE4 (NOLOCK) "+CHR(13)+CHR(10)
		cQueryTmp += "ON (E4_FILIAL = '"+xFilial("SE4")+"' AND E4_CODIGO = ZZG_CODPAG AND E4_MSBLQL <> '1' AND SE4.D_E_L_E_T_ = '') "+CHR(13)+CHR(10)
		cQueryTmp += "WHERE SA1.D_E_L_E_T_ = '' "+CHR(13)+CHR(10)
		cQueryTmp += "AND A1_FILIAL = '"+xFilial("SA1")+"' "+CHR(13)+CHR(10)
		cQueryTmp += "AND A1_COD = '"+oTcBrw1:aArray[oTcBrw1:nAt,1]+"' "+CHR(13)+CHR(10)
		cQueryTmp += "AND A1_LOJA = '"+oTcBrw1:aArray[oTcBrw1:nAt,2]+"' "+CHR(13)+CHR(10)

		If nTotT > 0
			cQueryTmp += "AND "+VALTOSQL(nValFaixa)+" >= E4_INFER "+CHR(13)+CHR(10)
			cQueryTmp += "AND "+VALTOSQL(nValFaixa)+" <= E4_SUPER "+CHR(13)+CHR(10)
		EndIf

		cQueryTmp += "ORDER BY E4_CODIGO "+CHR(13)+CHR(10)

		If (Select(cTmpQuery) > 0)
			(cTmpQuery)->(DbCloseArea())
		EndIf

		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQueryTmp), cTmpQuery, .T., .T.)
	
		If !(cTmpQuery)->(EOF())
			cCondPg := (cTmpQuery)->E4_CODIGO
		EndIf
	EndIf
EndIf

If oModelAtu <> NIL
	If oModelAtu:GetModel("PARAMETROS") <> NIL
		oModelAtu:GetModel("PARAMETROS"):LoadValue("ZZZ_CONDPG", cCondPg)
	EndIf	
EndIf

If (Select(cTmpQuery) > 0)
	(cTmpQuery)->(DbCloseArea())
EndIf
	
If oViewAtu <> NIL
	If oViewAtu:lActivate
		oViewAtu:Refresh()
	EndIf
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM01TOK

Validação final da rotina (Tudo Ok)

@author  Allan Bonfim

@since   14/11/2014

@version P11 

@param	[oModelCab], objeto, Objeto do Model
		
@return logico, Validação da rotina

/*/
//------------------------------------------------------------------- 

STATIC FUNCTION CAMBM01TOK(oModelCab)

Local aArea	 	:= GetArea()
Local lRet	 	:= .T.
Local nOper		:= oModelCab:GetOperation()   
Local nTotTit	:= 0
Local nTotFat	:= 0

oModelCab:lModify := .T.
	
If nOper == 3 .OR. nOper == 4

	aEval(aTotTit, {|x| nTotTit += x[9]})
	aEval(aFaturas, {|x| nTotFat += x[4]})

	If nTotTit == 0 .OR. nTotFat == 0
	
		HELP("ERRO",,"ERRO",,"Você deve selecionar títulos e fazer a simulação para a geração das faturas.",1,0)
		lRet := .F.

	Else
			
		If	!MsgYesNo("Deseja gerar as faturas a receber dos títulos selecionados ?", "Renegociação")
			lRet := .F.
		Else		
			If nTotTit <> nTotFat
				HELP("ERRO",,"ERRO",,"O valor dos títulos selecionados não confere com o valor total das faturas.",1,0)
				lRet := .F.
			EndIf
			
			If lRet
				If ASCAN(aFaturas, {|x| x[3] < oModelCab:GetModel("PARAMETROS"):GetValue("ZZZ_DTREFE") }) > 0
					HELP("ERRO",,"ERRO",,"Existem faturas com a data inferior a data de referência.",1,0)
					lRet := .F.
	    		EndIf
			EndIf
		EndIf
				
    EndIf
	
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM01GRV

Gravação das Faturas

@author  Allan Bonfim

@since   14/11/2014

@version P11 

@param	[oModelAtu], objeto, Objeto do Model

@return logico, Validação da rotina
              

/*/
//------------------------------------------------------------------- 

// BARRA DE PROGRESSO PARA A GRAVAÇÃO DOS TÍTULOS
// DJALMA BORGES 16/02/2017
STATIC FUNCTION CAMBM01GRV(oModelAtu)
	
	Local lRet
	
	FWMsgRun(, {|| lRet := PROGRAVA(oModelAtu)}, "Aguarde...")

RETURN lRet

Static Function PROGRAVA(oModelAtu)
         
Local aArea			:= GetArea()
Local lRet			:= .T.
Local nOper			:= oModelAtu:GetOperation()
Local aDadosIr		:= {0,0}
Local aPccBxCr		:= {0,0,0,0}
Local aRastroOri	:= {}
Local nValProces	:= 0
Local aFlagCTB 		:= {}
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T., .F. )
Local nHdlPrv		:= 0
Local nTotal		:= 0
Local cArquivo
Local cNumFat
Local aAreaSE1
Local lPccBxCr		:= .F. //If (FindFunction("FPccBxCr"),FPccBxCr(),.F.)
Local lBaseImp		:= .F. //If(FindFunction('F040BSIMP'),F040BSIMP(2),.F.)
Local lIrPjBxCr		:= .F. //If (FindFunction("FIrPjBxCr"),FIrPjBxCr(),.F.)
Local nValTotal 	:= 0
Local nTotFatura	:= 0
Local cPadrao		:= "595"
Local lPadrao  		:= VerPadrao(cPadrao)
Local aRastroDes	:= {}
Local aTitInc 		:= {}
Local aTit			:= {}
Local nPis			:= 0
Local nCofins		:= 0
Local nCsll			:= 0
Local cIrBxCr		:= ""
Local nIrrf			:= 0
Local cPccBxCr		:= "" //Fa280VerImp(cNat,.T.) 
Local nTotIr   		:= 0
Local nBaseImp		:= 0
Local nTotBaseIr	:= 0
Local nPropIR		:= 1
Local nTotBase		:= 0
Local nTotPis		:= 0
Local nTotCofins	:= 0
Local nTotCsll		:= 0
Local aDadosFat		:= {}
Local cFatura		:= ""
Local cCliente		:= ""
Local lRastro		:= If(FindFunction("FVerRstFin"),FVerRstFin(),.F.)
Local oViewAtu		:= FwViewActive()

Private mv_par01	:= 1 //Considera Loja = SIM
Private	cNat   		:= CRIAVAR("E1_NATUREZ")
Private cTipoFat	:= "FT" //Criavar ("E1_TIPOFAT")
Private cPrefixF 	:= SuperGetMv("MV_FATPREF",, "FAT")
//Private	cNumFat		:= 0
Private nRegSE1		:= 0
Private nMoedFat	:= 1
Private lMsErroAuto	:= .F.
Private cLote

//Rotina similar a FINA280 - Faturas a Receber pois ela não tem ExecAuto
If nOper == 3 .OR. nOper == 4
 
	Begin Transaction
		//aSort(aTotTit,,, {|x,y| x[1]+x[2]+DtoS(x[7]) < y[1]+y[2]+DtoS(y[7])})   
		aSort(aTotTit,,, {|x,y| x[1]+x[2]+DtoS(x[7])+x[4] < y[1]+y[2]+DtoS(y[7])+y[4]})
		For nX := 1 to Len(aTotTit)
			
			aAreaSE1 := SE1->(GetArea())
				DbSelectArea("SE1")
				SE1->(DbSetOrder(2))  //E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
                If SE1->(DbSeek(xFilial("SE1")+aTotTit[nX][1]+aTotTit[nX][2]+aTotTit[nX][3]+aTotTit[nX][4]+aTotTit[nX][5]+aTotTit[nX][6]))
					nRegSE1	:= SE1->(RECNO())
				EndIf
				
				If ALLTRIM(cCliente) <> ALLTRIM(SE1->E1_CLIENTE+SE1->E1_LOJA)
					cCliente 	:= SE1->E1_CLIENTE+SE1->E1_LOJA
					cNumFat		:= SE1->E1_NUM
					cNat		:= SE1->E1_NATUREZ
					AADD(aDadosFat, {SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_NUM, SE1->E1_NATUREZ})
				EndIf
   	    	RestArea(aAreaSE1)
   	    	
	   		//FA280MonFa(cAliasSe1, cFilSE1, cPrefSE1, cNumSE1, cParcSE1, nRegSE1, cNumFat, cPreFat, cTipoFat, dDataBx, lElimResid, cArquivo, nTotal,;
			//			nHdlPrv, lUsaFlag, aFlagCTB, nValProces, aRastroOri, aPccBxCr, aDadosIR, cTitpai)
			
			//FUNÇÃO PADRÃO SOBRESCRITA. NECESSÁRIO ABRIR CHAMADO NA TOTVS PARA A FUNÇÃO PADRÃO - Djalma Borges 21/11/2016
			FA280MFAZZ(	"SE1", xFilial("SE1"), aTotTit[nX][3], aTotTit[nX][4], aTotTit[nX][5], nRegSE1, cNumFat, cPrefixF, cTipoFat, dDataBase,.T., @cArquivo, @nTotal, @nHdlPrv, lUsaFlag,;
				   		@aFlagCTB, @nValProces, aRastroOri, aPccBxCr, aDadosIR, (aTotTit[nX][3]+aTotTit[nX][4]+aTotTit[nX][5]+aTotTit[nX][6]+aTotTit[nX][1]+aTotTit[nX][2]))

		Next nX
	
		nValTotal 	:= 0
		cCliente	:= ""

		aSort(aDadosFat,,, {|x,y| x[1]+x[2] < y[1]+y[2]})
		aSort(aFaturas,,, {|x,y| x[1]+x[2]+DtoS(x[3]) < y[1]+y[2]+DtoS(y[3])})
				
		For nX := 1 to Len(aFaturas)
			
			If ALLTRIM(cCliente) <> ALLTRIM(aFaturas[nX][1]+aFaturas[nX][2])
				cCliente 	:= aFaturas[nX][1]+aFaturas[nX][2]
				cParcela	:= "0"					
				cFatura		:= aDadosFat[ASCAN(aDadosFat, {|x| ALLTRIM(x[1]+x[2]) == cCliente})][3]
				cNat		:= aDadosFat[ASCAN(aDadosFat, {|x| ALLTRIM(x[1]+x[2]) == cCliente})][4]
			EndIf
			
			nTotFatura := 0
			//PCC Baixa CR
			//Necessario somar o total da fatura antes da geracao da fatura para proporcionalizar o valor do PCC
			If lPccBxCR .OR. lBaseImp .OR. lIrPjBxCr
				aEval(aFaturas, {|x| If(ALLTRIM(x[1]+x[2]) == cCliente, nTotFatura += aFaturas[nX][4], NIL)})
			Endif
			
			
			//Gera fatura atraves da rotina automatica do Fina040 para que faca o recalculo e gere os abatimentos referente ao valor total titulos que serao selecionados;
			nValTotal	:= 0 
			//nLen := Len(aCols)            

			//PCC Baixa CR
			//Tratamento da proporcionalizacao dos impostos PCC para posterior gravacao na parcela gerada
			If lPccBxCR .OR. lBaseImp
				nPropPcc	:= xMoeda(aFaturas[nX][4], nMoedFat, 1) / nTotFatura
				nPis		:= Round(NoRound(aPccBxCr[1] * nPropPcc,3),2)
				nCofins		:= Round(NoRound(aPccBxCr[2] * nPropPcc,3),2)						
				nCsll		:= Round(NoRound(aPccBxCr[3] * nPropPcc,3),2)
				nBaseImp	:= Round(NoRound(aPccBxCr[4] * nPropPcc,3),2)
				nTotPis		+= nPis
				nTotCofins	+= nCofins
				nTotCsll	+= nCsll
				nTotBase	+= nBaseImp
				 						
				//Acerto de eventuais problemas de arredondamento
				If aPccBxCr[1] - nTotPis <= 0.01
					nPis		+= aPccBxCr[1] - nTotPis
				Endif

				If aPccBxCr[2] - nTotCofins <= 0.01
					nCofins	+= aPccBxCr[2] - nTotCofins
				Endif

				If aPccBxCr[3] - nTotCsll <= 0.01
					nCSll		+= aPccBxCr[3] - nTotCsll
				Endif

				If aPccBxCr[4] - nTotBase <= 0.01
					nBaseImp	+= aPccBxCr[4] - nTotBase
				Endif
			Endif						
			
			//IR Baixa CR
			//Tratamento da proporcionalizacao dos impostos IR
			//para posterior gravacao na parcela gerada
			If lIrPjBxCr .or. lBaseImp
				nPropIr		:= xMoeda(aFaturas[nX][4], nMoedFat, 1) / nTotFatura
				nIrrf		:= Round(NoRound(aDadosIR[1] * nPropIr,3),2)
				nBaseImp	:= Round(NoRound(aDadosIR[2] * nPropIr,3),2)
				nTotIr		+= nIrrf
				nTotBaseIr	+= nBaseImp
				 						
				//Acerto de eventuais problemas de arredondamento
				If aDadosIR[1] - nTotIr <= 0.01
					nIrrf += aDadosIR[1] - nTotIr
				Endif      
				
				If aDadosIR[2] - nTotIr  <= 0.01
					nBaseImp += aDadosIR[2] - nTotIr
				Endif
			Endif
			
			IncProc("Incluindo a fatura...")

			cParcela := SOMA1(cParcela)
				
			aTit := {}

			AADD(aTit , {"E1_FILIAL"	, xFilial("SE1")																	, NIL})						
			AADD(aTit , {"E1_PREFIXO"	, cPrefixF																			, NIL})
			AADD(aTit , {"E1_NUM"    	, cFatura		 																	, NIL})
			AADD(aTit , {"E1_PARCELA"	, cParcela																			, NIL})
			AADD(aTit , {"E1_TIPO"   	, cTipoFat		 																	, NIL})
			AADD(aTit , {"E1_NATUREZ"	, cNat			 																	, NIL})
			AADD(aTit , {"E1_SITUACA"	, "0"			 				 													, NIL})
			AADD(aTit , {"E1_VENCTO" 	, aFaturas[nX][3]				 													, NIL})
			AADD(aTit , {"E1_VENCREA"	, DataValida(aFaturas[nX][3],.T.)						 							, NIL})
			AADD(aTit , {"E1_VENCORI"	, DataValida(aFaturas[nX][3],.T.)  						 							, NIL})
			AADD(aTit , {"E1_EMISSAO"	, oModelAtu:GetModel("PARAMETROS"):GetValue("ZZZ_DTREFE")							, NIL})
			AADD(aTit , {"E1_EMIS1"		, oModelAtu:GetModel("PARAMETROS"):GetValue("ZZZ_DTREFE")							, NIL})
			AADD(aTit , {"E1_CLIENTE"	, aFaturas[nX][1]																	, NIL})
			AADD(aTit , {"E1_LOJA"   	, aFaturas[nX][2]																	, NIL})
			AADD(aTit , {"E1_NOMCLI" 	, GETADVFVAL("SA1", "A1_NREDUZ", xFilial("SA1")+aFaturas[nX][1]+aFaturas[nX][2],1)	, NIL})
			AADD(aTit , {"E1_MOEDA"  	, nMoedFat																			, NIL})
			AADD(aTit , {"E1_VALOR"  	, aFaturas[nX][4]		  															, NIL})
			AADD(aTit , {"E1_SALDO"  	, aFaturas[nX][4]																	, NIL})
			AADD(aTit , {"E1_VLCRUZ" 	, xMoeda(aFaturas[nX][4], nMoedFat,1)												, NIL})
			AADD(aTit , {"E1_STATUS" 	, "A"																				, NIL})
			AADD(aTit , {"E1_OCORREN"	, "01"																				, NIL})
			AADD(aTit , {"E1_ORIGEM" 	, "FINA280"																			, NIL})
			AADD(aTit , {"E1_FATURA" 	, "NOTFAT"																			, NIL})
			AADD(aTit , {"E1_PORTADO" 	, GETADVFVAL("SA1", "A1_BCO1", xFilial("SA1")+aFaturas[nX][1]+aFaturas[nX][2], 1)	, NIL})
			AADD(aTit , {"E1_VALLIQ" 	, aFaturas[nX][4]																	, NIL})

			If lPccBxCr
					If "PIS" $ cPccBxCr .AND. nPis > 0
						AADD(aTit , {"E1_PIS", nPis, NIL})
					Endif
					If "COF" $ cPccBxCr .AND. nCofins > 0							
						AADD(aTit , {"E1_COFINS",  nCofins, NIL}) 
					Endif
					If "CSL" $ cPccBxCr .AND. nCsll > 0
						AADD(aTit , {"E1_CSLL", nCsll, NIL})
					Endif
				Endif						
  						
  				If lIrPjBxCr
					If "IRRF" $ cIrBxCr .AND. nIrrf > 0
						AADD(aTit , {"E1_IRRF", nIrrf, NIL})
					Endif
				Endif						

				//639.04 Base Impostos diferenciada
				If (lBaseImp .AND. nPis+nCofins+nCsll > 0)  .OR. lIrPjBxCr
					AADD(aTit , {"E1_BASEIRF"  ,  nBaseImp 	, NIL})
				Endif
				
				// TRATAMENTO PARA NÃO GERAR ISS INCORRETAMENTE 
				If (Alltrim(SE1->E1_ORIGEM) == "MATA460" ) .AND. !(GETADVFVAL("SA1", "A1_RECISS", xFilial("SA1")+aFaturas[nX][1]+aFaturas[nX][2], 1) == "1")
					AADD(aTit, {"E1_ISS", 0, NIL})
				Endif

				If !GetNewPar("MV_RMCLASS",.F.)
					MSExecAuto({|x, y| FINA040(x, y)}, aTit, 3)
				Else
				    lMsErroAuto := ClsF280InT(aTit)
				Endif
      
				If  lMsErroAuto
				    MOSTRAERRO() 
				    DisarmTransaction()
					MsUnlockAll()
					RestArea(aArea)

					HELP("ERRO",,"ERRO",,"Falha no processo de geração das Faturas a Receber. Favor entrar em contato com suporte.",1,0)
					lRet := .F.
					Return lRet
				Else

					IF lPadrao
						If nHdlPrv <= 0
							nHdlPrv := HeadProva(cLote, "FINA280", Substr(cUsuario,7,6), @cArquivo)
							lHead := .T.
						Endif

						If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
							aAdd(aFlagCTB, {"E1_LA", "S", "SE1", SE1->(Recno()), 0, 0, 0})
						Else
							RecLock("SE1")
								SE1->E1_LA := "S"
							MsUnlock()
						Endif
						
						nTotal += DetProva(nHdlPrv, cPadrao, "FINA280", cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/, /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/)
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PcoDetLan("000014", "01", "FINA280")

					//Rastreamento - Gerados
					If lRastro
						AADD(aRastroDes, {SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_VALOR})
					Endif							
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Adiciona o titulo na aTitInc - Int. Protheus x Classis³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					AADD(aTitInc, SE1->(RECNO()))
				
				DbSelectArea("SE1")					

			Endif
			
			nValTotal += xMoeda(aFaturas[nX][4], nMoedFat, 1)  // nValCruz					
			DbSelectArea("SE1")
			
			// DJALMA BORGES 16/02/2017 - INÍCIO
			If nX + 1 <= Len(aFaturas)
				If aFaturas[nX][1] + aFaturas[nX][2] <> aFaturas[nX+1][1] + aFaturas[nX+1][2]  
					If ExistBlock("FA280GRV")
						ExecBlock("FA280GRV",.F.,.F.)
					Endif
				EndIf
			Else
				If ExistBlock("FA280GRV")
					ExecBlock("FA280GRV",.F.,.F.)
				Endif
			EndIf
			// DJALMA BORGES 16/02/2017 - FIM
			
		Next nX
		
		MsgInfo("Foi enviado workflow para o(s) cliente(s) selecionado(s).")
						
		If (nTotal > 0) .AND. lPadrao
			FA280CONFA(nValTotal, cPadrao, cArquivo, nHdlPrv, @nTotal, "FINA280", @aFlagCTB)
		Endif

		//Gravacao do rastreamento
		If lRastro
			FINRSTGRV(2, "SE1", aRastroOri, aRastroDes, nValProces) 
		Endif

	End Transaction
	
//	If ExistBlock("FA280GRV") 			COMENTADO POR
//		ExecBlock("FA280GRV",.F.,.F.)	DJALMA BORGES
//	Endif								16/02/2017
	
	_cPeriDe  := DTOS(oModelAtu:GetValue("FILTROS","XXX_PERIDE"))
	_cPerAte  := DTOS(oModelAtu:GetValue("FILTROS","XXX_PERATE"))
	_dDataRef := oModelAtu:GetModel("PARAMETROS"):GetValue("ZZZ_DTREFE")
	
EndIf
	 	
RestaRea(aArea)	                    

If lRet
	MsgInfo("Faturas geradas com sucesso.","Renegociação")
	CAMBM001F(1) //Limpar campos e tela 
	
	If oViewAtu <> NIL
		If oViewAtu:lActivate
			oViewAtu:Refresh()
		EndIf
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} VLDCPO

Validação de campos

@author  Allan Bonfim
@since   14/11/2014
@version P11 
@param	[cCampo], Caracter, Campo que sofrerá validação
@return logico, Validação da rotina

/*/
//------------------------------------------------------------------- 

STATIC FUNCTION VLDCPO(cCampo)

	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local oModelAtu	:= FwModelActive()
	
	Default cCampo	:= ""
	
	Do Case
		Case cCampo == "ZZZ_DTREFE"
			If oModelAtu:GetModel("PARAMETROS"):GetValue("ZZZ_DTREFE") < oModelAtu:GetModel("FILTROS"):GetValue("XXX_PERIDE") .OR. oModelAtu:GetModel("PARAMETROS"):GetValue("ZZZ_DTREFE") < GETMV("MV_DATAFIN") .OR. oModelAtu:GetModel("PARAMETROS"):GetValue("ZZZ_DTREFE") < GETMV("MV_DATAFIS")
				HELP("ERRO",,"ERRO",,"A data de referência não poderá ser menor que o Período informado nos filtros e a data de fechamento fiscal ("+DTOC(GETMV("MV_DATAFIS"))+") .",1,0)
				lRet := .F.
			EndIf
	EndCase
	
	RestArea(aArea)

Return lRet

Static Function FA280MFaZZ( cAliasSe1,cFilSE1,cPrefSE1,cNumSE1,cParcSE1,nRegSE1,cNumFat,cPreFat,cTipoFat,;
                      dDataBx,lElimResid,cArquivo,nTotal,nHdlPrv,lUsaFlag,aFlagCTB,nValProces,aRastroOri,;
                      aPccBxCr,aDadosIR,cTitpai,nVlrISS)
                      
	Local bWhile
	Local bFor
	Local nInd 		:= SE1->(IndexOrd())
	Local nJuros 	:= 0
	Local nDesconto	:= 0
	Local nValCorr	:= 0
	Local lUsaJur	:= GetMV( "MV_JURFAT" ,.T.,.F.) // Determina se a fatura sera composta com os juros do titulo
													 // original caso haja.
													 
	Local cChaveTit := ""
	Local cChaveFK7	:= ""
	Local lAtuSldNat := .T.
	//Controle de abatimento
	Local lTitpaiSE1 := .T.
	Local nOrdTitPai:=0
	Local bSelAtb := {|| (cAliasSe1)->(!EOF()) .And. Eval(bWhile) .And. Eval(bFor) }
	
	#IFDEF TOP
		Local cArqTrab
		Local aStru := SE1->(DbStruct())
	#ENDIF
	
	Local nMulta := 0    //Valor da multa
	Local cMVJurTipo 	:= SuperGetMV("MV_JURTIPO",,"") //Tipo de calculo dos juros
	Local lLojxRMul     := .T.   //Funcao que calcula os juros e multas do loja
	Local lMvLjIntFs	:= SuperGetMv("MV_LJINTFS", , .F.) //Habilita integracao com o Financial Services?
	 
	Default dDataBx 	:= dDatabase
	Default lElimResid 	:= .T.
	Default aPccBxCr	:= {0,0,0,0}   
	Default aDadosIR	:= {0,0}                  
	Default cTitpai		:=""
	Default nVlrISS := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura pelos Titulos de Abatimentos			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea(cAliasSe1)
	#IFDEF TOP
		DbGotop()	
		bWhile := { || .T. }
		bFor	 := { ||	(cAliasSe1)->E1_FILIAL==cFilSE1 .And. (cAliasSe1)->E1_PREFIXO=cPrefSE1 .And. ;
					  		alltrim((cAliasSe1)->E1_NUM)==alltrim(cNumSE1) .And. (cAliasSe1)->E1_PARCELA==cParcSE1 }     
		If lTitpaiSE1
	 		If FunName() == "FINA281"	 
		 		Aadd(aStru, {"RECNO","N",10,0})
				cArqTrab := CriaTrab(aStru,.T.) // Nome do arquivo temporario	
				IndRegua (cAliasSe1,cArqTrab,"E1_FILIAL+E1_TITPAI",,,"Selecionando Registros...")
				DbSetOrder(1)			
				If	DbSeek(cFilSE1+cTitpai)    
						bSelAtb := {|| !Eof() .And. Alltrim((cAliasSe1)->E1_TITPAI) == Alltrim(cTitpai)}
				EndIf			
	 		Else
		 		If (nOrdTitPai:= OrdTitpai()) > 0
		  			DbSetOrder(nOrdTitPai)
					If	DbSeek(cFilSE1+cTitpai)    
						bSelAtb := {|| !Eof() .And. Alltrim((cAliasSe1)->E1_TITPAI) == Alltrim(cTitpai)}   
	
					Else
						dbSetOrder( 1 )
					Endif
				EndIf
			EndIf
		Endif
	
	#ELSE     
		
		If lTitpaiSE1
	 		If (nOrdTitPai:= OrdTitpai()) > 0
				dbselectarea("SE1")		
	  			DbSetOrder(nOrdTitPai)
				If	DbSeek(cFilSE1+cTitpai)    
					bSelAtb := {|| !Eof() .And. Alltrim((cAliasSe1)->E1_TITPAI) == Alltrim(cTitpai) }   
				Else
					DbSetOrder(1)
					DbSeek(cFilSE1+cPrefSE1+cNumSE1+cParcSE1)
	   				bWhile := { ||	(cAliasSe1)->E1_FILIAL==cFilSE1 .And. (cAliasSe1)->E1_PREFIXO=cPrefSE1 .And. ;
						  	alltrim((cAliasSe1)->E1_NUM)==alltrim(cNumSE1) .And. (cAliasSe1)->E1_PARCELA==cParcSE1 }
					bFor	 := { || .T. }			
				Endif
			Endif			
		Endif
				  	
	#ENDIF
	
	While Eval(bSelAtb) 
	
		If lTitpaiSE1
			If (  Alltrim(E1_TITPAI)!=Alltrim(cTitpai)) .and. !Empty(E1_TITPAI)
				DbSkip()
				Loop
			EndIf
		EndIf
		If	(cAliasSe1)->E1_TIPO $ MVABATIM+"/"+MVINABT+"/"+MVIRABT .And. (cAliasSe1)->E1_SALDO > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Efetua a Baixa dos Titulos de Abatimento   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FA280Baixa(cAliasSe1,cNumFat,cPrefat,cTipoFat,dDataBx,mv_par01,lElimResid,0,0,0,,lAtuSldNat, 0)
		Endif
		DBSELECTAREA(cAliasSe1)
		(cAliasSe1)->(dbSkip())
	Enddo
	
	dbGoto(nRegSE1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza a Baixa do Titulo     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !((cAliasSe1)->E1_TIPO $ MVABATIM+"/"+MVINABT+"/"+MVIRABT+"/"+MVISABT) .And. (cAliasSe1)->E1_SALDO > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a Baixa do Titulo Principal         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    //Calculo de Juros e Multas: SIGALOJA x SIGAFIN - Inicio
		nMulta := 0
		If (cMvJurTipo == "L" .OR. lMvLjIntFs) .and. lLojxRMul  .and. lUsaJur
			nMulta := LojxRMul( , , ,(cAliasSe1)->E1_SALDO, (cAliasSe1)->E1_ACRESC, (cAliasSe1)->E1_VENCREA, dDataBase, , (cAliasSe1)->E1_MULTA, ,;
	  					 (cAliasSe1)->E1_PREFIXO, (cAliasSe1)->E1_NUM, (cAliasSe1)->E1_PARCELA, (cAliasSe1)->E1_TIPO, (cAliasSe1)->E1_CLIENTE, (cAliasSe1)->E1_LOJA, cAliasSe1 )   	
	
		
		EndIf	
		nVlrISS += (cAliasSe1)->E1_ISS	// Acumulador do ISS  	
		nJuros := (cAliasSe1)->E1_SDACRES + If(lUsaJur,faJuros((cAliasSe1)->E1_VALOR,(cAliasSe1)->E1_SALDO,(cAliasSe1)->E1_VENCTO,(cAliasSe1)->E1_VALJUR,(cAliasSe1)->E1_PORCJUR,(cAliasSe1)->E1_MOEDA,(cAliasSe1)->E1_EMISSAO,dDataBase,If(cPaisLoc=="BRA",(cAliasSe1)->E1_TXMOEDA,0),,(cAliasSe1)->E1_VENCREA, cAliasSE1),0)		
		//Calculo de Juros e Multas: SIGALOJA x SIGAFIN - Final
		nDesconto := (cAliasSe1)->E1_SDDECRE
		nValCorr:= fa280Correc(dDataBx,cAliasSe1)
		FA280Baixa(cAliasSe1,cNumFat,cPrefat,cTipoFat,dDataBx,mv_par01,lElimResid,nJuros,nDesconto,nValCorr,aPccBxCr,lAtuSldNat, nMulta,aDadosIr,cTitPai) 	//Calculo de Juros e Multas: SIGALOJA x SIGAFIN 
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera movimento da Baixa do Titulo no SE5   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FA280Movim(	"SE1",cFilSE1,cNumFat,dDataBx,/*cRecPag*/,/*cTipoDoc*/,/*cHistor*/,/*cMotBx*/,;
						cNumFat,cPreFat,nJuros,nDesconto,nValCorr,@cArquivo,@nTotal,@nHdlPrv,lUsaFlag,aFlagCTB,;
						@nValProces,aRastroOri, nMulta)	//Calculo de Juros e Multas: SIGALOJA x SIGAFIN 
		/*
		Atualiza o status do titulo no SERASA */
		If cPaisLoc == "BRA"
			If SE1->E1_SALDO <= 0
				cChaveTit := xFilial("SE1") + "|" +;
							(cAliasSe1)->E1_PREFIXO + "|" +;
							(cAliasSe1)->E1_NUM		+ "|" +;
							(cAliasSe1)->E1_PARCELA + "|" +;
							(cAliasSe1)->E1_TIPO	+ "|" +;
							(cAliasSe1)->E1_CLIENTE + "|" +;
							(cAliasSe1)->E1_LOJA
				cChaveFK7 := FINGRVFK7("SE1",cChaveTit)
				F770BxRen("2","FAT",cChaveFK7)  /* a espera de um nome */
			Endif
		Endif	
					
	Endif
	
	SE1->(DbSetOrder(nInd))
	
Return