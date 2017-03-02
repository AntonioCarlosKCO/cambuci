#include "totvs.ch"
#include "topconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#include "Ap5Mail.ch"

#DEFINE NMARGLEFT 15
#DEFINE NMARGUP 20
#DEFINE NTAMLIN 8
#DEFINE NCENTER 290
#DEFINE NMAXBOTTOM 770    
#DEFINE NMAXLEFT 580
#DEFINE NCOL1 20
#DEFINE NCOL2 45
#DEFINE NCOL3 95
#DEFINE NCOL4 310
#DEFINE NCOL5 355
#DEFINE NCOL6 405
#DEFINE NCOL7 455
#DEFINE NCOL8 505
#DEFINE NCOL9 555
#DEFINE NMARGBOX 2

User Function RORC001
	Processa({||RORC001()}, "Gerando orçamento..")
Return

Static Function RORC001
	Local nValTot := 0
	Local aPrazos := {}
	Local aGarant := {}
	Local cPictQtd	:= "@E 99999" //PesqPict("SUB", "UB_QUANT")
	Local cPictIpi  := PesqPict("SUB", "UB_XVLRIPI")
	Local cPictST	:= PesqPict("SUB", "UB_XVLRST")
	Local cPictVUni	:= PesqPict("SUB", "UB_VRUNIT")	
	Local cQuery 	:= ""	
	Local nValST	:= 0
	Local nValIPI	:= 0
	Local cFilItem	:= ""
	Local aValImp	:= {}
	Local aImps		:= {}
	Local nI		:= 0
	Local cDir		:= "C:\temp\"   		
	Local cPerg		:= "RORC001E"
	Private cPictVTot	:= PesqPict("SUB", "UB_VLRITEM")
	Private nLin		:= NMARGUP
	Private nPag		:= 1
	Private cAliasQry	:= GetNextAlias()	
	Private aFilInfo	:= {}
	Private nQtdItens := 0
	Private nTotalST  := 0
	Private nTotalIPI := 0
	Private nTotalLiq := 0	
	Private nValorTot := 0	
	Private cPictVlr  := cPictVTot
	Private cFilePrint := "RORC001"                            
	Private oPrint
                                                                    	                                	
	If !ExistDir(cDir)
		If MakeDir(cDir) <> 0
			MsgAlert("Não foi possivel criar o diretorio ''"+cDir+"'' para impressão.", "Processo Cancelado")
			Return
		EndIf
	EndIf
	
	If File(cDir + cFilePrint + ".pdf")
		If FErase(cDir + cFilePrint + ".pdf") <> 0
			MsgAlert("Não foi possivel sobrescrever o arquivo " + cFilePrint + ".pdf", "Processo Cancelado")
			Return
		EndIf
	EndIf
	
	lAdjustToLegacy := .F. // Inibe legado de resolução com a TMSPrinter         

	oPrint := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy , cDir, .T., , , , , .F., ,.F. )

	oPrint:nDevice := IMP_PDF
	oPrint:cPathPDF := cDir	
	
	oFont10		:= TFontEx():New(oPrint,"Times New Roman",06,06,.F.,.T.,.F.)
	oFont10n	:= TFontEx():New(oPrint,"Times New Roman",06,06,.T.,.T.,.F.) //negrito
	oFontAr10	:= TFontEx():New(oPrint,"Arial",06,06,.F.,.T.,.F.) 
	oFontAr10n	:= TFontEx():New(oPrint,"Arial",06,06,.T.,.T.,.F.) //negrito
	oFontAr12	:= TFontEx():New(oPrint,"Arial",08,08,.F.,.T.,.F.) 		
	oFontAr12n	:= TFontEx():New(oPrint,"Arial",08,08,.T.,.T.,.F.) //negrito
	oFontAr14	:= TFontEx():New(oPrint,"Arial",10,10,.F.,.T.,.F.) 		
	oFontAr16n	:= TFontEx():New(oPrint,"Arial",12,12,.T.,.T.,.F.) //negrito	
	
	aFilInfo := InfoFil() 
	
	cQuery := "SELECT UB_XFILREF, " + CRLF
	cQuery += "	       UB_ITEM, " + CRLF
	cQuery += "	       UB_FILIAL, " + CRLF
	cQuery += "	       A1_NOME, " + CRLF
	cQuery += "	       A1_COD, " + CRLF
	cQuery += "	       A1_LOJA, " + CRLF
	cQuery += "	       A1_END, " + CRLF
	cQuery += "	       A1_COMPLEM, " + CRLF
	cQuery += "	       A1_MUN, " + CRLF
	cQuery += "	       A1_EST, " + CRLF
	cQuery += "	       A1_CEP, " + CRLF
	cQuery += "	       A1_CGC, " + CRLF
	cQuery += "	       A1_PESSOA, " + CRLF
	cQuery += "	       A1_DDD, " + CRLF
	cQuery += "	       A1_TEL, " + CRLF
	cQuery += "	       A1_FAX, " + CRLF
	cQuery += "	       A1_INSCR, " + CRLF
	cQuery += "	       A3_NOME, " + CRLF
	cQuery += "	       A4_NOME, " + CRLF
	cQuery += "	       UB_PRODUTO, " + CRLF
	cQuery += "	       B1_DESC, " + CRLF
	cQuery += "	       B1_POSIPI, " + CRLF
	cQuery += "	       UB_QUANT, " + CRLF
	cQuery += "	       UB_VRUNIT, " + CRLF
	cQuery += "	       UB_XVLRST, " + CRLF
	cQuery += "	       UB_XVLRIPI, " + CRLF
	cQuery += "	       UB_TES, " + CRLF
	cQuery += "	       UB_VALDESC, " + CRLF
	cQuery += "	       UB_VLRITEM " + CRLF
	cQuery += "	FROM   SUB010 SUB " + CRLF
	cQuery += "	       INNER JOIN SB1010 SB1 " + CRLF
	cQuery += "	               ON UB_PRODUTO = B1_COD" + CRLF 
	cQuery += "	       INNER JOIN SA1010 SA1 " + CRLF
	cQuery += "	               ON A1_COD = '" + SUA->UA_CLIENTE + "'" + CRLF
	cQuery += "	               AND A1_LOJA = '" + SUA->UA_LOJA + "'" + CRLF
	cQuery += "	       LEFT JOIN SA3010 SA3 " + CRLF
	cQuery += "	               ON A3_COD = '" + SUA->UA_VEND2 + "'" + CRLF
	cQuery += "				   AND SA3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	       LEFT JOIN SA4010 SA4 " + CRLF
	cQuery += "	               ON A4_COD = '" + SUA->UA_TRANSP + "'" + CRLF 
	cQuery += "	       		   AND SA4.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	WHERE  SUB.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	       AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	       AND SA1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	       AND SUB.UB_FILIAL = '" + SUA->UA_FILIAL + "'" + CRLF
	cQuery += "	       AND SUB.UB_NUM = '" + SUA->UA_NUM + "'" + CRLF
	cQuery += "	ORDER BY UB_XFILREF, UB_ITEM" + CRLF
 	
 	TCQUERY cQuery NEW ALIAS (cAliasQry)       	           	
	                                
	If (cAliasQry)->(EoF())
		MsgInfo("Não há dados!")
		Return
	EndIf
	
	//Primeiro loop para calcular e totalizar
	While (cAliasQry)->(!EoF())
		//Se item for da filial corrente, busca dos campos               
		If (cAliasQry)->UB_FILIAL == AllTrim((cAliasQry)->UB_XFILREF)
			nValST	:= (cAliasQry)->UB_XVLRST
			nValIPI	:= (cAliasQry)->UB_XVLRIPI
		Else //senao, troca filial e calcula por matxfis
			cFilAnt := AllTrim((cAliasQry)->UB_XFILREF)
			aValImp := CalcImp()          
	   		nValST	:= aValImp[1]
			nValIPI := aValImp[2]         
			cFilAnt := (cAliasQry)->UB_FILIAL
		EndIf
		
		aAdd(aImps, {nValST, nValIPI})
                                                         
		nQtdItens++
		nTotalST += nValST
		nTotalIPI += nValIPI
		nTotalLiq += (cAliasQry)->UB_VLRITEM 
		nValorTot += nTotalLiq + nTotalIPI + nTotalST

		(cAliasQry)->(DbSkip())
	EndDo                       
	                                 
	oPrint:StartPage()
	                    
	(cAliasQry)->(DbGoTop())
	
	cFilItem := (cAliasQry)->UB_XFILREF
   		
	ImpCabec(.T.)
	
	//Segundo loop para imprimir
	While (cAliasQry)->(!EoF())
		nI++		
		
		//quando trocar a filial de referencia, imprimir cabeçalho novamente para exibir o nome da filial
		If cFilItem <> (cAliasQry)->UB_XFILREF
			PulaLin()
			ImpCabec(.F., .T.)			
			cFilItem := (cAliasQry)->UB_XFILREF 
		EndIf
	
		nValST := aImps[nI][1]
		nValIPI := aImps[nI][2]
	
		oPrint:Say(nLin, NCOL1, (cAliasQry)->UB_ITEM, oFont10:oFont)
		oPrint:Say(nLin, NCOL2, (cAliasQry)->UB_PRODUTO, oFontAr10n:oFont)
		oPrint:Say(nLin, NCOL3, (cAliasQry)->B1_DESC, oFont10:oFont)
		oPrint:Say(nLin, NCOL4, (cAliasQry)->B1_POSIPI, oFont10:oFont)
	   	oPrint:Say(nLin, NCOL5, Transform((cAliasQry)->UB_QUANT, cPictQtd), oFont10:oFont)
		oPrint:Say(nLin, NCOL6, Transform((cAliasQry)->UB_VRUNIT, cPictVUni), oFontAr10n:oFont)
		oPrint:Say(nLin, NCOL7, Transform(nValST, cPictST), oFont10:oFont)
		oPrint:Say(nLin, NCOL8, Transform(nValIPI, cPictIPI), oFont10:oFont)
		oPrint:Say(nLin, NCOL9, Transform((cAliasQry)->UB_VLRITEM + nValST + nValIPI, cPictVTot), oFont10:oFont)
		PulaLin()
		
		(cAliasQry)->(DbSkip())
	EndDo

	ImpTotais()
	
	oPrint:EndPage()                                                                                                    
	
	(cAliasQry)->(DbCloseArea())
	
	oPrint:Print()
	
	cArquivo := cFilePrint + ".pdf"
	
	shellexecute("open", cDir + cArquivo , "", "", 1)
	
	AjustaSX1(cPerg)
	If Pergunte(cPerg)
		EnvMail(MV_PAR01, MV_PAR02, , 'Cambuci Metalurgica - Orçamento', cDir, cArquivo)
	EndIf
	
