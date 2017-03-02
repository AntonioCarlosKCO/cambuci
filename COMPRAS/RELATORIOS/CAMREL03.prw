#include "protheus.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"

//___________________________________________________
User Function CAMBR03()

Local _aQuery := {}
Local _cPerg

Public _cPedido := SC7->C7_NUM
Public _wFil    := SC7->C7_FILIAL

Private _lPag    := .T.
Private _cAlias := GetNextAlias()


If alltrim(SM0->M0_CODFIL) == "0101"
	_cPerg := "CAMBR03A"

ElseIf alltrim(SM0->M0_CODFIL) == "0102"
	_cPerg := "CAMBR03B"

ElseIf alltrim(SM0->M0_CODFIL) == "0201"
	_cPerg := "CAMBR03C"

ElseIf alltrim(SM0->M0_CODFIL) == "0202"
	_cPerg := "CAMBR03D"
Endif


CriaSx1(_cPerg)

Pergunte(_cPerg,.t.)

BeginSql Alias _cAlias
	
	column C7_QUANT as numeric(14,2)
	column C7_PRECO as numeric(14,2)
	column C7_TOTAL as numeric(14,2)
	column C7_IPI as numeric(14,2)
	
	%noparser%
	
	SELECT *
	FROM (
	SELECT *
	FROM %Table:SC7%
	WHERE %NotDel%
	AND C7_FILIAL = %Exp:_wFil%
	AND C7_NUM = %Exp:_cPedido%	
	) SC7
	
	LEFT JOIN (
	SELECT A2_COD,
	A2_LOJA,
	A2_NOME,
	A2_END,
	A2_BAIRRO,
	A2_MUN,
	A2_EST,
	A2_CGC,
	A2_DDD,
	A2_TEL,
	A2_EMAIL,
	A2_CONTATO,
	A2_INSCR
	FROM %Table:SA2%
	WHERE %NotDel%
	) SA2
	ON C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA
	
	LEFT JOIN (
	SELECT B1_COD, B1_DESC
	FROM %Table:SB1%
	WHERE %NotDel%
	) SB1
	ON C7_PRODUTO = B1_COD
	
	LEFT JOIN (
	SELECT *
	FROM %Table:SY1%
	WHERE %NotDel%
	) SY1
	ON C7_USER = Y1_USER and substring(C7_FILIAL,1,2) = substring(Y1_FILIAL,1,2)
		
	ORDER BY C7_ITEM
EndSql

_aQuery := GetLastQuery()

dbSelectArea(_cAlias)
dbGotop(_cAlias)


if ! (_cAlias)->(eof())
	
	Processa({||ImpPedCom( SC7->C7_NUM  )}, "Imprimindo Pedido de Compra..")
	
Endif

(_cAlias)->(dbCloseArea())

Return

//___________________________________________________
Static Function ImpPedCom(cPedido)
Local oPrint
Local oDlg
Local i 	     := 1
Local x 	     := 0
Local lin 	     := 0
Local lAdjustToLegacy := .f.
Local lDisableSetup  := .f.

Private nMargem  := 00
Private oFont16N,oFont16,oFont14N,oFont12N,oFont10N,oFont14,oFont12,oFont10,oFont08
Private cTexto   := ""
Private	nValMerc := 0
Private	nValDesc := 0
Private	nValIpi  := 0
Private nValIcm	 := 0
Private	nValSrv  := 0
Private	nValTot  := 0
Private nValSeg  := 0
Private nValDesp := 0
Private nValFrete:= 0
Private _nLinIni := lin
Private _cCond 		:= ""
Private _cTPFrete   := ""


Private _nTotIcm := 0
Private _nTotIpi := 0
Private _nTotSol := 0
Private aImp     := {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

oFont14N	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
oFont14 	:= TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
oFont13		:= TFont():New("Arial",13,13,,.F.,,,,.T.,.F.)
oFont13N	:= TFont():New("Arial",13,13,,.T.,,,,.T.,.F.)
oFont12		:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
oFont12N	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
oFont11		:= TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)
oFont11N	:= TFont():New("Arial",11,11,,.T.,,,,.T.,.F.)
oFont10		:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont10N	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
oFont9		:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
oFont9N		:= TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)

