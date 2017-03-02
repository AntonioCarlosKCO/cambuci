
#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_VENDEDOR
Geração Registro de Vendedores
@author 	Carlos Eduardo Saturnino
@since 		20/09/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}	, ${return_description}
@example	

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_VENDEDOR( _cLocal, _cFileName, lJob, _cVend )
	
	Local _cLFile
	Local _lPrim		:= .T.
	Local _cFile		:= ''
	Local _xVarTmp	:= ""
	Local _nHandle	:= 0
		
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
		dbSelectArea('SA3')
		dbSetOrder(1)
		dbGoTop()
		dbSeek(xFilial("SA3") + _cVend )
//		While ! SA3->(Eof()) .And. xFilial('SA3') == SA3->A3_FILIAL .And. SA3->A3_MSBLQL <> '1' .And. SA3->A3_COD == _cVend
		While ! SA3->(Eof()) .And. SA3->A3_MSBLQL <> '1' .And. SA3->A3_COD == _cVend // DJALMA BORGES 08/02/2017

			// Inclui a quebra de linha 
			If _lPrim 
				_lPrim := .F.
			Else
				_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
			Endif

			_xVarTmp	:= SA3->(A3_COD + ' - ' + A3_NREDUZ)										// Variável para Formatação
			_cFile 	+= U_FORMAT(_xVarTmp,'XD',30)												// A | VENNOM		- Nome do Vendedor					(Pos.001 - C,30 		- 						)
			_xVarTmp	:= SA3->A3_NOME					
			_cFile 	+= U_FORMAT(_xVarTmp,'XD',60)												// B | VENCOM 	- Contato								(Pos.031 - C,60 		- 						)
			_xVarTmp	:= SA3->A3_END
			_cFile 	+= U_FORMAT(_xVarTmp,'XD',60)												// C | VENEND 	- Endereço								(Pos.091 - C,60 		- 						)
			_xVarTmp	:= SA3->A3_BAIRRO
			_cFile 	+= U_FORMAT(_xVarTmp,'XD',20)												// D | VENBAI 	- Bairro								(Pos.151 - C,20		- 						)
			_xVarTmp	:= SA3->A3_CEP			
			_cFile 	+= U_FORMAT(_xVarTmp,'XD',08)												// E | VENCEP 	- Cep									(Pos.171 - N,8 		- 						)
			_xVarTmp	:= SA3->A3_MUN			
			_cFile 	+= U_FORMAT(_xVarTmp,'XD',20)												// F | VENMUN 	- Municipio							(Pos.179 - C,20 		- 						)
			_xVarTmp	:= SA3->A3_EST			
			_cFile 	+= U_FORMAT(_xVarTmp,'XD',02)												// G | VENUF 		- Estado (UF)							(Pos.199 - C,02 		- 						)
			_xVarTmp	:= SA3->('(' + Alltrim(A3_DDDTEL) + ')' + A3_TEL)		
			_cFile 	+= U_FORMAT(_xVarTmp,'XD',100)												// H | VENFON 	- Telefones							(Pos.201 - C,100 		- 						)
			_xVarTmp	:= SA3->A3_EMAIL			
			_cFile 	+= U_FORMAT(_xVarTmp,'XD',100)												// I | VENEML 	- Telefones							(Pos.301 - C,100 		- 						)						
			_cFile 	+= Replicate('0',08)															// J | VENMGMIN 	- Margem Minima						(Pos.401 - N,04,04 	- '00000000'			)
			_cFile		+= Replicate('0',14)															// K | VENVDMED 	- Venda Media Acumulada				(Pos.409 - N,12,02 	- '00000000000000'	)
			_cFile		+= Replicate('0',14)															// L | VENMGMED 	- Margem Media Acumulada				(Pos.423 - N,12,02 	- '00000000000000'	)
			_cFile		+= Replicate('0',14)															// M | VENVDAACU 	- Venda Acumulada						(Pos.437 - N,12,02 	- '00000000000000'	)
			_cFile		+= Replicate('0',14)															// N | VENMGACU 	- Margem Acumulada					(Pos.451 - N,12,02 	- '00000000000000'	)			
			_cFile		+= Replicate('0',08)															// O | VENMGNEG 	- Margem Minima do Negócio			(Pos.465 - N,04,04 	- '00000000'			)

			SA3->(dbSkip())

		EndDo
		
		// Gravação de Log de Processamento
		Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())
	
	Endif

	FWRITE(_nHandle,_cFile) // GRAVA TEXTO
	
	_cFile 	:= ''
	FCLOSE(_nHandle)

Return