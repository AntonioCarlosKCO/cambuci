#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_FINANCA
Geração Financeiro Contas a Receber (FINANCAS)
@author 	Rogério Doms
@since 		28/10/2016
@version 	1.0
@param 		_cLocal	    , ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}   , ${return_description}
@example

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_FINANCA( _cLocal, _cFileName, lJob, _cVend )

	Local cAliasQry  := GetNextAlias()
	Local cAliasSA1  := GetNextAlias()
	Local _cLFile    := ''
	Local _cFile	 := ''
	Local _xVarTmp	 := ''
	Local _cQry		 := ''
	Local _cIdent    := ''
	Local _nLocFat   := '0'
	Local _nHandle	 := 0	
	Local _lPrim	 := .T.
	
	Local _aArea	 := GetArea()
	
	//Nome do Arquivo
	_cLFile  := _cLocal + _cFileName
	_nHandle := FCreate(_cLFile)

	// Gravação de Log de Erro
	If _nHandle == -1

		If !lJob
			MsgAlert('Erro de gravação do arquivo no disco. Arquivo ' + _cFileName )
		Else
			Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Erro de gravação do arquivo no disco')
		Endif

	Else

		// Query para definição 
		_cQry := "SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_PORTADO, E1_CLIENTE, E1_LOJA,"	+ CHR(13) + CHR(10)
		_cQry += "       E1_EMISSAO, E1_VENCREA, E1_VALOR, E1_SALDO, A1_VEND, SE1.R_E_C_N_O_ E1REC"		+ CHR(13) + CHR(10)
		_cQry += "  FROM "      + RetSqlName("SE1") + " SE1 "							+ CHR(13) + CHR(10)
		_cQry += " INNER JOIN " + RetSqlName("SA1") + " SA1 "							+ CHR(13) + CHR(10)
		_cQry += "         ON SA1.D_E_L_E_T_ <> '*'"									+ CHR(13) + CHR(10)
		_cQry += "        AND SA1.A1_COD  = SE1.E1_CLIENTE"      						+ CHR(13) + CHR(10)
		_cQry += "        AND SA1.A1_LOJA = SE1.E1_LOJA" 								+ CHR(13) + CHR(10)
		_cQry += "        AND SA1.A1_MSBLQL	<> '1'"										+ CHR(13) + CHR(10)
		_cQry += "        AND SA1.A1_VEND = '" + _cVend + "'" 							+ CHR(13) + CHR(10)
		_cQry += " WHERE SE1.D_E_L_E_T_	<> '*'"											+ CHR(13) + CHR(10)
//		_cQry += "   AND SE1.E1_FILIAL = '" + xFilial("SE1") + "'"						+ CHR(13) + CHR(10) // COMENTADO POR DJALMA BORGES 08/02/2017
		_cQry += "   AND SE1.E1_FILIAL = '" + xFilial("SE1") + "'"						+ CHR(13) + CHR(10)
		_cQry += "   AND SE1.E1_SALDO  > 0" 											+ CHR(13) + CHR(10)
		_cQry += " ORDER BY E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA"		+ CHR(13) + CHR(10)
	
		MEMOWRIT("\SB_FINANCAS.SQL",_cQry)
		cQuery := ChangeQuery(_cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
				
		dbSelectArea(cAliasQry) 
		(cAliasQry)->(dbGoTop())
		While ! (cAliasQry)->(Eof())
		
			// Inclui a quebra de linha 
			If _lPrim
				_lPrim := .F.
			Else
				_cFile := CHR(13) + CHR(10)	// QUEBRA DE LINHA
			Endif
		
			// Fluxo de Informações do Arquivo
			_cFile += (cAliasQry)->(E1_CLIENTE + E1_LOJA)										// 01-FINCLI
			_cFile += U_FORMAT((cAliasQry)->E1REC,'ZN',8)												// 02-FINID
			_cFile += (cAliasQry)->E1_LOJA														// 03-FINEND
			_cFile += "DRPV"																	// 04-FINTIPO
			_cFile += SubStr((cAliasQry)->E1_NUM,2,8)											// 05-FINNRO
			_cFile += (cAliasQry)->E1_PARCELA + Space(01)                                		// 06-FINPAR
			_cFile += U_FORMAT((cAliasQry)->E1_PORTADO,'XD',05)									// 07-FINPOR
			_cFile += Substr((cAliasQry)->E1_EMISSAO,7,2) + "/" + Substr((cAliasQry)->E1_EMISSAO,5,2) + "/" + Substr((cAliasQry)->E1_EMISSAO,1,4)	// 08-FINDTEMI
			_cFile += Substr((cAliasQry)->E1_VENCREA,7,2) + "/" + Substr((cAliasQry)->E1_VENCREA,5,2) + "/" + Substr((cAliasQry)->E1_VENCREA,1,4) 	// 09-FINDTVCT
			_nVal  := Int((cAliasQry)->E1_VALOR*100)
			_cFile += U_FORMAT(_nVal,'ZN',13)													// 10-FINVORI
			_nVal  := Int((cAliasQry)->E1_SALDO*100)
			_cFile += U_FORMAT(_nVal,'ZN',13)													// 11-FINSDO
			_cFile += "R+"																		// 12-FINSTATUS
			_cFile += "00000"																	// 13-DINDTOL
			_cFile += Substr((cAliasQry)->E1_FILIAL,2,3)										// 14-FINLOF
	
			FWRITE(_nHandle,_cFile) // GRAVA TEXTO
	
			_cFile		:= ""
	
			(cAliasQry)->(dbSkip())

		EndDo
	
		(cAliasQry)->(dbCloseArea())

		// Gravação de Log de Processamento
		Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())

	Endif

	FWRITE(_nHandle,_cFile) // GRAVA TEXTO

	_cFile 	:= ''

	FCLOSE(_nHandle)

	RestArea(_aArea)

Return()


