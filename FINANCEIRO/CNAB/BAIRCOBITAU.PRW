#INCLUDE "PROTHEUS.CH"

User Function baiCobItau()

Local cbCob 

cbCob  := IIF(EMPTY(SA1->A1_BAIRROC),Substr(SA1->A1_BAIRRO,1,12),Substr(SA1->A1_BAIRROC,1,12))                                 

RETURN(cbCob)