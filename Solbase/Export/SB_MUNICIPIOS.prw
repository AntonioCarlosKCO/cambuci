#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'

//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_MUNICIPIOS
Geração Registro Municipios
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
/*/User Function SB_MUNICIPIOS( _cLocal, _cFileName, lJob )
	
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
		dbSelectArea("CC2")
		dbSetOrder(3)
		dbGoTop()
//		While ! Eof().And. xFilial("CC2") == CC2_FILIAL 
		While ! Eof() // DJALMA BORGES 08/02/2017
			
			// Inclui a quebra de linha 
			If _lPrim 
				_lPrim := .F.
			Else
				_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
			Endif
			
			// Inicio do Fluxo de Informações
			//_xVarTmp	:= CC2->CC2_CODMUN
			_xVarTmp	:= CC2->(RECNO())
			_cFile 	+= U_FORMAT(_xVarTmp,'ZC',8)					// A | MUNID 		- Código Municipio		(Pos.001 - N,08 	- 	)
			_cFile 	+= Substr(CC2->CC2_MUN,1,30)					// B | MUNDES 	- Descrição				(Pos.009 - C,30 	- 	)
			_cFile 	+= CC2->CC2_EST									// C | MUNUF 		- Estado					(Pos.040 - C,02 	- 	)
			//_cFile 	+= Repl('0',3)									// D | MUNETQLOC	- Loc. Estoque			(Pos.043 - N,03 	- 	)														 						
		
			CC2->(dbSkip())
		
		End While
		CC2->(dbCloseArea())
		Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Arquivo Gravado com sucesso as ' + Time())
	Endif
			
	FWRITE(_nHandle,_cFile) // GRAVA TEXTO

	_cFile 	:= ''
	FCLOSE(_nHandle)
	RestArea(_aArea)

Return