_cPrinter := GETNEWPAR("CB_PRINT01","EPSON L355 Series")
_lServer := .f.
oPrint := FWMSPrinter():New("CAMBR01.rel", IMP_SPOOL, lAdjustToLegacy, , lDisableSetup,,,_cPrinter,_lServer  )

oPrint:SetResolution(72)
oPrint:SetLandScape()
oPrint:SetPaperSize(DMPAPER_A4)
oPrint:SetMargin(50,10,50,50)

// nEsquerda, nSuperior, nDireita, nInferior

oPrint:cPathPDF := "c:\directory\"

// Caso seja utilizada impressão em IMP_PDF

MontaRel(oPrint,@i,.t., cPedido)

Return

//_______________________________________________________________
Static Function MontaRel(oPrint,i,lPreview, cNumPed)

Private lin := 0, lEnt := .F.
Private _nTotal := 0
Public _xFilPed

Public cFig := GetSrvProfString("StartPath","")

dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilAnt)

_xFilPed := ALLTRIM(SM0->M0_CODFIL)

If _xFilPed == "0101" .or. _xFilPed == "0102"
	cFig += "DANFE010101.BMP"
ElseIf _xFilPed == "0201" .or. _xFilPed == "0202"
	cFig += "DANFE010201.BMP"
Endif
cTexto  := ""

nValMerc := 0
nValDesc := 0
nValTot  := 0

Cabecalho(oPrint,@i, cNumPed, cFig)

Detail(oPrint,@i, cNumPed)

xRodape(oPrint,@i, cNumPed)

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
±±
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ARS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
************************************
Static Function Cabecalho(oPrint,i, cNumPed, cFig)
************************************

If !File(cFig)
	__CopyFile(Substr(cFig,1,Len(cFig)-4)+".BKP",Substr(cFig,1,Len(cFig)-4)+".BMP")
Endif

oPrint:StartPage() 		// Inicia uma nova pagina

Set Century On

oPrint:Box( lin+35, 015+nMargem, lin+065, 0240+nMargem, "-4" )
oPrint:SayBitMap(lin+36, 015+nMargem, cFig, 110, 28 )

oPrint:Box( lin+35, 240+nMargem, lin+065, 0780+nMargem, "-4" )
oPrint:Say( lin+45, 420+nMargem,"PEDIDO DE COMPRAS No.: "+cNumPed ,oFont14n)
oPrint:Say( lin+45, 680+nMargem,"Dt.Emissão: "+dtoc(Posicione("SC7",1,_xFilPed+cNumPed,"C7_EMISSAO")),oFont11n)
oPrint:Say( lin+55, 500+nMargem,"Pag : "+strzero(i,2) ,oFont11n)

oPrint:Box( lin+75, 015+nMargem, lin+170, 0420+nMargem, "-4" )
oPrint:Say( lin+090, 180+nMargem,"DADOS CAMBUCI",oFont14n)
oPrint:Say( lin+100, 020+nMargem,"Empresa : "+SM0->M0_NOMECOM ,oFont11N)
oPrint:Say( lin+108, 020+nMargem,"Endereço: "+SM0->M0_ENDENT ,oFont11n)
oPrint:Say( lin+116, 020+nMargem,"CEP : "+SM0->M0_CEPENT+"  Cidade : "+SM0->M0_CIDENT+"  UF : "+SM0->M0_ESTENT ,oFont11n)
oPrint:Say( lin+124, 020+nMargem,"TEL : "+SM0->M0_TEL ,oFont11n)
oPrint:Say( lin+132, 020+nMargem,"CNPJ / CPF : "+SM0->M0_CGC ,oFont11n)
oPrint:Say( lin+140, 020+nMargem,"Comprador : "+(_cAlias)->Y1_NOME ,oFont11n)
oPrint:Say( lin+148, 020+nMargem,"E-mail comprador : "+(_cAlias)->Y1_EMAIL ,oFont11n)
If _xFilPed == "0101" .or. _xFilPed == "0202"
	oPrint:Say( lin+156, 020+nMargem,"E-mail para recebimento nfe : "+GETMV("CB_RECNFE1") ,oFont11n)
