#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"  

//___________________________________________________
User Function CAMBR01(xAlias, cSeq)

	Local aPergs  	 := {}
	Local _nOpca 
	Local _cPedido := SC9->C9_PEDIDO
	Local _cFilial := SC9->C9_FILIAL // DJALMA BORGES 11/01/2017
	Local cQuery	:= ""
	Local aSeq		:= GetSeqs()
	Local aPergs	:= {}
	Local aParam	:= {}
	Local lImpRom := .T. // DJALMA BORGES 27/12/2016
	
	Default xAlias := ""
	Default cSeq	:= aSeq[Len(aSeq)] //Ultima sequencia

	Private _lPag    := .T.
	Private _cAlias := GetNextAlias()
	Private _lViaLib := .f.
	Private nLinCabTot := 0
	Private nColCabTot := 0
	Private cSeqImp	   := cSeq
	
	
	If AllTrim(FunName()) == "CAMBC002"
		aAdd(aPergs, {2, "Sequencia"	   				, "Todas", aSeq, 80, , .T.})
		If ParamBox(aPergs, "Parametros ", @aParam)
			cSeqImp := aParam[1]
		Else
			Return
		EndIf
	EndIf

	if xAlias <> ""
		_cPedido := (xAlias)->C5_NUM
		_cFilial := (xAlias)->C5_FILIAL // DJALMA BORGES 11/01/2017
		_nOpca := 4       
		_lviaLib := .f.
	Else		
		_nOpca := ParamIxb[1]		
	Endif

	if _nOpca == 4  //LIB TODOS
		cQuery := "		SELECT * " + CRLF 
		cQuery += "		FROM ( " + CRLF 
		cQuery += "			SELECT *, R_E_C_N_O_ REC_SC9 " + CRLF 
		cQuery += "				FROM " + RetSqlName("SC9") + " SC9" + CRLF 
		cQuery += "				WHERE SC9.D_E_L_E_T_ = ' '" + CRLF 
		cQuery += "				AND C9_PEDIDO = '" + _cPedido + "'" + CRLF 
		cQuery += "				AND C9_FILIAL = '" + _cFilial + "'" + CRLF
//		cQuery += "				AND C9_BLEST = ''" + CRLF -> DJALMA BORGES 11/01/2017 
//		cQuery += "				AND C9_BLCRED = ''" + CRLF -> NÃO HÁ IMPRESSÃO DE ROMANEIO COM LIBERAÇÃO PARCIAL
		cQuery += "				) SC9			" + CRLF 
		cQuery += "			INNER JOIN (" + CRLF 
		cQuery += "				SELECT B1_COD, B1_DESC, B1_PROC" + CRLF 
		cQuery += "				FROM " + RetSqlName("SB1") + " SB1" + CRLF 
		cQuery += "				WHERE SB1.D_E_L_E_T_ = ' '" + CRLF 
		cQuery += "				) SB1" + CRLF 
		cQuery += "				ON C9_PRODUTO = B1_COD" + CRLF 
