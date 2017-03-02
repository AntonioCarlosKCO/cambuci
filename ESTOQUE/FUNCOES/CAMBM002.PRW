#Include "RWMAKE.CH"
#Include "TOTVS.CH"
#Include "PROTHEUS.CH"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM002

Endereçamento automático da Nota Fiscal de Entrada

@author  Allan Bonfim

@since   07/11/2014

@ Alterado por Josmar Castiglioni em 05/12/15

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------

User Function CAMBM002()

Local _aArea		:= Getarea()
Local _cLocPad		:= SUPERGETMV("ES_XLOCPAD",, "01")
Local _cSeekSDA
Local _aAreaSD1
Local _aAreaSD1A
Public _cNFiscal
Public _cSerie
Public _cForne
Public _cLoja

MODATUSX1()		// Faz a gravacao dos Perguntes

If !Pergunte("ENDENF",.T.)
	Return Nil
EndIf

_cNFiscal := MV_PAR01
_cSerie   := Upper(MV_PAR02)
_cForne   := MV_PAR03
_cLoja	  := MV_PAR04
_cSeekSDA := _cNFiscal+_cSerie+_cForne+_cLoja

_aAreaSD1 := SD1->(Getarea())
SD1->(DbSetOrder(1)) //D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM, R_E_C_N_O_, D_E_L_E_T_
If SD1->(DbSeek(xFilial("SD1")+_cSeekSDA))
	While !SD1->(EOF()) .AND. SD1->D1_FILIAL == xFilial("SD1") .AND. SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == _cSeekSDA
		If SD1->D1_LOCAL == _cLocPad .AND. GETADVFVAL("SBZ", "BZ_LOCALIZ", xFilial("SBZ")+SD1->D1_COD, 1) == "S" .AND. GETADVFVAL("SF4", "F4_ESTOQUE", xFilial("SF4")+SD1->D1_TES, 1) == "S"
			_aAreaSD1A := SD1->(Getarea())
			U_ENDENF()
			//Voltar Ordenação correta
			SD1->(DbSetOrder(1))
			RestArea(_aAreaSD1A)
		EndIf
		SD1->(DbSkip())
	EndDo
EndIf
RestArea(_aAreaSD1)

RestArea(_aArea)

Return

************************************************************

User Function ENDENF()

Local _aArea		:= Getarea()
Local _aCabSDA    	:= {}
Local _aTmpSDB      := {}
Local _aIteSDB 		:= {}
Local _aDadSBE 		:= {}
Local _aAreaSBE
Local _aAreaSBZ
Local _cEndPad		:= "" //SUPERGETMV("ES_XENDPAD",, "RUA 1")
Local _cLocPad		:= "" //SUPERGETMV("ES_XLOCPAD",, "01")
Local _lTransf		:= .T.
Local _aLog			:= {}
Local _nX			:= 0

Private lMsErroAuto	:= .F.
Private _cFileLog	:= ""
Private _cPath		:= ""

_aAreaSBZ := SBZ->(Getarea())

DbSelectArea("SBZ")
SBZ->(DbSetOrder(1)) //BZ_FILIAL, BZ_COD

If SBZ->(DbSeek(xFilial("SBZ")+SD1->D1_COD))
	_cLocPad	:= SBZ->BZ_LOCPAD
	_cEndPad	:= SBZ->BZ_X_ENDER
EndIf

RestArea(_aAreaSBZ)


If !EMPTY(_cEndPad) .AND. !EMPTY(_cLocPad)
	
	_aAreaSBE := SBE->(Getarea())
	DbSelectArea("SBE")
	SBE->(DbSetOrder(1)) //BE_FILIAL, BE_LOCAL, BE_LOCALIZ
	If SBE->(DbSeek(xFilial("SBE")+_cLocPad+_cEndPad))
		If SBE->BE_STATUS == '3'
			_lTransf := .F.
			HELP("ERRO",,"ERRO",,"O status do endereço "+_cEndPad+" não possibilita o endereçamento automático. Favor verificar a cofiguração do endereço e fazer o endereçamento dos itens da nota manualmente.", 1, 0)
		EndIf
	Else
		lMsErroAuto	:= .F.
		_aDadSBE := {{"BE_LOCAL", _cLocPad, Nil}, {"BE_LOCALIZ", _cEndPad, NIL}, {"BE_DESCRIC", "AUTOMATICO NFE", NIL}, {"BE_STATUS", "1", NIL}}
		MSExecAuto({|x,y| MATA015(x,y)}, _aDadSBE, 3)
		
		If lMsErroAuto
			_cFileLog 	:= ""
			_cPath 		:= ""
			
			AutoGrLog("INICIANDO O LOG")
			AutoGrLog("---------------")
			AutoGrLog("DATABASE...........: "+Dtoc(dDataBase))
			AutoGrLog("DATA...............: "+Dtoc(MsDate()))
			AutoGrLog("HORA...............: "+Time())
			AutoGrLog("ENVIRONMENT........: "+GetEnvServer())
			AutoGrLog("PATCH..............: "+GetSrvProfString("Startpath",""))
			AutoGrLog("ROOT...............: "+GetSrvProfString("SourcePath",""))
			AutoGrLog("VERSÃO.............: "+GetVersao())
			AutoGrLog("EMPRESA / FILIAL...: "+SM0->M0_CODIGO+"/"+SM0->M0_CODFIL)
			AutoGrLog("NOME EMPRESA.......: "+Capital(Trim(SM0->M0_NOME)))
			AutoGrLog("NOME FILIAL........: "+Capital(Trim(SM0->M0_FILIAL)))
			AutoGrLog("USUÁRIO............: "+SubStr(cUsuario,7,15))
			
			_aLog := GetAutoGRLog()
			
			For _nX:=1 to Len (_aLog)
				If _nX == 1
					AutoGrLog("ERRO")
					AutoGrLog("---------------")
				EndIf
				AutoGrLog(_aLog[_nX])
			Next _nX
			
			AutoGrLog("---------------")
			AutoGrLog("FIM LOG")
			
			_cFileLog := NomeAutoLog()
			
			_lTransf := .F.
			HELP("ERRO",,"ERRO",,"Erro na criação do endereço "+_cEndPad+". Será necessário realizar o endereçamento dos itens da nota manualmente. Maiores detalhes em"+_cFileLog+".", 1, 0)
			
		EndIf
		
	EndIf
	RestArea(_aAreaSBE)
	
