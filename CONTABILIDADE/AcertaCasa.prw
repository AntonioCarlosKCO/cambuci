#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

User Function AcertaCasa()
Private lQtd	:= .F.
Private lVal 	:= .F.
Private lOk		:= .F. 
Private cQtdCp	:= Space(3)
Private cqtdDc	:= Space(2)
Private cPict	:= Space(25)

	If MsgYesNo("Confirma acerto das casas decimais?")
		//chama Tela para informar o tamanho do campo
		
		U_fTSelTam()
		
		//ACERTO DE QUANTIDADE
		If lOk .and. lQtd
			Processa({|| ProcQuant()},"Processando...Alteração de casas decimais de Quantidade...")
		EndIf
		//ACERTO DE VALORES
		If lOk .and. lVal	
			Processa({|| ProcPreco()},"Processando...Alteração de casas decimais de Valor...")
		EndIf	
	EndIf

Return Nil


Static Function ProcQuant()
Local cAliasUPD:= ""
Local aAliasUPD	:={} 

	If SELECT("TMP1")>0 
		dbSelectArea("TMP1")
		dbCloseArea()
	EndIf

	cArquivo := "\CASAS\QUANT.DBF"
	dbUseArea(.T.,"DBFCDXADS",cArquivo,"TMP1",.T.,.F.)
	
	dbSelectArea("TMP1")
	dbGotop()
	ProcRegua(TMP1->(LastRec()))
	While !EOF()  
	    cCampo := AllTrim(TMP1->QUANT)  
	    IncProc("Alterando o campo" + AllTrim(cCampo) )       
		
		dbSelectArea("SX3")
		dbSetOrder(2)
		If dbSeek(cCampo)
			RecLock("SX3",.F.)      
			SX3->X3_TAMANHO := Val(cQtdCp)
			SX3->X3_DECIMAL := Val(cQtdDc)
			SX3->X3_PICTURE := AllTrim(cPict)
			MsUnLock()                     
			If cAliasUPD <>	SX3->X3_ARQUIVO
				cAliasUPD:=	SX3->X3_ARQUIVO
				aadd(aAliasUPD,{SX3->X3_ARQUIVO})
			EndIf	
		EndIf
	    
	    /*     
		cQuery := "UPDATE TOP_FIELD "
		cQuery += "SET FIELD_DEC = "+cQtdDC+", FIELD_PREC = "+cQtdCp+" "
		cQuery += "WHERE FIELD_NAME = '"+cCampo+"' "
		TCSqlExec(cQuery)     
	     */
		

		dbSelectArea("TMP1")
		dbSkip()
	EndDo       
	For _nR:= 1 to len(aAliasUPD) 
		X31UPDTABLE (aAliasUPD[_nR,1])
	Next _nR	
MsgAlert("Finalizado Alteração de Quantidade")
           
return NIL

Static Function ProcPreco()
Local cAliasUPD:= ""
Local aAliasUPD	:={}

	If SELECT("TMP2")>0 
		dbSelectArea("TMP2")
		dbCloseArea()
	EndIf
	cArquivo := "\CASAS\PRECO.DBF"
	dbUseArea(.T.,"DBFCDXADS",cArquivo,"TMP2",.T.,.F.)
	ProcRegua(TMP2->(LastRec()))	
	dbSelectArea("TMP2")
	dbGotop()
	While !EOF()  	           
		cCampo := AllTrim(TMP2->PRECO)  
		IncProc("Alterando o campo" + AllTrim(cCampo) )       	
		
		dbSelectArea("SX3")
		dbSetOrder(2)
		If dbSeek(cCampo)
			RecLock("SX3",.F.)      
			SX3->X3_TAMANHO := Val(cQtdCp)
			SX3->X3_DECIMAL := Val(cQtdDc)
			SX3->X3_PICTURE := AllTrim(cPict)
			MsUnLock()
			If cAliasUPD <>	SX3->X3_ARQUIVO
				cAliasUPD:=	SX3->X3_ARQUIVO
				aadd(aAliasUPD,{SX3->X3_ARQUIVO})
			EndIf	
		EndIf
	    /*     
		cQuery := "UPDATE TOP_FIELD "
		cQuery += "SET FIELD_DEC = "+cQtdCp+", FIELD_PREC = "+cQtdCp+" "
		cQuery += "WHERE FIELD_NAME = '"+cCampo+"' "
		TCSqlExec(cQuery)     
	   */
	
		dbSelectArea("TMP2")
		dbSkip()
	EndDo       
	For _nR:= 1 to len(aAliasUPD) 
		X31UPDTABLE (aAliasUPD[_nR,1])
	Next _nR	
MsgAlert("Finalizado Alteração de Valor")

return NIL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fTSelTam  ºAutor  ³Reginaldo G. Ribeiroº Data ³  08/02/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para Seleção do Tamanho dos campos e da casa decimal  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function fTSelTam


SetPrvt("oDlg1","oSay1","oSay2","oSay3","oGet1","oGet2","oBtn1","oBtn2")

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Definicao do Dialog e todos os seus componentes.                        ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
oDlg1      := MSDialog():New( 092,232,329,605,"Selecionar Tamanho Decimal",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 008,004,{||"Esta Função irá realizar a alterração do tamanho do campo e das casas decimais"+Chr(10)+Chr(13)+;
			" conforme valores informado nos parametros"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,172,016)
oSay2      := TSay():New( 032,004,{||"Tam Campo"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay3      := TSay():New( 056,004,{||"Tam Decimal"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) 
oSay4      := TSay():New( 076,003,{||"Picture"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGet1      := TGet():New( 032,044,{|u|if(PCount()>0,cQtdCp:=u,cQtdCp)},oDlg1,020,008,'@E 999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"",cQtdCp,,)
oGet2      := TGet():New( 054,044,{|u|if(PCount()>0,cQtdDc:=u,cQtdDc)},oDlg1,020,008,'@E 99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"",cQtdDc,,)
oGet3      := TGet():New( 073,043,{|u|if(PCount()>0,cPict:=u,cPict)},oDlg1,049,008, ,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"",cPict,,)
oCBox1     := TCheckBox():New( 032,116,"Só de Valor",{|u| If(PCount()>0,lVal:=u,lVal)},oDlg1,048,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCBox2     := TCheckBox():New( 054,116,"Só de Quantidade",{|u| If(PCount()>0,lQtd:=u,lQtd)},oDlg1,048,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oBtn1      := TButton():New( 096,088,"ok",oDlg1,{|| lOk:=.T., oDlg1:End()},037,012,,,,.T.,,"",,,,.F. )
oBtn2      := TButton():New( 096,136,"Cancelar",oDlg1,{|| lOk:=.F.,oDlg1:End()},037,012,,,,.T.,,"",,,,.F. )

oDlg1:Activate(,,,.T.)

Return
