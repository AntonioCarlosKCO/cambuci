#include "rwmake.ch"
#include "topconn.ch"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ConsEst    ³ Autor ³ Walter C Silva(GLOBAL) Data ³26.08.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria uma tela de consulta com os saldos atuais de todas as   ³±±
±±³          ³empresas e seus respectivos codigos similares.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array (aViewB2) contendo todos os dados do SB2 para todas as ³±±
±±³          ³empresas. Traz tambem os codigos similares do produto com    ³±±
±±³          ³seus respectivos saldos.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MP8 - Especifico Fertgeo                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ConsEst()

Private _aARea:=GetArea()
Private oCursor	:= LoadBitMap(GetResources(),"LBNO")
Private nX        := 0
Private cQuery    := ""
Private _cNomeEmp := ""
Private _cCodEmp  := ""
Private aStruSB2  := {}

Private cProduto 	:= Space(TamSx3('B1_COD')[1] )                          
Private cCodProd 	:= Space(TamSx3('B1_COD')[1] )                          
Private cDescricao	:= Space(TamSx3('B1_DESC')[1] )                          
Private cReferencia	:= Space(20)  //Space(TamSx3('ZZA_COD')[1] )                          
Private cNCM	    := Space(TamSx3('B1_POSIPI')[1] )                          
Private cCodFor	    := Space(TamSx3('A5_CODPRF')[1] )                          
Private cTipo	    := Space(TamSx3('B1_TIPO')[1] )                          
Private cUnidade	:= Space(TamSx3('B1_UM')[1] )                          
Private cMarca		:= Space(TamSx3('ZZB_XDESMC')[1] ) 
Private cSubGrupo	:= Space(TamSx3('ZZD_XDESSG')[1] )
Private cLinha		:= Space(TamSx3('ZZC_XDESLN')[1] )


Private nIPI	    := 0                          
Private nTotDisp	:= 0
Private nSaldo	:= 0
Private nQtPV		:= 0
Private nQemp		:= 0
Private nSalpedi	:= 0
Private nReserva	:= 0
PrivAte nQempSA	:= 0
PrivAte nQTNP	:= 0
PrivAte nQNPT	:= 0
PrivAte nQTER	:= 0
PrivAte nQACLASS:= 0
PrivAte nQNAOCLAS:= 0

Private aViewB2	:= {}
			aAdd(aViewB2,{'',;
			'',;
			TransForm('',PesqPict("SB2","B2_LOCAL")),;
			TransForm('',PesqPict("SB2","B2_LOCALIZ")),;
			TransForm(0,PesqPict("SB2","B2_QATU")),;
			TransForm(0,PesqPict("SB2","B2_QATU")),;
			TransForm(0,PesqPict("SB2","B2_QEMP")),;
			TransForm(0,PesqPict("SB2","B2_RESERVA")),;
			TransForm(0,PesqPict("DA1","DA1_PRCVEN")),;
			TransForm(0,PesqPict("DA1","DA1_PRCVEN")),;
			TransForm(0,PesqPict("SB1","B1_UPRC")),;
			TransForm(0,PesqPict("SB1","B1_UPRC")),;
			TransForm(0,PesqPict("SB1","B1_UPRC")),;
			TransForm(0,PesqPict("SB1","B1_UPRC")),;
			TransForm(0,PesqPict("SB2","B2_QPEDVEN")),;
			TransForm(0,PesqPict("SB2","B2_SALPEDI")),;
			TransForm(0,PesqPict("SB2","B2_QEMPSA")),;
			TransForm(0,PesqPict("SB2","B2_QTNP")),;
			TransForm(0,PesqPict("SB2","B2_QNPT")),;
			TransForm(0,PesqPict("SB2","B2_QTER")),;
			TransForm(0,PesqPict("SB2","B2_QACLASS")),;
			TransForm(0,PesqPict("SB2","B2_NAOCLAS"))})

Private cPerg:='CONSEST'
AjustaSX1(cPerg)
If !Pergunte(cPerg,.T.)
   Return
End   
	
			@ 000,000 To 500,900 DIALOG oDlg TITLE "Saldos em Estoque"
			@ 023,004 To 23,445 Title "" Object oGrp
			@ 113,004 To 113,445 Title "" Object oGrp
			
