#include 'protheus.ch'
#include 'parmtype.ch'

// PEGA O CONTE�DO DO ACOLS NO MOMENTO QUE ENTRA PARA ALTERAR
// PARA IDENTIFICAR SE FORAM INSERIDOS ITENS NOVOS NO FONTE TK271BOK.PRW
// DJALMA BORGES - 10/02/2017

user function TMKACTIVE()

	Public _aColsAnt
	
	_aColsAnt := Aclone(aCols)
	
return