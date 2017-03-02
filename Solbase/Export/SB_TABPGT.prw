#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_TABPGT()
Geração Registro Tipo Condições de Pagamento
@author 	Carlos Eduardo Saturnino
@since 		03/10/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}, ${return_description}
@example	

@see 		(links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_TABPGT( _cLocal, _cFileName, lJob )
	
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
			MsgAlert('Erro de gravação do arquivo no disco. Arquivo ' + _cFileName )
		Else
			Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Erro de gravação do arquivo no disco')
		Endif
	Else
		dbSelectArea("SE4")
		dbSetOrder(1)		// E4_FILIAL + E4_CODIGO
		dbGoTop()
//		While ! Eof() .And. xFilial("SE4") == SE4->E4_FILIAL .And. SE4->E4_MSBLQL == '2'
		While ! Eof() .And. SE4->E4_MSBLQL == '2' // DJALMA BORGES 08/02/2017
		
			// Inclui a quebra de linha 
			If _lPrim 
				_lPrim := .F.
			Else
				_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
			Endif

			_xVarTmp	:= E4_CODIGO
			_cFile 	:= U_FORMAT(_xVarTmp,'ZC',6)					// A | PGID 		- Codigo								(Pos.001 - N,06 	- 			)
			_cFile 	+= SPACE(03)										// B | PGTFPG 	- Chave com TFPG (Enviar em branco)(Pos.007 - C,03 	- 			)
			_xVarTmp 	:= E4_DESCRI
			_cFile 	+= U_FORMAT(_xVarTmp,'XD',40)					// B | PGTDES 	- Descrição							(Pos.009 - C,40 	- 			)
			_cFile 	+= '01/01/2003'									// C | PGTDTINI 	- Data de Vigencia Inicial			(Pos.050 - C,10 	- 			)
			_cFile 	+= '31/12/2099'									// D | PGTDTFIM	- Data de Vigencia Final				(Pos.060 - C,10 	- 			)			
			_xVarTmp 	:= E4_INFER
			_cFile 	+= U_FORMAT(_xVarTmp,'ZC',13)					// E | PGTVMIN	- Valor Mínimo do Pedido				(Pos.070 - N,11,2	- 			)
			_cFile 	+= Space(04)										// F | PGTPZM		- Prazo Medio (Mandar em Branco)	(Pos.082 - C,04	- 			)
			_cFile 	+= Space(01)										// G | PGTCLI		- Trata por Cliente(Mandar em Brco)(Pos.086 - C,01	- 			)
			_cFile 	+= Space(04)										// H | PGTORD		- Ordem de Tela (Mandar em Branco)	(Pos.087 - C,04	- 			)
			
			SE4->(dbSkip())
		EndDo
		Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Arquivo Gravado com sucesso as ' + Time())
	Endif
	SE4->(dbCloseArea())

	FWRITE(_nHandle,_cFile) // GRAVA TEXTO

	_cFile 	:= ''
	FCLOSE(_nHandle)
	RestArea(_aArea)

Return