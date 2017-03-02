#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_ITEREFER()
Geração Registros de referências dos produtos
@author 	Carlos Eduardo Saturnino
@since 		24/10/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}, ${return_description}
@example	

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_ITEREFER( _cLocal, _cFileName, lJob )
		
	Local _cLFile
	lOCAL _nSeq		:= 0
	Local _lPrim		:= .T.
	Local _cFile		:= ''
	Local _xVarTmp	:= ""
	Local _nHandle	:= 0
	Local _aArea		:=	 GetArea()
		
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
		dbSelectArea('SB1')
		dbSetOrder(1)
		dbGoTop()
//		While ! SB1->(Eof()) .And. xFilial('SB1') == SB1->B1_FILIAL 
		While ! SB1->(Eof()) // DJALMA BORGES 08/02/2017
			If SB1->B1_MSBLQL <> '1' .And. SB1->B1_TIPO == "ME"
				// Inclui a quebra de linha 
				If _lPrim 
					_lPrim := .F.
				Else
					_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
				Endif	
				
				// Fluxo de Informações do Arquivo
				_xVarTmp	:= SB1->B1_COD
				_cFile 	+= U_FORMAT(_xVarTmp,'XE',15) 
				_xVarTmp	:= "5"
				_cFile 	+= U_FORMAT(_xVarTmp,'ZC',03)
				_xVarTmp	:= SB1->B1_XANTIGO
				_cFile 	+= U_FORMAT(_xVarTmp,'XE',08)
				_xVarTmp	:= 0
				_cFile 	+= U_FORMAT(_xVarTmp,'ZN',03)
				_xVarTmp	:= SB1->B1_DESC
				_cFile 	+= U_FORMAT(_xVarTmp,'XE',40)
				_cFile 	+= U_FORMAT(_xVarTmp,'XE',40)
			
				FWRITE(_nHandle,_cFile) // GRAVA TEXTO
				_cFile		:= ""

				dbSelectArea('ZZA')
				dbSetOrder(1)
				If ZZA->(DbSeek(xFilial("ZZA")+SB1->B1_COD))
					While ! ZZA->(Eof()) .And. xFilial('ZZA')+SB1->B1_COD == ZZA->ZZA_FILIAL+ZZA->ZZA_XCOD 
						
						/*/ Preenche o campo ZZA->ZZA_REFSSQ
						If ZZA-> ZZA_REFSSQ = 0 
							RecLock("ZZA", .F.)
							_nSeq := _nSeq + 1
							ZZA->ZZA_REFSSQ := _nSeq
							MsUnlock()
						Endif */
						
						// Inclui a quebra de linha 
						If _lPrim 
							_lPrim := .F.
						Else
							_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
						Endif	
						
						// Fluxo de Informações do Arquivo
						_xVarTmp	:= ZZA->ZZA_XCODRF
						_cFile 	+= U_FORMAT(_xVarTmp,'XE',15) 
						_xVarTmp	:= ZZA->ZZA_XTPREF
						_cFile 	+= U_FORMAT(_xVarTmp,'ZC',03)
						_xVarTmp	:= SB1->B1_XANTIGO
						_cFile 	+= U_FORMAT(_xVarTmp,'XE',08)
						_xVarTmp	:= ZZA->ZZA_REFSSQ
						_cFile 	+= U_FORMAT(_xVarTmp,'ZN',03)
						_xVarTmp	:= ZZA->ZZA_XDESCRI
						_cFile 	+= U_FORMAT(_xVarTmp,'XE',40)
						_cFile 	+= U_FORMAT(_xVarTmp,'XE',40)
			
						FWRITE(_nHandle,_cFile) // GRAVA TEXTO
						_cFile		:= ""
						
						ZZA->(dbSkip())
					
					EndDo
				EndIf
			EndIf
			
			SB1->(dbSkip())
		
		EndDo		

		// Gravação de Log de Processamento
		Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())
	Endif

	
	_cFile 	:= ''
	FCLOSE(_nHandle)
	ZZA->(dbCloseArea())
	RestArea(_aArea)

Return