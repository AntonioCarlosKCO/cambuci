#include "TOTVS.CH"
#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM005

Rotina para importação de Notas Fiscais de Entrada.

@author  Caio Garcia

@since   17/07/2015

@version P11
 
@param

@obs 	17/07/2015 - Caio Garcia - Desenvolvimento da rotina   
@obs 	05/09/2015 - Allan Bonfim - Inclusão do Layout para importação.

@return

/*/
//-------------------------------------------------------------------
User Function CAMBM005()

Local aArea	   		:= GetArea()
Local aSays 		:= {}
Local aButtons		:= {}
Local nOpca			:= 0
Local cTmpPath		:= GetTempPath(.T.)
Local cNomeArq		:= "NFE_ENTRADA.XLS"
Local cLayout		:= cTmpPath+cNomeArq

Private cCadastro	:= "Importação Notas Fiscais de Entrada"
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

AADD(aSays, OemToAnsi("Esta função tem o objetivo de importar as Notas Fiscais de Entrada informadas no arquivo para o sistema"))
AADD(aSays, OemToAnsi("Protheus - Tabela (SD1, SF1)"))
AADD(aSays, OemToAnsi("Os arquivos TXT e CSV deverão ter a primeira linha com o cabeçalho contendo o nome"))
AADD(aSays, OemToAnsi("dos campos e as demais linhas com os valores, separados por ; ."))    
AADD(aSays, OemToAnsi(""))

If File(cLayout)
	AADD(aButtons, {14,.T.,{|| nOpca := 0, SHELLEXECUTE("Open", cLayout, " /k dir", "C:\", 1 ), FECHABATCH()}})
EndIf

AADD(aButtons, {1,.T.,{|| nOpca := IIf(CAMBM05P(@aParam, @aPergs), 1, 0), FECHABATCH()}})
AADD(aButtons, {2,.T.,{|| nOpca := 0, FECHABATCH()}})

FormBatch(cCadastro, aSays, aButtons)

If nOpca == 1
	If MSGYESNO("Confirma a importação dos arquivos do diretório selecionado ?", cCadastro)
		//FWMsgRun(, {|| CAMBM05I()}, "Importando os Arquivos... Aguarde...")
		oProcess := MsNewProcess():New({ |lFim| CAMBM05I(@lFim)}, "Importação de NFe de Entrada", "Processando...", .T. )
		oProcess:Activate()			
	EndIf
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM05I

Rotina para importação das Notas Fiscais de Entrada

@author  Allan Bonfim

@since   15/06/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM05I(lFim)

Local aArea	   		:= GetArea()
Local cPstSrv		:= ALLTRIM(SUPERGETMV("CB_XPSTNFE", ,"\IMPORTACAO\NFE\NFE\"))
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
				If CAMBM05A(cPstSrv+cNomArq, cPathArq)					
					Begin Transaction
						If !CAMBM05G(aCabec, aLinhas, cPathArq)
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
	FWMsgRun(, {|| CAMBM05R(aCabec, aLinLog)}, "Gerando o Log da Importação... Aguarde...") 
EndIf

MSGINFO ("A importação dos arquivos do diretório "+UPPER(ALLTRIM(aParam[2]))+" foi finalizada.", cCadastro)


RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM05A

Função para abertura do arquivo.

@author  Allan Bonfim

@since   15/06/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static function CAMBM05A(cArqImp, cArqOri)

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
Local nLinha	:= 0
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
				nLinha++
				If "F1_" $ xBuffer
             		aCabec	:= WFTokenChar(UPPER(xBuffer), ";")
             		AADD(aCabec, "LINHA")
             	Else
             		If !EMPTY(STRTRAN(xBuffer, ";", ""))
				    	aLinTmp := WFTokenChar(UPPER(xBuffer), ";")
				    	AADD(aLinTmp, nLinha)
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
	If ASCAN(aCabec, {|x| ALLTRIM(x) == "F1_DOC"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "F1_SERIE"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "F1_FORNECE"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "F1_LOJA"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "D1_COD"}) == 0 .OR. ASCAN(aCabec, {|x| ALLTRIM(x) == "D1_CF"}) == 0 .OR. LEN(aLinhas) == 0
		AADD(aLinLog, {cArqOri, "", 0, "6", cValInc}) //Erro na estrutura do arquivo.
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)
 
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM05G

Função para gravação dos dados do arquivo.

@author  Allan Bonfim

@since   29/05/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static function CAMBM05G(aCab, aItens, cArqOri)

Local aArea			:= GetArea()
Local nX			:= 0
Local nY			:= 0
Local nPosNfe 		:= 0
Local nPosSer		:= 0
Local nPosFor		:= 0
Local nPosLoj		:= 0
Local nPosCod		:= 0
Local nPosCfo		:= 0
Local nPosIcm		:= 0
Local nPosISt		:= 0
Local nPosIpi		:= 0
//Local nPosDtD		:= 0
//Local nPosDtE		:= 0
Local nPosLin		:= 0
Local lIcms			:= .F.
Local lIcmST		:= .F.
Local lIpi			:= .F.
Local lRet			:= .F.
Local cLogTmp		:= ""
Local cValInc		:= ""    
Local cNomeArq		:= "LOG_"+ALLTRIM(STR(ALEATORIO(999999, VAL(SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)+SUBSTR(TIME(), 7, 2)))))+".log"
Local cBuffer		:= ""
Local nErrLin		:= 1 
Local nLinhas		:= 0
Local cErroTemp		:= ""
Local aDadosSF1		:= {}
Local aDadosSD1		:= {} 
Local aDadosTMP		:= {} 
Local aTipoNf		:= {}
Local cNumNfe 		:= ""
Local cSerNfe		:= ""
Local cCodFor		:= ""
Local cLojaFor		:= ""
Local cTipoFor		:= ""
Local lGravaNf		:= .T.
Local cFilImp		:= ""
Local cCodProd		:= ""
//Local dDtAtual		:= dDataBase
Local lFlag         := .F.

Private lMsHelpAuto	:= .F.
Private lMsErroAuto := .F.
  	 					
Default aCab		:= {}
Default aItens		:= {}
Default cArqOri		:= ""

If Len(aCab) > 0 .AND. Len(aItens) > 0

	nPosNfe 	:= ASCAN(aCab, {|x| ALLTRIM(x) == "F1_DOC"})
	nPosSer		:= ASCAN(aCab, {|x| ALLTRIM(x) == "F1_SERIE"})
	nPosFor		:= ASCAN(aCab, {|x| ALLTRIM(x) == "F1_FORNECE"})
	nPosLoj		:= ASCAN(aCab, {|x| ALLTRIM(x) == "F1_LOJA"})
	nPosCod		:= ASCAN(aCab, {|x| ALLTRIM(x) == "D1_COD"})
	nPosCfo		:= ASCAN(aCab, {|x| ALLTRIM(x) == "D1_CF"})
	nPosFil		:= ASCAN(aCab, {|x| ALLTRIM(x) == "F1_FILIAL"})
	nPosIcm		:= ASCAN(aCab, {|x| ALLTRIM(x) == "D1_VALICM"})
	nPosISt		:= ASCAN(aCab, {|x| ALLTRIM(x) == "D1_ICMSRET"})
	nPosIpi		:= ASCAN(aCab, {|x| ALLTRIM(x) == "D1_VALIPI"})
//	nPosDtD		:= ASCAN(aCab, {|x| ALLTRIM(x) == "F1_DTDIGIT"})
//	nPosDtE		:= ASCAN(aCab, {|x| ALLTRIM(x) == "F1_EMISSAO"})
	nPosLin		:= ASCAN(aCab, {|x| ALLTRIM(x) == "LINHA"})

	DbSelectArea("SF1")
	SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_FORMUL CHAVE UNICA
		
	DbSelectArea("SD1")
	SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM+D1_FORMUL+D1_ITEMGRD CHAVE UNICA
    
	If nPosFil == 0
		cFilImp := xFilial("SF1")
	Else
		cFilImp := STRZERO(VAL(aItens[nX][nPosFil]), 4)
	EndIf

	If nPosFil > 0
		ASORT(aItens,,, {|x,y| x[nPosFil]+x[nPosFor]+x[nPosLoj]+x[nPosNfe]+x[nPosSer]+x[nPosCod] < y[nPosFil]+y[nPosFor]+y[nPosLoj]+y[nPosNfe]+y[nPosSer]+y[nPosCod]})	
	Else
		ASORT(aItens,,, {|x,y| x[nPosFor]+x[nPosLoj]+x[nPosNfe]+x[nPosSer]+x[nPosCod] < y[nPosFor]+y[nPosLoj]+y[nPosNfe]+y[nPosSer]+y[nPosCod]})
	EndIf
		 			
	//Inicializar
	cNumNfe := aItens[1][nPosNfe]
	cSerNfe := aItens[1][nPosSer]

	oProcess:SetRegua2(Len(aItens))
					
	For nX:=1 To Len(aItens)

		oProcess:Incregua2("Gravando o Item "+STRZERO(nX, 5)+" de "+STRZERO(Len(aItens), 5))

		If EMPTY(aItens[nX][nPosNfe]) .OR. EMPTY(aItens[nX][nPosFor]) .OR. EMPTY(aItens[nX][nPosLoj]) .OR. EMPTY(aItens[nX][nPosCod]) .OR. EMPTY(aItens[nX][nPosCfo])
                  
			cValInc		:= ""
			cLogTmp		:= ""
			cCodProd	:= ""
			
			AEVAL(aItens[nX], {|X| cLogTmp += X+" "}, 1, LEN(aItens[nX])-1)

			If EMPTY(aItens[nX][nPosNfe])
				If !EMPTY(cValInc)
					cValInc += ", "
				EndIf

				cValInc += aCab[nPosNfe]
			EndIf
/*			
			If EMPTY(aItens[nX][nPosSer])
				If !EMPTY(cValInc)
					cValInc += ", "
				EndIf
			
				cValInc += aCab[nPosSer]
			EndIf
  */
			If EMPTY(aItens[nX][nPosFor])
				If !EMPTY(cValInc)
					cValInc += ", "
				EndIf
			
				cValInc += aCab[nPosFor]
			EndIf

			If EMPTY(aItens[nX][nPosLoj])
				If !EMPTY(cValInc)
					cValInc += ", "
				EndIf
			
				cValInc += aCab[nPosLoj]
			EndIf


			If EMPTY(aItens[nX][nPosCod])
				If !EMPTY(cValInc)
					cValInc += ", "
				EndIf
			
				cValInc += aCab[nPosCod]
			EndIf

			If EMPTY(aItens[nX][nPosCfo])
				If !EMPTY(cValInc)
					cValInc += ", "
				EndIf
			
				cValInc += aCab[nPosCfo]
			EndIf
								
			If !EMPTY(cValInc)
				cValInc += " não preenchido ou conteúdo inválido."
			EndIf
		
			AADD(aLinLog, {cArqOri, cLogTmp, aItens[nX][nPosLin], "3", cValInc})
	
		ElseIf SF1->(DbSeek(cFilImp+AVKEY(aItens[nX][nPosNfe], "F1_DOC")+AVKEY(aItens[nX][nPosSer], "F1_SERIE")+AVKEY(aItens[nX][nPosFor], "F1_FORNECE")+AVKEY(aItens[nX][nPosLoj], "F1_LOJA"))) 
		  
	 		//cValInc := ALLTRIM(STR(SF1->(RECNO())))
			//cLogTmp	:= "RECNO SF1"
			//AEVAL(aItens[nX], {|X| cLogTmp += X+" "}, 1, LEN(aItens[nX])-1)
			//AADD(aLinLog, {cArqOri, cLogTmp, aItens[nX][nPosLin], "4", cValInc}) //Registro já gravado.

