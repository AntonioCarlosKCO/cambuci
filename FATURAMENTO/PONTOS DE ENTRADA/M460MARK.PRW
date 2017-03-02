#Include 'Protheus.ch'

/*
Por 		: Luis Henrique - Global
Em     		: 30/01/15
Objetivo 	: ESPECIFICAÇÃO

CAMPOS ESPECIFICOS :  C9_XIDFAT   C    -  6


10.	Na geração do Documento de Saída, aglutinar e reajustar a condição de pagamento;
A geração do documento de saída deverá prever a aglutinação dos pedidos do mesmo cliente,
mesmo que com condições de pagamentos diferentes, pois a somatória que irá definir a nova condição de pagamento.
Não aglutinar pedidos de transportadora diferentes.
Pedidos com condição de pagamento Tipo 9 não deverão ser tratados na aglutinação.
*/

/*
Descrição:
O ponto de entrada M460MARK é utilizado para validar os pedidos marcados e está localizado
no inicio da função a460Nota (endereça rotinas para a geração dos arquivos SD2/SF2).
Será informado no terceiro parâmetro a série selecionada na geração da nota e o número da nota fiscal
poderá ser verificado pela variável private cNumero.
*/

/*
Parâmetros:

Lógico			Se o pedido esta marcado ou não no MarkBrowse, .T. marcado e .F. não marcado
cSerie			Array of Record			Série selecionada na geração da nota fiscal.

Retorno

lExecuta (logico)
Determina se deverá prosseguir com o processamento para geração da nota fiscal.

*/
User Function M460MARK()
	
	Local _aArea := GetArea()
	Local _lRet := .t.
	Local _nTotal := 0
	Local _cAlias := GetNextAlias()
	Local _cAlias2 := GetNextAlias()
	Local _aParam := PARAMIXB
	// DJALMA BORGES 27/12/2016 - INÍCIO
	Local aAreaSC6 := {} 
	Local aAreaSC5 := {} 
	Local nAliqIpi := 0
	Local nTotPedIpi := 0
	Local nItem := 0
	Local nDesconto := 0
	// DJALMA BORGES 27/12/2016 - FIM

	Private _aSepara := {}

	Private _cA1_XGRPCON := ""

	Private _cMarca 	:= _aParam[1]
	Private _lInverte 	:= _aParam[2]
	Private _cIdFat := GetSXENUM('SC9','C9_XIDFAT')
	ConfirmSx8()

	PreparaSC9()
	ExecQry(1,_cAlias)

	dbSelectArea(_cAlias)
	(_cAlias)->(dbGoTop())

	if ! (_cAlias)->(EOF())

		//SOMA TOTAL DOS PEDIDOS
		While ! (_cAlias)->(EOF())

			// DJALMA BORGES 27/12/2016 - INÍCIO
			
			aAreaSC5 := SC5->(GetArea())
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			SC5->(dbSeek((_cAlias)->C9_FILIAL + (_cAlias)->C9_PEDIDO))
			
			MaFisIni(SC5->C5_CLIENTE,; 	// 1-Codigo Cliente/Fornecedor
			SC5->C5_LOJACLI,; 			// 2-Loja do Cliente/Fornecedor
			"C",; 						// 3-C:Cliente , F:Fornecedor
			SC5->C5_TIPO,; 				// 4-Tipo da NF
			SC5->C5_TIPOCLI,; 			// 5-Tipo do Cliente/Fornecedor
			nil,; 						// 6-Relacao de Impostos que suportados no arquivo
			,; 							// 7-Tipo de complemento
			,; 							// 8-Permite Incluir Impostos no Rodape .T./.F.
			"SB1",; 					// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
			"U_M460MARK.PRW") 				// 10-Nome da rotina que esta utilizando a funcao 
			
			aAreaSC6 := SC6->(GetArea())
			dbSelectArea("SC6")
			SC6->(dbSetOrder(1))
			SC6->(dbSeek((_cAlias)->C9_FILIAL + (_cAlias)->C9_PEDIDO + (_cAlias)->C9_ITEM))
				
			MaFisAdd(SC6->C6_PRODUTO,; 	// 1-Codigo do Produto ( Obrigatorio )
			SC6->C6_TES,;				// 2-Codigo do TES ( Opcional )
			SC6->C6_QTDVEN,;			// 3-Quantidade ( Obrigatorio )
			SC6->C6_PRCVEN,;			// 4-Preco Unitario ( Obrigatorio )
			nDesconto,; 				// 5-Valor do Desconto ( Opcional )
			nil,;						// 6-Numero da NF Original ( Devolucao/Benef )
			nil,;						// 7-Serie da NF Original ( Devolucao/Benef )
			nil,;						// 8-RecNo da NF Original no arq SD1/SD2
			0,;							// 9-Valor do Frete do Item ( Opcional )
			0,; 						// 10-Valor da Despesa do item ( Opcional )
			0,; 						// 11-Valor do Seguro do item ( Opcional )
			0,;							// 12-Valor do Frete Autonomo ( Opcional )
			SC6->C6_VALOR+ nDesconto,;	// 13-Valor da Mercadoria ( Obrigatorio )
			0,;							// 14-Valor da Embalagem ( Opcional )
			0,;							// 15-RecNo do SB1
			0) 							// 16-RecNo do SF4 
			
			/*
			nIPI := MaFisRet(nItem,"IT_ALIQIPI")
			nICM := MaFisRet(nItem,"IT_ALIQICM")
			
			nValIcm := MaFisRet(nItem,"IT_VALICM")
			nValIpi := MaFisRet(nItem,"IT_VALIPI")
			
			nTotIpi := MaFisRet(,'NF_VALIPI')
			nTotIcms := MaFisRet(,'NF_VALICM')
			nTotalNF := MaFisRet(,'NF_TOTAL')
			nTotIcmSol := MaFisRet(,'NF_VALSOL')
			*/
			
			nAliqIpi := MaFisRet(1,"IT_ALIQIPI")
		
			MaFisEnd()
			
			RestArea(aAreaSC6)
			RestArea(aAreaSC5)
			
			// DJALMA BORGES 27/12/2016 - FIM
			
			_nPos := Ascan( _aSepara , { |x|  x[1]+x[2] == (_cAlias)->C9_CLIENTE + (_cAlias)->C5_TRANSP } )
			
			if _nPos == 0
					  //		  [1]					 [2]					[3]					   																							 [4]		   		    [5]								
				AADD( _aSepara, { (_cAlias)->C9_CLIENTE, (_cAlias)->C5_TRANSP,  ((_cAlias)->C9_PRCVEN * (_cAlias)->C9_QTDLIB + ((_cAlias)->C9_PRCVEN * (_cAlias)->C9_QTDLIB * nAliqIpi / 100)),  (_cAlias)->A1_XGRPCON, "" } ) // DJALMA BORGES 27/12/2016
