#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH" 

#DEFINE XERROR_ONLYFIRSTNODE -1 
#DEFINE XERROR_SUCCESS        0 
#DEFINE XERROR_FILE_NOT_FOUND 1 
#DEFINE XERROR_OPEN_ERROR     2 
#DEFINE XERROR_INVALID_XML    3 

#IFDEF SPANISH               
     #DEFINE STR001 "Éxito" 
     #DEFINE STR002 "Error desconocido" 
     #DEFINE STR003 "Archivo no encontrado: " 
     #DEFINE STR004 "No fue posible abrir el archivo " 
     #DEFINE STR005 "Archivo XML invalido: " 
#ELSE 
     #IFDEF ENGLISH 
          #DEFINE STR001 "Success" 
          #DEFINE STR002 "Unknown error" 
          #DEFINE STR003 "File not found: " 
          #DEFINE STR004 "It wasn´t possible to open the file " 
          #DEFINE STR005 "Invalid XML file: " 
     #ELSE              
          #DEFINE STR001 "Sucesso" 
          #DEFINE STR002 "Erro desconhecido"           
          #DEFINE STR003 "Arquivo não encontrado: "      
          #DEFINE STR004 "Não foi possível abrir o arquivo " 
          #DEFINE STR005 "Arquivo XML inválido: "           
     #ENDIF 
#ENDIF 

#xcommand CREATE XMLSTRING [] [ SETASARRAY ] [OPTIONAL ]; 
            => ; 
            :=XMLStr( ,[ \{<"aArray">\} ] ,[ \{<"aArray1">\} ], [<.lOnlyFirst.>] ) ; 

#xcommand CREATE XMLFILE [] [ SETASARRAY ] [OPTIONAL ]; 
            => ; 
            :=XMLFile( ,[ \{<"aArray">\} ] ,[ \{<"aArray1">\} ], [<.lOnlyFirst.>] ) ; 

#xcommand SAVE XMLSTRING [] => ; 
            :=XMLSaveStr( , [<.lNewLine.>] ) ; 

#xcommand SAVE XMLFILE [] => ; 
            XMLSaveFil( , , [<.lNewLine.>] ) ; 
             
#xcommand ADDITEM TAG ON [] [TEXT ] => ; 
            XMLAddItem( , , , [<.lArray.>],[] ) ; 
             
#xcommand ADDNODE NODE ON [ SETASARRAY ] => ; 
            XMLAddNode( , , , [ \{<"aChild">\} ] ) ; 

#xcommand DELETENODE ON => ; 
            XMLDelNode( , @ ) 
            
//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM006

Rotina para importação de notas fiscais de saída via XML.

@author  Allan Bonfim

@since   17/07/2015

@version P11
 
@obs 	17/07/2015 - Allan Bonfim - Desenvolvimento da rotina

@return

