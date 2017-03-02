#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_CLIFONES
Geração Endereços dos Clientes (CLIENDER)
@author 	Rogério Doms
@since 		27/10/2016
@version 	1.0
@param 		_cLocal	    , ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}   , ${return_description}
@example

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_CLIFONES( _cLocal, _cFileName, lJob, _cVend )

	Local _cLFile   := ''
	Local _cFile		:= ''
	Local _xVarTmp	:= ''
	Local _cQry		:= ''
	Local _nLocFat  	:= '0'
	Local _nHandle	:= 0
	Local _lPrim		:= .T.
	Local cAliasQry 	:= GetNextAlias()
	Local cAliasSU5 	:= GetNextAlias()
	Local cAliasAGB 	:= GetNextAlias()
	Local _cCpoSX3 	:= "AGB_TIPO"
	Local _cX3CBOX  	:= ""
	Local _cCampo   	:= ""
	Local _cTipo    	:= "TCO"
	Local _aX3COX   	:= {}

	Local _aArea	:= GetArea()

	// Seleciona os Tipos Telefone da Tabela TELEFONES X ENTIDADES (AGB)
	dbSelectArea("SX3")
	SX3->(dbSetOrder(02))
	If SX3->(dbSeek(_cCpoSX3))

		_cX3CBOX := SX3->X3_CBOX

		While !Empty(_cX3CBOX)
		
			i := AT(";",_cX3CBOX)
		
			If i > 0
		
				_cCampo := Left(_cX3CBOX,i-1)
		
				If Substr(_cCampo,1,1) == "1"
					_cTipo := "TCO"
				ElseIf Substr(_cCampo,1,1) == "2"
					_cTipo := "TRE"
				ElseIf Substr(_cCampo,1,1) == "3"
					_cTipo := "FAX"
				ElseIf Substr(_cCampo,1,1) == "4"
					_cTipo := "FAX"
				ElseIf Substr(_cCampo,1,1) == "5"
					_cTipo := "CEL"
				Else
					_cTipo := "TCO"
				EndIf
				
				aAdd(_aX3COX,_cTipo)
		
				_cX3CBOX := Substr(_cX3CBOX,i+1)
		
			Else
			
				_cCampo := _cX3CBOX

				If Substr(_cCampo,1,1) == "1"
					_cTipo := "TCO"
				ElseIf Substr(_cCampo,1,1) == "2"
					_cTipo := "TRE"
				ElseIf Substr(_cCampo,1,1) == "3"
					_cTipo := "FAX"
				ElseIf Substr(_cCampo,1,1) == "4"
					_cTipo := "FAX"
				ElseIf Substr(_cCampo,1,1) == "5"
					_cTipo := "CEL"
				Else
					_cTipo := "TCO"
				EndIf
			
				aAdd(_aX3COX,_cTipo)
			
				_cX3CBOX := ""
		
			EndIf
	
		EndDo

	EndIf
	
	//Nome do Arquivo
	_cLFile  := _cLocal + _cFileName
	_nHandle := FCreate(_cLFile)

	// Gravação de Log de Erro
	If _nHandle == -1

		If !lJob
			MsgAlert('Erro de gravação do arquivo no disco. Arquivo ' + _cFileName )
		Else
			Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Erro de gravação do arquivo no disco')
		Endif

	Else

		// Query para definição 		
		_cQry := "SELECT A1_VEND, A1_COD, A1_LOJA, A1_NOME, A1_DDD, A1_TEL, A1_EMAIL "	+ CHR(13) + CHR(10)
		_cQry += "FROM " + RetSqlName("SA1") + " SA1 "									+ CHR(13) + CHR(10)
