#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'

//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_ESTADOS
Geração Registro Estados
@author 	Carlos Eduardo Saturnino
@since 		13/09/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}, ${return_description}
@example	

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_ESTADOS( _cLocal, _cFileName, lJob )
	
	Local _cLFile
	Local _lPrim		:= .T.
	Local _cFile		:= ''
	Local _xVarTmp	:= ""
	Local _nHandle	:= 0
	Local _cEst		:= ""
	Local _aArea		:= GetArea()
		
	_cLFile  := _cLocal + _cFileName
	_nHandle :=	FCreate(_cLFile)

	If _nHandle == -1 
		If !lJob
			MsgAlert('Erro de gravação do arquivo no disco. Arquivo ' + _cFileName )
		Else
			Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Erro de gravação do arquivo no disco')
		Endif
	Else
		dbSelectArea("SX5")
		dbSetOrder(1)
		dbSeek(xFilial("SX5")+"12")
		While ! Eof().And. xFilial("SX5") == X5_FILIAL .And.	X5_TABELA == "12" 
			
			// Altero a nomenclatura de Estado EX para 
			// XX para compatibilizar com Solbase
			If	Substr(X5_CHAVE,1,2) == "EX"
				_cEst := "XX"
			Else
				_cEst := Substr(X5_CHAVE,1,2)
			Endif

			// Inclui a quebra de linha 
			If _lPrim 
				_lPrim := .F.
			Else
				_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
			Endif
			
			_cFile 	+= _cEst					//A | UFID 		- Código Estado 				(Pos.001 - C,2 	- "XX")
			_cEst		:= ''

			SX5->(dbSkip())

		End While
		Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Arquivo Gravado com sucesso as ' + Time())
	Endif
	
	SX5->(dbCloseArea())			
	FWRITE(_nHandle,_cFile) // GRAVA TEXTO

	_cFile := ''
	FCLOSE(_nHandle)
	RestArea(_aArea)

Return