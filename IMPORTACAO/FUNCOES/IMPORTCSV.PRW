#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APWIZARD.CH'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���PROGRAMA  �ImportCSV �Autor  �FELIPE NUNES DE TOLEDO �Data  � 28.Mai.11���
�������������������������������������������������������������������������Ĵ��
���DESCRICAO �Programa para importacao/carga de dados com base em arquivo ���
���          �(.CSV)                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
//  Melhorias introduzidas em 30/03/12 por Daniel para atender necessidades de importa��o de cadastro da Central Distribuidora de Papeis Ltda.:
//  1. Remover limita��o de 1023 caracteres por linha do arquivo de importa��o.
//  2. Tratamento de campos Memo.


User Function ImportCSV()
Local oWizard    := NIL
Local lFinish    := .F.
Local cHeader    := ''
Local cMessage   := ''
Local cText      := ''
Local cTitleProg := 'TOTVS ImportCSV 1.1'

Local oFileCSV   := Nil
Local cTextP2    := '' 
Local oTextP2    := Nil 

Local cNameFunc  := Space(100)
Local oNameFunc  := Nil
Local cTextP3    := ''
Local oTextP3    := Nil

Local nTipoData  := 1
Local lNoAcento  := .T.
Local oNoAcento  := Nil
Local lOrdVetX3  := .T.
Local oOrdVetX3  := .T.

Local cFileLog   := ''
Private cFileImp   := Space(100)
 
DEFINE FONT oArial10	NAME 'Arial'       WEIGHT 10
DEFINE FONT oCouri11	NAME 'Courier New' WEIGHT 11

//���������������������Ŀ
//�PAINEL PRINCIPAL     �
//�����������������������
cHeader  := 'ImportCSV - Importa��o de dados.'
cMessage := 'Assistente para processamento'
cText    := 'Este assistente ir� auxili�-lo na configura��o dos par�metros para realiza��o da importa��o '
cText    += 'dos dados a partir de um arquivo (.CSV). O objetivo desta aplica��o � efetuar a importa��o '
cText    += 'consistindo todas as valida��es existentes no sistema para o cadastramento da tabela.' + Chr(10)+Chr(13)
cText    += 'Para a realiza��o das valida��es o programa utilizar� o recurso de rotina autom�tica (MSExecAuto).'
cText    += Chr(10)+Chr(13)
cText    += Chr(10)+Chr(13)
cText    += Chr(10)+Chr(13)
cText    += 'Clique em "Avan�ar" para continuar...'
	