/*		ElseIf SD1->(DbSeek(IIF (nPosFil == 0, xFilial("SD1"), STRZERO(VAL(aItens[nX][nPosFil]), 4))+AVKEY(aItens[nX][nPosNfe], "D1_DOC")+AVKEY(aItens[nX][nPosSer], "D1_SERIE")+AVKEY(aItens[nX][nPosFor], "D1_FORNECE")+AVKEY(aItens[nX][nPosLoj], "D1_LOJA")+AVKEY(aItens[nX][nPosCod], "D1_COD")))
		  
	 		cValInc := "RECNO SD1 = "+ALLTRIM(STR(SD1->(RECNO())))
			cLogTmp	:= ""
			AEVAL(aItens[nX], {|X| cLogTmp += X+" "}, 1, LEN(aItens[nX])-1)
			AADD(aLinLog, {cArqOri, cLogTmp, aItens[nX][nPosLin], "4", cValInc}) //Registro já gravado.
*/
		Else	  						

			If cNumNfe <> aItens[nX][nPosNfe] .OR. cSerNfe <> aItens[nX][nPosSer]
				If Len(aDadosSF1) > 0 .AND. LEN(aDadosSD1) > 0				
					If lGravaNf
						//Altera a data base do sistema para a data de emissao da nota fiscal						