//			oListBox := TWBrowse():New( 80,4,445,69,,{"Filial","Nome","Armazém","Endereço" ,"Sld.Atual","Qtd.Disponivel","Qtd. Empenhada","Qtd. Reservada","Preço Venda","Preço Promocional","Preço Compra","Qtd. Giro Medio","Qtd. Vendida", "Qtd. Comprada","Qtd.Pedido de Vendas","Qtd. Prevista Entrada","Qtd.Empenhada S.A.","Qtd. Terc. em Nosso Poder","Qtd. Nosso em Poder Terc.","Saldo Poder 3.","Quantidade a Endereçar","Quantidade nao Enderecada"},{30,100,30,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60},oDlg,,,,,{||MSGBOX("TESTE"+Str(oListBox:nAT))},,,,,,,.F.,,.T.,,.F.,,,) 
			oListBox := TWBrowse():New( 80,4,445,69,,{"Filial","Nome","Armazém","Descrição","Sld.Atual","Qtd.Disponivel","Qtd. Empenhada","Qtd. Reservada","Preço Venda","Preço Promocional","Preço Compra","Qtd. Giro Medio","Qtd. Vendida", "Qtd. Comprada","Qtd.Pedido de Vendas","Qtd. Prevista Entrada","Qtd.Empenhada S.A.","Qtd. Terc. em Nosso Poder","Qtd. Nosso em Poder Terc.","Saldo Poder 3.","Quantidade a Endereçar","Quantidade nao Enderecada"},{30,100,30,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60},oDlg,,,,,{||MSGBOX("TESTE"+Str(oListBox:nAT))},,,,,,,.F.,,.T.,,.F.,,,)
			oListBox:SetArray(aViewB2)
			oListBox:bLine := { || aViewB2[oListBox:nAT]}
			@ 004,010 SAY "Pesquisa:" SIZE 30,9 Object oSay  
			@ 004,040 GET cProduto PICTURE PesqPict("SB1","B1_COD") VALID BuscaProd(cProduto) F3 'SB1' SIZE 50,009 Object oProduto

			@ 004,120 SAY "Produto:" SIZE 30,9 Object oSay  
			@ 004,160 GET cCodProd PICTURE PesqPict("SB1","B1_COD") WHEN .F. SIZE 50,009 Object oCodProd

			@ 004,230 SAY "Descrição:" SIZE 30,9 Object oSay  
			@ 004,270 GET cDescricao PICTURE PesqPict("SB1","B1_DESC") SIZE 150,9 WHEN .F. Object oDescricao  

			@ 019,010 SAY "Referência:" SIZE 30,9 Object oSay  
			@ 019,040 GET cReferencia SIZE 50,9 WHEN .F. Object oReferencia  

			@ 019,120 SAY "Cod Fornecedor:" SIZE 50,9 Object oSay  
			@ 019,160 GET cCodFor PICTURE PesqPict("SA5","A5_CODPRF")  SIZE 50,9 WHEN .F. Object oCodFor  

			@ 034,010 SAY "% IPI:" SIZE 30,9 Object oSay  
			@ 034,040 GET nIPI PICTURE PesqPict("SB1","B1_IPI") SIZE 50,9 WHEN .F. Object oIPI  

			@ 034,120 SAY "NCM:" SIZE 30,9 Object oSay  
			@ 034,160 GET cNCM PICTURE PesqPict("SB1","B1_POSIPI") SIZE 50,9 WHEN .F. Object oNCM  

			@ 034,230 SAY "Tipo:" SIZE 30,9 Object oSay  
			@ 034,270 GET cTipo PICTURE PesqPict("SB1","B1_TIPO") SIZE 50,9 WHEN .F. Object oTipo  

			@ 034,330 SAY "Unidade:" SIZE 30,9 Object oSay  
			@ 034,370 GET cUnidade PICTURE PesqPict("SAH","AH_UMRES") SIZE 50,9 WHEN .F. Object oUnidade 

			@ 049,010 SAY "Marca:" SIZE 30,9 Object oSay  
			@ 049,040 GET cMarca PICTURE PesqPict("ZZB","ZZB_XDESMC") SIZE 50,9 WHEN .F. Object oMarca  

			@ 049,120 SAY "Sub-Grupo:" SIZE 30,9 Object oSay  
			@ 049,160 GET cSubGrupo PICTURE PesqPict("ZZD",'ZZD_XDESSG') SIZE 50,9 WHEN .F. Object oSubGrupo  

			@ 049,230 SAY "Linha:" SIZE 30,9 Object oSay  
			@ 049,270 GET cLinha PICTURE PesqPict("ZZC",'ZZC_XDESLN') SIZE 150,9 WHEN .F. Object oLinha  

			@ 154,010 SAY "TOTAL " SIZE 30 ,9 Object oSay  //"TOTAL "

			@ 170,007 SAY "Saldo Atual   " Object oSay //"Saldo Atual   "
			@ 169,075 Get nSaldo Picture PesqPict("SB2","B2_QATU") SIZE 070,009 When .F. Object oSaldo
			@ 185,007 SAY "Quantidade Disponivel    " Object oSay //"Quantidade Disponivel    "
			@ 184,075 Get nTotDisp Picture PesqPict("SB2","B2_QATU") SIZE 070,009 When .F. Object oTotDisp
			@ 200,007 SAY "Quantidade Empenhada " Object oSay //"Quantidade Empenhada "
			@ 199,075 Get nQemp Picture PesqPict("SB2","B2_QEMP") SIZE 070,009 When .F. Object oQemp
			@ 215,007 SAY "Qtd. Reservada  " Object oSay //"Qtd. Reservada  "
			@ 214,075 Get nReserva Picture PesqPict("SB2","B2_RESERVA") SIZE 070,009 When .F. Object oReserva


			@ 170,155 SAY "Qtd. Pedido de Vendas  " Object oSay //"Qtd. Pedido de Vendas  "
			@ 169,223 Get nQtPv Picture PesqPict("SB2","B2_QPEDVEN") SIZE 070,009 When .F. Object oQtPv
			@ 185,155 SAY "Qtd. Prevista Entrada" Object oSay //"Qtd. Entrada Prevista"
			@ 184,223 Get nSalPedi Picture PesqPict("SB2","B2_SALPEDI") SIZE 070,009 When .F. Object oSalPedi
			@ 200,155 SAY "Qtd. Empenhada S.A."Object oSay //"Qtd. Empenhada S.A."
			@ 199,223 Get nQEmpSA Picture PesqPict("SB2","B2_QEMPSA") SIZE 070,009 When .F. Object oQEmpSA
			@ 215,155 SAY "Qtd. Terc. em Nosso Poder"Object oSay 
			@ 214,223 Get nQTNP Picture PesqPict("SB2","B2_QTNP") SIZE 070,009 When .F. Object oQTNP


			@ 170,303 SAY "Qtd. Nosso em Poder Terc." Object oSay 
			@ 169,376 Get nQNPT Picture PesqPict("SB2","B2_QNPT") SIZE 070,009 When .F. Object oQNPT
			@ 185,303 SAY "Saldo Poder 3." Object oSay 
			@ 184,376 Get nQTER Picture PesqPict("SB2","B2_QTER") SIZE 070,009 When .F. Object oQTER
			@ 200,303 SAY "Quantidade a Enderecar" Object oSay 
			@ 199,376 Get nQACLASS Picture PesqPict("SB2","B2_QACLASS") SIZE 070,009 When .F. Object oQACLASS
			@ 215,303 SAY "Quantidade nao Enderecada" Object oSay 
			@ 214,376 Get nQNAOCLAS Picture PesqPict("SB2","B2_NAOCLAS") SIZE 070,009 When .F. Object oQNAOCLAS
			
			
			@ 232,184 BUTTON "Parâmetros" SIZE 045,012 ACTION MudaPar() Object oBnt //"Voltar"
			@ 232,244 BUTTON "Voltar" SIZE 045,012 ACTION oDlg:End() Object oBnt //"Voltar"
			
			ACTIVATE DIALOG oDlg CENTERED