DEFINE	WIZARD	oWizard ;
		TITLE	'ImportCSV v1.1';
		HEADER	cHeader;
		MESSAGE	cMessage;
		TEXT	cText;
		NEXT 	{|| .T.};
		FINISH 	{|| .F.}

		//���������������������Ŀ
		//�PAINEL 02            �
		//�����������������������
		cMessage := 'Informe o local e o arquivo (.CSV) para importa��o dos dados...'
		CREATE	PANEL 	oWizard  ;
				HEADER 	cHeader;
				MESSAGE	cMessage;
				BACK	{|| .T.} ;
				NEXT	{|| !Empty(cFileImp) }; 
				FINISH	{|| .F.}
				
				cTextP2	:= 'Restri��es do arquivo:' + Chr(10)+Chr(13)
				cTextP2	+= Chr(10)+Chr(13)
				cTextP2	+= 'a.) A 1a. linha deve conter o cabe�alho do arquivo, com os nomes exatos de cada campo da tabela, exemplo: B1_COD;B1_DESC;B1_TIPO' + Chr(10)+Chr(13)
				cTextP2	+= Chr(10)+Chr(13)
				cTextP2	+= 'b.) No conte�do dos campos n�o pode haver caracteres especiais como aspas simples ou duplas ' + "(')" + '(")' + ' e ponto e v�rgula (;). Isso ira ocasionar em erro na montagem do arquivo.'
				cTextP2	+= Chr(10)+Chr(13)
				cTextP2	+= 'c.) A �ltima linha do arquivo deve conter apenas um asterisco "*"'
				
				@ 012, 010 Say oTextP2 PROMPT cTextP2 Size 228, 094 Of oWizard:oMPanel[2] FONT oArial10 Pixel
				@ 085, 005 GROUP To 113, 245 PROMPT "Local e nome do arquivo:" OF oWizard:oMPanel[2] Pixel
				@ 095, 020 MsGet oFileCSV Var cFileImp Valid( If( File(cFileImp), .T., ( Alert("O arquivo informado para importa��o n�o existe!") ,.F.) ) .Or. Empty(cFileImp) ) Size 212, 010 Of oWizard:oMPanel[2] F3 "DIR" Pixel

		//���������������������Ŀ
		//�PAINEL 03            �
		//�����������������������
		cMessage := 'Informe o nome da fun��o para importa��o dos dados...'
		CREATE	PANEL 	oWizard  ;
				HEADER 	cHeader;
				MESSAGE	cMessage;
				BACK	{|| .T.} ;
				NEXT	{|| !Empty(cNameFunc) }; 
				FINISH	{|| .F.}
				
				cTextP3	:= 'Restri��es da funcao:' + Chr(10)+Chr(13)
				cTextP3	+= Chr(10)+Chr(13)
				cTextP3	+= 'a.) A fun��o a ser informada deve conter o recurso de rotina autom�tica (MsExecAuto).' + Chr(10)+Chr(13)
				cTextP3	+= Chr(10)+Chr(13)
				cTextP3	+= 'b.) Informe apenas o nome da fun��o, sem o par�ntese, exemplo: MATA010' + Chr(10)+Chr(13)
				cTextP3	+= Chr(10)+Chr(13)
				cTextP3	+= 'c.) Utilize somente fun��es de cadastros ou movimenta��es simples, que requer apenas uma �nica tabela. Fun��es que requerem mais de uma tabela, como Nota Fiscal de Entrada, Pedido de Venda e etc, n�o podem ser importadas por esse programa.'
				
				@ 012, 010 Say oTextP3  PROMPT cTextP3 Size 228, 094 Of oWizard:oMPanel[3] FONT oArial10 Pixel
				@ 085, 005 GROUP To 113, 245 PROMPT "Digite o nome da fun��o:" OF oWizard:oMPanel[3] PIXEL
				@ 095, 020 MsGet oNameFunc Var cNameFunc Valid( If( FindFunction(cNameFunc), .T., ( Alert("Fun��o inv�lida!") ,.F.) ) .Or. Empty(cNameFunc) ) Size 212, 010 Of oWizard:oMPanel[3] Pixel
				
		//���������������������Ŀ
		//�PAINEL 04            �
		//�����������������������
		cMessage := 'Informe os par�metros para processamento...'
		CREATE	PANEL 	oWizard  ;
				HEADER 	cHeader;
				MESSAGE	cMessage;
				BACK	{|| .T.} ;
				NEXT	{|| .T. }; 
				FINISH	{|| .F.}
				
				@ 010, 005 GROUP To 055, 200 PROMPT 'Indique o formatado da data utilizada no arquivo CSV:' Of oWizard:oMPanel[4] Pixel
				@ 020, 010 Radio oTipoDia VAR nTipoData Items "1 = AAAAMMDD","2 = DD/MM/AA","3 = DD/MM/AAAA" SIZE 064, 026 Of oWizard:oMPanel[4] Color CLR_BLUE PIXEL

				@ 060, 005 GROUP To 090, 200 PROMPT 'Retira acentua��o:' Of oWizard:oMPanel[4] Pixel
				@ 070, 010 CheckBox oNoAcento Var lNoAcento Prompt "Retira os acentos dos textos a serem importados" Size 140, 010 Of oWizard:oMPanel[4] Color CLR_BLUE Pixel
				
				@ 095, 005 GROUP To 125, 200 PROMPT 'Ordena��o dos campos:' Of oWizard:oMPanel[4] Pixel
				@ 105, 010 CheckBox oOrdVetX3 Var lOrdVetX3 Prompt "Ordena os campos conforme o dicion�rios de dados" Size 140, 010 Of oWizard:oMPanel[4] Color CLR_BLUE Pixel
				
		//���������������������Ŀ
		//�PAINEL 05            �
		//�����������������������
		cMessage := 'Iniciar o processamento...'
		CREATE	PANEL 	oWizard  ;
				HEADER 	cHeader;
				MESSAGE	cMessage;
				BACK	{|| .T.} ;
				NEXT	{|| .F.}; 
				FINISH	{|| lFinish := .T.}
    			
    			cFileLog := SubStr(AllTrim(cFileImp), 1, At('.', AllTrim(cFileImp)) - 1) + '.LOG'
		
			    TSay():New(010, 005, {|| 'Ao t�rmino do processo ser� criado o arquivo de log no mesmo diret�rio do arquivo a ser importado. ' },;
						                    oWizard:oMPanel[5],, oCouri11,,,, .T.,,, 200, 50)
	  			
	  			TSay():New(045, 005, {|| 'Clique em "Finalizar" para encerrar o assistente e inicar o processamento...' },;
						                    oWizard:oMPanel[5],, oCouri11,,,, .T.,,, 200, 50)
			   
