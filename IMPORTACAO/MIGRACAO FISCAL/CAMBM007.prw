#include "TOTVS.CH"
#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM007

Rotina para importa��o de Movimentos Internos - SD3.

@author  Caio Garcia

@since   17/07/2015

@version P11
 
@param

@obs 	17/07/2015 - Caio Garcia - Desenvolvimento da rotina.
@obs 	05/09/2015 - Allan Bonfim - Inclus�o do Layout para importa��o.

@return

/*/
//-------------------------------------------------------------------
User Function CAMBM007()

Local aArea	   		:= GetArea()
Local aSays 		:= {}
Local aButtons		:= {}
Local nOpca			:= 0
Local cTmpPath		:= GetTempPath(.T.)
Local cNomeArq		:= "MOVIMENTACOES_INTERNAS.XLS"
Local cLayout		:= cTmpPath+cNomeArq

Private cCadastro	:= "Importa��o Movimenta��es Internas - Estoque (SD3)"
Private aCabec		:= {}
Private aLinhas		:= {}
Private cNomArq		:= ""
Private cPathArq 	:= ""
Private aTipoArq	:= {"TXT", "CSV"}
Private aLinLog		:= {}
Private aParam
Private aPergs

If File("\LAYOUT\"+cNomeArq)
	CPYS2T("\LAYOUT\"+cNomeArq, cTmpPath, .T.)
EndIf


AADD(aSays, OemToAnsi("Esta fun��o tem o objetivo de importar as Movimenta��es Internas informadas no arquivo para o sistema"))
AADD(aSays, OemToAnsi("Protheus - Tabela (SD3)"))
AADD(aSays, OemToAnsi("Os arquivos TXT e CSV dever�o ter a primeira linha com o cabe�alho contendo o nome"))
AADD(aSays, OemToAnsi("dos campos e as demais linhas com os valores, separados por ; ."))    
AADD(aSays, OemToAnsi(""))

If File(cLayout)
	AADD(aButtons, {14,.T.,{|| nOpca := 0, SHELLEXECUTE("Open", cLayout, " /k dir", "C:\", 1 ), FECHABATCH()}})
EndIf

AADD(aButtons, {1,.T.,{|| nOpca := IIf(CAMBM07P(@aParam, @aPergs), 1, 0), FECHABATCH()}})
AADD(aButtons, {2,.T.,{|| nOpca := 0, FECHABATCH()}})

FormBatch(cCadastro, aSays, aButtons)

If nOpca == 1
	If MSGYESNO("Confirma a importa��o dos arquivos do diret�rio selecionado ?", cCadastro)
		//FWMsgRun(, {|| CAMBM07I()}, "Importando os Arquivos... Aguarde...")
		oProcess := MsNewProcess():New({ |lFim| CAMBM07I(@lFim)}, "Importa��o das Movimenta��es Internas (Estoque)", "Processando...", .T. )
		oProcess:Activate()		
	EndIf
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM07I

Rotina para importa��o das Movimenta��es Internas.

@author  Allan Bonfim

@since   15/06/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM07I(lFim)

Local aArea	   		:= GetArea()
Local cPstSrv		:= ALLTRIM(SUPERGETMV("CB_XPSTSD3", ,"\IMPORTACAO\SD3\"))
Local cTmpPath		:= GetTempPath (.T.)
Local nX			:= 0
Local nY			:= 0
Local aArquivos		:= {} 
Local nTamReg		:= 0 
Local nSleep		:= 500 

//Begin Transaction
	For nX:=1 to Len(aTipoArq)
	
		aArquivos := Directory(ALLTRIM(aParam[2])+"*."+ALLTRIM(aTipoArq[nX]))

		nTamReg := Len(aArquivos)
		oProcess:SetRegua1(nTamReg)
				
		For nY:=1 to Len(aArquivos)

			If lFim
				Exit
			EndIf

			oProcess:IncRegua1("Gravando o Arquivo "+STRZERO(nY, 5)+" de "+STRZERO(nTamReg, 5))
			oProcess:Incregua2("Processando... Aguarde...")
			
			cPathArq	:= ALLTRIM(aParam[2])+ALLTRIM(aArquivos[nY][1])
			cNomArq		:= "IMPORT_"+__cUserID+"_"+DTOS(dDatabase)+"_"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(cPathArq, (LEN(cPathArq)-3), LEN(cPathArq))
	
			__CopyFile(cPathArq, cTmpPath+cNomArq)
	
			If EXISTDIR (cPstSrv) //Backup do arquivo de importa��o
				CPYT2S(cTmpPath+cNomArq, cPstSrv, .T.)
			Else	
				If MAKEDIR(cPstSrv) == 0
					CPYT2S(cTmpPath+cNomArq, cPstSrv, .T.)
				EndIf
			EndIf

			If FILE(cPstSrv+cNomArq) 
				If CAMBM07A(cPstSrv+cNomArq, cPathArq)
					Begin Transaction
						If !CAMBM07G(aCabec, aLinhas, cPathArq)
							FERASE(cPstSrv+cNomArq)
						EndIf
					End Transaction
				EndIf
	
				FERASE(cTmpPath+cNomArq)
			Else
				MSGSTOP ("Falha na cria��o do arquivo "+ALLTRIM(aArquivos[nY])+" na pasta "+cTmpPath+" do Servidor Protheus. Entre em contato com TI.", cCadastro)
			EndIf
			oProcess:Incregua2("Finalizando...")
			SLEEP(nSleep)				
		Next
	Next

//End Transaction
	
If aParam[1] == "1" //Gera Log
	FWMsgRun(, {|| CAMBM07R(aCabec, aLinLog)}, "Gerando o Log da Importa��o... Aguarde...") 
EndIf

MSGINFO ("A importa��o dos arquivos do diret�rio "+UPPER(ALLTRIM(aParam[2]))+" foi finalizada.", cCadastro)


RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM07A

Fun��o para abertura do arquivo.

@author  Allan Bonfim

@since   15/06/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static function CAMBM07A(cArqImp, cArqOri)

Local aArea		:= GetArea()
Local lRet 		:= .T.
Local aLinTmp	:= {}
Local cError   	:= ""
Local cWarning 	:= ""
Local aCposXML	:= {}
Local nPosExam	:= 0
Local nPosCpo	:= 0
Local aExames	:= {}
Local nX		:= 0
Local nY		:= 0
Local nZ		:= 0
Local cValInc	:= ""
Local xBuffer

Default cArqImp	:= ""
Default	cArqOri	:= ""

If !EMPTY(cArqImp)

	If UPPER(SUBSTR(cArqImp, (LEN(cArqImp)-2), LEN(cArqImp))) $ "TXT/CSV"
		aLinhas := {}
		aCabec	:= {}

		FT_FUSE(cArqImp) 
      
      	If File(cArqImp) 
 			While !FT_FEOF()
				xBuffer	:= UPPER(FT_FREADLN())
				If "D3_" $ xBuffer //Cabe�alho
             		aCabec	:= WFTokenChar(UPPER(xBuffer), ";")
             	Else
             		If !EMPTY(STRTRAN(xBuffer, ";", ""))
				    	aLinTmp := WFTokenChar(UPPER(xBuffer), ";")
					    AADD(aLinhas, aLinTmp)
					EndIf
				EndIf
						       
			    FT_FSKIP() //Pula para o pr�ximo registro				
			EndDo
			
			FT_FUSE()
		Else
			AADD(aLinLog, {cArqOri, "", 0, "6", ""}) //Erro na estrutura do arquivo.
			lRet := .F.
		EndIf
	EndIf
	
Else

	lRet := .F.
	
EndIf

If !(Len(aCabec) >= 0 .AND. Len(aLinhas) > 0)
	AADD(aLinLog, {cArqOri, "", 0, "2", cValInc}) //Erro na estrutura do arquivo.
	lRet := .F.
Else	        
	If ASCAN(aCabec, {|x| ALLTRIM(x) == "D3_TM"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "D3_COD"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "D3_UM"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "D3_LOCAL"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "D3_EMISSAO"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "D3_QUANT"}) == 0 .OR. LEN(aLinhas) == 0
		AADD(aLinLog, {cArqOri, "", 0, "6", cValInc}) //Erro na estrutura do arquivo.
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)
 
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM07G

Fun��o para grava��o dos dados do arquivo.

@author  Allan Bonfim

@since   29/05/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static function CAMBM07G(aCab, aItens, cArqOri)

Local aArea			:= GetArea()
Local nX			:= 0
Local nY			:= 0
Local nPosTM 		:= 0
Local nPosPrd		:= 0
Local nPosUni		:= 0
Local nPosArm 		:= 0
Local nPosQtd 		:= 0
Local nPosFil		:= 0
Local nPosDtE		:= 0
Local lRet			:= .F.
Local cLogTmp		:= ""
Local cValInc		:= ""    
Local cNomeArq		:= "LOG_"+ALLTRIM(STR(ALEATORIO(999999, VAL(SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)+SUBSTR(TIME(), 7, 2)))))+".log"
Local cBuffer		:= ""
Local nErrLin		:= 1 
Local nLinhas		:= 0
Local cErroTemp		:= ""
Local aDadosSD3		:= {}
Local nTamReg2		:= 0

Private lMsHelpAuto	:= .F.
Private lMsErroAuto := .F.
  	 					
Default aCab		:= {}
Default aItens		:= {}
Default cArqOri		:= ""

If Len(aCab) > 0 .AND. Len(aItens) > 0

	nPosTM 		:= ASCAN(aCab, {|x| ALLTRIM(x) == "D3_TM"})
	nPosPrd		:= ASCAN(aCab, {|x| ALLTRIM(x) == "D3_COD"})
	nPosUni		:= ASCAN(aCab, {|x| ALLTRIM(x) == "D3_UM"})
	nPosArm 	:= ASCAN(aCab, {|x| ALLTRIM(x) == "D3_LOCAL"})
	nPosQtd 	:= ASCAN(aCab, {|x| ALLTRIM(x) == "D3_QUANT"})
	nPosDtE 	:= ASCAN(aCab, {|x| ALLTRIM(x) == "D3_EMISSAO"})	
	nPosFil		:= ASCAN(aCab, {|x| ALLTRIM(x) == "D3_FILIAL"})
	
	DbSelectArea("SD3")
	SD3->(DbSetOrder(1)) //D3_FILIAL+D3_OP+D3_COD+D3_LOCAL
	
	nTamReg2 := Len(aItens)
	oProcess:SetRegua2(nTamReg2)
	
	For nX:=1 To Len(aItens)

		oProcess:Incregua2("Gravando o Item "+STRZERO(nX, 5)+" de "+STRZERO(Len(aItens), 5))
				                
		If EMPTY(aItens[nX][nPosTM]) .OR. EMPTY(aItens[nX][nPosPrd]) .OR. EMPTY(aItens[nX][nPosUni]) .OR. EMPTY(aItens[nX][nPosArm]) .OR. EMPTY(aItens[nX][nPosQtd]) .OR. EMPTY(aItens[nX][nPosDtE])
                  
			cValInc	:= ""
			cLogTmp	:= ""
			AEVAL(aItens[nX], {|X| cLogTmp += X+" "})

			If EMPTY(aItens[nX][nPosTM])
				If !EMPTY(cValInc)
					cValInc += ", "
				EndIf

				cValInc += aCab[nPosTM]
			EndIf
			
			If EMPTY(aItens[nX][nPosPrd])
				If !EMPTY(cValInc)
					cValInc += ", "
				EndIf
			
				cValInc += aCab[nPosPrd]
			EndIf

			If EMPTY(aItens[nX][nPosUni])
				If !EMPTY(cValInc)
					cValInc += ", "
				EndIf
			
				cValInc += aCab[nPosUni]
			EndIf

			If EMPTY(aItens[nX][nPosArm])
				If !EMPTY(cValInc)
					cValInc += ", "
				EndIf
			
				cValInc += aCab[nPosArm]
			EndIf

			If EMPTY(aItens[nX][nPosQtd])
				If !EMPTY(cValInc)
					cValInc += ", "
				EndIf
			
				cValInc += aCab[nPosQtd]
			EndIf

			If EMPTY(aItens[nX][nPosDtE])
				If !EMPTY(cValInc)
					cValInc += ", "
				EndIf
			
				cValInc += aCab[nPosDtE]
			EndIf

			If !EMPTY(cValInc)
				cValInc += " n�o preenchido ou conte�do inv�lido."
			EndIf
		
			AADD(aLinLog, {cArqOri, cLogTmp, nX, "3", cValInc})
	
		Else	  						

			aDadosSD3 	:= {}
			lMsErroAuto	:= .F.
			nErrLin		:= 0

			SX3->(DbSetOrder(2))
					
			For nY:=1 To Len(aCab)
				If SX3->(DbSeek(ALLTRIM(aCab[nY])))
					If "D3_" $ ALLTRIM(aCab[nY])
						If SX3->(GETADVFVAL("SX3", "X3_TIPO", ALLTRIM(aCab[nY]), 2, "C")) == "D"
							AADD(aDadosSD3,	{ALLTRIM(aCab[nY]), CTOD(aItens[nX][nY]), NIL})
						ElseIf SX3->(GETADVFVAL("SX3", "X3_TIPO", ALLTRIM(aCab[nY]), 2, "C")) == "N"
							AADD(aDadosSD3,	{ALLTRIM(aCab[nY]), VAL(STRTRAN(aItens[nX][nY], ",", ".")), NIL})
						Else
							AADD(aDadosSD3,	{ALLTRIM(aCab[nY]), AVKEY(FwNoAccent(aItens[nX][nY]), ALLTRIM(aCab[nY])), NIL})
						EndIf
					EndIf
				EndIf
			Next
			
			If nPosFil == 0
				AADD(aDadosSD3, {"D3_FILIAL"	, xFilial("SD3"), Nil})
			EndIf
			
			AADD(aDadosSD3, {"D3_XIMPORT", "S", Nil})

			MSExecAuto({|x,y| MATA240(x,y)}, aDadosSD3, 3)

			If lMsErroAuto
				cErroTemp 	:= MOSTRAERRO(GetSrvProfString("Startpath",""), cNomeArq)
				nLinhas 	:= MLCOUNT(cErroTemp)
				cBuffer 	:= RTRIM(MEMOLINE(cErroTemp,, nErrLin))
							
				While (nErrLin <= nLinhas)
					nErrLin++
			    	cBuffer := ALLTRIM(MEMOLINE(cErroTemp,, nErrLin))
			     	If (UPPER(SUBSTR(cBuffer, LEN(cBuffer)-7, LEN(cBuffer))) == "INVALIDO") 
						cValInc := "ERRO GRAVA��O SD3 = "+ALLTRIM(cBuffer)
						Exit									
			    	EndIf 
				EndDo
			  
				If EMPTY(cValInc)
					nErrLin := 0
					While (nErrLin <= 5)
						nErrLin++
				    	cBuffer := ALLTRIM(MEMOLINE(cErroTemp,, nErrLin))
						cValInc += ALLTRIM(cBuffer)+" "
					EndDo
				EndIf
									
				If File(GetSrvProfString("Startpath","")+cNomeArq)
					FERASE(GetSrvProfString("Startpath","")+cNomeArq)
				EndIf

				cLogTmp	:= ""
				AEVAL(aItens[nX], {|X| cLogTmp += X+" "})
				AADD(aLinLog, {cArqOri, cLogTmp, nX, "5", cValInc})
			Else
				lRet := .T.			
//				cLogTmp	:= ""
//				AEVAL(aItens[nX], {|X| cLogTmp += X+" "})
//				AADD(aLinLog, {cArqOri, cLogTmp, nX, "1", ""}) //Gravado com Sucesso
			EndIf
		EndIf
	Next

Else

	aLogTmp := ARRAY(3)
	cLogTmp	:= ""
	AADD(aLinLog, {cArqOri, cLogTmp, nX, "2", ""}) 

EndIf

//If ASCAN(aLinLog, {|x| x[LEN(aLinLog[1])] == "1", ""}) > 0 //Gravado com sucesso
//	lRet := .T.
//EndIf

RestArea(aArea)
 
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM07P

Par�metros da Rotina.

@author  Allan Bonfim

@since   29/05/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM07P(aParam, aPergs)

Local aArea		:= GetArea()
Local lRet   	:= .F.
Local lValid 	:= .F.
Local cTmpPath	:= GetTempPath (.T.)

Default aParam	:= {}
Default aPergs	:= {}

AADD(aPergs, {2, "Gera Log"	   				, "1", {"1=Sim", "2=N�o"}, 80, , .T.})
AADD(aPergs, {6, "Selecione o Diret�rio"	, cPathArq, "", "", "", 80, .T., "", cTmpPath, GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY})

Do While !lValid
	If ParamBox(aPergs, "Parametros ", @aParam)		
		lValid	:= CAMBM07V(aParam, aPergs)
		lRet	:= .T.
	Else
		lValid	:= .T.
		lRet	:= .F.
	EndIf
Enddo

RestArea(aArea)

Return lRet                 

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM07V

Valida��o dos Par�metros.

@author  Allan Bonfim

@since   29/05/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM07V(aPar, aPrgs)

Local lRet 		:= .F.
Local nX		:= 0
Local cTipoArq	:= ""

For nX:= 1 to Len (aTipoArq)

	If !EMPTY(cTipoArq)
		cTipoArq +=	", "
	EndIf
	
	cTipoArq += aTipoArq[nX]

	If !lRet .AND. FILE(ALLTRIM(aPar[2])+"*."+aTipoArq[nX])
		lRet := .T.	
	EndIf
Next

If !lRet
	MsgStop("N�o existem arquivos v�lidos ("+cTipoArq+") para importa��o no diret�rio selecionado ("+UPPER(ALLTRIM(aPar[2]))+"). Selecione um diret�rio v�lido.", cCadastro)
EndIf
	
Return lRet                    

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM07R

Relat�rio com o resultado da importa��o.

@author  Allan Bonfim

@since   11/03/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM07R(aCabec, aDadosLog)

Local aArea 	:= GetArea()
Local oReport

oReport := ReportDef(aCabec, aDadosLog)
oReport:PrintDialog()

Return        

//-------------------------------------------------------------------
/*/{Protheus.doc} REPORTDEF

