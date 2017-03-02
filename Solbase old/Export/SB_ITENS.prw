#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_ITENS()
Geração Registro Produtos
@author 	Carlos Eduardo Saturnino
@since 		20/10/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}, ${return_description}
@example	

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_ITENS( _cLocal, _cFileName, lJob )
		
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
		dbSelectArea('SB1')
		dbSetOrder(1)
		dbGoTop()
		While ! SB1->(Eof()) .And. xFilial('SB1') == SB1->B1_FILIAL 
			If SB1->B1_MSBLQL <> '1' .And. SB1->B1_TIPO == "ME"
				// Inclui a quebra de linha 
				If _lPrim 
					_lPrim := .F.
				Else
					_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
				Endif	
				
				// Fluxo de Informações do Arquivo
				_xVarTmp	:= Substr(SB1->B1_XANTIGO,1,8)
				_cFile 		+= U_FORMAT(_xVarTmp,'XE',08) 
				_xVarTmp	:= SB1->B1_DESC
				_cFile 		+= U_FORMAT(_xVarTmp,'XD',90)
				_cFile 		+= SB1->B1_COD
				_cFile 		+= Substr(SB1->B1_GRUPO,1,3)
				_cFile 		+= SB1->B1_XSUBGRU
				_cFile 		+= SB1->B1_XMARCA
				_cFile 		+= SB1->B1_XLINHA
				_cFile 		+= Space(03)
				_cFile 		+= Space(03)
				_cFile		+= Posicione("SYD",1,xFilial("SYD") + SB1->B1_POSIPI,"YD_XREFSB")
				_cFile		+= SB1->B1_UM
				_xVarTmp	:= Alltrim(StrTran(Str(SB1->B1_PESO),".","")) + "0"
				_cFile		+= U_FORMAT(_xVarTmp,'ZC',11)
				_cFile		+= "0"
				_cFile		+= SB1->B1_UM			 						
				_xVarTmp	:= SB1->B1_QE
				_cFile		+= U_FORMAT(_xVarTmp,'ZC',11)
				_cFile		+= "S"
				_cFile		+= Replicate("0",5)
				
				
				FWRITE(_nHandle,_cFile) // GRAVA TEXTO
				_cFile		:= ""
			EndIf
			
			SB1->(dbSkip())
		
		EndDo
		// Gravação de Log de Processamento
		Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())
	Endif

	
	_cFile 	:= ''
	FCLOSE(_nHandle)
	SB1->(dbCloseArea())
	RestArea(_aArea)

Return