//		_cQry += "WHERE SA1.A1_FILIAL 	= '" + xFilial("SA1") + "' "					+ CHR(13) + CHR(10)
//		_cQry += "  AND SA1.A1_VEND 	= '" + _cVend + "' "							+ CHR(13) + CHR(10)
		_cQry += "WHERE SA1.A1_VEND 	= '" + _cVend + "' "							+ CHR(13) + CHR(10) // DJALMA BORGES 08/02/2017
		_cQry += "  AND SA1.A1_MSBLQL 	<> '1' "										+ CHR(13) + CHR(10)
		_cQry += "  AND SA1.D_E_L_E_T_	<> '*' "										+ CHR(13) + CHR(10)
		_cQry += "ORDER BY A1_VEND, A1_COD, A1_LOJA "									+ CHR(13) + CHR(10)
	
		MEMOWRIT("\SB_CLIFONES.SQL",_cQry)
		cQuery := ChangeQuery(_cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
				
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		While ! (cAliasQry)->(Eof())
		
			// Telefone no Cadastro de Cliente Preenchido
			If !Empty((cAliasQry)->A1_TEL)
				_cTelefone := IIf( !Empty((cAliasQry)->A1_DDD), Alltrim((cAliasQry)->A1_DDD) + (cAliasQry)->A1_TEL , (cAliasQry)->A1_TEL )
				_cTelefone := U_FORMAT(_cTelefone,'XD',40)
				// Fluxo de Informações do Arquivo
				_cFile := GRFILE( (cAliasQry)->(A1_COD + A1_LOJA) , (cAliasQry)->A1_LOJA , "TCO" , _cTelefone )
			EndIf
		
			//EMAIL no Cadastro de Cliente Preenchido
			If !Empty((cAliasQry)->A1_EMAIL)
				_cEMail := U_FORMAT((cAliasQry)->A1_EMAIL,'XD',40)
			// Fluxo de Informações do Arquivo
				_cFile += GRFILE( (cAliasQry)->(A1_COD + A1_LOJA) , (cAliasQry)->A1_LOJA , "EML" , _cEMail )
			Endif
		
			// Query para definição dos CONTATOS
			_cQry := "SELECT U5_CODCONT, U5_CONTAT, U5_DDD, U5_FONE, U5_CELULAR, U5_FAX, "	+ CHR(13) + CHR(10)
			_cQry += "       U5_FCOM1, U5_FCOM2, U5_EMAIL, U5_XXCOM1, U5_XXFAX "       		+ CHR(13) + CHR(10)
			_cQry += "FROM " + RetSqlName("SU5") + " SU5 "									+ CHR(13) + CHR(10)
			_cQry += "WHERE SU5.U5_FILIAL 	= '" + xFilial("SU5") + "' "					+ CHR(13) + CHR(10)
			_cQry += "  AND SU5.U5_CODCONT 	= '" + (cAliasQry)->(A1_COD) + "' "				+ CHR(13) + CHR(10)
			_cQry += "  AND SU5.D_E_L_E_T_	<> '*' "										+ CHR(13) + CHR(10)
			_cQry += "ORDER BY U5_CODCONT "													+ CHR(13) + CHR(10)
	
			cQuery := ChangeQuery(_cQry)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSU5,.F.,.T.)
				
			dbSelectArea(cAliasSU5)
			(cAliasSU5)->(dbGoTop())
			While !(cAliasSU5)->(Eof())

				// FONE do Contato
				If !Empty((cAliasSU5)->U5_FONE)
					_cTelefone := IIf( !Empty((cAliasSU5)->U5_DDD), Alltrim((cAliasSU5)->U5_DDD) + (cAliasSU5)->U5_FONE , (cAliasSU5)->U5_FONE )
					_cTelefone := U_FORMAT(_cTelefone,'XD',40)
					// Fluxo de Informações do Arquivo
					_cFile += GRFILE((cAliasQry)->(A1_COD + A1_LOJA), (cAliasQry)->A1_LOJA , "TCO", _cTelefone )
				Endif

				// CELULAR do Contato
				If !Empty((cAliasSU5)->U5_CELULAR)
					_cCelular := U_FORMAT((cAliasSU5)->U5_CELULAR,'XD',40)
					// Fluxo de Informações do Arquivo
					_cFile += GRFILE((cAliasQry)->(A1_COD + A1_LOJA), (cAliasQry)->A1_LOJA , "CEL", _cCelular )
				Endif

				// FAX do Contato
				If !Empty((cAliasSU5)->U5_FAX)
					_cFax := U_FORMAT((cAliasSU5)->U5_FAX,'XD',40)
					// Fluxo de Informações do Arquivo
					_cFile += GRFILE((cAliasQry)->(A1_COD + A1_LOJA), (cAliasQry)->A1_LOJA , "FAX", _cFax )
				Endif

				// TEL COMERCIAL 1 do Contato
				If !Empty((cAliasSU5)->U5_FCOM1)
					_cTelefone := IIf( !Empty((cAliasSU5)->U5_DDD), Alltrim((cAliasSU5)->U5_DDD) + (cAliasSU5)->U5_FCOM1 , (cAliasSU5)->U5_FCOM1 )
					_cTelefone := U_FORMAT(_cTelefone,'XD',40)
					// Fluxo de Informações do Arquivo
					_cFile += GRFILE((cAliasQry)->(A1_COD + A1_LOJA), (cAliasQry)->A1_LOJA , "TCO", _cTelefone )
				Endif
			
				// TEL COMERCIAL 2 do Contato
				If !Empty((cAliasSU5)->U5_FCOM2)
					_cTelefone := IIf( !Empty((cAliasSU5)->U5_DDD), Alltrim((cAliasSU5)->U5_DDD) + (cAliasSU5)->U5_FCOM2 , (cAliasSU5)->U5_FCOM2 )
					_cTelefone := U_FORMAT(_cTelefone,'XD',40)
					// Fluxo de Informações do Arquivo 
					_cFile += GRFILE((cAliasQry)->(A1_COD + A1_LOJA), (cAliasQry)->A1_LOJA , "TCO", _cTelefone )
				Endif

				// EMAIL do Contato
				If !Empty((cAliasSU5)->U5_EMAIL)
					_cEMail := U_FORMAT((cAliasSU5)->U5_EMAIL,'XD',40)
				// Fluxo de Informações do Arquivo
					_cFile += GRFILE((cAliasQry)->(A1_COD + A1_LOJA), (cAliasQry)->A1_LOJA , "EML", _cEMail )
				Endif
			
				// FONE do Contato
				If !Empty((cAliasSU5)->U5_XXCOM1)
					_cTelefone := IIf( !Empty((cAliasSU5)->U5_DDD), Alltrim((cAliasSU5)->U5_DDD) + (cAliasSU5)->U5_XXCOM1 , (cAliasSU5)->U5_XXCOM1 )
					_cTelefone := U_FORMAT(_cTelefone,'XD',40)
					// Fluxo de Informações do Arquivo
					_cFile += GRFILE((cAliasQry)->(A1_COD + A1_LOJA), (cAliasQry)->A1_LOJA , "TCO", _cTelefone )
				Endif

				// FAX do Contato
				If !Empty((cAliasSU5)->U5_XXFAX)
					_cTelefone := IIf( !Empty((cAliasSU5)->U5_DDD), Alltrim((cAliasSU5)->U5_DDD) + (cAliasSU5)->U5_XXFAX , (cAliasSU5)->U5_XXFAX )
					_cTelefone := U_FORMAT(_cTelefone,'XD',40)
					// Fluxo de Informações do Arquivo
					_cFile += GRFILE((cAliasQry)->(A1_COD + A1_LOJA), (cAliasQry)->A1_LOJA , "FAX", _cTelefone )
				Endif
			
				// Query para definição dos TELEFONE X ENTIDADES
				_cQry := "SELECT AGB_CODIGO, AGB_ENTIDA, AGB_CODENT, AGB_TIPO, AGB_DDD, AGB_TELEFO "	+ CHR(13) + CHR(10)
				_cQry += "FROM " + RetSqlName("AGB") + " AGB "											+ CHR(13) + CHR(10)
				_cQry += "WHERE AGB.AGB_FILIAL 	= '" + xFilial("AGB") + "' "							+ CHR(13) + CHR(10)
				_cQry += "  AND AGB.AGB_CODIGO 	= '" + (cAliasSU5)->(U5_CODCONT) + "' "					+ CHR(13) + CHR(10)
				_cQry += "  AND AGB.D_E_L_E_T_	<> '*' "												+ CHR(13) + CHR(10)
				_cQry += "ORDER BY AGB_CODIGO "															+ CHR(13) + CHR(10)
	
				cQuery := ChangeQuery(_cQry)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAGB,.F.,.T.)
				
				dbSelectArea(cAliasAGB)
				(cAliasAGB)->(dbGoTop())
				While !(cAliasAGB)->(Eof())

					// Telefones
					If !Empty((cAliasAGB)->AGB_TELEFO)
						_cTelefone := IIf( !Empty((cAliasAGB)->AGB_DDD), Alltrim((cAliasAGB)->AGB_DDD) + (cAliasAGB)->AGB_TELEFO , (cAliasAGB)->AGB_TELEFO )
						_cTelefone := U_FORMAT(_cTelefone,'XD',40)
						_cTipo     := _aX3COX[Val((cAliasAGB)->(AGB_TIPO))]
						// Fluxo de Informações do Arquivo
						_cFile += GRFILE((cAliasQry)->(A1_COD + A1_LOJA), (cAliasQry)->A1_LOJA , _cTipo, _cTelefone )
					EndIf
				
					(cAliasAGB)->(dbSkip())
		
				EndDo

				(cAliasAGB)->(dbCloseArea())
			
				(cAliasSU5)->(dbSkip())
											
			Enddo
		
			(cAliasSU5)->(dbCloseArea())
				
			FWRITE(_nHandle,_cFile) // GRAVA TEXTO
	
			_cFile		:= ""
	
			(cAliasQry)->(dbSkip())

		EndDo
	
		(cAliasQry)->(dbCloseArea())

		// Gravação de Log de Processamento
		Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())

	Endif

	FWRITE(_nHandle,_cFile) // GRAVA TEXTO

	_cFile 	:= ''

	FCLOSE(_nHandle)

	RestArea(_aArea)

