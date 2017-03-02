#include "TOTVS.CH"
#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM009

Rotina para importação de SFK - Saldos CAT 17.

@author  Caio Garcia

@since   17/07/2015

@version P11
 
@param

@obs 	17/07/2015 - Caio Garcia - Desenvolvimento da rotina

@return

/*/
//-------------------------------------------------------------------

User Function CAMBM009()

Local aArea	   		:= GetArea()
Local aSays 		:= {}
Local aButtons		:= {}
Local nOpca			:= 0 
Local cTmpPath		:= GetTempPath(.T.)
Local cNomeArq		:= "CAT_17.XLS"
Local cLayout		:= cTmpPath+cNomeArq

Private cCadastro	:= "Importação Saldos CAT 17 (SFK)"
Private aCabec		:= {}
Private aLinhas		:= {}
Private cNomArq		:= ""
Private cPathArq 	:= ""
Private aTipoArq	:= {"TXT", "CSV"}
Private aLinLog		:= {}
Private aParam
Private aPergs
Private oProcess

If File("\LAYOUT\"+cNomeArq)
	CPYS2T("\LAYOUT\"+cNomeArq, cTmpPath, .T.)
EndIf

AADD(aSays, OemToAnsi("Esta função tem o objetivo de importar os saldos da CAT 17 informados no arquivo para o sistema"))
AADD(aSays, OemToAnsi("Protheus - Tabela (SFK)"))
AADD(aSays, OemToAnsi("Os arquivos TXT e CSV deverão ter a primeira linha com o cabeçalho contendo o nome"))
AADD(aSays, OemToAnsi("dos campos e as demais linhas com os valores, separados por ; ."))    
AADD(aSays, OemToAnsi(""))
                                         
If File(cLayout)
	AADD(aButtons, {14,.T.,{|| nOpca := 0, SHELLEXECUTE("Open", cLayout, " /k dir", "C:\", 1 ), FECHABATCH()}})
EndIf

AADD(aButtons, {1,.T.,{|| nOpca := IIf(CAMBM09P(@aParam, @aPergs), 1, 0), FECHABATCH()}})
AADD(aButtons, {2,.T.,{|| nOpca := 0, FECHABATCH()}})

FormBatch(cCadastro, aSays, aButtons)

If nOpca == 1
	If MSGYESNO("Confirma a importação dos arquivos do diretório selecionado ?", cCadastro)
		//FWMsgRun(, {|| CAMBM09I()}, "Importando os Arquivos... Aguarde...")
		oProcess := MsNewProcess():New({ |lFim| CAMBM09I(@lFim)}, "Importação dos Saldos CAT 17", "Processando...", .T. )
		oProcess:Activate()	
	EndIf
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM09I

Rotina para importação dos Saldos da CAT 17.

@author  Allan Bonfim

@since   15/06/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM09I(lFim)

Local aArea	   		:= GetArea()
Local cPstSrv		:= ALLTRIM(SUPERGETMV("CB_XPSTSFK", ,"\IMPORTACAO\SFK\"))
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
	
			If EXISTDIR (cPstSrv) //Backup do arquivo de importação
				CPYT2S(cTmpPath+cNomArq, cPstSrv, .T.)
			Else	
				If MAKEDIR(cPstSrv) == 0
					CPYT2S(cTmpPath+cNomArq, cPstSrv, .T.)
				EndIf
			EndIf

			If FILE(cPstSrv+cNomArq) 
				If CAMBM09A(cPstSrv+cNomArq, cPathArq)
					Begin Transaction
						If !CAMBM09G(aCabec, aLinhas, cPathArq)
							FERASE(cPstSrv+cNomArq)
						EndIf
					End Transaction
				EndIf
	
				FERASE(cTmpPath+cNomArq)
			Else
				MSGSTOP ("Falha na criação do arquivo "+ALLTRIM(aArquivos[nY])+" na pasta "+cTmpPath+" do Servidor Protheus. Entre em contato com TI.", cCadastro)
			EndIf
			oProcess:Incregua2("Finalizando...")
			SLEEP(nSleep)
		Next
	Next

//End Transaction
	
If aParam[1] == "1" //Gera Log
	FWMsgRun(, {|| CAMBM09R(aCabec, aLinLog)}, "Gerando o Log da Importação... Aguarde...") 
EndIf

MSGINFO ("A importação dos arquivos do diretório "+UPPER(ALLTRIM(aParam[2]))+" foi finalizada.", cCadastro)


RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM09A

Função para abertura do arquivo.

@author  Allan Bonfim

@since   15/06/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static function CAMBM09A(cArqImp, cArqOri)

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
				If "FK_" $ xBuffer //Cabeçalho
             		aCabec	:= WFTokenChar(UPPER(xBuffer), ";")
             	Else
             		If !EMPTY(STRTRAN(xBuffer, ";", ""))
				    	aLinTmp := WFTokenChar(UPPER(xBuffer), ";")
					    AADD(aLinhas, aLinTmp)
					EndIf
				EndIf
						       
			    FT_FSKIP() //Pula para o próximo registro				
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
	If 	ASCAN(aCabec, {|x| ALLTRIM(x) == "FK_PRODUTO"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "FK_DATA"}) == 0 .OR. LEN(aLinhas) == 0		
		AADD(aLinLog, {cArqOri, "", 0, "6", cValInc}) //Erro na estrutura do arquivo.
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)
 
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM09G

Função para gravação dos dados do arquivo.

@author  Allan Bonfim

@since   29/05/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static function CAMBM09G(aCab, aItens, cArqOri)

Local aArea			:= GetArea()
Local nX			:= 0
Local nY			:= 0
Local nPosData		:= 0
Local nPosProd		:= 0
Local nPosFil		:= 0
Local lRet			:= .F.
Local cLogTmp		:= ""
Local cValInc		:= ""    
Local cNomeArq		:= "LOG_"+ALLTRIM(STR(ALEATORIO(999999, VAL(SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)+SUBSTR(TIME(), 7, 2)))))+".log"
Local cBuffer		:= ""
Local nErrLin		:= 1 
Local nLinhas		:= 0
Local cErroTemp		:= ""
Local aDadosSFK		:= {}
Local nTamReg2		:= 0

Private lMsHelpAuto	:= .F.
Private lMsErroAuto := .F.
  	 					
Default aCab		:= {}
Default aItens		:= {}
Default cArqOri		:= ""

If Len(aCab) > 0 .AND. Len(aItens) > 0

	nPosProd	:= ASCAN(aCab, {|x| ALLTRIM(x) == "FK_PRODUTO"})
	nPosData 	:= ASCAN(aCab, {|x| ALLTRIM(x) == "FK_DATA"})
	nPosFil		:= ASCAN(aCab, {|x| ALLTRIM(x) == "FK_FILIAL"})
	
	DbSelectArea("SFK")
	SFK->(DbSetOrder(1)) //FK_FILIAL+FK_PRODUTO+DTOS(FK_DATA)
    SFK->(DbGoTop())
   
	nTamReg2 := Len(aItens)
	oProcess:SetRegua2(nTamReg2)
		
	For nX:=1 To Len(aItens)

		oProcess:Incregua2("Gravando o Item "+STRZERO(nX, 5)+" de "+STRZERO(Len(aItens), 5))
		                
		If EMPTY(aItens[nX][nPosProd]) .OR. EMPTY(aItens[nX][nPosData])
                  
			cValInc	:= ""
			cLogTmp	:= ""
			AEVAL(aItens[nX], {|X| cLogTmp += X+" "})

			If EMPTY(aItens[nX][nPosProd])
				If !EMPTY(cValInc)
					cValInc += ", "
				EndIf

				cValInc += aCab[nPosProd]
			EndIf
			
			If EMPTY(aItens[nX][nPosData])
				If !EMPTY(cValInc)
					cValInc += ", "
				EndIf
			
				cValInc += aCab[nPosData]
			EndIf
		
			If !EMPTY(cValInc)
				cValInc += " não preenchido ou conteúdo inválido."
			EndIf
		
			AADD(aLinLog, {cArqOri, cLogTmp, nX, "3", cValInc})
	
		ElseIf SFK->(DbSeek(IIF (nPosFil == 0, xFilial("SFK"), STRZERO(VAL(aItens[nX][nPosFil]), 4))+AVKEY(aItens[nX][nPosProd], "FK_PRODUTO")+DTOS(CTOD(aItens[nX][nPosData]))))
		    /*
			SX3->(DbSetOrder(2))
			
			//Tratamento via Reclock para evitar as validações da rotina.
			RecLock("SFK", .F.)

				If nPosFil == 0
					SFK->FK_FILIAL := xFilial("SFK")
				EndIf
			
				For nY:=1 To Len(aCab)
					If "FK_" $ ALLTRIM(aCab[nY])
 						If SX3->(DbSeek(ALLTRIM(aCab[nY])))
							If SX3->(GETADVFVAL("SX3", "X3_TIPO", ALLTRIM(aCab[nY]), 2, "C")) == "D"
								&("SFK->"+ALLTRIM(aCab[nY])) := CTOD(aItens[nX][nY])
							ElseIf SX3->(GETADVFVAL("SX3", "X3_TIPO", ALLTRIM(aCab[nY]), 2, "C")) == "N"
								&("SFK->"+ALLTRIM(aCab[nY])) := VAL(STRTRAN(aItens[nX][nY], ",", "."))
							Else
								&("SFK->"+ALLTRIM(aCab[nY])) := AVKEY(FwNoAccent(aItens[nX][nY]), ALLTRIM(aCab[nY]))
							EndIf
						EndIf
					EndIf
				Next
				
				SFK->FK_XIMPORT := "S"
				
			SFK->(MsUnlock())

  
//	 		cValInc := "RECNO SFK = "+ALLTRIM(STR(SFK->(RECNO())))
//			cLogTmp	:= ""
//			AEVAL(aItens[nX], {|X| cLogTmp += X+" "})
//			AADD(aLinLog, {cArqOri, cLogTmp, nX, "4", cValInc}) //Registro já gravado.
            */

		Else	  						
 
			SX3->(DbSetOrder(2))
			
			//Tratamento via Reclock para evitar as validações da rotina.
			RecLock("SFK", .T.)

				If nPosFil == 0
					SFK->FK_FILIAL := xFilial("SFK")
				EndIf
			
				For nY:=1 To Len(aCab)
					If "FK_" $ ALLTRIM(aCab[nY])
 						If SX3->(DbSeek(ALLTRIM(aCab[nY])))
							If SX3->(GETADVFVAL("SX3", "X3_TIPO", ALLTRIM(aCab[nY]), 2, "C")) == "D"
								&("SFK->"+ALLTRIM(aCab[nY])) := CTOD(aItens[nX][nY])
							ElseIf SX3->(GETADVFVAL("SX3", "X3_TIPO", ALLTRIM(aCab[nY]), 2, "C")) == "N"
								&("SFK->"+ALLTRIM(aCab[nY])) := VAL(STRTRAN(aItens[nX][nY], ",", "."))
							Else
								&("SFK->"+ALLTRIM(aCab[nY])) := AVKEY(FwNoAccent(aItens[nX][nY]), ALLTRIM(aCab[nY]))
							EndIf
						EndIf
					EndIf
				Next
				
				SFK->FK_XIMPORT := "S"
				
			SFK->(MsUnlock())        
        
