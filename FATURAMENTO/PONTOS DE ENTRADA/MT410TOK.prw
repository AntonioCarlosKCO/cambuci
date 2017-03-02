#include 'protheus.ch'
#include 'parmtype.ch'

User Function MT410TOK()
	If FWIsInCallStack("U_AFAT001") 
		AtuCondPag()
	EndIf 

Return .T.


Static Function AtuCondPag()
	Local aTotais 	:= {}
	Local cCondPag 	:= ""
	Local nTotal	:= 0
	Local nValST	:= 0
	
	aTotais := CalcImp()
	nTotal	:= aTotais[1]
	nValST	:= aTotais[2]
	
	cCondPag := U_CONDPAG(nTotal, nValST)
	
	If !Empty(cCondPag)
		M->C5_CONDPAG := cCondPag
	EndIf
Return


Static Function CalcImp()
	Local aRet := {}
	Local nI 		:= 0
	Local nRecProd  := 0
	Local nRecTes   := 0	
	Local nRecNFOri := 0	  
	Local nPosProd	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "C6_PRODUTO"})
	Local nPosTES	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "C6_TES"})
	Local nPosQuant	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "C6_QTDVEN"})
	Local nPosDesc	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "C6_VALDESC"})
	Local nPosVlrUn	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "C6_PRCVEN"})
	Local nPosVItem	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "C6_VALOR"})
	Private cCliente	:= M->C5_CLIENTE
	Private cLoja		:= M->C5_LOJACLI
	Private cTipo		:= M->C5_TIPO
	Private cTipoCli	:= M->C5_TIPOCLI
	
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1") + cCliente + cLoja)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa a funcao fiscal                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisSave()
	MaFisEnd()
	MaFisIni(cCliente, cLoja, IIf(cTipo $ "DB","F","C"), cTipo, cTipoCli, Nil, Nil, Nil, Nil, "MATA461")

	For nI := 1 To Len(aCols)
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1") + aCols[nI][nPosProd])
		nRecProd := Recno()
		
		DbSelectArea("SF4")
		DbSetOrder(1)
		DbSeek(xFilial("SF4") + aCols[nI][nPosTES])
		nRecTes := Recno()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Agrega os itens para a funcao fiscal         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaFisAdd(SB1->B1_COD,;  // Codigo do Produto ( Obrigatorio )
				SF4->F4_CODIGO,;	  // Codigo do TES ( Opcional )
				aCols[nI][nPosQuant],;	  // Quantidade ( Obrigatorio )
				aCols[nI][nPosVlrUn],;	  // Preco Unitario ( Obrigatorio )
				aCols[nI][nPosDesc],;   // Valor do Desconto ( Opcional )
				"",;	  // Numero da NF Original ( Devolucao/Benef )
				"",;	  // Serie da NF Original ( Devolucao/Benef )
				0,;		  // RecNo da NF Original no arq SD1/SD2
				0,;  // Valor do Frete do Item ( Opcional )
				0,;  // Valor da Despesa do item ( Opcional )
				0,;  // Valor do Seguro do item ( Opcional )
				0,;  // Valor do Frete Autonomo ( Opcional )
				aCols[nI][nPosVItem],;  // Valor da Mercadoria ( Obrigatorio )
				0,;  // Valor da Embalagem ( Opiconal )
				nRecProd,;		  // RecNo do SB1
				nRecTes) 		  // RecNo do SF4
				
		MaFisWrite(1)
	Next nI
		
	aRet := {MaFisRet(,"NF_TOTAL"), MaFisRet(,"NF_VALSOL")}
	
	MaFisEnd()					
		
Return aRet