Return


Static Function ImpCabec(lPrimPag, lCabFil)    
    Local cFilInfo := ""
    Default lPrimPag := .F.
    Default lCabFil  := .F.
	
	If !lCabFil
		oPrint:Box(nLin - NTAMLIN + NMARGBOX, NMARGLEFT, nLin + NMARGBOX, NMAXLEFT)
		oPrint:Say(nLin, NCOL1, "Nro: " + SUA->UA_NUM, oFontAr10n:oFont)
		oPrint:Say(nLin, NCOL9, "PAG-" + AllTrim(Str(nPag)), oFontAr10n:oFont)
		PulaLin()
	EndIf
	
	If lPrimPag		
		oPrint:Box(nLin - NTAMLIN + NMARGBOX, NMARGLEFT, nLin + NMARGBOX + (NTAMLIN * 15.5), NMAXLEFT) 
		PulaLin(0.5)
		oPrint:Say(nLin, NCENTER - 40, "CAMBUCI METALURGICA LTDA", oFontAr14:oFont)
		PulaLin()
	   	oPrint:SayBitmap(nLin, NCOL1, "\system\rorc001.png", 97, 18)
		PulaLin()
		oPrint:Say(nLin, NCENTER - 6, "Orçamento", oFontAr16n:oFont)
		oPrint:Say(nLin, NCOL9 - 6, "Dt. do Ped", oFontAr10n:oFont)
		PulaLin()
		oPrint:Say(nLin, NCOL9 - 6, DToC(SUA->UA_EMISSAO), oFontAr10:oFont)
		PulaLin(2)
		oPrint:Say(nLin, NCOL1, "Cliente: ", oFontAr12n:oFont)
		oPrint:Say(nLin, NCOL1 + 30, (cAliasQry)->A1_NOME, oFontAr14:oFont)
		oPrint:Say(nLin, NCOL6, "Nro do Pedido: " + SUA->UA_NUM, oFontAr16n:oFont)
		PulaLin(1.5)
		oPrint:Say(nLin, NCOL1, "Endereço: ", oFontAr12n:oFont)
		oPrint:Say(nLin, NCENTER, "Codigo: ", oFontAr12n:oFont)
		oPrint:Say(nLin, NCENTER + 30, SUA->UA_CLIENTE + " / " + SUA->UA_LOJA, oFontAr12:oFont)
		oPrint:Say(nLin, NCOL6, "Nro de Itens: ", oFontAr12n:oFont)
		oPrint:Say(nLin, NCOL6 + 45, AllTrim(Str(nQtdItens)), oFontAr12:oFont)
		PulaLin(1.5)
		oPrint:Say(nLin, NCOL1, (cAliasQry)->A1_END + " " + (cAliasQry)->A1_COMPLEM, oFontAr12:oFont)
		oPrint:Say(nLin, NCOL6, "Validade: " + AllTrim(Str(SUA->UA_DTLIM - dDataBase)), oFontAr12n:oFont)
		PulaLin(1.5)
		oPrint:Say(nLin, NCOL1, AllTrim((cAliasQry)->A1_MUN) + " - " + (cAliasQry)->A1_EST, oFontAr12:oFont)	
		oPrint:Say(nLin, NCOL6, "Vendedor: ", oFontAr12n:oFont)	
		oPrint:Say(nLin, NCOL6 + 40, (cAliasQry)->A3_NOME, oFontAr12:oFont)
		PulaLin(1.5)
		oPrint:Say(nLin, NCOL1, "CEP: " + Transform((cAliasQry)->A1_CEP, "@R 99999-999"), oFontAr12:oFont)	
		oPrint:Say(nLin, NCOL3, "CNPJ/CPF: " + Transform((cAliasQry)->A1_CGC, If((cAliasQry)->A1_PESSOA == "F", "@R 999.999.999-99", "@R 99.999.999/9999-99")), oFontAr12:oFont)	
		oPrint:Say(nLin, NCOL3 + 110, "I.E.: " + Transform((cAliasQry)->A1_INSCR, "@R 999.999.999"), oFontAr12:oFont)			
		oPrint:Say(nLin, NCOL6, "Valor Total: " + Transform(nValorTot, cPictVTot), oFontAr16n:oFont)					
		PulaLin(1.5)
		oPrint:Say(nLin, NCOL1, "Telefone: " + (cAliasQry)->A1_DDD + " " + (cAliasQry)->A1_TEL, oFontAr12:oFont)	
		oPrint:Say(nLin, NCOL3 + 20, "Fax: " + If(!Empty((cAliasQry)->A1_FAX), (cAliasQry)->A1_DDD + " " + (cAliasQry)->A1_FAX, ""), oFontAr12:oFont)			
		PulaLin(1.5)
		oPrint:Say(nLin, NCOL1, "Transportadora: ", oFontAr12n:oFont)	
		oPrint:Say(nLin, NCOL1 + 60, (cAliasQry)->A4_NOME, oFontAr12:oFont)	
		PulaLin(2)
	EndIf
               
 	nPos := aScan(aFilInfo, {|x| x[1] == AllTrim((cAliasQry)->UB_XFILREF)})
	cFilInfo := If(nPos > 0, aFilInfo[nPos][2], "")
	
	oPrint:Box(nLin - NTAMLIN + NMARGBOX, NMARGLEFT, nLin + NMARGBOX, NMAXLEFT)
	oPrint:Say(nLin, NCOL1, "Origem: " + cFilInfo, oFontAr10n:oFont)	 
	PulaLin()

	oPrint:Box(nLin - NTAMLIN + NMARGBOX, NMARGLEFT, nLin + NMARGBOX, NMAXLEFT)
	oPrint:Say(nLin, NCOL1, "Sq", oFontAr10n:oFont)
	oPrint:Say(nLin, NCOL2, "Referência", oFontAr10n:oFont)
	oPrint:Say(nLin, NCOL3, "Descrição", oFontAr10n:oFont)
	oPrint:Say(nLin, NCOL4, "NCM", oFontAr10n:oFont)
	oPrint:Say(nLin, NCOL5, "Qtde", oFontAr10n:oFont)
	oPrint:Say(nLin, NCOL6, "Vlr.Unit", oFontAr10n:oFont)
	oPrint:Say(nLin, NCOL7, "ICMS ST", oFontAr10n:oFont)
	oPrint:Say(nLin, NCOL8, "Vlr.IPI", oFontAr10n:oFont)
	oPrint:Say(nLin, NCOL9, "Vlr.Total", oFontAr10n:oFont)	
	PulaLin()
			
