#include "TOTVS.CH"
#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BUTESIMP

Função de busca da TES para importação dos movimentos fiscais (ZZI)

@author  Allan Bonfim

@since   05/08/2015

@version P11 

@param	[cCfop], caracter, obrigatório, Código CFOP
@param	[cTpOper], caracter, obrigatório, Tipo da operação (1=Entrada, 2=Saída, 3=Devolução de Venda, 4=Devolução de Compra)
@param	[cOrigPrd], caracter, opcional, Código da Origem do Produto
@param	[cNcmPrd], caracter, opcional, Código do NCM do Produto
@param	[cTpCliFor], caracter, opcional, Tipo do Cliente ou Fornecedor (A1_TIPO, A2_TIPO)
@param	[lIcms], lógico, opcional, Informa se possui o imposto ICMS
@param	[lIpi], lógico, opcional, Informa se possui o imposto IPI
@param	[lIcmsST], lógico, opcional, Informa se possui o imposto ICMS-ST
@param	[cCodPrd], caracter, opcional, Código do Produto. Utilizado para buscar a Origem (cOrigPrd) e NCM (cNcmPrd) quando não informados.
@param	[cCodCFor], caracter, opcional, Código do Cliente ou Fornecedor. Utilizado para buscar o Tipo do Cliente ou Fornecedor (cTpCliFor) quando não informado.
@param	[cLojCFor], caracter, opcional, Código do Cliente ou Fornecedor. Utilizado para buscar o Tipo do Cliente ou Fornecedor (cTpCliFor) quando não informado.
@param	[lBRedIcm], lógico, opcional, Informa se a Base de Cálculo do ICMS é reduzida.
@param	[lBRedIST], lógico, opcional, Informa se a Base de Cálculo do ICMS é reduzida.

@obs

@return [cTesRet] caracter, TES válida para utilização na importação

