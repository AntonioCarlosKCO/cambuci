#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_NOTITE()
Geração do arquivo de Itens das Notas Fiscais
@author 	Carlos Eduardo Saturnino
@since 		31/10/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}   , ${return_description}
@example

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_NOTITE( _cLocal, _cFileName, lJob, _cVend )
		
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
		_cQry		:= " SELECT	SF2.R_E_C_N_O_ AS SF2_RECNO, SD2.D2_ITEM, SC6.C6_XCODREF,SD2.D2_QUANT, SD2.D2_UM, "	+ CHR(13) + CHR(10)
		_cQry		+= " 			SB1.B1_QE, SD2.D2_PRCVEN, SD2.D2_TOTAL, SD2.D2_COD, SB1.B1_XANTIGO "		+ CHR(13) + CHR(10)
		_cQry		+= " FROM		" + RetSqlName("SD2") + " SD2  "												+ CHR(13) + CHR(10)
		_cQry		+= " INNER JOIN	" + RetSqlName("SC6") + " SC6 "												+ CHR(13) + CHR(10)		
		_cQry		+= " ON	SD2.D2_COD = SC6.C6_PRODUTO "												+ CHR(13) + CHR(10)
		_cQry		+= " AND	SD2.D2_LOJA = SC6.C6_LOJA	"													+ CHR(13) + CHR(10)	
		_cQry		+= " AND	SD2.D2_DOC = SC6.C6_NOTA  "															+ CHR(13) + CHR(10)
 		_cQry		+= " AND	SD2.D2_SERIE = SC6.C6_SERIE "														+ CHR(13) + CHR(10)
		_cQry		+= " INNER JOIN	" + RetSqlName("SB1") + " SB1 "												+ CHR(13) + CHR(10)		
		_cQry		+= " ON	SD2.D2_COD = SB1.B1_COD "													+ CHR(13) + CHR(10)
		_cQry		+= " INNER JOIN	" + RetSqlName("SF2") + " SF2 "												+ CHR(13) + CHR(10)
		_cQry		+= " ON	SF2.F2_FILIAL = SD2.D2_FILIAL "												+ CHR(13) + CHR(10)
		_cQry		+= " AND	SF2.F2_DOC = SD2.D2_DOC "														+ CHR(13) + CHR(10)
		_cQry		+= " AND	SF2.F2_SERIE = SD2.D2_SERIE "													+ CHR(13) + CHR(10)		
		_cQry		+= " WHERE	SD2.D_E_L_E_T_ <> '*' "															+ CHR(13) + CHR(10)
		_cQry		+= " AND	SF2.D_E_L_E_T_ <> '*' "															+ CHR(13) + CHR(10)		
		_cQry		+= " AND	SC6.D_E_L_E_T_ <> '*' "															+ CHR(13) + CHR(10)
		_cQry		+= " AND	SB1.D_E_L_E_T_ <> '*' "															+ CHR(13) + CHR(10)
//		_cQry		+= " AND	SF2.F2_FILIAL = '" + xFilial("SF2")+  "' "									+ CHR(13) + CHR(10)	COMENTADO					
//		_cQry		+= " AND	SD2.D2_FILIAL = '" + xFilial("SD2")+  "' "									+ CHR(13) + CHR(10) POR
//		_cQry		+= " AND	SC6.C6_FILIAL = '" + xFilial("SC6")+  "' "									+ CHR(13) + CHR(10) DJALMA BORGES
//		_cQry		+= " AND	SB1.B1_FILIAL = '" + xFilial("SB1")+  "' "									+ CHR(13) + CHR(10) 08/02/2017
		_cQry		+= " AND	SF2.F2_VEND1 = '" +  _cVend +  "' "											+ CHR(13) + CHR(10)								
		_cQry		+= " ORDER BY	D2_SERIE, D2_DOC, D2_ITEM "

	
		MEMOWRIT("\SB_NOTITE.SQL",_cQry)
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
				_xVarTmp	:= 	(cAliasQry)->SF2_RECNO
				_cFile 	+=	U_FORMAT(_xVarTmp,'ZN',08) 
				_xVarTmp	:= 	(cAliasQry)->D2_ITEM
				_cFile 	+=	U_FORMAT(_xVarTmp,'N',03)
				_xVarTmp	:= 	Substr(SB1->B1_XANTIGO,1,8)		//(cAliasQry)->C6_XCODREF
				_cFile 	+=	U_FORMAT(_xVarTmp,'XE',08)
				_xVarTmp	:= 	(cAliasQry)->D2_QUANT * 1000
				_cFile 	+=	U_FORMAT(_xVarTmp,'ZN',09)
				_cFile 	+=	(cAliasQry)->D2_UM
				_xVarTmp	:= 	(cAliasQry)->B1_QE * 1000
				_cFile 	+=	U_FORMAT(_xVarTmp,'ZN',08)
				_xVarTmp	:= 	(cAliasQry)->D2_PRCVEN * 100
				_cFile 	+=	U_FORMAT(_xVarTmp,'ZN',13)
				_xVarTmp	:= 	(cAliasQry)->D2_TOTAL * 100
				_cFile 	+=	U_FORMAT(_xVarTmp,'ZN',13)																

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