//				AADD( _aSepara, { (_cAlias)->C9_CLIENTE, (_cAlias)->C5_TRANSP,  ((_cAlias)->C9_PRCVEN),  																						 (_cAlias)->A1_XGRPCON, "" } )
			Else
//				_aSepara[_nPos][3] += ((_cAlias)->C9_PRCVEN) // DJALMA BORGES 27/12/2016
				_aSepara[_nPos][3] += ((_cAlias)->C9_PRCVEN * (_cAlias)->C9_QTDLIB + ((_cAlias)->C9_PRCVEN * (_cAlias)->C9_QTDLIB * nAliqIpi / 100))
			Endif

			(_cAlias)->(dbSkip())
		
		EndDo

		//OBTEM CONDICAO DE PAGAMENTO PARA CADA ITEM DO VETOR   CLIENTE + TRANSPORTADORA	
		For _nx := 1 to len(_aSepara)

			// Monta Query com dados da tela de grupo de condição de pagamento
			if ! empty(_aSepara[_nx][4] )

				_cA1_XGRPCON 	:= _aSepara[_nx][4]
				_nTotal			:= _aSepara[_nx][3]
								
				ExecQry(2,_cAlias2, _ntotal)	

				dbSelectArea(_cAlias2)
				(_cAlias2)->(dbGoTop())

				if ! (_cAlias2)->(EOF())

					_aSepara[_nx][5] := (_cAlias2)->E4_CODIGO     

				Endif			

				(_cAlias2)->(dbcloseArea())

			Endif

		Next

		//CONDIÇÃO DE PAGAMENTO CONFORME REGRAS DE ZZG PARA PEDIDOS COM CLIENTE / TRANSPORTADORA IGUAIS

		dbSelectArea(_cAlias)
		(_cAlias)->(dbGotop())

		While ! (_cAlias)->(EOF())

			_nPos := Ascan( _aSepara , {|x|  x[1]+x[2] == (_cAlias)->C9_CLIENTE + (_cAlias)->C5_TRANSP   } )

			if _nPos > 0

				SC5->(dbGoTo( (_cAlias)->(SC5_REC) ))
				
				If SC5->C5_XCPAMPL <> "S" // SÓ FORÇA C5_CONDPAG SE O CAMPO NÃO FOI ALTERADO POR ÚLTIMO PELA TELA CUSTOMIZADA "MANUT PED LIBERADOS"
					Reclock("SC5",.F.)			
						SC5->C5_CONDPAG := _aSepara[_nPos][5]			
					SC5->(MsUnlock())		
				EndIf // DJALMA BORGES 29/11/2016 	 		

			Endif

			(_cAlias)->(dbSkip())
		End

	Endif

	(_cAlias)->(dbCloseArea())

	RestArea(_aArea)