/*/
//-------------------------------------------------------------------

USER FUNCTION BUTESIMP(cCfop, cTpOper, cOrigPrd, cNcmPrd, cTpCliFor, lIcms, lIpi, lIcmsST, cCodPrd, cCodCFor, cLojCFor, lBRedIcm, lBRedIST)

Local aArea			:= GetArea()
Local cTesRet 		:= ""
Local cQuery 		:= ""
Local cTipoCli		:= ""
Local cTipoFor		:= ""
Local cQueryTes		:= GetNextAlias()
Local lcOrigPrd		:= .T. //Variável para identificar a passagem de valor através dos parâmetros da rotina
Local lcNcmPrd		:= .T. //Variável para identificar a passagem de valor através dos parâmetros da rotina
Local lcTipoFor		:= .T. //Variável para identificar a passagem de valor através dos parâmetros da rotina
Local lcTipoCli		:= .T. //Variável para identificar a passagem de valor através dos parâmetros da rotina
Local aFiltro		:= {}
Local lFiltro		:= .T.
Local cFiltro		:= ""
Local aAreaSA1
Local aAreaSA2
Local aAreaSB1
Local aArea

Default cCfop		:= ""
Default cTpOper		:= ""
Default cOrigPrd	:= ""
Default cNcmPrd		:= ""
Default cCodPrd		:= ""
Default cCodCFor	:= ""
Default cLojCFor	:= ""
Default cTpCliFor	:= ""
Default lIcms		:= .F.
Default	lIpi		:= .F.
Default lIcmsST		:= .F.   
Default lBRedIcm	:= .F.
Default lBRedIST	:= .F.

If !EMPTY(cCfop) .AND. !EMPTY(cTpOper)

	If !EMPTY(cCodPrd)
		DbSelectArea("SB1") 
		aAreaSB1 := SA1->(GetArea())
			SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
			If SB1->(DbSeek(xFilial("SB1")+AVKEY(cCodPrd, "B1_COD")))
				If EMPTY(cOrigPrd)
					cOrigPrd 	:= SB1->B1_ORIGEM
					lcOrigPrd	:= .F.
				EndIf
		
				If EMPTY(cNcmPrd)
					cNcmPrd 	:= SB1->B1_POSIPI
					lcNcmPrd	:= .F.
				EndIf
			EndIf
		RestArea(aAreaSB1)
	EndIf

	If (EMPTY(cCodCFor) .AND. EMPTY(cLojCFor)) .OR. EMPTY(cTpCliFor)
		lcTipoFor	:= .F.
		lcTipoCli	:= .F.
	EndIf	
	
	If cTpOper $ "1/4" //Entradas e Devoluções de Compras
		If EMPTY(cTpCliFor)		
			If !EMPTY(cCodCFor) .AND. !EMPTY(cLojCFor)
			    If Alltrim(cCfop) == "1949" .or. AllTrim(cCFOP) == "2949" .or. AllTrim(cCFOP) == "1915" .or. AllTrim(cCFOP) == "2915"
					DbSelectArea("SA1") 
					aArea := SA1->(GetArea())
					SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
					If SA1->(DbSeek(xFilial("SA1")+AVKEY(cCodCFor, "A1_COD")+AVKEY(cLojCFor, "A1_LOJA")))
						If EMPTY(cTipoFor)
							cTipoFor 	:= "R" //SA2->A2_TIPO
							lcTipoFor	:= .F.
							RestArea(aArea)
						EndIf
					Else
						DbSelectArea("SA2") 
						aArea := SA2->(GetArea())
						SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
						If SA2->(DbSeek(xFilial("SA2")+AVKEY(cCodCFor, "A2_COD")+AVKEY(cLojCFor, "A2_LOJA")))
							If EMPTY(cTipoFor)
								cTipoFor 	:= SA2->A2_TIPO
								lcTipoFor	:= .F.
								RestArea(aArea)
							EndIf
						EndIf
					EndIf
			    Else
					DbSelectArea("SA2") 
					aAreaSA2 := SA2->(GetArea())
						SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
						If SA2->(DbSeek(xFilial("SA2")+AVKEY(cCodCFor, "A2_COD")+AVKEY(cLojCFor, "A2_LOJA")))
							If EMPTY(cTipoFor)
								cTipoFor 	:= SA2->A2_TIPO
								lcTipoFor	:= .F.
							EndIf
						EndIf
					RestArea(aAreaSA2)
			    
			    Endif
			EndIf
		Else
			cTipoFor := cTpCliFor
		EndIf
	ElseIf cTpOper $ "2/3" //Saídas e Devoluções de Vendas
		If EMPTY(cTpCliFor)
			If !EMPTY(cCodCFor) .AND. !EMPTY(cLojCFor)
				DbSelectArea("SA1")
				aAreaSA1 := SA1->(GetArea())
					SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
					If SA1->(DbSeek(xFilial("SA1")+AVKEY(cCodCFor, "A1_COD")+AVKEY(cLojCFor, "A1_LOJA")))
						If EMPTY(cTipoCli)
							cTipoCli 	:= SA1->A1_TIPO
							lcTipoCli	:= .F.
						EndIf
					EndIf
				RestArea(aAreaSA1)
			EndIf
		Else
			cTipoCli := cTpCliFor
		EndIf
	EndIf
	
	cQuery := "SELECT DISTINCT ZZI_TESPAD AS TES, ZZI_ORIGEM, ZZI_NCMPRD, ZZI_TPFORN, ZZI_TPCLIE "+CHR(13)+CHR(10)  
	cQuery += "FROM "+RETSQLNAME("ZZI")+" ZZI "+CHR(13)+CHR(10)	
	cQuery += "INNER JOIN "+RETSQLNAME("SF4")+" SF4 "+CHR(13)+CHR(10)
	cQuery += "ON (F4_FILIAL = '"+xFilial("SF4")+"' AND ZZI_TESPAD = F4_CODIGO AND F4_MSBLQL <> '1' AND SF4.D_E_L_E_T_ = '') "+CHR(13)+CHR(10)
	cQuery += "WHERE "+CHR(13)+CHR(10)
	cQuery += "ZZI.D_E_L_E_T_ = '' "+CHR(13)+CHR(10)
	cQuery += "AND ZZI_X_CFOP = '"+ALLTRIM(cCfop)+"' "+CHR(13)+CHR(10)
	cQuery += "AND ZZI_OPERAC = '"+ALLTRIM(cTpOper)+"' "+CHR(13)+CHR(10)

	If !EMPTY(cOrigPrd)
		If lcOrigPrd
			cQuery += "AND ZZI_ORIGEM = '"+cOrigPrd+"' "+CHR(13)+CHR(10)
		Else	
			AADD(aFiltro, "ZZI_ORIGEM = '"+cOrigPrd+"' ")
		EndIf
	EndIf

	If !EMPTY(cNcmPrd)
		If lcNcmPrd
			cQuery += "AND ZZI_NCMPRD = '"+cNcmPrd+"' "+CHR(13)+CHR(10)
		Else
			AADD(aFiltro, "ZZI_NCMPRD = '"+cNcmPrd+"' ")
		EndIf
	EndIf
					
	If !EMPTY(cTipoFor)
		If lcTipoFor
			cQuery += "AND ZZI_TPFORN = '"+cTipoFor+"' "+CHR(13)+CHR(10)
		Else
			AADD(aFiltro, "ZZI_TPFORN = '"+cTipoFor+"' ")
		EndIf
	EndIf
	
	If !EMPTY(cTipoCli)
		If lcTipoCli
			cQuery += "AND ZZI_TPCLIE = '"+cTipoCli+"' "+CHR(13)+CHR(10)
		Else		
			AADD(aFiltro, "ZZI_TPCLIE = '"+cTipoCli+"' ")
		EndIf
	EndIf

	If lIcms
		cQuery += "AND ZZI_TEMICM = 'S' "+CHR(13)+CHR(10)
	EndIf

	If lIpi
		cQuery += "AND ZZI_TEMIPI = 'S' "+CHR(13)+CHR(10)
	EndIf

	If lIcmsST
		cQuery += "AND ZZI_TEMSBT = 'S' "+CHR(13)+CHR(10)
	EndIf
	
	If lBRedIcm
		cQuery += "AND ZZI_REDICM = 'S' "+CHR(13)+CHR(10)
	EndIf

	If lBRedIST
		cQuery += "AND ZZI_REDIST = 'S' "+CHR(13)+CHR(10)
	EndIf
	
	MemoWrite("BUTESIMP.SQL", cQuery)

	If Select(cQueryTes) > 0
		(cQueryTes)->(DbCloseArea())
	EndIf
	
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQueryTes, .F., .T.)


	If lcOrigPrd .OR. lcNcmPrd .OR. lcTipoFor .OR. lcTipoCli
		If !EMPTY((cQueryTes)->TES)	
			cTesRet := (cQueryTes)->TES
	  	EndIf
	Else
			
		aFiltroTMP := ACLONE (aFiltro)
		
		While lFiltro
			cFiltro := ""

			//Filtra todos os itens do Filtro
			For nX := 1 to Len(aFiltroTMP)
				If !EMPTY(cFiltro)
					cFiltro += " .AND. "
				EndIf
				
				cFiltro += aFiltroTMP[nX]
			Next
				
			DbSetFilter( {|| &cFiltro}, cFiltro)
			(cQueryTes)->(DbGoTop())

			If !EMPTY((cQueryTes)->TES)	
				cTesRet := (cQueryTes)->TES
				lFiltro	:= .F.
			Else
				If Len(aFiltroTMP) > 1
					ADEL(aFiltroTMP, Len(aFiltroTMP))
					ASIZE(aFiltroTMP, Len(aFiltroTMP)-1)
				EndIf
  			EndIf
			
			If lFiltro
				//Filtra cada Item do Filtro
				For nX := 1 to Len(aFiltro)
					cFiltro := aFiltro[nX]
					DbSetFilter( {|| &cFiltro}, cFiltro)
					(cQueryTes)->(DbGoTop())
					
					If !EMPTY((cQueryTes)->TES)
						cTesRet := (cQueryTes)->TES
						lFiltro	:= .F.
					EndIf
				Next
	  		EndIf

			If lFiltro
				//Tras o TES sem os demais filtros.
				DbSetFilter({|| .T.}, ".T.")
				(cQueryTes)->(DbGoTop())
				
				If !EMPTY((cQueryTes)->TES)
					cTesRet := (cQueryTes)->TES
					lFiltro	:= .F.
				EndIf						
			EndIf
			
			//Retorna em branco caso não encontrar um TES válido.
			lFiltro	:= .F.			
		EndDo
	EndIf
	
EndIf

If Select(cQueryTes) > 0
	(cQueryTes)->(DbCloseArea())
EndIf
	
RestArea(aArea)

Return cTesRet