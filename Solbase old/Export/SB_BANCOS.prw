#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_BANCOS
Geração Bancos Portadores (BANCOS)
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
/*/User Function SB_BANCOS( _cLocal, _cFileName, lJob )

	Local cAliasQry 	:= GetNextAlias()
	Local _cLFile   	:= ''
	Local _cFile		:= ''
	Local _xVarTmp	:= ''
	Local _cQry		:= ''
	Local _cIdent   	:= ''
	Local _nLocFat  	:= '0'
	Local _nHandle	:= 0
	Local _lPrim	:= .T.

	Local _aArea	:= GetArea()
	
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
		_cQry := "SELECT DISTINCT A6_COD"    					+ CHR(13) + CHR(10)
		_cQry += "  FROM " + RetSqlName("SA6") + " SA6 "		+ CHR(13) + CHR(10)
		_cQry += " WHERE SA6.D_E_L_E_T_	<> '*'"				+ CHR(13) + CHR(10)
		_cQry += "   AND SA6.A6_BLOCKED <> '1'"				+ CHR(13) + CHR(10)
		_cQry += "   AND SA6.A6_COD NOT LIKE 'C%'"			+ CHR(13) + CHR(10)
		_cQry += " ORDER BY A6_COD"		
	
		MEMOWRIT("\SB_BANCOS.SQL",_cQry)
		cQuery := ChangeQuery(_cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
				
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		While ! (cAliasQry)->(Eof())
		
			//Posiciona no Banco
			dbSelectArea("SA6")
			SA6->(dbSetOrder(01))
			If SA6->(dbSeek( xFilial("SA6") + (cAliasQry)->A6_COD))
		
				// Inclui a quebra de linha 
				If _lPrim
					_lPrim := .F.
				Else
					_cFile := CHR(13) + CHR(10)	// QUEBRA DE LINHA
				Endif
		
				// Fluxo de Informações do Arquivo
				_cFile += U_FORMAT(Val(SA6->A6_COD),'ZN',05)	// 01-PORID
				_cFile += Substr(SA6->A6_NREDUZ,1,5)			// 02-PORDES
	
				FWRITE(_nHandle,_cFile) // GRAVA TEXTO
	
				_cFile		:= ""
				
			EndIf	
	
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