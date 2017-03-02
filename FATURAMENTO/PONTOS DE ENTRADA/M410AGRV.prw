#include 'protheus.ch'
#include 'parmtype.ch'

// DJALMA BORGES 29/11/2016
// PEGA O VALOR DO C5_CONDPAG ANTES DE SER ALTERADO

user function M410AGRV()

	Public _cConPgAnt := ""
	
	If ALTERA == .T.
		_cConPgAnt := SC5->C5_CONDPAG
	Else	
		_cConPgAnt := ""
	End If
	
return