/*/
//-------------------------------------------------------------------
User Function CAMBM006()

Local aArea	   		:= GetArea()
Local aSays 		:= {}
Local aButtons		:= {}
Local nOpca			:= 0
Local lRet			:= .F.
Local aArqs			:= {}

Private cCadastro	:= "Importação de Notas Fiscais de Saída"
Private aCabec		:= {}
Private aLinhas		:= {}
Private cNomArq		:= ""
Private cPathArq 	:= ""
Private aTipoArq	:= {"XML"}
Private aLinLog		:= {}
Private cAliasTMP	:= GetNextAlias()
Private dDtAtual	:= dDataBase
Private aImpostx	:= {}
Private aTotImpx	:= {}
Private oProcess
Private aParam
Private aPergs

AADD(aSays, OemToAnsi("Esta função tem o objetivo de importar as notas fiscais de saída"))
AADD(aSays, OemToAnsi("para o sistema Protheus"))
AADD(aSays, OemToAnsi("O arquivo XML deverá ter o layout padrão da NFE (Danfe)."))
AADD(aSays, OemToAnsi(""))
AADD(aSays, OemToAnsi("### ATENÇÃO ###"))
AADD(aSays, OemToAnsi("PARA MELHOR PERFORMANCE E EVITAR TRAVAMENTOS DO SISTEMA"))
AADD(aSays, OemToAnsi("A PASTA SELECIONADA DEVERÁ CONTER ATÉ 1500 ARQUIVOS."))

AADD(aButtons, {1,.T.,{|| nOpca := IIf(CAMBM06P(@aParam, @aPergs), 1, 0), FECHABATCH()}})
AADD(aButtons, {2,.T.,{|| nOpca := 0, FECHABATCH()}})

FormBatch(cCadastro, aSays, aButtons)

If nOpca == 1
	FWMsgRun(, {|| lRet := CAMBM06B()}, "Processando... Aguarde...")

	If lRet
		
		DbSelectArea(cAliasTMP)
		(cAliasTMP)->(DbGoTop())
		dbEval ({|x| AADD(aArqs, {(cAliasTMP)->TMP_ARQ, 0, dDataBase, TIME(), "A"})},{|| !EMPTY((cAliasTMP)->TMP_OK)})
		(cAliasTMP)->(DbGoTop())
	
		oProcess := MsNewProcess():New({ |lFim| CAMBM06I(aArqs, @lFim)}, "Importação de NFe de Saída (XML)", "Processando...", .T. )
		oProcess:Activate()	
	EndIf
EndIf
            
If (Select(cAliasTMP) > 0)
	(cAliasTMP)->(DbCloseArea())
EndIf

//Restaura a Database do sistema
dDataBase := dDtAtual

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM06B

Função para selecionar os arquivos da pasta.

@author  Allan Bonfim

@since   20/07/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static function CAMBM06B()

Local aArea 		:= GetArea()
Local lRet			:= .F.
Local lOk			:= .F.
Local aSize    		:= MsAdvSize()
Local aObjects 		:= {}
Local aInfo    		:= {}
Local aPosObj  		:= {}
Local bOk      		:= {|| (lOk := .T., oDlg:End())}
Local bCancel  		:= {|| (lOk := .F., oDlg:End())}
Local aButtons  	:= {}
Local aCpoBrow		:= {} 
Local aCpoTMP		:= {}
Local nTotMarca		:= 0
Local aArquivos		:= {}
Local nX			:= 0
Local nY			:= 0
Local oDlg
Local cIndex

Private lInverte	:= .F.
Private cMark		:= GetMark()   
Private oMark

aAdd(aObjects,{100, 100, .T., .T., .F.})

aInfo     := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
aPosObj   := MsObjSize(aInfo, aObjects)

AADD(aCpoBrow,{"TMP_OK"		,"", "  ", ""})
AADD(aCpoBrow,{"TMP_ARQ"	,"", "Arquivo", "@!"})

AADD(aCpoTMP,{"TMP_OK"	,"C", 2, 0})			
AADD(aCpoTMP,{"TMP_ARQ"	,"C", 200, 0})
	
cIndex := CriaTrab(aCpoTMP, .T.)
dbUseArea(.T.,, cIndex, cAliasTMP, .F.)

For nX:=1 to Len(aTipoArq)
	aArquivos := Directory(ALLTRIM(aParam[2])+"*."+ALLTRIM(aTipoArq[nX]))
	For nY:=1 to Len(aArquivos)
		RecLock(cAliasTMP, .T.)
			(cAliasTMP)->TMP_OK := cMark
			(cAliasTMP)->TMP_ARQ := ALLTRIM(aArquivos[nY][1])
		(cAliasTMP)->(MsUnLock())	
	Next
Next

(cAliasTMP)->(DbGoTop())

DEFINE MSDIALOG oDlg TITLE OemToAnsi("Selecione o(s) Arquivos(s)") FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL STYLE DS_MODALFRAME  
				
oMark := MsSelect():New(cAliasTMP, "TMP_OK",, aCpoBrow, @lInverte, @cMark, {aPosObj[1][1],aPosObj[1][2],aPosObj[1][3],aPosObj[1][4]},,, oDlg)
oMark:oBrowse:lCanAllmark	:= .T.
oMark:oBrowse:lHasMark 		:= .T.
oMark:oBrowse:bAllMark 		:= {|| FWMsgRun(, {|| CAMBM01M(cMark, @oMark, cAliasTMP)}, "Selecionando os Arquivos...") }

ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg, bOk, bCancel,, aButtons)

If lOk

	DbSelectArea(cAliasTMP)
	(cAliasTMP)->(DbGoTop())
	dbEval ({|x| nTotMarca++},{|| !EMPTY((cAliasTMP)->TMP_OK)})
	(cAliasTMP)->(DbGoTop())
			
	If nTotMarca > 0
		If MSGYESNO("Confirma a importação dos arquivos selecionados ?", cCadastro)
			lRet := .T.
		EndIf
	Else
		HELP(,, 'HELP',, "Você deve selecionar arquivos para a importação.", 1, 0)
		lRet := .F.
	EndIf
EndIf
        	
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM06I

Rotina para importação das notas fiscais de saída via XML.

@author  Allan Bonfim

@since   17/07/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM06I(aArquivos, lFim)

Local aArea	   		:= GetArea()
Local cPstSrv		:= ALLTRIM(SUPERGETMV("CB_XPSTNFS", ,"\IMPORTACAO\NFE\NFS\"))
Local cTmpPath		:= GetTempPath (.T.)
Local nX			:= 0
Local nY			:= 0
Local nTamReg		:= 0
Local nSleep		:= 50

Default aArquivos	:= {} 

//Begin Transaction
	For nX:=1 to Len(aTipoArq)
	
		If Len(aArquivos) == 0
			aArquivos := Directory(ALLTRIM(aParam[2])+"*."+ALLTRIM(aTipoArq[nX]))
		EndIf		     
		
		nTamReg := Len(aArquivos)

		oProcess:SetRegua1(nTamReg)
			
		For nY:=1 to Len(aArquivos)

			If lFim
				Exit
			EndIf
			
			oProcess:IncRegua1("Gravando o Arquivo "+STRZERO(nY, 5)+" de "+STRZERO(nTamReg, 5))
			oProcess:SetRegua2(4)			
			oProcess:Incregua2("Abrindo o Arquivo o XML...")
			SLEEP(nSleep)
			
			cPathArq	:= ALLTRIM(aParam[2])+ALLTRIM(aArquivos[nY][1])
			cNomArq		:= "IMPORT_"+ALLTRIM(__cUserID)+"_"+DTOS(dDatabase)+"_"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)+SUBSTR(cPathArq, (LEN(cPathArq)-3), LEN(cPathArq))
	
			__CopyFile(cPathArq, cTmpPath+cNomArq)
	
			If EXISTDIR (cPstSrv) //Backup do arquivo de importação
				CPYT2S(cTmpPath+cNomArq, cPstSrv, .T.)
			Else	
				If MAKEDIR(cPstSrv) == 0
					CPYT2S(cTmpPath+cNomArq, cPstSrv, .T.)
				EndIf
			EndIf

			If FILE(cPstSrv+cNomArq) 
				If CAMBM06A(cPstSrv+cNomArq, cPathArq)
					oProcess:Incregua2("Gravando a Nota do XML...")
					SLEEP(nSleep)
					Begin Transaction
						If CAMBM06G(aCabec, aLinhas, cPathArq)
							oProcess:Incregua2("XML Gravado com Sucesso...")
							SLEEP(nSleep)
						Else
							oProcess:Incregua2("Falha na Gravação do XML...")
							SLEEP(nSleep)
							FERASE(cPstSrv+cNomArq)
						EndIf
					End Transaction
				Else
					oProcess:Incregua2("Falha na Leitura do XML...")
					SLEEP(nSleep)										
					oProcess:Incregua2("Falha na Leitura do XML...")
					SLEEP(nSleep)
					FERASE(cPstSrv+cNomArq)
				EndIf
			Else
				MSGSTOP ("Falha na criação do arquivo "+ALLTRIM(aArquivos[nY])+" na pasta "+cTmpPath+" do Servidor Protheus. Entre em contato com TI.", cCadastro)
			EndIf
			oProcess:Incregua2("Finalizando XML...")
			SLEEP(nSleep)
		Next
	Next

//End Transaction
	
If aParam[1] == "1" //Gera Log
	FWMsgRun(, {|| CAMBM06R(aCabec, aLinLog)}, "Gerando o Log da Importação... Aguarde...") 
EndIf

MSGINFO ("A importação dos arquivos do diretório "+UPPER(ALLTRIM(aParam[2]))+" foi finalizada.", cCadastro)


RestArea(aArea)

Return
        
//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM01M

Marcar todos itens do MsSelect

@author  Allan Bonfim

@since   20/07/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------

Static Function CAMBM01M(cMarca, oMark, cAliasT)

Local nReg := (cAliasT)->(Recno())

DbSelectArea(cAliasT)
(cAliasT)->(DbGoTop())

While !Eof()
	RecLock(cAliasT)

	If TMP_OK == cMarca
		(cAliasT)->TMP_OK := "  "
	Else
		(cAliasT)->TMP_OK := cMarca
	Endif
	
	(cAliasT)->(DbSkip())
EndDo

(cAliasT)->(DbGoto(nReg))

oMark:oBrowse:Refresh(.T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM06A

Função para abertura do arquivo.

@author  Allan Bonfim

@since   29/05/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static function CAMBM06A(cArqImp, cArqOri)

Local aArea		:= GetArea()
Local lRet 		:= .T.
Local cError   	:= ""
Local cWarning 	:= ""
Local nX		:= 0
Local nY		:= 0
Local nA		:= 0
Local nB		:= 0
Local cValInc	:= "" 
Local cC5DATA	:= ""
Local cC5PARC	:= ""
Local cCondPag	:= ALLTRIM(SUPERGETMV("CB_XIMPCPG", ,"001"))
Local oXMLImp	:= NIL
Local oXMLNf	:= NIL
Local oEmit		:= NIL
Local oIdent	:= NIL
Local oDest		:= NIL
Local oTotal	:= NIL
Local oTransp	:= NIL
Local oDet		:= NIL
Local oNfDev	:= NIL
Local oICMS		:= NIL
Local oFatura	:= NIL 
Local oRetira	:= NIL 
Local oEntreg	:= NIL 
Local aCabPv	:= {}
Local aItemPv	:= {}  
Local cChaveNf	:= ""
Local cAmbient	:= ""
Local cStatus	:= ""
Local cTipoNf	:= ""
Local dDtEmiss	:= CTOD("")
Local cCnpjTrs	:= ""
Local cModFrete	:= ""
Local cEspecie	:= ""
Local nPesoBru	:= ""
Local nPesoLiq	:= ""
Local nQtdeVol	:= ""
Local cFinaNfe	:= ""
Local cOperZZI  := ""
Local cFormPag	:= ""
Local cNatuOpe	:= ""
Local cModelNf	:= ""
Local cNumNfe	:= ""
Local cSeriNfe	:= ""
Local cCNPJDes	:= ""
Local cCNPJDes	:= ""
Local cNomeDes 	:= ""
Local cNomFDes 	:= ""
Local cIEDes  	:= ""
Local cEndeDes 	:= ""
Local cENroDes 	:= ""
Local cEBaiDes 	:= ""
Local cEMunDes 	:= ""
Local cEUFDes  	:= ""
Local cECEPDes 	:= ""
Local cPaisDes 	:= ""
Local cFoneDes	:= ""
Local cCNPJCEn	:= ""
Local cCNPJRem	:= ""
Local cNomeRem	:= ""
Local cNFanRem	:= ""
Local cIERem	:= ""
Local cIEstRem 	:= ""
Local cCnaeRem 	:= ""
Local cEndeRem 	:= ""
Local cECplRem 	:= ""
Local cENroRem 	:= ""
Local cEBaiRem 	:= ""
Local cEMunRem 	:= ""
Local cEUFRem  	:= ""
Local cECEPRem 	:= ""
Local cPaisRem 	:= ""
Local cFoneRem	:= ""
Local aProduto	:= {}
Local aDuplica	:= {}
Local cOpcLog	:= "2"
Local cCodiCli	:= ""
Local cLojaCli	:= ""
Local cTipoCli	:= ""
Local cNatureza	:= ""
Local cLogTmp	:= "" 
Local cCodTes	:= ""
//Local nItemLog	:= 0
Local lDevol	:= .F.
Local cNotaOri 	:= ""
Local cSeriOri 	:= ""
Local cOrigPrd	:= ""
Local lTIcms	:= .F.
Local lTIpi		:= .F.
Local lTIcmsST	:= .F.   
Local lBRedIcm	:= .F.
Local lBRedST	:= .F.
Local cICMS		:= "ICMS00/ICMS20/ICMS40/ICMS51/ICMS70/ICMS90"
Local cICMSST	:= "ICMS30/ICMS60/ICMS70/ICMS90"
Local lRemessa	:= .F. 
Local cCodProd	:= ""
Local cItemPed	:= ""
Local cCodCfop	:= ""

Default cArqImp	:= ""
Default	cArqOri	:= ""

If !EMPTY(cArqImp)

	If UPPER(SUBSTR(cArqImp, (LEN(cArqImp)-2), LEN(cArqImp))) $ "XML"
		aCabec	:= {}
		aLinhas	:= {}
		
		If VALIDXML(cArqImp) .OR. !SUPERGETMV("CB_VIMPXML",, .T.)
			
			oXMLImp := XMLParserFile(cArqImp, "_", @cError, @cWarning)
			
			If EMPTY(cError)				
				If VALTYPE(oXMLImp) == "O"
	                                
	   				aTotImpx := {}
	   				
					If VALTYPE(XMLCHILDEX(oXMLImp, "_CTEPROC")) == "O"
				 		oXMLNf := oXMLImp:_CTEPROC:_CTE
				   	ElseIf VALTYPE(XMLCHILDEX(oXMLImp, "_CTE")) == "O"
				      	oXMLNf := oXMLImp:_CTE
				   	ElseIf VALTYPE(XMLCHILDEX(oXMLImp, "_NFE")) == "O"
				      	oXMLNf := oXMLImp:_NFE  //NF ELETRONICA NORMAL
   				   	ElseIf VALTYPE(XMLCHILDEX(oXMLImp, "_NFEPROC")) == "O"
				      	oXMLNf := oXMLImp:_NFEPROC:_NFE //NF ELETRONICA CONTINGENCIA
				      	//_cTpObj := "NF-e"
					Else
						cValInc := "XML INVÁLIDO"
                   	EndIf

					If VALTYPE(XMLCHILDEX(oXMLImp, "_NFE")) == "O" .OR. VALTYPE(XMLCHILDEX(oXMLImp, "_NFEPROC")) == "O"
						
						oIdent	:= IIF(VALTYPE(XMLCHILDEX(oXMLNf:_INFNFE, "_IDE")) == "U", NIL, oXMLNf:_INFNFE:_IDE)
						oEmit	:= IIF(VALTYPE(XMLCHILDEX(oXMLNf:_INFNFE, "_EMIT")) == "U", NIL, oXMLNf:_INFNFE:_EMIT)
				      	oDest   := IIF(VALTYPE(XMLCHILDEX(oXMLNf:_INFNFE, "_DEST")) == "U", NIL, oXMLNf:_INFNFE:_DEST)
						oEntreg	:= IIF(VALTYPE(XMLCHILDEX(oXMLNf:_INFNFE, "_ENTREGA")) == "U", NIL, oXMLNf:_INFNFE:_ENTREGA)
				      	oTransp	:= IIF(VALTYPE(XMLCHILDEX(oXMLNf:_INFNFE, "_TRANSP")) == "U", NIL, oXMLNf:_INFNFE:_TRANSP)
				      	oTotal	:= IIF(VALTYPE(XMLCHILDEX(oXMLNf:_INFNFE, "_TOTAL")) == "U", NIL, oXMLNf:_INFNFE:_TOTAL)
				      	oDet	:= IIF(VALTYPE(XMLCHILDEX(oXMLNf:_INFNFE, "_DET")) == "U", NIL, oXMLNf:_INFNFE:_DET)
						oFatura := IIF(VALTYPE(XMLCHILDEX(oXMLNf:_INFNFE, "_COBR")) == "U", NIL, oXMLNf:_INFNFE:_COBR)
					   
						//procurar operação no ZZI para tratamento de notas de devolução nos XML com diferença de versões
						If Valtype(oDet) == "O"
							DbselectArea("ZZI")
							DbSetOrder(1)
							If ZZI->(DbSeek(xFilial("ZZI")+ALLTRIM(oDet:_PROD:_CFOP:TEXT)))
						    	cOperZZI := ZZI->ZZI_OPERAC      
							    cCodCfop := ALLTRIM(ZZI->ZZI_X_CFOP)
							Endif
						ElseIf Valtype(oDet) == "A"
							DbselectArea("ZZI")
							DbSetOrder(1)
							If ZZI->(DbSeek(xFilial("ZZI")+ALLTRIM(oDet[1]:_PROD:_CFOP:TEXT)))
						    	cOperZZI := ZZI->ZZI_OPERAC
						    	cCodCfop := ALLTRIM(ZZI->ZZI_X_CFOP)      
							Endif						 							
			            Endif
			            
			            If Valtype(oDet) == "O"
							oDet := {oDet}   
						EndIf					
						
						/* //Retirado para não gravar os valores das duplicatas devido a diferença do valor total e parcelas                    							   
						If VALTYPE(oFatura) == "O"											
							If VALTYPE(XMLCHILDEX(oFatura, "_DUP")) <> "U
								aDuplica	:= oFatura:_DUP //XmlNode2Arr (oFatura:_DUP, "_DUP")
			
								If Valtype(aDuplica) == "O"
									aDuplica := {aDuplica}
								EndIf
							EndIf
					    EndIf
						*/								      	
  						//Dados NF
						If VALTYPE(oIdent) == "O"
							cFinaNfe	:= ALLTRIM(oIdent:_FINNFE:TEXT) //1-NF-e normal; 2-NF-e complementar; 3–NF-e de ajuste; 4=Devolução 
							If !EMPTY(cOperZZI) //josmar - 10/11/15
								If cFinaNfe <> cOperZZI
									cFinaNfe := cOperZZI			 
							    Endif
							Endif    
							cFormPag	:= ALLTRIM(oIdent:_INDPAG:TEXT) //0–Pagamento à vista; 1–pagamento à prazo; 2-outros. 
							cNatuOpe	:= ALLTRIM(oIdent:_NATOP:TEXT) //Natureza da Operação //Venda de Mercadoria
							cModelNf	:= ALLTRIM(oIdent:_MOD:TEXT) //55-Nota Fiscal eletrônica; 57-Conhecimento de Transporte mar; 99-uso exclusivo do Fisco
							cNumNfe		:= STRZERO(VAL(oIdent:_NNF:TEXT), TAMSX3("F2_DOC")[1])
							cSeriNfe	:= PADR(oIdent:_SERIE:TEXT, TAMSX3("F2_SERIE")[1]) //ALLTRIM(oIdent:_SERIE:TEXT) //Informar zero para série inexistente 
							cAmbient	:= ALLTRIM(oIdent:_TPAMB:TEXT)
							cTipoNf		:= ALLTRIM(oIdent:_TPNF:TEXT) //0-entrada / 1-saída 
							//lRemessa	:= "REMESSA" $ UPPER(oIdent:_NATOP:TEXT)
							If  UPPER(oIdent:_NATOP:TEXT) $ "REMESSA EM GARANTIA" //IRA PESQUISAR lRemessa no cadastro de fornecedores se lRemessa = .T.
								lRemessa := .T.
							ElseIf  UPPER(oIdent:_NATOP:TEXT) $ "REMESSA P/ GARANTIA OU TROCA"
							     lRemessa := .T.
							ElseIf  UPPER(oIdent:_NATOP:TEXT) $ "REMESSA P/GARANTIA OU TROCA"
							     lRemessa := .T.							                                                       
							ElseIf  UPPER(oIdent:_NATOP:TEXT) $ "RETORNO SUBST EM GARANTIA"
								lRemessa := .T.
							ElseIf  UPPER(oIdent:_NATOP:TEXT) $"REMESSA P/ CONSERTO OU SIMPLES REMESSA"
								lRemessa := .T.
							ElseIf  UPPER(oIdent:_NATOP:TEXT) $"REMESSA P/CONSERTO OU SIMPLES REMESSA"
								lRemessa := .T.								
							Endif
							If ALLTRIM(oXMLNf:_INFNFE:_VERSAO:TEXT) $ "3.10"
								dDtEmiss	:= STOD(STRTRAN(oIdent:_DHEMI:TEXT, "-", ""))
							Else
								dDtEmiss	:= STOD(STRTRAN(oIdent:_DEMI:TEXT, "-", ""))
							EndIf 
							
							If VALTYPE(XMLCHILDEX(oXMLNf:_INFNFE, "_ID")) == "O"
								cChaveNf	:= SUBSTR(ALLTRIM(oXMLNf:_INFNFE:_ID:TEXT),4,44)
								cStatus		:= "100" //ALLTRIM(oXMLImp:_NFEPROC:_PROTNFE:_INFPROT:_CSTAT:TEXT)
							EndIf			                  					
							
							If VALTYPE(XMLCHILDEX(oIdent, "_NFREF")) == "O"   
								lDevol := .T.
								
								If VALTYPE(XMLCHILDEX(oIdent:_NFREF, "_REFNFE")) == "O"
									cNotaOri := SUBSTR(oIdent:_NFREF:_REFNFE:TEXT, 26, 9)
									cSeriOri := SUBSTR(oIdent:_NFREF:_REFNFE:TEXT, 25, 1)
								ElseIf VALTYPE(XMLCHILDEX(oIdent:_NFREF, "_REFNF")) == "O"
									cNotaOri := ALLTRIM(oIdent:_NFREF:_REFNF:_NNF:TEXT)
									cSeriOri := ALLTRIM(oIdent:_NFREF:_REFNF:_SERIE:TEXT)
								EndIf
						   	Else
						   		If cFinaNfe == "4" //trata a devolução em xml sem as Tags _NFREF e _REFNF
						   			lDevol := .T.
									cNotaOri := "999999999"
									cSeriOri := "IMP"
						   		Endif	 
						   	EndIf						   	
						EndIf
                        
						//Transporte - Frete
				      	If VALTYPE(oTransp) == "O"

							If VALTYPE(XMLCHILDEX(oTransp, "_TRANSPORTA")) <> "U"
								If VALTYPE(XMLCHILDEX(oTransp:_TRANSPORTA, "_CNPJ")) <> "U"
									cCnpjTrs	:= oTransp:_TRANSPORTA:_CNPJ:TEXT
								EndIf
							EndIf

							If VALTYPE(XMLCHILDEX(oTransp, "_MODFRETE")) <> "U"
								/*If oTransp:_MODFRETE:TEXT == "0"
									cModFrete	:= "1"
								Else
									cModFrete	:= "2"
								EndIf*/
								cModFrete	:= oTransp:_MODFRETE:TEXT
							Else
								cModFrete	:= "1"
							EndIf

							If VALTYPE(XMLCHILDEX(oTransp, "_VOL")) <> "U"							
								cEspecie	:= IIF(VALTYPE(XMLCHILDEX(oTransp:_VOL, "_ESP")) == "U", "", oTransp:_VOL:_ESP:TEXT)
								nPesoBru	:= IIF(VALTYPE(XMLCHILDEX(oTransp:_VOL, "_PESOB")) == "U", 0, VAL(oTransp:_VOL:_PESOB:TEXT))
								nPesoLiq	:= IIF(VALTYPE(XMLCHILDEX(oTransp:_VOL, "_PESOL")) == "U", 0, VAL(oTransp:_VOL:_PESOL:TEXT))
								nQtdeVol	:= IIF(VALTYPE(XMLCHILDEX(oTransp:_VOL, "_QVOL")) == "U", 0, VAL(oTransp:_VOL:_QVOL:TEXT))
							EndIf

							If VALTYPE(XMLCHILDEX(oTransp, "_VEICTRANSP")) <> "U"
								cPlaca	:= IIF(VALTYPE(XMLCHILDEX(oTransp:_VEICTRANSP, "_PLACA")) == "U", "", oTransp:_VEICTRANSP:_PLACA:TEXT)
							EndIf
						EndIf
	                        
                        //Dados do Remetente - Emissor da NF 
						If VALTYPE(oEmit) == "O"
					      	cCNPJRem	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oEmit, "_CNPJ")) == "U", "", oEmit:_CNPJ:TEXT))
					      	cNomeRem	:= UPPER(ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oEmit, "_XNOME")) == "U", "", oEmit:_XNOME:TEXT)))
					      	cNFanRem	:= UPPER(AllTrim(IIf(VALTYPE(XMLCHILDEX(oEmit, "_XFANT")) == "U", cNomeRem, oEmit:_XFANT:TEXT)))
					      	cIERem		:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oEmit, "_IE")) == "U", "", oEmit:_IE:TEXT))
				    	  	cIEstRem  	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oEmit, "_IEST")) == "U", "", oEmit:_IEST:TEXT))
				      		cCnaeRem 	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oEmit, "_CNAE")) == "U", "", oEmit:_CNAE:TEXT))
					      	cEndeRem 	:= UPPER(ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oEmit:_ENDEREMIT, "_XLGR")) == "U", "", oEmit:_ENDEREMIT:_XLGR:TEXT)))
					      	cECplRem 	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oEmit:_ENDEREMIT, "_XCPL")) == "U", "", oEmit:_ENDEREMIT:_XCPL:TEXT))
					      	cENroRem 	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oEmit:_ENDEREMIT, "_NRO")) == "U", "", oEmit:_ENDEREMIT:_NRO:TEXT))
					      	cEBaiRem 	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oEmit:_ENDEREMIT, "_XBAIRRO")) == "U", "", oEmit:_ENDEREMIT:_XBAIRRO:TEXT))
					      	cEMunRem 	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oEmit:_ENDEREMIT, "_CMUN")) == "U", "", oEmit:_ENDEREMIT:_CMUN:TEXT))
				    	  	cEUFRem  	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oEmit:_ENDEREMIT, "_UF")) == "U", "", oEmit:_ENDEREMIT:_UF:TEXT))
				      		cECEPRem 	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oEmit:_ENDEREMIT, "_CEP")) == "U", "", oEmit:_ENDEREMIT:_CEP:TEXT))
					      	cPaisRem 	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oEmit:_ENDEREMIT, "_CPAIS")) == "U", "", oEmit:_ENDEREMIT:_CPAIS:TEXT))
					      	cFoneRem 	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oEmit:_ENDEREMIT, "_FONE")) == "U", "", SUBSTR(oEmit:_ENDEREMIT:_FONE:TEXT, -8)))
						EndIf

						//Dados do Destinatario - Cliente
						If VALTYPE(oDest) == "O"						
							
							//CNPJ / CPF do Destinatario
							If VALTYPE(XMLCHILDEX(oDest, "_CPF")) <> "U"
								cCNPJDes	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oDest, "_CPF")) == "U", "", oDest:_CPF:TEXT))
							Else
								cCNPJDes	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oDest, "_CNPJ")) == "U", "", oDest:_CNPJ:TEXT))
							EndIf
														
				      		cNomeDes 	:= UPPER(ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oDest, "_XNOME")) == "U", "", oDest:_XNOME:TEXT)))
				      		cNomFDes 	:= UPPER(ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oDest, "_XFANT")) == "U", cNomeDes, oDest:_XFANT:TEXT)))
				      		cIEDes  	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oDest, "_IE")) == "U", "", oDest:_IE:TEXT))
				      		cEndeDes 	:= UPPER(ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oDest:_ENDERDEST, "_XLGR")) == "U","", oDest:_ENDERDEST:_XLGR:TEXT)))
				      		cENroDes 	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oDest:_ENDERDEST, "_NRO")) == "U", "", oDest:_ENDERDEST:_NRO:TEXT))
				      		cEBaiDes 	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oDest:_ENDERDEST, "_XBAIRRO")) == "U", "", oDest:_ENDERDEST:_XBAIRRO:TEXT))
				      		cEMunDes 	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oDest:_ENDERDEST, "_CMUN")) == "U", "", oDest:_ENDERDEST:_CMUN:TEXT))
				      		cEUFDes  	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oDest:_ENDERDEST, "_UF")) == "U", "", oDest:_ENDERDEST:_UF:TEXT))
				      		cECEPDes 	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oDest:_ENDERDEST, "_CEP")) == "U", "", oDest:_ENDERDEST:_CEP:TEXT))
				      		cPaisDes 	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oDest:_ENDERDEST, "_CPAIS")) == "U", "", oDest:_ENDERDEST:_CPAIS:TEXT))
				      		cFoneDes 	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oDest:_ENDERDEST, "_FONE")) == "U", "", SUBSTR(oDest:_ENDERDEST:_FONE:TEXT, -8)))
				      		        
				      		If VALTYPE(XMLCHILDEX(oIdent, "_NFREF")) == "O" .OR. lRemessa .OR. lDevol .OR. cCodCfop == "7949"
				      		
				      			If UPPER(ALLTRIM(cEUFDes)) == "EX" .OR. "00000000000" $ cCNPJDes //Fornecedor Exterior
									DbSelectArea("SA2")
									SA2->(DbSetOrder(2)) //A2_FILIAL+A2_NOME+A2_LOJA

									If SA2->(DbSeek(xFilial("SA2")+AVKEY(cNomeDes, "A2_NOME")))
										cCodiCli := SA2->A2_COD
										cLojaCli := SA2->A2_LOJA
										cTipoCli := "R" //SA2->A2_TIPO 17/11/15 - JOSMAR
									EndIf                                                
								Else
									DbSelectArea("SA2")
									SA2->(DbSetOrder(3)) //A2_FILIAL+A2_CGC
													
									If SA2->(DbSeek(xFilial("SA2")+cCNPJDes))
										cCodiCli := SA2->A2_COD
										cLojaCli := SA2->A2_LOJA
										cTipoCli := "R" //SA2->A2_TIPO 17/11/15 - JOSM,AR
									EndIf
								EndIf
				      		
				      		Else
				      		
				      			If UPPER(ALLTRIM(cEUFDes)) == "EX" .OR. "00000000000" $ cCNPJDes //Cliente Exterior
									DbSelectArea("SA1")
									SA1->(DbSetOrder(2)) //A1_FILIAL+A1_NOME+A1_LOJA

									If SA1->(DbSeek(xFilial("SA1")+AVKEY(cNomeDes, "A1_NOME")))
										cCodiCli 	:= SA1->A1_COD
										cLojaCli 	:= SA1->A1_LOJA
										cTipoCli 	:= SA1->A1_TIPO
										cNatureza	:= SA1->A1_NATUREZ
									EndIf
								Else
									DbSelectArea("SA1")
									SA1->(DbSetOrder(3)) //A1_FILIAL+A1_CGC
													
									If SA1->(DbSeek(xFilial("SA1")+cCNPJDes))
										cCodiCli := SA1->A1_COD
										cLojaCli := SA1->A1_LOJA 
										cTipoCli := SA1->A1_TIPO
									EndIf
								EndIf
							
							EndIf
							
						EndIf
                        
						//Entrega
						If VALTYPE(oEntreg) == "O"
						
							//CNPJ / CPF Entrega
							If VALTYPE(XMLCHILDEX(oEntreg, "_CPF")) <> "U"
								cCNPJCEn	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oEntreg, "_CPF")) == "U", "", oEntreg:_CPF:TEXT))
							Else
								cCNPJCEn	:= ALLTRIM(IIf(VALTYPE(XMLCHILDEX(oEntreg, "_CNPJ")) == "U", "", oEntreg:_CNPJ:TEXT))
							EndIf
							
						EndIf
												
						//Produtos
						aProduto	:= oDet
										      	
						//Total NF e Impostos
						
						// Pega o item 1 da nota como referencia de CODIGO DE SITUACAO TRIBUTARIA
					   	oICMS 	:= XMLGETCHILD(oDet[1]:_IMPOSTO:_ICMS, 1)
						cCST    := oICMS:REALNAME
						
						If VALTYPE(oTotal) == "O"
							AADD(aTotImpx, oTotal)
						EndIf
				   	
