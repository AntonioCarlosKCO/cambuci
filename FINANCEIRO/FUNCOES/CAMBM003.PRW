#include "RWMAKE.CH"
#include "TOTVS.CH"
#Include "PROTHEUS.CH"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM003

Envio de Workflow da Fatura a Receber

@author  Allan Bonfim
@since   12/11/2014
@version P11
@param
@obs
@return

/*/
//-------------------------------------------------------------------

User Function CAMBM003(nRegSE1)

	Local _aArea		:= Getarea()
	Local _lRet			:= .T.
	Local _cQueryTmp	:= ""
	Local _nTotal		:= 0
	Local _cLocGWF		:= ALLTRIM(SUPERGETMV("ES_PSTWFFT",, "\workflow\Html\Faturas"))
	Local _cPara
	Local _cTmpQuery
	Local _cTmpTitulo
	Local _cTmpSalTit
	Local _cProcess
	Local _aAreaSE1
	Local aAreaTmp
	
	Private oHtml
	Private oProcess
	
	Default nRegSE1		:= 0 //420 - Teste
	
	If nRegSE1 > 0
	
		_aAreaSE1 := SE1->(GetArea())
			DbSelectArea("SE1")
			SE1->(DbgoTo(nRegSE1))
					
			oProcess := TWFProcess():New("CAMB03",OemToAnsi("Workflow de Faturas a Receber (SE1) - FINA280"))
			
			oProcess:NewTask("CAMB03","\workflow\CAMBM003.HTM")
//			oProcess:NewTask("099990","\workflow\CAMBM003.HTM")
			
			oHtml := oProcess:oHtml
		
			//CABECALHO
			oProcess:oHtml:ValByName("cNomeEmp"	, UPPER(ALLTRIM(SM0->M0_NOMECOM)))
			oProcess:oHtml:ValByName("cEndCam"	, UPPER(ALLTRIM(SM0->M0_ENDCOB))+" - "+UPPER(ALLTRIM(SM0->M0_CIDCOB))+" - "+UPPER(ALLTRIM(SM0->M0_ESTCOB))) 
			oProcess:oHtml:ValByName("cCnpjCam"	, ALLTRIM(TRANSFORM(SM0->M0_CGC, "@R 99.999.999/9999-99")))
			oProcess:oHtml:ValByName("cTitulo"	, "FATURA")
		
			//DADOS DO CLIENTE
			oProcess:oHtml:ValByName("cSacado"	, UPPER(ALLTRIM(GETADVFVAL("SA1", "A1_NOME", xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA, 1))))
			oProcess:oHtml:ValByName("cIE"		, UPPER(ALLTRIM(GETADVFVAL("SA1", "A1_INSCR", xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA, 1))))	
			oProcess:oHtml:ValByName("cCnpj"	, ALLTRIM(TRANSFORM(GETADVFVAL("SA1", "A1_CGC", xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA, 1), "@R 99.999.999/9999-99"))) 
			oProcess:oHtml:ValByName("cEnderec"	, UPPER(ALLTRIM(GETADVFVAL("SA1", "A1_END", xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA, 1)))+" - "+UPPER(ALLTRIM(GETADVFVAL("SA1", "A1_BAIRRO", xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA, 1))))
			oProcess:oHtml:ValByName("cCep"		, ALLTRIM(TRANSFORM(GETADVFVAL("SA1", "A1_CEP", xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA, 1),"@R 99999-999")))
			oProcess:oHtml:ValByName("cMunic"	, UPPER(ALLTRIM(GETADVFVAL("SA1", "A1_MUN", xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA, 1)))+" - "+UPPER(ALLTRIM(GETADVFVAL("SA1", "A1_ESTADO", xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA, 1))))
			
			//DADOS DA FATURA
			oProcess:oHtml:ValByName("cNumero"	, SE1->E1_NUM)
			oProcess:oHtml:ValByName("cDataEmi"	, DTOC(dDatabase))
			oProcess:oHtml:ValByName("cHoraEmi"	, SUBSTR(TIME(),1,5))
			oProcess:oHtml:ValByName("cHoraEmi"	, SUBSTR(TIME(),1,5))
			oProcess:oHtml:ValByName("cPara"	, _cPara)		                             	
	
			//TITULOS
			_cQueryTmp := "SELECT E1_CLIENTE, E1_LOJA, E1_NUM, E1_EMISSAO, E1_TIPO, E1_PARCELA, E1_VENCREA, E1_VALOR, E1_SALDO, E1_PREFIXO, R_E_C_N_O_ AS RECNO "+CHR(13)+CHR(10)
			_cQueryTmp += "FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+CHR(13)+CHR(10)
			_cQueryTmp += "WHERE SE1.D_E_L_E_T_ = '' "+CHR(13)+CHR(10)
			_cQueryTmp += "AND E1_FILIAL = '"+xFilial("SE1")+"' "+CHR(13)+CHR(10)
			_cQueryTmp += "AND E1_CLIENTE = '"+SE1->E1_CLIENTE+"' "+CHR(13)+CHR(10)
			_cQueryTmp += "AND E1_LOJA = '"+SE1->E1_LOJA+"' "+CHR(13)+CHR(10)
			_cQueryTmp += "AND E1_FATPREF = '"+SE1->E1_PREFIXO+"' "+CHR(13)+CHR(10)
			_cQueryTmp += "AND E1_FATURA = '"+SE1->E1_NUM+"' "+CHR(13)+CHR(10)
			_cQueryTmp += "AND E1_TIPOFAT = '"+SE1->E1_TIPO+"' "+CHR(13)+CHR(10)                
			_cQueryTmp += "ORDER BY E1_NUM, E1_TIPO, E1_PARCELA "+CHR(13)+CHR(10)
	
			_cTmpQuery	:= GetNextAlias()
			
			If (Select(_cTmpQuery) > 0)
				(_cTmpQuery)->(DbCloseArea())
			EndIf
			
			DbUseArea(.T., "TOPCONN", TcGenQry(,,_cQueryTmp), _cTmpQuery, .T., .T.)
			
			TCSetField(_cTmpQuery, "E1_EMISSAO", "D", 8, 0)
			TCSetField(_cTmpQuery, "E1_VENCREA", "D", 8, 0)
				
			While !(_cTmpQuery)->(EOF())
				AADD(oHtml:ValByName("a.EmiTit")	, DTOC((_cTmpQuery)->E1_EMISSAO))
				AADD(oHtml:ValByName("a.DocTit")	, (_cTmpQuery)->E1_NUM)
				AADD(oHtml:ValByName("a.ParTit")	, (_cTmpQuery)->E1_PARCELA)
				AADD(oHtml:ValByName("a.TipTit")	, (_cTmpQuery)->E1_TIPO)
				AADD(oHtml:ValByName("a.VenTit")	, DTOC((_cTmpQuery)->E1_VENCREA))
				AADD(oHtml:ValByName("a.ValTit")	, ALLTRIM(TRANSFORM((_cTmpQuery)->E1_VALOR, "@E 999,999,999.99")))
			   //	AADD(oHtml:ValByName("a.SalTit")		, ALLTRIM(TRANSFORM((_cTmpQuery)->E1_SALDO, "@E 999,999,999.99")))
	
				aAreaTmp := GetArea()
	
					//SALDOS
					_cQueryTmp := "SELECT TOP 1 E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_VALOR, R_E_C_N_O_ AS RECNO "+CHR(13)+CHR(10)
					_cQueryTmp += "FROM "+RetSqlName("SE5")+" SE5 (NOLOCK) "+CHR(13)+CHR(10)
					_cQueryTmp += "WHERE SE5.D_E_L_E_T_ = '' "+CHR(13)+CHR(10)
					_cQueryTmp += "AND E5_FILIAL = '"+xFilial("SE5")+"' "+CHR(13)+CHR(10)
					_cQueryTmp += "AND E5_CLIFOR = '"+(_cTmpQuery)->E1_CLIENTE+"' "+CHR(13)+CHR(10)
					_cQueryTmp += "AND E5_LOJA = '"+(_cTmpQuery)->E1_LOJA+"' "+CHR(13)+CHR(10)
					_cQueryTmp += "AND E5_PREFIXO = '"+(_cTmpQuery)->E1_PREFIXO+"' "+CHR(13)+CHR(10)
					_cQueryTmp += "AND E5_NUMERO = '"+(_cTmpQuery)->E1_NUM+"' "+CHR(13)+CHR(10)
					_cQueryTmp += "AND E5_TIPO = '"+(_cTmpQuery)->E1_TIPO+"' "+CHR(13)+CHR(10)
					_cQueryTmp += "AND E5_PARCELA = '"+(_cTmpQuery)->E1_PARCELA+"' "+CHR(13)+CHR(10)
					_cQueryTmp += "ORDER BY R_E_C_N_O_ DESC "+CHR(13)+CHR(10)
				
					_cTmpSalTit	:= GetNextAlias()
					
					If (Select(_cTmpSalTit) > 0)
						(_cTmpSalTit)->(DbCloseArea())
					EndIf
					
					DbUseArea(.T., "TOPCONN", TcGenQry(,,_cQueryTmp), _cTmpSalTit, .T., .T.)
	
					AADD(oHtml:ValByName("a.SalTit")		, ALLTRIM(TRANSFORM((_cTmpSalTit)->E5_VALOR, "@E 999,999,999.99")))
	
	    		RestArea(aAreaTmp)
	
				(_cTmpQuery)->(DbSkip())
			EndDo
			
			//DUPLICATAS
			_cQueryTmp := "SELECT E1_CLIENTE, E1_LOJA, E1_NUM, E1_EMISSAO, E1_PARCELA, E1_VENCREA, E1_VALOR, E1_SALDO, R_E_C_N_O_ AS RECNO "+CHR(13)+CHR(10)
			_cQueryTmp += "FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+CHR(13)+CHR(10)
			_cQueryTmp += "WHERE SE1.D_E_L_E_T_ = '' "+CHR(13)+CHR(10)
			_cQueryTmp += "AND E1_CLIENTE = '"+SE1->E1_CLIENTE+"' "+CHR(13)+CHR(10)
			_cQueryTmp += "AND E1_LOJA = '"+SE1->E1_LOJA+"' "+CHR(13)+CHR(10)
			_cQueryTmp += "AND E1_PREFIXO = '"+SE1->E1_PREFIXO+"' "+CHR(13)+CHR(10)
			_cQueryTmp += "AND E1_NUM = '"+SE1->E1_NUM+"' "+CHR(13)+CHR(10)
			_cQueryTmp += "AND E1_TIPO = '"+SE1->E1_TIPO+"' "+CHR(13)+CHR(10)                
			_cQueryTmp += "ORDER BY E1_NUM, E1_PARCELA "+CHR(13)+CHR(10)
	
			_cTmpTitulo	:= GetNextAlias()
			
			If (Select(_cTmpTitulo) > 0)
				(_cTmpTitulo)->(DbCloseArea())
			EndIf
			
			DbUseArea(.T., "TOPCONN", TcGenQry(,,_cQueryTmp), _cTmpTitulo, .T., .T.)
			
			TCSetField(_cTmpTitulo, "E1_EMISSAO", "D", 8, 0)
			TCSetField(_cTmpTitulo, "E1_VENCREA", "D", 8, 0)
				
			While !(_cTmpTitulo)->(EOF())
				AADD(oHtml:ValByName("b.EmiDup")	, DTOC((_cTmpTitulo)->E1_EMISSAO))
				AADD(oHtml:ValByName("b.DocDup")	, (_cTmpTitulo)->E1_NUM)
				AADD(oHtml:ValByName("b.ParDup")	, (_cTmpTitulo)->E1_PARCELA)
				AADD(oHtml:ValByName("b.VenDup")	, DTOC((_cTmpTitulo)->E1_VENCREA))
				AADD(oHtml:ValByName("b.DesDup")	, "DUPLICATA")
				AADD(oHtml:ValByName("b.ValDup")	, ALLTRIM(TRANSFORM((_cTmpTitulo)->E1_VALOR, "@E 999,999,999.99")))
				AADD(oHtml:ValByName("b.SalDup")	, ALLTRIM(TRANSFORM((_cTmpTitulo)->E1_SALDO, "@E 999,999,999.99")))
				_nTotal += (_cTmpTitulo)->E1_SALDO
	
				(_cTmpTitulo)->(DbSkip())
			EndDo
		
			oProcess:oHtml:ValByName("cTotal"		, ALLTRIM(TRANSFORM(_nTotal, "@E 999,999,999.99")))	
	     
		RestArea(_aAreaSE1)
		
		// DJALMA - 25/11/2016 - INÍCIO
		
		oProcess:cTo 	:= "CAMB03"
		
		oProcess:UserSiga := "000000"
		_cProcess := oProcess:Start(_cLocGWF)

		_cPara := CAMBM003M(SE1->E1_CLIENTE, SE1->E1_LOJA)
		oProcess:cTo 	:= _cPara
		oProcess:cCC 	:= LOWER(ALLTRIM(SUPERGETMV("ES_MAILWFF",,"djalma@globalgcs.com.br")))
		
		// DJALMA - 25/11/2016 - FIM 
		
		oProcess:cSubject := UPPER(ALLTRIM(SM0->M0_NOMECOM))+" - FATURA Nº "+ALLTRIM(SE1->E1_NUM)
		oProcess:cFromAddr	:= ALLTRIM(GETMV("MV_RELACNT"))
		oProcess:cFromName	:= ALLTRIM(GETMV("MV_RELFROM"))
		
		oProcess:Start()
		
		If !EMPTY(_cProcess)
			(_cTmpTitulo)->(DbGoTop())
			While !(_cTmpTitulo)->(EOF())
		        SE1->(DbGoTo((_cTmpTitulo)->RECNO))	
				Reclock("SE1", .F.)
					SE1->E1_PROCWFF := ALLTRIM(_cProcess)
					SE1->E1_MAILWFF := ALLTRIM(_cPara)
				SE1->(MsUnlock())
	
				(_cTmpTitulo)->(DbSkip())
			EndDo
		EndIf 
	      
		If (Select(_cTmpQuery) > 0)
			(_cTmpQuery)->(DbCloseArea())
		EndIf                
		
		If (Select(_cTmpTitulo) > 0)
			(_cTmpTitulo)->(DbCloseArea())
		EndIf	
			
	EndIf
	
	RestArea(_aArea)

Return _lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CAMBM003M

Busca o e-mail do destinatário

@author  Allan Bonfim
@since   12/11/2014
@version P11
@param
@obs
@return

/*/
//-------------------------------------------------------------------

