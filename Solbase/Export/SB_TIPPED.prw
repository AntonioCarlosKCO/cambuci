#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'

//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_TIPPED
Geração Registro Tipo de Pedido de Vendas
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
/*/User Function SB_TIPPED( _cLocal, _cFileName, lJob )
	
	Local _cLFile
	Local _cFile		:= ''
	Local _xVarTmp	:= ""
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
		_cFile 	:= 'PFV'											// A | TPDID 		- Codigo								(Pos.001 - C,03 	- 			)
		_cFile 	+= 'Pedido-FORCA VENDAS - C. Metal'			// B | TPDDES 	- Descrição							(Pos.004 - C,30 	- 			)
		_cFile 	+= Space(01)										// C | TPDTRB 	- Calcula Trib. Item					(Pos.034 - C,01 	- S/N		)
		_cFile 	+= 'N'												// D | TPDEQD 	- Exige Estoque Disp.?				(Pos.035 - C,01 	- S/N		)
		_cFile 	+= '2' + Space(01)								// E | TPDLISP 	- Regra p/ Listar Preço em Tela		(Pos.036 - C,02 	- 1-2-3-4	)
		_cFile 	+= 'S'												// F | TPDDCTUL 	- Descto. s/ Unit. Liq.				(Pos.038 - C,01 	- S/N		)
		_cFile 	+= 'S'												// G | TPDTMGM 	- Trat. Calc. Margem					(Pos.039 - C,01 	- S/N		)
		_cFile 	+= 'VDF=NE;PLP;IPL;R1L;TPF=PCEN;EML=CB01;DCE'	// H | TPDPDIV 	- Parâmetros Diversos				(Pos.040 - C,40 	- 			)			
		_cFile 	+= StrZero(0,10)									// I | TPDVMIN 	- Vl. Minimo do Pedido				(Pos.080 - N,08,2	- 			)
		_cFile 	+= Space(01)										// *** Não está no lay out, incluido para compatibilizar com o arquivo de modelo
		_cFile 	+= 'N'												// J | TPDBNF		- Indicador de Bonificação			(Pos.091 - C,01 	- 			)
		_cFile 	+= 'N'												// K | TPDDIFICM	- Diferença de ICMS					(Pos.092 - C,01 	- S/N		)
		
		Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Arquivo Gravado com sucesso as ' + Time())
	Endif
			
	FWRITE(_nHandle,_cFile) // GRAVA TEXTO

	_cFile 	:= ''
	FCLOSE(_nHandle)
	RestArea(_aArea)

Return