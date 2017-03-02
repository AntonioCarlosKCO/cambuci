#include "TOTVS.CH"
#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM010

Rotina para importação de CD5 - Complemento de Importação.

@author  Caio Garcia

@since   17/07/2015

@version P11
 
@param

@obs 	17/07/2015 - Caio Garcia - Desenvolvimento da rotina

@return

/*/
//-------------------------------------------------------------------

User Function CAMBM010()

Local aArea	   		:= GetArea()
Local aSays 		:= {}
Local aButtons		:= {}
Local nOpca			:= 0
Local cTmpPath		:= GetTempPath(.T.)
Local cNomeArq		:= "COMPLEMENTO_IMPORTACAO.XLS"
Local cLayout		:= cTmpPath+cNomeArq

Private cCadastro	:= "Importação Complemento Importação (CD5)"
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

AADD(aSays, OemToAnsi("Esta função tem o objetivo de importar o Complemento da Importação informados no arquivo para o sistema"))
AADD(aSays, OemToAnsi("Protheus - Tabela (CD5)"))
AADD(aSays, OemToAnsi("Os arquivos TXT e CSV deverão ter a primeira linha com o cabeçalho contendo o nome"))
AADD(aSays, OemToAnsi("dos campos e as demais linhas com os valores, separados por ; ."))    
AADD(aSays, OemToAnsi(""))

AADD(aSays, OemToAnsi("LAYOUT DO ARQUIVO DE IMPORTAÇÃO - Incluir o campo FORNECEDOR com o nome"))
AADD(aSays, OemToAnsi("caso os campos CD5_FORNEC e CD5_LOJA não sejam informados."))

If File(cLayout)
	AADD(aButtons, {14,.T.,{|| nOpca := 0, SHELLEXECUTE("Open", cLayout, " /k dir", "C:\", 1 ), FECHABATCH()}})
EndIf

AADD(aButtons, {1,.T.,{|| nOpca := IIf(CAMBM10P(@aParam, @aPergs), 1, 0), FECHABATCH()}})
AADD(aButtons, {2,.T.,{|| nOpca := 0, FECHABATCH()}})

FormBatch(cCadastro, aSays, aButtons)

If nOpca == 1
	If MSGYESNO("Confirma a importação dos arquivos do diretório selecionado ?", cCadastro)
		//FWMsgRun(, {|| CAMBM10I()}, "Importando os Arquivos... Aguarde...")
		oProcess := MsNewProcess():New({ |lFim| CAMBM10I(@lFim)}, "Importação do Complemento Importação", "Processando...", .T. )
		oProcess:Activate()		
	EndIf
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM10I

Rotina para importação dos Saldos da CAT 83.

@author  Allan Bonfim

@since   15/06/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM10I(lFim)

Local aArea	   		:= GetArea()
Local cPstSrv		:= ALLTRIM(SUPERGETMV("CB_XPSTCD5", ,"\IMPORTACAO\CD5\"))
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
				If CAMBM10A(cPstSrv+cNomArq, cPathArq)
					Begin Transaction
						If !CAMBM10G(aCabec, aLinhas, cPathArq)
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
	FWMsgRun(, {|| CAMBM10R(aCabec, aLinLog)}, "Gerando o Log da Importação... Aguarde...") 
EndIf

MSGINFO ("A importação dos arquivos do diretório "+UPPER(ALLTRIM(aParam[2]))+" foi finalizada.", cCadastro)


RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM10A

Função para abertura do arquivo.

@author  Allan Bonfim

@since   15/06/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static function CAMBM10A(cArqImp, cArqOri)

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
				If "CD5_" $ xBuffer //Cabeçalho
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
	If 	ASCAN(aCabec, {|x| ALLTRIM(x) == "CD5_DOC"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "CD5_SERIE"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "CD5_DOCIMP"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "CD5_DTDI"}) == 0 .OR.; 
		LEN(aLinhas) == 0 .OR. ((ASCAN(aCabec, {|x| ALLTRIM(x) == "CD5_FORNEC"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "CD5_LOJA"}) == 0) .AND. ASCAN(aCabec, {|x| ALLTRIM(x) == "FORNECEDOR"}) == 0)
		AADD(aLinLog, {cArqOri, "", 0, "6", cValInc}) //Erro na estrutura do arquivo.
		lRet := .F.
	EndIf
EndIf
	
RestArea(aArea)
 
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM10G

Função para gravação dos dados do arquivo.

@author  Allan Bonfim

@since   29/05/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static function CAMBM10G(aCab, aItens, cArqOri)

Local aArea			:= GetArea()
Local nX			:= 0
Local nY			:= 0
Local nPosDoc		:= 0
Local nPosSer		:= 0
Local nPosFor		:= 0
Local nPosLoj		:= 0
Local nPosDIm		:= 0
Local nPosFil		:= 0
Local nPosDtD		:= 0
Local nPosEsp		:= 0
Local nPosNom		:= 0
Local lRet			:= .F.
Local cLogTmp		:= ""
Local cValInc		:= ""    
Local cNomeArq		:= "LOG_"+ALLTRIM(STR(ALEATORIO(999999, VAL(SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)+SUBSTR(TIME(), 7, 2)))))+".log"
Local cBuffer		:= ""
Local nErrLin		:= 1 
Local nLinhas		:= 0
Local cErroTemp		:= ""
Local aDadosCDU		:= {}
Local nTamReg2		:= 0

Private lMsHelpAuto	:= .F.
Private lMsErroAuto := .F.
  	 					
Default aCab		:= {}
Default aItens		:= {}
Default cArqOri		:= ""

If Len(aCab) > 0 .AND. Len(aItens) > 0

	nPosDoc 	:= ASCAN(aCab, {|x| ALLTRIM(x) == "CD5_DOC"})
	nPosSer		:= ASCAN(aCab, {|x| ALLTRIM(x) == "CD5_SERIE"})
	nPosEsp		:= ASCAN(aCab, {|x| ALLTRIM(x) == "CD5_ESPEC"})	
	nPosFor		:= ASCAN(aCab, {|x| ALLTRIM(x) == "CD5_FORNEC"})
	nPosLoj		:= ASCAN(aCab, {|x| ALLTRIM(x) == "CD5_LOJA"})	
	nPosNom		:= ASCAN(aCab, {|x| ALLTRIM(x) == "FORNECEDOR"})
	nPosDIm		:= ASCAN(aCab, {|x| ALLTRIM(x) == "CD5_DOCIMP"})
	nPosDtD		:= ASCAN(aCab, {|x| ALLTRIM(x) == "CD5_DTDI"})
	nPosFil		:= ASCAN(aCab, {|x| ALLTRIM(x) == "CD5_FILIAL"})
	
	DbSelectArea("SD1")
	SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM

	DbSelectArea("SA2")
	SA2->(DbSetOrder(2)) //A2_FILIAL+A2_NOME+A2_LOJA
	
	DbSelectArea("CD5")
	CD5->(DbSetOrder(1)) //CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_DOCIMP+CD5_NADIC

	nTamReg2 := Len(aItens)
	oProcess:SetRegua2(nTamReg2)
	
	For nX:=1 To Len(aItens)

		oProcess:Incregua2("Gravando o Item "+STRZERO(nX, 5)+" de "+STRZERO(Len(aItens), 5))
				                
		If EMPTY(aItens[nX][nPosDoc]) .OR. EMPTY(aItens[nX][nPosSer]) .OR. EMPTY(aItens[nX][nPosDIm]) .OR. EMPTY(aItens[nX][nPosDtD]) .OR. ((EMPTY(nPosFor) .OR. EMPTY(nPosLoj)) .AND. EMPTY(nPosNom))
			cValInc	:= ""
			cLogTmp	:= ""
			AEVAL(aItens[nX], {|X| cLogTmp += X+" "})

			If EMPTY(aItens[nX][nPosDoc])
				If !EMPTY(cValInc)
					cValInc += ", "
				EndIf

				cValInc += aCab[nPosDoc]
			EndIf
			
			If EMPTY(aItens[nX][nPosSer])
				If !EMPTY(cValInc)
					cValInc += ", "
				EndIf
			
				cValInc += aCab[nPosSer]
			EndIf
			
			If !EMPTY(nPosFor)
				If EMPTY(aItens[nX][nPosFor])
					If !EMPTY(cValInc)
						cValInc += ", "
					EndIf
				
					cValInc += aCab[nPosFor]
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

			If !EMPTY(nPosNom)
				If EMPTY(aItens[nX][nPosNom])
					If !EMPTY(cValInc)
						cValInc += ", "
					EndIf
				
					cValInc += aCab[nPosNom]
				EndIf
			EndIf
							
			If EMPTY(aItens[nX][nPosDtD])
				If !EMPTY(cValInc)
					cValInc += ", "
				EndIf
			
				cValInc += aCab[nPosDtD]
			EndIf

			If EMPTY(aItens[nX][nPosDIm])
				If !EMPTY(cValInc)
					cValInc += ", "
				EndIf
			
				cValInc += aCab[nPosDIm]
			EndIf
								
			If !EMPTY(cValInc)
				cValInc += " não preenchido ou conteúdo inválido."
			EndIf
		
			AADD(aLinLog, {cArqOri, cLogTmp, nX, "3", cValInc})

 		//A2_FILIAL+A2_NOME+A2_LOJA
		ElseIf nPosFor == 0 .AND. nPosLoj == 0 .AND. !SA2->(DbSeek(xFilial("SA2")+AVKEY(ALLTRIM(aItens[nX][nPosNom]), "A2_NOME")))

	 		cValInc := "FORNECEDOR = "+ALLTRIM(aItens[nX][nPosNom])
			cLogTmp	:= ""
			AEVAL(aItens[nX], {|X| cLogTmp += X+" "})
			AADD(aLinLog, {cArqOri, cLogTmp, nX, "7", cValInc})
			
 		//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		ElseIf !SD1->(DbSeek(IIF (nPosFil == 0, xFilial("SD1"), AVKEY(aItens[nX][nPosFil], "D1_FILIAL"))+AVKEY(aItens[nX][nPosDoc], "D1_DOC")+AVKEY(aItens[nX][nPosSer], "D1_SERIE")+IIF(nPosFor == 0, SA2->A2_COD, AVKEY(aItens[nX][nPosFor], "D1_FORNECE"))+IIF (nPosLoj == 0, SA2->A2_LOJA, AVKEY(aItens[nX][nPosLoj], "D1_LOJA"))))

	 		cValInc := "NOTA FISCAL / SERIE = "+AVKEY(aItens[nX][nPosDoc], "D1_DOC")+" / "+AVKEY(aItens[nX][nPosSer], "D1_SERIE")
			cLogTmp	:= ""
			AEVAL(aItens[nX], {|X| cLogTmp += X+" "})
			AADD(aLinLog, {cArqOri, cLogTmp, nX, "8", cValInc}) //Registro já gravado.

	    //CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_DOCIMP+STR(CD5_ALPIS,5,2)+STR(CD5_ALCOF,5,2)+CD5_NADIC+CD5_ITEM  //CHAVE UNICA	  
	  	//CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_DOCIMP+CD5_NADIC	  
		ElseIf CD5->(DbSeek(IIF (nPosFil == 0, xFilial("CD5"), STRZERO(VAL(aItens[nX][nPosFil]), 4))+AVKEY(aItens[nX][nPosDoc], "CD5_DOC")+AVKEY(aItens[nX][nPosSer], "CD5_SERIE")+IIF(nPosFor == 0, SA2->A2_COD, AVKEY(aItens[nX][nPosFor], "CD5_FORNEC"))+IIF (nPosLoj == 0, SA2->A2_LOJA, AVKEY(aItens[nX][nPosLoj], "CD5_LOJA"))+AVKEY(aItens[nX][nPosDIm], "CD5_DOCIMP")))
  
//	 		cValInc := "RECNO CD5 = "+ALLTRIM(STR(CD5->(RECNO())))
//			cLogTmp	:= ""
//			AEVAL(aItens[nX], {|X| cLogTmp += X+" "})
//			AADD(aLinLog, {cArqOri, cLogTmp, nX, "4", cValInc}) //Registro já gravado.
		
		Else	  						
			
			SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA - Para não dar erro nas validações do ExecAuto
			
			If nPosFor <> 0 .AND. nPosLoj <> 0
				SA2->(DbSeek(xFilial("SA2")+AVKEY(aItens[nX][nPosFor], "A2_COD")+AVKEY(aItens[nX][nPosLoj], "A2_LOJA")))
			EndIf			
			
			While !SD1->(EOF()) .AND. SD1->D1_DOC == AVKEY(aItens[nX][nPosDoc], "D1_DOC") .AND. SD1->D1_SERIE == AVKEY(aItens[nX][nPosSer], "D1_SERIE") .AND. SD1->D1_FORNECE == SA2->A2_COD .AND. SD1->D1_LOJA == SA2->A2_LOJA
			
				aDadosCD5 	:= {}
				lMsErroAuto	:= .F.
				nErrLin		:= 0

				SX3->(DbSetOrder(2))
					
				For nY:=1 To Len(aCab)
					If SX3->(DbSeek(ALLTRIM(aCab[nY])))
						If "CD5_" $ ALLTRIM(aCab[nY])
							If SX3->(GETADVFVAL("SX3", "X3_TIPO", ALLTRIM(aCab[nY]), 2, "C")) == "D"
								AADD(aDadosCD5,	{ALLTRIM(aCab[nY]), CTOD(aItens[nX][nY]), NIL})
								
								If ALLTRIM(aCab[nY]) == "CD5_DOCIMP"
									AADD(aDadosCD5,	{"CD5_NDI", CTOD(aItens[nX][nY]), NIL})
								ElseIf ALLTRIM(aCab[nY]) == "CD5_DTDI"
									AADD(aDadosCD5,	{"CD5_DTPPIS", CTOD(aItens[nX][nY]), NIL})
									AADD(aDadosCD5,	{"CD5_DTPCOF", CTOD(aItens[nX][nY]), NIL})
									AADD(aDadosCD5,	{"CD5_DTDES", CTOD(aItens[nX][nY]), NIL})
								EndIf
							ElseIf SX3->(GETADVFVAL("SX3", "X3_TIPO", ALLTRIM(aCab[nY]), 2, "C")) == "N"
								AADD(aDadosCD5,	{ALLTRIM(aCab[nY]), VAL(STRTRAN(aItens[nX][nY], ",", ".")), NIL})
			
								If ALLTRIM(aCab[nY]) == "CD5_DOCIMP"
									AADD(aDadosCD5,	{"CD5_NDI", VAL(STRTRAN(aItens[nX][nY], ",", ".")), NIL})
								ElseIf ALLTRIM(aCab[nY]) == "CD5_DTDI"
									AADD(aDadosCD5,	{"CD5_DTPPIS", VAL(STRTRAN(aItens[nX][nY], ",", ".")), NIL})
									AADD(aDadosCD5,	{"CD5_DTPCOF", VAL(STRTRAN(aItens[nX][nY], ",", ".")), NIL})
									AADD(aDadosCD5,	{"CD5_DTDES", VAL(STRTRAN(aItens[nX][nY], ",", ".")), NIL})
								EndIf
							Else
								AADD(aDadosCD5,	{ALLTRIM(aCab[nY]), AVKEY(FwNoAccent(aItens[nX][nY]), ALLTRIM(aCab[nY])), NIL})
			
								If ALLTRIM(aCab[nY]) == "CD5_DOCIMP"
									AADD(aDadosCD5,	{"CD5_NDI", AVKEY(FwNoAccent(aItens[nX][nY]), "CD5_NDI"), NIL})
								ElseIf ALLTRIM(aCab[nY]) == "CD5_DTDI"
									AADD(aDadosCD5,	{"CD5_DTPPIS", AVKEY(FwNoAccent(aItens[nX][nY]), "CD5_DTPPIS"), NIL})
									AADD(aDadosCD5,	{"CD5_DTPCOF", AVKEY(FwNoAccent(aItens[nX][nY]), "CD5_DTPCOF"), NIL})
									AADD(aDadosCD5,	{"CD5_DTDES", AVKEY(FwNoAccent(aItens[nX][nY]), "CD5_DTDES"), NIL})
								EndIf
							EndIf
						EndIf
					EndIf
				Next
				
				If nPosFil == 0
					AADD(aDadosCD5, {"CD5_FILIAL"	, xFilial("CD5"), Nil})
				EndIf
	
				If nPosEsp == 0
					AADD(aDadosCD5, {"CD5_ESPEC", "SPED", Nil})
				EndIf
				     			
				If ASCAN(aCab, {|x| ALLTRIM(x) == "CD5_TPIMP"}) == 0
					AADD(aDadosCD5, {"CD5_TPIMP", "0", Nil})
				EndIf
	
				If ASCAN(aCab, {|x| ALLTRIM(x) == "CD5_LOCAL"}) == 0
					AADD(aDadosCD5, {"CD5_LOCAL", "0", Nil})
				EndIf
	
				If ASCAN(aCab, {|x| ALLTRIM(x) == "CD5_LOCDES"}) == 0
					AADD(aDadosCD5, {"CD5_LOCDES", "AEROPORTO INTER. DE GUAR.", Nil})
				EndIf
	
				If ASCAN(aCab, {|x| ALLTRIM(x) == "CD5_UFDES"}) == 0
					AADD(aDadosCD5, {"CD5_UFDES", "SP", Nil})
				EndIf
	
				If ASCAN(aCab, {|x| ALLTRIM(x) == "CD5_NADIC"}) == 0
					AADD(aDadosCD5, {"CD5_NADIC", "1", Nil})
				EndIf
	
				If ASCAN(aCab, {|x| ALLTRIM(x) == "CD5_SQADIC"}) == 0
					AADD(aDadosCD5, {"CD5_SQADIC", "001", Nil})
				EndIf
	
				AADD(aDadosCD5, {"CD5_DOC"		, SD1->D1_DOC		, Nil})
				AADD(aDadosCD5, {"CD5_SERIE"	, SD1->D1_SERIE		, Nil})
				AADD(aDadosCD5, {"CD5_FORNEC"	, SD1->D1_FORNECE	, Nil})
				AADD(aDadosCD5, {"CD5_LOJA"		, SD1->D1_LOJA		, Nil})
				AADD(aDadosCD5, {"CD5_BSPIS"	, SD1->D1_BASEPIS	, Nil})
				AADD(aDadosCD5, {"CD5_ALPIS"	, SD1->D1_ALQPIS	, Nil})
				AADD(aDadosCD5, {"CD5_VLPIS"	, SD1->D1_VALPIS	, Nil})
				AADD(aDadosCD5, {"CD5_BSCOF"	, SD1->D1_BASECOF	, Nil})			
				AADD(aDadosCD5, {"CD5_ALCOF"	, SD1->D1_ALQCOF	, Nil})			
				AADD(aDadosCD5, {"CD5_VLCOF"	, SD1->D1_VALCOF	, Nil})			
				AADD(aDadosCD5, {"CD5_CODEXP"	, SD1->D1_FORNECE	, Nil})
				AADD(aDadosCD5, {"CD5_CODFAB"	, SD1->D1_FORNECE	, Nil})
				AADD(aDadosCD5, {"CD5_ITEM"		, SD1->D1_ITEM		, Nil})
				AADD(aDadosCD5, {"CD5_XIMPOR"	, "S"				, Nil})
				
				AXINCLUI("CD5", NIL, 3,,,,,,,,, aDadosCD5)
	
				If lMsErroAuto
					cErroTemp 	:= MOSTRAERRO(GetSrvProfString("Startpath",""), cNomeArq)
					nLinhas 	:= MLCOUNT(cErroTemp)
					cBuffer 	:= RTRIM(MEMOLINE(cErroTemp,, nErrLin))
								
					While (nErrLin <= nLinhas)
						nErrLin++
				    	cBuffer := ALLTRIM(MEMOLINE(cErroTemp,, nErrLin))
				     	If (UPPER(SUBSTR(cBuffer, LEN(cBuffer)-7, LEN(cBuffer))) == "INVALIDO") 
							cValInc := "ERRO GRAVAÇÃO CD5 = "+ALLTRIM(cBuffer)
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
				//	cLogTmp	:= ""
				//	AEVAL(aItens[nX], {|X| cLogTmp += X+" "})
				//	AADD(aLinLog, {cArqOri, cLogTmp, nX, "1", ""}) //Gravado com Sucesso 
					lRet := .T.
				EndIf
				
				SD1->(DbSkip())
			EndDo
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
/*/{Protheus.doc} CAMBM10P

