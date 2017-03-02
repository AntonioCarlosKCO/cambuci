#include "totvs.ch"

/*
+===========================================================================+
|===========================================================================|
|Programa: PE01NFESEFAZ    | Tipo: Ponto de Entrada   |  Data: 04/09/2014   |
|===========================================================================|
|Programador: Caio Garcia - Global Gcs                                      |
|===========================================================================|
|Utilidade: Tratar as especificações do xml do cliente.                     |
|                                                                           |
|===========================================================================|
+===========================================================================+
*/

USER FUNCTION PE01NFESEFAZ()

Local aProd		:= PARAMIXB[1]
Local cMensCli	:= PARAMIXB[2]
Local cMensFis	:= PARAMIXB[3]
Local aDest		:= PARAMIXB[4]
Local aNota   	:= PARAMIXB[5]
Local aInfoItem := PARAMIXB[6]
Local aDupl		:= PARAMIXB[7]
Local aTransp	:= PARAMIXB[8]
Local aEntrega	:= PARAMIXB[9]
Local aRetirada := PARAMIXB[10]
Local aVeiculo	:= PARAMIXB[11]
Local aReboque	:= PARAMIXB[12]

Local aRetorno := {}
Local nX
Local cAliasSF2:= ""
Local cAliasSF3:= ""
Local _cCodRef := ""
Local _cNDesc  := ""
Local cMsg	   := ""
Local cMsg2    := ""
Local cMsg3	   := ""	
Local _cCli    := ""
Local _cLoja   := ""
Local _cTpFat  := ""

Local _cNumDI   := ""
Local _cDataDi  := ""
Local _cEspecie := ""
Local _cVolume  := ""

//FILIAL+NUM+ITEM+PRODUTO
//Exemplo
/*
cMsg := 'Produto: '+aProd[1][4] + CRLF
cMsg += 'Mensagem da nota: '+cMensCli + CRLF
cMsg += 'Mensagem padrao: '+cMensFis + CRLF
cMsg += 'Destinatario: '+aDest[2] + CRLF
cMsg += 'Numero da nota: '+aNota[2] + CRLF
cMsg += 'Pedido: ' +aInfoItem[1][1]+ 'Item PV: ' +aInfoItem[1][2]+ 'Codigo do Tes: ' +aInfoItem[1][3]+ 'Item no pedido: ' +aInfoItem[1][4] + CRLF
cMsg += 'Existe Duplicata ' + If( len(aDupl) > 0, "SIM", "NAO" )  + CRLF
cMsg += 'Existe Transporte ' + If( len(aTransp) > 0, "SIM", "NAO" ) + CRLF
cMsg += 'Existe Entrega ' + If( len(aEntrega) > 0, "SIM", "NAO" ) + CRLF
cMsg += 'Existe Retirada ' + If( len(aRetirada) > 0, "SIM", "NAO" ) + CRLF
cMsg += 'Existe Veiculo ' + If( len(aVeiculo) > 0, "SIM", "NAO" )
cMsg += 'Placa Reboque: ' +aReboque[1]+ 'Estado Reboque:' +aReboque[2]+ 'RNTC:' +aReboque[3]
*/

