#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_GRITEM()
Gera��o Registro Grupo de Produtos
@author 	Carlos Eduardo Saturnino
@since 		04/10/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para grava��o do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}, ${return_description}
@example	

@see 		(links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_GRITEM( _cLocal, _cFileName, lJob )
	
	Local _cLFile
	Local _lPrim		:= .T.
	Local _cFile		:= ''
	Local _xVarTmp	:= ''
	Local _nHandle	:= 0
	Local _aArea		:= GetArea()
		
	_cLFile  := _cLocal + _cFileName
	_nHandle := FCreate(_cLFile)

	If _nHandle == -1 
		If !lJob
			MsgAlert('Erro de grava��o do arquivo no disco. Arquivo ' + _cFileName )
		Else
			Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Erro de grava��o do arquivo no disco')
		Endif
	Else
		dbSelectArea("SBM")
		dbSetOrder(1)		// BM_FILIAL + BM_GRUPO
		dbGoTop()
//		While ! Eof() .And. xFilial("SBM") == SBM->BM_FILIAL
		While ! Eof() // DJALMA BORGES 08/02/2017
			
			// Valido se o c�digo do Grupo est� preenchido com 3 d�gitos
			If Len(Alltrim(SBM->BM_GRUPO)) <= 3 
			
				// Inclui a quebra de linha 
				If _lPrim 
					_lPrim := .F.
				Else
					_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
				Endif
				
				// Inicio do Fluxo do Relat�rio
				_cFile 	+= AllTrim(SBM->BM_GRUPO)									// A | GRID 		- Codigo								(Pos.001 - C,03 	- 			)
				_cFile 	+= SUBSTR(SBM->BM_DESC,1,15)					// B | GRIDES 	- Descri��o							(Pos.004 - C,15	- 			)
								
				SBM->(dbSkip())
			Else
				If !lJob
					Aviso("O C�digo do Grupo " + SBM->BM_GRUPO + " - " + SBM->BM_DESC + " possui "+ Alltrim(Str(Len(SBM->BM_GRUPO))) + " d�gitos, efetue a altera��o para 3 d�gitos. O C�digo n�o ser� importado",{"OK"},2)
				Else
					Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. O Codigo '+ SBM->BM_GRUPO + ' possui '+ Alltrim(Str(Len(SBM->BM_GRUPO))) +' digitos. O tamanho maximo para esse campo e 3. O registro nao foi importado ' + Time())
				Endif
				SBM->(dbSkip())
			Endif
		EndDo
	Endif
	SBM->(dbCloseArea())

	If !Empty(_cFile)
		FWRITE(_nHandle,_cFile) // GRAVA TEXTO
		Conout( _cFileName + Space( 17 - Len(_cFileName) ) + '. Arquivo Gravado com sucesso as ' + Time())
		FCLOSE(_nHandle)
	Else
		FERASE(_cLFile)			// Apaga o arquivo do caminho especificado			 
		Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Arquivo '+ _cFileName + ' sem registros para gravacao. O arquivo nao foi gerado ' + Time())		
	Endif
	
	_cFile 	:= ''
	
	RestArea(_aArea)

Return