ACTIVATE WIZARD oWizard Center

//���������������������������������Ŀ
//�INICIO DO PROCESSO DE VERIFICACAO�
//�����������������������������������
If lFinish
	//--PROCESSA A IMPORTACAO:
	Processa({||  ProcImp(Alltrim(cFileImp), cFileLog, Alltrim(cNameFunc),nTipoData,lNoAcento, lOrdVetX3) }, cTitleProg, 'Processando importa��o...')
EndIf

Return Nil
/*/
���������������������������������������������������������������������������
���������������������������������������������������������������������������
�����������������������������������������������������������������������Ŀ��
���Fun��o    �ProcImp   � Autor �V.RASPA / FELIPE NUNES                 ���
�����������������������������������������������������������������������Ĵ��
���Descri��o �Processa a importacao do arquivo indicado nos parametros  ���
������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������
���������������������������������������������������������������������������
/*/
Static Function ProcImp(cFileImp, cFileLog, cNameRot, nTipoData, lNoAcento, lOrdVetX3)
Local nHdlLog     := 0
Local nLinha      := 0
Local aDataCab    := ''
Local aDataIte    := {}
Local cBuffer     := ''
Local aMsExcAuto  := {}
Local bBlockAuto  := {}
Local cArqErrAuto := ''
Local cErrAuto    := ''
Local nOpc        := 0
Local nCount      := 0
Local aMsExecAuto := {}
Local aTamSX3     := {}
Local xConteudo   := Nil   
Local lVai		  := .T.
                      
//�������������������Ŀ
//�CRIA ARQUIVO DE LOG�
//���������������������                               
cFileLog := SubStr(AllTrim(cFileImp), 1, At('.', AllTrim(cFileImp)) - 1) + '.LOG'
nHdlLog  := MSFCreate(cFileLog,0)
If nHdlLog < 0
	Aviso('ATEN��O', 'PROBLEMAS NA CRIA��O DO ARQUIVO DE LOG DE INCONSIST�NCIAS!' + Chr(10) + Chr(13) + 'C�digo do erro: ' + StrZero(FError(),10), {'OK'}, 3)