If aNota[4] == "1"
	
	//Trata o código de referência do produto
	For nX := 1 To Len(aProd)
		
		_cCodRef := AllTrim(POSICIONE("SC6",1,XFILIAL("SC6")+aInfoItem[nX,1]+aInfoItem[nX,2]+aProd[nX,2],"C6_XCODREFE"))
		
		If !Empty(_cCodRef)
			
			_cNDesc := "("+_cCodRef+") - "+AllTrim(aProd[nX,4])
			
			aProd[nX,4] := _cNDesc
			
		Else //caso não tenha a referência imprimir o código do produto
		
			_cNDesc := "("+Alltrim(aProd[nX,2])+") - "+AllTrim(aProd[nX,4])
			
			aProd[nX,4] := _cNDesc
				
			
		EndIf
		
		//Adiciona os pedidos de venda relacionados a nota fiscal
		If !Empty(aInfoItem[nX][1]) .and. !(aInfoItem[nX][1] $ cMsg)
			
			cMsg += CRLF + 'PEDIDO: ' + aInfoItem[nX][1]+" - "
			
		EndIf
		
	Next nX
	
	cMsg2 := cMsg+" "+cMensCli
	
	cMensCli := cMsg2
	
	//trata mensagem especifica para o estado parana
	If SM0->M0_ESTENT == "PR"
		
		cAliasSF3 := GetNextAlias()
		BeginSql Alias cAliasSF3
	
		SELECT SUM(F3_BASEICM) F3_BASEICM,SUM(F3_VALICM) F3_VALICM,SUM(F3_BASERET) F3_BASERET, SUM(F3_ICMSRET) F3_ICMSRET
		FROM %TABLE:SF3% SF3
		WHERE F3_FILIAL = %EXP:SF3->F3_FILIAL%
		AND F3_NFISCAL = %EXP:SF3->F3_NFISCAL%
		AND F3_SERIE = %EXP:SF3->F3_SERIE%
		AND F3_CLIEFOR = %EXP:SF3->F3_CLIEFOR%
		AND F3_LOJA = %EXP:SF3->F3_LOJA%
		AND F3_IDENTFT = %EXP:SF3->F3_IDENTFT%
		AND F3_CFO = '5405'
		AND %NotDel%
		EndSql
		
			(cAliasSF3)->(dbGoTop())
		If  (cAliasSF3)->(!EOF())
		
			cAliasSF2 := GetNextAlias()
			BeginSql Alias cAliasSF2		
			
			COLUMN F2_BASEICM as Numeric(16,2)
			COLUMN F2_VALICM as Numeric(16,2)
			COLUMN F2_BRICMS as Numeric(16,2)
			COLUMN F2_ICMSRET as Numeric(16,2)
			
			SELECT SUM(F2_BASEICM) F2_BASEICM,
			SUM(F2_VALICM) F2_VALICM,
			SUM(F2_BRICMS) F2_BRICMS, 
			SUM(F2_ICMSRET) F2_ICMSRET
			FROM SF2010 SF2
			WHERE F2_FILIAL = %EXP:SF3->F3_FILIAL%
			AND F2_DOC = %EXP:SF3->F3_NFISCAL%
			AND F2_SERIE = %EXP:SF3->F3_SERIE%
			AND F2_CLIENTE = %EXP:SF3->F3_CLIEFOR%
			AND F2_LOJA = %EXP:SF3->F3_LOJA%	
			AND %NotDel%
			EndSql		
				(cAliasSF2)->(dbGoTop())
				If  (cAliasSF2)->(!EOF())
					cMsg3 := "  ******  "
					cMsg3 += "  Base de Icms op propria 010 060 070: R$"+ Transform((cAliasSF2)->F2_BASEICM,"@E 999,999,999.99")+"  Valor Base Subst Tributaria: R$" + Transform((cAliasSF2)->F2_BRICMS,"@E 999,999,999.99")
					cMsg3 += "  Valor de Icms op propria 010 060 070: R$"+ Transform((cAliasSF2)->F2_VALICM,"@E 999,999,999.99")+"  Valor Subst Tributaria: R$"+ Transform((cAliasSF2)->F2_ICMSRET,"@E 999,999,999.99")
					cMsg3 += "  ICMS RET. POR SUBST. TRIB. CONF. PROT. 97/2010 - 62/2012" 
				EndIf
		EndIf
	EndIf
	
	cMensCli := cMensCli + cMsg3 
		
ElseIf aNota[4] == "0"
	
	If Alltrim(aDest[9]) == "EX"
		
		For nX := 1 To Len(aProd)
			
			//Adiciona os pedidos de compra relacionados a nota fiscal
			If !Empty(aInfoItem[nX][1]) .and. !(aInfoItem[nX][1] $ cMsg)
				
				cMsg += CRLF + 'PEDIDO DE COMPRAS: ' + aInfoItem[nX][1]+" - "
				
			EndIf
			
		Next
		
		_cNumDi   := CD5->CD5_NDI        //Número da DI;
		_cDataDi  := CD5->CD5_DTDI       //Data de Registro da DI;		
		
		cMsg += IIF(!Empty(_cNumDI),"DI: "+AllTrim(_cNumDi)+" ","")
		cMsg += IIF(!Empty(_cDataDi),"DE "+Subs(AllTrim(DtoS(_cDataDi)),7,2)+"/"+Subs(AllTrim(Dtos(_cDataDi)),5,2)+"/"+Subs(AllTrim(Dtos(_cDataDi)),1,4)+" ","")
		
		If Empty(cMensCli)
			cMensCli += AllTrim(SF1->F1_ESPECI1)+": "+cValToChar(SF1->F1_VOLUME1)
		Else
			cMensCli += " - "+AllTrim(SF1->F1_ESPECI1)+": "+cValToChar(SF1->F1_VOLUME1)
		EndIf	
		
		cMsg2 := cMsg+" "+cMensCli
		
		cMensCli := cMsg2
		
	EndIf
	
EndIf

//A ordem de retorno não pode ser alterada, pois é a ordem de retorno aguardada pelo ponto de entrada.
aRetorno := {aProd,cMensCli,cMensFis,aDest,aNota,aInfoItem,aDupl,aTransp,aEntrega,aRetirada,aVeiculo,aReboque}

Return aRetorno