//						If nPosDtD > 0
//							dDataBase := CTOD(aItens[nX][nPosDtD])
//						ElseIf nPosDtE > 0
//							dDataBase := CTOD(aItens[nX][nPosDtE])
//						EndIf
						
						MSExecAuto({|X,Y| MATA103(X,Y)}, aDadosSF1, aDadosSD1, 3)
			
						If lMsErroAuto
							cErroTemp 	:= MOSTRAERRO(GetSrvProfString("Startpath",""), cNomeArq)
							nLinhas 	:= MLCOUNT(cErroTemp)
							cBuffer 	:= RTRIM(MEMOLINE(cErroTemp,, nErrLin))
										
							While (nErrLin <= nLinhas)
								nErrLin++
						    	cBuffer := ALLTRIM(MEMOLINE(cErroTemp,, nErrLin))
						     	If (UPPER(SUBSTR(cBuffer, LEN(cBuffer)-7, LEN(cBuffer))) == "INVALIDO") 
									cValInc := ALLTRIM(cBuffer)
									//Exit
						    	EndIf 
							EndDo
							
							If EMPTY(cValInc)
								nErrLin := 0
								While (nErrLin <= 5)
									nErrLin++
							    	cBuffer := ALLTRIM(MEMOLINE(cErroTemp,, nErrLin))
									cValInc += ALLTRIM(cBuffer)
								EndDo
							EndIf
									
							If File(GetSrvProfString("Startpath","")+cNomeArq)
								FERASE(GetSrvProfString("Startpath","")+cNomeArq)
							EndIf
			
							cLogTmp	:= "NOTA FISCAL "+ALLTRIM(cNumNfe)+" | SERIE "+ALLTRIM(cSerNfe)+" | FORNECEDOR "+ALLTRIM(cCodFor)+" | LOJA "+ALLTRIM(cLojaFor)
							//AEVAL(aItens[nX], {|X| cLogTmp += X+" "}, 1, LEN(aItens[nX])-1)
							
							AADD(aLinLog, {cArqOri, cLogTmp, aItens[nX][nPosLin], "5", cValInc})
						Else
							lRet := .T.			
							ATUANFE(aDadosSD1)
			//				cLogTmp	:= ""
			//				AEVAL(aItens[nX], {|X| cLogTmp += X+" "}, 1, LEN(aItens[nX])-1)
			//				AADD(aLinLog, {cArqOri, cLogTmp, aItens[nX][nPosLin], "1", ""}) //Gravado com Sucesso
						EndIf
					EndIf
//				Else
				
//					cLogTmp	:= ""
					