ElseIf _xFilPed == "0102" .or. _xFilPed == "0201"
	oPrint:Say( lin+156, 020+nMargem,"E-mail para recebimento nfe : "+GETMV("CB_RECNFE2") ,oFont11n)
Endif
oPrint:Box( lin+75, 420+nMargem, lin+170, 0780+nMargem, "-4" )
oPrint:Say( lin+090, 520+nMargem,"DADOS DO FORNECEDOR",oFont14n)
oPrint:Say( lin+100, 430+nMargem,"Razão Social : "+(_cAlias)->A2_NOME ,oFont11n)
oPrint:Say( lin+108, 430+nMargem,"Codigo : "+(_cAlias)->C7_FORNECE+" - Loja : "+(_cAlias)->C7_LOJA+" - Bairro : "+(_cAlias)->A2_BAIRRO ,oFont11n)
oPrint:Say( lin+116, 430+nMargem,"Endereço : "+(_cAlias)->A2_END ,oFont11n)
oPrint:Say( lin+124, 430+nMargem,"Município : "+alltrim((_cAlias)->A2_MUN),oFont11n)
oPrint:Say( lin+132, 430+nMargem,"CNPJ / CPF : "+(_cAlias)->A2_CGC ,oFont11n)
oPrint:Say( lin+140, 430+nMargem,"Fone : ("+(_cAlias)->A2_DDD+") "+(_cAlias)->A2_TEL ,oFont11n)
oPrint:Say( lin+148, 430+nMargem,+"IE : "+(_cAlias)->A2_INSCR  ,oFont11n)
oPrint:Say( lin+156, 430+nMargem,"Contato : "+(_cAlias)->A2_CONTATO ,oFont11n)
oPrint:Say( lin+164, 430+nMargem,"E-mail contato : "+(_cAlias)->A2_EMAIL ,oFont11n)

oPrint:Box( lin+180, 015+nMargem , lin+195, 060+nMargem, "-4" )  //item
oPrint:Say( lin+190, 020+nMargem,"Item",oFont11)

oPrint:Box( lin+180, 060+nMargem , lin+195, 150+nMargem, "-4" )  //REF.FORN
oPrint:Say( lin+190, 065+nMargem,"Ref.Fornecedor",oFont11)

oPrint:Box( lin+180, 150+nMargem , lin+195, 240+nMargem, "-4" )  //PRODUTO
oPrint:Say( lin+190, 155+nMargem,"Produto",oFont11)

oPrint:Box( lin+180, 240+nMargem , lin+195, 420+nMargem, "-4" )  //DESCRICAO
oPrint:Say( lin+190, 245+nMargem,"Descrição",oFont11)

oPrint:Box( lin+180, 420+nMargem , lin+195, 480+nMargem, "-4" )  //DESCRICAO
oPrint:Say( lin+190, 425+nMargem,"N.C.M.",oFont11)

oPrint:Box( lin+180, 480+nMargem , lin+195, 510+nMargem, "-4" )  //UM
oPrint:Say( lin+190, 485+nMargem,"UM",oFont11)

oPrint:Box( lin+180, 510+nMargem , lin+195, 570+nMargem, "-4" )  //QUANTIDADE
oPrint:Say( lin+190, 515+nMargem,"Quantidade",oFont11)

oPrint:Box( lin+180, 570+nMargem , lin+195, 630+nMargem, "-4" )  //VL. UNIT
oPrint:Say( lin+190, 575+nMargem,"Vl. Unit.",oFont11)

