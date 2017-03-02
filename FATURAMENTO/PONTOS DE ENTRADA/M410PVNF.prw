#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M410PVNF ³ Autor ³ Raphael Araújo 	  ³ Data ³ 17.10.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto de entrada para validação.							  ³±±
±±³			   Executado antes da rotina de geração de NF's (MA410PVNFS). ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
/*/

User Function M410PVNF()

	//Local cDtSrv	:= Date()
	//Local cDtUsr	:= dDatabase
	//Local aArea := {}
	Local lCont	:= .T.
	
	/*
	If cDtUsr <> cDtSrv
		Alert("A data-base de seu sistema difere da data-base do servidor, por isso a NF não poderá ser gerada! Saia do sistema ou ajuste sua data-base! Data-base do Servidor "+DTOC(cDtSrv))
		lCont	:= .F.
	EndIf		
	*/
 	
 	dbselectarea("SC6")
	DbSetOrder(1)
	dbSeek(xfilial('SC6')+C6_ITEM+SC6->C6_NUM)
     
    If SC6->C6_QTDVEN <> SC6->C6_QTDLIB
    	alert("Não é permitido liberação parcial. Favor liberar quantidade total! - M410PVNF")
    	lCont := .F. 
    Endif
      	
Return lCont