RestArea(_aArea)

Return




Static Function BuscaProd(cProduto)

_cCodTab:=mv_par01                         
_cCodTab2:=mv_par02                       
_nMeses:=mv_par03       
cQuery    := ""
	
	cCodProd	:=Alltrim(Posicione("SB1",1,xFilial('SB1')+cProduto,'B1_COD'))
	cReferencia	:=Alltrim(Posicione("ZZA",2,xFilial('ZZA')+cProduto,'ZZA_XCODRF'))
    cCodFor		:=Alltrim(Posicione("SA5",5,xFilial('SA5')+cProduto,'A5_CODPRF'))

    If Empty(cCodProd) .AND. Empty(cReferencia) .AND. Empty(cCodFor)
		Aviso("Atencao","A informação Pesquisada não existe nos Códigos de Produtos, Referência ou Fornecedor.",{"Voltar"},2) //"Atencao"###"Nao registro de estoques para este produto."###"Voltar"
		IniciaVar()		
        Return                  
    Else
       If !Empty(cReferencia)
          cCodProd:=ZZA->ZZA_XCOD
       ElseIf !Empty(cCodFor)
          cCodProd:=SA5->A5_PRODUTO
       End   
            
 	EndIf

	cCursor   := "MAVIEWSB2"
	lQuery    := .T.
	aStruSB2  := SB2->(dbStruct())
	aSize(aViewB2,0)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre arquivo de empresas para obter empresas para consulta do estoque  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SM0")
	DbSetOrder(1)
	DbGoTop()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta cQuery para realizar select no SB2 de todas as Empresas e Filiais ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotDisp	:= 0
	nSaldo	:= 0
	nQtPV		:= 0
	nQemp		:= 0
	nSalpedi	:= 0
	nReserva	:= 0
	nQempSA	:= 0
	nQTNP	:= 0
	nQNPT	:= 0
	nQTER	:= 0
	nQACLASS:= 0
	nQNAOCLAS:= 0

	While !Eof()
		
