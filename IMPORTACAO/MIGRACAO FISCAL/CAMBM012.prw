#include "TOTVS.CH"
#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM012

Rotina para importação dos Livros Fiscais de Entrada e Saída por Item

@author  Allan Bonfim

@since  05/09/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------

User Function CAMBM012()

Local aArea	   		:= GetArea()
Local aSays 		:= {}
Local aButtons		:= {}
Local nOpca			:= 0
Local cTmpPath		:= GetTempPath(.T.)
Local cNomeArq		:= "LIVROS_FISCAIS_ITEM.XLS"
Local cLayout		:= cTmpPath+cNomeArq

Private cCadastro	:= "Importação dos Livros Fiscais de Entrada e Saída por Item (SFT)"
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

AADD(aSays, OemToAnsi("Esta função tem o objetivo de atualizar os Livros Fiscais por Item informados no arquivo para o sistema"))
AADD(aSays, OemToAnsi("Protheus - Tabela (SFT)"))
AADD(aSays, OemToAnsi("Os arquivos TXT e CSV deverão ter a primeira linha com o cabeçalho contendo o nome"))
AADD(aSays, OemToAnsi("dos campos e as demais linhas com os valores, separados por ; ."))    
AADD(aSays, OemToAnsi(""))

If File(cLayout)
	AADD(aButtons, {14,.T.,{|| nOpca := 0, SHELLEXECUTE("Open", cLayout, " /k dir", "C:\", 1 ), FECHABATCH()}})
EndIf

AADD(aButtons, {1,.T.,{|| nOpca := IIf(CAMBM12P(@aParam, @aPergs), 1, 0), FECHABATCH()}})
AADD(aButtons, {2,.T.,{|| nOpca := 0, FECHABATCH()}})

FormBatch(cCadastro, aSays, aButtons)

If nOpca == 1
	If MSGYESNO("Confirma a importação dos arquivos do diretório selecionado ?", cCadastro)
		//FWMsgRun(, {|| CAMBM12I()}, "Importando os Arquivos... Aguarde...")
		oProcess := MsNewProcess():New({ |lFim| CAMBM12I(@lFim)}, "Importação dos Livros Fiscais de Entrada e Saída por Item", "Processando...", .T. )
		oProcess:Activate()	
		
	EndIf
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM12I

Rotina para importação dos Livros Fiscais.

@author  Allan Bonfim

@since   05/09/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM12I(lFim)

Local aArea	   		:= GetArea()
Local cPstSrv		:= ALLTRIM(SUPERGETMV("CB_XPSTSFT", ,"\IMPORTACAO\SFT\"))
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
				If CAMBM12A(cPstSrv+cNomArq, cPathArq)
					Begin Transaction
						If !CAMBM12G(aCabec, aLinhas, cPathArq)
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
	FWMsgRun(, {|| CAMBM12R(aCabec, aLinLog)}, "Gerando o Log da Importação... Aguarde...") 
EndIf

MSGINFO ("A importação dos arquivos do diretório "+UPPER(ALLTRIM(aParam[2]))+" foi finalizada.", cCadastro)


RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM12A

Função para abertura do arquivo.

@author  Allan Bonfim

@since   05/09/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static function CAMBM12A(cArqImp, cArqOri)

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
				If "FT_" $ xBuffer //Cabeçalho
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
	If	(ASCAN(aCabec, {|x| ALLTRIM(x) == "FT_NFISCAL"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "FT_SERIE"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "FT_CLIEFOR"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "FT_LOJA"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "FT_PRODUTO"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "FT_ITEM"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "FT_CFOP"}) == 0 .OR. LEN(aLinhas) == 0)
		AADD(aLinLog, {cArqOri, "", 0, "6", cValInc}) //Erro na estrutura do arquivo.
		lRet := .F.
	EndIf
EndIf
	
RestArea(aArea)
 
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM12G

Função para gravação dos dados do arquivo.

@author  Allan Bonfim

@since   05/09/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static function CAMBM12G(aCab, aItens, cArqOri)

Local aArea			:= GetArea()
Local nX			:= 0
Local nY			:= 0
Local nPosDoc		:= 0
Local nPosSer		:= 0
Local nPosCod		:= 0
Local nPosLoj		:= 0
Local nPosPrd		:= 0
Local nPosFil		:= 0
Local nPosCfo		:= 0
Local lRet			:= .F.
Local cLogTmp		:= ""
Local cValInc		:= ""    
Local cNomeArq		:= "LOG_"+ALLTRIM(STR(ALEATORIO(999999, VAL(SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)+SUBSTR(TIME(), 7, 2)))))+".log"
Local cBuffer		:= ""
Local nErrLin		:= 1 
Local nLinhas		:= 0
Local cErroTemp		:= ""
//Local aDadosSF3		:= {}    16/11/15 - JOSMAR
Local aDadosSFT		:= {}
Local nTamReg2		:= 0

Private lMsHelpAuto	:= .F.
Private lMsErroAuto := .F.
  	 					
Default aCab		:= {}
Default aItens		:= {}
Default cArqOri		:= ""

If Len(aCab) > 0 .AND. Len(aItens) > 0

	nPosDoc 	:= ASCAN(aCab, {|x| ALLTRIM(x) == "FT_NFISCAL"})
	nPosSer		:= ASCAN(aCab, {|x| ALLTRIM(x) == "FT_SERIE"})
	nPosCod		:= ASCAN(aCab, {|x| ALLTRIM(x) == "FT_CLIEFOR"})
	nPosLoj		:= ASCAN(aCab, {|x| ALLTRIM(x) == "FT_LOJA"})	
	nPosPrd		:= ASCAN(aCab, {|x| ALLTRIM(x) == "FT_PRODUTO"})
	nPosItm		:= ASCAN(aCab, {|x| ALLTRIM(x) == "FT_ITEM"})
	nPosCfo		:= ASCAN(aCab, {|x| ALLTRIM(x) == "FT_CFOP"})	
	nPosFil		:= ASCAN(aCab, {|x| ALLTRIM(x) == "FT_FILIAL"})	

	DbSelectArea("SF2")
	SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		
	DbSelectArea("SD2")
	SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

	DbSelectArea("SF1")
	SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
			
	DbSelectArea("SD1")
	SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	
	DbSelectArea("SFT")
	SFT->(DbSetOrder(1)) //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
			
	//DbSelectArea("SF3") 16/11/15 - JOSMAR
	//SF3->(DbSetOrder(4)) //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE 
	
	If nPosFil == 0
		cFilImp := xFilial("SFT")
	Else
		cFilImp := STRZERO(VAL(aItens[1][nPosFil]), 4)
	EndIf

	If nPosFil > 0
		ASORT(aItens,,, {|x,y| x[nPosFil]+x[nPosCod]+x[nPosLoj]+x[nPosDoc]+x[nPosSer]+x[nPosItm]+x[nPosPrd] < y[nPosFil]+y[nPosCod]+y[nPosLoj]+y[nPosDoc]+y[nPosSer]+y[nPosItm]+y[nPosPrd]})
	Else
		ASORT(aItens,,, {|x,y| x[nPosCod]+x[nPosLoj]+x[nPosDoc]+x[nPosSer]+x[nPosItm]+x[nPosPrd] < y[nPosCod]+y[nPosLoj]+y[nPosDoc]+y[nPosSer]+y[nPosItm]+y[nPosPrd]})
	EndIf

	nTamReg2 := Len(aItens)
	oProcess:SetRegua2(nTamReg2)
			 					
	For nX:=1 To Len(aItens)

		oProcess:Incregua2("Gravando o Item "+STRZERO(nX, 5)+" de "+STRZERO(Len(aItens), 5))
				                
		If EMPTY(aItens[nX][nPosDoc]) .OR. EMPTY(aItens[nX][nPosSer]) .OR. EMPTY(aItens[nX][nPosCod]) .OR. EMPTY(aItens[nX][nPosLoj]) .OR. EMPTY(aItens[nX][nPosPrd]) .OR. EMPTY(aItens[nX][nPosItm]) .AND. EMPTY(aItens[nX][nPosCfo])
			cValInc	:= ""
			cLogTmp	:= ""
			AEVAL(aItens[nX], {|X| cLogTmp += X+" "})

			If !EMPTY(nPosDoc)
				If EMPTY(aItens[nX][nPosDoc])
					If !EMPTY(cValInc)
						cValInc += ", "
					EndIf
	
					cValInc += aCab[nPosDoc]
				EndIf
			EndIf
						
			If !EMPTY(nPosSer)
				If EMPTY(aItens[nX][nPosSer])
					If !EMPTY(cValInc)
						cValInc += ", "
					EndIf
				
					cValInc += aCab[nPosSer]
				EndIf
			EndIf
			
			If !EMPTY(nPosCod)
				If EMPTY(aItens[nX][nPosCod])
					If !EMPTY(cValInc)
						cValInc += ", "
					EndIf
				
					cValInc += aCab[nPosCod]
				EndIf
			EndIf
			
			If !EMPTY(nPosLoj)
				If EMPTY(aItens[nX][nPosLoj])
					If !EMPTY(cValInc)
						cValInc += ", "
					EndIf
				
					cValInc += aCab[nPosLoj]
				EndIf
			EndIf

			If !EMPTY(nPosPrd)
				If EMPTY(aItens[nX][nPosPrd])
					If !EMPTY(cValInc)
						cValInc += ", "
					EndIf
				
					cValInc += aCab[nPosPrd]
				EndIf
			EndIf

			If !EMPTY(nPosItm)
				If EMPTY(aItens[nX][nPosItm])
					If !EMPTY(cValInc)
						cValInc += ", "
					EndIf
				
					cValInc += aCab[nPosItm]
				EndIf
			EndIf

			If !EMPTY(nPosCfo)
				If EMPTY(aItens[nX][nPosCfo])
					If !EMPTY(cValInc)
						cValInc += ", "
					EndIf
				
					cValInc += aCab[nPosCfo]
				EndIf
			EndIf
											
			If !EMPTY(cValInc)
				cValInc += " não preenchido ou conteúdo inválido."
			EndIf
		
			AADD(aLinLog, {cArqOri, cLogTmp, nX, "3", cValInc})
		
		ElseIf Left(aItens[nX][nPosCfo], 1) < "5" .AND. !SF1->(DbSeek(xFilial("SF1")+AVKEY(aItens[nX][nPosDoc], "F1_DOC")+AVKEY(aItens[nX][nPosSer], "F1_SERIE")+AVKEY(aItens[nX][nPosCod], "F1_FORNECE")+AVKEY(aItens[nX][nPosLoj], "D1_LOJA")))

	 		cValInc := "NOTA FISCAL / SERIE = "+AVKEY(aItens[nX][nPosDoc], "F1_DOC")+" / "+AVKEY(aItens[nX][nPosSer], "F1_SERIE")
			cLogTmp	:= ""
			AEVAL(aItens[nX], {|X| cLogTmp += X+" "})
			AADD(aLinLog, {cArqOri, cLogTmp, nX, "8", cValInc})
			
		ElseIf Left(aItens[nX][nPosCfo], 1) < "5" .AND. !SD1->(DbSeek(xFilial("SD1")+AVKEY(aItens[nX][nPosDoc], "D1_DOC")+AVKEY(aItens[nX][nPosSer], "D1_SERIE")+AVKEY(aItens[nX][nPosCod], "D1_FORNECE")+AVKEY(aItens[nX][nPosLoj], "D1_LOJA")+AVKEY(aItens[nX][nPosPrd], "D1_COD")+AVKEY(aItens[nX][nPosItm], "D1_ITEM")))

	 		cValInc := "NOTA FISCAL / SERIE = "+AVKEY(aItens[nX][nPosDoc], "D1_DOC")+" / "+AVKEY(aItens[nX][nPosSer], "D1_SERIE")+" - ITEM ("+AVKEY(aItens[nX][nPosItm], "D1_ITEM")+")"
			cLogTmp	:= ""
			AEVAL(aItens[nX], {|X| cLogTmp += X+" "})
			AADD(aLinLog, {cArqOri, cLogTmp, nX, "8", cValInc})

		ElseIf Left(aItens[nX][nPosCfo], 1) >= "5" .AND. !SF2->(DbSeek(xFilial("SF2")+AVKEY(aItens[nX][nPosDoc], "F2_DOC")+AVKEY(aItens[nX][nPosSer], "F2_SERIE")+AVKEY(aItens[nX][nPosCod], "F2_CLIENTE")+AVKEY(aItens[nX][nPosLoj], "D1_LOJA")))

	 		cValInc := "NOTA FISCAL / SERIE = "+AVKEY(aItens[nX][nPosDoc], "F2_DOC")+" / "+AVKEY(aItens[nX][nPosSer], "F2_SERIE")
			cLogTmp	:= ""
			AEVAL(aItens[nX], {|X| cLogTmp += X+" "})
			AADD(aLinLog, {cArqOri, cLogTmp, nX, "7", cValInc})

		ElseIf Left(aItens[nX][nPosCfo], 1) >= "5" .AND. !SD2->(DbSeek(xFilial("SD2")+AVKEY(aItens[nX][nPosDoc], "D2_DOC")+AVKEY(aItens[nX][nPosSer], "D2_SERIE")+AVKEY(aItens[nX][nPosCod], "D2_CLIENTE")+AVKEY(aItens[nX][nPosLoj], "D2_LOJA")+AVKEY(aItens[nX][nPosPrd], "D2_COD")+AVKEY(aItens[nX][nPosItm], "D2_ITEM")))

	 		cValInc := "NOTA FISCAL / SERIE = "+AVKEY(aItens[nX][nPosDoc], "D2_DOC")+" / "+AVKEY(aItens[nX][nPosSer], "D2_SERIE")+" - ITEM ("+AVKEY(aItens[nX][nPosItm], "D2_ITEM")+")"
			cLogTmp	:= ""
			AEVAL(aItens[nX], {|X| cLogTmp += X+" "})
			AADD(aLinLog, {cArqOri, cLogTmp, nX, "7", cValInc})

		ElseIf !SFT->(DbSeek(IIF (nPosFil == 0, xFilial("SFT"), STRZERO(VAL(aItens[nX][nPosFil]), 4))+AVKEY(IIF (Left(aItens[nX][nPosCfo], 1) >= "5", "S", "E") ,"FT_TIPOMOV")+AVKEY(aItens[nX][nPosSer], "FT_SERIE")+AVKEY(aItens[nX][nPosDoc], "FT_NFISCAL")+AVKEY(aItens[nX][nPosCod], "FT_CLIEFOR")+AVKEY(aItens[nX][nPosLoj], "FT_LOJA")+AVKEY(aItens[nX][nPosItm], "FT_ITEM")+AVKEY(aItens[nX][nPosPrd], "FT_PRODUTO")))
	 		cValInc := "NOTA FISCAL / SERIE = "+AVKEY(aItens[nX][nPosDoc], "FT_NFISCAL")+" / "+AVKEY(aItens[nX][nPosSer], "FT_SERIE")+" - ITEM ("+AVKEY(aItens[nX][nPosItm], "FT_ITEM")+")"
			cLogTmp	:= ""
			AEVAL(aItens[nX], {|X| cLogTmp += X+" "})
			AADD(aLinLog, {cArqOri, cLogTmp, nX, "9", cValInc})
											
		Else	  						

			SX3->(DbSetOrder(2))
						
			//Tratamento via Reclock para evitar as validações da rotina.
			RecLock("SFT", .F.)
			
				For nY:=1 To Len(aCab)
					If SX3->(DbSeek(ALLTRIM(aCab[nY])))				
						If "FT_" $ ALLTRIM(aCab[nY])
							If SX3->(GETADVFVAL("SX3", "X3_TIPO", ALLTRIM(aCab[nY]), 2, "C")) == "D"
								&("SFT->"+ALLTRIM(aCab[nY])) := CTOD(aItens[nX][nY])
							ElseIf SX3->(GETADVFVAL("SX3", "X3_TIPO", ALLTRIM(aCab[nY]), 2, "C")) == "N"
								&("SFT->"+ALLTRIM(aCab[nY])) := VAL(STRTRAN(aItens[nX][nY], ",", "."))
							Else
								&("SFT->"+ALLTRIM(aCab[nY])) := AVKEY(FwNoAccent(aItens[nX][nY]), ALLTRIM(aCab[nY]))
							EndIf
						EndIf
					EndIf
				Next
				
				SFT->FT_XIMPORT := "S"
				
			SFT->(MsUnlock())
		EndIf
		
		/*	aDadosSFT := {}
			
			For nY:=1 To Len(aCab)
				If SX3->(GETADVFVAL("SX3", "X3_TIPO", ALLTRIM(aCab[nY]), 2, "C")) == "D"
					If "FT_" $ ALLTRIM(aCab[nY])
						AADD(aDadosSFT,	{ALLTRIM(aCab[nY]), CTOD(aItens[nX][nY]), NIL})
					EndIf
				ElseIf SX3->(GETADVFVAL("SX3", "X3_TIPO", ALLTRIM(aCab[nY]), 2, "C")) == "N"
					If "FT_" $ ALLTRIM(aCab[nY])
						AADD(aDadosSFT,	{ALLTRIM(aCab[nY]), VAL(STRTRAN(aItens[nX][nY], ",", ".")), NIL})
					EndIf
				Else
					If "FT_" $ ALLTRIM(aCab[nY])
						AADD(aDadosSFT,	{ALLTRIM(aCab[nY]), AVKEY(FwNoAccent(aItens[nX][nY]), ALLTRIM(aCab[nY])), NIL})
					EndIf
				EndIf
			Next
										
			If ASCAN(aDadosSFT, {|x| ALLTRIM(x) == "FT_FILIAL"}) == 0
				AADD(aDadosSFT, {"FT_FILIAL", cFilImp, Nil})
			EndIf			
			
			If ASCAN(aDadosSFT, {|x| ALLTRIM(x) == "FT_XIMPORT"}) == 0
				AADD(aDadosSFT, {"FT_XIMPORT", "S", Nil})
			EndIf

			If Len(aDadosSFT) > 0
				lMsErroAuto := .F.
				AXALTERA("SFT", SFT->(RECNO()), 4,,,,,,,,,, aDadosSFT)
					
				If lMsErroAuto
					cErroTemp 	:= MOSTRAERRO(GetSrvProfString("Startpath",""), cNomeArq)
					nLinhas 	:= MLCOUNT(cErroTemp)
					cBuffer 	:= RTRIM(MEMOLINE(cErroTemp,, nErrLin))
									
					While (nErrLin <= nLinhas)
						nErrLin++
					   	cBuffer := ALLTRIM(MEMOLINE(cErroTemp,, nErrLin))
					   	
					   	If "HELP" $ cBuffer
						   	cValInc := ALLTRIM(cErroTemp)
						   	Exit
					   	ElseIf (UPPER(SUBSTR(cBuffer, LEN(cBuffer)-7, LEN(cBuffer))) == "INVALIDO") 
							cValInc := "ERRO GRAVAÇÃO LIVRO FISCAL (SFT) = "+ALLTRIM(cBuffer)
							//Exit
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
			    EndIf				
			EndIf */
/*			
			If Len(aDadosSF3) > 0
				lMsErroAuto := .F.
				AXALTERA("SF3", SF3->(RECNO()), 4,,,,,,,,,, aDadosSF3)
	
				If lMsErroAuto
					cErroTemp 	:= MOSTRAERRO(GetSrvProfString("Startpath",""), cNomeArq)
					nLinhas 	:= MLCOUNT(cErroTemp)
					cBuffer 	:= RTRIM(MEMOLINE(cErroTemp,, nErrLin))
								
					While (nErrLin <= nLinhas)
						nErrLin++
				    	cBuffer := ALLTRIM(MEMOLINE(cErroTemp,, nErrLin))
				     	If (UPPER(SUBSTR(cBuffer, LEN(cBuffer)-7, LEN(cBuffer))) == "INVALIDO") 
							cValInc := "ERRO GRAVAÇÃO LIVRO FISCAL (SF3) = "+ALLTRIM(cBuffer)
							//Exit									
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
			EndIf			
		EndIf			*/
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
/*/{Protheus.doc} CAMBM12P

Parâmetros da Rotina.

@author  Allan Bonfim

@since   05/09/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM12P(aParam, aPergs)

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
		lValid	:= CAMBM12V(aParam, aPergs)
		lRet	:= .T.
	Else
		lValid	:= .T.
		lRet	:= .F.
	EndIf
Enddo

RestArea(aArea)

Return lRet                 

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM12V

Validação dos Parâmetros.

@author  Allan Bonfim

@since   05/09/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM12V(aPar, aPrgs)

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
/*/{Protheus.doc} CAMBM12R

Relatório com o resultado da importação.

@author  Allan Bonfim

@since   05/09/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM12R(aCabec, aDadosLog)

Local aArea 	:= GetArea()
Local oReport

oReport := ReportDef(aCabec, aDadosLog)
oReport:PrintDialog()

Return        

//-------------------------------------------------------------------
/*/{Protheus.doc} REPORTDEF

Relatório com o resultado da importação.

@author  Allan Bonfim

@since   05/09/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function REPORTDEF(aCabec, aDadosLog)

Local oReport

oReport  := TReport():New("CAMBM012", "LOG DA IMPORTAÇÃO - LIVROS FISCAIS DE ENTRADA E SAIDA POR ITEM", "", {|oReport| PrintReport(oReport, aDadosLog)}, "Log da Importação do arquivo para os Livros Fiscais de Entrada e Saída por Item (SFT)")

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

@since   05/09/2015

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
		cDescRet := "Falha na gravação do Livro Fiscal por Item (SFT)."
	Case cTipoLog == "6"
		cDescRet := "Falha na estrutura do arquivo."
	Case cTipoLog == "7"
		cDescRet := "Nota Fiscal de Saida não localizada."
	Case cTipoLog == "8"
		cDescRet := "Nota Fiscal de Entrada não localizada."
	Case cTipoLog == "8"
		cDescRet := "Nota Fiscal não localizada nos Livros Fiscais."
EndCase

Return cDescRet   