oPrint:Box( lin+180, 630+nMargem , lin+195, 690+nMargem, "-4" )  //VALOR TOTAL
oPrint:Say( lin+190, 635+nMargem,"Valor Total",oFont11)


oPrint:Box( lin+180, 690+nMargem , lin+195, 780+nMargem, "-4" )  //ALIQ IPI
oPrint:Say( lin+190, 695+nMargem,"Aliq. IPI",oFont11)

_nLinIni := lin + 195

lin := lin + 205

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

ItensPed(oPrint,@i, cNumPed) // Imprime os Itens do Pedido de vendas
DadosGer(oPrint,@i) // Imprime dados das Condicoes Gerais


Return lin



//__________________________________
Static Function ItensPed(oPrint,i, cNumPed)

Local nValorUni := 0
Local nValorTot := 0
Local nQtde		:= 0
Local nVlTot	:= 0
Local _nTotIcm := 0
Local _nTotIpi := 0
Local _nTotSol := 0
Local nValDesc := 0
Local _nLimite := 545
Local _nLinFim := lin
Local _aPrtdet := {}

Public	nValIpi  := 0

DbSelectArea(_cAlias)
(_cAlias)->(DbGotop())

_cCond		:= (_cAlias)->C7_COND
_cTpFrete	:= (_cAlias)->C7_TPFRETE

While ! (_cAlias)->(EOF())
	
	SC7->(Dbseek(xFilial("SC7")+(_cAlias)->C7_NUM+(_cAlias)->C7_ITEM))
	SF4->(Dbseek(xFilial("SF4")+SC7->C7_TES))
	
	_cTipoCli := Posicione("SA1",1,xFilial("SA1")+SC7->C7_FORNECE+SC7->C7_LOJA,"A1_TIPO")
	
	nItens++
	
	If lin > _nLimite
		
		CorpoDet(oPrint, _nLinIni, lin, @_aPrtDet)
		
		i++
		
		oPrint:EndPage() 		// Finaliza a pagina
		
		Lin:= 0
		Cabeca1(oPrint,i, cNumPed, cFig)
		
	Endif
	
	SB1->(Dbseek(xFilial("SB1")+(_cAlias)->C7_PRODUTO))
	
	nValDesc += SC7->C7_VLDESC
	
	aadd(_aPrtDet, {  lin		, 020+nMargem,(_cAlias)->C7_ITEM,oFont11 } )
	aadd(_aPrtDet, {lin		, 065+nMargem,(_cAlias)->C7_XCODFOR,oFont11  })
	aadd(_aPrtDet, {lin		, 155+nMargem,SB1->B1_COD,oFont11  })
	aadd(_aPrtDet, { lin		, 245+nMargem,alltrim(substr(SB1->B1_DESC,1,38)),oFont11  })
	aadd(_aPrtDet, { lin		, 425+nMargem,SB1->B1_POSIPI,oFont11 })
	aadd(_aPrtDet, {lin		, 485+nMargem,(_cAlias)->C7_UM,oFont11  })
	aadd(_aPrtDet, {lin		, 515+nMargem,Transform(INT((_cAlias)->C7_QUANT),"@E 999,999"),oFont11  })
	aadd(_aPrtDet, { lin		, 575+nMargem,Transform((_cAlias)->C7_PRECO,"@E 99,999.9999"),oFont11  })
	aadd(_aPrtDet, { lin		, 625+nMargem,Transform((_cAlias)->C7_TOTAL,"@E 999,999,999.9999"),oFont11 })
	aadd(_aPrtDet, {lin		, 695+nMargem,Transform((_cAlias)->C7_IPI,"@E 999.999"),oFont11  })
	
	nValMerc 	+= (_cAlias)->C7_TOTAL
	nValIPI		+= (_cAlias)->C7_VALIPI
	nvalICM		+= (_cAlias)->C7_VALICM
	
	nValDesp	+= 	(_cAlias)->C7_DESPESA
	nValSeg		+=	(_cAlias)->C7_SEGURO
	nValFrete	+=	(_cAlias)->C7_VALFRE
	
	lin += 08
	(_cAlias)->(Dbskip())
	