STATIC FUNCTION CAMBM003M (_cCodCli, _cLojCli)

	Local _aArea 		:= GetArea()
	Local _cRet 		:= LOWER(ALLTRIM(SUPERGETMV("ES_MAILWFF",,"raphael.araujo@globalgcs.com.br")))
	Local _cQueryTmp	:= ""
	Local _cTmpQuery	:= GetNextAlias()
	Local _cContFat		:= ALLTRIM(SUPERGETMV("ES_TPCONFT",,"000000003")) //000000003
	Local _cContAdm		:= ALLTRIM(SUPERGETMV("ES_TPCONAD",,"000000004")) //000000004
	Local _cCodCont		:= ""
	Local cContato := If(Empty(_cContFat), _cContAdm, _cContFat)
	
	Default _cCodCli	:= ""
	Default _cLojCli	:= ""
	
	If !EMPTY(_cCodCli) .AND. !EMPTY(_cLojCli)
	
		_cQueryTmp := "SELECT AC8_CODENT, U5_EMAIL, U5_DEPTO "+CHR(13)+CHR(10)
		_cQueryTmp += "FROM "+RetSqlName("SU5")+" SU5 (NOLOCK) "+CHR(13)+CHR(10)
		_cQueryTmp += "INNER JOIN "+RetSqlName("AC8")+" AC8 (NOLOCK) "+CHR(13)+CHR(10)
		_cQueryTmp += "ON (U5_CODCONT = AC8_CODCON AND AC8.D_E_L_E_T_ = '') "+CHR(13)+CHR(10)
		_cQueryTmp += "WHERE SU5.D_E_L_E_T_ = '' "+CHR(13)+CHR(10)
		_cQueryTmp += "AND AC8_CODENT = '"+(_cCodCli+_cLojCli)+"' "+CHR(13)+CHR(10)
		_cQueryTmp += "AND AC8_ENTIDA = 'SA1' "+CHR(13)+CHR(10)
		_cQueryTmp += "AND (U5_DEPTO = '"+_cContFat+"' OR U5_DEPTO = '"+cContato+"') "+CHR(13)+CHR(10)	// Raphael F. Araújo 05/12/2016	
		_cQueryTmp += "ORDER BY U5_DEPTO "+CHR(13)+CHR(10)
		
		If (Select(_cTmpQuery) > 0)
			(_cTmpQuery)->(DbCloseArea())
		EndIf
		
		DbUseArea(.T., "TOPCONN", TcGenQry(,,_cQueryTmp), _cTmpQuery, .T., .T.)
			
		While !(_cTmpQuery)->(EOF())
		   	
		   	If EMPTY(_cCodCont)
		   		_cCodCont := (_cTmpQuery)->U5_DEPTO
		   	EndIf
			
			If _cCodCont == (_cTmpQuery)->U5_DEPTO
				If !EMPTY(_cRet)
					_cRet += ";"
				EndIf
	
				_cRet += (_cTmpQuery)->U5_EMAIL
			EndIf
			
			(_cTmpQuery)->(dbSkip()) // DJALMA BORGES 23/12/2016
				
		EndDo
	
		(_cTmpQuery)->(DbCloseArea()) // DJALMA BORGES 17/02/2017
				
	EndIf
	
	_cRet := LOWER(ALLTRIM(_cRet))
		
	RestArea(_aArea)

Return _cRet