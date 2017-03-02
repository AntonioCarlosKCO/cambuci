#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_LISTAS()
Geração Registros de Tabela de Preços
@author 	Carlos Eduardo Saturnino
@since 		24/10/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}, ${return_description}
@example	

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_LISTAS( _cLocal, _cFileName, lJob )
		
	Local _cLFile
	Local cAliasQry 	:= GetNextAlias()
	Local _cQry		:= ''
	Local _lPrim		:= .T.
	Local _cFile		:= ''
	Local _xVarTmp	:= ''
	Local _nHandle	:= 0
	Local _aArea		:= GetArea()
	Local _nSaldo		:= 0
		
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
		_cQry		:= " SELECT	* " 																		+ CHR(13) + CHR(10)
		_cQry		+= " FROM		" + RetSqlName("DA0") + "  "											+ CHR(13) + CHR(10)
		_cQry		+= " WHERE		D_E_L_E_T_ <>  '*' "													+ CHR(13) + CHR(10)		
		_cQry		+= " ORDER BY	DA0_FILIAL, DA0_CODTAB, DA0_DESCRI "									+ CHR(13) + CHR(10)
	
		MEMOWRIT("\SB_LISTAS.SQL",_cQry)
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
			_xVarTmp	:= 	(cAliasQry)->DA0_CODTAB
			_cFile 	+= 	U_FORMAT(_xVarTmp,'XE',06) 
			_cFile 	+= 	Substr((cAliasQry)->DA0_DESCRI,1,15)
			_cFile 	+= Substr((cAliasQry)->DA0_DATDE,7,2)	+"/"+ Substr((cAliasQry)->DA0_DATDE,5,2)	+"/"+ Substr((cAliasQry)->DA0_DATDE,1,4)
			_cFile 	+= Substr((cAliasQry)->DA0_DATATE,7,2)	+"/"+ Substr((cAliasQry)->DA0_DATATE,5,2)	+"/"+ Substr((cAliasQry)->DA0_DATATE,1,4)
			_cFile 	+=	"NNNNSN"
			_cFile 	+= 	Replicate("0",20)
			_cFile 	+= Substr((cAliasQry)->DA0_DATDE,7,2)	+"/"+ Substr((cAliasQry)->DA0_DATDE,5,2)	+"/"+ Substr((cAliasQry)->DA0_DATDE,1,4)
			_cFile 	+= Substr((cAliasQry)->DA0_DATATE,7,2)	+"/"+ Substr((cAliasQry)->DA0_DATATE,5,2)	+"/"+ Substr((cAliasQry)->DA0_DATATE,1,4)
			_cFile 	+= "I"
			_cFile	+= REPLICATE("0",4)
			_cFile  += "S"

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