//		_cNomeEmp := Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL)
//		_cCodEmp  := SM0->(M0_CODIGO+M0_CODFIL)

		_cNomeEmp := Alltrim(SM0->M0_FILIAL)
		_cCodEmp  := SM0->M0_CODFIL
		
		cQuery += "SELECT '"+_cNomeEmp+"' as NOMEFIL, '"+_cCodEmp+"' as CODFIL, *, "
                   
        //Incluindo Somatoria de Quantidade Vendida
		cQuery += "(SELECT SUM(D2_QUANT)  " 
		cQuery += "FROM SD2"+SM0->M0_CODIGO+"0 AWHERE "
		cQuery += "D_E_L_E_T_ <> '*' AND D2_FILIAL = B2_FILIAL AND D2_COD = B2_COD AND D2_LOCAL = B2_LOCAL "
		cQuery += "		GROUP BY D2_COD,D2_LOCAL) AS VENDAS,  "

        //Incluindo Somatoria de Quantidade Comprada
		cQuery += "(SELECT SUM(D1_QUANT)  " 
		cQuery += "FROM SD1"+SM0->M0_CODIGO+"0 AWHERE "
		cQuery += "D_E_L_E_T_ <> '*' AND D1_FILIAL = B2_FILIAL AND D1_COD = B2_COD AND D1_LOCAL = B2_LOCAL "
		cQuery += "		GROUP BY D1_COD,D1_LOCAL) AS COMPRAS  "

		cQuery += "FROM SB2"+SM0->M0_CODIGO+"0 WHERE "
		cQuery += "B2_FILIAL = '"+SM0->M0_CODFIL+"' AND "
		
		cQuery += "B2_COD in ('"+cCodProd+"','"+cReferencia+"','"+cCodFor+"') AND "
		cQuery += "D_E_L_E_T_ = '' "
		
		DbSkip()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acrescenta clausula "Union" para juntar todas as select's.              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Eof()
			cQuery += "UNION "
		Else
			cQuery += "ORDER BY B2_COD, CODFIL, B2_LOCAL"
		EndIf
		
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida Query a ser executada.                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := ChangeQuery(cQuery)
    Memowrite('consest.sql',cQuery)
	
	SB2->(dbCommit())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Alias temporario com o resultado da Query.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursor,.T.,.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajusta os campos que nao sao Caracter de acordo com a estrutura do SB2  ³
	//³ uma vez que a TcGenQuery retorna todos os campos como Caracter.         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aStruSB2)
		If aStruSB2[nX][2]<>"C"
			TcSetField(cCursor,aStruSB2[nX][1],aStruSB2[nX][2],aStruSB2[nX][3],aStruSB2[nX][4])
		EndIf
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia montagem do array (aViewB2) para visualizacao no Browse e        ³
	//³ posterior retorno da funcao.                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cNomeEmp  := ""
	_cNomeEmpA := ""
	
	_cCodEmp   := ""
	_cCodEmpA  := ""
	
	_cCodPro   := ""
	_cCodProA  := ""

	DbSelectArea(cCursor)
	DbGoTop()
	While ( !Eof() )
		
		_cNomeEmp := Alltrim((cCursor)->NOMEFIL)
		_cCodEmp  := Alltrim((cCursor)->CODFIL)
		_cNomeEmpA := Alltrim((cCursor)->NOMEFIL)
		_cCodEmpA  := Alltrim((cCursor)->CODFIL)
		
		_cCodPro := Alltrim((cCursor)->B2_COD)
		_cCodProA    := Alltrim((cCursor)->B2_COD)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicia montagem do Array.                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd(aViewB2,{_cCodEmp,;
			_cNomeEmp,;
			TransForm((cCursor)->B2_LOCAL,PesqPict("SB2","B2_LOCAL")),;
			TransForm((cCursor)->B2_LOCALIZ,PesqPict("SB2","B2_LOCALIZ")),;
			TransForm((cCursor)->B2_QATU,PesqPict("SB2","B2_QATU")),;
			TransForm(SaldoSB2(,,,,,cCursor),PesqPict("SB2","B2_QATU")),;
			TransForm((cCursor)->B2_QEMP,PesqPict("SB2","B2_QEMP")),;
			TransForm((cCursor)->B2_RESERVA,PesqPict("SB2","B2_RESERVA")),;
			TransForm(Posicione("DA1",1,xFilial("DA1")+_cCodTab+_cCodPro,"DA1_PRCVEN"),PesqPict("DA1","DA1_PRCVEN")),;
			TransForm(Posicione("DA1",1,xFilial("DA1")+_cCodTab2+_cCodPro,"DA1_PRCVEN"),PesqPict("DA1","DA1_PRCVEN")),;
			TransForm(SB1->B1_UPRC,PesqPict("SB1","B1_UPRC")),;
			TransForm((cCursor)->VENDAS/_nMeses,PesqPict("SB2","B2_QATU")),;
			TransForm((cCursor)->VENDAS,PesqPict("SB2","B2_QATU")),;
			TransForm((cCursor)->COMPRAS,PesqPict("SB2","B2_QATU")),;
			TransForm((cCursor)->B2_QPEDVEN,PesqPict("SB2","B2_QPEDVEN")),;
			TransForm((cCursor)->B2_SALPEDI,PesqPict("SB2","B2_SALPEDI")),;
			TransForm((cCursor)->B2_QEMPSA,PesqPict("SB2","B2_QEMPSA")),;
			TransForm((cCursor)->B2_QTNP,PesqPict("SB2","B2_QTNP")),;
			TransForm((cCursor)->B2_QNPT,PesqPict("SB2","B2_QNPT")),;
			TransForm((cCursor)->B2_QTER,PesqPict("SB2","B2_QTER")),;
			TransForm((cCursor)->B2_QACLASS,PesqPict("SB2","B2_QACLASS")),;
			TransForm((cCursor)->B2_NAOCLAS,PesqPict("SB2","B2_NAOCLAS"))})
  
	    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acumula totalizadores.                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTotDisp	+= SaldoSB2(,,,,,cCursor)
		nSaldo	+= (cCursor)->B2_QATU
		nQtPV	+= (cCursor)->B2_QPEDVEN
		nQemp	+= (cCursor)->B2_QEMP
		nSalpedi	+= (cCursor)->B2_SALPEDI
		nReserva	+= (cCursor)->B2_RESERVA
		nQempSA	+= (cCursor)->B2_QEMPSA
		nQTNP	+= (cCursor)->B2_QTNP
		nQNPT	+= (cCursor)->B2_QNPT
		nQTER	+= (cCursor)->B2_QTER
		nQACLASS+= (cCursor)->B2_QACLASS
		nQNAOCLAS+= (cCursor)->B2_NAOCLAS
		
		DbSelectArea(cCursor)
		DbSkip()
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o cadastro de produtos                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea('SB1')
	DbSetOrder(1)

	If DbSeek(xFilial("SB1")+cCodProd,.f.)

		cCodProd	:=SB1->B1_COD
		cDescricao	:=SB1->B1_DESC
		cNCM		:=SB1->B1_POSIPI
		nIPI		:=SB1->B1_IPI             
		cTipo		:=Tabela("02",SB1->B1_TIPO)
		cUnidade	:=Posicione('SAH',1,xFilial('SAH')+SB1->B1_UM,'AH_UMRES')
		cMarca		:=Posicione('ZZB',1,xFilial('ZZB')+SB1->B1_XMARCA,'ZZB_XDESMC')
		cSubGrupo	:=Posicione('ZZD',1,xFilial('ZZD')+SB1->B1_XSUBGRU,'ZZD_XDESSG')
		cLinha		:=Posicione('ZZC',1,xFilial('ZZC')+SB1->B1_XLINHA,'ZZC_XDESLN')

        If Empty(cReferencia)
			cReferencia	:=Alltrim(Posicione("ZZA",1,xFilial('ZZA')+cCodProd,'ZZA_XCODRF'))
		End
		If Empty(cCodFor)	
	    	cCodFor		:=Alltrim(Posicione("SA5",2,xFilial('SA5')+cCodProd,'A5_CODPRF'))
        End
    End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha arquivo temporario da TcGenQuery                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea(cCursor)
	DbCloseArea()
	DbSelectArea("SB2")

