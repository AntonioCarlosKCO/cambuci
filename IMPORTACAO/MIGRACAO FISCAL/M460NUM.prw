#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} M460NUM

Ponto de Entrada na geracao da nota fiscal de saida para gravar o mesmo numero que esta contido no Xml de importacao

@author Allan Bonfim

@since 07/08/2015

@param

@obs  

@return

/*/
//-------------------------------------------------------------------
USER FUNCTION M460NUM()

Local cNumPv	:= PARAMIXB[1][1] //Numero do Pedido
Local cItemPv	:= PARAMIXB[1][2] //Item do Pedido
Local cSLibPv	:= PARAMIXB[1][3] //Sequencia da liberação
Local cNumNota	:= ""

DBSelectArea("SC5")
cNumNota := SC5->(GETADVFVAL("SC5", "C5_NOTAIMP", xFilial("SC5")+AVKEY(cNumPv, "C5_NOTAIMP"), 1))

If !EMPTY(cNumNota)
   cNumero := cNumNota
EndIf
   
Return Nil