Else
	//--Atualiza arquivo de LOG:
	UpdFileLog(nHdlLog, '[' + DtoC(Date()) + ' - ' + Time() + '] INICIANDO PROCESSO DE IMPORTA��O' + Chr(13) + Chr(10))
	
	//--Abre o arquivo e inicia a importacao:
	nh:=FOpen(cFileImp)
	ProcRegua(5000)

	//--Atualiza arquivo de LOG:
	UpdFileLog(nHdlLog, '[' + DtoC(Date()) + ' - ' + Time() + '] INICIANDO IMPORTA��O DOS DADOS ' + Chr(13) + Chr(10))

	Do While lVai
		nLinha++
		If nLinha == 1 
		    //-- Armazena em memoria a 1a. linha (Cabecalho).
		    cBuffer := ""
		    do While .t.
		    	xBuffer := Freadstr(nh,1)
		    	If xBuffer == "*"
		    		lVai := .F.
		    		Exit
		    	Endif
		    	If xBuffer == Chr(10)
		    		Exit
		    	Else
					cBuffer  += xBuffer
				Endif
			Enddo
			aDataCab := aBIToken(cBuffer, ';',.F.)
		Else		
			//-- Armazena em memoria os itens.
			cBuffer := "" 
		    do While .t.
		    	xBuffer := Freadstr(nh,1) 
		    	If xBuffer == Chr(10)
		    		Exit
		    	Else
					cBuffer  += xBuffer
				Endif
			Enddo    
			If Substr(cBuffer,1,1) == "*"
				lVai := .F.
				Exit
			Endif
			aDataIte := aBIToken(cBuffer, ';',.F.)
			If Len(aDataIte) > 0
				If Len(aDataIte) == Len(aDataCab)
			
					aMsExcAuto := {}
					cSituaca := ""
					//--Compatibiliza os campos conforme
					//--dicionario de dados:
					For nCntFor := 1 To Len(aDataCab)
						If !Empty(aDataIte[nCntFor])
							aTamSX3 := TamSX3(aDataCab[nCntFor])
							If aTamSX3[3] == 'N'
								xConteudo := Val( StrTran(aDataIte[nCntFor],",",".") )
							ElseIf aTamSX3[3] == 'D'
								If nTipoData == 1 //-- AAAAMMDD
									xConteudo := StoD( aDataIte[nCntFor] )
								Else  //-- DD/MM/AA ou DD/MM/AAAA
							   	xConteudo := CtoD( aDataIte[nCntFor] )
							 	EndIf
							ElseIf aTamSX3[3] == 'L'
								xConteudo := AllTrim(aDataIte[nCntFor]) == 'T' .Or. AllTrim(aDataIte[nCntFor]) == '.T.'
							ElseIf aTamSX3[3] == 'C'
								If lNoAcento
									xConteudo := NoAcento( PadR( AllTrim( StrTran(aDataIte[nCntFor],"|",";") ), aTamSX3[1] ) )
								Else
									xConteudo := PadR( AllTrim( StrTran(aDataIte[nCntFor],"|",";") ), aTamSX3[1] )
								EndIf
							ElseIf aTamSX3[3] == 'M'
								If lNoAcento
									xConteudo := NoAcento( AllTrim( aDataIte[nCntFor] ) )
								Else
									xConteudo := AllTrim( aDataIte[nCntFor] )
								EndIf							
							EndIf

							// Campo E1_SITUACA foram criados novos c�digos. MSExecAuto n�o consegue gravar. Grava 'por fora'.							
							If AllTrim(aDataCab[nCntFor]) == "E1_SITUACA"
								cSituaca := xConteudo	
							Else
								AAdd(aMsExcAuto, {aDataCab[nCntFor]	,xConteudo,NIL})
							Endif
						EndIf
					Next nCntFor
					
					//-- Ordena os campos do vetor conforme ordem do SX3
					If lOrdVetX3
						aMsExcAuto := OrdVetX3(aMsExcAuto)
					EndIf
					
					//--Determina a acao (3=Inclusao):
					nOpc := 3

					//--Monta instrucao para processamento
					//--da rotina automatica:
					bBlockAuto := {|X,Y| &(cNameRot)(X,Y)}

					//--Realiza o processamento da 
					//--rotina Automatica:
					lMsErroAuto := .F.
					MSExecAuto(bBlockAuto, aMsExcAuto, nOpc)
					If lMsErroAuto
						//-- Reporta o erro retornado pela rotina automatica:
						cArqErrAuto := NomeAutoLog()
						cErrAuto    := Memoread(cArqErrAuto)
						Ferase(cArqErrAuto)
						UpdFileLog(nHdlLog, Chr(13) + Chr(10) + '[' + DtoC(Date()) + ' - ' + Time() + '] [LINHA: ' + StrZero(nLinha, 5) + '] INCONSISTENCIA NA IMPORTACAO DOS DADOS. DETALHE DO ERRO: ' + Chr(13) + Chr(10) + cErrAuto + Chr(13) + Chr(10))
					Else
						UpdFileLog(nHdlLog, '[' + DtoC(Date()) + ' - ' + Time() + '] [LINHA: ' + StrZero(nLinha, 5) + '] IMPORTADA COM SUCESSO!' + Chr(13) + Chr(10))  
						// Campo E1_SITUACA foram criados novos c�digos. MSExecAuto n�o consegue gravar. Grava 'por fora'.
						If cNameRot == "FINA040"
							Reclock("SE1",.F.)
							SE1->E1_SITUACA := cSituaca
							msUnlock()
						Endif						
					EndIf
				Else
					UpdFileLog(nHdlLog, Chr(13) + Chr(10) + '[' + DtoC(Date()) + ' - ' + Time() + '] [LINHA: ' + StrZero(nLinha, 5) + '] INCONSISTENCIA NA IMPORTACAO DOS DADOS. ESTRUTURA DO ITEM DIFERENTE DA ESTRUTURA DO CABECALHO!' + Chr(13) + Chr(10))
				EndIf
			EndIf
		EndIf
		IncProc()                                                             
	EndDo

	//--Fecha arquivo utilizado para importacao:
	Fclose(nh)

	//--Atualiza arquivo de LOG:
	UpdFileLog(nHdlLog, '[' + DtoC(Date()) + ' - ' + Time() + '] FIM DO PROCESSO DE IMPORTACAO' + Chr(13) + Chr(10))

	//--Exibe LOG de processamento:
	FClose(nHdlLog)		
	ShowLog(cFileLog)
