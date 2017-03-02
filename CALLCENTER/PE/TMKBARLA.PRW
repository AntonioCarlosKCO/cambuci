#Include "Totvs.ch"

/*
@DOC
Funcao: U_TMKBARLA
Titulo: ponto entrada para criar botão lateral no orçamento, usado na rotina 
Parametros: 
1 - Array
2 - Array
Retorno: Array -> bitmap, função , titulo
@DOC
*/
User Function TMKBARLA(aBotao, aTitulo)            

	aAdd(aBotao,{"S4WB011N"	,{|| U_CTMK002()} 		,"Consulta Produtos[F12]"})   
	SetKey(VK_F12,{|| If( INCLUI .OR. ALTERA, U_CTMK002(),.T.)})
	
	aAdd(aBotao,{"S4WB011N", {|| U_TELAEST()}, "Mapa de Produto"})   
	SetKey(VK_F4,{|| If( INCLUI .OR. ALTERA, U_TELAEST(),.T.)})
		
Return(aBotao)

