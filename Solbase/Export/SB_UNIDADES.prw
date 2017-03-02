#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_UNIDADES()
Geração Registro de Unidades de Medida
@author 	Carlos Eduardo Saturnino
@since 		20/09/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}, ${return_description}
@example	

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_UNIDADES( _cLocal, _cFileName, lJob )
	
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
		dbSelectArea('SAH')
		dbSetOrder(1)
		dbGoTop()
//		While ! SAH->(Eof()) .And. xFilial('SAH') == SAH->AH_FILIAL
		While ! SAH->(Eof())  // DJALMA BORGES 08/02/2017

			// Inclui a quebra de linha 
			If _lPrim 
				_lPrim := .F.
			Else
				_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
			Endif

			_cFile 	+= SAH->AH_UNIMED																// A | UNIID		- Código da Unidade de Medida		(Pos.001 - C,02 		- 						)
			_xVarTmp	:= SAH->AH_UMRES					
			_cFile 	+= U_FORMAT(_xVarTmp,'XD',15)												// B | UNIDE 		- Descrição Portugues				(Pos.002 - C,15 		- 						)

			SAH->(dbSkip())

		EndDo
		
		// Fecha a Tabela Unidade de Medida
		SAH->(dbCloseArea())
		
		// Gravação de Log de Processamento
		Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())
	
	Endif
	FWRITE(_nHandle,_cFile) // GRAVA TEXTO
	
	_cFile 	:= ''
	FCLOSE(_nHandle)
	RestArea(_aArea)

Return