/*
			aDadosSFK 	:= {}
			lMsErroAuto	:= .F.
			nErrLin		:= 0
				
			For nY:=1 To Len(aCab)
				If SX3->(GETADVFVAL("SX3", "X3_TIPO", ALLTRIM(aCab[nY]), 2, "C")) == "D"
					AADD(aDadosSFK,	{ALLTRIM(aCab[nY]), CTOD(aItens[nX][nY]), NIL})
				ElseIf SX3->(GETADVFVAL("SX3", "X3_TIPO", ALLTRIM(aCab[nY]), 2, "C")) == "N"
					AADD(aDadosSFK,	{ALLTRIM(aCab[nY]), VAL(STRTRAN(aItens[nX][nY], ",", ".")), NIL})
				Else
					AADD(aDadosSFK,	{ALLTRIM(aCab[nY]), AVKEY(FwNoAccent(aItens[nX][nY]), ALLTRIM(aCab[nY])), NIL})
				EndIf							
			Next
			
			If nPosFil == 0
				AADD(aDadosSFK, {"FK_FILIAL"	, xFilial("SFK"), Nil})
			EndIf
			
			AADD(aDadosSFK, {"FK_XIMPORT", "S", Nil})

			AXINCLUI("SFK", NIL, 3,,,,,,,,, aDadosSFK)

			If lMsErroAuto
				cErroTemp 	:= MOSTRAERRO(GetSrvProfString("Startpath",""), cNomeArq)
				nLinhas 	:= MLCOUNT(cErroTemp)
				cBuffer 	:= RTRIM(MEMOLINE(cErroTemp,, nErrLin))
							
				While (nErrLin <= nLinhas)
					nErrLin++
			    	cBuffer := ALLTRIM(MEMOLINE(cErroTemp,, nErrLin))
			     	If (UPPER(SUBSTR(cBuffer, LEN(cBuffer)-7, LEN(cBuffer))) == "INVALIDO") 
						cValInc := "ERRO GRAVAÇÃO SFK = "+ALLTRIM(cBuffer)
						Exit									
			    	EndIf 
				EndDo
						
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
*/
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
/*/{Protheus.doc} CAMBM09P

Parâmetros da Rotina.

@author  Allan Bonfim

@since   29/05/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM09P(aParam, aPergs)

Local aArea		:= GetArea()
Local lRet   	:= .F.
Local lValid 	:= .F.
Local cTmpPath	:= GetTempPath (.T.)

Default aParam	:= {}
Default aPergs	:= {}

AADD(aPergs, {2, "Gera Log"	   				, "1", {"1=Sim", "2=Não"}, 80, , .T.})
AADD(aPergs, {6, "Selecione o Diretório"	, cPathArq, "", "", "", 80, .T., "", cTmpPath, GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY})

Do While !lValid
	If ParamBox(aPergs, "Parametros ", @aParam)		
		lValid	:= CAMBM09V(aParam, aPergs)
		lRet	:= .T.
	Else
		lValid	:= .T.
		lRet	:= .F.
	EndIf
Enddo

RestArea(aArea)

Return lRet                 

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM09V

Validação dos Parâmetros.

@author  Allan Bonfim

@since   29/05/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM09V(aPar, aPrgs)

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
	MsgStop("Não existem arquivos válidos ("+cTipoArq+") para importação no diretório selecionado ("+UPPER(ALLTRIM(aPar[2]))+"). Selecione um diretório válido.", cCadastro)
EndIf
	
Return lRet                    

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM09R

Relatório com o resultado da importação.

@author  Allan Bonfim

@since   11/03/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM09R(aCabec, aDadosLog)

Local aArea 	:= GetArea()
Local oReport

oReport := ReportDef(aCabec, aDadosLog)
oReport:PrintDialog()

Return        

//-------------------------------------------------------------------
/*/{Protheus.doc} REPORTDEF

