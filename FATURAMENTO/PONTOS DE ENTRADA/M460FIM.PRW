#include "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#Include "PROTHEUS.CH"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} M460FIM

Ponto de Entrada após a Gravação da Nota de Saída

@author  Allan Bonfim

@since   07/11/2014

@version P11
 
/*/
//-------------------------------------------------------------------

User Function M460FIM()

Local _aArea	:= Getarea()
Local _aAreaSE1	:= SE1->(GetArea())

/*/_______________________________________
SC5->(dbSetOrder(1))
if dbSeek(xfilial('SC5')+SD2->D2_PEDIDO)
	Reclock("SF2",.F.)
	SF2->F2_ESPECI5 := SC5->C5_ESPECI5
	SF2->F2_ESPECI6 := SC5->C5_ESPECI6
	SF2->F2_VOLUME5 := SC5->C5_VOLUME5
	SF2->F2_VOLUME6 := SC5->C5_VOLUME6
	SF2->(MsUnlock())
Endif    
*/


DbSelectArea("SE1")
SE1->(DbSetOrder(2)) //E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
If SE1->(DbSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+SF2->F2_DUPL))
	While !SE1->(EOF()) .AND. xFilial("SE1") == SE1->E1_FILIAL .AND. SF2->F2_CLIENTE == SE1->E1_CLIENTE .AND. SF2->F2_LOJA == SE1->E1_LOJA .AND. SF2->F2_PREFIXO == SE1->E1_PREFIXO .AND. SF2->F2_DUPL == SE1->E1_NUM
//		If !GETADVFVAL("SA1", "A1_XTPFAT", xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA, 1) == 'S'			
			If SE1->E1_TIPO $ MVNOTAFIS
				Reclock("SE1", .F.)
					SE1->E1_PORTADO	:= GETADVFVAL("SA1", "A1_BCO1", xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA, 1)
				SE1->(MsUnlock())
			EndIf
//		EndIf
				
		SE1->(DbSkip())		
	EndDo
EndIf

//Atualiza a tabela CDL - COMPLEMENTO DE EXPORTAÇÃO
If SF2->F2_EST == "EX"
	RecLock("CDL", .T.)    
    	CDL->CDL_FILIAL := xFilial("SF2")
    	CDL->CDL_DOC    := SF2->F2_DOC    	
    	CDL->CDL_SERIE  := SF2->F2_SERIE
    	CDL->CDL_CLIENT := SF2->F2_CLIENTE
    	CDL->CDL_LOJA   := SF2->F2_LOJA
    	CDL->CDL_ESPEC  := SF2->F2_ESPECIE
    	CDL->CDL_ITEMNF := SD2->D2_ITEM    	
    	CDL->CDL_PRODNF := SD2->D2_COD
    	CDL->CDL_PAIS   := "105" //BRASIL
    	CDL->CDL_UFEMB  := AVKEY(SM0->M0_ESTCOB, "CDL_UFEMB") //SP
    	CDL->CDL_LOCEMB := AVKEY(SM0->M0_CIDCOB, "CDL_LOCEMB") //SAO PAULO
    	CDL->CDL_LOCDES := AVKEY(SM0->M0_CIDCOB, "CDL_LOCDES") //SAO PAULO
    	CDL->CDL_INDDOC := "0" //0=Declaracao de Exportacao;1=Declaracao simplificada de exportacao
	CDL->(MsUnlock())
EndIf

RestArea(_aAreaSE1)
RestArea(_aArea)

Return