Relat�rio com o resultado da importa��o.

@author  Allan Bonfim

@since   11/03/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function REPORTDEF(aCabec, aDadosLog)

Local oReport

oReport  := TReport():New("CAMBM007", "LOG DA IMPORTA��O - MOVIMENTA��O INTERNA - ESTOQUE", "", {|oReport| PrintReport(oReport, aDadosLog)}, "Log da Importa��o do arquivo para a tabela SD3 (Movimentos Internos)")

oReport:nFontBody   := 8
oReport:nLineHeight := 50
oReport:cFontBody   := "Arial"
oReport:cDir		:= GetTempPath (.T.)
oReport:nDevice		:= 1 //1-Arquivo,2-Impressora,3-email,4-Planilha, 5-Html, 6=PDF, 7=ODF
oReport:nEnvironment:= 2 //1-Server e 2-Cliente.

oReport:NoUserFilter()
oReport:SetLandscape() //Escolher o padr�o de Impressao como Paisagem  		

oSection1 := TRSection():New(oReport, "LOG DA IMPORTACAO", ,{"LOG"})//"Lista"
oSection1:SetHeaderBreak(.T.)
oSection1:SetPageBreak(.T.) 
oSection1:NCLRBACK 	:= 13092807
oSection1:SetAutoSize(.T.)

