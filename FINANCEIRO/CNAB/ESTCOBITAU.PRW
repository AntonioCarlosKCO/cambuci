#INCLUDE "PROTHEUS.CH"

User Function EstCobItau()

Local EstCobItau      

EstCobItau  := IIF(EMPTY(SA1->A1_ESTC),Substr(SA1->A1_EST,1,15),Substr(SA1->A1_ESTC,1,15))


RETURN(EstCobItau)