Relatório com o resultado da importação.

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

oReport  := TReport():New("CAMBM009", "LOG DA IMPORTAÇÃO - SALDOS CAT 17", "", {|oReport| PrintReport(oReport, aDadosLog)}, "Log da Importação do arquivo para a tabela SFK (Saldos CAT 17)")

oReport:nFontBody   := 8
oReport:nLineHeight := 50
oReport:cFontBody   := "Arial"
oReport:cDir		:= GetTempPath (.T.)
oReport:nDevice		:= 1 //1-Arquivo,2-Impressora,3-email,4-Planilha, 5-Html, 6=PDF, 7=ODF
oReport:nEnvironment:= 2 //1-Server e 2-Cliente.

oReport:NoUserFilter()
oReport:SetLandscape() //Escolher o padrão de Impressao como Paisagem  		

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

Função para gerar o Relatório com o resultado da importação.

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

Descrição do Log.

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
		cDescRet := "Nâo existem dados válidos para a importação."
	Case cTipoLog == "3"
		cDescRet := "Linha inconsistente."
	Case cTipoLog == "4"
		cDescRet := "Registro já gravado na base de dados."
	Case cTipoLog == "5"
		cDescRet := "Falha na gravação do Saldo CAT 17 (SFK)."
	Case cTipoLog == "6"
		cDescRet := "Falha na estrutura do arquivo."
		
EndCase

Return cDescRet   