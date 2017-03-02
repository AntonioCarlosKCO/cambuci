#INCLUDE "TOTVS.CH"
 
USER FUNCTION AxcadZZI()
 
PRIVATE cCadastro  := "REGRA PARA IMPORTACAO FISCAL"
 
PRIVATE aRotina     := {}
 
AxCadastro("ZZI", OemToAnsi(cCadastro),".T.",".T.")
 
Return Nil