#INCLUDE "TOTVS.CH"
 
USER FUNCTION AxcadZZJ()
 
PRIVATE cCadastro  := "CADASTRO GRUPO PESSOA"
 
PRIVATE aRotina     := {}
 
AxCadastro("ZZJ", OemToAnsi(cCadastro),".T.",".T.")
 
Return Nil