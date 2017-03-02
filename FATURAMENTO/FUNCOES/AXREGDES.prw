#include "protheus.ch"


USER FUNCTION AxRegDes()
 
PRIVATE cCadastro  := "Regras de Desconto GeoSales"
 
PRIVATE aRotina     := {}
 
AxCadastro("ZZE", OemToAnsi(cCadastro),".T.",".T.")
 
Return Nil  