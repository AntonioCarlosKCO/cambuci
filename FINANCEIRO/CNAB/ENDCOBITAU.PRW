#INCLUDE "PROTHEUS.CH"

User Function EndCobItau()

Local EndCobItau       

EndCobItau  := IIF(Empty(SA1->A1_ENDCOB),SubStr(SA1->A1_END,1,40),SubStr(SA1->A1_ENDCOB,1,40))

RETURN(EndCobItau)