//                    ElseIf TYPE("oXMLImp:_CTEPROC") <> "U" .OR. TYPE("oXMLImp:_CTE") <> "U"
					
                	EndIf
					
					If cModelNf	== "55"
						If cAmbient == "1" //1=Produção 2=Homologação
					 		If !EMPTY(cChaveNf)
					   			If cStatus == "100" //Autorizado o uso da NF-e
					   		 		If cTipoNf == "1" //Nfe Saída
										//If cFinaNfe == "1" //Nfe Normal 
											If ALLTRIM(cCNPJRem) == ALLTRIM(SM0->M0_CGC) //Valida o CNPJ do Emitente
												//DbSelectArea("SA1")
												//SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
												If !EMPTY(cCodiCli) .AND. !EMPTY(cLojaCli) //.AND. SA1->(DbSeek(xFilial("SA1")+cCodiCli+cLojaCli))
													DbSelectArea("SF2")
													SF2->(DbSetOrder(2)) //F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE

													If !SF2->(DbSeek(xFilial("SF2")+cCodiCli+cLojaCli+cNumNfe+cSeriNfe))														
														DbSelectArea("SC5") //C5_FILIAL+C5_CLIENTE+C5_LOJACLI+C5_NOTA+C5_SERIE+C5_NUM   
														SC5->(DbOrderNickName("C5_NOTACLI"))
														
														If !SC5->(DbSeek(xFilial("SC5")+cCodiCli+cLojaCli+cNumNfe+cSeriNfe))
														
															AADD(aCabPv, {"C5_FILIAL", xFilial("SC5"), Nil}) //Normal
															
															If lRemessa .OR. cCodCfop == "7949"
																AADD(aCabPv, {"C5_TIPO", "B", Nil})
															ElseIf cFinaNfe == "4"
																AADD(aCabPv, {"C5_TIPO", "D", Nil})
															Else
																AADD(aCabPv, {"C5_TIPO", "N", Nil})
															EndIf
															
															//cNumped := GETSX8NUM("SC5", "C5_NUM")
															//AADD(aCabPv, {"C5_NUM", cNumPed, Nil})
							                                
															AADD(aCabPv, {"C5_NATUREZ"	, cNatureza	, NIL})		// Alterado por Carlos Eduardo Saturnino em 26/09/2016
															AADD(aCabPv, {"C5_CLIENTE"	, cCodiCli		, Nil})
															AADD(aCabPv, {"C5_LOJACLI"	, cLojaCli		, Nil})
															AADD(aCabPv, {"C5_CLIENT"	, cCodiCli		, Nil})
															AADD(aCabPv, {"C5_LOJAENT"	, cLojaCli		, Nil})
															
															/*																
															If cCNPJDes == cCNPJCEn
																AADD(aCabPv, {"C5_CLIENT", SA1->A1_COD, Nil})
																AADD(aCabPv, {"C5_LOJAENT", SA1->A1_LOJA, Nil})
															Else
																AADD(aCabPv, {"C5_CLIENT", SA1->(GETADVFVAL("SA1", "A1_COD", xFilial("SA1")+cCNPJDes, 3)), Nil})
																AADD(aCabPv, {"C5_LOJAENT", SA1->(GETADVFVAL("SA1", "A1_LOJA", xFilial("SA1")+cCNPJDes, 3)), Nil})
															EndIf
															*/
															
															If lDevol .OR. cCST == "ICMS00" .OR. cCST == "ICMS20" 
																AADD(aCabPv, {"C5_TIPOCLI", "F", Nil}) 
																cTipoCli := "F"
															Else
																AADD(aCabPv, {"C5_TIPOCLI", cTipoCli, Nil})
															EndIf															
																						    
											   		 		If !EMPTY(cCnpjTrs)
												   		 		AADD(aCabPv, {"C5_TRANSP", ALLTRIM(SA4->(GETADVFVAL("SA4", "A4_COD", xFilial("SA4")+cCnpjTrs, 3))), Nil})
											   		 		EndIf
														
															AADD(aCabPv, {"C5_CONDPAG", cCondPag, Nil})
															AADD(aCabPv, {"C5_EMISSAO", dDtEmiss, Nil})
											   		 		AADD(aCabPv, {"C5_TIPLIB", "2", Nil}) //Liberação por Pedido
											   		 		
											   		 		//AADD(aCabPv, {"C5_CONDPAG", cCondPag, Nil})
											   		 		
												   		 	For nA := 1 to Len(aDuplica)
							
												   		 		If EMPTY(cC5DATA)
													   				cC5DATA := "C5_DATA"+ALLTRIM(STR(nA))
													   			Else
														   	 		cC5DATA := STRTRAN(SOMA1(cC5DATA,1), "0", "_")
												   		 		EndIf
												   		 		
												   		 		If EMPTY(cC5PARC)
													   				cC5PARC := "C5_PARC"+ALLTRIM(STR(nA))
													   			Else
														   	 		cC5PARC := STRTRAN(SOMA1(cC5PARC,1), "0", "_")
												   		 		EndIf
							                                    									
													   		 	AADD(aCabPv, {cC5DATA, STOD(STRTRAN(aDuplica[nA]:_DVENC:TEXT,"-", "")) , Nil})
													   		 	AADD(aCabPv, {cC5PARC, VAL(aDuplica[nA]:_VDUP:TEXT), Nil})
												   		 	Next
																				   		 		
											   		 		If !EMPTY(cEspecie)
											   		 			AADD(aCabPv, {"C5_ESPECI1", ALLTRIM(cEspecie), Nil})
											   		 		EndIf
									
											   		 		If !EMPTY(nPesoLiq)
											   		 			AADD(aCabPv, {"C5_PESOL", nPesoLiq, Nil})
											   		 		EndIf
											   		 		
											   		 		If !EMPTY(nPesoBru)
											   		 			AADD(aCabPv, {"C5_PBRUTO", nPesoBru, Nil})
											   		 		EndIf
									
											   		 		If !EMPTY(nQtdeVol)
											   		 			AADD(aCabPv, {"C5_VOLUME1", nQtdeVol, Nil})
											   		 		EndIf				   		 		
											   		 		
											   		 		If cModFrete == "0"
																AADD(aCabPv, {"C5_TPFRETE", "C", Nil})
															ElseIf cModFrete == "1"
																AADD(aCabPv, {"C5_TPFRETE", "F", Nil})
															ElseIf cModFrete == "2"
																AADD(aCabPv, {"C5_TPFRETE", "T", Nil})
															ElseIf cModFrete == "9"
																AADD(aCabPv, {"C5_TPFRETE", "S", Nil})
															EndIf
															
															AADD(aCabPv, {"C5_ZZOBS", ALLTRIM(oXMLImp:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT), Nil})
															AADD(aCabPv, {"C5_MENNOTA", ALLTRIM(oXMLImp:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT), Nil})										  
															AADD(aCabPv, {"C5_XIMPORT", "S", Nil})
															AADD(aCabPv, {"C5_NOTAIMP", AVKEY(cNumNfe, "C5_NOTAIMP"), Nil})
															AADD(aCabPv, {"C5_SERIIMP", AVKEY(cSeriNfe, "C5_SERIIMP"), Nil})
															AADD(aCabPv, {"C5_CNFEIMP", AVKEY(cChaveNf, "C5_CNFEIMP"), Nil})
																																	
															//AADD (aCabec, aCabPv)											
															aCabec := ACLONE(aCabPv)
															
															aImpostx := {}
															
															For nB := 1 to LEN(aProduto)
																
																aItemPv		:= {}
																cCodProd 	:= aProduto[nB]:_PROD:_CPROD:TEXT
																lTIpi		:= .F.
																lTIcms		:= .F.
																lBRedIcm	:= .F.
																lTIcmsST	:= .F.
																lBRedST		:= .F.
																//tratar produto aqui - Josmar
																DbSelectArea("ZZA")   //habilitado 30/10/15
																ZZA->(DbSetOrder(2)) //ZZA_FILIAL+ZZA_XCODRF
																
																DbSelectArea("SB1")
																SB1->(DbSetOrder(12)) //B1_FILIAL+B1_XANTIGO
																
																//Buscar o código do produto ref. do XML
																If !SB1->(DbSeek(xFilial("SB1")+AVKEY(FmtXAntigo(cCodProd), "B1_COD"))) //alterado 30/10/15 - josmar
																	If ZZA->(DbSeek(xFilial("ZZA")+AVKEY(cCodProd , "ZZA_XCODRF")))
																		If SB1->(DbSeek(xFilial("SB1")+AVKEY(ZZA->ZZA_XCOD, "B1_COD")))
																			If !EMPTY(SB1->B1_XANTIGO)
																				cCodProd := SB1->B1_XANTIGO
																		    Endif
																		EndIf
																	Else
																		cCodProd := "Codigo do XML: " + alltrim(cCodProd) 										
																	EndIf
																Else
																	If !EMPTY(SB1->B1_XANTIGO) .AND. ALLTRIM(SB1->B1_COD) == ALLTRIM(FmtXAntigo(SB1->B1_XANTIGO))
																		If ZZA->(DbSeek(xFilial("ZZA")+AVKEY(FmtXAntigo(cCodProd) , "ZZA_XCODRF")))
																	    	If SB1->(DbSeek(xFilial("SB1")+AVKEY(ZZA->ZZA_XCOD, "B1_COD")))
																				If !EMPTY(SB1->B1_XANTIGO)
																					cCodProd := SB1->B1_XANTIGO
																		    	Endif
																		    Endif
																		Else
																			cCodProd := "Codigo do XML: " + alltrim(cCodProd)    
																		Endif	    																		
																	ElseIf !EMPTY(SB1->B1_XANTIGO) .AND. ALLTRIM(SB1->B1_COD) <> ALLTRIM(SB1->B1_XANTIGO)
																		cCodProd := SB1->B1_COD				// Alterado de B1_XANTIGO para B1_COD em 26/09/2016 por Carlos Eduardo Saturnino 
																    Endif
																EndIf
                                                                
																DbSelectArea("SB1")
																SB1->(DbSetOrder(1)) 	// Carlos Eduardo Saturnino em 26/09/2016
																SB1->(DbGoTop())			// Carlos Eduardo Saturnino em 26/09/2016
																SB1->(DbSeek(xFilial("SB1")+AVKEY(cCodProd, "B1_COD")))
															
																If oICMS:_ORIG:TEXT == "2"
																	cOrigPrd := "1"
																Else
																	cOrigPrd := oICMS:_ORIG:TEXT
																EndIf
																//desabilitado 30/10/15 - josmar	
																//If !SB1->(DbSeek(xFilial("SB1")+AVKEY(cCodProd, "B1_COD"))) //desabilitar inclusão de produto - josmar
																//	cCodProd := CADPRDOLD(cCodProd, aProduto[nB]:_PROD:_XPROD:TEXT, aProduto[nB]:_PROD:_UCOM:TEXT, aProduto[nB]:_PROD:_NCM:TEXT, cOrigPrd)
																//EndIf
																
																If SB1->(DbSeek(xFilial("SB1")+AVKEY(cCodProd , "B1_COD")))
																   	oICMS 	:= XMLGETCHILD(aProduto[nB]:_IMPOSTO:_ICMS, 1)
																	cCST    := oICMS:REALNAME
																	
																	If cCST $ cICMS
																		If VALTYPE(XMLCHILDEX(oICMS, "_VICMS")) == "O"
																			If VAL(STRTRAN(oICMS:_VICMS:TEXT, ",", ".")) > 0
																				lTIcms := .T.
																			EndIf
																		EndIf
																	EndIf
																	
																	If cCST $ cICMSST 
																		If VALTYPE(XMLCHILDEX(oICMS, "_VICMSSTRET")) == "O"
																			If VAL(STRTRAN(oICMS:_VICMSSTRET:TEXT, ",", ".")) > 0
																				lTIcmsST := .T.
																			EndIf
																		EndIf
																		
																		If VALTYPE(XMLCHILDEX(oICMS, "_VICMSST")) == "O"
																			If VAL(STRTRAN(oICMS:_VICMSST:TEXT, ",", ".")) > 0
																				lTIcmsST := .T.
																			EndIf
																		EndIf
																	EndIf
																	
																	If ALLTRIM(oICMS:_CST:TEXT) == "20"
																		lBRedIcm := .T.
																	EndIf

																	If ALLTRIM(oICMS:_CST:TEXT) $ "70"
																		lBRedST := .T.
																	EndIf
																	
																	If VALTYPE(XMLCHILDEX(aProduto[nB]:_IMPOSTO, "_IPI")) == "O"
																		If VALTYPE(XMLCHILDEX(aProduto[nB]:_IMPOSTO:_IPI, "_IPITRIB")) == "O"
																			If VAL(STRTRAN(aProduto[nB]:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT, ",", ".")) > 0
																				lTIpi := .T.
																			EndIf
																		EndIf
																	EndIf
																	
																	If lDevol
																		/*If EMPTY(cOrigPrd)
																			cCodTes := U_BUTESIMP(AVKEY(aProduto[nB]:_PROD:_CFOP:TEXT, "C6_CF"), "4", cOrigPrd, ALLTRIM(aProduto[nB]:_PROD:_NCM:TEXT), cTipoCli, lTIcms, lTIpi, lTIcmsST, SB1->B1_COD)
																		Else
																			cCodTes := U_BUTESIMP(AVKEY(aProduto[nB]:_PROD:_CFOP:TEXT, "C6_CF"), "4", cOrigPrd, ALLTRIM(aProduto[nB]:_PROD:_NCM:TEXT), cTipoCli, lTIcms, lTIpi, lTIcmsST)
																		EndIf*/                                                                                                                                                          
																		
																		cCodTes := U_BUTESIMP(AVKEY(aProduto[nB]:_PROD:_CFOP:TEXT, "C6_CF"), "4",,,, lTIcms, lTIpi, lTIcmsST,, cCodiCli, cLojaCli, lBRedIcm, lBRedST)
																	Else
