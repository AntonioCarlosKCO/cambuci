#INCLUDE "CBMATR720.CH" 
#Include "protheus.Ch"
//#Include "FIVEWIN.Ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CBMATR720 ³ Autor ³ Josmar Castiglioni   ³ Data ³ 01/12/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Minuta de Despacho				                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFAT  - Adaptado em 01/12/2015                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function CBMATR720()

Local oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	U_CBMR720R3()
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Marco Bianchi         ³ Data ³ 12/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport
Local lValadi  := cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0 //  Adiantamentos Mexico
#IFDEF TOP
	Local cAliasQry := GetNextAlias()
#ELSE
	Local cAliasQry := "SF2"
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New("CBMATR720",STR0024,"MTR720", {|oReport| ReportPrint(oReport,cAliasQry)},STR0022 + " " + STR0023)	// "RECIBO PARA DESPACHO"###"Este relatorio ira emitir a relacao de Recibos"###"de Despacho para as transportadoras."
oReport:SetPortrait()
oReport:SetTotalInLine(.F.)       

Pergunte(oReport:uParam,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oRecDesp := TRSection():New(oReport,STR0021,{"SF2"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "RECIBO PARA DESPACHO"
oReport:Section(1):SetLineStyle()
oReport:Section(1):SetCols(1)

TRCell():New(oRecDesp,"F2_DOC","SF2",RetTitle("F2_DOC"),PesqPict("SF2","F2_DOC"),TamSx3("F2_DOC")[1],/*lPixel*/,{|| (cAliasQry)->F2_DOC  }	)
TRCell():New(oRecDesp,"F2_VALBRUT","SF2",RetTitle("F2_VALBRUT"),PesqPict("SF2","F2_VALBRUT"),TamSx3("F2_VALBRUT")[1],/*lPixel*/,{|| (cAliasQry)->F2_VALMERC+(cAliasQry)->F2_VALIPI+(cAliasQry)->F2_FRETE+(cAliasQry)->F2_SEGURO+(cAliasQry)->F2_ICMSRET  }	)
If lValadi
	TRCell():New(oRecDesp,"F2_VALADI","SF2",RetTitle("F2_VALADI"),PesqPict("SF2","F2_VALADI"),TamSx3("F2_VALADI")[1],/*lPixel*/,{|| (cAliasQry)->F2_VALADI  }	)
EndIf

TRCell():New(oRecDesp,"A1_NOME","SA1",RetTitle("A1_NOME"),PesqPict("SA1","A1_NOME"),TamSx3("A1_NOME")[1],/*lPixel*/,{|| SA1->A1_NOME  }	)
TRCell():New(oRecDesp,"A1_END","SA1",RetTitle("A1_END"),PesqPict("SA1","A1_END"),TamSx3("A1_END")[1],/*lPixel*/,{|| SA1->A1_END  }	)
TRCell():New(oRecDesp,"A1_ENDENT","SA1",RetTitle("A1_ENDENT"),PesqPict("SA1","A1_ENDENT"),TamSx3("A1_ENDENT")[1],/*lPixel*/,{|| SA1->A1_ENDENT  }	)
TRCell():New(oRecDesp,"A1_BAIRRO","SA1",RetTitle("A1_BAIRRO"),PesqPict("SA1","A1_BAIRRO"),TamSx3("A1_BAIRRO")[1],/*lPixel*/,{|| SA1->A1_BAIRRO  }	)
TRCell():New(oRecDesp,"A1_MUN","SA1",RetTitle("A1_MUN"),PesqPict("SA1","A1_MUN"),TamSx3("A1_MUN")[1],/*lPixel*/,{|| SA1->A1_MUN  }	)
TRCell():New(oRecDesp,"A1_EST","SA1",RetTitle("A1_EST"),PesqPict("SA1","A1_EST"),TamSx3("A1_EST")[1],/*lPixel*/,{|| SA1->A1_EST  }	)

TRCell():New(oRecDesp,"A2_NOME","SA2",RetTitle("A2_NOME"),PesqPict("SA2","A2_NOME"),TamSx3("A2_NOME")[1],/*lPixel*/,{|| SA2->A2_NOME  }	)
TRCell():New(oRecDesp,"A2_END","SA2",RetTitle("A2_END"),PesqPict("SA2","A2_END"),TamSx3("A2_END")[1],/*lPixel*/,{|| SA2->A2_END  }	)
TRCell():New(oRecDesp,"A2_BAIRRO","SA2",RetTitle("A2_BAIRRO"),PesqPict("SA2","A2_BAIRRO"),TamSx3("A2_BAIRRO")[1],/*lPixel*/,{|| SA2->A2_BAIRRO  }	)
TRCell():New(oRecDesp,"A2_MUN","SA2",RetTitle("A2_MUN"),PesqPict("SA2","A2_MUN"),TamSx3("A2_MUN")[1],/*lPixel*/,{|| SA2->A2_MUN  }	)
TRCell():New(oRecDesp,"A2_EST","SA2",RetTitle("A2_EST"),PesqPict("SA2","A2_EST"),TamSx3("A2_EST")[1],/*lPixel*/,{|| SA2->A2_EST  }	)

TRCell():New(oRecDesp,"A4_NOME","SA4",RetTitle("A4_NOME"),PesqPict("SA4","A4_NOME"),TamSx3("A4_NOME")[1],/*lPixel*/,{|| SA4->A4_NOME  }	)
TRCell():New(oRecDesp,"A4_END","SA4",RetTitle("A4_END"),PesqPict("SA4","A4_END"),TamSx3("A4_END")[1],/*lPixel*/,{|| SA4->A4_END  }	)
TRCell():New(oRecDesp,"F2_PBRUTO","SF2",RetTitle("F2_PBRUTO"),PesqPict("SF2","F2_PBRUTO"),TamSx3("F2_PBRUTO")[1],/*lPixel*/,{|| (cAliasQry)->F2_PBRUTO  }	)
TRCell():New(oRecDesp,"F2_PLIQUI","SF2",RetTitle("F2_PLIQUI"),PesqPict("SF2","F2_PLIQUI"),TamSx3("F2_PLIQUI")[1],/*lPixel*/,{|| (cAliasQry)->F2_PLIQUI  }	)
TRCell():New(oRecDesp,"F2_ESPECI1","SF2",RetTitle("F2_ESPECI1"),PesqPict("SF2","F2_ESPECI1"),TamSx3("F2_ESPECI1")[1],/*lPixel*/,{|| (cAliasQry)->F2_ESPECI1  }	)
TRCell():New(oRecDesp,"F2_VOLUME1","SF2",RetTitle("F2_VOLUME1"),PesqPict("SF2","F2_VOLUME1"),TamSx3("F2_VOLUME1")[1],/*lPixel*/,{|| (cAliasQry)->F2_VOLUME1  }	)
TRCell():New(oRecDesp,"F2_ESPECI2","SF2",RetTitle("F2_ESPECI2"),PesqPict("SF2","F2_ESPECI2"),TamSx3("F2_ESPECI2")[1],/*lPixel*/,{|| (cAliasQry)->F2_ESPECI2  }	)
TRCell():New(oRecDesp,"F2_VOLUME2","SF2",RetTitle("F2_VOLUME2"),PesqPict("SF2","F2_VOLUME2"),TamSx3("F2_VOLUME2")[1],/*lPixel*/,{|| (cAliasQry)->F2_VOLUME2  }	)
TRCell():New(oRecDesp,"F2_ESPECI3","SF2",RetTitle("F2_ESPECI3"),PesqPict("SF2","F2_ESPECI3"),TamSx3("F2_ESPECI3")[1],/*lPixel*/,{|| (cAliasQry)->F2_ESPECI3  }	)
TRCell():New(oRecDesp,"F2_VOLUME3","SF2",RetTitle("F2_VOLUME3"),PesqPict("SF2","F2_VOLUME3"),TamSx3("F2_VOLUME3")[1],/*lPixel*/,{|| (cAliasQry)->F2_VOLUME3  }	)
TRCell():New(oRecDesp,"F2_ESPECI4","SF2",RetTitle("F2_ESPECI4"),PesqPict("SF2","F2_ESPECI4"),TamSx3("F2_ESPECI4")[1],/*lPixel*/,{|| (cAliasQry)->F2_ESPECI4  }	)
TRCell():New(oRecDesp,"F2_VOLUME4","SF2",RetTitle("F2_VOLUME4"),PesqPict("SF2","F2_VOLUME4"),TamSx3("F2_VOLUME4")[1],/*lPixel*/,{|| (cAliasQry)->F2_VOLUME4  }	)
TRCell():New(oRecDesp,"F2_ESPECI5","SF2",RetTitle("F2_ESPECI5"),PesqPict("SF2","F2_ESPECI5"),TamSx3("F2_ESPECI5")[1],/*lPixel*/,{|| (cAliasQry)->F2_ESPECI5  }	)
TRCell():New(oRecDesp,"F2_VOLUME5","SF2",RetTitle("F2_VOLUME5"),PesqPict("SF2","F2_VOLUME5"),TamSx3("F2_VOLUME5")[1],/*lPixel*/,{|| (cAliasQry)->F2_VOLUME5  }	)
TRCell():New(oRecDesp,"F2_ESPECI6","SF2",RetTitle("F2_ESPECI6"),PesqPict("SF2","F2_ESPECI6"),TamSx3("F2_ESPECI6")[1],/*lPixel*/,{|| (cAliasQry)->F2_ESPECI6  }	)
TRCell():New(oRecDesp,"F2_VOLUME6","SF2",RetTitle("F2_VOLUME6"),PesqPict("SF2","F2_VOLUME6"),TamSx3("F2_VOLUME6")[1],/*lPixel*/,{|| (cAliasQry)->F2_VOLUME6  }	)
//novos campos aqui - josmar

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³ Marco Bianchi         ³ Data ³ 12/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,cAliasQry)

Local nI 		:= 0
Local cEspecie  := ""
Local cVolume   := ""
Local lValadi   := cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0 //  Adiantamentos Mexico
Local cExpAdi	:= Iif(lValadi,"% ,F2_VALADI %","%%")

#IFNDEF TOP
	Local cCondicao := ""
#ENDIF


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatório                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF2")		// Cabecalho da Nota Fiscal de Saida
dbSetOrder(1)			// Doc,Serie,Cliente,Loja
#IFDEF TOP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatório da secao 1                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lQuery := .T.
	oReport:Section(1):BeginQuery()	
	BeginSql Alias cAliasQry  //campos novos aqui josmar
	SELECT F2_FILIAL,F2_DOC,F2_CLIENTE,F2_LOJA,F2_VALBRUT,F2_PBRUTO,F2_PLIQUI,F2_VALMERC,F2_VALIPI,F2_FRETE,;
		F2_SEGURO,F2_ICMSRET,F2_ESPECI1,F2_ESPECI2,F2_ESPECI3,F2_ESPECI4,F2_ESPECI5,F2_ESPECI6,F2_VOLUME1,F2_VOLUME2,F2_VOLUME3,F2_VOLUME4,;
		F2_VOLUME5,F2_VOLUME6,F2_TIPO,F2_TRANSP,F2_SERIE %Exp:cExpAdi%
	FROM %Table:SF2% SF2
	WHERE F2_FILIAL = %xFilial:SF2% AND 
		F2_SERIE = %Exp:mv_par01%	AND
		F2_DOC >= %Exp:mv_par02% AND F2_DOC <= %Exp:mv_par03% AND
		SF2.%NotDel%
	ORDER BY F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA
	EndSql 
	oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
		
#ELSE
	dbSelectArea(cAliasQry)

	cCondicao  := "F2_FILIAL=='"+xFilial("SF2")+"'.And."
	cCondicao  += "F2_SERIE == '"+MV_PAR01+"' .And. F2_DOC >= '"+MV_PAR02+"'.And."
	cCondicao  += "F2_DOC <='" + MV_PAR03+"'"
	oReport:Section(1):SetFilter(cCondicao,IndexKey())
	
#ENDIF		


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Metodo TrPosition()                                                     ³
//³                                                                        ³
//³Posiciona em um registro de uma outra tabela. O posicionamento será     ³
//³realizado antes da impressao de cada linha do relatório.                ³
//³                                                                        ³
//³                                                                        ³
//³ExpO1 : Objeto Report da Secao                                          ³
//³ExpC2 : Alias da Tabela                                                 ³
//³ExpX3 : Ordem ou NickName de pesquisa                                   ³
//³ExpX4 : String ou Bloco de código para pesquisa. A string será macroexe-³
//³        cutada.                                                         ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRPosition():New(oReport:Section(1),"SA1",1,{|| xFilial("SA1")+(cAliasQry)->F2_CLIENTE+(cAliasQry)->F2_LOJA})
TRPosition():New(oReport:Section(1),"SA2",1,{|| xFilial("SA2")+(cAliasQry)->F2_CLIENTE+(cAliasQry)->F2_LOJA})
TRPosition():New(oReport:Section(1),"SA4",1,{|| xFilial("SA4")+(cAliasQry)->F2_TRANSP})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impressao do Relatório                               				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasQry)
dbGoTop()
oReport:SetMeter((cAliasQry)->(LastRec()))
oReport:Section(1):Init()	
Do While !oReport:Cancel() .And. !Eof() .and. F2_FILIAL == xFilial("SF2")

	If !((cAliasQry)->F2_TIPO $ "DB")
		oReport:Section(1):Cell("A1_NOME"):Enable()
		oReport:Section(1):Cell("A1_END"):Enable()
		oReport:Section(1):Cell("A1_ENDENT"):Enable()
		oReport:Section(1):Cell("A1_BAIRRO"):Enable()
		oReport:Section(1):Cell("A1_MUN"):Enable()
		oReport:Section(1):Cell("A1_EST"):Enable()
		oReport:Section(1):Cell("A2_NOME"):Disable()
		oReport:Section(1):Cell("A2_END"):Disable()
		oReport:Section(1):Cell("A2_BAIRRO"):Disable()
		oReport:Section(1):Cell("A2_MUN"):Disable()
		oReport:Section(1):Cell("A2_EST"):Disable()
	Else
		oReport:Section(1):Cell("A1_NOME"):Disable()
		oReport:Section(1):Cell("A1_END"):Disable()
		oReport:Section(1):Cell("A1_ENDENT"):Disable()
		oReport:Section(1):Cell("A1_BAIRRO"):Disable()
		oReport:Section(1):Cell("A1_MUN"):Disable()
		oReport:Section(1):Cell("A1_EST"):Disable()
		oReport:Section(1):Cell("A2_NOME"):Enable()
		oReport:Section(1):Cell("A2_END"):Enable()
		oReport:Section(1):Cell("A2_BAIRRO"):Enable()
		oReport:Section(1):Cell("A2_MUN"):Enable()
		oReport:Section(1):Cell("A2_EST"):Enable()
	EndIf

	For nI := 1 to 6    //campos novos aqui josmar
		If nI >= 5
			cEspecie := "F2_ESPECI" + AllTrim(Str(nI))
			cVolume  := "F2_VOLUME" + AllTrim(Str(nI))
		Else
			cEspecie := "F2_ESPECI" + AllTrim(Str(nI))
			cVolume  := "F2_VOLUME" + AllTrim(Str(nI))
		Endif
		If !Empty(&cEspecie)
			oReport:Section(1):Cell(cEspecie):Enable()	
			oReport:Section(1):Cell(cVolume):Enable()	
		Else	
			oReport:Section(1):Cell(cEspecie):Disable()	
			oReport:Section(1):Cell(cVolume):Disable()	
		EndIf
	Next

	
	
	oReport:Section(1):PrintLine()

	//oReport:PrintText(STR0036,2500,500)		// eliminar josmar   												// "Data: ___/___/___"
	//oReport:Line(2500,1800,2500,2300)  														// Linha para Assinatura
	//oReport:PrintText(STR0037,2530,1900)													// "CARIMBO E ASSINATURA"
	oReport:EndPage()

	dbSelectArea(cAliasQry)
	dbSKip()
	oReport:IncMeter()
EndDo
oReport:Section(1):Finish()


Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CBMR720R3 ³ Autor ³ Paulo Boschetti      ³ Data ³ 12.05.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Minuta de Despacho                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MATR720(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Edson   M.   ³29/06/98³XXXXXX³Correcao para Argentina.                ³±±
±±³ Edson   M.   ³02/07/98³XXXXXX³Inclusao do Peso Liquido.               ³±±
±±³ Edson   M.   ³30/03/99³XXXXXX³Passar o tamanho na SetPrint.           ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function CBMR720R3()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL CbTxt
LOCAL titulo := OemToAnsi(STR0001)	//"Minuta de Despacho"
LOCAL cDesc1 := OemToAnsi(STR0002)	//"Este relatorio ira emitir a relacao de Recibos"
LOCAL cDesc2 := OemToAnsi(STR0003)	//"de Despacho para as transportadoras."
LOCAL cDesc3 := ""
LOCAL CbCont,cabec1,cabec2,wnrel
LOCAL tamanho:= "P"
LOCAL limite := 80
LOCAL cString:= "SF2"

PRIVATE aReturn := {STR0004, 1,STR0005, 2, 2, 1, "",1 }			//"Zebrado"###"Administracao"
PRIVATE nomeprog:="CBMATR720"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="MTR720"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("MTR720",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        	// Qual Serie De Nota Fiscal ?              ³
//³ mv_par02        	// Da Nota Fiscal ?                         ³ 
//³ mv_par03        	// Ate a Nota Fiscal ?                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:="CBMATR720"            //Nome Default do relatorio em Disco

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey==27
	dbClearFilter()
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	dbClearFilter()
   Return
Endif

RptStatus({|lEnd| CBC720Imp(@lEnd,wnRel,cString)},Titulo)

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C720IMP  ³ Autor ³ Rosane Luciane Chene  ³ Data ³ 09.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR720			                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CBC720Imp(lEnd,WnRel,cString)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL CbTxt
LOCAL titulo := OemToAnsi(STR0001)	//"Minuta de Despacho"
LOCAL CbCont,cabec1,cabec2
LOCAL tamanho:= "P"
LOCAL lContinua := lCab := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do cabecalho e tipo de impressao do relatorio      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo := STR0006		//"RECIBO PARA DESPACHO"
cabec1 := ""
cabec2 := ""

nTipo  := IIF(aReturn[4]=1,15,18)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       :=80
m_pag    :=1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Acesso nota fiscal informada pelo usuario                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SF2")
dbSetOrder(1)
Set SoftSeek On
dbSeek(cFilial+mv_par02+mv_par01)
Set SoftSeek Off

SetRegua(RecCount())		// Total de Elementos da regua

Do While !Eof() .and. F2_FILIAL == cFilial
	ListaMin(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo,cbcont,cbtxt)
	dbSKip()
EndDo

roda(cbcont,cbtxt,tamanho)

dbSelectArea("SF2")
dbClearFilter()
dbSetOrder(1)
Set device to screen

If aReturn[5] = 1
     Set Printer TO 
     dbCommitAll()
     ourspool(wnrel)
Endif

MS_FLUSH()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
STATIC FuncTion ListaMin(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo,cbcont,cbtxt)
LOCAL lImpr:=.T.
Local lNormal := .F.
LOCAL cX := " "
LOCAL I  := 1

If F2_SERIE != mv_par01 .Or. F2_FILIAL != cFilial .Or. F2_DOC < mv_par02 .Or. F2_DOC > mv_par03
	lImpr:=.F.
EndIf


lNormal := !(SF2->F2_TIPO $ "DB")

IncRegua()

If lImpr
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	@ 10,00 psay STR0007+F2_DOC		//"Nota Fiscal : "
	@ 10,51 psay STR0008		//"Valor : "
	@ 10,59 psay (F2_VALMERC+F2_VALIPI+F2_FRETE+F2_SEGURO+F2_ICMSRET)  PICTURE TM((F2_VALMERC+F2_VALIPI+F2_FRETE+F2_SEGURO+F2_ICMSRET),16)

   dbSelectArea( If( lNormal,"SA1","SA2" ) )
  	dbSeek(cFilial+SF2->F2_CLIENTE+SF2->F2_LOJA)

	@ 12,00 psay STR0009+If( lNormal,SA1->A1_NOME,SA2->A2_NOME )			//"Cliente     : "

   If lNormal
	   If empty( SA1->A1_ENDENT )
		   @ 14,00 psay STR0010+SA1->A1_END				//"Endereco    : "
	   Else
		   @ 14,00 psay STR0010+SA1->A1_ENDENT			//"Endereco    : "
	   EndIf
   Else
      @ 14,00 psay STR0010+SA2->A2_END					//"Endereco    : "
   EndIf

	@ 16,00 psay STR0011+If( lNormal,SA1->A1_BAIRRO,SA2->A2_BAIRRO )			//"Bairro      : "
	@ 18,00 psay STR0012+If( lNormal,SA1->A1_MUN,SA2->A2_MUN )					//"Cidade : "
	@ 18,72 psay STR0013+If( lNormal,SA1->A1_EST,SA2->A2_EST )					//"UF : "

	dbSelectArea("SA4")
	dbSeek(cFilial+SF2->F2_TRANSP)

	@ 20,00 psay STR0014+A4_NOME		//"Transportad.: "
	@ 22,00 psay STR0010+A4_END		//"Endereco    : "
	@ 24,00 psay STR0015+ Str(SF2->F2_PBRUTO)		//"Peso Bruto  : "
	@ 26,00 psay STR0020+ Str(SF2->F2_PLIQUI)		//"Peso Liquido : "
	dbSelectArea("SF2")

	Li   := 28
	lCab := .T.

	FOR I:=1 TO 6         //campos novos aqui josmar
		cX := Str(I,1)
		If cX >= '5'
			If !empty(F2_ESPECI&cX)  
				If lCab
					@Li ,15 psay REPLICATE("-",47)
					Li++
					@Li ,15 psay STR0016		//"E S P E C I E"
					@Li ,47 psay STR0017		//"V O L U M E (S)" 
					Li++
					@Li ,15 psay REPLICATE("-",47)
					Li++
					lCab := .F.	
					Li++	
				EndIf 
				@Li ,15 psay F2_ESPECI&cX  
				@Li ,56 psay F2_VOLUME&cX PICTURE "999999"
				Li++
			EndIf		
		Else
			If !empty(F2_ESPECI&cX)  
				If lCab
					@Li ,15 psay REPLICATE("-",47)
					Li++
					@Li ,15 psay STR0016		//"E S P E C I E"
					@Li ,47 psay STR0017		//"V O L U M E (S)" 
					Li++
					@Li ,15 psay REPLICATE("-",47)
					Li++
					lCab := .F.	
					Li++	
				EndIf 
				@Li ,15 psay F2_ESPECI&cX  
				@Li ,56 psay F2_VOLUME&cX PICTURE "999999"
				Li++
			EndIf
	    Endif	
	NEXT I

	//@ 56,00 psay STR0018+SPACE(32)+"----------------------------"			//"Data: ___/___/___"     //eliminar josmar
	//@ 57,53 psay STR0019		//"CARIMBO E ASSINATURA"
EndIf

Return (.T.)

