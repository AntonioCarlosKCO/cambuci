#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_TABFPG()
Geração Registro de Formas de Pagamento
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
/*/User Function SB_TABFPG( _cLocal, _cFileName, lJob )
	
	Local _cLFile
	Local _lPrim		:= .T.
	Local _cFile		:= ''
	Local _xVarTmp	:= ""
	Local _nHandle	:= 0
	Local _aArea		:= GetArea()
	Local _aFormPg	:= {}
	Local _nX
	
	
	aAdd(_aFormPg,{"CAR", "CARTEIRA" , "02" })
	aAdd(_aFormPg,{"COB", "DUPLICATA", "04" })
		
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
		For _nX := 1 to Len(_aFormPg)
		
			// Inclui a quebra de linha 
			If _lPrim 
				_lPrim := .F.
			Else
				_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
			Endif

			// Inicio do Fluxo de Informações
			_xVarTmp	:= _aFormPg[_nX][01]
			_cFile 	+= U_FORMAT(_xVarTmp,'XE',03)												// A | FPGID		- Codigo								(Pos.001 - C,03 		- 						)
			_xVarTmp	:= _aFormPg[_nX][02]					
			_cFile 	+= U_FORMAT(_xVarTmp,'XD' ,30)												// B | FPDES 		- Descrição 							(Pos.004 - C,30 		- 						)
			_xVarTmp	:= _aFormPg[_nX][03]															// C | FPGGEXG 	- Grau de Exigência					(Pos.034 - C,02 		- 						)
		
		Next
		
		// Gravação de Log de Processamento
		Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())
	
	Endif
	FWRITE(_nHandle,_cFile) // GRAVA TEXTO
	
	_cFile 	:= ''
	FCLOSE(_nHandle)
	RestArea(_aArea)

Return(Nil)