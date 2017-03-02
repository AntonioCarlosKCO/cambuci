#INCLUDE 'RWMAKE.CH'   
#include "Protheus.ch"   
#include "Topconn.ch"  
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

/*
---------------------------------------------------------------------------------------
Autor: Luis Henrique de Oliveira (GLOBAL)  - Data 28/03/16
---------------------------------------------------------------------------------------
Programa: CAMREL03  - Descrição: RELATORIO DE COMISSOES									  
--------------------------------------------------------------------------------------- 
*/

USER FUNCTION CAMREL03()
	Local oReport 
	Local _lRet  := .F.			// Variavel para controlar se a query veio vazia ou nao...
	Local _cPerg := 'CAMREL03'	// Variavel para manter o laco do pergunte...

	CriaSx1(_cPerg)	
	Pergunte(_cPerg,.f.)   

	Private cGCliAte   := MV_PAR01
	Private cGCliDe    := MV_PAR02
	Private cGEmiAte   := MV_PAR03
	Private cGEmiDe    := MV_PAR04
	Private cGRepAte   := MV_PAR04
	Private cGRepDe    := MV_PAR05
	Private cGTaxAte   := MV_PAR06
	Private cGTaxDe    := MV_PAR06

	//--------------------------------------------------------------------------
	// Declaração de Variaveis Private dos Objetos                             
	//--------------------------------------------------------------------------
	SetPrvt("oDlg1","oSBtn1","oSBtn2","oSBtn3","oRMenu1","oRMenu2","oPanel1","oSay1","oSay2","oSay3","oSay4")
	SetPrvt("oSay6","oSay7","oSay8","oGCliDe","oGCliAte","oGRepDe","oGRepAte","oGEmiDe","oGEmiAte","oGTaxDe")
	
	//--------------------------------------------------------------------------
	// Definicao do Dialog e todos os seus componentes.                        
	//--------------------------------------------------------------------------

	oDlg1      := MSDialog():New( 092,232,592,1246,"Relatório de Comissões",,,.F.,,,,,,.T.,,,.T. )
	oSBtn1     := SButton():New( 220,428,1,,oDlg1,,"", )
	oSBtn2     := SButton():New( 16322,380,1,,oDlg1,,"", )
	oSBtn3     := SButton():New( 220,464,2,,oDlg1,,"", )
	
	GoRMenu1   := TGroup():New( 012,116,188,296,"LayOut",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oRMenu1    := TRadMenu():New( 016,122,{"Detalhado - por Notas sem Valor Base ( Salta Pagina )","Detalhado - por Notas sem Valor Base ( Salta Pagina )","Detalhado - com Itens","----------------------------------------------------------","Resumo - Sintetizado com Valor Base","Resumo - Sintetizado sem Valor Base","----------------------------------------------------------","Comissao Corrigida - Detalhado - por Nota (Salta Pagina)","Comissao Corrigida - Detalhado - por Nota com IR (Salta Pagina)","Comissao Corrigida - Detalhado - com Itens","--------------------------------------------------------","Comissao Corrigida - Resumo - por Data","Comissao Corrigida - Resumo - por Operacao","Comissao Corrigida - Resumo - por Representante (Salta Pagina)","Comissao Corrigida - Resumo - por Repres. com IR (Salta Pagina)","Comissao Corrigida - Resumo - por Sintetizado"},,oDlg1,,,CLR_BLACK,CLR_WHITE,"",,,160,11,,.F.,.F.,.T. )
	
	GoRMenu2   := TGroup():New( 012,012,188,104,"Quebra",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oRMenu2    := TRadMenu():New( 016,018,{"Representante","Taxa de Comissao","Local","Tipo de Pedido","Regiao de Venda","Classe da Pessoa","Grupo da Pessoa","Status da Pessoa","Pessoa","Grupo","Marca ","Tipo","Linha","Lista de Preco","Ano / Mes","Data","UF"},,oDlg1,,,CLR_BLACK,CLR_WHITE,"",,,072,10,,.F.,.F.,.T. )
	
	oPanel1    := TPanel():New( 012,304,"Filtro",oDlg1,,.F.,.F.,,,188,176,.T.,.F. )
	
	oSay1      := TSay():New( 008,012,{||"Cliente de"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay2      := TSay():New( 020,012,{||"Cliente ate"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay3      := TSay():New( 032,012,{||"Representante de"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oSay4      := TSay():New( 044,012,{||"Representante ate"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008)
	oSay5      := TSay():New( 056,012,{||"Emissao de"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay6      := TSay():New( 068,012,{||"Emissao ate"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay7      := TSay():New( 080,012,{||"Taxa de"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay8      := TSay():New( 092,012,{||"Taxa ate"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	
	oGCliDe    := TGet():New( 005,084,{|u| If(PCount()>0,cGCliDe:=u,cGCliDe)},oPanel1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGCliDe",,)
	oGCliAte   := TGet():New( 017,084,{|u| If(PCount()>0,cGCliAte:=u,cGCliAte)},oPanel1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGCliAte",,)
	oGRepDe    := TGet():New( 030,084,{|u| If(PCount()>0,cGRepDe:=u,cGRepDe)},oPanel1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGRepDe",,)
	oGRepAte   := TGet():New( 042,084,{|u| If(PCount()>0,cGRepAte:=u,cGRepAte)},oPanel1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGRepAte",,)
	oGEmiDe    := TGet():New( 055,084,{|u| If(PCount()>0,cGEmiDe:=u,cGEmiDe)},oPanel1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGEmiDe",,)
	oGEmiAte   := TGet():New( 067,084,{|u| If(PCount()>0,cGEmiAte:=u,cGEmiAte)},oPanel1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGEmiAte",,)
	oGTaxDe    := TGet():New( 080,084,{|u| If(PCount()>0,cGTaxDe:=u,cGTaxDe)},oPanel1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGTaxDe",,)
	oGTaxAte   := TGet():New( 092,084,{|u| If(PCount()>0,cGTaxAte:=u,cGTaxAte)},oPanel1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGTaxAte",,)

	oDlg1:Activate(,,,.T.)

	oReport := REPORTDEF() 	  // 
	oReport:PRINTDIALOG()     // 

RETURN

Static Function RELINTa(_cPerg)
	Local _cAlias := GetNextAlias()

	ExecQry(_cAlias)
	RELINTb(_cAlias)  
	REPORTDEF(_cAlias)
	(_cAlias)->(dbcloseArea())

Return  

STATIC FUNCTION ExecQry(_cAlias)
	//Local oSEC := oReport:SECTION('RELINTERF')     
	Local _cStatus  := ''   

	//TRATA SELEÇÃO DE CATEGORIAS
	if ckAgend    
		if ! empty(_cStatus)
			_cStatus += "','"
		Endif
		_cStatus += "AG"
	Endif

	if ckSepara
		if ! empty(_cStatus)
			_cStatus += "','"
		Endif
		_cStatus += "ES"
	Endif 

	if  ckValeEm 
		if ! empty(_cStatus)
			_cStatus += "','"
		Endif
		_cStatus += "VE"
	Endif	

	if ckRetira 
		if ! empty(_cStatus)
			_cStatus += "','"
		Endif
		_cStatus += "RH"	
	Endif

	if ckEntreg
		if ! empty(_cStatus)
			_cStatus += "','"
		Endif
		_cStatus += "EE"
	Endif   

	if ckRetorn
		if ! empty(_cStatus)
			_cStatus += "','"
		Endif
		_cStatus += "PC"
	Endif   

	//MONTAGEM DA QUERY
	oSEC:BEGINQUERY() 

	BeginSql Alias _cAlias

	Column Z14_DATA   AS DATE
	Column Z15_DATCIR AS DATE
	Column Z15_DATENT AS DATE
	Column Z15_DATRET AS DATE
	%noparser%	  	

	SELECT 
	Z15.Z15_NUMORC
	,HOS.A1_NREDUZ 	NM_HOSPIT
	,MED.A1_NOME	NM_MEDICO
	,CIR.B1_DESC 	DESC_CIR					
	,AGE.Z14_USER 	USU_AGENDA
	,AGE.Z14_DATA 	DAT_AGENDA
	,AGE.Z14_HORA 	HOR_AGENDA				
	,SEP.Z14_USER	USU_SEPARA
	,SEP.Z14_DATA	DAT_SEPARA
	,SEP.Z14_HORA	HOR_SEPARA					
	,VLE.Z14_USER	USU_VALE
	,VLE.Z14_DATA	DAT_VALE
	,VLE.Z14_HORA	HOR_VALE					
	,MOE.DA4_NOME 	MOTO_ENTRE	
	,Z15.Z15_DATENT
	,Z15.Z15_HORENT
	,Z15.Z15_DATCIR
	,Z15.Z15_HORCIR		
	,MOR.DA4_NOME 	MOTO_RETIR
	,Z15.Z15_DATRET
	,Z15.Z15_HORRET				
	,RET.Z14_USER	USU_RETOR
	,RET.Z14_DATA	DAT_RETOR
	,RET.Z14_HORA	HOR_RETOR	

	FROM %Table:Z15% Z15

	LEFT JOIN %Table:SA1% HOS 
	ON 	HOS.%NotDel%
	AND HOS.A1_COD = Z15.Z15_CODHOS    

	LEFT JOIN %Table:SA1% MED
	ON 	MED.%NotDel%
	AND MED.A1_COD = Z15.Z15_CODMED

	LEFT JOIN %Table:Z16% Z16
	ON 	Z16.%NotDel%
	AND Z16.Z16_NUMORC = Z15.Z15_NUMORC  

	LEFT JOIN %Table:SB1% CIR
	ON 	CIR.%NotDel%
	AND CIR.B1_COD = Z16.Z16_CODCIR 	

	LEFT JOIN %Table:Z14% AGE
	ON 	AGE.%NotDel%
	AND AGE.Z14_CODIGO = Z15.Z15_NUMORC

	LEFT JOIN %Table:Z14% SEP 
	ON 	SEP.%NotDel%
	AND SEP.Z14_CODIGO = Z15.Z15_NUMORC

	LEFT JOIN %Table:Z14% VLE
	ON 	VLE.%NotDel%
	AND VLE.Z14_CODIGO = Z15.Z15_NUMORC

	LEFT JOIN %Table:Z14% RET
	ON 	RET.%NotDel%
	AND RET.Z14_CODIGO = Z15.Z15_NUMORC

	LEFT JOIN %Table:DA4% MOE
	ON 	MOE.%NotDel%
	AND MOE.DA4_COD = Z15.Z15_CODENT    

	LEFT JOIN %Table:DA4% MOR
	ON 	MOR.%NotDel%
	AND MOR.DA4_COD = Z15.Z15_CODRET

	WHERE 
	Z15.%NotDel%	
	AND Z15.Z15_STATUS <> 'CA'
	AND Z15.Z15_FILIAL 	= %xFilial:Z15% 
	AND Z15.Z15_STATUS IN (%Exp:_cStatus%)
	AND Z15.Z15_DATCIR 	BETWEEN %EXP:DTOS(MV_PAR01)% AND %EXP:DTOS(MV_PAR02)%
	AND Z15.Z15_NUMORC 	BETWEEN %EXP:MV_PAR03% AND %EXP:MV_PAR04%
	AND MED.A1_COD	 	BETWEEN %EXP:MV_PAR05% AND %EXP:MV_PAR06% 
	AND HOS.A1_COD		BETWEEN %EXP:MV_PAR07% AND %EXP:MV_PAR08%
	AND Z14.Z14_USER	BETWEEN %EXP:MV_PAR09% AND %EXP:MV_PAR10%

	ORDER BY Z15_NUMORC, NM_HOSPIT

	ENDSQL	

	//oSEC:ENDQUERY()
	//oSEC:RELINTb()

Return    

Static Function RELINTb(_cAlias)
	Private oPrinter  	:=	TmsPrinter():New("RELINTERF")

	oPrinter:Setup()
	oPrinter:StartPage()
	REPORTDEF(_cAlias)
	oPrinter:Preview()
	oPrinter:print()

Return			

STATIC FUNCTION REPORTDEF(_cAlias)
	Local oReport    			  
	Local oSEC  
	Local _cPerg := "RELINTERF"

	oReport:= TReport():New("RELINTERF", "RELATÓRIO INTERFACE", _cPerg, {|oReport| ExecQry(oReport)}, "Emissão Relatório de Interface (Rastreio de Agendamento)") 	
	oSEC := TRSection():New(oReport,"RELINTERF",{"Z15","SA1","Z14"})  

	TRCELL():NEW(oSEC,"Z15_NUMORC"	,"Z15"	,"Nro.Vale"	 		, PesqPict("Z15","Z15_NUMORC")	,TamSX3("Z15_NUMORC")[1])
	TRCELL():NEW(oSEC,"NM_HOSPIT"	,""		,"Hospital"	 		, 								,TamSX3("A1_NREDUZ")[1])
	TRCELL():NEW(oSEC,"NM_MEDICO"	,""		,"Médico" 			, 								,TamSX3("A1_NREDUZ")[1])
	TRCELL():NEW(oSEC,"DESC_CIR"	,""		,"Cirurgia"			, 								,TamSX3("B1_DESC")[1])
	TRCELL():NEW(oSEC,"USU_AGENDA"	,""		,"Usu.Agenda." 		, 								,TamSX3("Z14_USER")[1])
	TRCELL():NEW(oSEC,"DAT_AGENDA"	,""		,"Dt.Agend"	 		, PesqPict("Z14","Z14_DATA")	,TamSX3("Z14_DATA")[1])
	TRCELL():NEW(oSEC,"HOR_AGENDA"	,""		,"Hr.Ag"	 		, PesqPict("Z14","Z14_HORA")	,TamSX3("Z14_HORA")[1])
	TRCELL():NEW(oSEC,"USU_SEPARA"	,""		,"Usu.Separa." 		, 								,TamSX3("Z14_USER")[1])
	TRCELL():NEW(oSEC,"DAT_SEPARA"	,""		,"Dt.Separ"	 		, PesqPict("Z14","Z14_DATA")	,TamSX3("Z14_DATA")[1])
	TRCELL():NEW(oSEC,"HOR_SEPARA"	,""		,"Hr.Sep"	 		, PesqPict("Z14","Z14_HORA")	,TamSX3("Z14_HORA")[1])
	TRCELL():NEW(oSEC,"USU_VALE"	,""		,"Usu.Emis.Vale"	, 								,TamSX3("Z14_USER")[1])
	TRCELL():NEW(oSEC,"DAT_VALE"	,""		,"Dt.Vale"	 		, PesqPict("Z14","Z14_DATA")	,TamSX3("Z14_DATA")[1])
	TRCELL():NEW(oSEC,"HOR_VALE"	,""		,"Hr.Vale"	 		, PesqPict("Z14","Z14_HORA")	,TamSX3("Z14_HORA")[1])
	TRCELL():NEW(oSEC,"MOTO_ENTRE"	,""		,"Moto.Entre."		, 								,10)
	TRCELL():NEW(oSEC,"Z15_DATENT"	,"Z15"	,"Dt.Entreg"		, PesqPict("Z15","Z15_DATENT")	,TamSX3("Z15_DATENT")[1])
	TRCELL():NEW(oSEC,"Z15_HORENT"	,"Z15"	,"Hr.Ent"	 		, PesqPict("Z15","Z15_HORENT")	,TamSX3("Z15_HORENT")[1])
	TRCELL():NEW(oSEC,"Z15_DATCIR"	,"Z15"	,"Dt.Cirurgia"		, PesqPict("Z15","Z15_DATCIR") 	,08)
	TRCELL():NEW(oSEC,"Z15_HORCIR"	,"Z15"	,"Hr.Cirurgia"		, PesqPict("Z15","Z15_HORCIR") 	,05)
	TRCELL():NEW(oSEC,"MOTO_RETIR"	,""		,"Moto.Retira."		, 								,10)
	TRCELL():NEW(oSEC,"Z15_DATRET"	,"Z15"	,"Dt.Retira"	 	, PesqPict("Z15","Z15_DATRET")	,TamSX3("Z15_DATRET")[1])
	TRCELL():NEW(oSEC,"Z15_HORRET"	,"Z15"	,"Hr.Retira"	 	, PesqPict("Z15","Z15_HORRET")	,TamSX3("Z15_HORRET")[1])
	TRCELL():NEW(oSEC,"USU_RETOR"	,""		,"Usu.Retorno"		, 								,TamSX3("Z14_USER")[1])
	TRCELL():NEW(oSEC,"DAT_RETOR"	,""		,"Dt.Retorno"	 	, PesqPict("Z14","Z14_DATA")	,TamSX3("Z14_DATA")[1])
	TRCELL():NEW(oSEC,"HOR_RETOR"	,""		,"Hr.Retorno"	 	, PesqPict("Z14","Z14_HORA")	,TamSX3("Z14_HORA")[1])
	TRCELL():NEW(oSEC,"C5_EMISSAO"	,"SC5"	,"Dt.Fatura"	 	, PesqPict("SC5","C5_EMISSAO")	,TamSX3("C5_EMISSAO")[1]) // CONFIRMAR
	//TRCELL():NEW(oSEC,"Z00_NOME"	,"Z00"	,"Paciente" 		, ,TamSX3("A1_NREDUZ")[1])                                                

RETURN _cAlias