//					AEVAL(aItens[nX], {|X| cLogTmp += X+" "}, 1, LEN(aItens[nX])-1)
//					AADD(aLinLog, {cArqOri, cLogTmp, aItens[nX][nPosLin], "2"})

		        EndIf
						
				cNumNfe := aItens[nX][nPosNfe]
				cSerNfe := aItens[nX][nPosSer]
			
				aDadosSF1 	:= {}
				aDadosSD1 	:= {}
				aDadosTMP 	:= {}				
				lMsErroAuto	:= .F.
				nErrLin		:= 0
				lGravaNf	:= .T.
			EndIf

			aTipoNf := VERTIPNF(aItens[nX][nPosCfo])
            cCFOP   := ALLTRIM(aItens[nX][nPosCfo])                  
                                    			
   			If aTipoNf[1] == "N"
				If AllTrim(cCFOP) == "1949" .or. AllTrim(cCFOP) == "2949" .or. AllTrim(cCFOP) == "1915" .or. AllTrim(cCFOP) == "2915" .or. AllTrim(cCFOP) == "2603" //.or. AllTrim(cCFOP) == "2411" .or. AllTrim(cCFOP) == "1202" .or. AllTrim(cCFOP) == "2202"
					DbSelectArea("SA1")
					SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

					If SA1->(DbSeek(xFilial("SA1")+AVKEY(aItens[nX][nPosFor], "A1_COD")+AVKEY(aItens[nX][nPosLoj], "A1_LOJA")))
						cCodFor 	:= SA1->A1_COD
						cLojaFor	:= SA1->A1_LOJA
						cTipoFor 	:= "R" //SA1->A1_TIPO
					    lFlag       := .T.
					    aTipoNf[1]  := "D"
					Else
						DbSelectArea("SA2")
						SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA

						If SA2->(DbSeek(xFilial("SA2")+AVKEY(aItens[nX][nPosFor], "A2_COD")+AVKEY(aItens[nX][nPosLoj], "A2_LOJA")))
							cCodFor 	:= SA2->A2_COD
							cLojaFor	:= SA2->A2_LOJA
							cTipoFor 	:= SA2->A2_TIPO
						Else
							lGravaNf 	:= .F.

							cLogTmp := "FORNECEDOR NÃO CADASTRADO
	   						cValInc	:= "CODIGO ("+ALLTRIM(aItens[nX][nPosFor])+") - LOJA ("+ALLTRIM(aItens[nX][nPosLoj])+")"
							AADD(aLinLog, {cArqOri, cLogTmp, aItens[nX][nPosLin], "3", cValInc})
						EndIf
					EndIf                
                Else
					DbSelectArea("SA2")
					SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA

					If SA2->(DbSeek(xFilial("SA2")+AVKEY(aItens[nX][nPosFor], "A2_COD")+AVKEY(aItens[nX][nPosLoj], "A2_LOJA")))
						cCodFor 	:= SA2->A2_COD
						cLojaFor	:= SA2->A2_LOJA
						cTipoFor 	:= SA2->A2_TIPO
					Else
						lGravaNf 	:= .F.

						cLogTmp := "FORNECEDOR NÃO CADASTRADO
	   					cValInc	:= "CODIGO ("+ALLTRIM(aItens[nX][nPosFor])+") - LOJA ("+ALLTRIM(aItens[nX][nPosLoj])+")"
						AADD(aLinLog, {cArqOri, cLogTmp, aItens[nX][nPosLin], "3", cValInc})
					EndIf
				Endif						                
    		ElseIf aTipoNf[1] == "D"
				DbSelectArea("SA1")
				SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

				If SA1->(DbSeek(xFilial("SA1")+AVKEY(aItens[nX][nPosFor], "A1_COD")+AVKEY(aItens[nX][nPosLoj], "A1_LOJA")))
					cCodFor 	:= SA1->A1_COD
					cLojaFor	:= SA1->A1_LOJA
					cTipoFor 	:= "R" //SA1->A1_TIPO
				Else
					lGravaNf 	:= .F.
					
					cLogTmp := "CLIENTE NÃO CADASTRADO
		   			cValInc	:= "CODIGO ("+ALLTRIM(aItens[nX][nPosFor])+") - LOJA ("+ALLTRIM(aItens[nX][nPosLoj])+")"
					AADD(aLinLog, {cArqOri, cLogTmp, aItens[nX][nPosLin], "3", cValInc})
				EndIf                
			EndIf
			
			
			DbSelectArea("SB1") 
			SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD 
			
			If !SB1->(DbSeek(xFilial("SB1")+AVKEY(aItens[nX][nPosCod], "B1_COD")))  
				lGravaNf 	:= .F.
					
	   			cValInc := "PRODUTO ("+ALLTRIM(aItens[nX][nPosCod])+")"
	   			cLogTmp	:= "PRODUTO NÃO ENCONTRADO NO CADASTRO"
				AADD(aLinLog, {cArqOri, cLogTmp, aItens[nX][nPosLin], "3", cValInc})
				cCodProd := AVKEY(aItens[nX][nPosCod], "B1_COD")
			Else
				CodProd := SB1->B1_COD 
			EndIf

			SX3->(DbSetOrder(2))
	
			For nY:=1 To Len(aCab)
				If SX3->(DbSeek(ALLTRIM(aCab[nY])))
					If SX3->(GETADVFVAL("SX3", "X3_TIPO", ALLTRIM(aCab[nY]), 2, "C")) == "D"
						If "F1_" $ ALLTRIM(aCab[nY])						
							If ASCAN(aDadosSF1, {|x| ALLTRIM(x) == ALLTRIM(aCab[nY])}) == 0
								AADD(aDadosSF1,	{ALLTRIM(aCab[nY]), CTOD(aItens[nX][nY]), NIL})
							EndIf						
						ElseIf "D1_" $ ALLTRIM(aCab[nY])
							AADD(aDadosTMP,	{ALLTRIM(aCab[nY]), CTOD(aItens[nX][nY]), NIL})
						EndIf
					ElseIf SX3->(GETADVFVAL("SX3", "X3_TIPO", ALLTRIM(aCab[nY]), 2, "C")) == "N"
						If "F1_" $ ALLTRIM(aCab[nY])
							If ASCAN(aDadosSF1, {|x| ALLTRIM(x) == ALLTRIM(aCab[nY])}) == 0
								AADD(aDadosSF1,	{ALLTRIM(aCab[nY]), VAL(STRTRAN(aItens[nX][nY], ",", ".")), NIL})
							EndIf
						ElseIf "D1_" $ ALLTRIM(aCab[nY])
							AADD(aDadosTMP,	{ALLTRIM(aCab[nY]), VAL(STRTRAN(aItens[nX][nY], ",", ".")), NIL})
						EndIf
					Else
						If "F1_" $ ALLTRIM(aCab[nY])
							If ASCAN(aDadosSF1, {|x| ALLTRIM(x) == ALLTRIM(aCab[nY])}) == 0
								AADD(aDadosSF1,	{ALLTRIM(aCab[nY]), AVKEY(FwNoAccent(aItens[nX][nY]), ALLTRIM(aCab[nY])), NIL})
							EndIf
						ElseIf "D1_" $ ALLTRIM(aCab[nY])
							AADD(aDadosTMP,	{ALLTRIM(aCab[nY]), AVKEY(FwNoAccent(aItens[nX][nY]), ALLTRIM(aCab[nY])), NIL})
						EndIf
					EndIf
				EndIf
			Next
			
			If ASCAN(aDadosSF1, {|x| ALLTRIM(x) == "F1_TIPO"}) == 0
				AADD(aDadosSF1, {"F1_TIPO"   , aTipoNf[1], Nil})
				AADD(aDadosSF1, {"F1_FORMUL" , aTipoNf[2], Nil})
			EndIf

			If ASCAN(aDadosSF1, {|x| ALLTRIM(x) == "F1_ESPECIE"}) == 0
				AADD(aDadosSF1, {"F1_ESPECIE"   , "SPED", Nil})
			EndIf	
			
			If ASCAN(aDadosSF1, {|x| ALLTRIM(x) == "F1_COND"}) == 0
				AADD(aDadosSF1, {"F1_COND"   , "001", Nil})
			EndIf
			
			If ASCAN(aDadosSF1, {|x| ALLTRIM(x) == "F1_FILIAL"}) == 0
				AADD(aDadosSF1, {"F1_FILIAL", cFilImp, Nil})
			EndIf
				
			If ASCAN(aDadosSF1, {|x| ALLTRIM(x) == "D1_FILIAL"}) == 0
				AADD(aDadosTMP, {"D1_FILIAL", cFilImp, Nil})
			EndIf

			If aTipoNf[1] == "D"
				AADD(aDadosTMP, {"D1_NFORI", "IMPORTACA", Nil})
				AADD(aDadosTMP, {"D1_SERIORI", "O", Nil})				
			EndIf
			
			If nPosIcm > 0
				If VAL(aItens[nX][nPosIcm]) > 0
					lIcms := .T.
				Else
					lIcms := .F.
				EndIf
			Else
				lIcms := .F.
			EndIf

			If nPosISt > 0
				If VAL(aItens[nX][nPosISt]) > 0
					lIcmST := .T.
				Else
					lIcmST := .F.
				EndIf
			Else
				lIcmST := .F.
			EndIf

			If nPosIpi > 0
				If VAL(aItens[nX][nPosIpi]) > 0
					lIpi := .T.
				Else
					lIpi := .F.
				EndIf
			Else
				lIpi := .F.
			EndIf

			If lFlag
				cCodTes := U_BUTESIMP(aItens[nX][nPosCfo], "1" , /*SB1->B1_ORIGEM*/, /*SB1->B1_POSIPI*/, /*cTipoFor*/, lIcms, lIpi, lIcmST, SB1->B1_COD, AVKEY(aItens[nX][nPosFor], "A1_COD"), AVKEY(aItens[nX][nPosLoj], "A1_LOJA"))			
			Else
				cCodTes := U_BUTESIMP(aItens[nX][nPosCfo], IIF(aTipoNf[1] == "N", "1", "3"), /*SB1->B1_ORIGEM*/, /*SB1->B1_POSIPI*/, /*cTipoFor*/, lIcms, lIpi, lIcmST, SB1->B1_COD, AVKEY(aItens[nX][nPosFor], "A2_COD"), AVKEY(aItens[nX][nPosLoj], "A2_LOJA"))
			Endif
			
			If EMPTY(cCodTes)
				lGravaNf 	:= .F.
					
	   			cValInc := "CFOP = "+ALLTRIM(aItens[nX][nPosCfo])+ " | TIPO = "+IIF(aTipoNf[1] == "N", "1", "3")+" | ORIGEM = "+SB1->B1_ORIGEM+" | ICMS = "+IIF (lIcms, "SIM", "NAO")+" | ICMS ST = "+IIF (lIcmST, "SIM", "NAO")+" | IPI = "+IIF (lIpi, "SIM", "NAO")
	   			//cLogTmp	:= "NOTA = "+ALLTRIM(aItens[nX][nPosNfe])+" SERIE = "+ALLTRIM(aItens[nX][nPosSer])+" FORNECEDOR = "+ALLTRIM(aItens[nX][nPosFor])+" LOJA = "+ALLTRIM(aItens[nX][nPosLoj])+" PRODUTO = "+ALLTRIM(SB1->B1_COD)
	   			//cLogTmp := "TES NÃO ENCONTRADO"
				cLogTmp	:= "NOTA FISCAL "+ALLTRIM(cNumNfe)+" | SERIE "+ALLTRIM(cSerNfe)+" | FORNECEDOR "+ALLTRIM(cCodFor)+" | LOJA "+ALLTRIM(cLojaFor)+" | PRODUTO = "+ALLTRIM(cCodProd)
				AADD(aLinLog, {cArqOri, cLogTmp, aItens[nX][nPosLin], "3", cValInc})
				//Exit
			Else
				AADD(aDadosTMP, {"D1_TES", cCodTes, Nil})
			EndIf
			 
			cCodTes := ""
			
			If ASCAN(aDadosSF1, {|x| ALLTRIM(x) == "F1_XIMPORT"}) == 0
				AADD(aDadosSF1, {"F1_XIMPORT", "S", Nil})
			EndIf
			
			AADD(aDadosTMP, {"D1_XIMPORT", "S", Nil})
			
			//Correção do valor unitário para evitar erro do total diferente da quantidade x valor unitario
			If aDadosTMP[ASCAN(aDadosTMP, {|x| ALLTRIM(x[1]) == "D1_QUANT"})][2] * aDadosTMP[ASCAN(aDadosTMP, {|x| ALLTRIM(x[1]) == "D1_VUNIT"})][2] == aDadosTMP[ASCAN(aDadosTMP, {|x| ALLTRIM(x[1]) == "D1_TOTAL"})][2]
				AADD(aDadosSD1, aDadosTMP)
			Else
				aDadosTMP[ASCAN(aDadosTMP, {|x| ALLTRIM(x[1]) == "D1_VUNIT"})][2] := aDadosTMP[ASCAN(aDadosTMP, {|x| ALLTRIM(x[1]) == "D1_TOTAL"})][2] / aDadosTMP[ASCAN(aDadosTMP, {|x| ALLTRIM(x[1]) == "D1_QUANT"})][2]
				AADD(aDadosSD1, aDadosTMP) 
			EndIf
			
			aDadosTMP := {}
			
			If Len(aDadosSF1) > 0 .AND. LEN(aDadosSD1) > 0 .AND. nX == Len(aItens) //Gravar Ultimo Item
				If lGravaNf
					//Altera a data base do sistema para a data de emissao da nota fiscal						