Return()

//------------------------------------------------------------------------
/*/{Protheus.doc} User Function GRFILE
Função para gravação da Variável no arquivo
@author 	Rogério Doms
@since 		27/10/2016
@version 	1.0		 ,  ,  , 
@param 		_cCLFCLI	, ${param_type}, (Codigo + Loja)
@param 		_cCLFSEQ	, ${param_type}, (Loja)
@param 		_cCLFTIP	, ${param_type}, (Tipo do Telefone)
@param		_cCLFTXT	, ${param_type}, (Numero DDD + Telefone)
@return 	${return}   , ${return_description}
@example

@see (links_or_references)
//------------------------------------------------------------------------
/*/Static Function GRFILE( _cCLFCLI , _cCLFSEQ , _cCLFTIP , _cCLFTXT )

	Local _cTexto := ""

	// Fluxo de Informações do Arquivo
	_cTexto := _cCLFCLI				// 01-CLFCLI
	_cTexto += _cCLFSEQ				// 02-CLFSQE
	_cTexto += _cCLFTIP             // 03-CLFTIP
	_cTexto += _cCLFTXT   			// 04-CLFTXT
	If "leedspecas@gmail.com" = AllTrim(_cCLFTXT)
		a := 0
	EndIf
	_cTexto += CHR(13) + CHR(10)	// QUEBRA DE LINHA
Return(_cTexto)
