#INCLUDE "PROTHEUS.CH"

User Function MunCobItau()

Local MunCobItau
                       
MunCobItau  := IIF(EMPTY(SA1->A1_MUNC),Substr(SA1->A1_MUN,1,15),Substr(SA1->A1_MUNC,1,15))


RETURN(MunCobItau)