Else
	
	_lTransf := .F.
	
EndIf

If _lTransf
	
	lMsErroAuto	:= .F.
	
	_aCabSDA := {	{"DA_PRODUTO" 	,SD1->D1_COD	,Nil},;
	{"DA_NUMSEQ"  	,SD1->D1_NUMSEQ	,Nil}}
	
	_aTmpSDB := {	{"DB_ITEM"  	,"0001"	   		,Nil},;
	{"DB_ESTORNO"  	," "	   		,Nil},;
	{"DB_LOCALIZ"  	,_cEndPad		,Nil},;
	{"DB_DATA"	  	,dDataBase		,Nil},;
	{"DB_QUANT"		,SD1->D1_QUANT	,Nil}}
	
	AADD(_aIteSDB, _aTmpSDB)
	
	MATA265(_aCabSDA, _aIteSDB, 3)
	
	If lMsErroAuto
		_cFileLog 	:= ""
		_cPath 		:= ""
		
		AutoGrLog("INICIANDO O LOG")
		AutoGrLog("---------------")
		AutoGrLog("DATABASE...........: "+Dtoc(dDataBase))
		AutoGrLog("DATA...............: "+Dtoc(MsDate()))
		AutoGrLog("HORA...............: "+Time())
		AutoGrLog("ENVIRONMENT........: "+GetEnvServer())
		AutoGrLog("PATCH..............: "+GetSrvProfString("Startpath",""))
		AutoGrLog("ROOT...............: "+GetSrvProfString("SourcePath",""))
		AutoGrLog("VERSÃO.............: "+GetVersao())
		AutoGrLog("EMPRESA / FILIAL...: "+SM0->M0_CODIGO+"/"+SM0->M0_CODFIL)
		AutoGrLog("NOME EMPRESA.......: "+Capital(Trim(SM0->M0_NOME)))
		AutoGrLog("NOME FILIAL........: "+Capital(Trim(SM0->M0_FILIAL)))
		AutoGrLog("USUÁRIO............: "+SubStr(cUsuario,7,15))
		
		_aLog := GetAutoGRLog()
		
		For _nX:=1 to Len (_aLog)
			If _nX == 1
				AutoGrLog("ERRO")
				AutoGrLog("---------------")
			EndIf
			AutoGrLog(_aLog[_nX])
		Next _nX
		
		AutoGrLog("---------------")
		AutoGrLog("FIM LOG")
		
		_cFileLog := NomeAutoLog()
		
		_lTransf := .F.
		HELP("ERRO",,"ERRO",,"Erro no endereçamento do item "+SD1->D1_ITEM+" da NF "+SD1->D1_DOC+"/"+SD1->D1_SERIE+". Será necessário realizar o endereçamento manualmente. Maiores detalhes em"+_cFileLog+".", 1, 0)
		
	EndIf
	
EndIf

RestArea(_aArea)

Return

************************************************************

Static Function MODATUSX1()

Local aHelpPor 	:= {}					//Array com o Help do PutSx1
Local aHelpEsp 	:= {}					//Array com o Help do PutSx1
Local aHelpIng 	:= {}					//Array com o Help do PutSx1
Local cPerg		:= "ENDENF"

DBSelectArea("SX1")
DBSetOrder(1)

If DBSeek(cPerg)
	Return Nil
EndIf

Aadd(aHelpPor,"Número da Nota Fiscal de Entrada")
Aadd(aHelpEsp,"Número da Nota Fiscal de Entrada")
Aadd(aHelpIng,"Número da Nota Fiscal de Entrada")

PutSx1(cPerg,"01","N.Fiscal No.","","","mv_par01","C",9,0,0,"G","","","","","mv_ch1","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp,"")

AHelpPor := {}
AHelpEsp := {}
AHelpIng := {}

Aadd(aHelpPor,"Serie da Nota Fiscal de Entrada")
Aadd(aHelpEsp,"Serie da Nota Fiscal de Entrada")
Aadd(aHelpIng,"Serie da Nota Fiscal de Entrada")

PutSx1(cPerg,"02","Serie","","","mv_par02","C",3,0,0,"G","","","","","mv_ch2","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp,"")

AHelpPor := {}
AHelpEsp := {}
AHelpIng := {}

Aadd(aHelpPor,"Codigo do Fornecedor")
Aadd(aHelpEsp,"Codigo do Fornecedor")
Aadd(aHelpIng,"Codigo do Fornecedor")

PutSx1(cPerg,"03","Fornecedor","","","mv_par03","C",6,0,0,"G","","FOR","","","mv_ch3","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp,"")

AHelpPor := {}
AHelpEsp := {}
AHelpIng := {}

Aadd(aHelpPor,"Loja do Fornecedor")
Aadd(aHelpEsp,"Loja do Fornecedor")
Aadd(aHelpIng,"Loja do Fornecedor")

PutSx1(cPerg,"04","Loja","","","mv_par04","C",2,0,0,"G","","","","","mv_ch4","","","","","","","","","","","","","","","","",aHelpPor,aHelpIng,aHelpEsp,"")

Return Nil