Return

Static Function ImpTotais
	oPrint:Line(nLin + NMARGBOX,NMARGLEFT,nLin + NMARGBOX,NMAXLEFT)
	nLin1 := nLin + NMARGBOX
	PulaLin()	
	oPrint:Say(nLin, NCOL1, "Observação:", oFontAr10n:oFont)	
	oPrint:Say(nLin, NCOL6, "Valor dos itens", oFontAr10:oFont)
	oPrint:Say(nLin, NCOL9, Transform(nTotalLiq, cPictVlr), oFont10n:oFont)
	PulaLin()
	cObs := If(!Empty(SUA->UA_CODOBS), MSMM(SUA->UA_CODOBS), "")
	oPrint:Say(nLin, NCOL1, If(Len(cObs)>0, SubStr(cObs, 1, 100), ""), oFontAr10:oFont)		
	oPrint:Say(nLin, NCOL6, "Valor ICMS ST", oFontAr10:oFont)
	oPrint:Say(nLin, NCOL9, Transform(nTotalST, cPictVlr), oFont10n:oFont)
	PulaLin()                                                         
	oPrint:Say(nLin, NCOL1, If(Len(cObs)>100, SubStr(cObs, 101, 100), ""), oFontAr10:oFont)
	oPrint:Say(nLin, NCOL6, "Valor IPI", oFontAr10:oFont)
	oPrint:Say(nLin, NCOL9, Transform(nTotalIPI, cPictVlr), oFont10n:oFont)
	PulaLin()
	oPrint:Say(nLin, NCOL1, If(Len(cObs)>200, SubStr(cObs, 201, 100), ""), oFontAr10:oFont)
	oPrint:Say(nLin, NCOL6, "Valor Total do Pedido", oFontAr10:oFont)
	oPrint:Say(nLin, NCOL9, Transform(nValorTot, cPictVlr), oFont10n:oFont)
	oPrint:Line(nLin1,NCOL6 - 12, nLin + NMARGBOX, NCOL6 - 12)
	oPrint:Line(nLin + NMARGBOX,NMARGLEFT,nLin + NMARGBOX,NMAXLEFT)	
	PulaLin(5)
	oPrint:Line(nLin, NCOL2, nLin, NCOL2 + 120)
	oPrint:Line(nLin, NCOL6, nLin, NCOL6 + 120)
	PulaLin()
	oPrint:Say(nLin, NCOL3, "Cliente", oFontAr10:oFont)
	oPrint:Say(nLin, NCOL7 + 2, "Empresa", oFontAr10:oFont)
