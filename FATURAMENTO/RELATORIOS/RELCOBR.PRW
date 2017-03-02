#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE 'RWMAKE.CH'   
#INCLUDE "ERROR.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RELCOBR  ºAutor  ³TOTVS               º Data ³  09/19/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Emissão relatório Cobrança                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cambuci                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RELCOBR()
PRIVATE cDirTemp    := GetTempPath()
PRIVATE cPerg    := PADR("RELCOBR",LEN(SX1->X1_GRUPO))

If !SelecionaParam2()
   Return
End      

GeraCobr()

return






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ALBOLGEN  ºAutor  ³Microsiga           º Data ³  10/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SelecionaParam2()
LOCAL aMarked      := {}
Local aPergs := {}
Local aRet   := {}
Local Exec

Aadd(aPergs,{"Local De ?","Local De ?","Local De ?","mv_ch1","C",12,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","",""})
Aadd(aPergs,{"Local Ate?","Local Ate?","Local Ate?","mv_ch2","C",12,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","",""})
Aadd(aPergs,{"Cliente De ?","Cliente De ?","Cliente De ?","mv_ch3","C",06,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
Aadd(aPergs,{"Cliente Ate?","Cliente Ate?","Cliente Ate?","mv_ch4","C",06,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
Aadd(aPergs,{"Emissão De ?","Emissão De ?","Emissão De ?","mv_ch5","D",08,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Emissão Ate?","Emissão Ate?","Emissão Ate?","mv_ch6","D",08,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Lista NF   ?","Lista NF   ?","Lista NF   ?","mv_ch7","N",01,0,1,"C","","mv_par07","Todos","Todos","All","","Desconto Especial","Desconto Especial","Desconto Especial","","","","","","","","",""})

//AjustaSx1(cPerg,aPergs) Raphael 29/07/2016

If !Pergunte (cPerg,.T.)
   Return(.f.)
Endif                    

return(.t.)


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
Static Function GeraCobr()

PRIVATE oDanfe
PRIVATE aRelImp    := MaFisRelImp("MT100",{"SF2","SD2"})
PRIVATE cFilePdf := ''
PRIVATE _nPag :=0
PRIVATE nAjusLin := 0    

oFont36 := TFont():New( "Arial",,36,,.T.,,,,,.F. )
oFont34 := TFont():New( "Arial",,34,,.T.,,,,,.F. )
oFont32 := TFont():New( "Arial",,32,,.T.,,,,,.F. )
oFont30 := TFont():New( "Arial",,30,,.T.,,,,,.F. )
oFont28 := TFont():New( "Arial",,28,,.T.,,,,,.F. )
oFont24 := TFont():New( "Arial",,24,,.T.,,,,,.F. )
oFont22 := TFont():New( "Arial",,22,,.F.,,,,,.F. )
oFont20 := TFont():New( "Arial",,20,,.T.,,,,,.F. )
oFont18 := TFont():New( "Arial",,18,,.F.,,,,,.F. )
oFont14N:= TFont():New( "Arial",,14,,.F.,,,,,.F. )
oFont12 := TFont():New( "Arial",,12,,.T.,,,,,.F. )
oFont10N:= TFont():New( "Arial",,10,,.F.,,,,,.F. )
oFont09N:= TFont():New( "Arial",,09,,.F.,,,,,.F. )
oFont08 := TFont():New( "Arial",,08,,.T.,,,,,.F. )
oFont08N:= TFont():New( "Arial",,08,,.F.,,,,,.F. )
oFont06 := TFont():New( "Arial",,06,,.T.,,,,,.F. )


cFilePDF := 'RELCOBR_'+DTOS(dDataBase)
cFilePDF := UPPER(cFilePDF)

If File( cDirTemp+cFilePDF+'.pdf' )
	Ferase( cDirTemp+cFilePDF+'.pdf' )
Endif
			
lAdjustToLegacy := .T.
lDisableSetup := .t.

oDanfe 	:= FWMSPrinter():New( cFilePDF, IMP_PDF, lAdjustToLegacy, , lDisableSetup)
//oDanfe:Setup()
oDanfe:setDevice(IMP_PDF)
oDanfe:SetPortrait()
oDanfe:cPathPDF :=cDirTemp
oDanfe:SetPaperSize(9)
oDanfe:SetResolution(72)
oDanfe:SetMargin(60,60,60,60)

//Ajuste de saida para pdf para ajustar tamanho de pagina
//oDanfe:nDevice = 6 //SAIDA PDF
PixelX := odanfe:nLogPixelX()
PixelY := odanfe:nLogPixelY()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre arquivo de empresas para obter empresas para consulta do estoque  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SM0")
DbSetOrder(1)
DbGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta cQuery para realizar select no SF2 de todas as Empresas e Filiais ³
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

cCursor   := "RELCOBR"
lQuery    := .T.
aStruSF2  := SF2->(dbStruct())
cQuery:=''

While !Eof()
		
		_cNomeEmp := Alltrim(SM0->M0_FILIAL)
		_cCodEmp  := SM0->M0_CODFIL
		
		cQuery += "SELECT '"+_cNomeEmp+"' as NOMEFIL, '"+_cCodEmp+"' as CODFIL, F2_DOC, F2_EMISSAO, F2_CLIENTE, F2_LOJA, F2_VALBRUT, F2_VALMERC, F2_SERIE, F2_FILIAL, F2_XTOTESP  "
                   
        //Incluindo Somatoria de Quantidade Vendida            
//		cQuery += "SELECT F2_DOC, F2_EMISSAO, F2_CLIENTE, F2_LOJA, F2_VALBRUT  " 
		cQuery += "FROM SF2"+SM0->M0_CODIGO+"0 SF2 WHERE "
		cQuery += "SF2.D_E_L_E_T_ <> '*' AND "
		cQuery += "    F2_FILIAL = '" + _cCodEmp + "' AND "
		cQuery += "    F2_CLIENTE >= '" + MV_PAR03 + "' AND "
		cQuery += "    F2_CLIENTE <= '" + MV_PAR04 + "' AND "
		cQuery += "    F2_EMISSAO >= '" + DtoS(MV_PAR05) + "' AND "
		cQuery += "    F2_EMISSAO <= '" + DtoS(MV_PAR06) + "' "  
		If mv_par07 == 2 //So NF desconto especial
			cQuery += " AND F2_XTOTESP > 0 "   				
	    End
	
		DbSkip()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acrescenta clausula "Union" para juntar todas as select's.              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Eof()
			cQuery += "UNION "
		Else
			cQuery += "	ORDER BY F2_CLIENTE,F2_LOJA, F2_EMISSAO, CODFIL, F2_DOC  "
		EndIf
		
EndDo
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida Query a ser executada.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := ChangeQuery(cQuery)
Memowrite('relcobr.sql',cQuery)
	
SF2->(dbCommit())
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Alias temporario com o resultado da Query.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select(cCursor) > 0
   (cCursor)->(DbCloseArea())
End
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursor,.T.,.T.)
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta os campos que nao sao Caracter de acordo com a estrutura do SF2  ³
//³ uma vez que a TcGenQuery retorna todos os campos como Caracter.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aStruSF2)
	If aStruSF2[nX][2]<>"C"
		TcSetField(cCursor,aStruSF2[nX][1],aStruSF2[nX][2],aStruSF2[nX][3],aStruSF2[nX][4])
	EndIf
Next nX

_nLin:=200 
_nGerNF :=0
_nGerDes:=0
_nGerEsp:=0	  

	DbSelectArea(cCursor)
	DbGoTop()
	While ( (cCursor)->(!Eof()) )

		  _cCliAtu := (cCursor)->(F2_CLIENTE+F2_LOJA)
		  _cNomeCli:=Posicione('SA1',1,xFilial('SA1')+(cCursor)->(F2_CLIENTE+F2_LOJA),'A1_NOME')

		  If _nLin > 70
		     ImpCabec()
		  Else   
	          oDanfe:Line(nAjusLin, 0010, nAjusLin, 2200)
	    	  nAjusLin+=50                     
			  oDanfe:Say(nAjusLin, 0010,'Pessoa: ' + Space(20) + _cNomeCli,oFont08 )
	    	  nAjusLin+=50                     
	      End	  

	      _nCliNF :=0
	      _ncliDes:=0
	      _nCliEsp:=0	  

          While (cCursor)->(!Eof()) .and. (cCursor)->(F2_CLIENTE+F2_LOJA)== _cCliAtu
         
			  If _nLin > 70
			     ImpCabec()
			  End

			  oDanfe:Say(nAjusLin, 0010,(cCursor)->NOMEFIL,oFont08N )
			  oDanfe:Say(nAjusLin, 0210,Posicione('SC6',4,(cCursor)->(F2_FILIAL+F2_DOC+F2_SERIE),'C6_NUM'),oFont08N )
			  oDanfe:Say(nAjusLin, 0320,(cCursor)->F2_DOC,oFont08N )
			  oDanfe:Say(nAjusLin, 0440,DtoC((cCursor)->F2_EMISSAO),oFont08N )

			  oDanfe:Say(nAjusLin, 0570,(cCursor)->F2_CLIENTE+'-'+(cCursor)->F2_LOJA,oFont08N )
			  oDanfe:Say(nAjusLin, 0700,_cNomeCli,oFont08N )

			  _nImpostos:=(cCursor)->(F2_VALBRUT-F2_VALMERC)
  			  _nTotEsp 	:=(cCursor)->F2_XTOTESP + _nImpostos
			  If _nTotEsp > 0
		          _nDesEsp :=_nTotEsp - (cCursor)->F2_VALBRUT
	    	  Else
	        	 _nTotEsp:=(cCursor)->F2_VALBRUT
		         _nDesEsp:=0
		      End    

			  oDanfe:SayAlign(nAjusLin, 1200,AllTrim(Transform(_nTotEsp,"@E 999,999,999.99")),oFont08N,200,40, ,1,2 ) 
			  oDanfe:SayAlign(nAjusLin, 1400,Alltrim(Transform((cCursor)->F2_VALBRUT,PesqPict('SF2','F2_VALBRUT'))),oFont08N,200,40, ,1,2 )
			  oDanfe:SayAlign(nAjusLin, 1600,Alltrim(Transform(_nDesEsp,"@E 999,999,999.99")),oFont08N,200,40, ,1,2 ) 

		      _nCliNF +=(cCursor)->F2_VALBRUT
		      _nCliDes+=_nDesEsp
	    	  _nCliEsp+=_nTotEsp	  

		      _nGerNF +=(cCursor)->F2_VALBRUT
		      _nGerDes+=_nDesEsp
	    	  _nGerEsp+=_nTotEsp	  

			  _nLin++	
	    	  nAjusLin+=30

		 	 DbSelectArea(cCursor)
		 	 (cCursor)->(DbSkip())
		 End	                             

  	     oDanfe:SayAlign(nAjusLin, 0010,'Total Pessoa ---->    ' ,oFont08,200,40, ,0,2 )
   	     oDanfe:SayAlign(nAjusLin, 1200,Transform(_nCliEsp,PesqPict('SF2','F2_VALBRUT')),oFont08,200,40, ,1,2 )
   	     oDanfe:SayAlign(nAjusLin, 1400,Transform(_nCliNF ,PesqPict('SF2','F2_VALBRUT')),oFont08,200,40, ,1,2 )
   	     oDanfe:SayAlign(nAjusLin, 1600,Transform(_nCliDes,PesqPict('SF2','F2_VALBRUT')),oFont08,200,40, ,1,2 )
	     
	     nAjusLin+=50
		 
	End
                             
     if _nGerNF > 0
	     oDanfe:SayAlign(nAjusLin, 0010,'TOTAL GERAL  -------->    ' ,oFont08,200,40, ,0,2 )
    	 oDanfe:SayAlign(nAjusLin, 1200,Transform(_nGerEsp,PesqPict('SF2','F2_VALBRUT')),oFont08,200,40, ,1,2 )
    	 oDanfe:SayAlign(nAjusLin, 1400,Transform(_nGerNF ,PesqPict('SF2','F2_VALBRUT')),oFont08,200,40, ,1,2 )
	     oDanfe:SayAlign(nAjusLin, 1600,Transform(_nGerDes,PesqPict('SF2','F2_VALBRUT')),oFont08,200,40, ,1,2 )
     end	 

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

Return




Static Function ImpCabec()

oDanfe:StartPage()

_nPag++

nAjusLin := 50    
_nLin:=1
If oDanfe:ndevice == 6
	nAjusLin := 100
Endif

oDanfe:Line(nAjusLin, 0010, nAjusLin, 2200)
nAjusLin+=30
oDanfe:Say (nAjusLin, 0010,'Vendas - Descontos Especiais',oFont10N )
oDanfe:Say (nAjusLin, 0810,'CAMBUCI METALÚRGICA LTDA',oFont14N )
oDanfe:Say (nAjusLin, 1900,DtoC(dDataBase),oFont10N )
oDanfe:Say (nAjusLin, 2100,Time(),oFont10N )

nAjusLin+=30
oDanfe:Say (nAjusLin, 0010,'Local De: ' + mv_par01 + ' Ate ' + mv_par02,oFont10N )
oDanfe:Say (nAjusLin, 0850,'Perido De: ' + Dtoc(mv_par05) + ' Ate: ' + Dtoc(mv_par05),oFont10N )
oDanfe:Say (nAjusLin, 2100,'PAG-: ' + Str(_nPag,2) ,oFont10N )

nAjusLin+=30
oDanfe:Say (nAjusLin, 0010,'Local                    Docto      NF             Data          Código       Pessoa                                                                       Valor Total              Valor NF          Descto.Esp  ' ,oFont10N )

nAjusLin+=30
oDanfe:Line(nAjusLin, 0010, nAjusLin, 2200)
nAjusLin+=50

oDanfe:Say(nAjusLin, 0010,'Pessoa:    ' + _cNomeCli,oFont08 )
nAjusLin+=50

Return