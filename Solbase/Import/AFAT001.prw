#Include 'Totvs.ch'
#include 'Topconn.ch'
#Include 'TBICONN.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} AFAT001

Específico Cambuci - Programa com a finalidade de importar dados para faturamento de 
planilha em formato TXT para inclusão de Atendimento no Call Center

@author 	Carlos Eduardo Saturnino 
@since 		04/11/2016
@version 	1.0
@see 		Alterar o conteúdo do parâmetro 	MV_NFS_JOB de .F. para .T.
			Criação do campo A1_XPROD, C, 15 
/*///---------------------------------------------------------------------------
User Function AFAT001()
	Local _aArea		:= GetArea()
	Local _cPerg		:= ''
	Local _nx			:= 0

	Private _cPath	:= SuperGetMv( "MV_XDIRINT"	, .F., "C:\TEMP\SOL_BASE")	
	Private aArqs		:= {}
	Private aArqOri	:= {}
	Private _nRet, _hInicio, _hFim
	
	// Cabeçalho da Gravação de Logs
	Conout("")
	Conout("==============================================================")
	Conout("========= Inicio Log Imp. Atend. Protheus X SolBase ==========")
	Conout("==============================================================")

	// Configura o caminho para gravação do arquivo EDI
	If substr(_cPath,Len(_cPath),1) <> '\'
		_cPath += '\'
	Endif
	
	_cPath += "PEDIDOS\"
	
	If !ExistDir(_cPath)		
		MakeDir(_cPath)	
	EndIf
	
	If !ExistDir(_cPath + "PROCESSADOS\")
		MakeDir(_cPath + "PROCESSADOS\")
	EndIf
	
	// Verifica a quantidade de arquivos na pasta 
	aArqOri := Directory(_cPath + "*.PED")

	_hInicio := Time()
	
	for _nx := 1 to Len(aArqOri)
		
		// Incluo o nome do arquivo no Array
		aadd(aArqs, aArqOri[_nx])
		
		// Gravação de Log
		Conout("AFAT001      . Existencia do arquivo " + aArqOri[_nx, 1] + " confirmada. ")
		
		_cPerg := _cPath + aArqs[_nx,1]
		
		// Efetuo a chamada para o programa de importação de arquivo .PED		
		U_ImpPED( _cPerg, _nX)

	next _nx 

	_hFim := Time()
	
	// Gravação de Log
	Conout("Tempo de processamento dos arquivos foi de " + ElapTime(_hInicio,_hFim) )
	Conout("==============================================================")

Return(Nil)
`
//------------------------------------------------------------------------------  
/*/{Protheus.doc} ImpPED
Específico Cambuci - Função responsável por ler o conteúdo do arquivo PED e gravá-los
em variáveis para manipulação.
@author 	Carlos Eduardo Saturnino - (11) 95425.55.92
@since 		03/11/2016
@version 	1.0
/*///------------------------------------------------------------------------------
User Function ImpPED(_cPerg, _nX)
	
	Local cLinha  	:= ""
	Local lPrim   	:= .T.
	Local cCabec 		:= ''
	Local nHandle		:= 0	 
	Local aDados		:= {}

	// Abro o arquivo .PED
	FT_FUSE(_cPerg)
	
	// Determino qual o último registro
	//ProcRegua(FT_FLASTREC())
	
	// Movo o ponteiro para o Primeiro Registro
	FT_FGOTOP()
	
	While !FT_FEOF()
		cLinha := FT_FREADLN()
		
		// Gravo o Registro Reader
		If Substr(cLinha,1,1) == "P"	 
			cCabec	:= cLinha
		Else 
			// Gravo o Registro Detalhe de Itens
			If Substr(cLinha,1,1) == "I"
				AADD(aDados,cLinha)
			Endif
		EndIf

		FT_FSKIP()
	EndDo
	
	// Fecha arquivo
	FT_FUSE()
	
	If Len(aDados) > 0
		U_EAM410(_cPerg, cCabec, aDados, _nX)
	Else
		Conout("AFAT001          . Não há dados no arquivo " + _cPerg + ".Operação Cancelada.")
	Endif

Return(Nil)

//--------------------------------------------------------------------------------
/*/{Protheus.doc} EAM410
Específico Cambuci - Função responsável por gerar o MSExecAuto para a rotina TMKA271