Enddo
(_cAlias)->(dbSkip(-1))


If lin > _nLimite
	
	CorpoDet(oPrint, _nLinIni, lin, @_aPrtDet)
	
	i++
	
	oPrint:EndPage() 		// Finaliza a pagina
	Lin:= 165
	Cabeca1(oPrint,@i, cNumPed,cFig)
	CorpoDet(oPrint, _nLinIni, 350, _aPrtDet)
Else
	
	CorpoDet(oPrint, _nLinIni, 350, _aPrtDet)
	_aPrtDet := {}
	
Endif

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄü¿
//³Impressao dos dados do cliente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄüÙ


//_____________________________________________

Static Function DadosGer(oPrint,i)
Local _cCondPag := ""
Local _cTipoFrete := ""

nValTot := nValMerc + nValIpi + nValSrv
nValTot += nValDesp+nValSeg+nValFrete

lin := 0

oPrint:Box( lin+350, 015+nMargem , lin+390, 780+nMargem, "-4" )  //local entrega e cobrança
oPrint:Box( lin+390, 015+nMargem , lin+410, 420+nMargem, "-4" )  // observações

//oBrush1 := TBrush():New( , CLR_YELLOW)
//oPrint:Fillrect( {lin+371, 016+nMargem, lin+389, 419+nMargem }, oBrush1, "-2")

oPrint:Box( lin+390, 420+nMargem , lin+410, 630+nMargem, "-4" )  //Valor Mercadoria
oPrint:Box( lin+390, 630+nMargem , lin+410, 780+nMargem, "-4" )  //IPI / ICMS
oPrint:Box( lin+410, 015+nMargem , lin+435, 420+nMargem, "-4" )  //Condiçaõ de pagamento
oPrint:Box( lin+410, 420+nMargem , lin+435, 630+nMargem, "-4" )  //Total Pedido
oPrint:Box( lin+410, 630+nMargem , lin+435, 780+nMargem, "-4" )  //Valor de Desconto


oPrint:Say(lin+360,020+nMargem,"Local Entrega: ",oFont11N)
oPrint:Say(lin+380,020+nMargem,"Local Cobrança: ",oFont11N)

If alltrim(SM0->M0_CODFIL) == "0101" .or. alltrim(SM0->M0_CODFIL) == "0202"
	oPrint:Say(lin+360,090+nMargem,GETMV(ALLTRIM("CB_LOCENTA")),oFont11N)
ElseIf ALLTRIM(SM0->M0_CODFIL) == "0102" .or. ALLTRIM(SM0->M0_CODFIL) == "0201"
	oPrint:Say(lin+360,090+nMargem,GETMV(ALLTRIM("CB_LOCENTB")),oFont11N)
Endif

oPrint:Say(lin+380,090+nMargem,GETMV(ALLTRIM("CB_LOCCOBA")),oFont11N)

oPrint:Say(lin+400,020+nMargem,"Observações: ",oFont11N)
oPrint:Say(lin+400,090+nMargem,(_cAlias)->C7_OBS,oFont11N)

oPrint:Say(lin+398,470+nMargem,"Valor Mercadoria :",oFont11N)
oPrint:Say(lin+408,475+nMargem,Transform(nValMerc,"@E 999,999,999.99"),oFont11N)

//Total IPI
oPrint:Say(lin+398,660+nMargem,"Valor do IPI R$ "+Transform(nValIPI,"@E 999,999,999.99"),oFont10N)
oPrint:Say(lin+408,660+nMargem,"Valor do ICMS R$ "+Transform(nValICM,"@E 999,999,999.99"),oFont10N)

