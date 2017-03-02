#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_TRIBUTA()
Geração Registros de Tributação
@author 	Carlos Eduardo Saturnino
@since 		31/10/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}, ${return_description}
@example	

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_TRIBUTA( _cLocal, _cFileName, lJob )
		
	Local _cLFile
	Local cAliasQry 	:= GetNextAlias()
	Local cAliasSX5 	:= GetNextAlias()
	Local _cQry		:= ''
	Local _lPrim		:= .T.
	Local _cFile		:= ''
	Local _xVarTmp	:= ''
	Local _nHandle	:= 0
	Local _aArea		:= GetArea()

	// Valido o De/Para do Grupo de Clientes
	_cQry		:= " SELECT	SF7.F7_GRPCLI, SX5.X5_DESCRI "						+ CHR(13) + CHR(10)
	_cQry		+= " FROM	" + RetSqlName("SF7") + "   SF7 "						+ CHR(13) + CHR(10)
	_cQry		+= " INNER JOIN	" + RetSqlName("SX5") + " SX5 "					+ CHR(13) + CHR(10)
	_cQry		+= " ON 	X5_CHAVE = F7_GRPCLI "									+ CHR(13) + CHR(10)
	_cQry		+= " WHERE	X5_TABELA = '_Z' "										+ CHR(13) + CHR(10)
	_cQry		+= " AND	X5_DESCRI = ''  "											+ CHR(13) + CHR(10)
	_cQry		+= " GROUP BY 	SF7.F7_GRPCLI, SX5.X5_DESCRI, SX5.X5_TABELA "
	
	MEMOWRIT("\SB_TRIBUTA_1.SQL",_cQry)
	cQuery := ChangeQuery(_cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSX5,.F.,.T.)
	
	// Se o Alias contiver dados, é pq está faltando amarração na Tabela SX5
	If ! (cAliasSX5)->(Eof())

		// Grava o Log Caso não tenha Amarração do Grupo de Clientes X De/Para do Arquivo SolBase na tabela SX5
		While !(cAliasSX5)->(Eof())
			Conout(_cFileName + Space( 17 - Len(_cFileName)) + '. Arquivo não gravado as ' + Time() + '. Preencha a sequencia do campo X5_DESCRI para o Grupo de Cliente ' + (cAliasSX5)->F7_GRPCLI + ' na Tabela SX5')
			(cAliasSX5)->(dbSkip())
		EndDo
	
	 		
	Else

		_cLFile  	:= _cLocal + _cFileName
		_nHandle 	:= FCreate(_cLFile)
	
		// Gravação de Log de Erro
		If _nHandle == -1
			If !lJob
				MsgAlert('Erro de gravação do arquivo no disco. Arquivo ' + _cFileName )
			Else
				Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Erro de gravação do arquivo no disco')
			Endif
		Endif
		
		// Query DO Fluxo do Relatório 		
		_cQry		:= " SELECT	* , SX5.X5_DESCRI" 									+ CHR(13) + CHR(10)
		_cQry		+= " FROM	" + RetSqlName("SF7") + " SF7 "							+ CHR(13) + CHR(10)
		_cQry		+= " INNER JOIN	" + RetSqlName("SX5") + " SX5 "					+ CHR(13) + CHR(10)
		_cQry		+= " ON	SF7.F7_GRPCLI = SX5.X5_CHAVE "							+ CHR(13) + CHR(10)
		_cQry		+= " WHERE	SX5.X5_TABELA = '_Z' "									+ CHR(13) + CHR(10)
		_cQry		+= " AND	SF7.D_E_L_E_T_ <>  '*' "									+ CHR(13) + CHR(10)
		_cQry		+= " AND	SX5.D_E_L_E_T_ <>  '*' "									+ CHR(13) + CHR(10)
		_cQry		+= " ORDER BY	F7_FILIAL, F7_GRTRIB, F7_GRPCLI, F7_SEQUEN  "	+ CHR(13) + CHR(10)
	
		MEMOWRIT("\SB_TRIBUTA.SQL",_cQry)
		cQuery := ChangeQuery(_cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
				
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		While !(cAliasQry)->(Eof())
		

			// Inclui a quebra de linha 
			If _lPrim
				_lPrim := .F.
			Else
				_cFile += CHR(13) + CHR(10)														// QUEBRA DE LINHA
			Endif
			
			// Fluxo de Informações do Arquivo
			_cFile 	+= 	Substr((cAliasQry)->F7_FILIAL,2,3)				//01
			_cFile 	+= 	(cAliasQry)->F7_EST 							//04
			_cFile 	+=	SubStr((cAliasQry)->F7_GRTRIB,1,3)				//06
			_cFile 	+=	Alltrim((cAliasQry)->X5_DESCRI)
			
			Do Case
			Case (cAliasQry)->F7_MARGEM <> 0
				_xVarTmp	:= "S"
			Case (cAliasQry)->F7_MARGEM == 0 .And. (cAliasQry)->F7_BASEICM <> 0
				_xVarTmp	:= "B"
			Case (cAliasQry)->F7_MARGEM == 0 .And. (cAliasQry)->F7_BASEICM == 0
				_xVarTmp	:= "N"
			EndCase
			
			_cFile 	+=	_xVarTmp											//11
			_xVarTmp	:=	If((cAliasQry)->F7_BASEICM==0, 100, (cAliasQry)->F7_BASEICM) * 10000
			_cFile 	+= 	U_FORMAT(_xVarTmp,'ZN',07)						//12
			_xVarTmp	:=	(cAliasQry)->F7_ALIQEXT * 100
			_cFile 	+=	U_FORMAT(_xVarTmp,'ZN',04)						//19
			_xVarTmp	:=	(cAliasQry)->F7_ALIQINT * 100
			_cFile 	+=	U_FORMAT(_xVarTmp,'ZN',04)						//23
			_xVarTmp	:=	If((cAliasQry)->F7_MARGEM <> 0, Round(((cAliasQry)->F7_MARGEM + 100) * (If((cAliasQry)->F7_BSICMST==0, 100, (cAliasQry)->F7_BSICMST)/100), 4) * 10000, 0)
			_cFile 	+=	U_FORMAT(_xVarTmp,'ZN',07)						//27
			_cFile 	+=	(cAliasQry)->F7_XDSTIPI							//34
			_cFile 	+= 	"N"													//35
			_cFile 	+= 	Iif((cAliasQry)->F7_MARGEM <> 0,'I',' ') + Space(9)	//35
			_cFile 	+= 	Space(30)											//36
			_cFile		+= 	Replicate('0',7)									//76
			_cFile		+= 	Replicate('0',7)									//83
			_xVarTmp 	:=	(cAliasQry)->R_E_C_N_O_
			_cFile		+= 	U_FORMAT(_xVarTmp,'ZC',08)						//90
			_cFile		+= 	Replicate('0',6)									//98
			_cFile 	+= 	"C"													//104
			_cFile		+= 	Replicate('0',5)									//105
			_cFile		+= 	"N"													//110
			_cFile		+= 	Replicate('0',10)									//111
			
			Do Case
			Case (cAliasQry)->F7_EST == "MT"
				_xVarTmp	:= 	(cAliasQry)->F7_MARGEM * 1000
			OtherWise
				_xVarTmp	:= 	0
			EndCase
						
			_cFile 	+= 	U_FORMAT(_xVarTmp,'ZN',10)
			_cFile		+= 	Replicate('0',30)
			
			FWRITE(_nHandle,_cFile) // GRAVA TEXTO
			_cFile		:= ""
			(cAliasQry)->(dbSkip())

		EndDo
	
		// Gravação de Log de Processamento
		Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())

		// Fecha Query do Fluxo do Relatorio
		(cAliasQry)->(dbCloseArea())
		
	Endif
	
	// Fecha a Query de Verificação de Consistência de Dados
	(cAliasSX5)->(dbCloseArea())
	
	// Fecha o arquivo TXT, caso tenha sido criado
	If _nHandle <> -1
		FCLOSE(_nHandle)
	Endif
	
	RestArea(_aArea)

Return