oListBox:Refresh()
oDescricao:Refresh()
oReferencia:Refresh()
oNCM:Refresh()
oIPI:Refresh()
oTipo:Refresh()
oUnidade:Refresh()
oMarca:Refresh()
oSubGrupo:Refresh()
oLinha:Refresh()
oTotDisp:Refresh()
oSaldo:Refresh()
oQtPV:Refresh()
oQemp:Refresh()
oSalpedi:Refresh()
oReserva:Refresh()
oQempSA:Refresh()
oQTNP:Refresh()
oQNPT:Refresh()
oQTER:Refresh()
oQACLASS:Refresh()
oQNAOCLAS:Refresh()



Return



Static Function IniciaVar()

aSize(aViewB2,0)
cProduto 	:= Space(TamSx3('B1_COD')[1] )                          
cCodProd 	:= Space(TamSx3('B1_COD')[1] )                          
cDescricao	:= Space(TamSx3('B1_DESC')[1] )                          
cReferencia	:= Space(20)  //Space(TamSx3('ZZA_COD')[1] )                          
cNCM	    := Space(TamSx3('B1_POSIPI')[1] )                          
nIPI	    := 0                          
cCodFor	    := Space(TamSx3('A5_CODPRF')[1] )                          
cTipo	    := Space(TamSx3('B1_TIPO')[1] )                          
cUnidade	:= Space(TamSx3('B1_UM')[1] )                          
cMarca		:= Space(TamSx3('ZZB_XDESMC')[1] ) 
cSubGrupo	:= Space(TamSx3('ZZD_XDESSG')[1] )
cLinha		:= Space(TamSx3('ZZC_XDESLN')[1] )
nTotDisp	:= 0
nSaldo		:= 0
nQtPV		:= 0
nQemp		:= 0
nSalpedi	:= 0
nReserva	:= 0
nQTNP		:= 0
nQNPT		:= 0
nQTER		:= 0
nQACLASS	:= 0
nQNAOCLAS	:= 0

