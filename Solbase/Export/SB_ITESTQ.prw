#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_ITESTQ()
Geração Registros de Estoque
@author 	Carlos Eduardo Saturnino
@since 		21/10/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}, ${return_description}
@example	

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_ITESTQ( _cLocal, _cFileName, lJob )
		
	Local _cLFile
	Local cAliasQry 	:= GetNextAlias()
	Local _cQry		:= ''
	Local _lPrim		:= .T.
	Local _cFile		:= ''
	Local _xVarTmp	:= ''
	Local _nHandle	:= 0
	Local _aArea		:= GetArea()
		
	_cLFile  	:= _cLocal + _cFileName
	_nHandle 	:= FCreate(_cLFile)

	// Gravação de Log de Erro
	If _nHandle == -1 
		If !lJob
			MsgAlert('Erro de gravação do arquivo no disco. Arquivo ' + _cFileName )
		Else
			Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Erro de gravação do arquivo no disco')
		Endif
	Else
		
		// Query para definição 		
		_cQry		:= " SELECT	B2_FILIAL, B1_XANTIGO, BZ_GRTRIB, SUM(B2_QATU-B2_QACLASS-B2_RESERVA) SLDDISP " 	+ CHR(13) + CHR(10)
		_cQry		+= " FROM	" + RetSqlName("SB1") + "  "											+ CHR(13) + CHR(10)
		_cQry		+= " INNER JOIN	" + RetSqlName("SB2") + "  "										+ CHR(13) + CHR(10)
		_cQry		+= " ON	B1_COD = B2_COD "															+ CHR(13) + CHR(10)
		_cQry		+= " INNER JOIN	" + RetSqlName("SBZ") + "  "										+ CHR(13) + CHR(10)
		_cQry		+= " ON 	BZ_FILIAL = B2_FILIAL "													+ CHR(13) + CHR(10)
		_cQry		+= " AND	BZ_COD = B1_COD "														+ CHR(13) + CHR(10)
		_cQry		+= " WHERE	B1_TIPO = 'ME' "														+ CHR(13) + CHR(10)
 		_cQry		+= " AND	B2_LOCAL IN ('01', '02')"												+ CHR(13) + CHR(10)
 		_cQry		+= " AND	(B2_QATU - B2_QACLASS- B2_RESERVA) > 0"									+ CHR(13) + CHR(10)
		_cQry		+= " GROUP BY 	B2_FILIAL, B1_XANTIGO, BZ_GRTRIB"									+ CHR(13) + CHR(10)
		_cQry		+= " ORDER BY	B2_FILIAL, B1_XANTIGO"												+ CHR(13) + CHR(10)
	
		MEMOWRIT("\SB_ITESTQ.SQL",_cQry)
		cQuery := ChangeQuery(_cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)		
				
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		While ! (cAliasQry)->(Eof())
		
			// Inclui a quebra de linha 
			If _lPrim 
				_lPrim := .F.
			Else
				_cFile += CHR(13) + CHR(10)														// QUEBRA DE LINHA
			Endif	
			
			// Fluxo de Informações do Arquivo
			_xVarTmp	:= (cAliasQry)->B1_XANTIGO
			_cFile 	+= U_FORMAT(_xVarTmp,'XE',08) 
			_cFile 	+= Substr((cAliasQry)->B2_FILIAL,2,3) 
			_cFile 	+= U_FORMAT((cAliasQry)->SLDDISP * 1000,'ZN',14)
			_cFile 	+= Replicate("0",13)
			_cFile 	+= U_FORMAT((cAliasQry)->BZ_GRTRIB, 'XE', 03)
			_cFile 	+= Replicate("0",08)
			_cFile 	+= Replicate("0",08)
			_cFile 	+= Replicate("0",13)
			_cFile 	+= Replicate("0",05)
			_cFile	+= Space(01)

			FWRITE(_nHandle,_cFile) // GRAVA TEXTO
			_cFile		:= ""
			(cAliasQry)->(dbSkip())
			
		EndDo
		// Gravação de Log de Processamento
		Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())
	Endif

	FCLOSE(_nHandle)
	(cAliasQry)->(dbCloseArea())
	RestArea(_aArea)

Return