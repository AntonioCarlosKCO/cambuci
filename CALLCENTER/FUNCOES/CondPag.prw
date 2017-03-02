#include 'protheus.ch'
#include 'parmtype.ch'

User Function CondPag(nTotT, nValSol)
	Local nValFaixa	:= 0
	Local cQueryTmp := ""
	Local cTmpQuery	:= GetNextAlias()
	Local cCondPag	:= ""	

	nValFaixa := nTotT - nValSol

	cQueryTmp := "SELECT A1_COD, A1_LOJA, E4_CODIGO "																						+CHR(13)+CHR(10)
	cQueryTmp += "FROM "+RetSqlName("SA1")+" SA1 (NOLOCK) "																					+CHR(13)+CHR(10)
	cQueryTmp += "INNER JOIN "+RetSqlName("ZZF")+" ZZF (NOLOCK) "																			+CHR(13)+CHR(10)
	cQueryTmp += "ON (ZZF_FILIAL = '"+xFilial("ZZF")+"' AND ZZF_CODIGO = A1_XGRPCON AND ZZF.D_E_L_E_T_ = '') "						+CHR(13)+CHR(10)
	cQueryTmp += "INNER JOIN "+RetSqlName("ZZG")+" ZZG (NOLOCK) "																			+CHR(13)+CHR(10)
	cQueryTmp += "ON (ZZG_FILIAL = '"+xFilial("ZZG")+"' AND ZZG_CODGRP = ZZF_CODIGO AND ZZG.D_E_L_E_T_ = '') "						+CHR(13)+CHR(10)
	cQueryTmp += "INNER JOIN "+RetSqlName("SE4")+" SE4 (NOLOCK) "																			+CHR(13)+CHR(10)
	cQueryTmp += "ON (E4_FILIAL = '"+xFilial("SE4")+"' AND E4_CODIGO = ZZG_CODPAG AND E4_MSBLQL <> '1' AND SE4.D_E_L_E_T_ = '') "	+CHR(13)+CHR(10)
	cQueryTmp += "WHERE SA1.D_E_L_E_T_ = '' "																									+CHR(13)+CHR(10)
	cQueryTmp += "AND A1_FILIAL = '"+xFilial("SA1")+"' "																						+CHR(13)+CHR(10)
	cQueryTmp += "AND A1_COD = '"+ SA1->A1_COD +"' AND A1_LOJA = '" + SA1->A1_LOJA + "' "												+CHR(13)+CHR(10)

	If nTotT > 0
		cQueryTmp += "AND "+VALTOSQL(nValFaixa)+" >= E4_INFER "+CHR(13)+CHR(10)
		cQueryTmp += "AND "+VALTOSQL(nValFaixa)+" <= E4_SUPER "+CHR(13)+CHR(10)
	EndIf

	cQueryTmp += "ORDER BY E4_CODIGO "+CHR(13)+CHR(10)

	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQueryTmp), cTmpQuery, .T., .T.)

	If !(cTmpQuery)->(EOF())
		cCondPag 		:= (cTmpQuery)->E4_CODIGO
		lRet := .T. 
	EndIf

	If (Select(cTmpQuery) > 0)
		(cTmpQuery)->(DbCloseArea())
	EndIf
	
Return cCondPag