Return        


Static Function PulaLin(nQtd)
	Default nQtd := 1                 
	
	nLin += NTAMLIN * nQtd
	
	If nLin > NMAXBOTTOM
		oPrint:EndPage()
		oPrint:StartPage()
		nLin := NMARGUP
		nPag++
		ImpCabec(.F.)	
	EndIf	
Return nLin


Static Function InfoFil()
	Local aArea := GetArea()
	Local aAreaSM0 := SM0->(GetArea())
	Local aRet := {}
	
	DbSelectArea("SM0")
	While !EoF()    
		If M0_CODIGO == cEmpAnt
			aAdd(aRet, {AllTrim(M0_CODFIL), AllTrim(M0_CIDENT) + " - " + M0_ESTENT})
		EndIf
		DbSkip()
	EndDo
	
	RestArea(aAreaSM0)	                               
	RestArea(aArea)
Return aRet
           

Static Function CalcImp()
	Local aRet := {}
	Local nI 		:= 0
	Local nRecProd  := 0
	Local nRecTes   := 0	
	Local nRecNFOri := 0	  
	Local lOk		:= .T.
	Private cCliente	:= SUA->UA_CLIENTE
	Private cLoja		:= SUA->UA_LOJA
	Private cTipo		:= "N"
	Private cTipoCli	:= ""
	
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1") + cCliente + cLoja)
	
	cTipoCli := SA1->A1_TIPO
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa a funcao fiscal                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisSave()
	MaFisEnd()
	MaFisIni(cCliente, cLoja, IIf(cTipo $ "DB","F","C"), cTipo, cTipoCli, Nil, Nil, Nil, Nil, "MATA461")

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1") + (cAliasQry)->UB_PRODUTO)
	nRecProd := Recno()
	
	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xFilial("SF4") + (cAliasQry)->UB_TES)
	nRecTes := Recno()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Agrega os itens para a funcao fiscal         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisAdd((cAliasQry)->UB_PRODUTO,;  // Codigo do Produto ( Obrigatorio )
			(cAliasQry)->UB_TES,;	  // Codigo do TES ( Opcional )
			(cAliasQry)->UB_QUANT,;	  // Quantidade ( Obrigatorio )
			(cAliasQry)->UB_VRUNIT,;	  // Preco Unitario ( Obrigatorio )
			(cAliasQry)->UB_VALDESC,;   // Valor do Desconto ( Opcional )
			"",;	  // Numero da NF Original ( Devolucao/Benef )
			"",;	  // Serie da NF Original ( Devolucao/Benef )
			0,;		  // RecNo da NF Original no arq SD1/SD2
			0,;  // Valor do Frete do Item ( Opcional )
			0,;  // Valor da Despesa do item ( Opcional )
			0,;  // Valor do Seguro do item ( Opcional )
			0,;  // Valor do Frete Autonomo ( Opcional )
			(cAliasQry)->UB_VLRITEM,;  // Valor da Mercadoria ( Obrigatorio )
			0,;  // Valor da Embalagem ( Opiconal )
			nRecProd,;		  // RecNo do SB1
			nRecTes) 		  // RecNo do SF4
	MaFisWrite(1)	
	
	aRet := {MaFisRet(1, "IT_VALIPI"), MaFisRet(1, "IT_VALSOL")}
	
	MaFisEnd()					
	
