#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'

//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_GRUITEX
Geração Registro de Grupos Auxiliares de Itens
@author 	Carlos Eduardo Saturnino
@since 		12/09/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}, ${return_description}
@example	REGISTRO VAZIO

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_GRUITEX( _cLocal, _cFileName, lJob )

	
	Local _cLFile
	Local _cFile		:= ''
	Local _xVarTmp	:= ""
	Local _nHandle	:= 0
	Local _nCount		:= 0
	Local _cHist		:= ""
		
	_cLFile  := _cLocal + _cFileName
	_nHandle :=	FCreate(_cLFile)

	If _nHandle == -1 
		If !lJob
			MsgAlert('Erro de gravação do arquivo no disco. Arquivo ' + _cFileName )
		Else
			Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Erro de gravação do arquivo no disco')
		Endif
	Endif
	
	// Gravação de Logs
	Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Arquivo Gravado com sucesso as ' + Time())	

	FCLOSE(_nHandle)

Return