EndIf

Return Nil
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �UpdFileLog� Autor �V.RASPA                �Data  � 03.Jan.10���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava linha no arquivo de log de erro                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function UpdFileLog(nHdlLog, cMsg)
FWrite(nHdlLog, cMsg)
Return Nil
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ShowLog   � Autor �V.RASPA                �Data  � 03.Jan.10���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Exibe LOG com as inconsistencias                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ShowLog(cFileLog)
Local oDlg     := NIL
Local oFont    := NIL
Local cMemo    := ''
Local oMemo    := NIL

cMemo := MemoRead(cFileLog)
DEFINE FONT oFont NAME "Courier New" SIZE 5,0
DEFINE MSDIALOG oDlg TITLE 'LOG' From 3,0 to 340,617 PIXEL
	@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 300,145 OF oDlg PIXEL 
	oMemo:bRClicked := {|| AllwaysTrue()}
	oMemo:oFont:=oFont
	DEFINE SBUTTON  FROM 153,280 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
ACTIVATE MSDIALOG oDlg CENTER
Return Nil
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���NoAcento  �Retira os acentos da string                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function NoAcento(cString)
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "�����"+"�����"
Local cCircu := "�����"+"�����"
Local cTrema := "�����"+"�����"
Local cCrase := "�����"+"�����" 
Local cTio   := "��"
Local cCecid := "��"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next                                                                                                                                                      
For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123 .Or. cChar $ '&'
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
cString := _NoTags(cString)
Return cString
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �OrdVetX3  � Autor �FELIPE NUNES DE TOLEDO �Data  � 28.Mai.11���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Ordena uma vetor que sera usado no MSEXECAUTO conforme      ���
���          �a posicao dos campos no SX3                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function OrdVetX3( aVetor, cTabela )
Local aRet     := {}
Local aAux     := {}
Local nCt      := 1
Local aArea    := GetArea()
Local aAreaSX3 := SX3->( GetArea() )

SX3->( dbSetOrder( 1 ) ) //-- X3_ARQUIVO + X3_ORDEM

If cTabela == NIL
    cTabela := SubStr( aVetor[1][1], 1, At( '_', aVetor[1][1] ) - 1 )
    cTabela := IIf( Len( cTabela ) == 2, 'S' + cTabela, cTabela )
EndIf

SX3->( dbSeek( cTabela ) )

While !SX3->( Eof () ) .AND. SX3->X3_ARQUIVO == cTabela
    If  ( nPos := aScan( aVetor, { |x| RTrim( SX3->X3_CAMPO ) $ RTrim( x[1] ) } ) ) <> 0
        aAdd( aAux, { StrZero( nCt, 4), aVetor[nPos] } )
        nCt++
    EndIf
    SX3->( dbSkip() )
End

aSort( aAux,,, { | x, y | x[1] < y[1] } )
aEval( aAux, { | x, y | aAdd( aRet, aAux[y][2] ) } )

RestArea( aAreaSX3 )
RestArea( aArea )
Return aRet