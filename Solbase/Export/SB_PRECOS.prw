#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_PRECOS
Geração Preços dos Itens (PRECOS)
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
/*/User Function SB_PRECOS( _cLocal, _cFileName, lJob )

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
		_cQry := "SELECT DA0_FILIAL, DA0_CODTAB, DA1_CODPRO, DA1_PRCVEN, B1_XANTIGO, B1_UM"	+ CHR(13) + CHR(10)
		_cQry += "  FROM " + RetSqlName("DA0") + " DA0 "			+ CHR(13) + CHR(10)
		_cQry += " INNER JOIN " + RetSqlName("DA1") + " DA1 "		+ CHR(13) + CHR(10)
		_cQry += "         ON DA1.DA1_FILIAL = DA0.DA0_FILIAL " 	+ CHR(13) + CHR(10)
		_cQry += "        AND DA1.DA1_CODTAB = DA0.DA0_CODTAB " 	+ CHR(13) + CHR(10)
		_cQry += "        AND DA1.D_E_L_E_T_ <> '*' "           	+ CHR(13) + CHR(10)
		_cQry += " INNER JOIN " + RetSqlName("SB1") + " SB1 "		+ CHR(13) + CHR(10)
		_cQry += "         ON SB1.B1_COD = DA1.DA1_CODPRO "		+ CHR(13) + CHR(10)
		_cQry += "        AND SB1.D_E_L_E_T_ <> '*' "	        	+ CHR(13) + CHR(10)
//		_cQry += " WHERE DA0.DA0_FILIAL = '" + xFilial("DA0") + "'" + CHR(13) + CHR(10)
//		_cQry += "   AND DA0.D_E_L_E_T_	<> '*'"						+ CHR(13) + CHR(10)
		_cQry += " WHERE DA0.D_E_L_E_T_	<> '*'"						+ CHR(13) + CHR(10) // DJALMA BORGES 08/02/2017
		_cQry += " ORDER BY DA0_CODTAB, DA1_CODPRO"					+ CHR(13) + CHR(10)
	
		MEMOWRIT("\SB_PRECOS.SQL",_cQry)
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
			_cFile += Substr((cAliasQry)->B1_XANTIGO,1,8)				//01-PREITE
			_cFile += U_FORMAT( Val((cAliasQry)->DA0_CODTAB),'ZN',6 )	//02-PRELIS
			_nVal  := Int((cAliasQry)->DA1_PRCVEN*100)
			_cFile += U_FORMAT(_nVal,'ZN',15)							//03-PREVLR
			_cFile += "0000000000"										//04-PREQTM
			_cFile += "S"												//05-PRETRTDC
			_cFile += "0000"											//06-PRETXDCT
			_cFile += "0000001000"										//07-PREEMBQ
			_cFile += (cAliasQry)->B1_UM								//08-PREEMBU
			
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