oListBox:Refresh()
oDescricao:Refresh()
oReferencia:Refresh()
oNCM:Refresh()
oIPI:Refresh()
oTipo:Refresh()
oUnidade:Refresh()
oMarca:Refresh()
oSubGrupo:Refresh()
oLinha:Refresh()
oTotDisp:Refresh()
oSaldo:Refresh()
oQtPV:Refresh()
oQemp:Refresh()
oSalpedi:Refresh()
oReserva:Refresh()
oQTNP:Refresh()
oQNPT:Refresh()
oQTER:Refresh()
oQACLASS:Refresh()
oQNAOCLAS:Refresh()

Return




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³AjustaSX1 ³ Autor ³Gustavo G. Rueda       ³ Data ³12.01.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta perguntas no SX1.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL -> lRet = .T. ou .F.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nenhum.                                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSx1 (cPerg)
	Local	lRet		:=	.T.
	Local 	aHelpPor	:= {}
	Local 	aHelpEng	:= {}
	Local 	aHelpSpa	:= {}
	PutSx1 (cPerg, "01", 'Tab Preços Venda      ', 'Tab Preços Venda      ', 'Tab Preços Venda      ', "mv_ch1", "C", 3, 0, 0, "G", "NAOVAZIO", "", "", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")	
	PutSx1 (cPerg, "02", 'Tab Preços Promocional', 'Tab Preços Promocional', 'Tab Preços Promocional', "mv_ch2", "C", 3, 0, 0, "G", "NAOVAZIO", "", "", "", "mv_par02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")	
	PutSx1 (cPerg, "03", 'Qtd Meses (Media Variável)', 'Qtd Meses (Media Variável)', 'Qtd Meses (Media Variável)', "mv_ch3", "N", 2, 0, 2, "G", "", "", "", "", "mv_par03",'', '','', "", '', '', '', "", "", "", "", "", "", "", "", "")

Return (lRet)


Static Function MudaPar()
AjustaSX1(cPerg)
If !Pergunte(cPerg,.T.)
   Return
End   
Return