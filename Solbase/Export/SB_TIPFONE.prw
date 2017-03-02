#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_TIPFONE
Geração Tipos de Imagens (TIPFONE)
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
/*/User Function SB_TIPFONE( _cLocal, _cFileName, lJob )

	Local cAliasQry 	:= GetNextAlias()
	Local _aArea		:= GetArea()
	Local _aTipFone 	:= {}
	Local _cLFile   	:= ''
	Local _cFile		:= ''
	Local _xVarTmp	:= ''
	Local _cQry		:= ''
	Local _cIdent   	:= ''
	Local _nLocFat  	:= '0'
	Local _nHandle	:= 0
	Local _lPrim		:= .T.
	Local _nX
	
	aAdd(_aTipFone,{"TCO", "Comercial      ", "01" })
	aAdd(_aTipFone,{"TRE", "Residencial    ", "02" })
	aAdd(_aTipFone,{"FAX", "Fax            ", "03" })	
	aAdd(_aTipFone,{"EML", "Email          ", "04" })
	aAdd(_aTipFone,{"CEL", "Celular        ", "05" })	
	
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

		For _nX := 1 To Len(_aTipFone)
		
			// Inclui a quebra de linha 
			If _lPrim 
				_lPrim := .F.
			Else
				_cFile 	+= CHR(13) + CHR(10)		// QUEBRA DE LINHA
			Endif

			// Inicio do Fluxo de Informações
			_xVarTmp	:= _aTipFone[_nX][01]
			_cFile 	+= U_FORMAT(_xVarTmp,'XE',03)	// 01-FONID
			_xVarTmp	:= _aTipFone[_nX][02]					
			_cFile 	+= U_FORMAT(_xVarTmp,'XD',15)	// 02-FONDES
	
			FWRITE(_nHandle,_cFile) // GRAVA TEXTO
	
			_cFile		:= ""
	
		Next n
	
		// Gravação de Log de Processamento
		Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())

	Endif

	FWRITE(_nHandle,_cFile) // GRAVA TEXTO

	_cFile 	:= ''

	FCLOSE(_nHandle)

	RestArea(_aArea)

Return()