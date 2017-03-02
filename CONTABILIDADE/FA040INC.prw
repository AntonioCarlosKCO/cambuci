
User Function FA040INC()
Local lRetorno := .T.                                                                       

If INCLUI .And. AllTrim(M->E1_TIPO) == "NF" 
	lRetorno := .F.
	Alert("Tipo NF não pode ser informado manualmente!")
EndIf

Return lRetorno