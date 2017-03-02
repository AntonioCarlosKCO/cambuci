#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_ITECOMPL()
Geração Registros de Complemento de Produtos
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
/*/User Function SB_ITECOMPL( _cLocal, _cFileName, lJob )
		
	Local _cLFile
	lOCAL _nSeq		:= 0
	Local _lPrim		:= .T.
	Local _cFile		:= ''
	Local _xVarTmp	:= ""
	Local _nHandle	:= 0
	Local _aArea		:=	 GetArea()
		
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
		dbSelectArea('ZZA')
		dbSetOrder(1)
		dbGoTop()
//		While ! ZZA->(Eof()) .And. xFilial('ZZA') == ZZA->ZZA_FILIAL 
		While ! ZZA->(Eof()) // DJALMA BORGES 08/02/2017
			
			// Inclui a quebra de linha 
			If _lPrim 
				_lPrim := .F.
			Else
				_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
			Endif	
			
			// Fluxo de Informações do Arquivo
			_xVarTmp	:= Posicione("SB1",1, xFilial("SB1")+ ZZA->ZZA_XCOD, "B1_XANTIGO")
			_cFile 	+= U_FORMAT(_xVarTmp,'XE',08) 
			_cFile 	+= "APL"
			_cFile 	+= Substr(ZZA->ZZA_XAPLIC, 1, 40)

			FWRITE(_nHandle,_cFile) // GRAVA TEXTO
			_cFile		:= ""
			
			ZZA->(dbSkip())
		
		EndDo
		// Gravação de Log de Processamento
		Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())
	Endif

	
	_cFile 	:= ''
	FCLOSE(_nHandle)
	ZZA->(dbCloseArea())
	RestArea(_aArea)

Return