/*																		If EMPTY(cOrigPrd)
																			cCodTes := U_BUTESIMP(AVKEY(aProduto[nB]:_PROD:_CFOP:TEXT, "C6_CF"), "2", cOrigPrd, ALLTRIM(aProduto[nB]:_PROD:_NCM:TEXT), cTipoCli, lTIcms, lTIpi, lTIcmsST, SB1->B1_COD)
																		Else
																			cCodTes := U_BUTESIMP(AVKEY(aProduto[nB]:_PROD:_CFOP:TEXT, "C6_CF"), "2", cOrigPrd, ALLTRIM(aProduto[nB]:_PROD:_NCM:TEXT), cTipoCli, lTIcms, lTIpi, lTIcmsST)
																		EndIf*/
																		cCodTes := U_BUTESIMP(AVKEY(aProduto[nB]:_PROD:_CFOP:TEXT, "C6_CF"), "2",,,, lTIcms, lTIpi, lTIcmsST,,,, lBRedIcm, lBRedST)
																	EndIf
																	
																	If !EMPTY(cCodTes)
																		AADD(aItemPv,	{"C6_FILIAL", xFilial("SC6"), Nil})
																	 //	AADD(aItemPv,	{"C6_NUM", cNumPed, Nil})
																		
																		If VAL(aProduto[nB]:_NITEM:TEXT) < 100
																			cItemPed := AVKEY(STRZERO(VAL(aProduto[nB]:_NITEM:TEXT),2), "C6_ITEM")
																		Else
																			cItemPed := AVKEY(SOMA1(alinhas[LEN(aLinhas)][ASCAN(aLinhas[LEN(aLinhas)], {|x| ALLTRIM(x[1]) == "C6_ITEM"})][2]), "C6_ITEM")
																		EndIf
																		
																		AADD(aItemPv,	{"C6_ITEM", cItemPed, Nil})
																		AADD(aItemPv,	{"C6_PRODUTO", AVKEY(SB1->B1_COD, "C6_PRODUTO"), Nil})
																		AADD(aItemPv,	{"C6_LOCAL", AVKEY(SB1->B1_LOCPAD, "C6_LOCAL"), Nil})
																		AADD(aItemPv,	{"C6_DESCRI", AVKEY(aProduto[nB]:_PROD:_XPROD:TEXT, "C6_DESCRI"), Nil})
																		AADD(aItemPv,	{"C6_UM", AVKEY(aProduto[nB]:_PROD:_UCOM:TEXT, "C6_UM"), Nil})
																		AADD(aItemPv,	{"C6_QTDVEN", VAL(STRTRAN(aProduto[nB]:_PROD:_QCOM:TEXT, ",", ".")), Nil})
																		AADD(aItemPv,	{"C6_PRCVEN", VAL(STRTRAN(aProduto[nB]:_PROD:_VUNCOM:TEXT, ",", ".")), Nil})
																		AADD(aItemPv,	{"C6_VALOR", VAL(STRTRAN(aProduto[nB]:_PROD:_VPROD:TEXT, ",", ".")), Nil})
																		AADD(aItemPv,	{"C6_QTDLIB", VAL(STRTRAN(aProduto[nB]:_PROD:_QCOM:TEXT, ",", ".")), Nil})
																		AADD(aItemPv,	{"C6_TES", AVKEY(cCodTes, "C6_TES"), Nil}) //U_BUTESIMP(cCfop, cTpOper, cOrigPrd, cNcmPrd, cTpCliFor, lIcms, lIpi, lIcmsST, cCodPrd, cCodCFor, cLojCFor)
																		AADD(aItemPv,	{"C6_CF", AVKEY(aProduto[nB]:_PROD:_CFOP:TEXT, "C6_CF"), Nil})
																		AADD(aItemPv,	{"C6_ENTREG", dDtEmiss, Nil})
																		AADD(aItemPv,	{"C6_DATFAT", dDtEmiss, Nil})
																		//AADD(aItemPv,	{"C6_NOTA", AVKEY(cNumNfe, "C6_NOTA"), Nil})
																		//AADD(aItemPv,	{"C6_SERIE", AVKEY(cSeriNfe, "C6_SERIE"), Nil})
																		//AADD(aItemPv,	{"C6_DESCONT", cNumPed, Nil})
	
																		If TYPE("aProduto[nB]:_PROD:_VDESC:TEXT") <> "U"
																	   		AADD(aItemPv,	{"C6_VALDESC", VAL(STRTRAN(aProduto[nB]:_PROD:_VDESC:TEXT, ",", ".")), Nil})
																		EndIf
	                                                                    
																		If !EMPTY(cNotaOri)
																			AADD(aItemPv,	{"C6_NFORI", cNotaOri, Nil})
																			AADD(aItemPv,	{"C6_SERIORI", cSeriOri, Nil})																		
																			//AADD(aItemPv,	{"C6_ITEMORI", "0001", Nil})
																		EndIf
																		
																		//AADD(aItemPv,	{"C6_CLASFIS", cNumPed, Nil})
																		AADD(aItemPv,	{"C6_SUGENTR", dDtEmiss, Nil})
																		//AADD(aItemPv,	{"C6_ICMSRET", cNumPed, Nil})
																		AADD(aItemPv,	{"C6_XIMPORT", "S", Nil}) 
																		
																		If VALTYPE(XMLCHILDEX(aProduto[nB], "_IMPOSTO")) == "O"
																			AADD(aImpostx, {cItemPed, aProduto[nB]:_IMPOSTO})
																		Else
																			AADD(aImpostx, {})
																		EndIf

																		AADD (aLinhas, aItemPv)  
																																																	
																	Else
