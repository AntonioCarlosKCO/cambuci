#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_LINITEM()
Geração Registro Linha
@author 	Carlos Eduardo Saturnino
@since 		20/10/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}, ${return_description}
@example	

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_LINITEM( _cLocal, _cFileName, lJob )
		
	Local _cLFile
	Local _lPrim		:= .T.
	Local _cFile		:= ''
	Local _xVarTmp	:= ""
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
		dbSelectArea('ZZC')
		dbSetOrder(1)
		dbGoTop()
//		While ! ZZC->(Eof()) .And. xFilial('ZZC') == ZZC->ZZC_FILIAL
		While ! ZZC->(Eof()) 
			
			// Inclui a quebra de linha 
			If _lPrim 
				_lPrim := .F.
			Else
				_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
			Endif	
			
			// Fluxo de Informações do Arquivo
			_cFile 	+= ZZC->ZZC_XCODLN															// A | CIPID 		- Codigo								(Pos.001 - N,05 	- 			)
			_cFile 	+= Substr(ZZC->ZZC_XDESLN,1,15)												// B | CIPALIQ 	- Aliquota de IPI						(Pos.006 - N,2,2 	- 			)

			ZZC->(dbSkip())

		EndDo
		// Gravação de Log de Processamento
		Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())
	Endif

	FWRITE(_nHandle,_cFile) // GRAVA TEXTO
	
	_cFile 	:= ''
	FCLOSE(_nHandle)
	ZZC->(dbCloseArea())
	RestArea(_aArea)

Return