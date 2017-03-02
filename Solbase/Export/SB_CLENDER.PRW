#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_CLIENDER
Geração Endereços dos Clientes (CLIENDER)
@author 	Rogério Doms
@since 		26/10/2016
@version 	1.0
@param 		_cLocal	    , ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}   , ${return_description}
@example

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_CLENDER( _cLocal, _cFileName, lJob, _cVend )

Local _cLFile 	:= ''
Local _cFile	:= ''
Local _xVarTmp	:= ''
Local _cQry		:= ''
Local cQuery	:= ''
Local _nLocFat  := '0'
Local _nHandle	:= 0
Local _lPrim	:= .T.
Local cAliasQry	:= GetNextAlias()
Local aUF		:= {}

Local _aTratam	:= {{'A','Administracao'},{'E','Entrega'},{'C','Cobranca'}}

Local _aArea	:= GetArea()


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
	_cQry := "SELECT A1_VEND, A1_COD, A1_LOJA, A1_NOME, A1_END, A1_COMPLEM, A1_BAIRRO, A1_EST,"	+ CHR(13) + CHR(10)
	_cQry += "       ISNULL(CC2.R_E_C_N_O_,0) CC2REC, A1_CEP, A1_GRPTRIB, A1_TRANSP, A1_PESSOA,"+ CHR(13) + CHR(10)
	_cQry += "       A1_CGC, A1_GRPTRIB " 														+ CHR(13) + CHR(10)		
	_cQry += "FROM " + RetSqlName("SA1") + " SA1 "												+ CHR(13) + CHR(10)
	_cQry += "LEFT JOIN " + RetSqlName("CC2") + " CC2 "											+ CHR(13) + CHR(10)
	_cQry += "  ON  SA1.A1_COD_MUN 	= CC2_CODMUN"												+ CHR(13) + CHR(10)
	_cQry += "  AND SA1.A1_EST = CC2_EST"														+ CHR(13) + CHR(10)
	_cQry += "  AND CC2.D_E_L_E_T_	<> '*' "													+ CHR(13) + CHR(10)
//	_cQry += "WHERE SA1.A1_FILIAL 	= '" + xFilial("SA1") + "' "								+ CHR(13) + CHR(10)
//	_cQry += "  AND SA1.A1_VEND 	= '" + _cVend + "' "										+ CHR(13) + CHR(10)
	_cQry += "WHERE SA1.A1_VEND 	= '" + _cVend + "' "										+ CHR(13) + CHR(10) // DJALMA BORGES 08/02/2017
	_cQry += "  AND SA1.A1_MSBLQL 	<> '1' "													+ CHR(13) + CHR(10)
	_cQry += "  AND SA1.D_E_L_E_T_	<> '*' "													+ CHR(13) + CHR(10)		
	_cQry += "ORDER BY A1_VEND, A1_COD, A1_LOJA "												+ CHR(13) + CHR(10)
	
	MEMOWRIT("\SB_CLIENDER.SQL",_cQry)
	cQuery := ChangeQuery(_cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)		
				
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	While ! (cAliasQry)->(Eof())
		
		// Inclui a quebra de linha 
		If _lPrim 
			_lPrim := .F.
		Else
			_cFile += CHR(13) + CHR(10)	// QUEBRA DE LINHA
		Endif
		
		// Separa o Endereço do Numero
		_cEnd := Substr((cAliasQry)->A1_END,01,AT(",",(cAliasQry)->A1_END)-1)
		_cNr  := Substr((cAliasQry)->A1_END,AT(",",(cAliasQry)->A1_END)+1,AT(" ",(cAliasQry)->A1_END))
				
		// Fluxo de Informações do Arquivo
		_cFile += (cAliasQry)->(A1_COD + A1_LOJA)					// 01-CLECLI
		_cFile += (cAliasQry)->(A1_LOJA)							// 02-CLESSQ
		_cFile += 'A'												// 03-CLETRT
		_cFile += 'ADM       '										// 04-CLETIP
		_cFile += U_FORMAT(_cEnd,'XD',40)							// 05-CLEEND
		_cFile += U_FORMAT(_cNr,'N',6)								// 06-CLENRO
		_cFile += U_FORMAT((cAliasQry)->(A1_COMPLEM),'XD',20)  		// 07-CLECPL
		_cFile += U_FORMAT((cAliasQry)->(A1_BAIRRO),'XD',15)		// 08-CLEBAI
		_cFile += U_FORMAT((cAliasQry)->(A1_EST),'XD',2)			// 09-CLEUF
		_cFile += U_FORMAT((cAliasQry)->(CC2REC),'ZN',8)			// 10-CLEMUN
		_cFile += U_FORMAT((cAliasQry)->(A1_CEP),'XD',8)			// 11-CLECEP
		_xVarTmp := Posicione("SX5",1,xFilial("SX5")+'_Z'+(cAliasQry)->A1_GRPTRIB,"X5_DESCRI")
		_cFile += U_FORMAT(_xVarTmp,'XD',2)   						// 12-CLESTPES
		_cFile += U_FORMAT((cAliasQry)->(A1_TRANSP),'ZC',8)			// 13-CLETRA
		_cFile += SubStr(cFilAnt, 2, 3)								// 14-CLELOF
		_cFile += U_FORMAT((cAliasQry)->(A1_LOJA),'XD',3)          	// 15-CLEORDEM
		// Valida Tipo de Cliente
		If (cAliasQry)->(A1_TRANSP) == 'J'
			_cFile += Substr((cAliasQry)->(A1_CGC),8,6)			// 16-CLECGC
		Else
			_cFile += Replicate('0',6) // 16-CLECGC
		EndIf	
				
		FWRITE(_nHandle,_cFile) // GRAVA TEXTO
	
		_cFile		:= ""
	
		(cAliasQry)->(dbSkip())

	EndDo

	// Gravação de Log de Processamento
	Conout(_cFileName + Space( 17 - Len(_cFileName))+ '. Arquivo Gravado com sucesso as ' + Time())

Endif

FCLOSE(_nHandle)
RestArea(_aArea)

Return()