Return(_lRet)



/*/{Protheus.doc} ExecQry
//Executa queries do programa
@author totvsremote
@since 02/03/2016
@version undefined
@param _nTipo, , descricao
@type function
/*/
Static Function ExecQry(_nTipo, _cAlias, _nTotal)

	if _nTipo == 1

		// Query para seleção dos pedidos selecionados cujo tipo seja =N ( Normal )
		BeginSql Alias _cAlias

		column C9_PRCVEN as numeric(14,2)

		%noparser%

		SELECT *
		FROM (
		SELECT *, R_E_C_N_O_ SC9_REC
		FROM %Table:SC9% (Nolock)
		WHERE %NotDel%
		AND C9_XIDFAT = %Exp:_cIdFat%
		) SC9

		INNER JOIN (
		SELECT *, R_E_C_N_O_ SC5_REC
		FROM %Table:SC5% (Nolock)
		Where %NotDel%
		AND C5_TIPO = 'N'

		) SC5 ON C9_FILIAL = C5_FILIAL AND C9_PEDIDO = C5_NUM

		INNER JOIN (
		SELECT A1_XGRPCON , A1_COD
		FROM %Table:SA1% (Nolock)
		Where %NotDel%

		) SA1 ON C5_CLIENTE = A1_COD

		ORDER BY C5_CLIENTE, C5_TRANSP

		EndSql

	Elseif _ntipo == 2

		BeginSql Alias _cAlias

		column E4_SUPER as numeric(14,2)
		column E4_INFER as numeric(14,2)

		%noparser%

		SELECT *
		FROM (
		SELECT *
		FROM %Table:ZZG% (Nolock)
		WHERE %NotDel%
		AND ZZG_CODGRP = %Exp:_cA1_XGRPCON%
		) SZG

		INNER JOIN (
		SELECT *
		FROM %Table:SE4% (Nolock)
		WHERE %NotDel%
		) SE4
		ON ZZG_CODPAG = E4_CODIGO
		AND E4_SUPER >= %Exp:_nTotal%
		AND E4_INFER <= %Exp:_nTotal%

		ORDER BY ZZG_CODPAG

		EndSql                          

	Endif

Return

	//________________________________________________________________________________________________

Static Function PreparaSC9()

	Local _cTipo := ''
	Local _aAreaSC6 := sc6->(GetArea())
	Local aFiltro := Eval(bFiltraBrw,1)
	Local cFilSC9 := aFiltro[1]
	Local cQrySC9 := aFiltro[2]
	Local cFilBrw := aFiltro[3]
	Local cQryBrw := aFiltro[4]
	Local cCond := cFilSC9
	Local lRet := .F. 


	_Alias := Alias()
	_Index := IndexOrd()
	_Regis := Recno()
	_Filial := xFilial()

	Dbselectarea('SC9')
	AliaSC9 := Alias()
	IndeSC9 := IndexOrd()
	RecnSC9 := Recno()
	nRegFilt := RecNo()

	Dbselectarea('SC9')
	cIndice := 'C9_AGREG+'+IndexKey()
	cArq := CriaTrab(NIL,.F.)
	If _lInverte
		cCond += ' .And. C9_OK <> "'+_cMarca+'" '
	Else
		cCond += ' .And. C9_OK = "'+_cMarca+'" '
	EndIf
	cCond += ' .And. C9_NFISCAL == "'+Space(Len(C9_NFISCAL))+'" '
	cCond += ' .And. C9_BLEST == "'+Space(Len(C9_BLEST))+'" .And. C9_BLCRED == "'+Space(Len(C9_BLCRED))+'" '

	IndRegua('SC9',cArq,cIndice,,cCond,OemToAnsi('Selecionando Registros…'))

	nIndex := RetIndex('SC9')
	#IFNDEF TOP
	dbSetIndex(cArq+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndex+1)
	nIndFilt := nIndex + 1

	//===========================================================================

	DbSelectarea('SC9')
	SC9->(DbGotop())
	While !SC9->(EOF())

		Reclock('SC9',.F.)
		SC9->C9_XIDFAT := _cIdFat
		SC9->(MsUnlock())

		SC9->( DbSkip() )
	EndDo

	//————————————————————————————————————————————

	nIndex := RetIndex('SC9')
	Set Filter To
	RestArea(_aAreaSC6)

	Dbselectarea(AliaSC9)
	Dbsetorder(IndeSC9)

	Dbselectarea(_AliaS)
	Dbsetorder(_Index)

Return(lRet)


