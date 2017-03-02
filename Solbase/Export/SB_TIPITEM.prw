#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_TIPITEM
Geração Tipos de Produtos (TIPITEM)
@author 	Rogério Doms
@since 		01/11/2016
@version 	1.0
@param 		_cLocal	    , ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}   , ${return_description}
@example

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_TIPITEM( _cLocal, _cFileName, lJob )

	Local cAliasQry := GetNextAlias() 
	Local _aArea	:= GetArea()
	Local _cLFile   := ''
	Local _cFile	:= ''
	Local _xVarTmp	:= ''
	Local _cQry		:= ''
	Local _cIdent   := ''
	Local _nLocFat  := '0'
	Local _nHandle	:= 0
	Local _lPrim	:= .T.

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
		_cQry := "SELECT ZZD_XCODSG, ZZD_XDESSG, ZZD_MSBLQL"	+ CHR(13) + CHR(10)
		_cQry += "  FROM " + RetSqlName("ZZD") + " ZZD "		+ CHR(13) + CHR(10)
		_cQry += " WHERE ZZD.D_E_L_E_T_	<> '*'"					+ CHR(13) + CHR(10)
		_cQry += "   AND ZZD.ZZD_MSBLQL <> '2'"					+ CHR(13) + CHR(10)
		_cQry += " ORDER BY ZZD_XCODSG"							+ CHR(13) + CHR(10)
	
		MEMOWRIT("\SB_TIPITEM.SQL",_cQry)
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
			_cFile += (cAliasQry)->ZZD_XCODSG						// 01-TPIID
			_cFile += Substr((cAliasQry)->ZZD_XDESSG,1,15)			// 02-TPIDES
			_cFile += Space(03)										// 03-TPIGRU 
			_cFile += "S"											// 04-TPIAJUQVD 
			_cFile += Space(02)										// 05-TPIETQTRT
			_cFile += Space(03)										// 06-TPIETQLOC
	
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

