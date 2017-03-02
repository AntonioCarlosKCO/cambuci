#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "RWMAKE.CH"   
#INCLUDE "TOTVS.CH"
#INCLUDE "ERROR.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RELCONF  ºAutor  ³ Walter Global       º Data ³  09/19/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatório de Conferencia - PEDIDOS DE VENDA				  º±±
±±º          ³			                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/
User Function RELCONF()
	
	Private cDirTemp    := GetTempPath()
	Private cPerg    := PADR("RELCONF",LEN(SX1->X1_GRUPO))
	
	If !SelecionaParam()
	   Return
	End      
	
	GeraConf()

return

Static Function SelecionaParam()
	Local aPergs := {}
	
	//PutSx1(cPerg, "Pedido De?", "Pedido De?", "Pedido De?", "mv_ch1","C",6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SC5","","","","")
	//PutSx1(cPerg, "Pedido Ate?","Pedido Ate?","Pedido Ate?","mv_ch2","C",6,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SC5","","","","")
	//AjustaSX1(cPerg,{aPergs}) 
	
	Aadd(aPergs,{"Pedido De?", "Pedido De?", "Pedido De?", "mv_ch1","C",6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SC5","","","",""})
	Aadd(aPergs,{"Pedido Ate?","Pedido Ate?","Pedido Ate?","mv_ch2","C",6,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SC5","","","",""})
	
	If !Pergunte(cPerg,.T.)
	   Return(.F.)
	Endif                    

return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraBoleto                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a geracao do boleto                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraConf()
// -- Raphael Global 12/12/2016 - INÍCIO
Local _nPag		:= 1                               
Local _nContIt	:= 1
Local nLin2 	:= 0
Local lFim := .T.
// -- FIM
Local oDanfe
Local aBolText :=	{"Após o vencimento cobrar multa de R$ ",;
					"Mora Diaria de R$ ",;
					Alltrim(mv_par20),;
					Alltrim(mv_par21)}  
Local aRelImp    := MaFisRelImp("MT100",{"SF2","SD2"})

Private aCB_RN_NN    := {}
Private PixelX, PixelY
Private XLOGO, XCODBANCO, XCEDENTE, XAGENCIA_CEDENTE, XSACADO, XEND_CEDENTE, XCID_CEDENTE, XEST_CEDENTE, XCEP_CEDENTE
Private XNOSSONUM, XVENCTO, XNUMDOC, XESPECIE, XVALOR
Private XCPFCNPJ_CEDENTE, XDATADOC, XESPDOC, XACEITE, XDATAPROC
Private XCARTEIRA, XESPECIE, XSACADO, XCPFCNPJ_SACADO, XEND_SACADO
Private XCEP_SACADO, XCIDADE_SACADO, XESTADO_SACADO, XCODBAIXA
Private XCODBARRAS, XMENSAGEM1, XMENSAGEM2, XMENSAGEM3, XMENSAGEM4, XLINHADIG
Private cBarraFim
Private cFilePdf := ''

oFont36 := TFont():New( "Arial",,36,,.T.,,,,,.F. )
oFont34 := TFont():New( "Arial",,34,,.T.,,,,,.F. )
oFont32 := TFont():New( "Arial",,32,,.T.,,,,,.F. )
oFont30 := TFont():New( "Arial",,30,,.T.,,,,,.F. )
oFont28 := TFont():New( "Arial",,28,,.T.,,,,,.F. )
oFont24 := TFont():New( "Arial",,24,,.T.,,,,,.F. )
oFont22 := TFont():New( "Arial",,22,,.F.,,,,,.F. )
oFont20 := TFont():New( "Arial",,20,,.T.,,,,,.F. )
oFont18 := TFont():New( "Arial",,18,,.F.,,,,,.F. )
oFont14 := TFont():New( "Arial",,14,,.T.,,,,,.F. )
oFont12 := TFont():New( "Arial",,12,,.T.,,,,,.F. )
oFont10 := TFont():New( "Arial",,10,,.T.,,,,,.F. )
oFont09N:= TFont():New( "Arial",,09,,.F.,,,,,.F. )
oFont08 := TFont():New( "Arial",,08,,.T.,,,,,.F. )
oFont08N:= TFont():New( "Arial",,08,,.F.,,,,,.F. )
oFont06 := TFont():New( "Arial",,06,,.T.,,,,,.F. )

//Posiciona na tabela SC5 de acordo com os parametros recebidos
DbSelectArea('SC5')
SC5->(DbSetOrder(1))
SC5->(DbSeek(xFilial('SC5')+mv_par01))      
             
While SC5->(!EOF()) .AND. SC5->(C5_FILIAL+C5_NUM) <= xFilial('SC5')+mv_par02

	cFilePDF := SC5->C5_FILIAL + SC5->C5_NUM
	cFilePDF := UPPER(cFilePDF)

	If File( cDirTemp+cFilePDF+'.pdf' )
		Ferase( cDirTemp+cFilePDF+'.pdf' )
	Endif
			
	lAdjustToLegacy := .T.
	lDisableSetup 	:= .T.

	oDanfe 	:= FWMSPrinter():New( cFilePDF, IMP_PDF, lAdjustToLegacy, , lDisableSetup)
	oDanfe:setDevice(IMP_PDF)
	oDanfe:SetPortrait()
	oDanfe:cPathPDF :=cDirTemp
	oDanfe:SetPaperSize(9)
	oDanfe:SetResolution(72)
	oDanfe:SetMargin(60,60,60,60)
	oDanfe:StartPage()

	//Importante:
	//Ajuste de saida para pdf para ajustar tamanho de pagina
	nAjusLin := 0
	If oDanfe:nDevice == 6 //SAIDA PDF
		nAjusLin := 100
	Endif

	PixelX := odanfe:nLogPixelX()
	PixelY := odanfe:nLogPixelY()

	cCliEnt := IIf(!Empty(SC5->(FieldGet(FieldPos("C5_CLIENT")))),SC5->C5_CLIENT,SC5->C5_CLIENTE)
	MaFisIni(cCliEnt,;						// 1-Codigo Cliente/Fornecedor
		SC5->C5_LOJACLI,;					// 2-Loja do Cliente/Fornecedor
		If(SC5->C5_TIPO$'DB',"F","C"),;		// 3-C:Cliente , F:Fornecedor
		SC5->C5_TIPO,;						// 4-Tipo da NF
		SC5->C5_TIPOCLI,;					// 5-Tipo do Cliente/Fornecedor
		aRelImp,;							// 6-Relacao de Impostos que suportados no arquivo
		,;						   			// 7-Tipo de complemento
		,;									// 8-Permite Incluir Impostos no Rodape .T./.F.
		"SB1",;								// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
		"MATA461")							// 10-Nome da rotina que esta utilizando a funcao

	//Logotipo
	//oDanfe:SayBitmap( -040+nAjusLin, 0010,XLOGO,300 )

	oDanfe:Box(0050+nAjusLin, 0010, 2950+nAjusLin, 2200) // Raphael Global 13/12/2016

	oDanfe:Say(0080+nAjusLin, 0050, "Nro: " + SC5->C5_NUM,oFont08)
	oDanfe:Say(0080+nAjusLin, 2110, "PÁG." + Str(_nPag,2),oFont08)
	oDanfe:Line(0090+nAjusLin, 0010, 0090+nAjusLin, 2198)
	oDanfe:Say(0160+nAjusLin,  0810,'Relatório de Conferência ',oFont20 )
	oDanfe:Line(0200+nAjusLin, 0010, 0200+nAjusLin, 2198)
	oDanfe:Line(0205+nAjusLin, 1310, 0490+nAjusLin, 1310)
	oDanfe:Say(0230+nAjusLin, 0050,'Cliente: ',oFont10 ) 
	oDanfe:Say(0230+nAjusLin, 0160,Upper(Posicione('SA1',1,xFilial('SA1')+SC5->(C5_CLIENTE+C5_LOJACLI),'A1_NOME')),oFont09N ) 
	oDanfe:Say(0280+nAjusLin, 1010,'Código: ',oFont10 )
	oDanfe:Say(0280+nAjusLin, 1160,SA1->A1_COD,oFont09N )
	oDanfe:Say(0280+nAjusLin, 0050,'Endereço: ',oFont10 )
	oDanfe:Say(0330+nAjusLin, 0050,SA1->A1_END,oFont09N )
	oDanfe:Say(0360+nAjusLin, 0050,AllTrim(SA1->A1_BAIRRO) + ' - ' + Alltrim(SA1->A1_MUN) + ' - ' + SA1->A1_EST,oFont09N )
	oDanfe:Say(0390+nAjusLin, 0050,	'CEP: ' + Transform(SA1->A1_CEP,'@R 99999-999') +;
									'  CNPJ/CPF: - ' + Transform(SA1->A1_CGC,If(SA1->A1_PESSOA=='J','@R 99.999.999/9999-99','@R 999.999.999-99')) +;
									'  I.E.: ',oFont09N )
	oDanfe:Say(0420+nAjusLin, 0050,'Telefone: ' + AllTrim(SA1->A1_DDD) + ' ' + AllTrim(SA1->A1_TEL) + '         Fax: ' + AllTrim(SA1->A1_DDD) + ' ' +Alltrim(SA1->A1_FAX) ,oFont09N )
	oDanfe:Say(0460+nAjusLin, 0050,'Transportadora: ',oFont10 )
	oDanfe:Say(0460+nAjusLin, 0250,Posicione('SA4',1,xFilial('SA4')+SC5->C5_TRANSP,'A4_NOME'),oFont09N )
	oDanfe:Say(0260+nAjusLin, 1350,'Nro do Pedido:   ' + Transform(SC5->C5_NUM,'@R XXX.XXX'),oFont14)
	//oDanfe:Say(0340+nAjusLin, 1350,'Nro Itens:   ' ,oFont10) // Contador incluído no Rodapé - Raphael Global 12/12/2016
	//oDanfe:Say(0340+nAjusLin, 1750,Str(_nContIt,3),oFont09N )
	oDanfe:Say(0390+nAjusLin, 1350,'Vendedor:   ' ,oFont10)
	oDanfe:Say(0390+nAjusLin, 1500,Posicione('SA3',1,xFilial('SA3')+SC5->C5_VEND1,'A3_NOME'),oFont09N )
	oDanfe:Say(0440+nAjusLin, 1350,'Data do Pedido:   '  ,oFont10)
	oDanfe:Say(0440+nAjusLin, 1750,DTOC(SC5->C5_EMISSAO),oFont09N )
	oDanfe:Line(0490+nAjusLin, 0010, 0490+nAjusLin, 2198)
	oDanfe:Say(0520+nAjusLin, 0050,'Sq      Referência                              Descrição   ' ,oFont08)
	oDanfe:Say(0520+nAjusLin, 01150,'Qtde                         Vlr. Unit.                     Alq. IPI                           Vlr. IPI                          Vlr. STB                      Vlr. Total    ' ,oFont08)

	oDanfe:Line(0535+nAjusLin, 0010, 0535+nAjusLin, 2198)

    nItem	:= 0
    _nTotIt := 0
    _nTotIpi:= 0
    _nTotSt := 0
    _nTotNf := 0

	SC6->(DbSetOrder(1))
    SC6->(DbSeek(xFilial('SC6')+SC5->C5_NUM))  //FILIAL+NUM+ITEM+PRODUTO

	While SC6->(!EOF()) .and. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)
		
		// -- Raphael Global 13/12/2016 - INÍCIO
		If _nPag > 1
			nLin2 := 0160
		Else
			nLin2 := 0560
		Endif // -- FIM
		
		nItem+=1
		MaFisAdd(SC6->C6_PRODUTO,;								// 1-Codigo do Produto ( Obrigatorio )
		SC6->C6_TES,;											// 2-Codigo do TES ( Opcional )
		SC6->C6_QTDVEN,;										// 3-Quantidade ( Obrigatorio )
		IIF(SC6->C6_XPRCESP>0,SC6->C6_XPRCESP,SC6->C6_PRUNIT),;	// 4-Preco Unitario ( Obrigatorio )
		SC6->C6_DESCONT,;										// 5-Valor do Desconto ( Opcional )
		'',;													// 6-Numero da NF Original ( Devolucao/Benef )
		'',;													// 7-Serie da NF Original ( Devolucao/Benef )
		0,;														// 8-RecNo da NF Original no arq SD1/SD2
		0,;														// 9-Valor do Frete do Item ( Opcional )
		0,;														// 10-Valor da Despesa do item ( Opcional )
		0,;														// 11-Valor do Seguro do item ( Opcional )
		0,;														// 12-Valor do Frete Autonomo ( Opcional )
		IIF(SC6->C6_XPRCESP>0,SC6->C6_XPRCESP,SC6->C6_PRUNIT),;	// 13-Valor da Mercadoria ( Obrigatorio ) //SC6->C6_QTDVEN*If(SC6->C6_XPRCESP>0,SC6->C6_XPRCESP,SC6->C6_PRUNIT) //Raphael 02/08/2016 - Ajuste no Valor Unitário impresso
		0,;														// 14-Valor da Embalagem ( Opiconal )
		0,;														// 15-RecNo do SB1
		0 )														// 16-RecNo do SF4
		
		// -- Raphael Global 13/12/2016 (Incluído variável nLin2) - INÍCIO
		oDanfe:Say(nLin2+nAjusLin, 0050,SC6->C6_ITEM,oFont08N )
		oDanfe:Say(nLin2+nAjusLin, 0100,SC6->C6_PRODUTO,oFont08N )
		oDanfe:Say(nLin2+nAjusLin, 0350,SC6->C6_DESCRI,oFont08N )
		oDanfe:Say(nLin2+nAjusLin, 1130,Transform(SC6->C6_QTDVEN,PesqPict('SC6','C6_QTDVEN')),oFont08N )
		oDanfe:Say(nLin2+nAjusLin, 1520,Transform(MaFisRet(nItem,"IT_ALIQIPI"),PesqPict('SD2','D2_IPI')),oFont08N )
		//oDanfe:Say(0560+nAjusLin, 1320,Transform(If(SC6->C6_XPRCESP>0,SC6->C6_XPRCESP,SC6->C6_PRUNIT),PesqPict('SC6','C6_PRUNIT')),oFont08N )	  
		
		DBSELECTAREA("SD2")
		DBSETORDER(8)
		  
		If SD2->(DbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))
		  	
		  	 oDanfe:Say(nLin2+nAjusLin, 1320,Transform(IIF(SC6->C6_XPRCESP>0,SC6->C6_XPRCESP,SC6->C6_PRUNIT),PesqPict('SC6','C6_PRUNIT')),oFont08N ) 	 //Raphael 02/08 - Ajuste Preço Unitário impressão
		  	 oDanfe:Say(nLin2+nAjusLin, 1670,Transform(SD2->D2_VALIPI,PesqPict('SD2','D2_VALIPI')),oFont08N )
		  	 oDanfe:Say(nLin2+nAjusLin, 1870,Transform(SD2->D2_ICMSRET,PesqPict('SD2','D2_ICMSRET')),oFont08N )
			 oDanfe:Say(nLin2+nAjusLin, 2050,Transform((SC6->C6_QTDVEN*IIF(SC6->C6_XPRCESP>0,(SC6->C6_XPRCESP),SC6->C6_PRUNIT))+SD2->D2_VALIPI+SD2->D2_ICMSRET ,PesqPict('SC6','C6_VALOR')) ,oFont08N )  //Raphael 20/10 - Ajuste Valor Total impressão
		
		     _nTotIt := _nTotIt  + (SC6->C6_QTDVEN*If(SC6->C6_XPRCESP>0,SC6->C6_XPRCESP,SC6->C6_PRUNIT))
        	_nTotIpi := _nTotIpi + SD2->D2_VALIPI
        	_nTotSt  := _nTotSt  + SD2->D2_ICMSRET
        	_nTotNf  := _nTotNf  + (SC6->C6_QTDVEN*(IIF(SC6->C6_XPRCESP>0,(SC6->C6_XPRCESP),SC6->C6_PRUNIT)))+SD2->D2_VALIPI+SD2->D2_ICMSRET
        	
        	_nContIt+=1        	
        Else
        
		  	 MsgAlert("Não existe Nota Fiscal para este pedido. Relatório disponível somente após a emissão da Nota Fiscal")
  	  	 	 MaFisEnd()
			 oDanfe:EndPage()
			 lFim := .F. 
		  	 Return
		  	 //oDanfe:Say(0560+nAjusLin, 1320,Transform(If(SC6->C6_XPRCESP>0,SC6->C6_XPRCESP,SC6->C6_PRUNIT),PesqPict('SC6','C6_PRUNIT')),oFont08N )
		  	 //oDanfe:Say(0560+nAjusLin, 1670,Transform(MaFisRet(nItem,"IF_VALIPI"),PesqPict('SD2','D2_VALIPI')),oFont08N )
		  	 //oDanfe:Say(0560+nAjusLin, 1870,Transform(MaFisRet(nItem,"IT_VALSOL"),PesqPict('SD2','D2_ICMSRET')),oFont08N )
			 //oDanfe:Say(0560+nAjusLin, 2050,Transform(SC6->C6_QTDVEN*If(SC6->C6_XPRCESP>0,SC6->C6_XPRCESP,SC6->C6_PRUNIT)	 ,PesqPict('SC6','C6_VALOR')) ,oFont08N )
		Endif                            
	  
		nAjusLin+=30
		
		// -- Raphael Global 12/12/2016 (Quebra de página) - INÍCIO
		If nAjusLin > 2480
			_nPag+=1
			oDanfe:EndPage()
			oDanfe:StartPage()
			nAjusLin := 100
			oDanfe:Box(0050+nAjusLin, 0010, 2950+nAjusLin, 2200) 
			oDanfe:Say(0080+nAjusLin, 0050, "Nro: " + SC5->C5_NUM,oFont08)
			oDanfe:Say(0080+nAjusLin, 2110, "PÁG." + Str(_nPag,2),oFont08)
			oDanfe:Line(0090+nAjusLin, 0010, 0090+nAjusLin, 2200)
			oDanfe:Say(0120+nAjusLin, 0050,'Sq      Referência                              Descrição   ' ,oFont08)
			oDanfe:Say(0120+nAjusLin, 01150,'Qtde                         Vlr. Unit.                     Alq. IPI                           Vlr. IPI                          Vlr. STB                      Vlr. Total    ' ,oFont08)
			oDanfe:Line(0135+nAjusLin, 0010, 0135+nAjusLin, 2200)
					
		Endif // FIM
		
		DBSELECTAREA("SC6") 
      	SC6->(DbSkip())
		
	End

/* 	nAjusLin := 0
	If oDanfe:ndevice == 6
		nAjusLin := 100
	Endif 
*/	
	// -- Raphael Global 13/12/2016 - INÍCIO
    If lFim  
    	oDanfe:Line(3000, 0010, 3000, 2200)
		oDanfe:Say(3030, 0050,'Qtd. Itens: ',oFont10 )
		oDanfe:Say(3030, 0200, Str(_nContIt,3),oFont10 )
		oDanfe:Say(3030, 0850,'Valor Itens: ',oFont10 )
		oDanfe:Say(3030, 1000, Transform(_nTotIt,PesqPict("SF2","F2_VALMERC")),oFont10 )
		oDanfe:Say(3030, 1200,'Valor IPI: ',oFont10 )
		oDanfe:Say(3030, 1300, Transform(_nTotIpi,PesqPict("SF2","F2_VALIPI")),oFont10 )
		oDanfe:Say(3030, 1500,'Valor STB: ',oFont10 )    
		oDanfe:Say(3030, 1650,	Transform(_nTotSt,PesqPict("SF2","F2_VALBRUT")),oFont10 )
		oDanfe:Say(3030, 1850,'Valor Total: ',oFont10 )
		oDanfe:Say(3030, 2000,	Transform(_nTotNf,PesqPict("SF2","F2_VALBRUT")),oFont10 ) // FIM
	Endif

    _nTotIt  := 0
    _nTotIpi := 0
    _nTotSt  := 0
    _nTotNf  := 0
    
	MaFisEnd()

	//oDanfe:EndPage()
	if oDanfe:nModalResult == PD_OK 
	   oDanfe:Preview()
	EndIf	
	oDanfe:Print(.f.)
	//Copia o arquivo para o servidor
	If File( oDanfe:cPathPDF+cFilePDF+'.pdf' )
		If File( '\BOLETO\'+cFilePDF+'.pdf')
			Ferase( '\BOLETO\'+cFilePDF+'.pdf' )
		Endif
		CpyT2S(oDanfe:cPathPDF+cFilePDF+'.pdf','\BOLETOS')
	Endif

	DbSelectArea('SC5')
	SC5->(DbSkip())

End

Return