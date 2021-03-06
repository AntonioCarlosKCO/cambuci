#INCLUDE "TOTVS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �XQGAltPV  �Autor  �Stanko              � Data �  16/01/17   ���
�������������������������������������������������������������������������͹��
���Desc.     � Programa para alterar os pedidos de venda em aberto.       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function XQGAltPV()

dbSelectArea("SC5")
dbSetOrder(1)

dbSelectArea("SC6")
dbSetOrder(1)

dbSelectArea("SC9")
dbSetOrder(1)
 
If cFilAnt <> "0201"
	MsgAlert("Nao permitido")
	Return Nil
EndIf
	
If MsgYesNo("Confirma altera��o de todos os pedidos de venda em aberto?")
	Processa({|| ProcAlt()},"Aguarde","Processando...")
EndIf

Return Nil

Static Function ProcAlt()
Local nContador := 0

cQuery := "SELECT C5_FILIAL, C5_NUM FROM "+RetSQLName("SC5")+" SC5 WHERE SC5.D_E_L_E_T_ = ' ' "
cQuery += "AND C5_FILIAL = '"+xFilial("SC5")+"' "
cQuery += "AND C5_NOTA = ' ' "
cQuery += "AND C5_TIPO = 'N' "
cQuery += "AND C5_XUPD = '' "
cQuery += "AND C5_NUM NOT IN ('000001') "
cQuery += "ORDER BY C5_FILIAL, C5_NUM "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "TMPGERA", .T., .F.)


While !TMPGERA->(EOF())
	
	MemoWrite("C:\temp\antes.txt",TMPGERA->C5_NUM)
	
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	SC5->(Dbseek(xFilial("SC5")+TMPGERA->C5_NUM))
	RecLock("SC5",.F.)
	SC5->C5_XOPER := "XX"   
	SC5->C5_XUPD  := "1"
	SC5->(MsUnLock())
	
	//AltPV(2)
	AltPV(1)

	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	SC5->(Dbseek(xFilial("SC5")+TMPGERA->C5_NUM))
	RecLock("SC5",.F.)
	SC5->C5_XUPD  := "2"
	SC5->(MsUnLock())
	
	                                          
	MemoWrite("C:\temp\depois.txt",SC5->C5_NUM)
	
	TMPGERA->(dbSkip())
	
EndDo
TMPGERA->(dbCloseArea())
MsgAlert("Processamento finalizado!")

Return Nil


Static Function AltPV(nOper) 
Local aArea := Getarea()
Local aCabPV  := {}
Local aItemPV := {}
Local aAux   := {}
Local nOpc    := 4

DbSelectArea("SX3") 
dbSetOrder(1)
DbSeek( "SC5" )
aCabPV:={}


/*Aadd( aCabPV, { "C5_FILIAL", xFilial("SC5"), Nil} )
Aadd( aCabPV, { "C5_NUM", SC5->C5_NUM, Nil} )
Aadd( aCabPV, { "C5_CLIENTE", SC5->C5_CLIENTE, Nil} )
Aadd( aCabPV, { "C5_LOJACLI", SC5->C5_LOJACLI, Nil} )
Aadd( aCabPV, { "C5_TIPO"	, SC5->C5_TIPO, Nil} )
Aadd( aCabPV, { "C5_MENNOTA", AllTrim(SC5->C5_MENNOTA)+".", Nil} )
Aadd( aCabPV, { "C5_XOPER", StrZero(nOper,2), Nil} )
*/
While !Sx3->(Eof()) .And. Sx3->X3_Arquivo="SC5"
	
	If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
		
		cCampo := AllTrim(Sx3->X3_Campo)
		If cCampo $ "C5_NUM/C5_CLIENTE/C5_LOJACLI/C5_TIPO/C5_MENNOTA/C5_XOPER" .or. (SC5->(FieldPos(cCampo)) > 0 .And. !Empty(SC5->&(cCampo)))
			
			If  cCampo == "C5_XOPER"
				Aadd( aCabPV, { cCampo, StrZero(nOper,2), Nil} )
				
			ElseIf cCampo == "C5_MENNOTA"
				Aadd( aCabPV, { cCampo, AllTrim(SC5->C5_MENNOTA)+".", Nil} )
			Else
				Aadd( aCabPV, { cCampo, SC5->&(cCampo), Nil} )
			EndIf
			
		EndIf
		
	EndIf
	
	Sx3->(DbSkip())
	
EndDo
//Aadd( aCabPV, { "C5_MENNOTA", AllTrim(SC5->C5_MENNOTA)+".", Nil} )

DbSelectarea("SC6")     
dbSetOrder(1)
Dbseek(xFilial("SC6")+SC5->C5_NUM)

While  !Sc6->(Eof()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM
	
	RecLock("SC6",.F.)
	SC6->C6_TES := "XXX"
	SC6->(MsUnLock())

	aAux :={}
	
	DbSelectArea("SX3")
	DbSeek( "SC6" )
	While !Sx3->(Eof()) .And. Sx3->X3_Arquivo="SC6"
		
		
		If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
			
			cCampo := AllTrim(Sx3->X3_Campo)
			
			If cCampo $ "C6_ITEM/C6_PRODUTO/C6_LOCAL/C6_QTDVEN/C6_PRCVEN/C6_VALOR/C6_TES/C6_OPER" .Or. (SC6->(FieldPos(cCampo)) > 0 .And. !Empty(SC6->&(cCampo)))
				
				If cCampo == "C6_TES"
					cTES :=MaTesInt(2,StrZero(nOper,2),SC5->C5_CLIENTE,SC5->C5_LOJACLI,"C",SC6->C6_PRODUTO,)
					Aadd( aAux, { cCampo, cTES, Nil} )
				ElseIf 	cCampo == "C6_OPER"                     
					Aadd( aAux, { cCampo, StrZero(nOper,2), Nil} )
				Else
					Aadd( aAux, { cCampo, SC6->&(cCampo), Nil} )
				EndIf
			EndIf
		EndIf
		
		Sx3->(DbSkip())
	EndDo
	
	/*cTES :=MaTesInt(2,StrZero(nOper,2),SC5->C5_CLIENTE,SC5->C5_LOJACLI,"C",SC6->C6_PRODUTO,)
	
	Aadd( aAux, { "C6_FILIAL", SC6->C6_FILIAL, Nil} )
	Aadd( aAux, { "C6_ITEM", SC6->C6_ITEM, Nil} )
	Aadd( aAux, { "C6_PRODUTO", SC6->C6_PRODUTO, Nil} )
	Aadd( aAux, { "C6_LOCAL", SC6->C6_LOCAL, Nil} )
	Aadd( aAux, { "C6_QTDVEN", SC6->C6_QTDVEN, Nil} )
	Aadd( aAux, { "C6_PRCVEN", SC6->C6_PRCVEN, Nil} )
	Aadd( aAux, { "C6_VALOR", SC6->C6_VALOR, Nil} )
	Aadd( aAux, { "C6_TES", cTES, Nil} )
	Aadd( aAux, { "C6_OPER", StrZero(nOper,2), Nil} )
	*/
	
	aadd(aItemPV,aAux)
	Sc6->(DbSkip())
	
Enddo

lMsErroAuto := .F.
MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItemPV,nOpc)
If lMsErroAuto
	MostraErro()
EndIf

RestArea(aArea)                        

Return Nil


