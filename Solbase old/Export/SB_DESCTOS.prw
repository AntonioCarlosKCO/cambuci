#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_DESCTOS
Geração Tabela de Descontos (DESCONTOS)
@author 	Rogério Doms
@since 		01/11/2016
@version 	1.0
@param 		_cLocal	    , ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, (Job)
@return 	${return}   , ${return_description}
@example

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_DESCTOS( _cLocal, _cFileName, lJob )

	Local cAliasQry := GetNextAlias() 
	Local _aArea	:= GetArea()
	Local _cLFile   := ''
	Local _cFile	:= ''
	Local _xVarTmp	:= ''
	Local _cQry		:= ''
	Local _cIdent   := ''
	Local _nLocFat  := '0'
	Local _nHandle	:= 0
	Local _lPrim	:= .T.

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
		_cQry := "SELECT ZZE_FILIAL, ZZE_XORDEM, ZZE_XPDESC, ZZE_XTPCAL, ZZE_XMARCA, ZZE_XDESMC, "	+ CHR(13) + CHR(10)
		_cQry += "       ZZE_XSUBGR, R_E_C_N_O_ , ZZE_NCM, ZZE_XDESTC, ZZE_XPRODU, ZZE_XDPROD, " 	+ CHR(13) + CHR(10)
		_cQry += "       ZZE_XGRPCL, ZZE_XCODCL, ZZE_XDESCL, ZZE_XGRUPO, ZZE_XDGRPO, ZZE_XLINHA, " + CHR(13) + CHR(10)
		_cQry += "       ZZE_XDLINH, ZZE_XTABEL "  														+ CHR(13) + CHR(10)
		_cQry += "  FROM " + RetSqlName("ZZE") + " ZZE "													+ CHR(13) + CHR(10)
		_cQry += " WHERE ZZE.ZZE_FILIAL = '" + xFilial("ZZE") + "'" 									+ CHR(13) + CHR(10)
		_cQry += "   AND ZZE.D_E_L_E_T_	<> '*'"															+ CHR(13) + CHR(10)
		_cQry += " ORDER BY R_E_C_N_O_ "																	+ CHR(13) + CHR(10)
	
		MEMOWRIT("\SB_DESCONTOS.SQL",_cQry)
		cQuery := ChangeQuery(_cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
				
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		While ! (cAliasQry)->(Eof())
		
			//Posiciona no Cliente
			_cCliLoja := "00000000"
			If !Empty((cAliasQry)->ZZE_XCODCL)
				dbSelectArea("SA1")
				SA1->(dbSetOrder(01))
				If SA1->(dbSeek(xFilial("SA1") + (cAliasQry)->ZZE_XCODCL))
					_cCliLoja := SA1->(A1_COD + A1_LOJA)
				EndIf	
			EndIf
			
			//Posiciona na Tabela de Preço
			_dDtDe := CTOD(Space(08))
			_dDtAte:= CTOD(Space(08))
			If !Empty((cAliasQry)->ZZE_XTABEL)
				dbSelectArea("DA0")
				DA0->(dbSetOrder(01))
				If DA0->(dbSeek(xFilial("DA0") + (cAliasQry)->ZZE_XTABEL))
					
					// Tratamento para quando a Data De estiver em branco 
					If Empty(DA0->DA0_DATDE)
						_dDtDe := '20150101'
					Else
						_dDtDe := DA0->DA0_DATDE
					Endif
					
					// Tratamento para quando a Data Ate estiver em branco
					If Empty(DA0->DA0_DATATE)
						_dDtAte := '20401231'
					Else
						_dDtAte:= DA0->DA0_DATATE
					Endif					

				EndIf	
			EndIf
			
			//Posiciona na Tabela de Produtos
			_cProdAnt := Space(08)
			_cUnidade := Space(08)
			_cPosIpi  := Space(10)
			If !Empty((cAliasQry)->ZZE_XPRODU)
				dbSelectArea("SB1")
				SB1->(dbSetOrder(01))
				If SB1->(dbSeek(xFilial("SB1") + (cAliasQry)->ZZE_XPRODU))
					_cProdAnt := SB1->B1_XANTIGO
					_cUnidade := SB1->B1_UM
					_cPosIpi  := SB1->B1_POSIPI
				EndIf	
			EndIf
			
			//Posiciona na Tabela de Nomenclatura Comum do Mercosul
			_cXRefSb := "00000"
			If !Empty(_cPosIpi)
				dbSelectArea("SYD")
				SYD->(dbSetOrder(01))
				If SYD->(dbSeek(xFilial("SYD") + _cPosIpi))
					_cXRefSb := SYD->YD_XREFSB
				EndIf	
			EndIf
			
			// Inclui a quebra de linha 
			If _lPrim
				_lPrim := .F.
			Else
				_cFile := CHR(13) + CHR(10)	// QUEBRA DE LINHA
			Endif
		
			// Fluxo de Informações do Arquivo
			_cFile 	+= _cCliLoja																						//01-DCTCLI
			_cFile 	+= U_FORMAT((cAliasQry)->R_E_C_N_O_ ,'ZN',08)													//02-DCTID
			_xVarTmp	:= Iif(Empty(_dDtDe),Dtos(dDataBase),Dtos(_dDtDe)) 
			_cFile 	+= Substr(_xVarTmp,7,2)	+"/"+ Substr(_xVarTmp,5,2)	+"/"+ Substr(_xVarTmp,1,4)			//03-DTCVIG_INICIO
			_xVarTmp	:= Iif(Empty(_dDtAte),Dtos(dDataBase),Dtos(_dDtAte))
			_cFile 	+= Substr(_xVarTmp,7,2)	+"/"+ Substr(_xVarTmp,5,2)	+"/"+ Substr(_xVarTmp,1,4)			//04-DTCVIG_FIM
			_cFile 	+= Substr((cAliasQry)->ZZE_XGRUPO,1,3)																//05-DCTGRI
			_cFile 	+= Substr((cAliasQry)->ZZE_XSUBGR,1,3)																//06-DCTTPI
			_cFile 	+= Substr((cAliasQry)->ZZE_XMARCA,1,3)																//07-DCTMCI
			_cFile 	+= Substr((cAliasQry)->ZZE_XLINHA,1,3)																//08-DCTLHI
			_cFile 	+= U_FORMAT(_cUnidade,'XD',08)																		//09-DCTITE
			_cFile 	+= U_FORMAT(Val((cAliasQry)->ZZE_XTABEL ),'ZN',08)												//10-DCTLIS
			_cFile 	+= Substr(_cXRefSb,1,5)																				//11-DCTIPI
			_cFile 	+= Substr(_cProdAnt,1,8)																				//12-DCTGRC
			_cFile 	+= "0000"																								//13-DCTPZM
			_cFile 	+= "S"																									//14-DCTDIG
			_cFile 	+= "N"																									//15-DCTDIFICM
			_cFile 	+= "00000000"																							//16-DCTTAXA
			_cFile 	+= U_FORMAT(Val((cAliasQry)->ZZE_XORDEM),'ZN',06)												//17-DCTORDEM
			
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