Parâmetros da Rotina.

@author  Allan Bonfim

@since   29/05/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM10P(aParam, aPergs)

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
		lValid	:= CAMBM10V(aParam, aPergs)
		lRet	:= .T.
	Else
		lValid	:= .T.
		lRet	:= .F.
	EndIf
Enddo

RestArea(aArea)

Return lRet                 

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM10V

Validação dos Parâmetros.

@author  Allan Bonfim

@since   29/05/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM10V(aPar, aPrgs)

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
/*/{Protheus.doc} CAMBM10R

Relatório com o resultado da importação.

@author  Allan Bonfim

@since   11/03/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM10R(aCabec, aDadosLog)

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

oReport  := TReport():New("CAMBM010", "LOG DA IMPORTAÇÃO - COMPLEMENTO DE IMPORTAÇÃO", "", {|oReport| PrintReport(oReport, aDadosLog)}, "Log da Importação do arquivo para a tabela CD5 (Complemento de Importação)")

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
		cDescRet := "Falha na gravação do Complemento de Importação (CD5)."
	Case cTipoLog == "6"
		cDescRet := "Falha na estrutura do arquivo."
	Case cTipoLog == "7"
		cDescRet := "Fornecedor não localizado no cadastro (SA2)."
	Case cTipoLog == "8"
		cDescRet := "Nota Fiscal não localizada (SD1)."		
EndCase

Return cDescRet   