#INCLUDE "TOTVS.CH"
 
USER FUNCTION AxcadZZH()
 
PRIVATE cCadastro  := "Cadastro NCM x TES"
 
PRIVATE aRotina     := {}
 
AxCadastro("ZZH", OemToAnsi(cCadastro),".T.",".T.")
 
Return Nil