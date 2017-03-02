#include "PROTHEUS.CH"

//________________________
//CADASTRO DE PROJETOS
//POR : LUIS HENRIQUE -
//EM  : 02/02/2015
//________________________

User Function CAMBC003()  
	
	Local _aFixe := {}
	Local _cAlias := GetNextAlias()
	Local _aStruct := {}
	Private _lTOK := .f.
	
	cCadastro := "MANUTENÇÃO DE COMISSÕES PARA PEDIDOS FATURADOS"

//	aRotina := {{ "Visualizar"   ,'AxPesqui()'	, 0, 2},;
//	{ "Alterar"      ,'U_CMBC03' 	, 0, 4}}
	
	aRotina := {{ "Visualizar"   ,'AxVisual'	, 0, 2},; // DJALMA BORGES 28/12/2016
				{ "Alterar"      ,'U_CMBC03' 	, 0, 4}}
	           
	BeginSql Alias _cAlias           
	      
		%noparser%        
	
		SELECT *
		FROM ( 
			SELECT *, R_E_C_N_O_ SC5_REC 
			FROM %Table:SC5% (NOLOCK)
			WHERE %NotDel%
			) SC5
			
			INNER JOIN (
				SELECT DISTINCT C9_FILIAL, C9_PEDIDO, C9_BLCRED, C9_BLEST 
				FROM %Table:SC9% (NOLOCK)
				WHERE  %NotDel%
					AND C9_BLCRED = '10'
					AND C9_BLEST = '10'
					) SC9
					
					ON C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO
				
			ORDER BY C5_FILIAL, C5_NUM
			
	EndSql		
				
	dbSelectArea("SX3")
	dbSetorder(1)
	dbSeek("SC5")
	
	While ! SX3->(eof()) .AND. X3_ARQUIVO = "SC5" 
		IF ALLTRIM(X3_CAMPO) $ "C5_FILIAL,C5_NUM,C5_TIPO,C5_CLIENTE,C5_LOJACLI,C5_TRANSP,C5_CONDPAG"   
	   		AADD(_aFixe, { X3_DESCRIC, X3_CAMPO, X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE  } )
			Aadd(_aStruct,{X3_CAMPO ,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	    ENDIF
		SX3->(dbSkip())
	End	
	
	Aadd(_aStruct, {"C5_RECNO", "N", 14, 0})
	
	//CRIA ARQUIVO DE TRABALHO
		
		cCriaTrab := CriaTrab(_aStruct,.T.)
		cIndTrab  := CriaTrab("",.f.)
		
		// Abre Arquivo Temporario
		DbUseArea(.T.,,cCriaTrab,"TRB",.T.,.F.)
		IndRegua("TRB",cIndTrab,"C5_FILIAL+C5_NUM",,"")
		
	dbSelectArea(_cAlias)
	(_cAlias)->(dbGotop())                  
	While ! (_calias)->(eof())
	                        
		Reclock("TRB",.T.)
		TRB->C5_FILIAL 	:= (_calias)->C5_FILIAL	                 
		TRB->C5_NUM 	:= (_calias)->C5_NUM
		TRB->C5_CLIENTE := (_calias)->C5_CLIENTE                
		TRB->C5_LOJACLI := (_calias)->C5_LOJACLI                 
		TRB->C5_TRANSP 	:= (_calias)->C5_TRANSP	                 
		TRB->C5_CONDPAG := (_calias)->C5_CONDPAG	                 
		TRB->C5_RECNO 	:= (_calias)->SC5_REC	                 
	
	    TRB->(MsUnlock())
	
		(_calias)->(dbSkip())   	
	End
	
	dbSelectArea("TRB")
	mBrowse( 6, 1,22,75,"TRB",_aFixe)  
	
	TRB->(dbCloseArea())

Return

User Function CMBC03(cAlias, nReg, nOpc)
	
	Local _nSC5_REC := 0      
	Local _aCampos := {}
	Local _cTudoOk := "U_CMB03TOK()"
	
	Private aHeader := {}
	Private aCols := {}
	Private N := 1
	
	Private _aComisFat := {} // DJALMA BORGES 29/12/2016
	Private _aVendFat := {}  // DJALMA BORGES 29/12/2016
	Private nPercDesc := 0       
	
	//POSICIONA SC5 CONFORME BROWSE TRB
	TRB->(dbGoto(nReg))
	
	_nSC5_REC := TRB->C5_RECNO
	dbSelectArea("SC5")
	SC5->(dbGoTo(_nSC5_REC))
	
	// DJALMA BORGES 29/12/2016 - INÍCIO
	Aadd(_aVendFat, SC5->C5_VEND1) // [1]
	Aadd(_aVendFat, SC5->C5_VEND2) // [2]
	// DJALMA BORGES 29/12/2016 - FIM
	
	//CARREGA AHEADER E ACOLS DE SC6 PARA VALIDAÇÃO DE C5_CONDPAG
	
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("SC6")
	While ! SC6->(eof()) .and. X3_ARQUIVO = "SC6"
	
		If X3USO(X3_USADO) .And. (cNivel >= X3_NIVEL)
		
			AADD(aHeader,{ TRIM(x3_titulo),;
			x3_campo,;
			x3_picture,;
			x3_tamanho,;
			x3_decimal,;
			x3_valid ,;
			/*RESERVADO*/,;
			x3_tipo,;
			/*RESERVADO*/,;
			x3_context /*RESERVADO*/ } )
	    
	    Endif
	         
		SX3->(dbSkip())
	
	End
	
	//PREENCHE VETOR ACOLS
	dbSelectArea("SC6")
	dbSetOrder(1)
	SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM) )
	
	While ! SC6->(EOF()) .and. xFilial("SC6")+SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM
		
		aadd(aCols, Array(len(aHeader)+1) )
		
		For _nx := 1 to len(aHeader)
			aCols[ len(aCols) ][_nx] := FieldGet( FieldPos( aHeader[_nx,2] ) )
		Next
		
		aCols[len(aCols)][ len(aHeader)+1 ] := .f.
	
		SC6->(dbSkip())
	End
	
	//__________________________________
	
	Aadd(_aCampos,"C5_VEND1")
	Aadd(_aCampos,"C5_VEND2")

	Aadd(_aCampos,"NOUSER")
	
	AxAltera("SC5", _nSC5_REC, nOpc, _aCampos, _aCampos ,,,_cTudoOk)
	
	If _lTok
	
		U_MTA410T()
		
		U_ATUCOMIS(TRB->C5_FILIAL, TRB->C5_NUM) // DJALMA BORGES 29/12/2016
	
	EndIf