//Cond pag
_cCondPag := GETADVFVAL("SE4","E4_DESCRI", xfilial("SE4")+_cCond,1,"")

if _cTpFrete =="C"
	_cTipoFrete := "CIF"
Elseif 	_cTpFrete =="F"
	_cTipoFrete := "FOB"
Elseif 	_cTpFrete =="T"
	_cTipoFrete := "Por Conta Terceiros"
Elseif 	_cTpFrete =="S"
	_cTipoFrete := "Sem Frete"
Endif

oPrint:Say(lin+420,120+nMargem,"Condição de Pagto : "+_cCondPag,oFont11N)
oPrint:Say(lin+430,120+nMargem,"Tipo do Frete: "+_cTipoFrete,oFont11N)

//Total Pedido
oPrint:Say(lin+420,470+nMargem,"Total Pedido :",oFont11N)
oPrint:Say(lin+430,475+nMargem,Transform( nValTot ,"@E 999,999,999.99"),oFont11N)

//Valor Total Desconto
oPrint:Say(lin+420,640+nMargem,"Valor total de Desconto :",oFont10N)
oPrint:Say(lin+430,640+nMargem,Transform( nValDesc ,"@E 999,999,999.99"),oFont11N)

oPrint:Box( lin+435, 015+nMargem , lin+480, 780+nMargem, "-4" )  //Valor de Desconto


oPrint:Line( lin+460, 015+nMargem, lin+460, 200+nMargem, , "-5" )
oPrint:Line( lin+460, 600+nMargem, lin+460, 780+nMargem, , "-5")

oPrint:Say(lin+470,075+nMargem,"COMPRADOR",oFont14N)
oPrint:Say(lin+470,640+nMargem,"Autorização do Gerente",oFont14N)


Return



// Função Rodape
//_______________________________________________

Static Function xRodape(oPrint,i,cNumPed)
Local _nx
Local _cSeparadores := ",.;:/|- "
Local _aFormulas := {}
Local _cFormulas := alltrim(MV_PAR01)

//CONVERTE STRING DE FORMULAS EM VETOR
_cIni := 1
For _nx := 1 to len(_cFormulas)
	if substr(_cFormulas,_nx,1) $ _cSeparadores
		aadd(_aFormulas, substr(_cFormulas,_cIni,_nx-1) )
		_cIni := _nx + 1
	Endif
Next

//if len(_aFormulas) > 0
//	aadd(_aFormulas, _cFormulas)
//Endif
//_________________________________________________________________

//IMPRIME FORMULAS
For _nx := 1 to len(_aFormulas)
	If _nx <=6
		_cMsg := Formula(_aFormulas[_nx])
		oPrint:Box( lin+480 , 015+nMargem , lin+495, 780+nMargem, "-4" )
		oPrint:Say(lin+492,020+nMargem,_cMsg,oFont11)
		lin += 15
	else
		IF lin > 75
			If _nx > 6
				i++
				oPrint:EndPage() 		// Finaliza a pagina
				Lin:=0
				dbSelectArea(_cAlias)
				dbGotop(_cAlias)
				Cabeca1(oPrint,@i, cNumPed,cFig)
				Lin :=60 //65
				For _ny := 7 to len(_aFormulas)
					_cMsg := Formula(_aFormulas[_ny])
					oPrint:Box( lin+15 , 015+nMargem , lin+30, 780+nMargem, "-4" )
					oPrint:Say( lin+27,020+nMargem,_cMsg,oFont11)
					lin += 15
				next
			Endif
			exit
		Endif
	Endif
Next

Return

// Calcula impostos por item
//___________________________________________________
Static Function fCalcImp(cCliente,cLoja,cTipo,cProduto,cTes,nQtd,nPrc,nValor)