//					If nPosDtD > 0
//						dDataBase := CTOD(aItens[nX][nPosDtD])
//					ElseIf nPosDtE > 0
//						dDataBase := CTOD(aItens[nX][nPosDtE])
//					EndIf

					MSExecAuto({|X,Y| MATA103(X,Y)}, aDadosSF1, aDadosSD1, 3)
		
					If lMsErroAuto
						cErroTemp 	:= MOSTRAERRO(GetSrvProfString("Startpath",""), cNomeArq)
						nLinhas 	:= MLCOUNT(cErroTemp)
						cBuffer 	:= RTRIM(MEMOLINE(cErroTemp,, nErrLin))
									
						While (nErrLin <= nLinhas)
							nErrLin++
					    	cBuffer := ALLTRIM(MEMOLINE(cErroTemp,, nErrLin))
					     	If (UPPER(SUBSTR(cBuffer, LEN(cBuffer)-7, LEN(cBuffer))) == "INVALIDO") 
								cValInc := ALLTRIM(cBuffer)
								//Exit									
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
		
						//cLogTmp	:= "ERRO GRAVAÇÃO NF ENTRADA"
						cLogTmp	:= "NOTA FISCAL "+ALLTRIM(cNumNfe)+" | SERIE "+ALLTRIM(cSerNfe)+" | FORNECEDOR "+ALLTRIM(cCodFor)+" | LOJA "+ALLTRIM(cLojaFor)						
						//AEVAL(aItens[nX], {|X| cLogTmp += X+" "}, 1, LEN(aItens[nX])-1)
						AADD(aLinLog, {cArqOri, cLogTmp, aItens[nX][nPosLin], "5", cValInc})
					Else
						lRet := .T.
						ATUANFE(aDadosSD1)
		//				cLogTmp	:= ""
		//				AEVAL(aItens[nX], {|X| cLogTmp += X+" "}, 1, LEN(aItens[nX])-1)
		//				AADD(aLinLog, {cArqOri, cLogTmp, aItens[nX][nPosLin], "1", ""}) //Gravado com Sucesso
					EndIf					
				EndIf
