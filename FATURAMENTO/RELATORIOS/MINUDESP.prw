#include 'protheus.ch'
#include 'parmtype.ch'
#include "FWPrintSetup.ch"

User Function PARAMIDE()

	Local cCadastro := "Impressão de Minuta de Despacho"
	Local aSays      := {}
	Local aButtons   := {}
	Local nOpca      := 0
	Local lPerg      := .F. // Para controlar se o usuario acessou as perguntas.
	
	Private cPerg := PadR("X1MINUDESP", Len(SX1->X1_GRUPO))
	
	PutSx1(cPerg, "01","Tipo de Impressão",'','',"mv_ch1","C",30				   ,0,1,"C","","","","","mv_par01","Todas Pendentes","","","","Seleção Manual ","","","","","","","","","","","")
	PutSx1(cPerg, "02","Nota Fiscal De	 ",'','',"mv_ch2","C",TamSx3("F2_DOC")[1]  ,0, ,"G","","","","","mv_par02",""               ,"","","",""			   ,"","","","","","","","","","","")
	PutSx1(cPerg, "03","Nota Fiscal Até  ",'','',"mv_ch3","C",TamSx3("F2_DOC")[1]  ,0, ,"G","","","","","mv_par03",""			    ,"","","",""			   ,"","","","","","","","","","","")
	PutSx1(cPerg, "04","Série			 ",'','',"mv_ch4","C",TamSx3("F2_SERIE")[1],0, ,"G","","","","","mv_par04",""			    ,"","","",""			   ,"","","","","","","","","","","")

	AADD(aSays," ")
	AADD(aSays,"Informe os parâmetros para a impressão da Minuta de Despacho.")
	AADD(aSays," ")
	AADD(aButtons, {5, .T., {|| lPerg := Pergunte(cPerg,.T.)}})
	AADD(aButtons, {1, .T., {|| nOpca := If((lPerg .Or. Pergunte(cPerg,.T.)), 1, 2), ; 
										 If(nOpca == 1, FechaBatch(), Nil), ; 
										 PRMINUDESP(mv_par01, mv_par02, mv_par03, mv_par04)}}) 
	AADD(aButtons, {2, .T., {|| FechaBatch()}})
	
	FormBatch(cCadastro, aSays, aButtons)

Return

