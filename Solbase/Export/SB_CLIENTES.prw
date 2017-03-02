
#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_CLIENTES()
Geração Registros de Clientes
@author 	Carlos Eduardo Saturnino
@since 		21/10/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@param 		_cVend		, ${param_type}, (Código do Vendedor - Só p/ Arquivos Locais)
@return 	${return}	, ${return_description}
@example	

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_CLIENTES( _cLocal, _cFileName, lJob, _cVend )
		
	Local _cLFile
	Local cAliasQry 	:= GetNextAlias()
	Local _cQry		:= ''
	Local _lPrim		:= .T.
	Local _cFile		:= ''
	Local _xVarTmp	:= ''
	Local _nHandle	:= 0
	Local _aArea		:= GetArea()
	Local _nSaldo		:= 0
	

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
		
		// Query para definição 		
		_cQry		:= " SELECT	A1_COD, A1_LOJA, A1_NOME, A1_NREDUZ, A1_PESSOA, A1_CGC, "	+ CHR(13) + CHR(10)
		_cQry		+= " 			A1_DTINIV, A1_BCO1, A1_COND, A1_ULTCOM, A1_RISCO,	"		+ CHR(13) + CHR(10)		
		_cQry		+= " 			A1_VENCLC, A1_LC, A1_SALDUP"									+ CHR(13) + CHR(10)		
		_cQry		+= " FROM		" + RetSqlName("SA1") + "  "									+ CHR(13) + CHR(10)
//		_cQry		+= " WHERE		A1_FILIAL 	= '" + xFilial("SA1") + "' "						+ CHR(13) + CHR(10)
//		_cQry		+= " AND 		A1_VEND 	= '" + _cVend + "' "									+ CHR(13) + CHR(10)
		_cQry		+= " WHERE 		A1_VEND 	= '" + _cVend + "' "									+ CHR(13) + CHR(10) // DJALMA BORGES 08/02/2017
		_cQry		+= " AND 		D_E_L_E_T_	<> '*' "												+ CHR(13) + CHR(10)		
		_cQry		+= " AND 		A1_MSBLQL 	<> '1' "												+ CHR(13) + CHR(10)
		_cQry		+= " ORDER BY	A1_COD, A1_LOJA "													+ CHR(13) + CHR(10)
	
		MEMOWRIT("\SB_CLIENTES.SQL",_cQry)
		cQuery := ChangeQuery(_cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)		
				
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		While ! (cAliasQry)->(Eof())
		
			// Inclui a quebra de linha 
			If _lPrim 
				_lPrim := .F.
			Else
				_cFile := CHR(13) + CHR(10)														// QUEBRA DE LINHA
			Endif
			
			// Verifico a situação de Crédito
			If (cAliasQry)->A1_RISCO $ "E|B|C|D"  .Or. ! Empty((cAliasQry)->A1_VENCLC) .And. (cAliasQry)->A1_VENCLC < Dtos(dDataBase)  .Or. ( (cAliasQry)->A1_LC - (cAliasQry)->A1_SALDUP ) < 0 
				_cSitCred := "I"
			ElseIf ! Empty((cAliasQry)->A1_VENCLC) .And. (cAliasQry)->A1_VENCLC < Dtos(dDataBase) .Or. ( ((cAliasQry)->A1_LC - (cAliasQry)->A1_SALDUP ) > 0 )
				_cSitCred := "L"
			ElseIf (cAliasQry)->A1_RISCO ==  "A"
				_cSitCred := "A"
			Endif
			
			// Fluxo de Informações do Arquivo
			_cFile		+= (cAliasQry)->(A1_COD + A1_LOJA)
			_xVarTmp	:= SubStr((cAliasQry)->A1_NOME, 1, 40)
			_cFile 	+=	U_FORMAT(_xVarTmp,'XE',40)
			_xVarTmp	:= SubStr((cAliasQry)->A1_NREDUZ, 1, 30)
			_cFile 	+=	U_FORMAT(_xVarTmp,'XE',30)
			_cFile 	+= (cAliasQry)->A1_PESSOA
			_xVarTmp	:= (cAliasQry)->A1_CGC
			_cFile 	+=	U_FORMAT(_xVarTmp,'ZC',20)
			_xVarTmp	:= Iif(Empty((cAliasQry)->A1_DTINIV),Dtos(dDataBase),(cAliasQry)->A1_DTINIV) 
			_cFile 	+= Substr(_xVarTmp,7,2)	+"/"+ Substr(_xVarTmp,5,2)	+"/"+ Substr(_xVarTmp,1,4)
			_xVarTmp	:= (cAliasQry)->A1_BCO1
			_cFile 	+= Iif(Empty(_xVarTmp),"CAR", "COB")
			_xVarTmp	:= (cAliasQry)->A1_COND				
			_cFile 	+= U_FORMAT(_xVarTmp,'ZC',06)
			_xVarTmp	:= Iif(Empty((cAliasQry)->A1_ULTCOM),Dtos(dDatabase),(cAliasQry)->A1_ULTCOM)
			_cFile 	+= Substr(_xVarTmp,7,2)	+"/"+ Substr(_xVarTmp,5,2)	+"/"+ Substr(_xVarTmp,1,4)
			_xVarTmp	:= (cAliasQry)->A1_RISCO
			_cFile 	+= U_FORMAT(_xVarTmp,'ZC',06)				
			_cFile 	+= _cSitCred
			_cFile 	+= Space(03) // (cAliasQry)->A1_XTEXTO É UM CAMPO MEMO, NÃO PODE SER APENAS DE C, 03							

			FWRITE(_nHandle,_cFile) // GRAVA TEXTO
			(cAliasQry)->(dbSkip())
	
		EndDo
		// Gravação de Log de Processamento
		Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())
	Endif

	FCLOSE(_nHandle)
	(cAliasQry)->(dbCloseArea())
	RestArea(_aArea)

Return