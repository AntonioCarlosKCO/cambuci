#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_MRITEM
Geração Registro Tipos de Produto
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
/*/User Function SB_MRITEM( _cLocal, _cFileName, lJob )
		
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
		dbSelectArea('ZZB')
		dbSetOrder(1)
		dbGoTop()
//		While ! ZZB->(Eof()) .And. xFilial('ZZB') == ZZB->ZZB_FILIAL
		While ! ZZB->(Eof()) // DJALMA BORGES 08/02/2017
			
			// Inclui a quebra de linha 
			If _lPrim 
				_lPrim := .F.
			Else
				_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
			Endif	
			
			_cFile 	+= ZZB->ZZB_XCODMC															// A | CIPID 		- Codigo								(Pos.001 - N,05 	- 			)
			_cFile 	+= Substr(ZZB->ZZB_XDESMC,1,15)												// B | CIPALIQ 	- Aliquota de IPI						(Pos.006 - N,2,2 	- 			)

			ZZB->(dbSkip())

		EndDo
		
		// Gravação de Log de Processamento
		Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())
	Endif

	FWRITE(_nHandle,_cFile) // GRAVA TEXTO
	
	_cFile 	:= ''
	FCLOSE(_nHandle)
	ZZB->(dbCloseArea())
	RestArea(_aArea)

Return