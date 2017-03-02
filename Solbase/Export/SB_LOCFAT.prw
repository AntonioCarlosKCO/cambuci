#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_LOCFAT
Geração do arquivo de Locais de Faturamento
@author 	Carlos Eduardo Saturnino
@since 		31/10/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}   , ${return_description}
@example

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_LOCFAT( _cLocal, _cFileName, lJob )
		
	Local _cLFile
	lOCAL _nSeq		:= 0
	Local _lPrim		:= .T.
	Local _cFile		:= ''
	Local _xVarTmp	:= ""
	Local _nHandle	:= 0
	Local _aArea		:=	 SM0->(GetArea())
		
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
		dbSelectArea('SM0')
		dbSetOrder(1)
		dbGoTop()
		While ! SM0->(Eof()) 
		
			If ! ALLTRIM(SM0->M0_CODFIL) $ GETMV("ES_FILCONS") // DJALMA BORGES 08/02/2017
			
				// Inclui a quebra de linha 
				If _lPrim 
					_lPrim := .F.
				Else
					_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
				Endif	
				
				// Fluxo de Informações do Arquivo
				_cFile 	+= Substr(SM0->M0_CODFIL,02,03) 
				_cFile 	+= Substr(SM0->M0_FILIAL,01,15)
				_cFile 	+= SM0->M0_ESTCOB

				FWRITE(_nHandle,_cFile) // GRAVA TEXTO
				_cFile		:= ""
			
			EndIf
			
			SM0->(dbSkip())
		
		EndDo
		// Gravação de Log de Processamento
		Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())
	Endif

	
	_cFile 	:= ''
	FCLOSE(_nHandle)
	RestArea(_aArea)

Return