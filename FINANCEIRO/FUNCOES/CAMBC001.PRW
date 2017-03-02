#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWBROWSE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBC001

Cadastro de Grupos X Condição de Pagamento

@author  Allan Bonfim

@since   24/10/2014

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------   

User Function CAMBC001()

Local _aArea		:= GetArea()
Local _oBrowse

_oBrowse := FWMarkBrowse():New()
_oBrowse:SetAlias("ZZF")
_oBrowse:SetDescription("Cadastro de Grupo de Condição de Pagamento")
_oBrowse:DisableDetails()

_oBrowse:AddLegend("ZZF_MSBLQL == '1' "	, "BR_VERMELHO"	, "Grupo Bloqueado")
_oBrowse:AddLegend("ZZF_MSBLQL <> '1' "	, "BR_VERDE"	, "Grupo Ativo")
_oBrowse:DisableDetails()
_oBrowse:Activate()

RestArea(_aArea)

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

Local _aRotina 	:= {} 

ADD OPTION _aRotina TITLE "Pesquisar"	ACTION "PesqBrw"          	OPERATION 1 ACCESS 0
ADD OPTION _aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.CAMBC001"	OPERATION 2 ACCESS 0 
ADD OPTION _aRotina TITLE "Incluir"		ACTION "VIEWDEF.CAMBC001" 	OPERATION 3 ACCESS 0 
ADD OPTION _aRotina TITLE "Alterar"		ACTION "VIEWDEF.CAMBC001" 	OPERATION 4 ACCESS 0
ADD OPTION _aRotina TITLE "Excluir"		ACTION "VIEWDEF.CAMBC001" 	OPERATION 5 ACCESS 0
					
Return _aRotina     

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

Local _oStruct1
Local _oStruct2
Local _oModel

_oStruct1	:= FWFormStruct(1, "ZZF")
_oStruct2	:= FWFormStruct(1, "ZZG")

_oModel		:= MPFormModel():New("CAMBC01MOD", , {|_oModel| CAMBC001TOK(_oModel)})

//Estrutura Model
_oModel:AddFields("ZZF_GRUPO"	,				, _oStruct1)
_oModel:AddGrid("ZZG_CONDPAG"	, "ZZF_GRUPO"	, _oStruct2)

_oModel:SetRelation('ZZG_CONDPAG', {{'ZZG_FILIAL', 'xFilial("ZZG")'}, {'ZZG_CODGRP', 'ZZF_CODIGO'}}, ZZG->(IndexKey(1)))

_oModel:GetModel("ZZG_CONDPAG"):SetUniqueLine({"ZZG_FILIAL", "ZZG_CODGRP", "ZZG_CODPAG"})
_oModel:GetModel("ZZG_CONDPAG"):SetOptional(.T.)

_oModel:SetPrimaryKey({})

Return _oModel

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

Local _oStruct1
Local _oStruct2
Local _oModel
Local _oView
Local _aCpoZZG := {"ZZG_CODPAG", "ZZG_DESPAG", "ZZG_TIPCON", "ZZG_CONDIC", "ZZG_LIMINF", "ZZG_LIMSUP"}

_oModel    := FWLoadModel("CAMBC001") //Chamada do model utilizando o nome do fonte (PRW)

_oStruct1	:= FWFormStruct(2, "ZZF")
_oStruct2	:= FWFormStruct(2, "ZZG", {|_cCampo| CAMBC01CPO(_cCampo, _aCpoZZG)})

_oView     := FWFormView():New() //View da MVC

_oView:SetModel(_oModel)

//Estrutura View
_oView:AddField("VIEW_ZZFGRUPO"	, _oStruct1, "ZZF_GRUPO")
_oView:AddGrid("VIEW_ZZGCONDPAG", _oStruct2, "ZZG_CONDPAG")

//Formatação da Tela
_oView:CreateHorizontalBox("BOXZZF"	,30) //Uma barra horizontal com proporção de 35% da tela.
_oView:CreateHorizontalBox("BOXZZG"	,70) //Uma barra horizontal com proporção de 35% da tela.

_oView:SetOwnerView("VIEW_ZZFGRUPO"	, "BOXZZF")
_oView:SetOwnerView("VIEW_ZZGCONDPAG", "BOXZZG")