//		cQuery += "			INNER JOIN "+ RetSqlName("SUB") + " SUB" + CRLF  
		cQuery += "			LEFT JOIN "+ RetSqlName("SUB") + " SUB" + CRLF // ALTERADO POR DJALMA BORGES 22/12/2016
		cQuery += "				ON C9_FILIAL = UB_FILIAL" + CRLF 
		cQuery += "				AND C9_PEDIDO = UB_NUMPV" + CRLF 
		cQuery += "				AND C9_ITEM = UB_ITEMPV" + CRLF 
		If cSeqImp <> "Todas"
			cQuery += "				AND UB_XSEQ = '" + cSeqImp + "'" + CRLF
		EndIf 
		cQuery += "				AND SUB.D_E_L_E_T_ = ' '" + CRLF 
		cQuery += "			LEFT JOIN (" + CRLF 
		cQuery += "				SELECT * " + CRLF 
		cQuery += "				FROM " + RetSqlName("SDC") + " SDC" + CRLF 
		cQuery += "				WHERE SDC.D_E_L_E_T_ = ' '" + CRLF 
		cQuery += "				) SDC" + CRLF 
		cQuery += "				ON C9_FILIAL = DC_FILIAL " + CRLF 
		cQuery += "					AND C9_PEDIDO 	= DC_PEDIDO " + CRLF 		
		cQuery += "					AND C9_ITEM		= DC_ITEM" + CRLF 
		cQuery += "					AND C9_PRODUTO	= DC_PRODUTO" + CRLF 
		cQuery += "			LEFT JOIN (" + CRLF 
		cQuery += "				SELECT A5_PRODUTO, A5_CODPRF, A5_FORNECE" + CRLF 
		cQuery += "				FROM " + RetSqlName("SA5") + " SA5" + CRLF 
		cQuery += "				WHERE SA5.D_E_L_E_T_ = ' '" + CRLF 
		cQuery += "					AND A5_FILIAL = '" + xFilial("SA5") + "'" + CRLF 
		cQuery += "				) SA5" + CRLF 
		cQuery += "        		ON B1_PROC = A5_FORNECE " + CRLF 
		cQuery += "        			AND B1_COD = A5_PRODUTO" + CRLF
		// DJALMA BORGES 27/12/2016 - INÍCIO
		cQuery += "			INNER JOIN (" + CRLF
		cQuery += "				SELECT C6_NUM, C6_PRODUTO, C6_ITEM, C6_QTDVEN" + CRLF
		cQuery += "				FROM SC6010 SC6" + CRLF
		cQuery += "				WHERE SC6.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "				) SC6" + CRLF
		cQuery += "				ON C6_NUM + C6_PRODUTO + C6_ITEM = C9_PEDIDO + C9_PRODUTO + C9_ITEM" + CRLF
		// DJALMA BORGES 27/12/2016 - FIM 
		cQuery += "			ORDER BY UB_XSEQ, DC_LOCALIZ" + CRLF 

		TCQUERY cQuery NEW ALIAS (_cAlias)

		dbSelectArea(_cAlias)
		
		(_cAlias)->(dbGotop()) // SÓ IMPRIME SE QTDLIB FOR IGUAL A QTDVEN - DJALMA BORGES 31/12/2016 - E SE NÃO TIVER BLOQUEIO 02/01/2017
		While (_cAlias)->(!EOF())
			If (_cAlias)->C9_QTDLIB <> (_cAlias)->C6_QTDVEN .or. !Empty((_cAlias)->C9_BLEST) .or. !Empty((_cAlias)->C9_BLCRED) 
				lImpRom := .F.
			EndIf
			(_cAlias)->(dbSkip())
		EndDo
		
		(_cAlias)->(dbGotop())
		
		if ! (_cAlias)->(eof()) .and. lImpRom == .T. 
		
			Processa({||ImpRoma((_cAlias)->C9_PEDIDO)}, "Gerando os Romaneios..")

		Endif

		(_cAlias)->(dbCloseArea())

	Endif

Return

