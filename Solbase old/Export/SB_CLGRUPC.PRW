#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_CLGRUPC
Geração Grupos de Cada Cliente (CLIGRUPC)
@author 	Rogério Doms
@since 		27/10/2016
@version 	1.0
@param 		_cLocal	    , ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}   , ${return_description}
@example

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_CLGRUPC( _cLocal, _cFileName, lJob, _cVend )

	Local _cLFile		:= ''
	Local _cFile		:= ''
	Local _xVarTmp	:= ''
	Local _cQry		:= ''
	Local _nLocFat  	:= '0'
	Local _nHandle	:= 0
	Local _lPrim		:= .T.
	Local cAliasQry	:= GetNextAlias()
	Local _aArea		:= GetArea()
	
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
		_cQry := "SELECT A1_VEND, A1_COD, A1_LOJA, A1_NOME, A1_GRPVEN "	+ CHR(13) + CHR(10)
		_cQry += "FROM " + RetSqlName("SA1") + " SA1 "					+ CHR(13) + CHR(10)
		_cQry += "WHERE SA1.A1_FILIAL 	= '" + xFilial("SA1") + "' "	+ CHR(13) + CHR(10)
		_cQry += "  AND SA1.A1_VEND 	= '" + _cVend + "' "			+ CHR(13) + CHR(10)
		_cQry += "  AND SA1.A1_MSBLQL 	<> '1' "						+ CHR(13) + CHR(10)
		_cQry += "  AND SA1.D_E_L_E_T_	<> '*' "						+ CHR(13) + CHR(10)
		_cQry += "ORDER BY A1_VEND, A1_COD, A1_LOJA "					+ CHR(13) + CHR(10)
	
		MEMOWRIT("\SB_CLIGRUPC.SQL",_cQry)
		cQuery := ChangeQuery(_cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
				
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		While ! (cAliasQry)->(Eof())
		
			// Inclui a quebra de linha 
			If _lPrim
				_lPrim := .F.
			Else
				_cFile += CHR(13) + CHR(10)	// QUEBRA DE LINHA
			Endif
		
			// Fluxo de Informações do Arquivo
			_cFile := (cAliasQry)->(A1_COD + A1_LOJA)					// 01-CLGCLI
			_cFile += U_FORMAT((cAliasQry)->A1_GRPVEN,'ZC',8)		// 03-CLGGRU

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