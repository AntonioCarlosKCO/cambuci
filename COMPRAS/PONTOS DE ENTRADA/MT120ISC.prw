#INCLUDE "PROTHEUS.CH"

/*------------------------------------------------------------------------------------------------------------------------------------------------*\
| Fonte:	 |	MT120ISC.PRW                                                                                                                       |
| Autor:	 |	Raphael F. Araújo                                                                                                                      |
| Data:		 |	22/11/2016                                                                                                                         |
| Descrição: |	Ponto de Entrada para preencher os campos de categoria de compra e licitação na inclusão do Pedido.								   |
\*------------------------------------------------------------------------------------------------------------------------------------------------*/

User Function MT120ISC()

	Local _nPOper 		:= ascan( aHeader, {|x,y|  alltrim(x[2]) == 'C7_OPER'})
	
	aCols[n][_nPOper]	:= _cOper
	RunTrigger(2,n,nil,,'C7_OPER')
			
Return