//___________________________________________________
Static Function ImpRoma(cPedido)
	Local oPrint
	Local oDlg
	Local i 	     := 1
	Local x 	     := 0
	Local lin 	     := 0
	Local lAdjustToLegacy := .f. 
	Local lDisableSetup  := .T. // .T. RAPHAEL // MUDEI PARA TRUE - DJALMA 20/12/2016

	Private nMargem  := 00
	Private oFont16N,oFont16,oFont14N,oFont12N,oFont10N,oFont14,oFont12,oFont10,oFont08
	Private cTexto   := ""
	Private	nValMerc := 0
	Private	nValDesc := 0
	Private	nValIpi  := 0
	Private	nValSrv  := 0
	Private	nValTot  := 0

	Private _nTotIcm := 0
	Private _nTotIpi := 0
	Private _nTotSol := 0
	Private aImp     := {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

	oFont14N	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
	oFont14 	:= TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
	oFont13	:= TFont():New("Arial",13,13,,.F.,,,,.T.,.F.)
	oFont13N	:= TFont():New("Arial",13,13,,.T.,,,,.T.,.F.)
	oFont12	:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
	oFont12N	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
	oFont11	:= TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)
	oFont11N	:= TFont():New("Arial",11,11,,.T.,,,,.T.,.F.)
	oFont10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
	oFont10N	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
	oFont9		:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
	oFont9N	:= TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)

	// CONFORME A FILIAL LOGADA DEVE MANDAR PARA UMA IMPRESSORA DIFERENTE - DJALMA BORGES 22/12/2016
	If xFilial("SC9") $ "0101,0202" 
		_cPrinter := GETNEWPAR("CB_PRINTSP","HP LASERJET 600 M602")
		_lServer := .f.
	EndIf
	If xFilial("SC9") $ "0102,0201" 
		_cPrinter := GETNEWPAR("CB_PRINTPR","HP LASERJET 600 M602")
		_lServer := .f.
	EndIf
	
	//oPrintSetup := FWPrintSetup():New(PD_ISTOTVSPRINTER, "Set Device Printer")
                     
	oPrint := FWMSPrinter():New("CAMBR01.rel", IMP_SPOOL, lAdjustToLegacy, "\spool\", lDisableSetup, ,/*oPrintSetup*/, _cPrinter, _lServer)
    oPrint:cPrinter := _cPrinter                   
                       
	//if ! _lViaLib    // Se chamada não foi via liberação de credito estoque ativa tela de setup
	//	oPrint:Setup()                       
	//Endif
                                      
	oPrint:SetResolution(72)
	oPrint:SetLandScape()
	oPrint:SetPaperSize(DMPAPER_A4) 
	oPrint:SetMargin(50,10,50,50) 

// nEsquerda, nSuperior, nDireita, nInferior 

//	oPrint:cPathPDF := "c:\directory\" 

// Caso seja utilizada impressão em IMP_PDF

	MontaRel(oPrint,@i,.F., cPedido)

Return

//_______________________________________________________________
Static Function MontaRel(oPrint,i,lPreview, cNumPed)

	Private lin := 0, lEnt := .F.
	Private cFig := GetSrvProfString("StartPath","")
	Private _nTotal := 0

//cFig += "LGRL01.BMP"
	cFig += "DANFE010101.BMP"
	cTexto  := ""

//	_nTotal := TotalPed(cNumPed)

	SA1->(Dbseek(xFilial("SA1")+(_cAlias)->(C9_CLIENTE+C9_LOJA)))
	SC5->(Dbseek(xFilial("SC5")+(_cAlias)->C9_PEDIDO))
	SA3->(Dbseek(xFilial("SA3")+SC5->C5_VEND1))
	SA4->(Dbseek(xFilial("SA4")+SC5->C5_TRANSP))

	nValMerc := 0
	nValDesc := 0
	nValTot  := 0

	Cabecalho(oPrint,@i, cNumPed)

	Detail(oPrint,@i, cNumPed)

	oPrint:EndPage()

	If lPreview
		oPrint:Preview()
	Else
		oPrint:Print()
	Endif

	Ms_Flush()

	oPrint:SaveAllasJpeg("\SIGAADV\ORCAM\"+cNumped,2500,2500)

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³Descricao ³ Cabecalho do relatorio                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cabecalho(ExpO1,ExpN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpN1 = Contador de paginas                                ³±±
±±³          ³ ExpN2 = Modelo do layout do relatorio                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ARS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
************************************
Static Function Cabecalho(oPrint,i, cNumPed)
************************************

// Corrige problema na MSPRINTER()

	If !File(cFig)
		__CopyFile(Substr(cFig,1,Len(cFig)-4)+".BKP",Substr(cFig,1,Len(cFig)-4)+".BMP")
	Endif

	oPrint:StartPage() 		// Inicia uma nova pagina

	Set Century On

	oPrint:Line( lin+30,0+nMargem,lin+30, 810+nMargem, , "-5" )

	oPrint:Say(lin+045,000+nMargem,"Pedido: "+cNumPed,oFont14N)
	oPrint:Say(lin+045,360+nMargem,"R O M A N E I O",oFont14N)
	oPrint:Say(lin+045,760+nMargem,"PAG - "+Strzero(i,2),oFont9)

	oPrint:Say(lin+060,000+nMargem,"Dt. Pedido: "+DTOC(SC5->C5_EMISSAO),oFont10)
	oPrint:Say(lin+060,360+nMargem,"Dt. Emi: "+DTOC(dDataBase),oFont10)
	oPrint:Say(lin+060,720+nMargem,"Valor Total",oFont12N)

	oPrint:Say(lin+075,000+nMargem,"Cliente: "+alltrim(SA1->A1_NOME)+"  ("+SC5->C5_CLIENTE+"-"+SC5->C5_LOJACLI+")",oFont10)
	oPrint:Say(lin+075,360+nMargem,"Vend. EXT: "+alltrim(SA3->A3_NOME)+"  ("+SC5->C5_VEND1+")",oFont10)

	nLinCabTot := lin+075
	nColCabTot := 720+nMargem 
	
	oPrint:Say(lin+090,000+nMargem,"CNPJ: "+SA1->A1_CGC,oFont10)
	SA3->(Dbseek(xFilial("SA3")+SC5->C5_VEND2))
	oPrint:Say(lin+090,360+nMargem,"Vend. INT: "+alltrim(SA3->A3_NOME)+"  ("+SC5->C5_VEND2+")",oFont10)

	oPrint:Say(lin+105,000+nMargem,"Endereço: "+alltrim(SA1->A1_END)+" - "+alltrim(SA1->A1_MUN)+" - "+SA1->A1_EST,oFont10)
	oPrint:Say(lin+105,360+nMargem,"Transp: "+SA4->A4_NOME+   "("+SC5->C5_TRANSP+")",oFont10)
	oPrint:Say(lin+105,720+nMargem, "Seq. Impressão: " + cSeqImp, oFont12N)



	oPrint:Line(lin+108, 0+nMargem, lin+108, 810+nMargem, , "-5" )

	lin := lin + 108

	oPrint:Say(lin+10,0000+nMargem,"Localização",oFont12)
	oPrint:Say(lin+10,0090+nMargem,"Qtde",oFont12)
	oPrint:Say(lin+10,0125+nMargem,"Sep",oFont12)
	oPrint:Say(lin+10,0158+nMargem,"Nro. Original",oFont12)
	oPrint:Say(lin+10,0240+nMargem,"Refer.Vda",oFont12)
	oPrint:Say(lin+10,0310+nMargem,"Cod.For.",oFont12)
	oPrint:Say(lin+10,0380+nMargem,"Descrição",oFont12)
	oPrint:Say(lin+10,0625+nMargem,"Armaz",oFont12)
//	oPrint:Say(lin+10,0620+nMargem,"Vend.",oFont12)
	oPrint:Say(lin+10,0670+nMargem,"Vlr.Uni",oFont12)
	oPrint:Say(lin+10,0720+nMargem,"Vlr.Tot",oFont12)
	oPrint:Say(lin+10,0790+nMargem,"Item",oFont12)

	oPrint:Line(lin+015, 0+nMargem, lin+015, 810+nMargem, , "-5" )

	lin += 035

	Set century Off

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Detail(ExpO1,ExpN1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpN1 = Contador de paginas                                ³±±
±±³          ³ ExpN2 = Modelo do layout do relatorio                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ARS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Detail(oPrint,i, cNumPed)
	Private nItens    := 0
	Private nVlTot	:= 0
	Private _nTotIcm := 0
	Private _nTotIpi := 0
	Private _nTotSol := 0
	

	ItensPed(oPrint,@i, cNumPed) // Imprime os Itens do Pedido de vendas
	DadosGer(oPrint,@i) // Imprime dados das Condicoes Gerais
	Observa(oPrint,@i)
	
Return lin



//__________________________________
Static Function ItensPed(oPrint,i, cNumPed)

	Local nValorUni 	:= 0
	Local nValorTot	:= 0
	Local nQtde		:= 0
	Local nValIPI 	:= 0
	Local nValDesc 	:= 0

	DbSelectArea(_cAlias)
	(_cAlias)->(DbGotop())
	SC5->(Dbseek(xFilial("SC5")+(_cAlias)->C9_PEDIDO))
	While (_cAlias)->(C9_FILIAL+C9_PEDIDO) == xFilial("SC9")+cNumPed .and. !(_cAlias)->(Eof())
	
	  	If (_cAlias)->UB_XSEQ == cSeqImp .or. cSeqImp == "Todas" // DJALMA BORGES 05/01/2017
		
			SC6->(DbGoTop())
			SC6->(Dbseek(xFilial("SC6")+(_cAlias)->C9_PEDIDO+(_cAlias)->C9_ITEM))
			SF4->(Dbseek(xFilial("SF4")+SC6->C6_TES))		
			
			_cTipoCli := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_TIPO")
			fCalcImp(SC5->C5_CLIENTE,SC5->C5_LOJACLI,_cTipoCli,(_cAlias)->C9_PRODUTO,SC6->C6_TES,(_cAlias)->C9_QTDLIB,(_cAlias)->C9_PRCVEN, (_cAlias)->C9_PRCVEN * (_cAlias)->C9_QTDLIB)
		
			nItens++
		
			If lin > 540
				i++
				//oPrint:Line( 0550, 0+nMargem, 0550, 810+nMargem, , "-5" )
				oPrint:Say(lin+15,0555+nMargem,"Continua na Página: "+Strzero(i,3),oFont12)
	            lin+=15                      
	            
	            Observa(oPrint,@i)
									
				oPrint:EndPage() 		// Finaliza a pagina
				_lPag := .F.
				Lin:= 0
				Cabecalho(oPrint,i, cNumPed)		
			Endif
		
			SB1->(Dbseek(xFilial("SB1")+(_cAlias)->C9_PRODUTO))
		
		
			nValorUni 	:= (_cAlias)->C9_PRCVEN
			nQtde	  	:= (_cAlias)->C9_QTDLIB
	//		nValorTot 	:= (_cAlias)->C9_QTDLIB * (_cAlias)->C9_PRCVEN
			nValorTot 	:= (_cAlias)->DC_QUANT  * (_cAlias)->C9_PRCVEN // DJALMA BORGES 22/12/2016
			nValMerc  	+= nValorTot
			nVltot    	:= NOROUND((_cAlias)->C9_QTDLIB * (_cAlias)->C9_PRCVEN )
		
			//Impostos
			_nTotIcm += aImp[4]
			_nTotIpi += aImp[5]
			_nTotSol += aImp[16]
		
			If  SA1->A1_TIPO <> "X" .and. SF4->F4_IPI=="S" // !Empty(SB1->B1_IPI) .and.
			
				If SF4->F4_IPIFRET == "S"
					nPerc := (_cAlias)->C9_PRCVEN / _nTotal
					nValFret := Round(SC5->C5_FRETE * nPerc,2)
				Else
					nValFret := 0
				EndIf
				nValIpi += Round((nVlTot+nValFret) * (SB1->B1_IPI/100),2)
			
			Endif
		
			nValDesc += SC6->C6_VALDESC
	
			oPrint:Say(lin, 0000+nMargem, (_cAlias)->DC_LOCALIZ								, oFont13N)
	//		oPrint:Say(lin, 0085+nMargem, Transform(INT((_cAlias)->C9_QTDLIB),"@E 999")		, oFont11)
			oPrint:Say(lin, 0085+nMargem, CVALTOCHAR(INT((_cAlias)->DC_QUANT))				, oFont11) // DJALMA BORGES 22/12/2016
			oPrint:Say(lin, 0125+nMargem, "(        )"										, oFont11)
			oPrint:Say(lin, 0158+nMargem, SB1->B1_COD										, oFont11)
			oPrint:Say(lin, 0240+nMargem, SC6->C6_XCODREF									, oFont11)
			oPrint:Say(lin, 0310+nMargem, substr((_cAlias)->A5_CODPRF,1,15)					, oFont10)
			oPrint:Say(lin, 0380+nMargem, substr(SB1->B1_DESC,1,50)							, oFont11)
	//		oPrint:Say(lin, 0630+nMargem, (_cAlias)->C9_LOCAL								, oFont11)
			oPrint:Say(lin, 0630+nMargem, (_cAlias)->DC_LOCAL								, oFont11) // DJALMA BORGES 22/12/2016
	//		oPrint:Say(lin, 0620+nMargem, SC5->C5_VEND2										, oFont12)
			oPrint:Say(lin, 0670+nMargem, Transform((_cAlias)->C9_PRCVEN,"@E 99,999.999")	, oFont11)
			oPrint:Say(lin, 0730+nMargem, Transform(nValorTot,"@E 99,999.999")				, oFont11)
			oPrint:Say(lin, 0800+nMargem, (_cAlias)->C9_ITEM								, oFont11)
		    
			oPrint:Line( lin+7, 0+nMargem, lin+7, 810+nMargem, , "-2" )
			lin += 17
		
		EndIf
			
		(_cAlias)->(Dbskip())
				
	EndDo

	If lin > 0470  
		i++
		oPrint:Line( 0510, 0+nMargem, 0510, 810+nMargem, , "-5" )
	
		oPrint:EndPage() 		// Finaliza a pagina
		Lin:= 165
		Cabecalho(oPrint,@i, cNumPed)
	Else
		oPrint:Line( lin, 0+nMargem, lin, 810+nMargem, , "-5" )

		lin += 10
	Endif

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄü¿
//³Impressao dos dados do cliente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄüÙ


//_____________________________________________

Static Function DadosGer(oPrint,i)

	nValTot := nValMerc + nValIpi + nValSrv
	nValTot += SC5->(C5_DESPESA+C5_SEGURO+C5_FRETE)


//Total ST
//oPrint:Say(lin,100+nMargem,"   Total do ICMS R$ ",oFont10N)
//oPrint:Say(lin,330+nMargem,Transform(_nTotIcm,"@E 999,999,999.99"),oFont10N)

	oPrint:Say(lin,000+nMargem,"Nro de Itens do Pedido : "+ALLTRIM(str(nItens)),oFont10N)
	nItens := 0

//Total IPI
	oPrint:Say(lin,300+nMargem,"   Total do Ipi R$ ",oFont10N)
	oPrint:Say(lin,360+nMargem,Transform(_nTotIpi,"@E 999,999,999.99"),oFont10N)

//Total Solidário
	oPrint:Say(lin,460+nMargem,"   Total do ICMS ST R$ ",oFont10N)
	oPrint:Say(lin,550+nMargem,Transform(_nTotSol,"@E 999,999,999.99"),oFont10N)


	oPrint:Say(lin,625+nMargem,"Total Mercadoria R$ ",oFont10N)
	oPrint:Say(lin,700+nMargem,Transform(nValTot,"@E 999,999,999.99"),oFont12N)

	//Valor Total do Cabeçalho com icms
	oPrint:Say(nlinCabTot,nColCabTot,Transform(nValTot+_nTotSol+_nTotIpi , "@E 999,999.99"   ),oFont12N)

	lin += 50
               
	oPrint:Line( lin, 000+nMargem, lin, 200+nMargem, , "-5" )
	oPrint:Line( lin, 300+nMargem, lin, 500+nMargem, , "-5")
	oPrint:Line( lin, 610+nMargem, lin, 810+nMargem, , "-5")

	lin += 20

	oPrint:Say(lin,075+nMargem,"SEPARADOR",oFont14N)
	oPrint:Say(lin,355+nMargem,"CONFERENTE",oFont14N)
	oPrint:Say(lin,655+nMargem,"EMBALADOR",oFont14N)

Return

Static Function Observa(oPrint,i)
Local _cObs := alltrim(SC5->C5_ZZOBS)
      
	oPrint:Say(558,000+nMargem,_cObs,oFont14N)

Return

// Calcula impostos por item              
//___________________________________________________
Static Function fCalcImp(cCliente,cLoja,cTipo,cProduto,cTes,nQtd,nPrc,nValor)
 
	aImp := {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
 
    // -------------------------------------------------------------------
    // Realiza os calculos necessários
    // -------------------------------------------------------------------
	MaFisIni(cCliente,;                    // 1-Codigo Cliente/Fornecedor
	cLoja,;                                // 2-Loja do Cliente/Fornecedor
	"C",;                                  // 3-C:Cliente , F:Fornecedor
	"N",;                                  // 4-Tipo da NF
	cTipo,;                                // 5-Tipo do Cliente/Fornecedor
	MaFisRelImp("MTR700",{"SC5","SC6"}),;  // 6-Relacao de Impostos que suportados no arquivo
	,;                                     // 7-Tipo de complemento
	,;                                     // 8-Permite Incluir Impostos no Rodape .T./.F.
	"SB1",;                                // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
	"MTR700")                              // 10-Nome da rotina que esta utilizando a funcao
 
    // -------------------------------------------------------------------
    // Monta o retorno para a MaFisRet
    // -------------------------------------------------------------------
	MaFisAdd(cProduto, cTes, nQtd, nPrc, 0, "", "",, 0, 0, 0, 0, nValor, 0)
 
    //Monta um array com os valores necessários
 
	aImp[1] := cProduto
	aImp[2] := cTes
	aImp[3] := MaFisRet(1,"IT_ALIQICM")  //Aliquota ICMS
	aImp[4] := MaFisRet(1,"IT_VALICM")  //Valor de ICMS
	aImp[5] := MaFisRet(1,"IT_VALIPI")  //Valor de IPI
	aImp[6] := MaFisRet(1,"IT_ALIQCOF") //Aliquota de calculo do COFINS
	aImp[7] := MaFisRet(1,"IT_ALIQPIS") //Aliquota de calculo do PIS
	aImp[8] := MaFisRet(1,"IT_ALIQPS2") //Aliquota de calculo do PIS 2
	aImp[9] := MaFisRet(1,"IT_ALIQCF2") //Aliquota de calculo do COFINS 2
	aImp[10]:= MaFisRet(1,"IT_DESCZF")  //Valor de Desconto da Zona Franca de Manaus
	aImp[11]:= MaFisRet(1,"IT_VALPIS")  //Valor do PIS
	aImp[12]:= MaFisRet(1,"IT_VALCOF")  //Valor do COFINS
	aImp[13]:= MaFisRet(1,"IT_BASEICM") //Valor da Base de ICMS
	aImp[14]:= MaFisRet(1,"IT_BASESOL") //Base do ICMS Solidario
	aImp[15]:= MaFisRet(1,"IT_ALIQSOL") //Aliquota do ICMS Solidario
	aImp[16]:= MaFisRet(1,"IT_VALSOL" ) //Valor Solidário
	aImp[17]:= MaFisRet(1,"IT_MARGEM")  //Margem de lucro para calculo da Base do ICMS Sol.
           
	MaFisSave()
	MaFisEnd()
 
Return aImp


//_______________________________ TOTAL DO PEDIDO
Static Function TotalPed(_cNumPed)
	Local _cAlias := GetNextAlias()
	Local _nTotal := 0

	BeginSql Alias _cAlias

		Column C9_PRCVEN as numeric(14,2)

		%noparser%

		SELECT SUM(C9_PRCVEN * C9_QTDLIB ) C9_PRCVEN
		FROM %Table:SC9%
		WHERE %NotDel%
		AND C9_PEDIDO = %Exp:_cNumPed%

	EndSql

	_nTotal := (_cAlias)->C9_PRCVEN

	(_cAlias)->(dbCloseArea())

Return(_nTotal)


Static Function GetSeqs()
	Local cAliasTmp := GetNextAlias()
	Local cQuery	:= ""
	Local aSeq		:= {}
	Local cFil		:= ""
	Local cNum		:= ""
	
	If AllTrim(FunName()) == "CAMBC002"
		cFil := TRB->C5_FILIAL
		cNum := TRB->C5_NUM
	Else
		cFil := SC9->C9_FILIAL
		cNum := SC9->C9_PEDIDO
	EndIf
	
	cQuery := "SELECT UB_XSEQ FROM " + RetSqlName("SUB") + " SUB" + CRLF
	cQuery += " WHERE UB_FILIAL = '" + cFil + "'" + CRLF
	cQuery += " AND UB_NUMPV = '" + cNum + "'" + CRLF
	cQuery += " AND D_E_L_E_T_ = ' '" + CRLF
	cQuery += " GROUP BY UB_XSEQ" + CRLF
	cQuery += " ORDER BY UB_XSEQ" + CRLF
	
	TCQUERY cQuery NEW ALIAS (cAliasTmp)
	
	aAdd(aSeq, "Todas")
	
	While !Eof()
		aAdd(aSeq, UB_XSEQ)
		DbSkip()
	EndDo
	
	If Select(cAliasTmp) > 0
		(cAliasTmp)->(DbCloseArea())
	EndIf
	
Return aSeq
