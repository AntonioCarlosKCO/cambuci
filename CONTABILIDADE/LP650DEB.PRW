#INCLUDE "rwmake.ch"
//---------------------------------------------------------------------------------------------------------------------------------=
//LANCAMENTO PARA CONTABILIDADE INCLUSAO DE DOCUMENTOS DE ENTRADA  =
//BUSCANDO A CONTA DÉBITO DO CADASTRO DE NATUREZAS - LP 650                   =
//---------------------------------------------------------------------------------------------------------------------------------=
//POR WALDIR ARRUDA 																							   =
//---------------------------------------------------------------------------------------------------------------------------------=
//ESPECIFICO ENCRENQUINHAS - DATA   27/10/15                                                                         =
//---------------------------------------------------------------------------------------------------------------------------------=

USER FUNCTION LP650DEB()
LOCAL cConta	:= ""
LOCAL aAREA_ATU	:= GETAREA()

DBSelectArea("SE2")
DBSetOrder(6)
DBSeeK(xFilial("SE2") + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_SERIE + SF1->F1_DOC )
    

DBSelectArea("SED")
DBSetOrder(1)
DBSeek( XFILIAL("SED") + SE2->E2_NATUREZ )
cConta := SED->ED_DEBITO

RESTAREA(aAREA_ATU)
RETURN(cConta)