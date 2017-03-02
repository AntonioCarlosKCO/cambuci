#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_CLAIPI
Geração Registro Aliquotas de IPI
@author 	Carlos Eduardo Saturnino
@since 		15/09/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}, ${return_description}
@example	

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_CLAIPI( _cLocal, _cFileName, lJob )
	
	Local _cLFile
	Local _lPrim		:= .T.
	Local _nCodigo	:= 0
	Local _cFile		:= ''
	Local _xVarTmp	:= ""
	Local _nHandle	:= 0
	Local _aArea		:= GetArea()
	Local _nCont		:= 0
		
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
		dbSelectArea('SYD')
		dbSetOrder(1)
		dbGoTop()
		While ! SYD->(Eof()) .And. xFilial('SYD') == SYD->YD_FILIAL
		
			// Preenchimento campo customizado
			If Empty(SYD->YD_XREFSB)
				_nCont ++
				RecLock("SYD",.F.)
				SYD->YD_XREFSB := U_FORMAT(_nCont,'ZC',05)
				SYD->(MsUnlock())
			Endif 

			// Inclui a quebra de linha 
			If _lPrim 
				_lPrim := .F.
			Else
				_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
			Endif

			_xVarTmp	:= Alltrim(SYD->YD_TEC)														// Variável para Formatação
			_cFile 	+= SYD->YD_XREFSB																// A | CIPID 		- Codigo								(Pos.001 - N,05 	- 			)
			_cFile 	+= U_FORMAT(SYD->YD_PER_IPI * 100,'ZC',04)								// B | CIPALIQ 	- Aliquota de IPI						(Pos.006 - N,2,2 	- 			)
			_cFile 	+= U_FORMAT(SYD->YD_PER_PIS * 100,'ZC',04)								// C | CIPPIS 	- Aliquota do PIS						(Pos.010 - N,2,2 	- 			)
			_cFile 	+= U_FORMAT(SYD->YD_PER_COF * 100,'ZC',04)								// D | CIPCOF 	- Aliquota do Cofins					(Pos.014 - N,2,2 	- 			)
			_cFile 	+= U_FORMAT(_xVarTmp,'ZC',10)												// E | CIPNCM 	- Classificação Fiscal NCM			(Pos.018 - N,2,2 	- 			)

			SYD->(dbSkip())

		EndDo
		// Gravação de Log de Processamento
		Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())
	Endif

	FWRITE(_nHandle,_cFile) // GRAVA TEXTO
	
	_nCodigo	:= 0
	_cFile 	:= ''
	FCLOSE(_nHandle)
	RestArea(_aArea)

Return