//			Else
			
//				cLogTmp	:= ""
				
//				AEVAL(aItens[nX], {|X| cLogTmp += X+" "}, 1, LEN(aItens[nX])-1)
//				AADD(aLinLog, {cArqOri, cLogTmp, aItens[nX][nPosLin], "2"})

			EndIf			
		EndIf
	Next

Else

	aLogTmp := ARRAY(3)
	cLogTmp	:= ""
	AADD(aLinLog, {cArqOri, cLogTmp, 0, "2", ""}) 

EndIf

//If ASCAN(aLinLog, {|x| x[LEN(aLinLog[1])] == "1", ""}) > 0 //Gravado com sucesso
//	lRet := .T.
//EndIf

//Restaura a Database do sistema
//dDataBase := dDtAtual


RestArea(aArea)
 
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM05P

Parâmetros da Rotina.

@author  Allan Bonfim

@since   29/05/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM05P(aParam, aPergs)

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
		lValid	:= CAMBM05V(aParam, aPergs)
		lRet	:= .T.
	Else
		lValid	:= .T.
		lRet	:= .F.
	EndIf
Enddo

RestArea(aArea)

Return lRet                 

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM05V

Validação dos Parâmetros.

@author  Allan Bonfim

@since   29/05/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM05V(aPar, aPrgs)

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
/*/{Protheus.doc} CAMBM05R

Relatório com o resultado da importação.

@author  Allan Bonfim

@since   11/03/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM05R(aCabec, aDadosLog)

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

oReport  := TReport():New("CAMBM005", "LOG DA IMPORTAÇÃO - NFE DE ENTRADA", "", {|oReport| PrintReport(oReport, aDadosLog)}, "Log da Importação do arquivo para a Nota Fiscal de Entrada")

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

TRCell():New(oSection2, "ITEM"		, "   ", "ITEM"		, "@!"	, 015, .F., {|| STRZERO(aDadosLog[nX][3],4)},, .T.)
TRCell():New(oSection2, "LINHA"		, "   ", "LINHA"	, "@!"	, 500, .F., {|| ALLTRIM(aDadosLog[nX][2])},, .T.)
TRCell():New(oSection2, "LOG"		, "   ", "LOG"		, "@!"	, 100, .F., {|| DESCLOG(aDadosLog[nX][4])},, .T.)  
TRCell():New(oSection2, "DETALHE"	, "   ", "DETALHE"	, "@!"	, 200, .F., {|| ALLTRIM(aDadosLog[nX][5])},, .T.)  
			
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
		cDescRet := "Falha na gravação da Nota Fiscal de Entrada."
	Case cTipoLog == "6"
		cDescRet := "Falha na estrutura do arquivo."
		
EndCase

Return cDescRet  

//-------------------------------------------------------------------
/*/{Protheus.doc} VERTIPNF

