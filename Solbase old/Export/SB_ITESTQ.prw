#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_ITESTQ()
Gera��o Registros de Estoque
@author 	Carlos Eduardo Saturnino
@since 		21/10/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para grava��o do Arquivo)
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
	Local _nSaldo		:= 0
	Local _cXAntigo	:= '' 
		
	_cLFile  	:= _cLocal + _cFileName
	_nHandle 	:= FCreate(_cLFile)

	// Grava��o de Log de Erro
	If _nHandle == -1 
		If !lJob
			MsgAlert('Erro de grava��o do arquivo no disco. Arquivo ' + _cFileName )
		Else
			Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Erro de grava��o do arquivo no disco')
		Endif
	Else
		
		// Query para defini��o 		
		_cQry		:= " SELECT	B2_FILIAL, B1_XANTIGO, B2_COD, BZ_GRTRIB, B1_COD, B2_LOCAL " 		+ CHR(13) + CHR(10)
		_cQry		+= " FROM	" + RetSqlName("SB1") + "  "												+ CHR(13) + CHR(10)
		_cQry		+= " INNER JOIN	" + RetSqlName("SB2") + "  "										+ CHR(13) + CHR(10)
		_cQry		+= " ON	B1_COD = B2_COD "																+ CHR(13) + CHR(10)
		_cQry		+= " INNER JOIN	" + RetSqlName("SBZ") + "  "										+ CHR(13) + CHR(10)
		_cQry		+= " ON 	BZ_FILIAL = B2_FILIAL "														+ CHR(13) + CHR(10)
		_cQry		+= " AND	BZ_COD = B1_COD "																+ CHR(13) + CHR(10)
		_cQry		+= " WHERE	B1_TIPO = 'ME' "																+ CHR(13) + CHR(10)
	 	_cQry		+= " AND	B2_FILIAL = '"+ xFilial("SB2") +"' "					 					+ CHR(13) + CHR(10)
 		_cQry		+= " AND	B2_LOCAL NOT IN ('98|99') "													+ CHR(13) + CHR(10)
		_cQry		+= " GROUP BY 	B2_FILIAL, B1_XANTIGO, B2_COD, BZ_GRTRIB, B1_COD, B2_LOCAL "	+ CHR(13) + CHR(10)
		_cQry		+= " ORDER BY	B2_FILIAL, B1_XANTIGO "													+ CHR(13) + CHR(10)
	
		MEMOWRIT("\SB_ITESTQ.SQL",_cQry)
		cQuery := ChangeQuery(_cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)		
				
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		While ! (cAliasQry)->(Eof())
			
			_cXAntigo	:= (cAliasQry)-> B1_XANTIGO
		
			
			While ! (cAliasQry)->(Eof()) .And. (cAliasQry)-> B1_XANTIGO = _cXantigo .And. (cAliasQry)-> B2_FILIAL == xFilial("SB2")     
				
				// Efetuo o c�lculo do Estoque do Produto somando todos os armaz�ns 
				dbSelectArea("SB2")
				dbSeek( (cAliasQry)->(B2_FILIAL + B1_COD + B2_LOCAL) )
				_nSaldo += (SaldoSB2() * 100 ) / 100
				
				(cAliasQry)->(dbSkip())
			
			End Do 
			
			If _nSaldo >= 0
			
				// Inclui a quebra de linha 
				If _lPrim 
					_lPrim := .F.
				Else
					_cFile += CHR(13) + CHR(10)														// QUEBRA DE LINHA
				Endif	
				
				// Fluxo de Informa��es do Arquivo
				_xVarTmp	:= (cAliasQry)->B1_XANTIGO
				_cFile 	+= U_FORMAT(_xVarTmp,'XE',08) 
				_cFile 	+= Substr((cAliasQry)->B2_FILIAL,2,3) 
				_cFile 	+= U_FORMAT(_nSaldo,'ZN',14)
				_cFile 	+= Space(13)
				_cFile 	+= (cAliasQry)->BZ_GRTRIB
				_cFile 	+= Replicate("0",08)
				_cFile 	+= Replicate("0",08)
				_cFile 	+= Replicate("0",13)
				_cFile 	+= Replicate("0",05)
				_cFile		+= Space(01)
	
				FWRITE(_nHandle,_cFile) // GRAVA TEXTO
				_cFile		:= ""
				(cAliasQry)->(dbSkip())
			Else		
				_cFile		:= ""
				(cAliasQry)->(dbSkip())
			Endif
			
			_nSaldo := 0
			
		EndDo
		// Grava��o de Log de Processamento
		Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())
	Endif

	FCLOSE(_nHandle)
	(cAliasQry)->(dbCloseArea())
	RestArea(_aArea)

Return