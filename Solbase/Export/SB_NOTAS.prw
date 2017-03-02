#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_NOTAS()
Geração do arquivo de Notas
@author 	Carlos Eduardo Saturnino
@since 		28/10/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}   , ${return_description}
@example

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_NOTAS( _cLocal, _cFileName, lJob, _cVend )
		
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
		_cQry		:= " SELECT			SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.R_E_C_N_O_, SF2.F2_DOC, SF2.F2_SERIE,  "	+ CHR(13) + CHR(10)
		_cQry		+= " 					SF2.F2_VALFAT, SF2.F2_FILIAL, SF2.F2_TRANSP, SF2.F2_COND, SA1.A1_BCO1,  "	+ CHR(13) + CHR(10)
		_cQry		+= " 					SF2.F2_EMISSAO   "																+ CHR(13) + CHR(10)
		_cQry		+= " FROM				" + RetSqlName("SF2") + " SF2  "												+ CHR(13) + CHR(10)
		_cQry		+= " INNER JOIN		" + RetSqlName("SA1") + " SA1 "													+ CHR(13) + CHR(10)		
		_cQry		+= " ON				SF2.F2_CLIENTE = SA1.A1_COD "													+ CHR(13) + CHR(10)
		_cQry		+= " AND				SF2.F2_LOJA = SA1.A1_LOJA	"													+ CHR(13) + CHR(10)
//		_cQry		+= " WHERE				SF2.F2_FILIAL = '" + xFilial("SF2") + "' "									+ CHR(13) + CHR(10)
//		_cQry		+= " AND				SA1.A1_FILIAL = '" + xFilial("SA1") + "' "									+ CHR(13) + CHR(10)
		_cQry		+= " WHERE				SA1.A1_FILIAL = '" + xFilial("SA1") + "' "									+ CHR(13) + CHR(10)
		_cQry		+= " AND 				F2_VEND1 	= '" + _cVend + "' "													+ CHR(13) + CHR(10)
		_cQry		+= " AND 				SF2.D_E_L_E_T_	<> '*' "														+ CHR(13) + CHR(10)		
		_cQry		+= " ORDER BY			F2_SERIE, F2_DOC "																+ CHR(13) + CHR(10)
	
		MEMOWRIT("\SB_NOTAS.SQL",_cQry)
		cQuery := ChangeQuery(_cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)		
				
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		While ! (cAliasQry)->(Eof())
		
				// Inclui a quebra de linha 
				If _lPrim 
					_lPrim := .F.
				Else
					_cFile += CHR(13) + CHR(10)														// QUEBRA DE LINHA
				Endif
				
				// Fluxo de Informações do Arquivo
				_cFile		+= (cAliasQry)->(F2_CLIENTE + F2_LOJA)
				_cFile 	+=	U_FORMAT((cAliasQry)->R_E_C_N_O_,'ZN',8) 
				_cFile 	+=	Space(02)
				_cFile 	+=	Space(02)
				_cFile 	+=	Right((cAliasQry)->F2_DOC,9)
				_cFile 	+=	"NFE"
				_cFile 	+=	Substr((cAliasQry)->F2_EMISSAO,7,2) + "/" + Substr((cAliasQry)->F2_EMISSAO,5,2)+ "/" + Substr((cAliasQry)->F2_EMISSAO,1,4)
				_cFile 	+=	Iif(Empty((cAliasQry)->A1_BCO1),"CAR","COB")
				_xVarTmp	:= 	(cAliasQry)->F2_COND 
				_cFile 	+= 	U_FORMAT(_xVarTmp,'ZC',06)
				_cFile 	+= 	Replicate("0",03)
				_xVarTmp	:= ((cAliasQry)->F2_VALFAT * 100 )
				_cFile 	+= 	U_FORMAT(_xVarTmp,'ZC',13)
				_cFile 	+= 	Replicate("0", 07)
				_cFile 	+=	Substr(cFilant,2,3)
				_xVarTmp	:= 	(cAliasQry)->F2_TRANSP
				_cFile 	+=	U_FORMAT(_xVarTmp,'ZC',13)									
				
				FWRITE(_nHandle,_cFile) // GRAVA TEXTO
				_cFile := ''
				(cAliasQry)->(dbSkip())

		EndDo
		// Gravação de Log de Processamento
		Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())
	Endif

	FCLOSE(_nHandle)
	(cAliasQry)->(dbCloseArea())
	RestArea(_aArea)

Return