Descrição do Log.

@author  Allan Bonfim

@since   13/03/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function VERTIPNF(cCodCfop)

Local aTipoNf 	:= {}

Default cCodCfop:= ""

DbSelectArea("ZZI") //incluido 11/11/15 - josmar

If ALLTRIM(GETADVFVAL("ZZI", "ZZI_OPERAC", xFilial("ZZI")+AVKEY(cCodCfop, "ZZI_X_CFOP"),1)) == "3"
	AADD(aTipoNf, "D")
Else
	AADD(aTipoNf, "N")
EndIf

AADD(aTipoNf, "N")

Return aTipoNf                                  


//-------------------------------------------------------------------
/*/{Protheus.doc} VERTIPNF

Descrição do Log.

@author  Allan Bonfim

@since   13/03/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function ATUANFE(_aNota)

Local _aD1 		:= {}
Local _nPro  	:= 0
Local _nImp1 	:= 0
Local _nImp2 	:= 0
Local _nImp3 	:= 0
Local _nImp4 	:= 0
Local _nImp5 	:= 0
Local _DtDigit      
Local _dDigit
Local _cTipo    := ""
Local _cIDF3    := ""
Local _nTotIPI 	:= 0
Local _nTotICM 	:= 0
Local _nTotPIS 	:= 0
Local _nTotCOF 	:= 0
Local _nTotRIC 	:= 0
Local _nPicms   := 0
Local _nIcms    := 0

For _nx := 1 To Len(_aNota[1])	
	Aadd(_aD1, {AllTrim(_aNota[1,_nx,1])})	
Next _nx

_nCfo 	:= AsCan(_aD1,{|X|X[1]== "D1_CF"})
_nPro  	:= AsCan(_aD1,{|X|X[1]== "D1_COD"})
_nImp1 	:= AsCan(_aD1,{|X|X[1]== "D1_VALIPI"})
_nImp2 	:= AsCan(_aD1,{|X|X[1]== "D1_VALICM"})
_nImp3 	:= AsCan(_aD1,{|X|X[1]== "D1_ICMSRET"}) 
_nImp4 	:= AsCan(_aD1,{|X|X[1]== "D1_VALPIS"})  
_nImp5 	:= AsCan(_aD1,{|X|X[1]== "D1_VALCOF"})
_dDigit := AsCan(_aD1,{|X|X[1]== "D1_DTDIGIT"})
_nPicms := AsCan(_aD1,{|X|X[1]== "D1_PICM"})
           
For _nx := 1 To Len(_aNota)	
	DbSelectArea("SD1")                      
	SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM

	If DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+Padr(_aNota[_nx,_nPro,2],TAMSX3("D1_COD")[1])+StrZero(_nx,4))
			
		RecLock("SD1", .F.)		
			SD1->D1_CF     	:= _aNota[_nx,_nCfo,2]
			SD1->D1_VALIPI	:= _aNota[_nx,_nImp1,2]
			SD1->D1_VALICM	:= _aNota[_nx,_nImp2,2]
			SD1->D1_ICMSRET	:= _aNota[_nx,_nImp3,2]
			SD1->D1_VALPIS	:= _aNota[_nx,_nImp4,2]
			SD1->D1_VALCOF	:= _aNota[_nx,_nImp5,2]
			SD1->D1_DTDIGIT	:= _aNota[_nx,_dDigit,2]
			SD1->D1_PICM	:= _aNota[_nx,_nPicms,2]
			SD1->D1_XIMPORT	:= "S"			
		SD1->(MsUnLock())
		
		_DtDigit := _aNota[_nx,_dDigit,2]
		_nTotIPI += _aNota[_nx,_nImp1,2]
		_nTotICM += _aNota[_nx,_nImp2,2]
		_nTotPIS += _aNota[_nx,_nImp4,2]
		_nTotCOF += _aNota[_nx,_nImp5,2]
		_nTotRIC += _aNota[_nx,_nImp3,2]
		_nIcms   := _aNota[_nx,_nPicms,2]
		
		//GRAVAR NO SFT AQUÍ
		DbSelectArea("SFT")
		SFT->(DbSetOrder(1)) //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
		If SFT->(DbSeek(xFilial("SFT")+AVKEY("E", "FT_TIPOMOV")+SD1->D1_SERIE+SD1->D1_DOC+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM+SD1->D1_COD))  
			RecLock("SFT", .F.)
			SFT->FT_ALIQICM := _nIcms
			SFT->(MsUnlock())
		Endif
		_cIDF3 := SFT->FT_IDENTF3
		
		//GRAVAR NO SF3 AQUÍ
		DbSelectArea("SF3")
		SF3->(DbSetOrder(5)) //F3_FILIAL+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA+F3_IDENTFT
		If SF3->(DbSeek(xFilial("SF3")+SD1->D1_SERIE+SD1->D1_DOC+SD1->D1_FORNECE+SD1->D1_LOJA+_cIDF3))  
			RecLock("SF3", .F.)
			SF3->F3_ALIQICM := _nIcms
			SF3->(MsUnlock())
		Endif
		dbselectarea("SD1")
		
	EndIf	
Next _nx

_cTipo := SF1->F1_TIPO

//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
RecLock("SF1",.F.)
	SF1->F1_IPI		:= _nTotIPI
	SF1->F1_ICMS	:= _nTotICM
	SF1->F1_ICMSRET	:= _nTotRIC
	SF1->F1_VALPIS	:= _nTotPIS
	SF1->F1_VALIMP6	:= _nTotPIS
	SF1->F1_VALCOFI	:= _nTotCOF
	SF1->F1_VALIMP5	:= _nTotCOF
	SF1->F1_DTDIGIT	:= _DtDigit
	SF1->F1_XIMPORT	:= "S"
SF1->(MsUnLock())

SD1->(DbCloseArea()) 

DbSelectArea("SF3")
SF3->(DbSetOrder(4)) //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE

DbSelectArea("SFT")
SFT->(DbSetOrder(1)) //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO

If SF3->(DbSeek(xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE))
	While 	!SF3->(EOF()) .AND. SF3->F3_FILIAL == xFilial("SF3") .AND. SF3->F3_CLIEFOR == SF1->F1_FORNECE .AND. SF3->F3_LOJA == SF1->F1_LOJA .AND. ;
			SF3->F3_NFISCAL == SF1->F1_DOC .AND. SF3->F3_SERIE == SF1->F1_SERIE
						
		RecLock("SF3", .F.)
			//SF3->F3_CHVNFE 	:= SC5->C5_CNFEIMP
			SF3->F3_XIMPORT := "S"
			SF3->F3_ENTRADA := _DtDigit
		    SF3->F3_TIPO    := _cTipo
		SF3->(MsUnlock())

		SF3->(DbSkip())
	EndDo
	
 	If SFT->(DbSeek(xFilial("SFT")+AVKEY("E", "FT_TIPOMOV")+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA))
 		While 	!SFT->(EOF()) .AND. SFT->FT_FILIAL == xFilial("SFT") .AND. SFT->FT_TIPOMOV == AVKEY("E", "FT_TIPOMOV") .AND. SFT->FT_SERIE == SF1->F1_SERIE .AND. ;
 				SFT->FT_NFISCAL == SF1->F1_DOC .AND. SFT->FT_CLIEFOR == SF1->F1_FORNECE .AND. SFT->FT_LOJA == SF1->F1_LOJA
									
			RecLock("SFT", .F.)
				//SFT->FT_CHVNFE 	:= SC5->C5_CNFEIMP
				SFT->FT_XIMPORT := "S"
				SFT->FT_ENTRADA := _DtDigit
				SFT->FT_TIPO    := _cTipo
			SFT->(MsUnlock())
        	
			SFT->(DbSkip())
		EndDo
		_cTipo := ""
	EndIf	
EndIf

Return