TRCell():New(oSection1, "ARQUIVO"	, "   ", ""	, "@!"	, 080, .F., {|| UPPER(ALLTRIM(aDadosLog[nX][1]))},, .T.)
oBreak := TRBreak():New(oSection1, oSection1:Cell("ARQUIVO"), "")

oSection2 := TRSection():New(oSection1, "ITENS", "   ")
oSection2:SetAutoSize(.F.) 
oSection2:SetPageBreak(.F.)
oSection2:SetHeaderBreak(.T.)

TRCell():New(oSection2, "ITEM"		, "   ", "ITEM"		, "@!"	, 015, .F., {|| STRZERO(aDadosLog[nX][3],6)},, .T.)
TRCell():New(oSection2, "LINHA"		, "   ", "LINHA"	, "@!"	, 500, .F., {|| ALLTRIM(aDadosLog[nX][2])},, .F.)
TRCell():New(oSection2, "LOG"		, "   ", "LOG"		, "@!"	, 100, .F., {|| DESCLOG(aDadosLog[nX][4])},, .T.)  
TRCell():New(oSection2, "DETALHE"	, "   ", "DETALHE"	, "@!"	, 100, .F., {|| ALLTRIM(aDadosLog[nX][5])},, .T.)  
			
Return oReport    

//-------------------------------------------------------------------
/*/{Protheus.doc} PRINTREPORT

Fun��o para gerar o Relat�rio com o resultado da importa��o.

@author  Allan Bonfim

@since   11/03/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function PRINTREPORT(oReport, aDadosLog)

Local oSection1 := oReport:Section(1)   
Local oSection2 := oReport:Section(1):Section(1)   
Local cNomeArq	:= ""

oReport:SetTitle(oReport:Title())
oReport:SkipLine()
oReport:SetMeter(Len(aDadosLog))

For nX:=1 to Len(aDadosLog)
 	If nX == 1 .OR. ALLTRIM(cNomeArq) <> ALLTRIM(aDadosLog[nX][1])
		cNomeArq := aDadosLog[nX][1]

 		oSection2:Finish()    
		oReport:SkipLine()
		
		oSection1:Init()
		oSection1:PrintLine()
	EndIf

	If oReport:Cancel()
		Exit
	EndIf 			

	oSection2:Init()
	oSection2:PrintLine()
   	oReport:IncMeter()
   	
Next

oSection2:Finish()    
oReport:SkipLine()	
	
oSection1:Finish()   	  	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DESCLOG

Descri��o do Log.

@author  Allan Bonfim

@since   13/03/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function DESCLOG(cTipoLog)

Local cDescRet := ""

Do Case
	Case cTipoLog == "1"
		cDescRet := "Registro gravado corretamente."
	Case cTipoLog == "2"
		cDescRet := "N�o existem dados v�lidos para a importa��o."
	Case cTipoLog == "3"
		cDescRet := "Linha inconsistente."
	Case cTipoLog == "4"
		cDescRet := "Registro j� gravado na base de dados."
	Case cTipoLog == "5"
		cDescRet := "Falha na grava��o da Movimenta��o Interna (SD3)."
	Case cTipoLog == "6"
		cDescRet := "Falha na estrutura do arquivo."
		
EndCase

Return cDescRet   