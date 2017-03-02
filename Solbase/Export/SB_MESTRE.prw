#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'

//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_REGMESTRE()
Geração Registro Mestre
@author 	Carlos Eduardo Saturnino
@since 		09/09/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}, ${return_description}
@example	Conteúdo FIXO: NNNNN01/01/202000003001100000000000000000000XXX

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function	SB_MESTRE( _cLocal, _cFileName, lJob )
	
	Local _cLFile
	Local _lPrim		:= .T.
	Local _cFile		:= ''
	Local _xVarTmp	:= ""
	Local _nHandle	:= 0
	Local _nCount		:= 0
	Local _cHist		:= ""
		
	_cLFile  := _cLocal + _cFileName
	_nHandle :=	FCreate(_cLFile)

	If _nHandle == -1 
		If !lJob
			MsgAlert('Erro de gravação do arquivo no disco. Arquivo ' + _cFileName )
		Else
			Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Erro de gravação do arquivo no disco')
		Endif
	Else
		
		// Inclui a quebra de linha 
		If _lPrim 
			_lPrim := .F.
		Else
			_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
		Endif
		
		// Inicio do Fluxo de informações		
		_cFile 	+= "N" 					 				//A | MTRMGM 		- Calcula Margem 				(Pos.001 - C,1 	- "S/N")
		_cFile 	+= "N"										//B | MTRPRETEL 	- Exibe Precos Item 			(Pos.002 - C,1	- "S/N")
		_cFile 	+= "N"										//C | MTRDEPURA 	- Modo Depuração	 			(Pos.003 - C,1 	- "S/N")
		_cFile 	+= "N"										//D | MTRCOMPIS 	- Subtrai Pis na BaseCom		(Pos.004 - C,1 	- "S/N")
		_cFile 	+= "N"										//E | MTRCOMCOF 	- Subtrai Cofins na BCom		(Pos.005 - C,1 	- "S/N")
		_cFile 	+= "01/01/2020"							//F | MTRDLM	 	- Data Limite sem At. Dados	(Pos.006 - D,10 	- "01/01/2020")			
		_cFile 	+= "00003"									//G | MTRNPDPEN 	- Num. Pedidos Pendentes		(Pos.016 - N,5 	- 00003)
		_cFile 	+= "001"									//H | MTRLOCFAT 	- Local de Faturamento		(Pos.021 - N,3 	- 001)
		_cFile 	+= "10000000000000000000"				//I | MTRLIC	 	- Módulos Licenciados		(Pos.024 - C,20	- 10000000000000000000)
		_cFile 	+= "0XXX"									//J | MTRDIV	 	- Diversos Indicadores		(Pos.044 - C,30	- "0XXX")
		//_cFile 	+= Space(30)								//K | MTRPCALCMGM	- Divs. Indic. Calc. Mrgm	(Pos.074 - C,30	- "")		
		
		Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Arquivo Gravado com sucesso as ' + Time())
	Endif
		
	FWRITE(_nHandle,_cFile) // GRAVA TEXTO

	_cFile := ''
	FCLOSE(_nHandle)

Return