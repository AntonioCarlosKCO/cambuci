#include "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �U_AddCTH  �Autor  �Stanko              � Data �  29/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Adiciona registros na tabela CTH.                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AddCTH()
If MsgYesNo("Confirma carga da tabela de classe de valor (CTH)?")
	Processa( {|| AtuClasse()}	,"Aguarde" ,"Atualizando classe de valor...")
EndIf	
	
Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������������������S����������������ͻ��
���Programa  �AtuClasse �Autor  �Microsiga           � Data �  10/30/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function AtuClasse()
Local cQuery
Local cEnter := Chr(13)

cQuery := "SELECT A1_FILIAL FILIAL, A1_CGC CGC , A1_NOME NOME FROM "+RetSQLName("SA1")+" SA1 "
cQuery += "WHERE SA1.D_E_L_E_T_ = '' "
cQuery += "AND A1_CGC <> '' "
cQuery += "AND A1_CGC NOT IN "

cQuery += "(SELECT SUBSTRING(CTH_CLVL,1,14) FROM "+RetSQLName("CTH")+" CTH "
cQuery += "WHERE CTH.D_E_L_E_T_ = ' '   ) "  

cQuery += "UNION ALL "

cQuery += "SELECT A2_FILIAL FILIAL, A2_CGC CGC, A2_NOME NOME FROM "+RetSQLName("SA2")+" SA2 "
cQuery += "WHERE SA2.D_E_L_E_T_ = '' " 
cQuery += "AND A2_CGC <> '' "
cQuery += "AND A2_CGC NOT IN "
cQuery += "(SELECT SUBSTRING(CTH_CLVL,1,14) FROM "+RetSQLName("CTH")+" CTH "
cQuery += "WHERE CTH.D_E_L_E_T_ = ' '   )  "  
                    
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "TMP", .F., .T. )


ProcRegua(RecCount())

While !EOF()
	
	//IncProc()
	
	cChave := AllTrim(TMP->CGC)
	If Empty(cChave)
		cChave := "88888888888888"
	EndIf	
	
	dbSelectArea("CTH")
	dbSetOrder(1)
	If !dbSeek(xFilial()+cChave)
		RecLock("CTH",.T.)
		CTH->CTH_FILIAL := xFilial()
		CTH->CTH_CLVL   := AllTrim(cChave)
		CTH->CTH_DESC01 := Substr(TMP->NOME,1,30)
		CTH->CTH_CLASSE := "2"
		CTH->CTH_BLOQ   := "2"
		MsUnLock()
	EndIf
	
	
	dbSelectArea("TMP")
	dbSkip()
EndDo
dbSelectArea("TMP")
dbCloseArea()

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M030Inc   �Autor  �Microsiga           � Data �  10/30/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �P.E. apos a gravacao do cliente                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function M030Inc()


cChave := AllTrim(SA1->A1_CGC)  
cNome  := AllTrim(SA1->A1_NOME)  

If !CTH->(dbSeek(xFilial("CTH")+cChave))
		RecLock("CTH",.T.)
		CTH->CTH_FILIAL := xFilial()
		CTH->CTH_CLVL   := AllTrim(cChave)
		CTH->CTH_DESC01 := Substr(cNome,1,30)
		CTH->CTH_CLASSE := "2"
		CTH->CTH_BLOQ   := "2"
		CTH->(MsUnLock())
EndIf
  
  
  
Return .T. //Nil      


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M020Inc   �Autor  �Microsiga           � Data �  10/30/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �P.E. apos a gravacao do fornecedor                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function M020Inc()

cChave := AllTrim(M->A2_CGC)  
cNome  := AllTrim(M->A2_NOME)  
 

CTH->(dbSetOrder(1))
If !CTH->(dbSeek(xFilial("CTH")+cChave))
	RecLock("CTH",.T.)
	CTH->CTH_FILIAL := xFilial()
	CTH->CTH_CLVL   := AllTrim(cChave)
	CTH->CTH_DESC01 := Substr(cNome,1,30)
	CTH->CTH_CLASSE := "2"
	CTH->CTH_BLOQ   := "2"
	CTH->(MsUnLock())
EndIf

  
Return .T.