Static function PRMINUDESP(mv_par01, mv_par02, mv_par03, mv_par04)

	Local cAliasQry := GetNextAlias()
	Local cNomeTrab
	Local nRowCent := 10
	Local nColCent := 10
	
	Local oFont1 := TFont():New("Arial",15,15,,.T.,,,,,.F.)   // Negrito
	Local oFont2 := TFont():New("Arial",13,13,,.F.,,,,,.F.)   // Normal
	Local oFont3 := TFont():New("Arial",10,10,,.F.,,,,,.F.)   // Normal
	Local oFont4 := TFont():New("Arial",10,10,,.T.,,,,,.F.)   // Negrito
	Local oFont5 := TFont():New("Arial",11,11,,.F.,,,,,.F.)   // Normal
	Local oFont6 := TFont():New("Arial",08,08,,.F.,,,,,.F.)   // Normal
	Local oFont7 := TFont():New("Arial",09,09,,.F.,,,,,.F.)   // Normal
	
	Local cLogoFil := ""
	
	If SubStr(xFilial("SF2"),1,2) == "01"
		cLogoFil := "DANFE010102.bmp"
	EndIf
	
	If SubStr(xFilial("SF2"),1,2) == "02"
		cLogoFil := "DANFE010202.bmp"
	EndIf
	
	If mv_par01 == 1
		BeginSql Alias cAliasQry
			SELECT F2_FILIAL,F2_DOC,F2_SERIE,F2_EMISSAO,F2_CLIENTE,F2_LOJA,F2_VALBRUT,F2_PBRUTO,F2_PLIQUI,F2_VALMERC,F2_VALIPI,F2_ICMSRET,
				F2_FRETE, F2_TPFRETE, F2_SEGURO,F2_TIPO,F2_TRANSP,
				F2_ESPECI1,F2_ESPECI2,F2_ESPECI3,F2_ESPECI4,F2_ESPECI5,F2_ESPECI6,
				F2_VOLUME1,F2_VOLUME2,F2_VOLUME3,F2_VOLUME4,F2_VOLUME5,F2_VOLUME6,
				A4_NOME, A4_DDD, A4_TEL, A4_END, A4_BAIRRO, A4_MUN, A4_EST,
				A1_NOME, A1_DDD, A1_TEL, A1_END, A1_BAIRRO, A1_MUN, A1_EST
			FROM %Table:SF2% SF2
				LEFT JOIN %Table:SA4% SA4 ON SA4.%NotDel% AND A4_FILIAL = %xFilial:SA4%
					AND A4_COD = F2_TRANSP
				LEFT JOIN %Table:SA1% SA1 ON SA1.%NotDel% AND A1_FILIAL = %xFilial:SA4%
					AND A1_COD = F2_CLIENTE
			WHERE F2_FILIAL = %xFilial:SF2% AND 
				F2_CHVNFE <> '' AND
				F2_XMINUDE = 'F' AND
				SF2.%NotDel%
			ORDER BY F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA
		EndSql
	EndIf 
	
	If mv_par01 == 2
		BeginSql Alias cAliasQry
			SELECT F2_FILIAL,F2_DOC,F2_SERIE,F2_EMISSAO,F2_CLIENTE,F2_LOJA,F2_VALBRUT,F2_PBRUTO,F2_PLIQUI,F2_VALMERC,F2_VALIPI,F2_ICMSRET,
				F2_FRETE, F2_TPFRETE, F2_SEGURO,F2_TIPO,F2_TRANSP,
				F2_ESPECI1,F2_ESPECI2,F2_ESPECI3,F2_ESPECI4,F2_ESPECI5,F2_ESPECI6,
				F2_VOLUME1,F2_VOLUME2,F2_VOLUME3,F2_VOLUME4,F2_VOLUME5,F2_VOLUME6,
				A4_NOME, A4_DDD, A4_TEL, A4_END, A4_BAIRRO, A4_MUN, A4_EST,
				A1_NOME, A1_DDD, A1_TEL, A1_END, A1_BAIRRO, A1_MUN, A1_EST
			FROM %Table:SF2% SF2
				LEFT JOIN %Table:SA4% SA4 ON SA4.%NotDel% AND A4_FILIAL = %xFilial:SA4%
					AND A4_COD = F2_TRANSP
				LEFT JOIN %Table:SA1% SA1 ON SA1.%NotDel% AND A1_FILIAL = %xFilial:SA4%
					AND A1_COD = F2_CLIENTE
			WHERE F2_FILIAL = %xFilial:SF2% AND
			 	F2_CHVNFE <> '' AND
				F2_SERIE = %Exp:mv_par04%	AND
				F2_DOC >= %Exp:mv_par02% AND F2_DOC <= %Exp:mv_par03% AND
				SF2.%NotDel%
			ORDER BY F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA
		EndSql
	EndIf
	
	cNomeTrab := CriaTrab(NIL, .F.)
	
	oPrinter := TMSPRINTER():New(cNomeTrab)
	
	oPrinter:setup()

	// Converte pixel em centímetros e milímetros
	oPrinter:Cmtr2Pix(nRowCent, nColCent)
	nRowCent := nRowCent / 10
	nColCent := nColCent / 10
	
	oPrinter:SetPortRait()
	oPrinter:SetPaperSize(9)
	
	SF2->(dbSetOrder(1)) 
	
	(cAliasQry)->(dbGoTop())	
	While (cAliasQry)->(!EOF())
	
		oPrinter:StartPage()
		
		/*
		MS = MARGEM SUPEIOR
		MI = MARGEM INFERIOR
		AL = ACRÉSCIMO DA LINHA
		
		ME = MARGEM ESQUERDA
		MD = MARGEM DIREITA
		AC = ACRÉSCIMO DA COLUNA
		
		DM = DESCONTO DA MARGEM
		AM = ACRÉSCIMO DA MARGEM
		C2P = CENTÍMETROS PARA PIXELS
		*/
		
		//          ((MS  -DM +AL )*C2P    , (ME  -DM + AC)*C2P    , (MI  -DM +AL )*C2P    , (MD  +AM +AC )*C2P    )
		oPrinter:Box((01.0-0.0+0.0)*nRowCent, (01.0-0.5+0.0)*nColCent, (13.7-0.0+0.0)*nRowCent, (20.0+0.5+0.0)*nColCent)	
		
		oPrinter:Box((01.0-0.0+0.0)*nRowCent, (01.0-0.5+0.0)*nColCent, (03.6-0.3+0.0)*nRowCent, (07.5-0.5+0.3)*nColCent)
		oPrinter:Box((01.0-0.0+0.0)*nRowCent, (07.5-0.5+0.3)*nColCent, (03.6-0.3+0.0)*nRowCent, (13.5-0.5+0.6)*nColCent)
		oPrinter:Box((01.0-0.0+0.0)*nRowCent, (13.5-0.5+0.6)*nColCent, (03.6-0.3+0.0)*nRowCent, (20.0+0.5+0.0)*nColCent)
		
		oPrinter:Box((03.6-0.3+0.0)*nRowCent, (01.0-0.5+0.0)*nColCent, (05.1-0.3+0.0)*nRowCent, (20.0+0.5+0.0)*nColCent)
		oPrinter:Box((05.1-0.3+0.0)*nRowCent, (01.0-0.5+0.0)*nColCent, (06.6-0.3+0.1)*nRowCent, (20.0+0.5+0.0)*nColCent)
		
		oPrinter:Box((06.6-0.3+0.1)*nRowCent, (01.0-0.5+0.0)*nColCent, (07.3-0.3+0.0)*nRowCent, (07.5-0.5+0.3)*nColCent)
		oPrinter:Box((06.6-0.3+0.1)*nRowCent, (07.5-0.5+0.3)*nColCent, (07.3-0.3+0.0)*nRowCent, (13.5-0.5+0.6)*nColCent)
		oPrinter:Box((06.6-0.3+0.1)*nRowCent, (13.5-0.5+0.6)*nColCent, (07.3-0.3+0.0)*nRowCent, (20.0+0.5+0.0)*nColCent)
		
		oPrinter:Box((07.3-0.3+0.0)*nRowCent, (01.0-0.5+0.0)*nColCent, (08.3-0.3+0.0)*nRowCent, (07.5-0.5+0.3)*nColCent)
		oPrinter:Box((07.3-0.3+0.0)*nRowCent, (07.5-0.5+0.3)*nColCent, (08.3-0.3+0.0)*nRowCent, (13.5-0.5+0.6)*nColCent)
		oPrinter:Box((07.3-0.3+0.0)*nRowCent, (13.5-0.5+0.6)*nColCent, (08.3-0.3+0.0)*nRowCent, (20.0+0.5+0.0)*nColCent)
		
		oPrinter:Box((08.3-0.3+0.0)*nRowCent, (01.0-0.5+0.0)*nColCent, (09.0-0.3+0.0)*nRowCent, (04.8-0.5+0.2)*nColCent)
		oPrinter:Box((08.3-0.3+0.0)*nRowCent, (04.8-0.5+0.2)*nColCent, (09.0-0.3+0.0)*nRowCent, (08.6-0.5+0.4)*nColCent)
		oPrinter:Box((08.3-0.3+0.0)*nRowCent, (08.6-0.5+0.4)*nColCent, (09.0-0.3+0.0)*nRowCent, (12.4-0.5+0.5)*nColCent)
		oPrinter:Box((08.3-0.3+0.0)*nRowCent, (12.4-0.5+0.5)*nColCent, (09.0-0.3+0.0)*nRowCent, (16.2-0.5+0.7)*nColCent)
		oPrinter:Box((08.3-0.3+0.0)*nRowCent, (16.2-0.5+0.7)*nColCent, (09.0-0.3+0.0)*nRowCent, (20.0+0.5+0.0)*nColCent)
		
		oPrinter:Box((09.0-0.3+0.0)*nRowCent, (01.0-0.5+0.0)*nColCent, (11.3-0.3+0.0)*nRowCent, (04.8-0.5+0.2)*nColCent)
		oPrinter:Box((09.0-0.3+0.0)*nRowCent, (04.8-0.5+0.2)*nColCent, (11.3-0.3+0.0)*nRowCent, (08.6-0.5+0.4)*nColCent)
		oPrinter:Box((09.0-0.3+0.0)*nRowCent, (08.6-0.5+0.4)*nColCent, (11.3-0.3+0.0)*nRowCent, (12.4-0.5+0.5)*nColCent)
		oPrinter:Box((09.0-0.3+0.0)*nRowCent, (12.4-0.5+0.5)*nColCent, (11.3-0.3+0.0)*nRowCent, (16.2-0.5+0.7)*nColCent)
		oPrinter:Box((09.0-0.3+0.0)*nRowCent, (16.2-0.5+0.7)*nColCent, (11.3-0.3+0.0)*nRowCent, (20.0+0.5+0.0)*nColCent)
		
		oPrinter:Box((11.3-0.3+0.0)*nRowCent, (01.0-0.5+0.0)*nColCent, (13.7-0.0+0.0)*nRowCent, (05.8-0.5+0.3)*nColCent)
		oPrinter:Box((11.3-0.3+0.0)*nRowCent, (05.8-0.5+0.3)*nColCent, (13.7-0.0+0.0)*nRowCent, (12.0-0.5+0.6)*nColCent)
		oPrinter:Box((11.3-0.3+0.0)*nRowCent, (12.0-0.5+0.6)*nColCent, (13.7-0.0+0.0)*nRowCent, (20.0+0.5+0.0)*nColCent)
		
		oPrinter:Say((14.7-0.0+0.0)*nRowCent, (01.0-0.5+0.0)*nColCent,"Cortar aqui " + Replicate(".",230))
		
		//						  +SEGUNDA VIA										   	 +SEGUNDA VIA
		oPrinter:Box((01.0-0.0+0.0+15.2)*nRowCent, (01.0-0.5+0.0)*nColCent, (13.7-0.0+0.0+15.2)*nRowCent, (20.0+0.5+0.0)*nColCent)
		
		oPrinter:Box((01.0-0.0+0.0+15.2)*nRowCent, (01.0-0.5+0.0)*nColCent, (03.6-0.3+0.0+15.2)*nRowCent, (07.5-0.5+0.3)*nColCent)
		oPrinter:Box((01.0-0.0+0.0+15.2)*nRowCent, (07.5-0.5+0.3)*nColCent, (03.6-0.3+0.0+15.2)*nRowCent, (13.5-0.5+0.6)*nColCent)
		oPrinter:Box((01.0-0.0+0.0+15.2)*nRowCent, (13.5-0.5+0.6)*nColCent, (03.6-0.3+0.0+15.2)*nRowCent, (20.0+0.5+0.0)*nColCent)
		
		oPrinter:Box((03.6-0.3+0.0+15.2)*nRowCent, (01.0-0.5+0.0)*nColCent, (05.1-0.3+0.0+15.2)*nRowCent, (20.0+0.5+0.0)*nColCent)
		oPrinter:Box((05.1-0.3+0.0+15.2)*nRowCent, (01.0-0.5+0.0)*nColCent, (06.6-0.3+0.1+15.2)*nRowCent, (20.0+0.5+0.0)*nColCent)
		
		oPrinter:Box((06.6-0.3+0.1+15.2)*nRowCent, (01.0-0.5+0.0)*nColCent, (07.3-0.3+0.0+15.2)*nRowCent, (07.5-0.5+0.3)*nColCent)
		oPrinter:Box((06.6-0.3+0.1+15.2)*nRowCent, (07.5-0.5+0.3)*nColCent, (07.3-0.3+0.0+15.2)*nRowCent, (13.5-0.5+0.6)*nColCent)
		oPrinter:Box((06.6-0.3+0.1+15.2)*nRowCent, (13.5-0.5+0.6)*nColCent, (07.3-0.3+0.0+15.2)*nRowCent, (20.0+0.5+0.0)*nColCent)
		
		oPrinter:Box((07.3-0.3+0.0+15.2)*nRowCent, (01.0-0.5+0.0)*nColCent, (08.3-0.3+0.0+15.2)*nRowCent, (07.5-0.5+0.3)*nColCent)
		oPrinter:Box((07.3-0.3+0.0+15.2)*nRowCent, (07.5-0.5+0.3)*nColCent, (08.3-0.3+0.0+15.2)*nRowCent, (13.5-0.5+0.6)*nColCent)
		oPrinter:Box((07.3-0.3+0.0+15.2)*nRowCent, (13.5-0.5+0.6)*nColCent, (08.3-0.3+0.0+15.2)*nRowCent, (20.0+0.5+0.0)*nColCent)
		
		oPrinter:Box((08.3-0.3+0.0+15.2)*nRowCent, (01.0-0.5+0.0)*nColCent, (09.0-0.3+0.0+15.2)*nRowCent, (04.8-0.5+0.2)*nColCent)
		oPrinter:Box((08.3-0.3+0.0+15.2)*nRowCent, (04.8-0.5+0.2)*nColCent, (09.0-0.3+0.0+15.2)*nRowCent, (08.6-0.5+0.4)*nColCent)
		oPrinter:Box((08.3-0.3+0.0+15.2)*nRowCent, (08.6-0.5+0.4)*nColCent, (09.0-0.3+0.0+15.2)*nRowCent, (12.4-0.5+0.5)*nColCent)
		oPrinter:Box((08.3-0.3+0.0+15.2)*nRowCent, (12.4-0.5+0.5)*nColCent, (09.0-0.3+0.0+15.2)*nRowCent, (16.2-0.5+0.7)*nColCent)
		oPrinter:Box((08.3-0.3+0.0+15.2)*nRowCent, (16.2-0.5+0.7)*nColCent, (09.0-0.3+0.0+15.2)*nRowCent, (20.0+0.5+0.0)*nColCent)
		
		oPrinter:Box((09.0-0.3+0.0+15.2)*nRowCent, (01.0-0.5+0.0)*nColCent, (11.3-0.3+0.0+15.2)*nRowCent, (04.8-0.5+0.2)*nColCent)
		oPrinter:Box((09.0-0.3+0.0+15.2)*nRowCent, (04.8-0.5+0.2)*nColCent, (11.3-0.3+0.0+15.2)*nRowCent, (08.6-0.5+0.4)*nColCent)
		oPrinter:Box((09.0-0.3+0.0+15.2)*nRowCent, (08.6-0.5+0.4)*nColCent, (11.3-0.3+0.0+15.2)*nRowCent, (12.4-0.5+0.5)*nColCent)
		oPrinter:Box((09.0-0.3+0.0+15.2)*nRowCent, (12.4-0.5+0.5)*nColCent, (11.3-0.3+0.0+15.2)*nRowCent, (16.2-0.5+0.7)*nColCent)
		oPrinter:Box((09.0-0.3+0.0+15.2)*nRowCent, (16.2-0.5+0.7)*nColCent, (11.3-0.3+0.0+15.2)*nRowCent, (20.0+0.5+0.0)*nColCent)
		
		oPrinter:Box((11.3-0.3+0.0+15.2)*nRowCent, (01.0-0.5+0.0)*nColCent, (13.7-0.0+0.0+15.2)*nRowCent, (05.8-0.5+0.3)*nColCent)
		oPrinter:Box((11.3-0.3+0.0+15.2)*nRowCent, (05.8-0.5+0.3)*nColCent, (13.7-0.0+0.0+15.2)*nRowCent, (12.0-0.5+0.6)*nColCent)
		oPrinter:Box((11.3-0.3+0.0+15.2)*nRowCent, (12.0-0.5+0.6)*nColCent, (13.7-0.0+0.0+15.2)*nRowCent, (20.0+0.5+0.0)*nColCent)
		
		oPrinter:SayBitmap ( (01.3-0.0+0.0)*nRowCent, (02.0-0.5+0.0)*nColCent, cLogoFil, 4.8*nColCent, 1.9*nRowCent )
		
		oPrinter:Say ( (01.5-0.0+0.0)*nRowCent, (08.2-0.5+0.0)*nColCent, "MINUTA DE DESPACHO", oFont1, , , , )
		oPrinter:Say ( (02.4-0.0+0.0)*nRowCent, (09.4-0.5+0.0)*nColCent, "RODOVIÁRIO"		   , oFont1, , , , )
		
		oPrinter:Say ( (01.5-0.0+0.0)*nRowCent, (14.6-0.5+0.0)*nColCent, "Nota Fiscal: " + (cAliasQry)->F2_DOC, oFont2, , , , )
		oPrinter:Say ( (02.0-0.0+0.0)*nRowCent, (14.6-0.5+0.0)*nColCent, "Data de Emissão: " + DTOC(STOD((cAliasQry)->F2_EMISSAO)), oFont2, , , , )
		
		oPrinter:Say ( (03.4-0.0+0.0)*nRowCent, (01.1-0.5+0.0)*nColCent, "Transportadora: " + (cAliasQry)->A4_NOME, oFont3, , , , )
		oPrinter:Say ( (03.4-0.0+0.0)*nRowCent, (14.5-0.5+0.0)*nColCent, "Telefone: " + (cAliasQry)->A4_DDD + " - " + (cAliasQry)->A4_TEL, oFont3, , , , )
		
		oPrinter:Say ( (03.9-0.0+0.0)*nRowCent, (01.1-0.5+0.0)*nColCent, "Endereço.........: " + (cAliasQry)->A4_END, oFont3, , , , )
		oPrinter:Say ( (03.9-0.0+0.0)*nRowCent, (14.5-0.5+0.0)*nColCent, "Bairro...: " + (cAliasQry)->A4_BAIRRO, oFont3, , , , )
		
		oPrinter:Say ( (04.4-0.0+0.0)*nRowCent, (01.1-0.5+0.0)*nColCent, "Município.........: " + (cAliasQry)->A4_MUN, oFont3, , , , )
		oPrinter:Say ( (04.4-0.0+0.0)*nRowCent, (14.5-0.5+0.0)*nColCent, "Estado..: " + (cAliasQry)->A4_EST, oFont3, , , , )
		
		oPrinter:Say ( (04.9-0.0+0.0)*nRowCent, (01.1-0.5+0.0)*nColCent, "Destinatário.....: " + (cAliasQry)->A1_NOME, oFont3, , , , )
		oPrinter:Say ( (04.9-0.0+0.0)*nRowCent, (14.5-0.5+0.0)*nColCent, "Telefone: " + (cAliasQry)->A1_DDD + " - " + (cAliasQry)->A1_TEL, oFont3, , , , )
		
		oPrinter:Say ( (05.4-0.0+0.0)*nRowCent, (01.1-0.5+0.0)*nColCent, "Endereço.........: " + (cAliasQry)->A1_END, oFont3, , , , )
		oPrinter:Say ( (05.4-0.0+0.0)*nRowCent, (14.5-0.5+0.0)*nColCent, "Bairro...: " + (cAliasQry)->A1_BAIRRO, oFont3, , , , )
		
		oPrinter:Say ( (05.9-0.0+0.0)*nRowCent, (01.1-0.5+0.0)*nColCent, "Município.........: " + (cAliasQry)->A1_MUN, oFont3, , , , )
		oPrinter:Say ( (05.9-0.0+0.0)*nRowCent, (14.5-0.5+0.0)*nColCent, "Estado..: " + (cAliasQry)->A1_EST, oFont3, , , , )
		
		oPrinter:Say ( (06.3-0.0+0.2)*nRowCent, (03.5-0.5+0.0)*nColCent, "CONTEÚDO", oFont4, , , , )
		oPrinter:Say ( (06.3-0.0+0.2)*nRowCent, (10.0-0.5+0.0)*nColCent, "NOTA FISCAL", oFont4, , , , )
		oPrinter:Say ( (06.3-0.0+0.2)*nRowCent, (15.8-0.5+0.0)*nColCent, "VALOR DA NOTA FISCAL", oFont4, , , , )
		
		oPrinter:Say ( (07.1-0.0+0.2)*nRowCent, (03.5-0.5+0.0)*nColCent, "", oFont5, , , , )
		oPrinter:Say ( (07.1-0.0+0.2)*nRowCent, (10.0-0.5+0.0)*nColCent, (cAliasQry)->F2_DOC, oFont5, , , , )
		oPrinter:Say ( (07.1-0.0+0.2)*nRowCent, (15.8-0.5+0.0)*nColCent, Transform((cAliasQry)->F2_VALBRUT, PESQPICT("SF2","F2_VALBRUT")), oFont5, , , , )
		
		oPrinter:Say ( (08.0-0.0+0.2)*nRowCent, (02.4-0.5+0.0)*nColCent, "MARCA", oFont4, , , , )
		oPrinter:Say ( (08.0-0.0+0.2)*nRowCent, (05.9-0.5+0.0)*nColCent, "QUANTIDADE", oFont4, , , , )
		oPrinter:Say ( (08.0-0.0+0.2)*nRowCent, (10.2-0.5+0.0)*nColCent, "ESPÉCIE", oFont4, , , , )
		oPrinter:Say ( (08.0-0.0+0.2)*nRowCent, (14.5-0.5+0.0)*nColCent, "PESO", oFont4, , , , )
		oPrinter:Say ( (08.0-0.0+0.2)*nRowCent, (18.2-0.5+0.0)*nColCent, "NÚMERO", oFont4, , , , )
		
		oPrinter:Say ( (08.6-0.0+0.2)*nRowCent, (02.4-0.5+0.0)*nColCent, "", oFont3, , , , )
		If !Empty((cAliasQry)->F2_ESPECI1)
			oPrinter:Say ( (08.6-0.0+0.2)*nRowCent, (06.6-0.5+0.0)*nColCent, CVALTOCHAR((cAliasQry)->F2_VOLUME1), oFont6, , , , )
			oPrinter:Say ( (08.6-0.0+0.2)*nRowCent, (09.7-0.5+0.0)*nColCent, (cAliasQry)->F2_ESPECI1, oFont6, , , , )
		EndIf
		If !Empty((cAliasQry)->F2_ESPECI2)
			oPrinter:Say ( (08.9-0.0+0.2)*nRowCent, (06.6-0.5+0.0)*nColCent, CVALTOCHAR((cAliasQry)->F2_VOLUME2), oFont6, , , , )
			oPrinter:Say ( (08.9-0.0+0.2)*nRowCent, (09.7-0.5+0.0)*nColCent, (cAliasQry)->F2_ESPECI2, oFont6, , , , )
		EndIf
		If !Empty((cAliasQry)->F2_ESPECI3)
			oPrinter:Say ( (09.2-0.0+0.2)*nRowCent, (06.6-0.5+0.0)*nColCent, CVALTOCHAR((cAliasQry)->F2_VOLUME3), oFont6, , , , )
			oPrinter:Say ( (09.2-0.0+0.2)*nRowCent, (09.7-0.5+0.0)*nColCent, (cAliasQry)->F2_ESPECI3, oFont6, , , , )
		EndIf
		If !Empty((cAliasQry)->F2_ESPECI4)
			oPrinter:Say ( (09.5-0.0+0.2)*nRowCent, (06.6-0.5+0.0)*nColCent, CVALTOCHAR((cAliasQry)->F2_VOLUME4), oFont6, , , , )
			oPrinter:Say ( (09.5-0.0+0.2)*nRowCent, (09.7-0.5+0.0)*nColCent, (cAliasQry)->F2_ESPECI4, oFont6, , , , )
		EndIf
		If !Empty((cAliasQry)->F2_ESPECI5)
			oPrinter:Say ( (09.8-0.0+0.2)*nRowCent, (06.6-0.5+0.0)*nColCent, CVALTOCHAR((cAliasQry)->F2_VOLUME5), oFont6, , , , )
			oPrinter:Say ( (09.8-0.0+0.2)*nRowCent, (09.7-0.5+0.0)*nColCent, (cAliasQry)->F2_ESPECI5, oFont6, , , , )
		EndIf
		If !Empty((cAliasQry)->F2_ESPECI6)
			oPrinter:Say ( (10.1-0.0+0.2)*nRowCent, (06.6-0.5+0.0)*nColCent, CVALTOCHAR((cAliasQry)->F2_VOLUME6), oFont6, , , , )
			oPrinter:Say ( (10.1-0.0+0.2)*nRowCent, (09.7-0.5+0.0)*nColCent, (cAliasQry)->F2_ESPECI6, oFont6, , , , )
		EndIf
		oPrinter:Say ( (08.6-0.0+0.2)*nRowCent, (14.5-0.5+0.0)*nColCent, Transform((cAliasQry)->F2_PBRUTO, PESQPICT("SF2","F2_PBRUTO")), oFont3, , , , )
		oPrinter:Say ( (08.6-0.0+0.2)*nRowCent, (18.2-0.5+0.0)*nColCent, "", oFont3, , , , )
		
		oPrinter:Say ( (11.1-0.0+0.0)*nRowCent, (01.1-0.5+0.0)*nColCent, "SEGURO (R$)", oFont4, , , , )
		oPrinter:Say ( (11.1-0.0+0.0)*nRowCent, (06.2-0.5+0.0)*nColCent, "FRETE (R$): ", oFont4, , , , )
		oPrinter:Say ( (11.1-0.0+0.0)*nRowCent, (08.2-0.5+0.0)*nColCent, "Destinatário", oFont3, , , , )
		
		oPrinter:Say ( (12.0-0.0+0.0)*nRowCent, (02.0-0.5+0.0)*nColCent, Transform((cAliasQry)->F2_SEGURO, PESQPICT("SF2","F2_SEGURO")), oFont5, , , , )
		oPrinter:Say ( (12.0-0.0+0.0)*nRowCent, (07.0-0.5+0.0)*nColCent, Transform((cAliasQry)->F2_FRETE, PESQPICT("SF2","F2_FRETE")), oFont5, , , , )
		
		oPrinter:Say ( (11.1-0.0+0.0)*nRowCent, (12.8-0.5+0.0)*nColCent, "Declaro ter recebido da CAMBUCI METALÚRGICA LTDA. para", oFont6, , , , )
		oPrinter:Say ( (11.4-0.0+0.0)*nRowCent, (12.8-0.5+0.0)*nColCent, "despacho do(s) volume(s) acima descrito(s).", oFont6, , , , )
		
		oPrinter:Say ( (12.3-0.0+0.0)*nRowCent, (12.8-0.5+0.0)*nColCent, "___/___/______", oFont2, , , , )
		oPrinter:Say ( (12.3-0.0+0.0)*nRowCent, (16.5-0.5+0.0)*nColCent, "__________________", oFont2, , , , )
		
		oPrinter:Say ( (12.9-0.0+0.0)*nRowCent, (13.8-0.5+0.0)*nColCent, "DATA", oFont3, , , , )
		oPrinter:Say ( (12.9-0.0+0.0)*nRowCent, (17.5-0.5+0.0)*nColCent, "ASSINATURA", oFont3, , , , )
		
		//						  		  +SEGUNDA VIA							
		oPrinter:SayBitmap ( (01.3-0.0+0.0+15.2)*nRowCent, (02.0-0.5+0.0)*nColCent, cLogoFil, 4.8*nColCent, 1.9*nRowCent )
		
		oPrinter:Say ( (01.5-0.0+0.0+15.2)*nRowCent, (08.2-0.5+0.0)*nColCent, "MINUTA DE DESPACHO", oFont1, , , , )
		oPrinter:Say ( (02.4-0.0+0.0+15.2)*nRowCent, (09.4-0.5+0.0)*nColCent, "RODOVIÁRIO"		   , oFont1, , , , )
		
		oPrinter:Say ( (01.5-0.0+0.0+15.2)*nRowCent, (14.6-0.5+0.0)*nColCent, "Nota Fiscal: " + (cAliasQry)->F2_DOC, oFont2, , , , )
		oPrinter:Say ( (02.0-0.0+0.0+15.2)*nRowCent, (14.6-0.5+0.0)*nColCent, "Data de Emissão: " + DTOC(STOD((cAliasQry)->F2_EMISSAO)), oFont2, , , , )
		
		oPrinter:Say ( (03.4-0.0+0.0+15.2)*nRowCent, (01.1-0.5+0.0)*nColCent, "Transportadora: " + (cAliasQry)->A4_NOME, oFont3, , , , )
		oPrinter:Say ( (03.4-0.0+0.0+15.2)*nRowCent, (14.5-0.5+0.0)*nColCent, "Telefone: " + (cAliasQry)->A4_DDD + " - " + (cAliasQry)->A4_TEL, oFont3, , , , )
		
		oPrinter:Say ( (03.9-0.0+0.0+15.2)*nRowCent, (01.1-0.5+0.0)*nColCent, "Endereço.........: " + (cAliasQry)->A4_END, oFont3, , , , )
		oPrinter:Say ( (03.9-0.0+0.0+15.2)*nRowCent, (14.5-0.5+0.0)*nColCent, "Bairro...: " + (cAliasQry)->A4_BAIRRO, oFont3, , , , )
		
		oPrinter:Say ( (04.4-0.0+0.0+15.2)*nRowCent, (01.1-0.5+0.0)*nColCent, "Município.........: " + (cAliasQry)->A4_MUN, oFont3, , , , )
		oPrinter:Say ( (04.4-0.0+0.0+15.2)*nRowCent, (14.5-0.5+0.0)*nColCent, "Estado..: " + (cAliasQry)->A4_EST, oFont3, , , , )
		
		oPrinter:Say ( (04.9-0.0+0.0+15.2)*nRowCent, (01.1-0.5+0.0)*nColCent, "Destinatário.....: " + (cAliasQry)->A1_NOME, oFont3, , , , )
		oPrinter:Say ( (04.9-0.0+0.0+15.2)*nRowCent, (14.5-0.5+0.0)*nColCent, "Telefone: " + (cAliasQry)->A1_DDD + " - " + (cAliasQry)->A1_TEL, oFont3, , , , )
		
		oPrinter:Say ( (05.4-0.0+0.0+15.2)*nRowCent, (01.1-0.5+0.0)*nColCent, "Endereço.........: " + (cAliasQry)->A1_END, oFont3, , , , )
		oPrinter:Say ( (05.4-0.0+0.0+15.2)*nRowCent, (14.5-0.5+0.0)*nColCent, "Bairro...: " + (cAliasQry)->A1_BAIRRO, oFont3, , , , )
		
		oPrinter:Say ( (05.9-0.0+0.0+15.2)*nRowCent, (01.1-0.5+0.0)*nColCent, "Município.........: " + (cAliasQry)->A1_MUN, oFont3, , , , )
		oPrinter:Say ( (05.9-0.0+0.0+15.2)*nRowCent, (14.5-0.5+0.0)*nColCent, "Estado..: " + (cAliasQry)->A1_EST, oFont3, , , , )
		
		oPrinter:Say ( (06.3-0.0+0.2+15.2)*nRowCent, (03.5-0.5+0.0)*nColCent, "CONTEÚDO", oFont4, , , , )
		oPrinter:Say ( (06.3-0.0+0.2+15.2)*nRowCent, (10.0-0.5+0.0)*nColCent, "NOTA FISCAL", oFont4, , , , )
		oPrinter:Say ( (06.3-0.0+0.2+15.2)*nRowCent, (15.8-0.5+0.0)*nColCent, "VALOR DA NOTA FISCAL", oFont4, , , , )
		
		oPrinter:Say ( (07.1-0.0+0.2+15.2)*nRowCent, (03.5-0.5+0.0)*nColCent, "", oFont5, , , , )
		oPrinter:Say ( (07.1-0.0+0.2+15.2)*nRowCent, (10.0-0.5+0.0)*nColCent, (cAliasQry)->F2_DOC, oFont5, , , , )
		oPrinter:Say ( (07.1-0.0+0.2+15.2)*nRowCent, (15.8-0.5+0.0)*nColCent, Transform((cAliasQry)->F2_VALBRUT, PESQPICT("SF2","F2_VALBRUT")), oFont5, , , , )
		
		oPrinter:Say ( (08.0-0.0+0.2+15.2)*nRowCent, (02.4-0.5+0.0)*nColCent, "MARCA", oFont4, , , , )
		oPrinter:Say ( (08.0-0.0+0.2+15.2)*nRowCent, (05.9-0.5+0.0)*nColCent, "QUANTIDADE", oFont4, , , , )
		oPrinter:Say ( (08.0-0.0+0.2+15.2)*nRowCent, (10.2-0.5+0.0)*nColCent, "ESPÉCIE", oFont4, , , , )
		oPrinter:Say ( (08.0-0.0+0.2+15.2)*nRowCent, (14.5-0.5+0.0)*nColCent, "PESO", oFont4, , , , )
		oPrinter:Say ( (08.0-0.0+0.2+15.2)*nRowCent, (18.2-0.5+0.0)*nColCent, "NÚMERO", oFont4, , , , )
		
		oPrinter:Say ( (08.6-0.0+0.2+15.2)*nRowCent, (02.4-0.5+0.0)*nColCent, "", oFont3, , , , )
		If !Empty((cAliasQry)->F2_ESPECI1)
			oPrinter:Say ( (08.6-0.0+0.2+15.2)*nRowCent, (06.6-0.5+0.0)*nColCent, CVALTOCHAR((cAliasQry)->F2_VOLUME1), oFont6, , , , )
			oPrinter:Say ( (08.6-0.0+0.2+15.2)*nRowCent, (09.7-0.5+0.0)*nColCent, (cAliasQry)->F2_ESPECI1, oFont6, , , , )
		EndIf
		If !Empty((cAliasQry)->F2_ESPECI2)
			oPrinter:Say ( (08.9-0.0+0.2+15.2)*nRowCent, (06.6-0.5+0.0)*nColCent, CVALTOCHAR((cAliasQry)->F2_VOLUME2), oFont6, , , , )
			oPrinter:Say ( (08.9-0.0+0.2+15.2)*nRowCent, (09.7-0.5+0.0)*nColCent, (cAliasQry)->F2_ESPECI2, oFont6, , , , )
		EndIf
		If !Empty((cAliasQry)->F2_ESPECI3)
			oPrinter:Say ( (09.2-0.0+0.2+15.2)*nRowCent, (06.6-0.5+0.0)*nColCent, CVALTOCHAR((cAliasQry)->F2_VOLUME3), oFont6, , , , )
			oPrinter:Say ( (09.2-0.0+0.2+15.2)*nRowCent, (09.7-0.5+0.0)*nColCent, (cAliasQry)->F2_ESPECI3, oFont6, , , , )
		EndIf
		If !Empty((cAliasQry)->F2_ESPECI4)
			oPrinter:Say ( (09.5-0.0+0.2+15.2)*nRowCent, (06.6-0.5+0.0)*nColCent, CVALTOCHAR((cAliasQry)->F2_VOLUME4), oFont6, , , , )
			oPrinter:Say ( (09.5-0.0+0.2+15.2)*nRowCent, (09.7-0.5+0.0)*nColCent, (cAliasQry)->F2_ESPECI4, oFont6, , , , )
		EndIf
		If !Empty((cAliasQry)->F2_ESPECI5)
			oPrinter:Say ( (09.8-0.0+0.2+15.2)*nRowCent, (06.6-0.5+0.0)*nColCent, CVALTOCHAR((cAliasQry)->F2_VOLUME5), oFont6, , , , )
			oPrinter:Say ( (09.8-0.0+0.2+15.2)*nRowCent, (09.7-0.5+0.0)*nColCent, (cAliasQry)->F2_ESPECI5, oFont6, , , , )
		EndIf
		If !Empty((cAliasQry)->F2_ESPECI6)
			oPrinter:Say ( (10.1-0.0+0.2+15.2)*nRowCent, (06.6-0.5+0.0)*nColCent, CVALTOCHAR((cAliasQry)->F2_VOLUME6), oFont6, , , , )
			oPrinter:Say ( (10.1-0.0+0.2+15.2)*nRowCent, (09.7-0.5+0.0)*nColCent, (cAliasQry)->F2_ESPECI6, oFont6, , , , )
		EndIf
		oPrinter:Say ( (08.6-0.0+0.2+15.2)*nRowCent, (14.5-0.5+0.0)*nColCent, Transform((cAliasQry)->F2_PBRUTO, PESQPICT("SF2","F2_PBRUTO")), oFont3, , , , )
		oPrinter:Say ( (08.6-0.0+0.2+15.2)*nRowCent, (18.2-0.5+0.0)*nColCent, "", oFont3, , , , )
		
		oPrinter:Say ( (11.1-0.0+0.0+15.2)*nRowCent, (01.1-0.5+0.0)*nColCent, "SEGURO (R$)", oFont4, , , , )
		oPrinter:Say ( (11.1-0.0+0.0+15.2)*nRowCent, (06.2-0.5+0.0)*nColCent, "FRETE (R$): ", oFont4, , , , )
		oPrinter:Say ( (11.1-0.0+0.0+15.2)*nRowCent, (08.2-0.5+0.0)*nColCent, "Destinatário", oFont3, , , , )
		
		oPrinter:Say ( (12.0-0.0+0.0+15.2)*nRowCent, (02.0-0.5+0.0)*nColCent, Transform((cAliasQry)->F2_SEGURO, PESQPICT("SF2","F2_SEGURO")), oFont5, , , , )
		oPrinter:Say ( (12.0-0.0+0.0+15.2)*nRowCent, (07.0-0.5+0.0)*nColCent, Transform((cAliasQry)->F2_FRETE, PESQPICT("SF2","F2_FRETE")), oFont5, , , , )
		
		oPrinter:Say ( (11.1-0.0+0.0+15.2)*nRowCent, (12.8-0.5+0.0)*nColCent, "Declaro ter recebido da CAMBUCI METALÚRGICA LTDA. para", oFont6, , , , )
		oPrinter:Say ( (11.4-0.0+0.0+15.2)*nRowCent, (12.8-0.5+0.0)*nColCent, "despacho do(s) volume(s) acima descrito(s).", oFont6, , , , )
		
		oPrinter:Say ( (12.3-0.0+0.0+15.2)*nRowCent, (12.8-0.5+0.0)*nColCent, "___/___/______", oFont2, , , , )
		oPrinter:Say ( (12.3-0.0+0.0+15.2)*nRowCent, (16.5-0.5+0.0)*nColCent, "__________________", oFont2, , , , )
		
		oPrinter:Say ( (12.9-0.0+0.0+15.2)*nRowCent, (13.8-0.5+0.0)*nColCent, "DATA", oFont3, , , , )
		oPrinter:Say ( (12.9-0.0+0.0+15.2)*nRowCent, (17.5-0.5+0.0)*nColCent, "ASSINATURA", oFont3, , , , )
					
		oPrinter:EndPage()
		
		SF2->(dbseek(xFilial("SF2") + (cAliasQry)->F2_DOC + (cAliasQry)->F2_SERIE + (cAliasQry)->F2_CLIENTE + (cAliasQry)->F2_LOJA))
		RECLOCK("SF2", .F.)
			SF2->F2_XMINUDE := .T.
		SF2->(MSUNLOCK())
	
		(cAliasQry)->(dbSkip())
	EndDo
	
	oPrinter:Print()

Return