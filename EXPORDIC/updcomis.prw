#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} UPDCOMIS
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  10/12/2015
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPDCOMIS( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça um"
Local   cDesc4    := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
Local   cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk
	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else
		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Atualização Realizada.", "UPDCOMIS" )
				Else
					MsgStop( "Atualização não Realizada.", "UPDCOMIS" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualização Concluída." )
				Else
					Final( "Atualização não Realizada." )
				EndIf
			EndIf

		Else
			MsgStop( "Atualização não Realizada.", "UPDCOMIS" )

		EndIf

	Else
		MsgStop( "Atualização não Realizada.", "UPDCOMIS" )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  10/12/2015
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// Só adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Versão.............: " + GetVersao(.T.) )
			AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Estação............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicionário SX2
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX2()

			//------------------------------------
			// Atualiza o dicionário SX3
			//------------------------------------
			FSAtuSX3()

			//------------------------------------
			// Atualiza o dicionário SIX
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de índices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSIX()

			oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices" )

			// Alteração física dos arquivos
			__SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
					AutoGrLog( "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] )
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX

			//------------------------------------
			// Atualiza o dicionário SX6
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de parâmetros" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX6()

			//------------------------------------
			// Atualiza o dicionário SX7
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de gatilhos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX7()

			//------------------------------------
			// Atualiza o dicionário SXA
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de pastas" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSXA()

			//------------------------------------
			// Atualiza o dicionário SXB
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de consultas padrão" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSXB()

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()

		Next nI

		If !lAuto

			cTexto := LeLog()

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX2
Função de processamento da gravação do SX2 - Arquivos

@author TOTVS Protheus
@since  10/12/2015
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX2()
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cCpoUpd   := "X2_ROTINA /X2_UNICO  /X2_DISPLAY/X2_SYSOBJ /X2_USROBJ /X2_POSLGT /"
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SX2" + CRLF )

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"   , "X2_NOMESPA", "X2_NOMEENG", "X2_MODO"   , ;
             "X2_TTS"    , "X2_ROTINA" , "X2_PYME"   , "X2_UNICO"  , "X2_DISPLAY", "X2_SYSOBJ" , "X2_USROBJ" , ;
             "X2_POSLGT" , "X2_CLOB"   , "X2_AUTREC" , "X2_MODOEMP", "X2_MODOUN" , "X2_MODULO" }


dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Tabela SZ2
//
aAdd( aSX2, { ;
	'SZ2'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'SZ2'+cEmpr																, ; //X2_ARQUIVO
	'ITENS REGRA COMISSIONAMENTO'											, ; //X2_NOME
	'ITENS REGRA COMISSIONAMENTO'											, ; //X2_NOMESPA
	'ITENS REGRA COMISSIONAMENTO'											, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( "Atualizando Arquivos (SX2)..." )

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			AutoGrLog( "Foi incluída a tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		MsUnLock()

	Else

		If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), " ", "" ) )
			RecLock( "SX2", .F. )
			SX2->X2_UNICO := aSX2[nI][12]
			MsUnlock()

			If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + "_UNQ"  )
				TcInternal( 60, RetSqlName( aSX2[nI][1] ) + "|" + RetSqlName( aSX2[nI][1] ) + "_UNQ" )
			EndIf

			AutoGrLog( "Foi alterada a chave única da tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .F. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If PadR( aEstrut[nJ], 10 ) $ cCpoUpd
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf

			EndIf
		Next nJ
		MsUnLock()

	EndIf

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  10/12/2015
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local cX3Campo  := ""
Local cX3Dado   := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nPosVld   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX3" + CRLF )

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
             { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
             { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
             { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
             { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
             { "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_POSLGT" , 0 }, { "X3_IDXFLD" , 0 }, ;
             { "X3_AGRUP"  , 0 }, { "X3_MODAL"  , 0 }, { "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )


//
// Campos Tabela SA1
//
aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'N3'																	, ; //X3_ORDEM
	'A1_XGRPPES'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Grupo Pessoa'															, ; //X3_TITULO
	'Grupo Pessoa'															, ; //X3_TITSPA
	'Grupo Pessoa'															, ; //X3_TITENG
	'Grupo Pessoa'															, ; //X3_DESCRIC
	'Grupo Pessoa'															, ; //X3_DESCSPA
	'Grupo Pessoa'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'ZZJ'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	"existcpo('ZZJ',M->A1_XGRPPES)"											, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'5'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SB1
//
aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'B1_XLINHA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Linha'																	, ; //X3_TITULO
	'Linha'																	, ; //X3_TITSPA
	'Linha'																	, ; //X3_TITENG
	'Linha do Produto'														, ; //X3_DESCRIC
	'Linha do Produto'														, ; //X3_DESCSPA
	'Linha do Produto'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'ZZC'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'16'																	, ; //X3_ORDEM
	'B1_XMARCA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Marca'																	, ; //X3_TITULO
	'Marca'																	, ; //X3_TITSPA
	'Marca'																	, ; //X3_TITENG
	'Marca do Produto'														, ; //X3_DESCRIC
	'Marca do Produto'														, ; //X3_DESCSPA
	'Marca do Produto'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'ZZB'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SC5
//
aAdd( aSX3, { ;
	'SC5'																	, ; //X3_ARQUIVO
	'G8'																	, ; //X3_ORDEM
	'C5_XTIPOPV'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Origem Venda'															, ; //X3_TITULO
	'Origem Venda'															, ; //X3_TITSPA
	'Origem Venda'															, ; //X3_TITENG
	'Origem Venda'															, ; //X3_DESCRIC
	'Origem Venda'															, ; //X3_DESCSPA
	'Origem Venda'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'PERTENCE("PEG|PTM|PEX|PFV")'											, ; //X3_VLDUSER
	'PEG=TELEV;PTM=TLV MARINGA;PEX=PV EXTERNO;PFV=FORCA VENDA'				, ; //X3_CBOX
	'PEG=TELEV;PTM=TLV MARINGA;PEX=PV EXTERNO;PFV=FORCA VENDA'				, ; //X3_CBOXSPA
	'PEG=TELEV;PTM=TLV MARINGA;PEX=PV EXTERNO;PFV=FORCA VENDA'				, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SZ2
//
aAdd( aSX3, { ;
	'SZ2'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'Z2_FILIAL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ2'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'Z2_CODIGO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Tabela'															, ; //X3_TITULO
	'Cod. Tabela'															, ; //X3_TITSPA
	'Cod. Tabela'															, ; //X3_TITENG
	'Cod. Tabela'															, ; //X3_DESCRIC
	'Cod. Tabela'															, ; //X3_DESCSPA
	'Cod. Tabela'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ2'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'Z2_ORDEM'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ordem'																	, ; //X3_TITULO
	'Ordem'																	, ; //X3_TITSPA
	'Ordem'																	, ; //X3_TITENG
	'Ordem'																	, ; //X3_DESCRIC
	'Ordem'																	, ; //X3_DESCSPA
	'Ordem'																	, ; //X3_DESCENG
	'9999'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ2'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'Z2_TX1'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Taxa 1'																, ; //X3_TITULO
	'Taxa 1'																, ; //X3_TITSPA
	'Taxa 1'																, ; //X3_TITENG
	'Taxa 1'																, ; //X3_DESCRIC
	'Taxa 1'																, ; //X3_DESCSPA
	'Taxa 1'																, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ2'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'Z2_TX2'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Taxa 2'																, ; //X3_TITULO
	'Taxa 2'																, ; //X3_TITSPA
	'Taxa 2'																, ; //X3_TITENG
	'Taxa 2'																, ; //X3_DESCRIC
	'Taxa 2'																, ; //X3_DESCSPA
	'Taxa 2'																, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ2'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'Z2_VEND'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Representant'															, ; //X3_TITULO
	'Representant'															, ; //X3_TITSPA
	'Representant'															, ; //X3_TITENG
	'Representante'															, ; //X3_DESCRIC
	'Representante'															, ; //X3_DESCSPA
	'Representante'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SA3'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'existcpo("SA3")'														, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ2'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'Z2_TIPOREP'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo Represe'															, ; //X3_TITULO
	'Tipo Represe'															, ; //X3_TITSPA
	'Tipo Represe'															, ; //X3_TITENG
	'Tipo Representante'													, ; //X3_DESCRIC
	'Tipo Representante'													, ; //X3_DESCSPA
	'Tipo Representante'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	'pertence("IE")'														, ; //X3_VLDUSER
	'I=Interno;E=Externo'													, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ2'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'Z2_NOMEVEN'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome Repr.'															, ; //X3_TITULO
	'Nome Repr.'															, ; //X3_TITSPA
	'Nome Repr.'															, ; //X3_TITENG
	'Nome Representante'													, ; //X3_DESCRIC
	'Nome Representante'													, ; //X3_DESCSPA
	'Nome Representante'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ2'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'Z2_ITEMGRP'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Item Grupo'															, ; //X3_TITULO
	'Item Grupo'															, ; //X3_TITSPA
	'Item Grupo'															, ; //X3_TITENG
	'Item Grupo'															, ; //X3_DESCRIC
	'Item Grupo'															, ; //X3_DESCSPA
	'Item Grupo'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SBM'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'existcpo("SBM")'														, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ2'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'Z2_NOMEGRU'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome Grupo'															, ; //X3_TITULO
	'Nome Grupo'															, ; //X3_TITSPA
	'Nome Grupo'															, ; //X3_TITENG
	'Nome Grupo'															, ; //X3_DESCRIC
	'Nome Grupo'															, ; //X3_DESCSPA
	'Nome Grupo'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ2'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'Z2_TPED'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo Pedido'															, ; //X3_TITULO
	'Tipo Pedido'															, ; //X3_TITSPA
	'Tipo Pedido'															, ; //X3_TITENG
	'Tipo Pedido'															, ; //X3_DESCRIC
	'Tipo Pedido'															, ; //X3_DESCSPA
	'Tipo Pedido'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'PERTENCE("PEG|PTM|PEX|PFV")'											, ; //X3_VLDUSER
	'PEG=TELEV;PTM=TLV MARINGA;PEX=PV EXTERNO;PFV=FORCA VENDA'				, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ2'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'Z2_ITEMMAR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Item Marca'															, ; //X3_TITULO
	'Item Marca'															, ; //X3_TITSPA
	'Item Marca'															, ; //X3_TITENG
	'Item Marca'															, ; //X3_DESCRIC
	'Item Marca'															, ; //X3_DESCSPA
	'Item Marca'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'ZZB'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	"existcpo('ZZB',M->Z2_ITEMMAR)"											, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ2'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'Z2_GRUPOPE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Grupo Pessoa'															, ; //X3_TITULO
	'Grupo Pessoa'															, ; //X3_TITSPA
	'Grupo Pessoa'															, ; //X3_TITENG
	'Grupo Pessoa'															, ; //X3_DESCRIC
	'Grupo Pessoa'															, ; //X3_DESCSPA
	'Grupo Pessoa'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'ZZJ'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ2'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'Z2_LINHA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Linha'																	, ; //X3_TITULO
	'Linha'																	, ; //X3_TITSPA
	'Linha'																	, ; //X3_TITENG
	'Linha'																	, ; //X3_DESCRIC
	'Linha'																	, ; //X3_DESCSPA
	'Linha'																	, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'ZZC'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ2'																	, ; //X3_ARQUIVO
	'15'																	, ; //X3_ORDEM
	'Z2_SEQUENC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Sequencia'																, ; //X3_TITULO
	'Sequencia'																, ; //X3_TITSPA
	'Sequencia'																, ; //X3_TITENG
	'Sequencia'																, ; //X3_DESCRIC
	'Sequencia'																, ; //X3_DESCSPA
	'Sequencia'																, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'GETSXENUM("SZ2","Z2_SEQUENC")'											, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME


//
// Atualizando dicionário
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo] + " NÃO atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )

			ElseIf aEstrut[nJ][2] > 0
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ] ) )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		AutoGrLog( "Criado campo " + aSX3[nI][nPosCpo] )

	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSIX
Função de processamento da gravação do SIX - Indices

@author TOTVS Protheus
@since  10/12/2015
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSIX()
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SIX" + CRLF )

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
             "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

//
// Tabela SC5
//
aAdd( aSIX, { ;
	'SC5'																	, ; //INDICE
	'6'																		, ; //ORDEM
	'C5_FILIAL+C5_CLIENTE+C5_LOJACLI+C5_NOTA+C5_SERIE+C5_NUM'				, ; //CHAVE
	'Cliente+Loja+Nota Fiscal+Serie+Numero'									, ; //DESCRICAO
	'Cliente+Loja+Nota Fiscal+Serie+Numero'									, ; //DESCSPA
	'Cliente+Loja+Nota Fiscal+Serie+Numero'									, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'C5_NOTACLI'															, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SZ2
//
aAdd( aSIX, { ;
	'SZ2'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'Z2_FILIAL+Z2_CODIGO+Z2_ORDEM'											, ; //CHAVE
	'Cod. Tabela+Ordem'														, ; //DESCRICAO
	'Cod. Tabela+Ordem'														, ; //DESCSPA
	'Cod. Tabela+Ordem'														, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt    := .F.
	lDelInd := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		AutoGrLog( "Índice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
	Else
		lAlt := .T.
		aAdd( aArqUpd, aSIX[nI][1] )
		If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "" ) == ;
		    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
			AutoGrLog( "Chave do índice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
			lDelInd := .T. // Se for alteração precisa apagar o indice do banco
		EndIf
	EndIf

	RecLock( "SIX", !lAlt )
	For nJ := 1 To Len( aSIX[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
		EndIf
	Next nJ
	MsUnLock()

	dbCommit()

	If lDelInd
		TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] )
	EndIf

	oProcess:IncRegua2( "Atualizando índices..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX6
Função de processamento da gravação do SX6 - Parâmetros

@author TOTVS Protheus
@since  10/12/2015
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX6()
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lContinua := .T.
Local lReclock  := .T.
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )

AutoGrLog( "Ínicio da Atualização" + " SX6" + CRLF )

aEstrut := { "X6_FIL"    , "X6_VAR"    , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , ;
             "X6_DSCSPA1", "X6_DSCENG1", "X6_DESC2"  , "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", ;
             "X6_CONTENG", "X6_PROPRI" , "X6_VALID"  , "X6_INIT"   , "X6_DEFPOR" , "X6_DEFSPA" , "X6_DEFENG" , ;
             "X6_PYME"   }

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CB_VIMPXML'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Ativa a validacao do Schema do XML. Utilizada na'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'rotina de Importacao das Notas de Saida (CAMBM006)'					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CB_VPSTXML'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define a pasta com os Schemas das notas para a'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'validacao. Utilizada na rotina de Importacao das'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Notas de Saida (CAMBM006)'												, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'\SCHEMAS\'																, ; //X6_CONTEUD
	'\SCHEMAS\'																, ; //X6_CONTSPA
	'\SCHEMAS\'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CB_XIMPCPG'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define a condicao de pagamento padrao utilizada na'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'rotina de Importacao das Notas de Saida (CAMBM006)'					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'001'																	, ; //X6_CONTEUD
	'001'																	, ; //X6_CONTSPA
	'001'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CB_XPSTCD5'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define a pasta para gravacao dos itens importados'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'corretamente atraves da rotina de Importacao de'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Complemento de Importacao (CAMBM010)'									, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'\IMPORTACAO\CD5\'														, ; //X6_CONTEUD
	'\IMPORTACAO\CD5\'														, ; //X6_CONTSPA
	'\IMPORTACAO\CD5\'														, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CB_XPSTCDU'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define a pasta para gravacao dos itens importados'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'corretamente atraves da rotina de Importacao dos'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Saldos da CAT 83 (CAMBM008)'											, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'\IMPORTACAO\CDU\'														, ; //X6_CONTEUD
	'\IMPORTACAO\CDU\'														, ; //X6_CONTSPA
	'\IMPORTACAO\CDU\'														, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CB_XPSTNFE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define a pasta para gravacao dos itens importados'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'atraves da rotina de Importacao das Notas'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'de Entrada (CAMBM005)'													, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'\IMPORTACAO\NFE\NFE\'													, ; //X6_CONTEUD
	'\IMPORTACAO\NFE\NFE\'													, ; //X6_CONTSPA
	'\IMPORTACAO\NFE\NFE\'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CB_XPSTNFS'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define a pasta para gravacao dos itens importados'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'corretamente atraves da rotina de Importacao das'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Notas de Saida (CAMBM006)'												, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'\IMPORTACAO\NFE\NFS\'													, ; //X6_CONTEUD
	'\IMPORTACAO\NFE\NFS\'													, ; //X6_CONTSPA
	'\IMPORTACAO\NFE\NFS\'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CB_XPSTSD3'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define a pasta para gravacao dos itens importados'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'corretamente atraves da rotina de Importacao das'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Movimentacoes de Estoque (CAMBM007)'									, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'\IMPORTACAO\SD3\'														, ; //X6_CONTEUD
	'\IMPORTACAO\SD3\'														, ; //X6_CONTSPA
	'\IMPORTACAO\SD3\'														, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CB_XPSTSF3'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define a pasta para gravacao dos itens importados'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'corretamente atraves da rotina de Importacao dos'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Livros Fiscais de Entrada e Saida (CAMBM011)'							, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'\IMPORTACAO\SF3\'														, ; //X6_CONTEUD
	'\IMPORTACAO\SF3\'														, ; //X6_CONTSPA
	'\IMPORTACAO\SF3\'														, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CB_XPSTSFK'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define a pasta para gravacao dos itens importados'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'corretamente atraves da rotina de Importacao dos'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Saldos da CAT 17 (CAMBM009)'											, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'\IMPORTACAO\SFK\'														, ; //X6_CONTEUD
	'\IMPORTACAO\SFK\'														, ; //X6_CONTSPA
	'\IMPORTACAO\SFK\'														, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CB_XPSTSFT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define a pasta para gravacao dos itens importados'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'corretamente atraves da rotina de Importacao dos'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Itens dos Livros Fiscais Entrada Saida (CAMBM012)'						, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'\IMPORTACAO\SFT\'														, ; //X6_CONTEUD
	'\IMPORTACAO\SFT\'														, ; //X6_CONTSPA
	'\IMPORTACAO\SFT\'														, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_ALTPORT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo dos Titulos que poderao sofrer alteracoes no'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Portador (E1_PORTADO) - F040CPO'										, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'NF/FT'																	, ; //X6_CONTEUD
	'NF/FT'																	, ; //X6_CONTSPA
	'NF/FT'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_MAILWFF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Endereco de e-mail para copia do e-mail (workflow)'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'das Faturas a Receber (CAMBM003)'										, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'cambuci@cambuci.com.br'												, ; //X6_CONTEUD
	'cambuci@cambuci.com.br'												, ; //X6_CONTSPA
	'cambuci@cambuci.com.br'												, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_PSTWFFT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Pasta onde sera salvo o HTML de envio do workflow'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'das Faturas (CAMBM003)'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'\workflow\Html\Faturas'												, ; //X6_CONTEUD
	'\workflow\Html\Faturas'												, ; //X6_CONTSPA
	'\workflow\Html\Faturas'												, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_TPCONAD'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo do Contato Admnistrativo (SU5) para envio de'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'E-mail (workflow) - CAMBM003'											, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'000000004'																, ; //X6_CONTEUD
	'000000004'																, ; //X6_CONTSPA
	'000000004'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_TPCONFT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo do Contato Fatura (SU5) para envio de E-mail'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'(workflow) - CAMBM003'													, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'000000003'																, ; //X6_CONTEUD
	'000000003'																, ; //X6_CONTSPA
	'000000003'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_TPTITCR'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipos de titulos que deverao ser demonstrados na r'					, ; //X6_DESCRIC
	'Tipos de titulos que deverao ser demonstrados na r'					, ; //X6_DSCSPA
	'Tipos de titulos que deverao ser demonstrados na r'					, ; //X6_DSCENG
	'otina de Renegociacao - Cambuci - Separado por /'						, ; //X6_DESC1
	'otina de Renegociacao - Cambuci'										, ; //X6_DSCSPA1
	'otina de Renegociacao - Cambuci'										, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'NF'																	, ; //X6_CONTEUD
	'NF'																	, ; //X6_CONTSPA
	'NF'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_UFICM'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'UF dos Estados onde devem haver quebra aliq icms'						, ; //X6_DESCRIC
	'UF dos Estados onde devem haver quebra aliq icms'						, ; //X6_DSCSPA
	'UF dos Estados onde devem haver quebra aliq icms'						, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RO'																	, ; //X6_CONTEUD
	'RO'																	, ; //X6_CONTSPA
	'RO'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_XENDPAD'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Endereco padrao para o enderecamento automatico'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'nos Documentos de Entrada (MT103FIM)'									, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RUA 1'																	, ; //X6_CONTEUD
	'RUA 1'																	, ; //X6_CONTSPA
	'RUA 1'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_XLOCPAD'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Armazem que tera o enderecamento automatico nos'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Documentos de Entrada (MT103FIM)'										, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'01'																	, ; //X6_CONTEUD
	'01'																	, ; //X6_CONTSPA
	'01'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_GCTCOT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo Contrato para cotacao'											, ; //X6_DESCRIC
	'Tipo Contrato para cotizacion'											, ; //X6_DSCSPA
	'Contract type for quotation'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'001'																	, ; //X6_CONTEUD
	'001'																	, ; //X6_CONTSPA
	'001'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'001'																	, ; //X6_DEFPOR
	'001'																	, ; //X6_DEFSPA
	'001'																	, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_ PERCAT'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Percentual da Carga Tributaria Media, do destinata'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'rio MT.'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'16'																	, ; //X6_CONTEUD
	'16'																	, ; //X6_CONTSPA
	'16'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_DCTF000'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Referencia de codigos de retencäo do sistema para'						, ; //X6_DESCRIC
	'Referencia de cod. de retencion del sistema para'						, ; //X6_DSCSPA
	'Reference of the system withholding codes for'							, ; //X6_DSCENG
	'os adotados pela DCTF com a periodicidade'								, ; //X6_DESC1
	'los adoptados por DCTF con la periodicidad'							, ; //X6_DSCSPA1
	'those adopted by DCTF with the corresponding'							, ; //X6_DSCENG1
	'correspondente'														, ; //X6_DESC2
	'correspondiente'														, ; //X6_DSCSPA2
	'periodicity.'															, ; //X6_DSCENG2
	'5952=595202Q;8045=804506M;1708=170806M;0561=056107M;5123=512301M;6912=691201M;5856=585601M;2362=236201M;2484=248401M;3208=320806M;5960=596004Q;5979=597904Q;5993=599301M;1097=109702M;8190=810902M;', ; //X6_CONTEUD
	'5952=595202Q;8045=804506M;1708=170806M;0561=056107M;5123=512301M;6912=691201M;5856=585601M;2362=236201M;2484=248401M;3208=320806M;5960=596004Q;5979=597904Q;5993=599301M;1097=109702M;8190=810902M;', ; //X6_CONTSPA
	'5952=595202Q;8045=804506M;1708=170806M;0561=056107M;5123=512301M;6912=691201M;5856=585601M;2362=236201M;2484=248401M;3208=320806M;5960=596004Q;5979=597904Q;5993=599301M;1097=109702M;8190=810902M;', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XCALIPI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Grupos de Tributacao'													, ; //X6_DESCRIC
	'Grupos de Tributacao'													, ; //X6_DSCSPA
	'Grupos de Tributacao'													, ; //X6_DSCENG
	'Que devem calcular IPI no GeoSales'									, ; //X6_DESC1
	'Que devem calcular IPI no GeoSales'									, ; //X6_DSCSPA1
	'Que devem calcular IPI no GeoSales'									, ; //X6_DSCENG1
	'Que devem calcular IPI no GeoSales'									, ; //X6_DESC2
	'Que devem calcular IPI no GeoSales'									, ; //X6_DSCSPA2
	'Que devem calcular IPI no GeoSales'									, ; //X6_DSCENG2
	'3RI/ZMI/ZMS/STS/STI/ODS/ODE'											, ; //X6_CONTEUD
	'3RI/ZMI/ZMS/STS/STI/ODS/ODE'											, ; //X6_CONTSPA
	'3RI/ZMI/ZMS/STS/STI/ODS/ODE'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XGERTXT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	']Hora de extracao de dados'											, ; //X6_DESCRIC
	']Hora de extracao de dados'											, ; //X6_DSCSPA
	']Hora de extracao de dados'											, ; //X6_DSCENG
	'Para o GeoSales'														, ; //X6_DESC1
	'Para o GeoSales'														, ; //X6_DSCSPA1
	'Para o GeoSales'														, ; //X6_DSCENG1
	'Para o GeoSales'														, ; //X6_DESC2
	'Para o GeoSales'														, ; //X6_DSCSPA2
	'Para o GeoSales'														, ; //X6_DSCENG2
	'07:00'																	, ; //X6_CONTEUD
	'07:00'																	, ; //X6_CONTSPA
	'07:00'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESCRIC
	'Informar en este parametro el nombre del municipi'						, ; //X6_DSCSPA
	'Enter the name of the city referring to the Tax'						, ; //X6_DSCENG
	'esta estabelecido.'													, ; //X6_DESC1
	'donde el Contribuyente esta establecido'								, ; //X6_DSCSPA1
	'Payer in this parameter'												, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'MARINGA'																, ; //X6_CONTEUD
	'MARINGA'																, ; //X6_CONTSPA
	'MARINGA'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'MV_DCTF000'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Referencia de codigos de retencäo do sistema para'						, ; //X6_DESCRIC
	'Referencia de cod. de retencion del sistema para'						, ; //X6_DSCSPA
	'Reference of the system withholding codes for'							, ; //X6_DSCENG
	'os adotados pela DCTF com a periodicidade'								, ; //X6_DESC1
	'los adoptados por DCTF con la periodicidad'							, ; //X6_DSCSPA1
	'those adopted by DCTF with the corresponding'							, ; //X6_DSCENG1
	'correspondente'														, ; //X6_DESC2
	'correspondiente'														, ; //X6_DSCSPA2
	'periodicity.'															, ; //X6_DSCENG2
	'5952=595202Q;8045=804506M;1708=170806M;0561=056107M;5123=512301M;6912=691201M;5856=585601M;2362=236201M;2484=248401M;3208=320806M;5960=596004Q;5979=597904Q;5993=599301M;1097=109702M;8190=810902M;', ; //X6_CONTEUD
	'5952=595202Q;8045=804506M;1708=170806M;0561=056107M;5123=512301M;6912=691201M;5856=585601M;2362=236201M;2484=248401M;3208=320806M;5960=596004Q;5979=597904Q;5993=599301M;1097=109702M;8190=810902M;', ; //X6_CONTSPA
	'5952=595202Q;8045=804506M;1708=170806M;0561=056107M;5123=512301M;6912=691201M;5856=585601M;2362=236201M;2484=248401M;3208=320806M;5960=596004Q;5979=597904Q;5993=599301M;1097=109702M;8190=810902M;', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema, pa-'					, ; //X6_DESCRIC
	'Abreviatura de la estado de la empresa usuaria'						, ; //X6_DSCSPA
	'State abbreviation referring to the system user'						, ; //X6_DSCENG
	'ra efeito de calculo de ICMS (7, 12 ou 18%).'							, ; //X6_DESC1
	'del sistema a efectos de calculo del ICMS'								, ; //X6_DSCSPA1
	'code, for the purpose of calculating the'								, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	'(7, 12 o 18%).'														, ; //X6_DSCSPA2
	'ICMS (7,12 OR 18%).'													, ; //X6_DSCENG2
	'PR'																	, ; //X6_CONTEUD
	'PR'																	, ; //X6_CONTSPA
	'PR'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'MV_ICMPAD'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informar a aliquota de ICMS aplicada em  operacoes'					, ; //X6_DESCRIC
	'Informar la alicuota de ICMS aplicada en operacio-'					, ; //X6_DSCSPA
	'Inform the value added tax rate, applied in the'						, ; //X6_DSCENG
	'dentro do estado onde a empresa esta localizada.'						, ; //X6_DESC1
	'nes dentro de la provincia donde se localiza la'						, ; //X6_DSCSPA1
	'operation within the states, in which the company'						, ; //X6_DSCENG1
	'(17 ou 18) %'															, ; //X6_DESC2
	'empresa. (17 o 18) %'													, ; //X6_DSCSPA2
	'is localized (17 or 18%).'												, ; //X6_DSCENG2
	'12'																	, ; //X6_CONTEUD
	'12'																	, ; //X6_CONTSPA
	'12'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'MV_TXCOFIN'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Taxa para calculo da COFINS.'											, ; //X6_DESCRIC
	'Tasa para calculo del COFINS.'											, ; //X6_DSCSPA
	'Rate for COFINS calculation.'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'7.6'																	, ; //X6_CONTEUD
	'7.6'																	, ; //X6_CONTSPA
	'7.6'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'MV_TXPIS'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Taxa para calculo do PIS.'												, ; //X6_DESCRIC
	'Tasa para calculo del PIS.'											, ; //X6_DSCSPA
	'Rate for PIS calculation.'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1.65'																	, ; //X6_CONTEUD
	'1.65'																	, ; //X6_CONTSPA
	'1.65'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'MV_ULMES'																, ; //X6_VAR
	'D'																		, ; //X6_TIPO
	'Data ultimo fechamento do estoque.'									, ; //X6_DESCRIC
	'Fecha del ultimo cierre de stock.'										, ; //X6_DSCSPA
	'Inventory last closing date.'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'20151202'																, ; //X6_CONTEUD
	'20151202'																, ; //X6_CONTSPA
	'20151202'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0102'																	, ; //X6_FIL
	'MV_CAT8309'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Utiliza portaria CAT83'												, ; //X6_DESCRIC
	'Utiliza porteria CAT83'												, ; //X6_DSCSPA
	'Use decree CAT83'														, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0102'																	, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESCRIC
	'Informar en este parametro el nombre del municipi'						, ; //X6_DSCSPA
	'Enter the name of the city referring to the Tax'						, ; //X6_DSCENG
	'esta estabelecido.'													, ; //X6_DESC1
	'donde el Contribuyente esta establecido'								, ; //X6_DSCSPA1
	'Payer in this parameter'												, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'MARINGA'																, ; //X6_CONTEUD
	'MARINGA'																, ; //X6_CONTSPA
	'MARINGA'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0102'																	, ; //X6_FIL
	'MV_DIAISS'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Dia padrao para gerar os titulos de  ISS.'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'20'																	, ; //X6_CONTEUD
	'20'																	, ; //X6_CONTSPA
	'20'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0102'																	, ; //X6_FIL
	'MV_ENQLEG'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Definir Codigo Enq. Legal para cada UF conforme'						, ; //X6_DESCRIC
	'Definir Codigo Enq. Legal para cada UF conforme'						, ; //X6_DSCSPA
	'Definir Codigo Enq. Legal para cada UF conforme'						, ; //X6_DSCENG
	'aliquota (estadual ou interestadual).'									, ; //X6_DESC1
	'aliquota (estadual ou interestadual).'									, ; //X6_DSCSPA1
	'aliquota (estadual ou interestadual).'									, ; //X6_DSCENG1
	'Exemplo de uso: SP01MG02RJ02'											, ; //X6_DESC2
	'Exemplo de uso: SP01MG02RJ02'											, ; //X6_DSCSPA2
	'Exemplo de uso: SP01MG02RJ02'											, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0102'																	, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema, pa-'					, ; //X6_DESCRIC
	'Abreviatura de la estado de la empresa usuaria'						, ; //X6_DSCSPA
	'State abbreviation referring to the system user'						, ; //X6_DSCENG
	'ra efeito de calculo de ICMS (7, 12 ou 18%).'							, ; //X6_DESC1
	'del sistema a efectos de calculo del ICMS'								, ; //X6_DSCSPA1
	'code, for the purpose of calculating the'								, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	'(7, 12 o 18%).'														, ; //X6_DSCSPA2
	'ICMS (7,12 OR 18%).'													, ; //X6_DSCENG2
	'PR'																	, ; //X6_CONTEUD
	'PR'																	, ; //X6_CONTSPA
	'PR'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0102'																	, ; //X6_FIL
	'MV_ICMPAD'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informar a aliquota de ICMS aplicada em  operacoes'					, ; //X6_DESCRIC
	'Informar la alicuota de ICMS aplicada en operacio-'					, ; //X6_DSCSPA
	'Inform the value added tax rate, applied in the'						, ; //X6_DSCENG
	'dentro do estado onde a empresa esta localizada.'						, ; //X6_DESC1
	'nes dentro de la provincia donde se localiza la'						, ; //X6_DSCSPA1
	'operation within the states, in which the company'						, ; //X6_DSCENG1
	'(17 ou 18) %'															, ; //X6_DESC2
	'empresa. (17 o 18) %'													, ; //X6_DSCSPA2
	'is localized (17 or 18%).'												, ; //X6_DSCENG2
	'12'																	, ; //X6_CONTEUD
	'12'																	, ; //X6_CONTSPA
	'12'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0102'																	, ; //X6_FIL
	'MV_MODRISS'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define o modo de retencao do ISSQN.'									, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0102'																	, ; //X6_FIL
	'MV_TXCOFIN'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Taxa para calculo da COFINS.'											, ; //X6_DESCRIC
	'Tasa para calculo del COFINS.'											, ; //X6_DSCSPA
	'Rate for COFINS calculation.'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'7.6'																	, ; //X6_CONTEUD
	'7.6'																	, ; //X6_CONTSPA
	'7.6'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0102'																	, ; //X6_FIL
	'MV_TXPIS'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Taxa para calculo do PIS.'												, ; //X6_DESCRIC
	'Tasa para calculo del PIS.'											, ; //X6_DSCSPA
	'Rate for PIS calculation.'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1.65'																	, ; //X6_CONTEUD
	'1.65'																	, ; //X6_CONTSPA
	'1.65'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0102'																	, ; //X6_FIL
	'MV_ULMES'																, ; //X6_VAR
	'D'																		, ; //X6_TIPO
	'Data ultimo fechamento do estoque.'									, ; //X6_DESCRIC
	'Fecha del ultimo cierre de stock.'										, ; //X6_DSCSPA
	'Inventory last closing date.'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'20151202'																, ; //X6_CONTEUD
	'20151202'																, ; //X6_CONTSPA
	'20151202'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0102'																	, ; //X6_FIL
	'MV_VRETISS'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Valor minimo para dispensa de retencao de ISS'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'15.00'																	, ; //X6_CONTEUD
	'15.00'																	, ; //X6_CONTSPA
	'15.00'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESCRIC
	'Informar en este parametro el nombre del municipi'						, ; //X6_DSCSPA
	'Enter the name of the City reffering to the Tax'						, ; //X6_DSCENG
	'esta estabelecido.'													, ; //X6_DESC1
	'donde El Contribuinte esta estabelecido'								, ; //X6_DSCSPA1
	'Payer in this parameter'												, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'MARINGA'																, ; //X6_CONTEUD
	'MARINGA'																, ; //X6_CONTSPA
	'MARINGA'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'MV_DCTF000'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Referencia de codigos de retencäo do sistema para'						, ; //X6_DESCRIC
	'Referencia de cod. de retencion del sistema para'						, ; //X6_DSCSPA
	'Reference of the system withholding codes for'							, ; //X6_DSCENG
	'os adotados pela DCTF com a periodicidade'								, ; //X6_DESC1
	'los adoptados por DCTF con la periodicidad'							, ; //X6_DSCSPA1
	'those adopted by DCTF with the corresponding'							, ; //X6_DSCENG1
	'correspondente'														, ; //X6_DESC2
	'correspondiente'														, ; //X6_DSCSPA2
	'periodicity.'															, ; //X6_DSCENG2
	'0561=056107M;1708=170806M;3208=320806M;5952=595202Q;5960=596004Q;5979=597904Q;8045=804506M;5123=512301M;1097=109702M;2089=208901T;3272=327201T;8109=810902M;2172=217201M;', ; //X6_CONTEUD
	'0561=056107M;1708=170806M;3208=320806M;5952=595202Q;5960=596004Q;5979=597904Q;8045=804506M;5123=512301M;1097=109702M;2089=208901T;3272=327201T;8109=810902M;2172=217201M;', ; //X6_CONTSPA
	'0561=056107M;1708=170806M;3208=320806M;5952=595202Q;5960=596004Q;5979=597904Q;8045=804506M;5123=512301M;1097=109702M;2089=208901T;3272=327201T;8109=810902M;2172=217201M;', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema, pa-'					, ; //X6_DESCRIC
	'Abreviatura de la estado de la empresa usuaria'						, ; //X6_DSCSPA
	'State abbreviation referring to the system user'						, ; //X6_DSCENG
	'ra efeito de calculo de ICMS (7, 12 ou 18%).'							, ; //X6_DESC1
	'del sistema a efectos de calculo del ICMS'								, ; //X6_DSCSPA1
	'code, for the purpose of calculating the'								, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	'(7, 12 o 18%).'														, ; //X6_DSCSPA2
	'ICMS (7,12 OR 18%).'													, ; //X6_DSCENG2
	'PR'																	, ; //X6_CONTEUD
	'PR'																	, ; //X6_CONTSPA
	'PR'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'MV_ICMPAD'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informar a aliquota de ICMS aplicada em  operacoes'					, ; //X6_DESCRIC
	'Informar la alicuota de ICMS aplicada en operacio-'					, ; //X6_DSCSPA
	'Inform the value added tax rate, applied in the'						, ; //X6_DSCENG
	'dentro do estado onde a empresa esta localizada.'						, ; //X6_DESC1
	'nes dentro de la provincia donde se localiza la'						, ; //X6_DSCSPA1
	'operation within the states, in which the company'						, ; //X6_DSCENG1
	'(17 ou 18) %'															, ; //X6_DESC2
	'empresa. (17 o 18) %'													, ; //X6_DSCSPA2
	'is localized (17 or 18%).'												, ; //X6_DSCENG2
	'12'																	, ; //X6_CONTEUD
	'12'																	, ; //X6_CONTSPA
	'12'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'MV_TXCOFIN'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Taxa para calculo da COFINS.'											, ; //X6_DESCRIC
	'Tasa para calculo del COFINS.'											, ; //X6_DSCSPA
	'Rate for COFINS calculation.'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'3.0'																	, ; //X6_CONTEUD
	'3.0'																	, ; //X6_CONTSPA
	'3.0'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'MV_TXPIS'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Taxa para calculo do PIS.'												, ; //X6_DESCRIC
	'Tasa para calculo del PIS.'											, ; //X6_DSCSPA
	'Rate for PIS calculation.'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'0.65'																	, ; //X6_CONTEUD
	'0.65'																	, ; //X6_CONTSPA
	'0.65'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'MV_ULMES'																, ; //X6_VAR
	'D'																		, ; //X6_TIPO
	'Data ultimo fechamento do estoque.'									, ; //X6_DESCRIC
	'Fecha del ultimo cierre de stock.'										, ; //X6_DSCSPA
	'Inventory last closing date.'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'20151202'																, ; //X6_CONTEUD
	'20151202'																, ; //X6_CONTSPA
	'20151202'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0201'																	, ; //X6_FIL
	'MV_CAT8309'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Utiliza portaria CAT83'												, ; //X6_DESCRIC
	'Utiliza porteria CAT83'												, ; //X6_DSCSPA
	'Use decree CAT83'														, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0201'																	, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESCRIC
	'Informar en este parametro el nombre del municipi'						, ; //X6_DSCSPA
	'Enter the name of the City reffering to the Tax'						, ; //X6_DSCENG
	'esta estabelecido.'													, ; //X6_DESC1
	'donde El Contribuinte esta estabelecido'								, ; //X6_DSCSPA1
	'Payer in this parameter'												, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'MARINGA'																, ; //X6_CONTEUD
	'MARINGA'																, ; //X6_CONTSPA
	'MARINGA'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0201'																	, ; //X6_FIL
	'MV_DCTF000'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Referencia de codigos de retencäo do sistema para'						, ; //X6_DESCRIC
	'Referencia de cod. de retencion del sistema para'						, ; //X6_DSCSPA
	'Reference of the system withholding codes for'							, ; //X6_DSCENG
	'os adotados pela DCTF com a periodicidade'								, ; //X6_DESC1
	'los adoptados por DCTF con la periodicidad'							, ; //X6_DSCSPA1
	'those adopted by DCTF with the corresponding'							, ; //X6_DSCENG1
	'correspondente'														, ; //X6_DESC2
	'correspondiente'														, ; //X6_DSCSPA2
	'periodicity.'															, ; //X6_DSCENG2
	'0561=056107M;1708=170806M;3208=320806M;5952=595202Q;5960=596004Q;5979=597904Q;8045=804506M;5123=512301M;1097=109702M;2089=208901T;3272=327201T;8109=810902M;2172=217201M;', ; //X6_CONTEUD
	'0561=056107M;1708=170806M;3208=320806M;5952=595202Q;5960=596004Q;5979=597904Q;8045=804506M;5123=512301M;1097=109702M;2089=208901T;3272=327201T;8109=810902M;2172=217201M;', ; //X6_CONTSPA
	'0561=056107M;1708=170806M;3208=320806M;5952=595202Q;5960=596004Q;5979=597904Q;8045=804506M;5123=512301M;1097=109702M;2089=208901T;3272=327201T;8109=810902M;2172=217201M;', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0201'																	, ; //X6_FIL
	'MV_DIAISS'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Dia padrao para gerar os titulos de  ISS.'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'20'																	, ; //X6_CONTEUD
	'20'																	, ; //X6_CONTSPA
	'20'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0201'																	, ; //X6_FIL
	'MV_ENQLEG'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Definir Codigo Enq. Legal para cada UF conforme'						, ; //X6_DESCRIC
	'Definir Codigo Enq. Legal para cada UF conforme'						, ; //X6_DSCSPA
	'Definir Codigo Enq. Legal para cada UF conforme'						, ; //X6_DSCENG
	'aliquota (estadual ou interestadual).'									, ; //X6_DESC1
	'aliquota (estadual ou interestadual).'									, ; //X6_DSCSPA1
	'aliquota (estadual ou interestadual).'									, ; //X6_DSCENG1
	'Exemplo de uso: SP01MG02RJ02'											, ; //X6_DESC2
	'Exemplo de uso: SP01MG02RJ02'											, ; //X6_DSCSPA2
	'Exemplo de uso: SP01MG02RJ02'											, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0201'																	, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema, pa-'					, ; //X6_DESCRIC
	'Abreviatura de la estado de la empresa usuaria'						, ; //X6_DSCSPA
	'State abbreviation referring to the system user'						, ; //X6_DSCENG
	'ra efeito de calculo de ICMS (7, 12 ou 18%).'							, ; //X6_DESC1
	'del sistema a efectos de calculo del ICMS'								, ; //X6_DSCSPA1
	'code, for the purpose of calculating the'								, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	'(7, 12 o 18%).'														, ; //X6_DSCSPA2
	'ICMS (7,12 OR 18%).'													, ; //X6_DSCENG2
	'PR'																	, ; //X6_CONTEUD
	'PR'																	, ; //X6_CONTSPA
	'PR'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0201'																	, ; //X6_FIL
	'MV_ICMPAD'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informar a aliquota de ICMS aplicada em  operacoes'					, ; //X6_DESCRIC
	'Informar la alicuota de ICMS aplicada en operacio-'					, ; //X6_DSCSPA
	'Inform the value added tax rate, applied in the'						, ; //X6_DSCENG
	'dentro do estado onde a empresa esta localizada.'						, ; //X6_DESC1
	'nes dentro de la provincia donde se localiza la'						, ; //X6_DSCSPA1
	'operation within the states, in which the company'						, ; //X6_DSCENG1
	'(17 ou 18) %'															, ; //X6_DESC2
	'empresa. (17 o 18) %'													, ; //X6_DSCSPA2
	'is localized (17 or 18%).'												, ; //X6_DSCENG2
	'12'																	, ; //X6_CONTEUD
	'12'																	, ; //X6_CONTSPA
	'12'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0201'																	, ; //X6_FIL
	'MV_MODRISS'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define o modo de retencao do ISSQN.'									, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0201'																	, ; //X6_FIL
	'MV_TXCOFIN'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Taxa para calculo da COFINS.'											, ; //X6_DESCRIC
	'Tasa para calculo del COFINS.'											, ; //X6_DSCSPA
	'Rate for COFINS calculation.'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'3.0'																	, ; //X6_CONTEUD
	'3.0'																	, ; //X6_CONTSPA
	'3.0'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0201'																	, ; //X6_FIL
	'MV_TXPIS'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Taxa para calculo do PIS.'												, ; //X6_DESCRIC
	'Tasa para calculo del PIS.'											, ; //X6_DSCSPA
	'Rate for PIS calculation.'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'0.65'																	, ; //X6_CONTEUD
	'0.65'																	, ; //X6_CONTSPA
	'0.65'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0201'																	, ; //X6_FIL
	'MV_ULMES'																, ; //X6_VAR
	'D'																		, ; //X6_TIPO
	'Data ultimo fechamento do estoque.'									, ; //X6_DESCRIC
	'Fecha del ultimo cierre de stock.'										, ; //X6_DSCSPA
	'Inventory last closing date.'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'20151202'																, ; //X6_CONTEUD
	'20151202'																, ; //X6_CONTSPA
	'20151202'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0201'																	, ; //X6_FIL
	'MV_VRETISS'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Valor minimo para dispensa de retencao de ISS'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'15.00'																	, ; //X6_CONTEUD
	'15.00'																	, ; //X6_CONTSPA
	'15.00'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0202'																	, ; //X6_FIL
	'MV_CAT8309'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Utiliza portaria CAT83'												, ; //X6_DESCRIC
	'Utiliza porteria CAT83'												, ; //X6_DSCSPA
	'Use decree CAT83'														, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0202'																	, ; //X6_FIL
	'MV_CIDADE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informe o nome do municipio em que o contribuinte'						, ; //X6_DESCRIC
	'Informar en este parametro el nombre del municipio'					, ; //X6_DSCSPA
	'Enter the name of the city referring to the Tax'						, ; //X6_DSCENG
	'esta estabelecido'														, ; //X6_DESC1
	'donde el Contribuyente esta establecido'								, ; //X6_DSCSPA1
	'Payer to this parameter'												, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SAO PAULO'																, ; //X6_CONTEUD
	'SAO PAULO'																, ; //X6_CONTSPA
	'SAO PAULO'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0202'																	, ; //X6_FIL
	'MV_DCTF000'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Referencia de codigos de retencäo do sistema para'						, ; //X6_DESCRIC
	'Referencia de cod. de retencion del sistema para'						, ; //X6_DSCSPA
	'Reference of the system withholding codes for'							, ; //X6_DSCENG
	'os adotados pela DCTF com a periodicidade'								, ; //X6_DESC1
	'los adoptados por DCTF con la periodicidad'							, ; //X6_DSCSPA1
	'those adopted by DCTF with the corresponding'							, ; //X6_DSCENG1
	'correspondente'														, ; //X6_DESC2
	'correspondiente'														, ; //X6_DSCSPA2
	'periodicity.'															, ; //X6_DSCENG2
	'0561=056107M;1708=170806M;3208=320806M;5952=595202Q;5960=596004Q;5979=597904Q;8045=804506M;5123=512301M;1097=109702M;2089=208901T;3272=327201T;8109=810902M;2172=217201M;', ; //X6_CONTEUD
	'0561=056107M;1708=170806M;3208=320806M;5952=595202Q;5960=596004Q;5979=597904Q;8045=804506M;5123=512301M;1097=109702M;2089=208901T;3272=327201T;8109=810902M;2172=217201M;', ; //X6_CONTSPA
	'0561=056107M;1708=170806M;3208=320806M;5952=595202Q;5960=596004Q;5979=597904Q;8045=804506M;5123=512301M;1097=109702M;2089=208901T;3272=327201T;8109=810902M;2172=217201M;', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0202'																	, ; //X6_FIL
	'MV_DIAISS'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Dia padrao para gerar os titulos de  ISS.'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'10'																	, ; //X6_CONTEUD
	'10'																	, ; //X6_CONTSPA
	'10'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0202'																	, ; //X6_FIL
	'MV_ENQLEG'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Definir Codigo Enq. Legal para cada UF conforme'						, ; //X6_DESCRIC
	'Definir Codigo Enq. Legal para cada UF conforme'						, ; //X6_DSCSPA
	'Definir Codigo Enq. Legal para cada UF conforme'						, ; //X6_DSCENG
	'aliquota (estadual ou interestadual).'									, ; //X6_DESC1
	'aliquota (estadual ou interestadual).'									, ; //X6_DSCSPA1
	'aliquota (estadual ou interestadual).'									, ; //X6_DSCENG1
	'Exemplo de uso: SP01MG02RJ02'											, ; //X6_DESC2
	'Exemplo de uso: SP01MG02RJ02'											, ; //X6_DSCSPA2
	'Exemplo de uso: SP01MG02RJ02'											, ; //X6_DSCENG2
	'AC0001AL0001AM0001AP0001BA0001CE0001DF0001ES0001GO0001MA0001MT0001MS0001MG0002PA0001PB0001PR0002PE0001PI0001RN0001RS0002RJ0002RO0001RR0001SC0002SP0004SE0001TO0001', ; //X6_CONTEUD
	'AC0001AL0001AM0001AP0001BA0001CE0001DF0001ES0001GO0001MA0001MT0001MS0001MG0002PA0001PB0001PR0002PE0001PI0001RN0001RS0002RJ0002RO0001RR0001SC0002SP0004SE0001TO0001', ; //X6_CONTSPA
	'AC0001AL0001AM0001AP0001BA0001CE0001DF0001ES0001GO0001MA0001MT0001MS0001MG0002PA0001PB0001PR0002PE0001PI0001RN0001RS0002RJ0002RO0001RR0001SC0002SP0004SE0001TO0001', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0202'																	, ; //X6_FIL
	'MV_ESTADO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sigla do estado da empresa usuaria do Sistema, pa-'					, ; //X6_DESCRIC
	'Abreviatura de la estado de la empresa usuaria'						, ; //X6_DSCSPA
	'State abbreviation referring to the system user'						, ; //X6_DSCENG
	'ra efeito de calculo de ICMS (7, 12 ou 18%).'							, ; //X6_DESC1
	'del sistema a efectos de calculo del ICMS'								, ; //X6_DSCSPA1
	'code, for the purpose of calculating the'								, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	'(7, 12 o 18%).'														, ; //X6_DSCSPA2
	'ICMS (7,12 OR 18%).'													, ; //X6_DSCENG2
	'SP'																	, ; //X6_CONTEUD
	'SP'																	, ; //X6_CONTSPA
	'SP'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0202'																	, ; //X6_FIL
	'MV_ICMPAD'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informar a aliquota de ICMS aplicada em  operacoes'					, ; //X6_DESCRIC
	'Informar la alicuota de ICMS aplicada en operacio-'					, ; //X6_DSCSPA
	'Inform the value added tax rate, applied in the'						, ; //X6_DSCENG
	'dentro do estado onde a empresa esta localizada.'						, ; //X6_DESC1
	'nes dentro de la provincia donde se localiza la'						, ; //X6_DSCSPA1
	'operation within the states, in which the company'						, ; //X6_DSCENG1
	'(17 ou 18) %'															, ; //X6_DESC2
	'empresa. (17 o 18) %'													, ; //X6_DSCSPA2
	'is localized (17 or 18%).'												, ; //X6_DSCENG2
	'18'																	, ; //X6_CONTEUD
	'18'																	, ; //X6_CONTSPA
	'18'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0202'																	, ; //X6_FIL
	'MV_MODRISS'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define o modo de retencao do ISSQN.'									, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'1'																		, ; //X6_CONTSPA
	'1'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0202'																	, ; //X6_FIL
	'MV_TXCOFIN'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Taxa para calculo da COFINS.'											, ; //X6_DESCRIC
	'Tasa para calculo del COFINS.'											, ; //X6_DSCSPA
	'Rate for COFINS calculation.'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'3.0'																	, ; //X6_CONTEUD
	'3.0'																	, ; //X6_CONTSPA
	'3.0'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0202'																	, ; //X6_FIL
	'MV_TXPIS'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Taxa para calculo do PIS.'												, ; //X6_DESCRIC
	'Tasa para calculo del PIS'												, ; //X6_DSCSPA
	'Rate for PIS calculation.'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'0.65'																	, ; //X6_CONTEUD
	'0.65'																	, ; //X6_CONTSPA
	'0.65'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0202'																	, ; //X6_FIL
	'MV_ULMES'																, ; //X6_VAR
	'D'																		, ; //X6_TIPO
	'Data ultimo fechamento do estoque.'									, ; //X6_DESCRIC
	'Fecha del ultimo cierre de stock.'										, ; //X6_DSCSPA
	'Inventory last closing date.'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'20151202'																, ; //X6_CONTEUD
	'20151202'																, ; //X6_CONTSPA
	'20151202'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0202'																	, ; //X6_FIL
	'MV_VRETISS'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Valor minimo para dispensa de retencao de ISS'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'0.00'																	, ; //X6_CONTEUD
	'0.00'																	, ; //X6_CONTSPA
	'0.00'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX6 ) )

dbSelectArea( "SX6" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )
	lContinua := .F.
	lReclock  := .F.

	If !SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )
		lContinua := .T.
		lReclock  := .T.
		AutoGrLog( "Foi incluído o parâmetro " + aSX6[nI][1] + aSX6[nI][2] + " Conteúdo [" + AllTrim( aSX6[nI][13] ) + "]" )
	EndIf

	If lContinua
		If !( aSX6[nI][1] $ cAlias )
			cAlias += aSX6[nI][1] + "/"
		EndIf

		RecLock( "SX6", lReclock )
		For nJ := 1 To Len( aSX6[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
	EndIf

	oProcess:IncRegua2( "Atualizando Arquivos (SX6)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX7
Função de processamento da gravação do SX7 - Gatilhos

@author TOTVS Protheus
@since  10/12/2015
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX7()
Local aEstrut   := {}
Local aAreaSX3  := SX3->( GetArea() )
Local aSX7      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX7->X7_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX7" + CRLF )

aEstrut := { "X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "X7_TIPO", "X7_SEEK", ;
             "X7_ALIAS", "X7_ORDEM"  , "X7_CHAVE", "X7_PROPRI", "X7_CONDIC" }

//
// Campo Z2_ITEMGRP
//
aAdd( aSX7, { ;
	'Z2_ITEMGRP'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'getadvfval("SBM","BM_DESC",xfilial("SBM")+M->Z2_ITEMGRP,1,"")'			, ; //X7_REGRA
	'Z2_NOMEGRU'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo Z2_VEND
//
aAdd( aSX7, { ;
	'Z2_VEND'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'GETADVFVAL("SA3","A3_NOME", xfilial("SA3")+M->Z2_VEND,1,"")'			, ; //X7_REGRA
	'Z2_NOMEVEN'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX7 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )

dbSelectArea( "SX7" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX7 )

	If !SX7->( dbSeek( PadR( aSX7[nI][1], nTamSeek ) + aSX7[nI][2] ) )

		If !( aSX7[nI][1] $ cAlias )
			cAlias += aSX7[nI][1] + "/"
			AutoGrLog( "Foi incluído o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] )
		EndIf

		RecLock( "SX7", .T. )
		For nJ := 1 To Len( aSX7[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX7[nI][nJ] )
			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		If SX3->( dbSeek( SX7->X7_CAMPO ) )
			RecLock( "SX3", .F. )
			SX3->X3_TRIGGER := "S"
			MsUnLock()
		EndIf

	EndIf
	oProcess:IncRegua2( "Atualizando Arquivos (SX7)..." )

Next nI

RestArea( aAreaSX3 )

AutoGrLog( CRLF + "Final da Atualização" + " SX7" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXA
Função de processamento da gravação do SXA - Pastas

@author TOTVS Protheus
@since  10/12/2015
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXA()
Local aEstrut   := {}
Local aSXA      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nPosAgr   := 0
Local lAlterou  := .F.

AutoGrLog( "Ínicio da Atualização" + " SXA" + CRLF )

aEstrut := { "XA_ALIAS"  , "XA_ORDEM"  , "XA_DESCRIC", "XA_DESCSPA", "XA_DESCENG", "XA_AGRUP"  , "XA_TIPO"   , ;
             "XA_PROPRI" }


//
// Tabela SA1
//
aAdd( aSXA, { ;
	'SA1'																	, ; //XA_ALIAS
	'5'																		, ; //XA_ORDEM
	'Cambuci'																, ; //XA_DESCRIC
	'Cambuci'																, ; //XA_DESCSPA
	'Cambuci'																, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

nPosAgr := aScan( aEstrut, { |x| AllTrim( x ) == "XA_AGRUP" } )

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSXA ) )

dbSelectArea( "SXA" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXA )

	If SXA->( dbSeek( aSXA[nI][1] + aSXA[nI][2] ) )

		lAlterou := .F.

		While !SXA->( EOF() ).AND.  SXA->( XA_ALIAS + XA_ORDEM ) == aSXA[nI][1] + aSXA[nI][2]

			If SXA->XA_AGRUP == aSXA[nI][nPosAgr]
				RecLock( "SXA", .F. )
				For nJ := 1 To Len( aSXA[nI] )
					If FieldPos( aEstrut[nJ] ) > 0 .AND. Alltrim(AllToChar(SXA->( FieldGet( nJ ) ))) <> Alltrim(AllToChar(aSXA[nI][nJ]))
						FieldPut( FieldPos( aEstrut[nJ] ), aSXA[nI][nJ] )
						lAlterou := .T.
					EndIf
				Next nJ
				dbCommit()
				MsUnLock()
			EndIf

			SXA->( dbSkip() )

		End

		If lAlterou
			AutoGrLog( "Foi alterada a pasta " + aSXA[nI][1] + "/" + aSXA[nI][2] + "  " + aSXA[nI][3] )
		EndIf

	Else

		RecLock( "SXA", .T. )
		For nJ := 1 To Len( aSXA[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSXA[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()

		AutoGrLog( "Foi incluída a pasta " + aSXA[nI][1] + "/" + aSXA[nI][2] + "  " + aSXA[nI][3] )

	EndIf

oProcess:IncRegua2( "Atualizando Arquivos (SXA)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SXA" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXB
Função de processamento da gravação do SXB - Consultas Padrao

@author TOTVS Protheus
@since  10/12/2015
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXB()
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0

AutoGrLog( "Ínicio da Atualização" + " SXB" + CRLF )

aEstrut := { "XB_ALIAS"  , "XB_TIPO"   , "XB_SEQ"    , "XB_COLUNA" , "XB_DESCRI" , "XB_DESCSPA", "XB_DESCENG", ;
             "XB_WCONTEM", "XB_CONTEM" }


//
// Consulta SA3
//
aAdd( aSXB, { ;
	'SA3'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Vendedor'																, ; //XB_DESCRI
	'Vendedor'																, ; //XB_DESCSPA
	'Sales Representative'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA3'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA3'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA3'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA3'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'CNPJ'																	, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA3'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A3_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A3_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A3_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A3_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'CNPJ'																	, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A3_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A3_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA3'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA3->A3_COD'															} ) //XB_CONTEM

//
// Consulta SBM
//
aAdd( aSXB, { ;
	'SBM'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Grupo'																	, ; //XB_DESCRI
	'Grupo'																	, ; //XB_DESCSPA
	'Group'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBM'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBM'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBM'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBM'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBM->BM_GRUPO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBM'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBM->BM_DESC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBM'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Marca'																	, ; //XB_DESCRI
	'Marca'																	, ; //XB_DESCSPA
	'Brand'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBM->BM_CODMAR'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBM'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBM->BM_GRUPO'															} ) //XB_CONTEM

//
// Consulta ZZB
//
aAdd( aSXB, { ;
	'ZZB'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Marca'																	, ; //XB_DESCRI
	'Marca'																	, ; //XB_DESCSPA
	'Marca'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZB'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZB'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Marca'															, ; //XB_DESCRI
	'Cod. Marca'															, ; //XB_DESCSPA
	'Cod. Marca'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZB'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Marca'															, ; //XB_DESCRI
	'Cod. Marca'															, ; //XB_DESCSPA
	'Cod. Marca'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZB_XCODMC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZB'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc. Marca'															, ; //XB_DESCRI
	'Desc. Marca'															, ; //XB_DESCSPA
	'Desc. Marca'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZB_XDESMC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZB'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZB->ZZB_XCODMC'														} ) //XB_CONTEM

//
// Consulta ZZC
//
aAdd( aSXB, { ;
	'ZZC'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Linha do Produto'														, ; //XB_DESCRI
	'Linha do Produto'														, ; //XB_DESCSPA
	'Linha do Produto'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZC'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZC'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Linha'															, ; //XB_DESCRI
	'Cod. Linha'															, ; //XB_DESCSPA
	'Cod. Linha'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZC'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Linha'															, ; //XB_DESCRI
	'Cod. Linha'															, ; //XB_DESCSPA
	'Cod. Linha'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZC_XCODLN'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZC'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc. Linha'															, ; //XB_DESCRI
	'Desc. Linha'															, ; //XB_DESCSPA
	'Desc. Linha'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZC_XDESLN'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZC'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZC->ZZC_XCODLN'														} ) //XB_CONTEM

//
// Consulta ZZJ
//
aAdd( aSXB, { ;
	'ZZJ'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'GRUPO PESSOA'															, ; //XB_DESCRI
	'GRUPO PESSOA'															, ; //XB_DESCSPA
	'GRUPO PESSOA'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZJ'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZJ'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZJ'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZJ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZJ_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZJ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZJ_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZJ'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZJ->ZZJ_CODIGO'														} ) //XB_CONTEM

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSXB ) )

dbSelectArea( "SXB" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXB )

	If !Empty( aSXB[nI][1] )

		If !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

			If !( aSXB[nI][1] $ cAlias )
				cAlias += aSXB[nI][1] + "/"
				AutoGrLog( "Foi incluída a consulta padrão " + aSXB[nI][1] )
			EndIf

			RecLock( "SXB", .T. )

			For nJ := 1 To Len( aSXB[nI] )
				If FieldPos( aEstrut[nJ] ) > 0
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
				EndIf
			Next nJ

			dbCommit()
			MsUnLock()

		Else

			//
			// Verifica todos os campos
			//
			For nJ := 1 To Len( aSXB[nI] )

				//
				// Se o campo estiver diferente da estrutura
				//
				If aEstrut[nJ] == SXB->( FieldName( nJ ) ) .AND. ;
					!StrTran( AllToChar( SXB->( FieldGet( nJ ) ) ), " ", "" ) == ;
					 StrTran( AllToChar( aSXB[nI][nJ]            ), " ", "" )

					cMsg := "A consulta padrão " + aSXB[nI][1] + " está com o " + SXB->( FieldName( nJ ) ) + ;
					" com o conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( SXB->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
					", e este é diferente do conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( aSXB[nI][nJ] ) ) + "]" + CRLF +;
					"Deseja substituir ? "

					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Diferença de conteúdo - SXB" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SXB e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
						EndIf

						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SXB que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
						EndIf

					EndIf

					If nOpcA == 1
						RecLock( "SXB", .F. )
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
						dbCommit()
						MsUnLock()

							If !( aSXB[nI][1] $ cAlias )
								cAlias += aSXB[nI][1] + "/"
								AutoGrLog( "Foi alterada a consulta padrão " + aSXB[nI][1] )
							EndIf

					EndIf

				EndIf

			Next

		EndIf

	EndIf

	oProcess:IncRegua2( "Atualizando Consultas Padrões (SXB)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SXB" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleções feitas.
             Se não for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
Local   aRet      := {}
Local   aSalvAmb  := GetArea()
Local   aSalvSM0  := {}
Local   aVetor    := {}
Local   cMascEmp  := "??"
Local   cVar      := ""
Local   lChk      := .F.
Local   lOk       := .F.
Local   lTeveMarc := .F.
Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

Local   aMarcadas := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), oDlg:End()  ) ;
Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  10/12/2015
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  10/12/2015
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet


/////////////////////////////////////////////////////////////////////////////