//															   			cValInc := "CFOP ("+ALLTRIM(aProduto[nB]:_PROD:_CFOP:TEXT)+")"
															   			cLogTmp	:= "TES NÃO ENCONTRADO"
															   			cValInc := "CFOP = "+ALLTRIM(aProduto[nB]:_PROD:_CFOP:TEXT)+ " | TIPO = "+IIF(lDevol, "4", "2")+" | ORIGEM = "+SB1->B1_ORIGEM+" | ICMS = "+IIF (lTIcms, "SIM", "NAO")+" | BASE RED ICM = "+IIF (lBRedIcm, "SIM", "NAO")+" | ICMS ST = "+IIF (lTIcmsST, "SIM", "NAO")+" | BASE RED ST = "+IIF (lBRedST, "SIM", "NAO")+" | IPI = "+IIF (lTIpi, "SIM", "NAO")

															   			cOpcLog	:= "2"
															   			//Exit
															   			AADD(aLinLog, {cArqOri, cLogTmp, nB, cOpcLog, cValInc})
																	EndIf
																	
																Else
														   			cValInc := "PRODUTO ("+ALLTRIM(cCodProd)+")"
														   			cLogTmp	:= "PRODUTO NÃO ENCONTRADO NO CADASTRO"
														   			//nItemLog:= nB
														   			cOpcLog	:= "2"
														   			
														   			AADD(aLinLog, {cArqOri, cLogTmp, nB, cOpcLog, cValInc})
														   			//Exit
																EndIf
																
																aItemPv := {}
															Next
															
										   				Else												
											   				//cValInc := "PEDIDO DE VENDA ("+ALLTRIM(SC5->C5_NUM)+")"
											   				//cLogTmp	:= "NOTA FISCAL JÁ CADASTRADA NO SISTEMA"
												   			//cOpcLog	:= "4"
												   			
												   			//AADD(aLinLog, {cArqOri, cLogTmp, 0, cOpcLog, cValInc})
												   		EndIf        	
										   			Else
											   			//cValInc := "CLIENTE/LOJA ("+ALLTRIM(SF2->F2_CLIENTE)+"/"+ALLTRIM(SF2->F2_LOJA)+"), NOTA/SERIE ("+ALLTRIM(SF2->F2_DOC)+"/"+ALLTRIM(SF2->F2_SERIE)+")"
											   			//cLogTmp	:= "NOTA FISCAL JÁ CADASTRADA NO SISTEMA"
											   			//cOpcLog	:= "4"
											   			
											   			//AADD(aLinLog, {cArqOri, cLogTmp, 0, cOpcLog, cValInc})
											   		EndIf
									   			Else
											   		If lDevol
												   		cLogTmp := "FORNECEDOR NÃO CADASTRADO
												   	Else
											   			cLogTmp := "CLIENTE NÃO CADASTRADO
											   		EndIf
											   		
										   			cValInc	:= "NOME ("+ALLTRIM(cNomeDes)+") - CNPJ ("+TRANSFORM(cCNPJDes, "@R 99.999.999/9999-99")+")"
										   			cOpcLog	:= "2"
										   			
										   			AADD(aLinLog, {cArqOri, cLogTmp, 0, cOpcLog, cValInc})
										   		EndIf
								   			Else
									   			cValInc := "CNPJ ("+TRANSFORM(cCNPJCEn, "@R 99.999.999/9999-99")+")"
									   			cLogTmp	:= "CNPJ DO EMITENTE DIFERENTE DO CNPJ DA NOTA FISCAL"
									   			cOpcLog	:= "2"
									   			
									   			AADD(aLinLog, {cArqOri, cLogTmp, 0, cOpcLog, cValInc})
									   		EndIf										   		
							   			//Else
								   		//	cValInc := "FINALIDADE DA NOTA FISCAL INVÁLIDA
								   		//	cLogTmp	:= "FINALIDADE DE EMISSÃO DA NF-E ("+ALLTRIM(cFinaNfe)+")"
								   		//	cOpcLog	:= "2"
								   		//EndIf							   		
							   		//Else desabilitado 18/11/15 - Josmar 
							   			//cValInc := "NOTA DE ENTRADA"    
							   			//cLogTmp	:= "TIPO DA NOTA FISCAL ELETRÔNICA INVÁLIDO"
							   			//cOpcLog	:= "2"
							   			
							   			//AADD(aLinLog, {cArqOri, cLogTmp, 0, cOpcLog, cValInc})							   		
							   		EndIf
					   			Else
						   			cValInc := "STATUS PROCESSAMENTO ("+ALLTRIM(cStatus)+")"
						   			cLogTmp	:= "NOTA FISCAL ELETRÔNICA NÃO FOI PROCESSADA CORRETAMENTE NO SEFAZ"
						   			cOpcLog	:= "2"
						   			
						   			AADD(aLinLog, {cArqOri, cLogTmp, 0, cOpcLog, cValInc})
						   		EndIf
					   		Else
						   		cValInc := "CHAVE DA NOTA FISCAL ELETRÔNICA INVÁLIDA"
						   		cOpcLog	:= "2"

						   		AADD(aLinLog, {cArqOri, cLogTmp, 0, cOpcLog, cValInc})
						   	EndIf
						Else
							cValInc := "AMBIENTE ("+ALLTRIM(cAmbient)+")"
				   			cLogTmp	:= "XML NÃO FOI EMITIDO NO AMBIENTE PRODUÇÃO DO SEFAZ"
							cOpcLog	:= "2"
							
							AADD(aLinLog, {cArqOri, cLogTmp, 0, cOpcLog, cValInc})
					 	EndIf
					Else
						cValInc := "MODELO ("+ALLTRIM(cModelNf)+")"
			   			cLogTmp	:= "MODELO DO XML INVÁLIDO"
						cOpcLog	:= "2"
						
						AADD(aLinLog, {cArqOri, cLogTmp, 0, cOpcLog, cValInc})
				 	EndIf	
				Else
					cValInc := "XML INVÁLIDO"
					cOpcLog	:= "6"
					
					AADD(aLinLog, {cArqOri, cLogTmp, 0, cOpcLog, cValInc})
				EndIf
			Else
				cValInc := "XML INVÁLIDO
	   			cLogTmp	:= "FALHA NA LEITURA ("+ALLTRIM(cError)+")"
				cOpcLog	:= "6"
				
				AADD(aLinLog, {cArqOri, cLogTmp, 0, cOpcLog, cValInc})
			EndIf			
		Else
			cValInc := "XML INVÁLIDO
   			cLogTmp	:= "FALHA NA VALIDAÇÃO DO SCHEMA"
			cOpcLog	:= "6"
			
			AADD(aLinLog, {cArqOri, cLogTmp, 0, cOpcLog, cValInc})
		EndIf
	Else
		cValInc := "ARQUIVO INVÁLIDO"		
		AADD(aLinLog, {cArqOri, cLogTmp, 0, cOpcLog, cValInc})
	EndIf
				   	
