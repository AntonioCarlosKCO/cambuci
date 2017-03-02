#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_TIPREFER()
Geração Registro de Tabela de Referência
@author 	Carlos Eduardo Saturnino
@since 		03/10/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}, ${return_description}
@example	

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_TIPREFER( _cLocal, _cFileName, lJob )
	
	Local _cLFile
	Local _lPrim		:= .T.
	Local _cFile		:= ''
	Local _xVarTmp	:= ''
	Local _nHandle	:= 0
	Local _aArea		:= GetArea()
	Local _aTipRef	:= {}
	Local _nX
	
	
	aAdd(_aTipRef,{"1", "Opcional"	})
	aAdd(_aTipRef,{"2", "Similar"	})
	aAdd(_aTipRef,{"3", "Montadora"	})
	aAdd(_aTipRef,{"4", "Tecnica"	})                                                                                       
	aAdd(_aTipRef,{"5", "Original"	})
		
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
		For _nX := 1 to Len(_aTipRef)

			// Inclui a quebra de linha 
			If _lPrim 
				_lPrim := .F.
			Else
				_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
			Endif

			_xVarTmp	:= _aTipRef[_nX][01]
			_cFile 	+= U_FORMAT(_xVarTmp,'XE',03)												// A | TRFID		- Codigo								(Pos.001 - C,03 		- 						)
			_xVarTmp	:= _aTipRef[_nX][02]					
			_cFile 	+= U_FORMAT(_xVarTmp,'XD',15)												// B | UNIDE 		- Descrição 							(Pos.002 - C,15 		- 						)
		
		Next
		
		// Gravação de Log de Processamento
		Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())
	
	Endif
	FWRITE(_nHandle,_cFile) // GRAVA TEXTO
	
	_cFile 	:= ''
	FCLOSE(_nHandle)
	RestArea(_aArea)

Return(Nil)