#INCLUDE "PROTHEUS.CH"

User Function CepCobItau()

Local CepCobItau
               

IF EMPTY(SA1->A1_CEPC)

	CepCobItau  := SA1->A1_CEP

Elseif EMPTY(SA1->A1_CEP)    

	CepCobItau  := "00000000"

Else

	CepCobItau  := SA1->A1_CEPC

Endif

RETURN(CepCobItau)