Else

	lRet := .F.
	
EndIf

/*
If VALTYPE(oXMLImp) == "O"
	FreeObj(oXMLImp)
EndIf

If VALTYPE(oXMLNf) == "O"
	FreeObj(oXMLNf)
EndIf

If VALTYPE(oEmit) == "O"
	FreeObj(oEmit)
EndIf

If VALTYPE(oIdent) == "O"
	FreeObj(oIdent)
EndIf

If VALTYPE(oDest) == "O"
	FreeObj(oDest)
EndIf

If VALTYPE(oTotal) == "O"
	FreeObj(oTotal)
EndIf

If VALTYPE(oTransp) == "O"
	FreeObj(oTransp)
EndIf

If VALTYPE(oDet) == "O"
	FreeObj(oDet)
EndIf

If VALTYPE(oNfDev) == "O"
	FreeObj(oNfDev)
EndIf

If VALTYPE(oICMS) == "O"
	FreeObj(oICMS)
EndIf

If VALTYPE(oFatura) == "O"
	FreeObj(oFatura)
EndIf

If VALTYPE(oRetira) == "O"
	FreeObj(oRetira)
EndIf

If VALTYPE(oEntreg) == "O"
	FreeObj(oEntreg)
EndIf
*/

If Len(aCabec) == 0 .OR. Len(aLinhas) <> Len(aProduto)
//	AADD(aLinLog, {cArqOri, cLogTmp, nItemLog, cOpcLog, cValInc})
	lRet := .F.
EndIf

RestArea(aArea)
 
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM06G

Função para gravação dos dados do arquivo.

@author  Allan Bonfim