Return aRet



Static Function EnvMail(cTo,cCC,cBCC,cAssunto,cDir,cArquivo)

	Local cServer		:= GetMV("MV_RELSERV")
	Local cAccount		:= GetMV("MV_RELACNT")
	Local cPassword	    := GetMV("MV_RELPSW")
	Local lAuth			:= .T.
	Local lRet			:= .f.
	Local cDirSrv		:= "\spool\" + AllTrim(cUserName) + "\"

	Default cCC			:= ""
	Default cBCC		:= ""
	Default cAnexo		:= ""

	If !ExistDir(cDirSrv)
		If MakeDir(cDirSrv) <> 0
			MsgAlert("Problemas para criar diretorio no servidor.", "Processo Cancelado")
		EndIf
	EndIf
	
	If !CpyT2S(cDir + cArquivo, cDirSrv)
		MsgAlert("Problemas para copiar arquivo para o servidor.", "Processo Cancelado")
		Return .F.
	Else
		cAnexo := cDirSrv + cArquivo
	EndIf

	CHTML := ' <html> '
	CHTML += ' <head> '
	CHTML += '<meta http-equiv="Content-Type" '
	CHTML += 'content="text/html; charset=iso-8859-1"> '
	CHTML += '<title>Orçamento</title>'
	CHTML += '</head>'
	CHTML += '<body style="background-color: rgb(255, 255, 255);">'
	CHTML += '<table width="100%">'
	CHTML += '<tbody>'
	CHTML += '<tr>'
	CHTML += '<th align="left" bgcolor="#202664"> <font color="#ffffff" face="verdana, arial, helvetica, times" size="5"><br>'
	CHTML += 'Orçamento<br>'
	CHTML += '</font></th>'
	CHTML += '</tr>'
	CHTML += '</tbody>'
	CHTML += '</table>'
	CHTML += '<br>'
	CHTML += '<table border="1" width="1194">'
	CHTML += '<tbody>'
	CHTML += '<tr>'
	CHTML += '<td colspan="2" height="81">'
	CHTML += '<p><strong>Prezado cliente, segue o orçamento solicitado.</strong></p>'
	CHTML += '</td>'
	CHTML += '</tr>'
	CHTML += '</tbody>'
	CHTML += '</table>'
	CHTML += '<br>'
	CHTML += '<br>'
	CHTML += '<br>'
	CHTML += '<font color="#000000" face="verdana, arial, helvetica, times" size="-1">'
	CHTML += 'Esta mensagem foi gerada automaticamente pelo sistema, favor não responder.</font> <br>'
	CHTML += '<br>'
	CHTML += '</body>'
	CHTML += '</html>'


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Conecta no Servidor SMTP ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lConectou:=MailSmtpOn( cServer, cAccount, cPassword )

	If !lConectou
		MSGALERT("Email não enviado. Não foi possivel realizar conexão.", "Alerta")
		Return
	Endif

	If lAuth
		lOk := MailAuth(cAccount,cPassword)
	Endif		

	If Empty(cCC)
		Send Mail From cAccount To cTo SubJect cAssunto BODY CHTML ATTACHMENT cAnexo RESULT lEnviado
	Else
		Send Mail From cAccount To cTo CC cCC SubJect cAssunto BODY CHTML ATTACHMENT cAnexo RESULT lEnviado
	EndIf

	If !lEnviado
		cErro := ""
		Get Mail Error cErro
		MsgAlert(cErro)
		lRet := .f.
	Else
		FErase(cDirSrv + cArquivo)
		MsgInfo("Email enviado com sucesso.", "Email")
		lRet := .t.
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desconecta do Servidor SMTP ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Disconnect SMTP SERVER Result lDesConectou

Return(lRet)


Static Function AjustaSX1(cPerg)
	PutSx1(cPerg, '01', 'Email:'    ,'' ,'' , 'mv_ch1', 'C', 60, 0, 1, 'G', '', ''      , '', '', 'mv_par01','','','','','','','','','','','','','','','','', '','','')
	PutSx1(cPerg, '02', 'Copia:'    ,'' ,'' , 'mv_ch2', 'C', 60, 0, 1, 'G', '', ''      , '', '', 'mv_par02','','','','','','','','','','','','','','','','', '','','')	
Return