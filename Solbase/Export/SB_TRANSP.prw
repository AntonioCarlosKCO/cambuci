#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'

//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_TRANSP
Geração Registro Transportadoras
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
/*/User Function SB_TRANSP( _cLocal, _cFileName, lJob )
	
	Local _cLFile
	Local _lPrim		:= .T.
	Local _cFile		:= ''
	Local _xVarTmp	:= ""
	Local _nHandle	:= 0
	Local _aArea		:= GetArea()
		
	_cLFile  := _cLocal + _cFileName
	_nHandle := FCreate(Upper(_cLFile))

	If _nHandle == -1 
		If !lJob
			MsgAlert('Erro de gravação do arquivo no disco. Arquivo ' + _cFileName )
		Else
			Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Erro de gravação do arquivo no disco')
		Endif
	Else
		dbSelectArea("SA4")
		dbSetOrder(1)
		dbGoTop()
//		While ! Eof().And. xFilial("SA4") == A4_FILIAL 
		While ! Eof() // DJALMA BORGES 08/02/2017

			// Inclui a quebra de linha 
			If _lPrim 
				_lPrim := .F.
			Else
				_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
			Endif
			
			_xVarTmp	:= A4_COD
			_cFile 	+= U_FORMAT(_xVarTmp,'ZC',8)					// A | TRAID 		- Cofigo		(Pos.001 - N,08 	- 	)
			_cFile 	+= SA4->A4_NOME									// B | TRANOM 	- Nome			(Pos.009 - C,40 	- 	)
			
			SA4->(dbSkip())
		
		End While
		SA4->(dbCloseArea())
		Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Arquivo Gravado com sucesso as ' + Time())
	Endif
			
	FWRITE(_nHandle,_cFile) // GRAVA TEXTO

	_cFile 	:= ''
	FCLOSE(_nHandle)
	RestArea(_aArea)

Return