aImp := {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

// -------------------------------------------------------------------
// Realiza os calculos necessários
// -------------------------------------------------------------------
MaFisIni(cCliente,;                             // 1-Codigo Cliente/Fornecedor
cLoja,;                                // 2-Loja do Cliente/Fornecedor
"F",;                                  // 3-C:Cliente , F:Fornecedor
"N",;                                  // 4-Tipo da NF
cTipo,;                                // 5-Tipo do Cliente/Fornecedor
MaFisRelImp("MTR700",{"SC7"}),;  // 6-Relacao de Impostos que suportados no arquivo
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


******************************************************
Static Function CorpoDet(oPrint, lini, lfim, _aPrtDet)
******************************************************

oPrint:Box( lini, 015+nMargem , lfim, 060+nMargem, "-4" )  //item
oPrint:Box( lini, 060+nMargem , lfim, 150+nMargem, "-4" )  //REF.FORN
oPrint:Box( lini, 150+nMargem , lfim, 240+nMargem, "-4" )  //PRODUTO
oPrint:Box( lini, 240+nMargem , lfim, 420+nMargem, "-4" )  //DESCRICAO
oPrint:Box( lini, 420+nMargem , lfim, 480+nMargem, "-4" )  //DESCRICAO
oPrint:Box( lini, 480+nMargem , lfim, 510+nMargem, "-4" )  //UM
oPrint:Box( lini, 510+nMargem , lfim, 570+nMargem, "-4" )  //QUANTIDADE
oPrint:Box( lini, 570+nMargem , lfim, 630+nMargem, "-4" )  //VL. UNIT
oPrint:Box( lini, 630+nMargem , lfim, 690+nMargem, "-4" )  //VALOR TOTAL
oPrint:Box( lini, 690+nMargem , lfim, 780+nMargem, "-4" )  //ALIQ IPI

For _nx := 1 to len(_aPrtDet)
	
	oPrint:Say( _aPrtDet[_nx][1] , _aPrtDet[_nx][2], _aPrtDet[_nx][3] ,_aPrtDet[_nx][4])
	
Next
_aPrtDet := {}
Return


/*
ROTINA..................:CriaSX1
OBJETIVO................:Criar registros no arquivo de perguntas SX1
*/
Static Function CriaSX1(_cPerg)

Local _ABrea := GetArea()
Local _aRegs := {}


_sAlias := Alias()
dbSelectArea("SX1")
SX1->(dbSetOrder(1))
_cPerg := padr(_cPerg,len(SX1->X1_GRUPO))

If _cPerg == "CAMBR03A"
	Aadd(_aRegs,{_cPerg,"01","Formulas p/ Obs: Filial 0101 ?","mv_ch1","C",60,0,"C","mv_par01","","","","","",""})
ElseIf _cPerg == "CAMBR03B"
	Aadd(_aRegs,{_cPerg,"01","Formulas p/ Obs: Filial 0102 ?","mv_ch1","C",60,0,"C","mv_par01","","","","","",""})
ElseIf _cPerg == "CAMBR03C"
	Aadd(_aRegs,{_cPerg,"01","Formulas p/ Obs: Filial 0201 ?","mv_ch1","C",60,0,"C","mv_par01","","","","","",""})
ElseIf _cPerg == "CAMBR03D"
	Aadd(_aRegs,{_cPerg,"01","Formulas p/ Obs: Filial 0202 ?","mv_ch1","C",60,0,"C","mv_par01","","","","","",""})
Endif

DbSelectArea("SX1")
SX1->(DbSetOrder(1))

For i := 1 To Len(_aRegs)
	IF  !DbSeek(_aRegs[i,1]+_aRegs[i,2])
		RecLock("SX1",.T.)
		Replace X1_GRUPO   with _aRegs[i,01]
		Replace X1_ORDEM   with _aRegs[i,02]
		
		Replace X1_PERGUNT with _aRegs[i,03]
		Replace X1_PERSPA  with _aRegs[i,03]
		Replace X1_PERENG  with _aRegs[i,03]
		
		Replace X1_VARIAVL 	with _aRegs[i,04]
		Replace X1_TIPO     with _aRegs[i,05]
		Replace X1_TAMANHO 	with _aRegs[i,06]
		Replace X1_DECIMAL  with _aRegs[i,07]
		Replace X1_GSC    	with _aRegs[i,08]
		Replace X1_VAR01   	with _aRegs[i,09]
		Replace X1_F3     	with _aRegs[i,10]
		Replace X1_DEF01   	with _aRegs[i,11]
		Replace X1_DEF02   	with _aRegs[i,12]
		Replace X1_DEF03   	with _aRegs[i,13]
		Replace X1_DEF04   	with _aRegs[i,14]
		Replace X1_DEF05   	with _aRegs[i,15]
		MsUnlock()
	EndIF
Next i

RestArea(_ABrea)

Return


************************************************
Static Function Cabeca1(oPrint,i, cNumPed, cFig)
************************************************

oPrint:StartPage() 		// Inicia uma nova pagina

dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilAnt)

Set Century On

oPrint:Box( lin+35, 015+nMargem, lin+065, 0240+nMargem, "-4" )
oPrint:SayBitMap(lin+36, 015+nMargem, cFig, 110, 28 )

oPrint:Box( lin+35, 240+nMargem, lin+065, 0780+nMargem, "-4" )
oPrint:Say( lin+45, 420+nMargem,"PEDIDO DE COMPRAS No.: "+cNumPed ,oFont14n)
oPrint:Say( lin+45, 680+nMargem,"Dt.Emissão: "+dtoc(Posicione("SC7",1,_xFilPed+cNumPed,"C7_EMISSAO")),oFont11n)
oPrint:Say( lin+55, 500+nMargem,"Pag : "+strzero(i,2) ,oFont11n)

oPrint:Box( lin+75, 015+nMargem , lin+90, 060+nMargem, "-4" )  //item
oPrint:Say( lin+85, 020+nMargem,"Item",oFont11)

oPrint:Box( lin+75, 060+nMargem , lin+90, 150+nMargem, "-4" )  //REF.FORN
oPrint:Say( lin+85, 065+nMargem,"Ref.Fornecedor",oFont11)

oPrint:Box( lin+75, 150+nMargem , lin+90, 240+nMargem, "-4" )  //PRODUTO
oPrint:Say( lin+85, 155+nMargem,"Produto",oFont11)

oPrint:Box( lin+75, 240+nMargem , lin+90, 420+nMargem, "-4" )  //DESCRICAO
oPrint:Say( lin+85, 245+nMargem,"Descrição",oFont11)

oPrint:Box( lin+75, 420+nMargem , lin+90, 480+nMargem, "-4" )  //DESCRICAO
oPrint:Say( lin+85, 425+nMargem,"N.C.M.",oFont11)

oPrint:Box( lin+75, 480+nMargem , lin+90, 510+nMargem, "-4" )  //UM
oPrint:Say( lin+85, 485+nMargem,"UM",oFont11)

oPrint:Box( lin+75, 510+nMargem , lin+90, 570+nMargem, "-4" )  //QUANTIDADE
oPrint:Say( lin+85, 515+nMargem,"Quantidade",oFont11)

oPrint:Box( lin+75, 570+nMargem , lin+90, 630+nMargem, "-4" )  //VL. UNIT
oPrint:Say( lin+85, 575+nMargem,"Vl. Unit.",oFont11)

oPrint:Box( lin+75, 630+nMargem , lin+90, 690+nMargem, "-4" )  //VALOR TOTAL
oPrint:Say( lin+85, 635+nMargem,"Valor Total",oFont11)


oPrint:Box( lin+75, 690+nMargem , lin+90, 780+nMargem, "-4" )  //ALIQ IPI
oPrint:Say( lin+85, 695+nMargem,"Aliq. IPI",oFont11)

_nLinIni := lin + 90

lin := lin + 100

Set century Off

Return Nil