_oView:SetCloseOnOk({|| .T.})

Return _oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBC001TOK

Validação final da rotina (Tudo Ok)

@author  Allan Bonfim

@since   24/10/2014

@version P11 

@param	[oModelCab], objeto, Objeto do Model
		
@return

/*/
//------------------------------------------------------------------- 

STATIC FUNCTION CAMBC001TOK(_oModelCab)

Local _aArea	:= GetArea()
Local _lRet	 	:= .T.
Local _nOper	:= _oModelCab:GetOperation() 
Local _cQuery	:= ""  
Local _cTmpDoc	:= GetNextAlias()

If _nOper == 5

	_cQuery 	:= "SELECT A1_COD, A1_LOJA, A1_NOME FROM "+RETSQLNAME("SA1")+" SA1 "+CHR(13)+CHR(10)	
	_cQuery 	+= "WHERE SA1.D_E_L_E_T_ = '' "+CHR(13)+CHR(10)
	_cQuery 	+= "AND A1_XGRPCON = '"+_oModelCab:GetValue('ZZF_GRUPO', 'ZZF_CODIGO')+"' "+CHR(13)+CHR(10)
    
	If Select(_cTmpDoc) > 0
		(_cTmpDoc)->(DbCloseArea())
	EndIf
	
	DbUseArea(.T., "TOPCONN", TcGenQry(,,_cQuery), _cTmpDoc, .T., .T.)
	      
	If !(_cTmpDoc)->(EOF())
		HELP(,, 'HELP',, "O Grupo de Condição de Pagamento não poderá ser excluído pois está vinculado ao Cliente "+ALLTRIM((_cTmpDoc)->A1_COD)+"/"+ALLTRIM((_cTmpDoc)->A1_LOJA)+" - "+ALLTRIM(CAPITAL((_cTmpDoc)->A1_NOME))+"." , 1, 0)
		_lRet := .F.	
	EndIf
	
Else

	_cQuery 	:= "SELECT ZZF_CODIGO FROM "+RETSQLNAME("ZZF")+" ZZF "+CHR(13)+CHR(10)	
	_cQuery 	+= "WHERE ZZF.D_E_L_E_T_ = '' "+CHR(13)+CHR(10)
	_cQuery 	+= "AND ZZF_DESCRI = '"+_oModelCab:GetValue('ZZF_GRUPO', 'ZZF_DESCRI')+"' "+CHR(13)+CHR(10)
	_cQuery		+= "AND ZZF_CODIGO <> '"+_oModelCab:GetValue('ZZF_GRUPO', 'ZZF_CODIGO')+"' "+CHR(13)+CHR(10)

	If Select(_cTmpDoc) > 0
		(_cTmpDoc)->(DbCloseArea())
	EndIf

	DbUseArea(.T., "TOPCONN", TcGenQry(,,_cQuery), _cTmpDoc, .T., .T.)
      
	If !(_cTmpDoc)->(EOF())
	
		_lRet := .F.

	    If _nOper == 3
	   		HELP(,, 'HELP',, "O Grupo de Condição de Pagamento não será incluído pois já está cadastrado com o código Nº "+(_cTmpDoc)->ZZF_CODIGO+".", 1, 0)
	    ElseIf _nOper == 4
	   		HELP(,, 'HELP',, "O Grupo de Condição de Pagamento não será alterado pois já está cadastrado com o código Nº "+(_cTmpDoc)->ZZF_CODIGO+".", 1, 0)
    	EndIf
    
	EndIf
	
EndIf

If Select(_cTmpDoc) > 0
	(_cTmpDoc)->(DbCloseArea())
EndIf
	
RestArea(_aArea)

Return _lRet  

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBC01CPO

Campos que serão listados na tela

@author  Allan Bonfim

@since   26/05/2014

@version P11 

@param [cCpo], caracter, Campo do objeto Model
@param [aCpo], array, Array com os campos que serão demonstrados na tela

@return lógico, Gravação dos dados
/*/
//------------------------------------------------------------------- 

STATIC FUNCTION CAMBC01CPO(_cCpo, _aCpo)

Return aScan(_aCpo, {|x| ALLTRIM(x) == ALLTRIM(_cCpo)}) > 0