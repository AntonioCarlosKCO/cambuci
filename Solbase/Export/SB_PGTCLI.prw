#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_PGTCLI
Geração Cond. Pagamento X Clientes (SB_PGTCLI)
@author 	Rogério Doms
@since 		31/10/2016
@version 	1.0
@param 		_cLocal	    , ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}   , ${return_description}
@example

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_PGTCLI( _cLocal, _cFileName, lJob, _cVend )

	Local cAliasQry  := GetNextAlias() 
	Local _cLFile    := ''
	Local _cFile	 := ''
	Local _xVarTmp	 := ''
	Local _cQry		 := ''
	Local _cIdent    := ''
	Local _nLocFat   := '0'
	Local _nHandle	 := 0
	Local _nValFaixa := 0	
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
	_cQry := "SELECT A1_VEND, A1_COD, A1_LOJA, A1_COND, A1_XGRPCON, ZZG_CODPAG, E4_CODIGO "													+ CHR(13) + CHR(10)
	_cQry += "  FROM " + RetSqlName("SA1") + " SA1 (NOLOCK) "																				+ CHR(13) + CHR(10)
	_cQry += " INNER JOIN " + RetSqlName("ZZF") + " ZZF (NOLOCK) "																			+ CHR(13) + CHR(10)
	_cQry += "         ON (ZZF_FILIAL = '" + xFilial("ZZF") + "' AND ZZF_CODIGO = A1_XGRPCON AND ZZF.D_E_L_E_T_ = '') "						+ CHR(13) + CHR(10)
	_cQry += " INNER JOIN " + RetSqlName("ZZG") + " ZZG (NOLOCK) "																			+ CHR(13) + CHR(10)
	_cQry += "         ON (ZZG_FILIAL = '" + xFilial("ZZG") + "' AND ZZG_CODGRP = ZZF_CODIGO AND ZZG.D_E_L_E_T_ = '') "						+ CHR(13) + CHR(10)
	_cQry += " INNER JOIN " + RetSqlName("SE4") + " SE4 (NOLOCK) "																			+ CHR(13) + CHR(10)
	_cQry += "         ON (E4_FILIAL = '" + xFilial("SE4") + "' AND E4_CODIGO = ZZG_CODPAG AND E4_MSBLQL <> '1' AND SE4.D_E_L_E_T_ = '') "	+ CHR(13) + CHR(10)
	_cQry += " WHERE SA1.D_E_L_E_T_ = '' "																						            + CHR(13) + CHR(10)
//	_cQry += "   AND A1_FILIAL = '" + xFilial("SA1") + "' "	 SOMENTE ESTA LINHA FOI COMENTADA POR DJALMA BORGES 08/02/2017																				
	//_cQry += "   AND A1_VEND = '" + _cVend + "'" 																							+ CHR(13) + CHR(10)
	//_cQry += "AND " + _nValFaixa + " >= E4_INFER " + CHR(13) + CHR(10)
	//_cQry += "AND " + _nValFaixa + " <= E4_SUPER " + CHR(13) + CHR(10)

	_cQry += "ORDER BY E4_CODIGO "+CHR(13)+CHR(10)	
	 		
	MEMOWRIT("\SB_PGTCLI.SQL",_cQry)
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
			_cFile += (cAliasQry)->(A1_COND + ZZG_CODPAG)	// 01-PGCPGT
			_cFile += (cAliasQry)->(A1_COD + A1_LOJA)		// 02-PGCCLI
	
			FWRITE(_nHandle,_cFile) // GRAVA TEXTO
	
			_cFile := ""
	
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