@author	Carlos Eduardo Saturnino - (11) 95425.55.92
@since 		07/11/2016
@version 	1.0
/*///----------------------------------------------------------------------------
User Function EAM410(_cPerg , cCabec , aDados, _nX)

	Local aArea		:= GetArea()
	Local aCabec 		:= {}
	Local aItens 		:= {}
	Local aLinha 		:= {}
	Local aPvlNfs		:= {}
	Local cDoc   		:= ""
	Local _cOpc		:= 3
	Local lRet			:= .F.
	Local _cLine 		:= "Arquivo.: " + _cPerg + Chr(13) + Chr(10)
	Local _cFname		:= ""
	Local cItem			:= "00"
	Local cLogLib		:= ""
	Local cOperVend		:= AllTrim(GetMV("MV_XSBOPER",, "01"))
	Local cFil			:= "0" + Substr(cCabec, 193, 3)
	Local nY, _nRet
	
	PRIVATE lMsErroAuto := .F.
	
	//So processa pedidos da filial corrente
	If cFil <> AllTrim(cFilAnt)
		Return
	EndIf
	
	//Se pedido já não foi importado
	DbSelectArea("SC5")
	DbOrderNickName("IDSOLBASE")
	If !DbSeek(xFilial("SC5") + Substr(cCabec, 02, 08))
		Begin Transaction
		
		// 	Guardo o numero do Proximo Pedido nao utilizado
		cDoc := GetSxeNum("SC5","C5_NUM")	
		
		aCabec := {}
		aItens := {}
		
		aadd(aCabec,{"C5_NUM"   	,cDoc							,Nil})
		aadd(aCabec,{"C5_TIPO" 		,"N"							,Nil})
		aadd(aCabec,{"C5_CLIENTE"	,Substr(cCabec, 031,06)			,Nil})
		aadd(aCabec,{"C5_LOJACLI"	,Substr(cCabec, 037,02)			,Nil})
		aadd(aCabec,{"C5_LOJAENT"	,Substr(cCabec, 037,02)			,Nil})
		aadd(aCabec,{"C5_CONDPAG"	,"001"/*Substr(cCabec, 063,03)*/,Nil})
		aadd(aCabec,{"C5_TRANSP"	,Substr(cCabec, 047,06)			,Nil})
		aadd(aCabec,{"C5_XTIPOPV"	,"PFV"							,Nil})
		aadd(aCabec,{"C5_YCDPALM"	,Substr(cCabec, 02, 08)			,Nil})
		aadd(aCabec,{"C5_YDTIMPR"	,dDataBase						,Nil})
	
		SB1->( dbOrderNickName("XANTIGO") )
		
		For nY := 1 to Len(aDados)
			aLinha := {}
			
			SB1->( dbSeek(xFilial("SB1")+ Substr(aDados[nY],14,08) ))
			 
			aadd(aLinha,{"C6_ITEM"		,Soma1(cItem)							,Nil})
			aadd(aLinha,{"C6_PRODUTO"	,SB1->B1_COD							,Nil})
			aadd(aLinha,{"C6_QTDVEN"	,Val(Substr(aDados[nY],050,09))/1000	,Nil})
			aadd(aLinha,{"C6_QTDLIB"	,Val(Substr(aDados[nY],050,09))/1000	,Nil})
			aadd(aLinha,{"C6_PRCVEN"	,Val(Substr(aDados[nY],069,12))			,Nil})
			aadd(aLinha,{"C6_PRUNIT"	,Val(Substr(aDados[nY],081,12))			,Nil})
			aadd(aLinha,{"C6_VALDESC"	,Val(Substr(aDados[nY],098,12))			,Nil})		
			aadd(aLinha,{"C6_VALOR"		,Val(Substr(aDados[nY],110,13))			,Nil})
			aadd(aLinha,{"C6_OPER"		,cOperVend								,Nil})
			aadd(aLinha,{"C6_PEDCLI"	,Substr(cCabec, 031,06)					,Nil})
			aadd(aLinha,{"AUTDELETA"	,"N"									,Nil})
	
			aadd(aItens,aLinha)
		
		Next nY
	
		DBSELECTAREA("SE1")
		dbSetOrder(1)
		
		// Inclusao		
		MATA410(aCabec,aItens,3)
	
		// Em caso de erro de MSExecAuto grava no diretório c:\Billing\error 
		If lMsErroAuto
	
			// Verifico se existe a pasta \Error, e em caso negativo a crio, e mostro o erro.
			If !ExistDir(_cPath + "Error")
				_nRet := MakeDir(_cPath + "Error")
			Endif
			
			// Apresento o Error.log									
			If !_nRet = 0	
				_cFname := StrTran(aArqs[_nx,1],".PED",".LOG")
				MostraErro(  _cPath + "ERROR\", _cFname )
	    	Endif
			
			RollbackSX8()
	
		Endif
				
		End Transaction
	Else
		cDoc := SC5->C5_NUM
	EndIf
	
	BEGIN TRANSACTION	
	// Desbloqueia crédito ou estoque e posiciona Tabelas para Faturamento
	dbSelectArea("SC6")
	dbSetOrder(1)
	If dbSeek( xFilial("SC6") + cDoc )
		While SC6->C6_FILIAL + SC6->C6_NUM == xFilial("SC6") + cDoc .And. SC6->(! Eof())
			
			//Efetuo a liberação de Credito/Estoque
			MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN, .T., .T., .T., .T. )

			If SC9->C9_FILIAL == SC6->C6_FILIAL .AND. SC9->C9_PEDIDO == SC6->C6_NUM .AND. SC9->C9_ITEM == SC6->C6_ITEM 
				If SC9->C9_BLEST == "02"
					cLogLib += "ERRO - NAO FOI POSSIVEL EFETUAR RESERVA DE MATERIAL:"+SC6->C6_FILIAL+"/"+cDoc+" (EST)" + CRLF
				EndIf

				If ALLTRIM(SC9->C9_BLCRED) <> ""
					cLogLib += "ERRO - NAO FOI POSSIVEL EFETUAR RESERVA DE MATERIAL:"+SC6->C6_FILIAL+"/"+cDoc+" (CRED)" + CRLF
				EndIf
			EndIf
			
			SC6->(dbSkip())
		EndDo
		
		// Altero a legenda do Pedido de Vendas
		MaLiberOk({ cDoc },.T.)
		
		//Se nao houve problemas na liberação
		If Empty(cLogLib) 		
			// Altero a legenda do Pedido de Vendas
			MaLiberOk({ cDoc },.T.)
			//Move para processados
			FRename(_cPath + aArqs[_nx,1], _cPath + "PROCESSADOS\" + aArqs[_nx,1])
		Else
			If !ExistDir(_cPath + "Error")
				_nRet := MakeDir(_cPath + "Error")
			Endif
															
			If !_nRet = 0	
				_cFname := StrTran(aArqs[_nx,1],".PED",".LOG")
				Conout("Processo nõo concluido. Verificar arquivo! " + _cFname)
				MemoWrite(  _cPath + "ERROR\" + _cFname, cLogLib)
			EndIf
		EndIf
		
		
		//Parametros ExpA1 : A - Array com os itens a serem gerados		 
		//           ExpC2 : C - Serie da Nota Fiscal 
		//           ExpL3 : F - Mostra Lct.Contabil 
		//           ExpL4 : F - Aglutina Lct.Contabil 
		//           ExpL5 : T - Contabiliza On-Line 
		//           ExpL6 : T - Contabiliza Custo On-Line 
		//           ExpL7 : F - Reajuste de preco na nota fiscal 
		//           ExpN8 : 0 - Tipo de Acrescimo Financeiro 
		//           ExpN9 : 0 - Tipo de Arredondamento 
		//           ExpLA : T - Atualiza Amarracao Cliente x Produto 
		//           ExplB : F - Cupom Fiscal 
		//           ExpCC : C - Numero do Embarque de Exportacao 
		//           ExpBD : 	Code block para complemento de atualizacao dos titulos financeiros. 
		//           ExpBE : 	Code block para complemento de atualizacao dos dados apos a geracao da nota fiscal. 
		//           ExpBF : 	Code Block de atualizacao do pedido de venda antes da geracao da nota fiscal. 
	Endif
	
	END TRANSACTION
	
	RestArea(aArea)
	
Return(.T.)


Static Function SchedDef()
	Local aParam 	:= {}
	Local aOrd 		:= {}
	
	aParam := {"P", "PARAMDEF", "", aOrd, }
Return aParam