@since   29/05/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static function CAMBM06G(aCab, aItens, cArqOri)

	Local aArea		:= GetArea()
	Local lRet			:= .F.
	Local cLogTmp		:= ""
	Local cValInc		:= ""
	Local nX			:= 0
	Local cBuffer		:= ""
	Local nErrLin		:= 1
	Local nLinhas		:= 0
	Local cErroTemp	:= ""
	Local dDtAtual	:= dDataBase
	Local cNomeArq	:= "LOG_"+ALLTRIM(STR(ALEATORIO(999999, VAL(SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)+SUBSTR(TIME(), 7, 2)))))+".log"
	Local cDoc			:= ""
	Local aPvlNfs		:= {}
	Local cTpNrNfs	:= SuperGetMV("MV_TPNRNFS")
	Local cNFEIni		:= ''
	Local cNFEIFim	:= ''
	Local aAreaSF2
    	 					
	Private lMsHelpAuto	:= .F.
	Private lMsErroAuto 	:= .F.
	Private cSerie		:= ''

	Default aCab			:= {}
	Default aItens		:= {}
	Default cArqOri		:= ""

	If Len(aCab) > 0 .And. Len(aItens) > 0

		// Guardo o numero do Proximo Pedido nao utilizado
		cDoc := GetSxeNum("SC5","C5_NUM")
	
		//Altera a data base do sistema para a data de emissao da nota fiscal
		dDataBase := aCab[ASCAN(aCab, {|x| ALLTRIM(x[1]) == "C5_EMISSAO"})][2]

		lMsErroAuto := .F.

		//MsExecAuto({|x,y,z| MATA410(x,y,z)},aCab, aItens, 3) //CRIA PEDIDO DE VENDAS
		MATA410(aCab,aItens,3)
				
		If lMsErroAuto
					
			cErroTemp 	:= MOSTRAERRO(GetSrvProfString("Startpath",""), cNomeArq)
			nLinhas 	:= MLCOUNT(cErroTemp)
			cBuffer 	:= RTRIM(MEMOLINE(cErroTemp,, nErrLin))
										
			While (nErrLin <= nLinhas)
				nErrLin++
				cBuffer := ALLTRIM(MEMOLINE(cErroTemp,, nErrLin))
				If (UPPER(SUBSTR(cBuffer, LEN(cBuffer)-7, LEN(cBuffer))) == "INVALIDO")
					cValInc := "ERRO NA GERAÇÃO DO PEDIDO DE VENDAS = "+ALLTRIM(cBuffer)
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
			//AEVAL(aItens[nX], {|X| cLogTmp += X+" "}) 
			//cLogTmp := "PRODUTO ("+ALLTRIM(aItens[nX][3][2])+"), TES ("+ALLTRIM(aItens[nX][11][2])+"), QTD ("+ALLTRIM(STR(aItens[nX][7][2]))+"), VL UNIT ("+ALLTRIM(STR(aItens[nX][8][2]))+"), TOTAL ("+ALLTRIM(STR(aItens[nX][9][2]))+")
			//cLogTmp := "PRODUTO ("+ALLTRIM(aItens[nX][3][2])+"), TES ("+ALLTRIM(aItens[nX][11][2])+"), QTD ("+ALLTRIM(STR(aItens[nX][7][2]))+"), VL UNIT ("+ALLTRIM(STR(aItens[nX][8][2]))+"), TOTAL ("+ALLTRIM(STR(aItens[nX][9][2]))+")
        				
			AADD(aLinLog, {cArqOri, cLogTmp, nX, "5", cValInc})
        				
			lRet := .F.
			ROLLBACKSXE()
			DisarmTransaction()
							
		Else
				/*
				If LIBERPED(SC5->C5_NUM)
					If GERANOTA(SC5->C5_NUM)
						If ATUFISCAL(SC5->C5_NUM)

							//cLogTmp := ""
							//cValInc	:= "PEDIDO ("+ALLTRIM(SC5->C5_NUM)+"), NF ("+ALLTRIM(SC5->C5_NOTAIMP)+" / "+ALLTRIM(SC5->C5_SERIIMP)+")"
							//AADD(aLinLog, {cArqOri, cLogTmp, 0, "1", cValInc}) //Gravado com Sucesso
	                        SC5->(CONFIRMSX8())
   							lRet := .T.
	                                    
						Else
	
							cLogTmp	:= ""
							cValInc	:= ""
							//AEVAL(aItens[nX], {|X| cLogTmp += X+" "})
							cValInc	:= "PEDIDO ("+ALLTRIM(SC5->C5_NUM)+"), NF ("+ALLTRIM(SC5->C5_NOTAIMP)+" / "+ALLTRIM(SC5->C5_SERIIMP)+")"
							AADD(aLinLog, {cArqOri, cLogTmp, nX, "7", cValInc})
	
							lRet := .F.
							SC5->(ROLLBACKSX8())
							DisarmTransaction()
							
						EndIf
										
					Else
	
						cLogTmp	:= ""
						cValInc	:= ""
						cValInc	:= "PEDIDO ("+ALLTRIM(SC5->C5_NUM)+"), NF ("+ALLTRIM(SC5->C5_NOTAIMP)+" / "+ALLTRIM(SC5->C5_SERIIMP)+")"
						AADD(aLinLog, {cArqOri, cLogTmp, nX, "7", cValInc})
	
						lRet := .F.
						SC5->(ROLLBACKSX8())
						DisarmTransaction()
	
					EndIf		*/

			// Desbloqueia crédito ou estoque e posiciona Tabelas para Faturamento
			dbSelectArea("SC6")
			dbSetOrder(1)
			If dbSeek( xFilial("SC6") + cDoc )
				While SC6->C6_NUM == cDoc .And. SC6->(! Eof())
						
					//Efetuo a liberação de Credito/Estoque
					MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN, .T., .T., .T., .T. )
						
							
					// Posiciono nas Tabelas para Faturamento
					dbSelectArea("SC9")
					SC9->( dbSetOrder(1) )
					SC9->( dbSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM)),.F.)
					dbSelectArea("SE4")
					SE4->( dbSetOrder(1) )
					dbSelectArea("SB1")
					SB1->( dbSetOrder(1) )
					SB1->( dbSeek(xFilial("SB1")+SC6->C6_PRODUTO) )
					dbSelectArea("SB2")
					SB2->( dbSetOrder(1) )
					SB2->( dbSeek(xFilial("SB2")+SC6->C6_PRODUTO) )
					dbSelectArea("SF4")
					SF4->( dbSetOrder(1) )
					SF4->( dbSeek(xFilial("SF4")+SC6->C6_TES) )
				 
					aAdd(aPvlNfs,{SC6->C6_NUM 		,;	//[01]
									SC6->C6_ITEM 		,;	//[02]
									SC6->C6_LOCAL 	,;	//[03]
									SC6->C6_QTDVEN 	,;	//[04]
									SC6->C6_VALOR 	,;	//[05]
									SC6->C6_PRODUTO 	,;	//[06]
									.F. 				,;	//[07]
									SC9->(RecNo())	,;	//[08]
									SC5->(RecNo()) 	,;	//[09]
									SC6->(RecNo()) 	,;	//[10]
									SE4->(RecNo())	,;	//[11]
									SB1->(RecNo())	,;	//[12]
									SB2->(RecNo())	,;	//[13]
									SF4->(RecNo())	}) 	//[14]
									SC6->(dbSkip())
				EndDo
					
				// Altero a legenda do Pedido de Vendas		
				MaLiberOk({ cDoc },.T.)
					
					
				//Parametros ExpA1 : A - Array com os itens a serem gerados		 
				//           ExpC2 : C - Serie da Nota Fiscal 
				//           ExpL3 : F - Mostra Lct.Contabil 
				//           ExpL4 : F - Aglutina Lct.Contabil 
				//           ExpL5 : T - Contabiliza On-Line 
				//           ExpL6 : T - Contabiliza Custo On-Line 
				//           ExpL7 : F - Reajuste de preco na nota fiscal 
				//           ExpN8 : 0 - Tipo de Acrescimo Financeiro 
				//           ExpN9 : 0 - Tipo de Arredondamento 
				//           ExpLA : T - Atualiza Amarracao Cliente x Produto 
				//           ExplB : F - Cupom Fiscal 
				//           ExpCC : C - Numero do Embarque de Exportacao 
				//           ExpBD : 	Code block para complemento de atualizacao dos titulos financeiros. 
				//           ExpBE : 	Code block para complemento de atualizacao dos dados apos a geracao da nota fiscal. 
				//           ExpBF : 	Code Block de atualizacao do pedido de venda antes da geracao da nota fiscal. 
			
				// Seleciono a Série da Nota Fiscal						  
				If !lRet
					lRet 		:= Sx5NumNota(@cSerie,cTpNrNfs)
				Endif
					
				// Efetuo o faturamento do Pedido de Vendas
				If ! Empty(aPvlNfs)`
					Pergunte("MT461A",.F.)
					cNota := MaPvlNfs(aPvlNfs,@cSerie, .F. , .F. , .T. , .T. , .F. , 0 , 0 , .T. , .F.)
				Endif
				SC5->(CONFIRMSX8())
				lRet 		:= .T.
				aPvlNfs 	:= {}
			Else
				cLogTmp	:= ""
				cValInc	:= ""
				cValInc	:= "PEDIDO ("+ALLTRIM(SC5->C5_NUM)+"), NF ("+ALLTRIM(SC5->C5_NOTAIMP)+" / "+ALLTRIM(SC5->C5_SERIIMP)+")"
				AADD(aLinLog, {cArqOri, cLogTmp, nX, "7", cValInc})
	
				lRet := .F.
				SC5->(ROLLBACKSX8())
				DisarmTransaction()
			EndIf
		Endif
		//Restaura a Database do sistema
		dDataBase := dDtAtual
	Else
		aLogTmp := ARRAY(3)
		cLogTmp	:= ""
		AADD(aLinLog, {cArqOri, cLogTmp, 0, "2", ""}) //Sem dados para importação
	EndIf
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM06P

Parâmetros da Rotina.

@author  Allan Bonfim

@since   29/05/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM06P(aParam, aPergs)

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
		lValid	:= CAMBM06V(aParam, aPergs)
		lRet	:= .T.
	Else
		lValid	:= .T.
		lRet	:= .F.
	EndIf
Enddo

RestArea(aArea)

Return lRet                 

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM06V

Validação dos Parâmetros.

@author  Allan Bonfim

@since   29/05/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM06V(aPar, aPrgs)

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
/*/{Protheus.doc} CAMBM06R

Relatório com o resultado da importação.

@author  Allan Bonfim

@since   11/03/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
Static Function CAMBM06R(aCabec, aDadosLog)

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

oReport  := TReport():New("CAMBM006", "LOG DA IMPORTAÇÃO - NFE DE SAIDA", "", {|oReport| PrintReport(oReport, aDadosLog)}, "Log da Importação do Arquivo para as Notas Fiscais de Saída")

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

TRCell():New(oSection1, "ARQUIVO"	, "   ", ""	, "@!"	, 200, .F., {|| UPPER(ALLTRIM(aDadosLog[nX][1]))},, .T.)
oBreak := TRBreak():New(oSection1, oSection1:Cell("ARQUIVO"), "")

oSection2 := TRSection():New(oSection1, "ITENS", "   ")
oSection2:SetAutoSize(.F.) 
oSection2:SetPageBreak(.F.)
oSection2:SetHeaderBreak(.T.)

TRCell():New(oSection2, "ITEM"		, "   ", "ITEM"		, "@!"	, 015, .F., {|| STRZERO(aDadosLog[nX][3],4)},, .T.)
TRCell():New(oSection2, "LINHA"		, "   ", "LINHA"	, "@!"	, 500, .F., {|| ALLTRIM(aDadosLog[nX][2])},, .F.)
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
		cDescRet := "Falha na geração do Pedido de Vendas."
	Case cTipoLog == "6"
		cDescRet := "Falha na estrutura do arquivo."
	Case cTipoLog == "7"
		cDescRet := "Falha na liberação do Pedido de Vendas."
EndCase

Return cDescRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VALIDXML

Validação do Schema do XML.

@author  Allan Bonfim

@since   27/07/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
STATIC FUNCTION VALIDXML(cArqXML) 

Local lRet		:= .F.
Local cError	:= ""
Local cWarning 	:= ""
Local nZ		:= 0
Local aArqXDS	:= {}
Local cPathXSD 	:= SUPERGETMV("CB_VPSTXML",, "\SCHEMAS\")

Default cArqXML := "" 

If !EMPTY(cArqXML)
	aArqXDS := Directory(cPathXSD+"*.XSD")
	
	If Len(aArqXDS) == 0
		HELP(,, 'HELP',, "Não existem arquivos do Schema do XML na pasta ("+ALLTRIM(cPathXSD)+"). Entre em contato com o TI.", 1, 0)
		lRet := .F.	
	Else	
		For nZ := 1 To LEN(aArqXDS)
			If XMLFVLDSCH(cArqXML , cPathXSD+aArqXDS[nZ][1], @cError, @cWarning) 
				lRet := .T.
				Exit
	        EndIf
		Next
	EndIf
EndIf
	 
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LIBERPED

Liberação do Pedido de Vendas.

@author  Allan Bonfim

@since   27/07/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
STATIC FUNCTION LIBERPED(cNumPed)

Local aArea 	:= GetArea()
Local lRet		:= .T.

Default cNumPed	:= ""

DBSelectArea("SC5")
SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM

DbSelectArea("SC6")
SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

If SC5->(DbSeek(xFilial("SC5")+cNumPed))
	If SC6->(DbSeek(xFilial("SC6")+cNumPed))	
		//MaLibDoFat(nRegSC6,nQtdaLib,lCredito,lEstoque,lAvCred,lAvEst,lLibPar,lTrfLocal,aEmpenho,bBlock,aEmpPronto,lTrocaLot,lOkExpedicao,nVlrCred,nQtdalib2)
		
		While !SC6->(EOF()) .AND. SC6->C6_FILIAL == xFilial("SC6") .AND. SC6->C6_NUM == cNumPed
 			MALIBDOFAT(SC6->(RecNo()), SC6->C6_QTDVEN,,, .F., .F., .F., .F.)
		    
			//Begin Transaction
			//SC6->(MaLiberOk({cPed},.F.))
			//End Transaction

			SC6->(dBSkip())
		EndDo
	Else
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet     

//-------------------------------------------------------------------
/*/{Protheus.doc} GERANOTA

Geração da Nota Fiscal de Saída.

@author  Allan Bonfim

@since   07/08/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
STATIC FUNCTION GERANOTA(cNumPed)

Local aArea 	:= GetArea()
Local lRet		:= .F.

Default cNumPed	:= ""

Private aPvlNfs	:= {}

DBSelectArea("SC5")
SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM

DbSelectArea("SC6")
SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

DbSelectArea("SC9")
SC9->(DbSetOrder(1)) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

DbSelectArea("SE4")
SE4->(DbSetOrder(1)) //E4_FILIAL+E4_CODIGO

DbSelectArea("SB1")
SB1->(DbSetOrder(1)) //B1_FILIAL+B1_CODIGO

DbSelectArea("SB2")
SB2->(DbSetOrder(1)) //B2_FILIAL+B2_CODIGO+B2_LOCAL

DbSelectArea("SF4")
SF4->(DbSetOrder(1)) //F4_FILIAL+F4_CODIGO

If SC5->(DbSeek(xFilial("SC5")+cNumPed))
	If SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))
		While !SC6->(EOF()) .AND. SC6->C6_FILIAL == xFilial("SC6") .AND. SC6->C6_NUM == SC5->C5_NUM
			SC9->(DbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM))
			SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
			SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))	
			SB2->(DbSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL))
			SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES))
	
			//	nPrcVen := SC9->C9_PRCVEN
			//	If ( SC5->C5_MOEDA <> 1 )
			//		nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase)
			//	EndIf
	
			AADD(aPvlNfs, {	SC9->C9_PEDIDO,;
							SC9->C9_ITEM,;
							SC9->C9_SEQUEN,;
							SC9->C9_QTDLIB,;
							SC9->C9_PRCVEN,;
							SC9->C9_PRODUTO,;
							.F.,;
							SC9->(RECNO()),;
							SC5->(RECNO()),;
							SC6->(RECNO()),;
							SE4->(RECNO()),;
							SB1->(RECNO()),;
							SB2->(RECNO()),;
							SF4->(RECNO())})

			SC6->(DbSkip())
		EndDo
	EndIf
EndIf

//Numero para o ponto de entrada M460NUM
//cNumIMP001 := cDoc
If Len(aPvlNfs) > 0
	//lRet := !EMPTY(MAPVLNFS(aPvlNfs, SC5->C5_SERIIMP, .F., .F., .F., .T., .F., 0, 0, .T., .F.))    
	lRet := !EMPTY(MAPVLNFS(aPvlNfs, SC5->C5_SERIIMP, .F., .F., .F., .T., .F., 0, 0, .T., .F.))    
EndIf
/*/
±±³Parametros³ExpA1: Array com os itens a serem gerados                   ³±±
±±³          ³ExpC2: Serie da Nota Fiscal                                 ³±±
±±³          ³ExpL3: Mostra Lct.Contabil                                  ³±±
±±³          ³ExpL4: Aglutina Lct.Contabil                                ³±±
±±³          ³ExpL5: Contabiliza On-Line                                  ³±±
±±³          ³ExpL6: Contabiliza Custo On-Line                            ³±±
±±³          ³ExpL7: Reajuste de preco na nota fiscal                     ³±±
±±³          ³ExpN8: Tipo de Acrescimo Financeiro                         ³±±
±±³          ³ExpN9: Tipo de Arredondamento                               ³±±
±±³          ³ExpLA: Atualiza Amarracao Cliente x Produto                 ³±±
±±³          ³ExplB: Cupom Fiscal                                         ³±±
±±³          ³ExpCC: Numero do Embarque de Exportacao                     ³±±
±±³          ³ExpBD: Code block para complemento de atualizacao dos titu- ³±±
±±³          ³       los financeiros.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
/*/	     
If lRet
	
	SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM
	SC5->(DbSeek(xFilial("SC5")+cNumPed))
	
	DbSelectArea("SF2")
	DbSetOrder(2) //F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE
	If SF2->(DbSeek(xFilial("SF2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI+AVKEY(SC5->C5_NOTAIMP, "F2_DOC")+AVKEY(SC5->C5_SERIIMP, "F2_SERIE")))
		RecLock("SF2", .F.)
			SF2->F2_CHVNFE 	:= SC5->C5_CNFEIMP
			SF2->F2_XIMPORT := "S"
		SF2->(MsUnlock())
	EndIf
	
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ATUFISCAL

Atualização dos Livros Fiscais da Nota Fiscal de Saída Importada.

@author  Allan Bonfim

@since   07/08/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
STATIC FUNCTION ATUFISCAL(cNumPed)

Local aArea 	:= GetArea()
Local lRet		:= .T.

Default cNumPed	:= ""

DBSelectArea("SD2")
SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

DBSelectArea("SC5")
SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM

DbSelectArea("SF3")
SF3->(DbSetOrder(4)) //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE

DbSelectArea("SFT")
SFT->(DbSetOrder(1)) //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO

SC5->(DbSeek(xFilial("SC5")+cNumPed))
	
If SF3->(DbSeek(xFilial("SF3")+SC5->C5_CLIENTE+SC5->C5_LOJACLI+AVKEY(SC5->C5_NOTAIMP, "F3_NFISCAL")+AVKEY(SC5->C5_SERIIMP, "F3_SERIE")))
	
	While 	!SF3->(EOF()) .AND. SF3->F3_FILIAL == xFilial("SF3") .AND. SF3->F3_CLIEFOR == SC5->C5_CLIENTE .AND. SF3->F3_LOJA == SC5->C5_LOJACLI .AND. ;
			SF3->F3_NFISCAL == AVKEY(SC5->C5_NOTAIMP, "F2_DOC") .AND. SF3->F3_SERIE == AVKEY(SC5->C5_SERIIMP, "F2_SERIE")
						
		RecLock("SF3", .F.)
			SF3->F3_CHVNFE 	:= SC5->C5_CNFEIMP
			SF3->F3_XIMPORT := "S"
			//SF3->F3_BASERET := 0
		SF3->(MsUnlock())                                                             
        
		//If SD2->(DbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
		//   	While !SD2->(EOF()) .and. SF3->F3_FILIAL == xFilial("SF3") .AND. SF3->F3_NFISCAL == SD2->D2_DOC .AND. SF3->F3_SERIE == SD2->D2_SERIE .AND. ;
		//   		  SF3->F3_CLIEFOR == SD2->D2_CLIENTE .AND. SF3->F3_LOJA == SD2->D2_LOJA
		//   		if SF3->F3_ALIQICM == SD2->D2_PICM
		//			RecLock("SF3", .F.)
		//				SF3->F3_BASERET := SF3->F3_BASERET + SD2->D2_BRICMS
		//			SF3->(MsUnlock())
		//		endif	                                                              
        //        SD2->(DbSkip())
        //    Enddo
        //Endif           

		SF3->(DbSkip())                         
	EndDo
	                                                                                                                                                              
 	If SFT->(DbSeek(xFilial("SFT")+AVKEY("S", "FT_TIPOMOV")+AVKEY(SC5->C5_SERIIMP, "FT_SERIE")+AVKEY(SC5->C5_NOTAIMP, "FT_NFISCAL")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
 		While 	!SFT->(EOF()) .AND. SFT->FT_FILIAL == xFilial("SFT") .AND. SFT->FT_TIPOMOV == AVKEY("S", "FT_TIPOMOV") .AND. SFT->FT_SERIE == AVKEY(SC5->C5_SERIIMP, "FT_SERIE") .AND. ;
 				SFT->FT_NFISCAL == AVKEY(SC5->C5_NOTAIMP, "FT_NFISCAL") .AND. SFT->FT_CLIEFOR == SC5->C5_CLIENTE .AND. SFT->FT_LOJA == SC5->C5_LOJACLI
									
			RecLock("SFT", .F.)
				SFT->FT_CHVNFE 	:= SC5->C5_CNFEIMP
				SFT->FT_XIMPORT := "S"
			SFT->(MsUnlock())    
			
			//If SD2->(DbSeek(xFilial("SD2")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO+SFT->FT_ITEM))
			//	RecLock("SFT", .F.)
			//		SFT->FT_BASERET := SD2->D2_BRICMS
			//	SFT->(MsUnlock())
			//endif	                                                                      
        	
        	DBSELECTAREA("SFT")
        	      
			SFT->(DbSkip())
		EndDo                 
 	Else
		lRet := .F.
	EndIf	
Else
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet                            


//-------------------------------------------------------------------
/*/{Protheus.doc} CADPRDOLD

Cadastro do Produto para os códigos antigos e não encontrados

@author  Allan Bonfim

@since   30/09/2015

@version P11
 
@param

@obs

@return

/*/
//-------------------------------------------------------------------
STATIC FUNCTION CADPRDOLD(cCodSB1, cDescSB1, cUmSB1, cNcmSB1, cOrigSB1)

Local aAreaAtu	:=	GetArea()
Local aAreaB1C	:=	SB1->(GetArea())
Local cCodRet	:= ""

Default cCodSB1	:= ""
Default cDescSB1:= ""
Default cUmSB1	:= ""
Default cNcmSB1	:= ""
Default cOrigSB1:= "0"

If !EMPTY(cCodSB1) .AND. !EMPTY(cDescSB1) .AND. !EMPTY(cUmSB1) .AND. !EMPTY(cNcmSB1)
	SB1->(DbSetOrder(1))
	//A rotina não foi feita via ExecAuto devido a vários campos obrigatórios e validações de informações não existentes no XML da nota.
	If !SB1->(DbSeek(xFilial("SB1")+AVKEY(cCodSB1, "B1_COD"))) 
		Reclock("SB1", .T.)
			SB1->B1_COD		:= AVKEY(cCodSB1, "B1_COD")
			SB1->B1_XANTIGO	:= AVKEY(cCodSB1, "B1_COD")			
			SB1->B1_DESC	:= AVKEY(cDescSB1, "B1_DESC")
			SB1->B1_TIPO	:= AVKEY("ME", "B1_TIPO")		
			SB1->B1_UM		:= AVKEY(cUmSB1, "B1_UM")
			SB1->B1_LOCPAD	:= AVKEY("01", "B1_LOCPAD")
			SB1->B1_GRUPO	:= AVKEY("FIS", "B1_GRUPO")
			SB1->B1_POSIPI	:= AVKEY(cNcmSB1, "B1_POSIPI")
			SB1->B1_ORIGEM	:= AVKEY(cOrigSB1, "B1_ORIGEM")						
		SB1->(MsUnlock())

		cCodRet := SB1->B1_COD
	EndIf
EndIf

RestArea(aAreaB1C)
RestArea(aAreaAtu)

Return cCodRet


Static Function FmtXAntigo(cCod)
	Local cRet := ""
	
	If IsNumeric(cCod)
		Str(Val(cCod), 8)
	Else 
		cRet := Space(8)
	EndIf
		
Return cRet