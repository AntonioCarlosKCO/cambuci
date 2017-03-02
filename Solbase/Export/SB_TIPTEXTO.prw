#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_TIPTEXTO
Geração Registro Tipo de Texto
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
/*/User Function SB_TIPTEXTO( _cLocal, _cFileName, lJob )
	
	Local _cLFile, _n
	Local _lPrim		:= .T.
	Local _aTipTxt	:= {{'IAP','Aplicacao'},{'OBS','Obs Gerais'}}
	Local _cFile		:= ''
	Local _xVarTmp	:= ""
	Local _nHandle	:= 0
	Local _aArea		:= GetArea()
		
	_cLFile  := _cLocal + _cFileName
	_nHandle := FCreate(_cLFile)

	If _nHandle == -1 
		If !lJob
			MsgAlert('Erro de gravação do arquivo no disco. Arquivo ' + _cFileName )
		Else
			Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Erro de gravação do arquivo no disco')
		Endif
	Else
		For _n := 1 To Len(_aTipTxt)

			// Inclui a quebra de linha 
			If _lPrim 
				_lPrim := .F.
			Else
				_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
			Endif
			
			_cFile 	+= _aTipTxt[_n][01]															// A | TXTID 		- Codigo								(Pos.001 - N,08 	- 			)
			_cFile 	+= _aTipTxt[_n][02] + Space(15 - Len(_aTipTxt[_n][02]))					// B | TXTDES 	- Descrição							(Pos.004 - C,15 	- 			)
			
		Next _n
		Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Arquivo Gravado com sucesso as ' + Time())
	Endif

	FWRITE(_nHandle,_cFile) // GRAVA TEXTO

	_cFile 	:= ''
	FCLOSE(_nHandle)
	RestArea(_aArea)

Return