Return
                  
//__________________________
User Function CMB03TOK()
	
	Local lRetorna := .t.             
	Local _nPC6_VALOR := ascan( aHeader , {|x|  alltrim(x[2]) == "C6_VALOR"  } )                           
	Local nTotPed := 0               
	Local _aArea := GetArea()
	
	_lTOk := .t.
	                     
	RestArea(_aArea)
	
Return(lRetorna)

// FUNÇÃO PARA ATUALIZAR O VALOR DA COMISSÃO NA SC5, SF2, SE1 E SE3
// DJALMA BORGES 29/12/2016
USER FUNCTION ATUCOMIS(cFilSC5, cNumSC5)

	Local cQuery := ""
	Local cAliasQry	:= GetNextAlias()
	
	SC5->(dbSetOrder(1))
	SC5->(dbSeek(cFilSC5 + cNumSC5))
	RECLOCK("SC5", .F.)
		SC5->C5_VEND1  := _aComisFat[1]
		SC5->C5_COMIS1 := _aComisFat[2]
		SC5->C5_VEND2  := _aComisFat[3]
		SC5->C5_COMIS2 := _aComisFat[4]
	SC5->(MSUNLOCK())
	
	SF2->(dbSetOrder(1))
	SF2->(dbSeek(cFilSC5 + SC5->C5_NOTA + SC5->C5_SERIE + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
	RECLOCK("SF2", .F.)
		SF2->F2_VEND1 := _aComisFat[1]
		SF2->F2_VEND2 := _aComisFat[3]
	SF2->(MSUNLOCK())
	
	cQuery += "SELECT E3_FILIAL, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_SEQ, E3_VEND "
	cQuery += "FROM " + RetSqlName("SE3") + " SE3 "
	cQuery += "WHERE SE3.D_E_L_E_T_ = '' " 
	cQuery += "AND E3_FILIAL = '" + cFilSC5 +"' AND E3_PEDIDO = '" + cNumSC5 +"' " 
	
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .T.)
	
	(cAliasQry)->(dbGoTop())
	While (cAliasQry)->(!EOF())
	
		SE1->(dbSetOrder(1))
		SE1->(dbSeek((cAliasQry)->(E3_FILIAL + E3_PREFIXO + E3_NUM + E3_PARCELA)))
		RECLOCK("SE1", .F.)
			SE1->E1_VEND1  := aComisFat[1]
			SE1->E1_COMIS1 := aComisFat[2]
			SE1->E1_VEND2  := aComisFat[3]
			SE1->E1_COMIS2 := aComisFat[4]
		SE1->(MSUNLOCK())
		
		SE3->(dbSetOrder(1))
		SE3->(dbSeek((cAliasQry)->(E3_FILIAL + E3_PREFIXO + E3_NUM + E3_PARCELA + E3_SEQ + E3_VEND)))
		RECLOCK("SE3", .F.)
			If SE3->E3_VEND == _aVendFat[1]
				SE3->E3_VEND := _aComisFat[1]
				SE3->E3_PORC := _aComisFat[2]
				SE3->E3_COMIS := SE3->E3_BASE * _aComisFat[2] / 100
			ElseIf SE3->E3_VEND == _aVendFat[2]
				SE3->E3_VEND := _aComisFat[3]
				SE3->E3_PORC := _aComisFat[4]
				SE3->E3_COMIS := SE3->E3_BASE * _aComisFat[4] / 100
			EndIf
		SE3->(MSUNLOCK())
		
		(cAliasQry)->(dbSkip())
	EndDo
	
	(cAliasQry)->(dbCloseArea())

RETURN