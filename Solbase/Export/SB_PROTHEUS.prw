#Include 'Totvs.ch'
#Include 'TBICONN.ch'

//-----------------------------------------------------------------
/*/{Protheus.doc} SB_MESTRE
Gera玢o EDI's Protheus X Solbase
@type 		User Function
@author 	Carlos Eduardo Saturnino
@since 		09/09/2016
@version 	1.0
@param 		lJob	, ${param_type}, (Gera玢o via WorkFlow)
@return $	{return}, ${return_description}
@example

@see (links_or_references) 
//-------------------------------------------------------------/*/
User Function SB_PROTHEUS()
					
	CONOUT("")
	CONOUT(Replicate('-',80))
	CONOUT("INICIADO ROTINA DE TRANSMISSAO DE VENDAS: SB_PROTHEUS() - DATA/HORA: "+DToC(Date())+" AS "+Time())
	
	GeraTXT()
	
	CONOUT("FINALIZADO ROTINA DE TRANSMISSAO DE VENDAS: SB_PROTHEUS() - DATA/HORA: "+DToC(Date())+" AS "+Time())
	CONOUT(Replicate('-',80))
	CONOUT("")
	
Return .T.

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北赏屯屯屯屯脱屯屯屯屯屯屯退屯屯屯脱屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯突北
北篜rograma  ?GeraTXT	   ?Autor ?TOTVS			 ?Data ? 28/11/16    罕?北
北掏屯屯屯屯拓屯屯屯屯屯屯褪屯屯屯拖屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯凸北
北篋esc.     矯arrega as lojas para filtrar os registros que tiveram vendas罕?
北篋esc.     砪om erros de transmissao.                                    罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯图北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?*/
Static Function GeraTXT(cEmpTrab,cFilTrab)

	Local _cTitulo 	:= "Exporta玢o Solbase X Protheus"
	Local _aPastas	:= {}
	Local _cQry		:= ""
	Local cQuery		:= ""
	Local cAliasQry 	:= GetNextAlias()
	Local _cVend		:= ''
	Local _aArea		:= GetArea()
	Local _nRet, _hInicio, _hFim, _nx
	Local cDir		:= SuperGetMv( "MV_XDIRINT"	, .F., "C:\TEMP\SOL_BASE")
	Local lJob 	:= IsBlind()

	// Cabe鏰lho da Grava玢o de Logs
	Conout("")
	Conout("==============================================================")
	Conout("============ Inicio Log EDI's Protheus X SolBase =============")
	Conout("==============================================================")

	//-------------------------------------------------------
	// Configura o caminho para grava玢o do arquivo EDI
	//-------------------------------------------------------
	If substr(cDir,Len(cDir),1) <> '\'
		cDir += '\'
	Endif

	// Adiciono os caminhos de grava玢o dos arquivos no Array
	_aPastas := { cDir + "GLOBAIS\", cDir + "LOCAIS\"}
	
	//----------------------------------------------------------------
	// Verifico a exist阯cia do diret髍io de grava玢o dos arquivos
	//----------------------------------------------------------------
	For _nx := 1 to Len(_aPastas)
		If ! ExistDir(_aPastas[_nx])
			_nRet := MakeDir(_aPastas[_nx])
			If _nRet != 0
				// Grava玢o de Logs
				Conout('SB_PROTHEUS. Nao foi poss韛el a criacao da pasta '+ _aPastas[_nx] )
				Return
			Endif
		Endif

		//-----------------------------
		// Grava玢o de Log
		//-----------------------------
		Conout("SB_PROTHEUS      . Existencia da pasta " + _aPastas[_nx] + " confirmada. ")
	Next _nx
	
	//--------------------------------
	// Hora de Inicio dos Processos
	//--------------------------------
	_hInicio := Time()

	// Processamento dos arquivos com destino na pasta Globais		
	Processa({|| U_SB_GRUITEX	( _aPastas[01] , "GRUITEX.TXT"		, lJob ) }	,"Aguarde...","Gerando Arquivo de Grupo Aux.Itens...")
	Processa({|| U_SB_TAMITEM	( _aPastas[01] , "TAMITEM.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Tamanho dos Produtos...")
	Processa({|| U_SB_ITEIMAGE	( _aPastas[01] , "ITEIMAGE.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Imagem dos Produtos...")
	Processa({|| U_SB_VLRPMC	( _aPastas[01] , "VLRPMC.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Valor PMC Itens...")
	Processa({|| U_SB_ITEPERMIS	( _aPastas[01] , "ITEPERMIS.TXT"	, lJob ) }	,"Aguarde...","Gerando Arquivo Permissao de Itens...")
	Processa({|| U_SB_ESTADOS	( _aPastas[01] , "ESTADOS.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Estados...")
	Processa({|| U_SB_MUNICIPIOS( _aPastas[01] , "MUNICIPIOS.TXT"	, lJob ) }	,"Aguarde...","Gerando Arquivo de Municipio...")
	Processa({|| U_SB_TRANSP	( _aPastas[01] , "TRANSP.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Transportadoras...")
	Processa({|| U_SB_TIPPED	( _aPastas[01] , "TIPPED.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Tipo Pedido Vendas...")
	Processa({|| U_SB_GRUCLI	( _aPastas[01] , "GRUCLI.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Grupo de Clientes...")
	Processa({|| U_SB_TIPTEXTO	( _aPastas[01] , "TIPTEXTO.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Tipo de Texto...")
	Processa({|| U_SB_CRETSIT	( _aPastas[01] , "CRETSIT.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Situa玢o de Cr閐ito...")
	Processa({|| U_SB_CLAIPI	( _aPastas[01] , "CLAIPI.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Aliquotas de IPI...")
	Processa({|| U_SB_UNIDADES	( _aPastas[01] , "UNIDADES.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Unidades de Medida...")
	Processa({|| U_SB_TIPREFER	( _aPastas[01] , "TIPREFER.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Tabela de Refer阯cia...")
	Processa({|| U_SB_TABFPG 	( _aPastas[01] , "TABFPG.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Tabela de Formas Pagto...")
	Processa({|| U_SB_TABPGT 	( _aPastas[01] , "TABPGT.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Tabela de Cond. Pagto...")
	Processa({|| U_SB_GRITEM 	( _aPastas[01] , "GRUITEM.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Tabela de Grupo Produto...")
	Processa({|| U_SB_MRITEM 	( _aPastas[01] , "MARITEM.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Tabela Tipo de Produto...")
	Processa({|| U_SB_LINITEM 	( _aPastas[01] , "LINITEM.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Linha...")
	Processa({|| U_SB_ITENS 	( _aPastas[01] , "ITENS.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Produtos...")
	Processa({|| U_SB_ITESTQ	( _aPastas[01] , "ITEESTOQ.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Estoque de Produtos...")
	Processa({|| U_SB_ITEREFER	( _aPastas[01] , "ITEREFER.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Refer阯cia de Produtos...")
	Processa({|| U_SB_ITECOMPL	( _aPastas[01] , "ITECOMPL.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Complemento de Produtos...")
	Processa({|| U_SB_LISTAS	( _aPastas[01] , "LISTAS.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Complemento de Produtos...")
	Processa({|| U_SB_CORITEM	( _aPastas[01] , "CORITEM.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Complemento de Produtos...")
	Processa({|| U_SB_TRIBCLF	( _aPastas[01] , "TRIBCLF.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de PIS/COFINS...")
	Processa({|| U_SB_LOCFAT	( _aPastas[01] , "LOCFAT.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Locais de Faturamento...")
	Processa({|| U_SB_LISLOC	( _aPastas[01] , "LISLOC.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Locais X Listas...")
	Processa({|| U_SB_TRIBUTA	( _aPastas[01] , "TRIBUTA.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Tributa玢o...")
	Processa({|| U_SB_BANCOS	( _aPastas[01] , "BANCOS.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Bancos...")
	Processa({|| U_SB_TIPFONE	( _aPastas[01] , "TIPFONE.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Tipos de Imagens...")
	Processa({|| U_SB_PGTCLI	( _aPastas[01] , "PGTCLI.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Cond Pagto X Clientes...")
	Processa({|| U_SB_TIPITEM	( _aPastas[01] , "TIPITEM.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Tipo do Item...")
	Processa({|| U_SB_PRECOS	( _aPastas[01] , "PRECOS.TXT"	 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Pre鏾s...")
	Processa({|| U_SB_DESCTOS	( _aPastas[01] , "DESCONTOS.TXT" 	, lJob ) }	,"Aguarde...","Gerando Arquivo de Descontos...")
		
	// Processamento dos arquivos com destino na pasta Locais
	_cQry		:= " SELECT	* "												+ CHR(13) + CHR(10)
	_cQry		+= " FROM		" + RetSqlName("SA3") + "  "				+ CHR(13) + CHR(10)
//	_cQry		+= " WHERE		A3_FILIAL 	= '" + xFilial("SA3") + "' "	+ CHR(13) + CHR(10)
//	_cQry		+= " AND 		A3_MSBLQL 	<> 	'1' "							+ CHR(13) + CHR(10)
	_cQry		+= " WHERE 		A3_MSBLQL 	<> 	'1' "							+ CHR(13) + CHR(10) // DJALMA BORGES 08/02/2017
	_cQry		+= " AND 		A3_TIPO 	= 	'E' "							+ CHR(13) + CHR(10)
	_cQry		+= " AND 		D_E_L_E_T_	<> 	'*' "							+ CHR(13) + CHR(10)
	_cQry		+= " ORDER BY	A3_COD "										+ CHR(13) + CHR(10)

	MEMOWRIT("\SB_PROTHEUS.SQL",_cQry)
	cQuery := ChangeQuery(_cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	
	aAdd(_aPastas, {})
	
	While ! (cAliasQry)->(Eof())
		
		// Armazeno o C骴igo do Vendedor para par鈓etros dos arquivos 		
		_cVend := (cAliasQry)->A3_COD
		
		// Armazeno o local de grava玢o dos arquivos
		_aPastas[03] :=  _aPastas[02] + "01" + Alltrim(A3_COD) + "\"
		
		// Cria a Pasta do Vendedor em Local
		If !File(_aPastas[03])
			_nRet := MakeDir(_aPastas[03])
		Endif
	
		// Efetua o processamento dos arquivos
		Processa({|| U_SB_MESTRE	( _aPastas[03] , "MESTRE.TXT"	 	, lJob, 			) }	,"Aguarde...","Gerando Arquivo de Registro Mestre...")
		Processa({|| U_SB_CLILOCALZ	( _aPastas[03] , "CLILOCALZ.TXT" 	, lJob, 			) }	,"Aguarde...","Gerando Arquivo de Permissao de Itens...")
		Processa({|| U_SB_VENDEDOR	( _aPastas[03] , "VENDEDOR.TXT"	 	, lJob, _cVend  	) }	,"Aguarde...","Gerando Arquivo de Vendedores...")
		Processa({|| U_SB_CLIENTES	( _aPastas[03] , "CLIENTES.TXT"	 	, lJob, _cVend  	) }	,"Aguarde...","Gerando Arquivo de Clientes...")
		Processa({|| U_SB_CLENDER	( _aPastas[03] , "CLIENDER.TXT"	 	, lJob, _cVend  	) }	,"Aguarde...","Gerando Arquivo de Endere鏾 de Clientes...")
		Processa({|| U_SB_CLIFONES	( _aPastas[03] , "CLIFONES.TXT"	 	, lJob, _cVend  	) }	,"Aguarde...","Gerando Arquivo de Endere鏾 de Clientes...")
		Processa({|| U_SB_CLTEXTO	( _aPastas[03] , "CLITEXTO.TXT"	 	, lJob, _cVend  	) }	,"Aguarde...","Gerando Arquivo de Endere鏾 de Clientes...")
		Processa({|| U_SB_CLGRUPC	( _aPastas[03] , "CLIGRUPC.TXT"	 	, lJob, _cVend  	) }	,"Aguarde...","Gerando Arquivo de Endere鏾 de Clientes...")
		Processa({|| U_SB_NOTAS		( _aPastas[03] , "NOTAS.TXT"	 	, lJob, _cVend  	) }	,"Aguarde...","Gerando Arquivo de Notas Fiscais...")
		Processa({|| U_SB_NOTITE	( _aPastas[03] , "NOTITE.TXT"	 	, lJob, _cVend  	) }	,"Aguarde...","Gerando Arquivo de Itens das Notas Fiscais...")
		Processa({|| U_SB_FINANCA	( _aPastas[03] , "FINANCAS.TXT" 	, lJob, _cVend  	) }	,"Aguarde...","Gerando Arquivo de Contas a Receber...")

	(cAliasQry)->(dbSkip())
	
	EndDo

	_hFim := Time()

	// Grava玢o de Log
	Conout("Tempo de processamento dos arquivos foi de " + ElapTime(_hInicio,_hFim) )
	Conout("==============================================================")

	RestArea(_aArea)
Return

Static Function SchedDef()
	Local aParam 	:= {}
	Local aOrd 		:= {}
	
	aParam := {"P", "PARAMDEF", "", aOrd, }
Return aParam