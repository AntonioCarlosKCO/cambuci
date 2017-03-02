#INCLUDE 'totvs.ch'

#Include "PROTHEUS.CH"
/*
@DOC
Funcao: U_CTMK002
Titulo: Tela consulta outros clientes, execcutado do botão no TMK
Parametros:
Retorno: Logico
@DOC
*/
Function U_CTMK002()

Local oDlg1, oButton11, oButton21, oGet11, oGet21, oGet31, oGet41
Local oSay11, oSay21, oSay31, oSay41

Local cCli  := Space(TamSX3("UA_CLIENTE")[1])
Local cLoj  := '01'
Local cOper := '01'
local cProd := Space(TamSX3("UB_PRODUTO")[1])

DEFINE MSDIALOG oDlg1 TITLE "Consulta referencia outros clientes" FROM 000, 000  TO 150, 400 COLORS 0, 16777215 PIXEL

    @ 015, 014 SAY oSay11 PROMPT "Cliente:"    SIZE 025, 007 OF oDlg1 COLORS 0, 16777215 PIXEL
    @ 015, 085 SAY oSay21 PROMPT "Operação:"   SIZE 025, 007 OF oDlg1 COLORS 0, 16777215 PIXEL
    @ 015, 121 SAY oSay31 PROMPT "Referencia:" SIZE 037, 007 OF oDlg1 COLORS 0, 16777215 PIXEL

    @ 026, 014 MSGET oGet11 VAR cCli  SIZE 040, 010 OF oDlg1 PICTURE "@!" VALID { || fValidCli(cCli,cLoj) } COLORS 0, 16777215 F3 "SA1" PIXEL
    @ 026, 059 MSGET oGet21 VAR cLoj  SIZE 012, 010 OF oDlg1 PICTURE "@!" VALID { || fValidCli(cCli,cLoj) } COLORS 0, 16777215 PIXEL
    @ 026, 085 MSGET oGet31 VAR cOper SIZE 018, 010 OF oDlg1 PICTURE "@!" VALID { || fValidOper(cOper) } COLORS 0, 16777215 F3 "DJ" PIXEL
    @ 026, 121 MSGET oGet41 VAR cProd SIZE 060, 010 OF oDlg1 PICTURE "@!" VALID { || fValidProd(cProd,cCli,cLoj,cOper) } COLORS 0, 16777215 PIXEL

    @ 050, 090 BUTTON oButton11 PROMPT "&Cancelar"  SIZE 037, 012 OF oDlg1 ACTION { || oDlg1:End() } PIXEL

ACTIVATE MSDIALOG oDlg1

Return .T.

//----------------------------------------
//validar o cliente
Static Function fValidCli(cCli,cLoj)
//-----------------------------------------
Local lRet := .F.
Local aArea := GetArea()
Local aAreaSA1 := SA1->(GetArea())
SA1->(DbSetOrder(1))
If SA1->(DbSeek(XFilial('SA1')+cCli+cLoj))
   lRet := .T.
EndIf   
RestArea(aArea)
RestArea(aAreaSA1)
Return lRet

//----------------------------------------
//validar operação fiscal
Static Function fValidOper(cOper)
//----------------------------------------
Local lRet := .F.
Local aArea := GetArea()
Local aAreaSA1 := SA1->(GetArea())
If ExistCpo("SX5","DJ"+cOper)
   lRet := .T.
EndIf   
RestArea(aArea)
RestArea(aAreaSA1)
Return lRet

//----------------------------------------
//validar caracteres da referencia
Static Function fValidProd(cProd,cCli,cLoj,cOper)
//----------------------------------------
Local aArea := GetArea()
Local lRet := .T.
U_CTMK001(cProd,'B',cCli,cLoj,cOper)
RestArea(aArea)

Return lRet