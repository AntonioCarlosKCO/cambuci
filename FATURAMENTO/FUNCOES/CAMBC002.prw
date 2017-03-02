#include "PROTHEUS.CH"

//________________________
//CADASTRO DE PROJETOS
//POR : LUIS HENRIQUE -
//EM  : 02/02/2015
//________________________


/*/{Protheus.doc} CAMBC002
// CRIAR GATILHO C5_DESC1 -> C5_XTOTPV1 
@author totvsremote
@since 26/01/2016
@version undefined

@type function
/*/
User Function CAMBC002()
	Local _aFixe 		:= {}
	Local _aStruct 		:= {}
	Local _aTipoPv		:= {{'PEG','TELEV'},{'PTM','TLV MARINGA'},{'PEX','PV EXTERNO'},{'PFV','FORCA VENDA'}}
	Private _cAlias 	:= GetNextAlias()
	Private _aCampos 	:= {}

	Public _lPrint := .f.

	Aadd(_aCampos,"C5_NUM")
	Aadd(_aCampos,"C5_XTIPOPV")
	Aadd(_aCampos,"C5_TRANSP")
	Aadd(_aCampos,"C5_XTOTPV1")
	Aadd(_aCampos,"C5_XTOTPV2") // DJALMA BORGES 28/11/2016
	Aadd(_aCampos,"C5_CONDPAG")
	Aadd(_aCampos,"C5_PARC1")
	Aadd(_aCampos,"C5_DATA1")
	Aadd(_aCampos,"C5_PARC2")
	Aadd(_aCampos,"C5_DATA2")
	Aadd(_aCampos,"C5_PARC3")
	Aadd(_aCampos,"C5_DATA3")
	Aadd(_aCampos,"C5_PARC4")
	Aadd(_aCampos,"C5_DATA4")
	Aadd(_aCampos,"C5_PARC5")
	Aadd(_aCampos,"C5_DATA5")
	Aadd(_aCampos,"C5_PARC6")
	Aadd(_aCampos,"C5_DATA6")
	Aadd(_aCampos,"C5_PARC7")
	Aadd(_aCampos,"C5_DATA7")
	Aadd(_aCampos,"C5_PARC8")
	Aadd(_aCampos,"C5_DATA8")
	Aadd(_aCampos,"C5_PARC9")
	Aadd(_aCampos,"C5_DATA9")
	Aadd(_aCampos,"C5_PARCA")
	Aadd(_aCampos,"C5_DATAA")
	Aadd(_aCampos,"C5_PARCB")
	Aadd(_aCampos,"C5_DATAB")
	Aadd(_aCampos,"C5_PARCC")
	Aadd(_aCampos,"C5_DATAC")
	Aadd(_aCampos,"C5_PARCD")
	Aadd(_aCampos,"C5_DATAD")
	Aadd(_aCampos,"C5_PARCE")
	Aadd(_aCampos,"C5_DATAE")
	Aadd(_aCampos,"C5_PARCF")
	Aadd(_aCampos,"C5_DATAF")
	Aadd(_aCampos,"C5_PARCG")
	Aadd(_aCampos,"C5_DATAG")
	Aadd(_aCampos,"C5_PARCH")
	Aadd(_aCampos,"C5_DATAH")
	Aadd(_aCampos,"C5_PARCI")
	Aadd(_aCampos,"C5_DATAI")
	Aadd(_aCampos,"C5_PARCJ")
	Aadd(_aCampos,"C5_DATAJ")
	Aadd(_aCampos,"C5_PARCK")
	Aadd(_aCampos,"C5_DATAK")
	Aadd(_aCampos,"C5_PARCL")
	Aadd(_aCampos,"C5_DATAL")
	Aadd(_aCampos,"C5_PARCM")
	Aadd(_aCampos,"C5_DATAM")
	Aadd(_aCampos,"C5_PARCN")
	Aadd(_aCampos,"C5_DATAN")
	Aadd(_aCampos,"C5_PARCO")
	Aadd(_aCampos,"C5_DATAO")
	Aadd(_aCampos,"C5_PARCP")
	Aadd(_aCampos,"C5_DATAP")
	Aadd(_aCampos,"C5_PARCQ")
	Aadd(_aCampos,"C5_DATAQ")
	Aadd(_aCampos,"C5_DESC1")
	Aadd(_aCampos,"C5_DESC2") // DJALMA BORGES 20/02/2017
	Aadd(_aCampos,"C5_TPFRETE")
	Aadd(_aCampos,"C5_FRETE")
	Aadd(_aCampos,"C5_SEGURO")
	Aadd(_aCampos,"C5_MENNOTA") // DJALMA BORGES 28/11/2016
	Aadd(_aCampos,"C5_PESOL")
	Aadd(_aCampos,"C5_PBRUTO")
	Aadd(_aCampos,"C5_REDESP")
	Aadd(_aCampos,"C5_VOLUME1")
	Aadd(_aCampos,"C5_VOLUME2")
	Aadd(_aCampos,"C5_VOLUME3")
	Aadd(_aCampos,"C5_VOLUME4")
	Aadd(_aCampos,"C5_VOLUME5")
	Aadd(_aCampos,"C5_VOLUME6")
	Aadd(_aCampos,"C5_ESPECI1")
	Aadd(_aCampos,"C5_ESPECI2")
	Aadd(_aCampos,"C5_ESPECI3")
	Aadd(_aCampos,"C5_ESPECI4")
	Aadd(_aCampos,"C5_ESPECI5")
	Aadd(_aCampos,"C5_ESPECI6")
	Aadd(_aCampos,"NOUSER")

	cCadastro := "MANUTENÇÃO DE PEDIDOS LIBERADOS"

	aRotina := {	{ "Alterar"      	,'U_CMBC02' 		, 0, 4},;
					{ "Visualizar"		,'U_VISUALX'		, 0 ,2},;
					{ "Imp. Romaneio"	,'U_CAMBR01("TRB")'	, 0, 6},;
					{ "Imp. Etiq Exp"	,'U_CAMBR02("TRB")'	, 0, 7} }

	BeginSql Alias _cAlias

	column C5_PARC1 as numeric(14,2)
	column C5_DATA1 as date
	column C5_PARC2 as numeric(14,2)
	column C5_DATA2 as date
	column C5_PARC3 as numeric(14,2)
	column C5_DATA3 as date
	column C5_PARC4 as numeric(14,2)
	column C5_DATA4 as date
	column C5_PARC5 as numeric(14,2)
	column C5_DATA5 as date
	column C5_PARC6 as numeric(14,2)
	column C5_DATA6 as date
	column C5_PARC7 as numeric(14,2)
	column C5_DATA7 as date
	column C5_PARC8 as numeric(14,2)
	column C5_DATA8 as date
	column C5_PARC9 as numeric(14,2)
	column C5_DATA9 as date
	column C5_PARCA as numeric(14,2)
	column C5_DATAA as date
	column C5_PARCB as numeric(14,2)
	column C5_DATAB as date
	column C5_PARCC as numeric(14,2)
	column C5_DATAC as date
	column C5_PARCD as numeric(14,2)
	column C5_DATAD as date
	column C5_PARCE as numeric(14,2)
	column C5_DATAE as date
	column C5_PARCF as numeric(14,2)
	column C5_DATAF as date
	column C5_PARCG as numeric(14,2)
	column C5_DATAG as date
	column C5_PARCH as numeric(14,2)
	column C5_DATAH as date
	column C5_PARCI as numeric(14,2)
	column C5_DATAI as date
	column C5_PARCJ as numeric(14,2)
	column C5_DATAJ as date
	column C5_PARCK as numeric(14,2)
	column C5_DATAK as date
	column C5_PARCL as numeric(14,2)
	column C5_DATAL as date
	column C5_PARCM as numeric(14,2)
	column C5_DATAM as date
	column C5_PARCN as numeric(14,2)
	column C5_DATAN as date
	column C5_PARCO as numeric(14,2)
	column C5_DATAO as date
	column C5_PARCP as numeric(14,2)
	column C5_DATAP as date
	column C5_PARCQ as numeric(14,2)
	column C5_DATAQ as date

	column C9_VENDA as numeric(14,2)

	%noparser%

	SELECT PESOLIQ, PESOBRU, VENDA, *
	FROM ( 
	SELECT *, R_E_C_N_O_ SC5_REC/* DJALMA BORGES 17/02/2017 - INÍCIO*/,
			(
			SELECT COUNT(SC6COUNT.R_E_C_N_O_)
			FROM SC6010 SC6COUNT
				LEFT JOIN SC9010 SC9COUNT ON SC9COUNT.D_E_L_E_T_ = ''
					AND SC9COUNT.C9_FILIAL + SC9COUNT.C9_PEDIDO + SC9COUNT.C9_ITEM + SC9COUNT.C9_PRODUTO 
				      = SC6COUNT.C6_FILIAL + SC6COUNT.C6_NUM    + SC6COUNT.C6_ITEM + SC6COUNT.C6_PRODUTO
			WHERE SC6COUNT.D_E_L_E_T_ = ''
				AND SC6COUNT.C6_FILIAL = SC5010.C5_FILIAL AND SC6COUNT.C6_NUM = SC5010.C5_NUM
				AND (SC9COUNT.C9_BLEST <> '' OR SC9COUNT.C9_BLCRED <> '')
			) BLOQUEADOS /* DJALMA BORGES 17/02/2017 - FIM */
	FROM %Table:SC5% (NOLOCK)
	WHERE %NotDel% AND C5_FILIAL = %xfilial:SC5%
	) SC5

	INNER JOIN (
	SELECT SUM(PESOLIQ) PESOLIQ, SUM(PESOBRU) PESOBRU, SUM(VALITEM) AS VENDA, C9_FILIAL, C9_PEDIDO, C9_SEQUEN 
	FROM (
	SELECT (C9_QTDLIB * C9_PRCVEN) AS VALITEM, C9_FILIAL, C9_PEDIDO, C9_PRODUTO, C9_SEQUEN
	FROM %Table:SC9% (Nolock)
	WHERE  %NotDel%
	AND C9_BLCRED = ''
	AND C9_BLEST = ''
	AND C9_FILIAL = %xfilial:SC9%

	)SC9_0

	INNER JOIN (
	SELECT SUM(B1_PESO) AS PESOLIQ, SUM(B1_PESBRU) AS PESOBRU, B1_COD
	FROM %Table:SB1%
	WHERE %NotDel% AND B1_FILIAL = %xfilial:SB1%
	GROUP BY B1_COD

	)SB1		

	ON C9_PRODUTO = B1_COD

		GROUP BY C9_FILIAL, C9_PEDIDO, C9_SEQUEN
		) SC9

	ON C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO

	WHERE BLOQUEADOS = 0 // DJALMA BORGES 17/02/2017
	
	ORDER BY C5_FILIAL, C5_NUM		
	EndSql		

	dbSelectArea("SX3")
	dbSetorder(1)
	dbSeek("SC5")

	While ! SX3->(eof()) .AND. X3_ARQUIVO = "SC5" 

		IF ascan( _aCampos, ALLTRIM(X3_CAMPO) ) > 0 .or. alltrim(X3_CAMPO) $ 'C5_FILIAL,C5_NUM,C5_CLIENTE,C5_LOJACLI'

			AADD(_aFixe, { X3_DESCRIC, X3_CAMPO, X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE  } )
			if alltrim(X3_CAMPO) == 'C5_XTIPOPV'
				Aadd(_aStruct,{X3_CAMPO ,X3_TIPO,15,X3_DECIMAL})
			Else	
				Aadd(_aStruct,{X3_CAMPO ,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
			Endif		
		ENDIF
		SX3->(dbSkip())
	End	

	Aadd(_aStruct,{"C5_RECNO" ,"N",14,0})

	//CRIA ARQUIVO DE TRABALHO

	cCriaTrab := CriaTrab(_aStruct,.T.)
	cIndTrab  := CriaTrab("",.f.)

	// Abre Arquivo Temporario
	DbUseArea(.T.,,cCriaTrab,"TRB",.T.,.F.)
	IndRegua("TRB",cIndTrab,"C5_FILIAL+C5_NUM",,"")

	dbSelectArea(_calias)
	(_calias)->(dbGotop())                  
	While ! (_calias)->(eof())

	/*/__________________________________
	//GRAVA O VALOR TOTAL DAS MERCADORIAS LIBERADAS
	/*
	SC5->(dbGoTo(_nSC5_REC))
	Reclock('SC5',.T.)
	SC5->C5_XTOTPV1 := (_cAlias)->VENDA
	SC5->(MsUnlock())
	//____________________________________________*/
	
	Reclock("TRB",.T.)
		
		TRB->C5_FILIAL 	:= (_calias)->C5_FILIAL	                 
		TRB->C5_NUM 	:= (_calias)->C5_NUM

		nPos := ascan(_aTipoPv, {|x| x[1] == alltrim((_cAlias)->C5_XTIPOPV)  })    
		
		if nPos > 0
			TRB->C5_XTIPOPV	:= _aTipoPv[nPos][2]
		Endif	

		TRB->C5_CLIENTE := (_calias)->C5_CLIENTE                
		TRB->C5_LOJACLI := (_calias)->C5_LOJACLI                 
		TRB->C5_TRANSP 	:= (_calias)->C5_TRANSP	                 
		TRB->C5_CONDPAG := (_calias)->C5_CONDPAG	                 
		TRB->C5_MENNOTA := (_calias)->C5_MENNOTA // DJALMA 28/11/2016

		TRB->C5_PARC1 := (_cAlias)->C5_PARC1
		TRB->C5_DATA1 := (_cAlias)->C5_DATA1
		TRB->C5_PARC2 := (_cAlias)->C5_PARC2
		TRB->C5_DATA2 := (_cAlias)->C5_DATA2
		TRB->C5_PARC3 := (_cAlias)->C5_PARC3
		TRB->C5_DATA3 := (_cAlias)->C5_DATA3
		TRB->C5_PARC4 := (_cAlias)->C5_PARC4
		TRB->C5_DATA4 := (_cAlias)->C5_DATA4
		TRB->C5_PARC5 := (_cAlias)->C5_PARC5
		TRB->C5_DATA5 := (_cAlias)->C5_DATA5
		TRB->C5_PARC6 := (_cAlias)->C5_PARC6
		TRB->C5_DATA6 := (_cAlias)->C5_DATA6
		TRB->C5_PARC7 := (_cAlias)->C5_PARC7
		TRB->C5_DATA7 := (_cAlias)->C5_DATA7
		TRB->C5_PARC8 := (_cAlias)->C5_PARC8
		TRB->C5_DATA8 := (_cAlias)->C5_DATA8
		TRB->C5_PARC9 := (_cAlias)->C5_PARC9
		TRB->C5_DATA9 := (_cAlias)->C5_DATA9
		TRB->C5_PARCA := (_cAlias)->C5_PARCA
		TRB->C5_DATAA := (_cAlias)->C5_DATAA
		// Alterado por Carlos Eduardo Saturnino em 26/09/2016
		TRB->C5_PARCB := (_cAlias)->C5_PARCB
		TRB->C5_DATAB := (_cAlias)->C5_DATAB
		TRB->C5_PARCC := (_cAlias)->C5_PARCC
		TRB->C5_DATAC := (_cAlias)->C5_DATAC
		TRB->C5_PARCD := (_cAlias)->C5_PARCD
		TRB->C5_DATAD := (_cAlias)->C5_DATAD
		TRB->C5_PARCE := (_cAlias)->C5_PARCE
		TRB->C5_DATAE := (_cAlias)->C5_DATAE
		TRB->C5_PARCF := (_cAlias)->C5_PARCF
		TRB->C5_DATAF := (_cAlias)->C5_DATAF
		TRB->C5_PARCG := (_cAlias)->C5_PARCG
		TRB->C5_DATAG := (_cAlias)->C5_DATAG
		TRB->C5_PARCH := (_cAlias)->C5_PARCH
		TRB->C5_DATAH := (_cAlias)->C5_DATAH
		TRB->C5_PARCI := (_cAlias)->C5_PARCI
		TRB->C5_DATAI := (_cAlias)->C5_DATAI
		TRB->C5_PARCJ := (_cAlias)->C5_PARCJ
		TRB->C5_DATAJ := (_cAlias)->C5_DATAJ
		TRB->C5_PARCK := (_cAlias)->C5_PARCK
		TRB->C5_DATAK := (_cAlias)->C5_DATAK
		TRB->C5_PARCL := (_cAlias)->C5_PARCL
		TRB->C5_DATAL := (_cAlias)->C5_DATAL
		TRB->C5_PARCM := (_cAlias)->C5_PARCM
		TRB->C5_DATAM := (_cAlias)->C5_DATAM
		TRB->C5_PARCN := (_cAlias)->C5_PARCN
		TRB->C5_DATAN := (_cAlias)->C5_DATAN
		TRB->C5_PARCO := (_cAlias)->C5_PARCO
		TRB->C5_DATAO := (_cAlias)->C5_DATAO
		TRB->C5_PARCP := (_cAlias)->C5_PARCP
		TRB->C5_DATAP := (_cAlias)->C5_DATAP
		TRB->C5_PARCQ := (_cAlias)->C5_PARCQ
		TRB->C5_DATAQ := (_cAlias)->C5_DATAQ
		// <----------- Término da alteração
		TRB->C5_RECNO 	:= (_calias)->SC5_REC	
		TRB->C5_PBRUTO	:= (_calias)->C5_PBRUTO
		TRB->C5_PESOL	:= (_calias)->PESOLIQ 
		TRB->C5_DESC1	:= (_cAlias)->C5_DESC1  // Raphael Araújo 11/10/2016              
		TRB->C5_DESC2	:= (_cAlias)->C5_DESC2 // DJALMA BORGES 20/02/2017                

		TRB->C5_VOLUME1 := (_cAlias)->C5_VOLUME1
		TRB->C5_VOLUME2 := (_cAlias)->C5_VOLUME2
		TRB->C5_VOLUME3 := (_cAlias)->C5_VOLUME3
		TRB->C5_VOLUME4 := (_cAlias)->C5_VOLUME4
		TRB->C5_VOLUME5 := (_cAlias)->C5_VOLUME5
		TRB->C5_VOLUME6 := (_cAlias)->C5_VOLUME6

		TRB->C5_ESPECI1 := (_cAlias)->C5_ESPECI1
		TRB->C5_ESPECI2 := (_cAlias)->C5_ESPECI2
		TRB->C5_ESPECI3 := (_cAlias)->C5_ESPECI3
		TRB->C5_ESPECI4 := (_cAlias)->C5_ESPECI4
		TRB->C5_ESPECI5 := (_cAlias)->C5_ESPECI5
		TRB->C5_ESPECI6 := (_cAlias)->C5_ESPECI6

//		TRB->C5_XTOTPV1	:= (_cAlias)->VENDA

		TRB->C5_RECNO	:= (_cAlias)->SC5_REC

	TRB->(MsUnlock())

	(_calias)->(dbSkip())   	
	End

	dbSelectArea("TRB")
	mBrowse( 6, 1,22,75,"TRB",_aFixe,,,,,,,,,,.F.)  

	TRB->(dbCloseArea())

Return

/*/{Protheus.doc} CMBC02
//TODO Descrição auto-gerada.
@author totvsremote
@since 18/01/2016
@version undefined
@param cAlias, characters, descricao
@param nReg, numeric, descricao
@param nOpc, numeric, descricao
@type function
/*/
User Function CMBC02(cAlias, nReg, nOpc)

	Local _nSC5_REC := 0      
	Local _cTudoOk 	:= "U_CMB02TOK()"
	
	Private aHeader := {}
	Private aCols 	:= {}
	Private N 		:= 1       
	
	//POSICIONA SC5 CONFORME BROWSE TRB
	TRB->(dbGoto(nReg))

	_nSC5_REC := TRB->C5_RECNO
	dbSelectArea("SC5")
	SC5->(dbGoTo(_nSC5_REC))
	
	//_________________________________

	//CARREGA AHEADER E ACOLS DE SC6 PARA VALIDAÇÃO DE C5_CONDPAG

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("SC6")
	While ! SC6->(eof()) .and. X3_ARQUIVO = "SC6"

		If X3USO(X3_USADO) .And. (cNivel >= X3_NIVEL)

			AADD(aHeader,{ 	TRIM(x3_titulo),;
							x3_campo,;
							x3_picture,;
							x3_tamanho,;
							x3_decimal,;
							x3_valid ,;
							/*RESERVADO*/,;
							x3_tipo,;
							/*RESERVADO*/,;
							x3_context} )
		Endif

		SX3->(dbSkip())

	End

	//PREENCHE VETOR ACOLS
	//_____________________

	dbSelectArea("SC6")
	dbSetOrder(1)
	SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM) )

	While ! SC6->(EOF()) .and. xFilial("SC6")+SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM

		aadd(aCols,array(len(aHeader)+1) )

		For _nx := 1 to len(aHeader)
			aCols[ len(aCols) ][_nx] := FieldGet( FieldPos( aHeader[_nx,2] ) )
		Next

		aCols[len(aCols)][ len(aHeader)+1 ] := .f.

		SC6->(dbSkip())
	End

	//__________________________________

	AxAltera("SC5", _nSC5_REC, nOpc, _aCampos  , _aCampos ,,,_cTudoOk )

Return

//__________________________
User Function CMB02TOK()
	
	Local lRetorna 		:= .t.             
	Local _nPVALOR 		:= ascan( aHeader , {|x|  alltrim(x[2]) == "C6_VALOR"  } )                           
	Local _nPPRCVEN		:= ascan( aHeader , {|x|  alltrim(x[2]) == "C6_PRCVEN"  } )                           
	Local _nPPRUNIT 	:= ascan( aHeader , {|x|  alltrim(x[2]) == "C6_PRUNIT"  } )                           
	Local _nPQTDVEN 	:= ascan( aHeader , {|x|  alltrim(x[2]) == "C6_QTDVEN"  } )                           
	Local _nPITEM 		:= ascan( aHeader , {|x|  alltrim(x[2]) == "C6_ITEM"  } )                           
	Local _nPPRODUTO 	:= ascan( aHeader , {|x|  alltrim(x[2]) == "C6_PRODUTO"  } )                           
	Local _aArea 		:= GetArea()
	Local nTotPed 		:= 0               
	Local nTotParc		:= 0

	Begin Transaction

		For _nx := 1 to len(aCols)

			SC6->(dbSetOrder(1))
			if SC6->(dbSeek(xfilial('SC6')+TRB->C5_NUM + aCols[_nx][_nPITEM] + aCols[_nx][_nPPRODUTO]))

				Reclock('SC6',.f.)
				SC6->C6_PRCVEN 	:= aCols[_nx][_nPPRCVEN]
				SC6->C6_VALOR 	:= aCols[_nx][_nPVALOR]
				SC6->(MsUnlock())
				
			Endif

			SC9->(dbSetOrder(1))
			if SC9->(dbSeek(xfilial('SC9')+TRB->C5_NUM + aCols[_nx][_nPITEM]))

				Reclock('SC9',.f.)
				SC9->C9_PRCVEN 	:= aCols[_nx][_nPPRCVEN] 
				SC9->(MsUnlock())

				nTotPed += SC9->C9_QTDLIB * SC9->C9_PRCVEN    

			Endif

		Next

		SE4->(dbSetOrder(1))
		if SE4->(dbSeek(xfilial('SE4')+M->C5_CONDPAG))

			if SE4->E4_TIPO == '9'

				_nx := 1
				While .t.

					if _nx < 10
						_nStrDesloc := 48
					Else
						_nStrDesloc := 55
					Endif

					_cParc := "C5_PARC"+   chr(_nx + _nStrDesloc)

					If SC5->(FieldPos(_cParc)) > 0
						_cParc := 'M->'+_cParc
						nTotParc += &_cParc
					Else	
						Exit
					Endif	 
					_nx+=1

				End		

				if alltrim(SE4->E4_COND) == '%'

					if nTotParc <> 100
						MsgAlert('A soma dos percentuais difere de 100 %')
						lRetorna := .f.
					Endif	

				Else
					if nTotParc <> round(nTotPed,2)
						MsgAlert('Valor das parcelas '+transform(nTotParc, '@E 999,999.99')+' diverge do valor total do pedido '+transform(nTotPed,'@E 999,999,999.99'))
						lRetorna := .f.
					Endif
				Endif	

			Else

//				If nTotPed > SE4->E4_SUPER .AND. SE4->E4_SUPER <> 0 .And. GetNewPar("MV_CNDPLIM","1")=="1"
				If nTotPed > SE4->E4_SUPER .AND. SE4->E4_SUPER <> 0
					Help(" ","1","LJLIMSUPER")
					lRetorna := .F.
//				ElseIf nTotPed < SE4->E4_INFER .AND. SE4->E4_INFER <> 0 .And. GetNewPar("MV_CNDPLIM","1")=="1"
				ElseIf nTotPed < SE4->E4_INFER .AND. SE4->E4_INFER <> 0
					Help(" ","1","LJLIMINFER")
					lRetorna := .F.
				Endif

			Endif
		Endif

		If ! lRetorna
			DisarmTransaction()
		Endif

	End Transaction

	/*if lRetorna

		SC6->(dbSetOrder(1))
		SC6->(dbSeek(xfilial('SC6')+TRB->C5_NUM))
	
		While ! SC6->(eof()) .and. SC6->C6_NUM == TRB->C5_NUM

			Reclock('SC6',.F.)
			dbDelete()
			SC6->(MsUnlock())
			SC6->(dbskip())
		Enddo
		
		For _nx := 1 to len(aCols)
		
			Reclock('SC6',.T.)
			SC6->C6_FILIAL 	:= xfilial("SC6")
			SC6->C6_NUM 	:= TRB->C5_NUM
			SC6->C6_CLI		:= TRB->C5_CLIENTE
		
			For _nY := 1 to len(aHeader)
		
				if aHeader[_nY][10] != "V"
					FieldPut( FieldPos(aHeader[_nY][2]) ,aCols[_nX][_nY]  )
				Endif
			
			Next
			
				SC6->(MsUnlock())
				SC9->(MsUnlock())		
		Next
			
		End
			
	Endif
	*/
	
	U_CBTotPv1()

	RestArea(_aArea)
	
	// DJALMA BORGES 29/11/2016 - INÍCIO
	If lRetorna == .T.
		If M->C5_CONDPAG <> SC5->C5_CONDPAG // SE CONDPAG FOI ALTERADO PELA TELA CUSTOMIZADA
			M->C5_XCPAMPL := "S"
		EndIf
	EndIf		
	// DJALMA BORGES 29/11/2016 - FIM

Return(lRetorna)


/*/{Protheus.doc} VisualX
//TODO Descrição auto-gerada.
@author totvsremote
@since 18/01/2016
@version undefined

@type function
/*/
User Function VisualX()
	
	Local nReg
	Local _aArea := GetArea()
	Local nOpc := 2
	Local __aRotina := aclone(aRotina)
	
	aRotina	  := { 	{"Pesquisar" ,"AxPesqui"  ,    0 , 1,  0, .F.},;
	{"Visualizar","A410Visual",      0 , 2,  0, .F.}}
	nReg := TRB->C5_RECNO	
	SC5->(dbGoTo(nReg))
	
	A410Visual('SC5',nReg,nOpc)
	
	aRotina := aClone(__aRotina)

	RestArea(_aArea)

Return


/*/{Protheus.doc} CBTotPv1
//TODO Descrição auto-gerada.
@author totvsremote
@since 26/01/2016
@version undefined

@type function
/*/
User Function CBTotPv1()

	Local _nTotal 	:= 0
	Local _nPVALOR 	:= ascan( aHeader , {|x|  alltrim(x[2]) == "C6_VALOR"  } )                           
	Local _nPPRCVEN := ascan( aHeader , {|x|  alltrim(x[2]) == "C6_PRCVEN"  } )  // Raphael Araújo - 21/10/2016                      
	Local _nPPRUNIT := ascan( aHeader , {|x|  alltrim(x[2]) == "C6_PRUNIT"  } )                           
	Local _nPQTDVEN := ascan( aHeader , {|x|  alltrim(x[2]) == "C6_QTDVEN"  } )                           
//	Local NVALOR 	:= 0
	Local NVALOR1 	:= 0 // DJALMA BORGES
	Local NVALOR2 	:= 0 // 20/02/2017
	Local nTotPed 	:= 0               
	Local nTotParc	:= 0
//	Local NPERC 	:= 0
	Local NPERC1 	:= 0 // DJALMA BORGES
	Local NPERC2 	:= 0 // 20/02/2017
	
//	NPERC := 100 - M->C5_DESC1
//	NPERC := NPERC / 100
	
	NPERC1 := 100 - M->C5_DESC1 // DJALMA
	NPERC1 := NPERC1 / 100		// BORGES
	
	NPERC2 := 100 - M->C5_DESC2 // 20/02
	NPERC2 := NPERC2 / 100		// 2017
	
	if IsInCallStack('U_CAMBC002')

		For _nx := 1 to len(aCols)

//			NVALOR 					:= aCols[_nx][_nPPRUNIT] * NPERC
//			aCols[_nx][_nPPRCVEN] 	:= NVALOR
//			aCols[_nx][_nPVALOR] 	:= NVALOR * aCols[_nx][_nPQTDVEN]
			
			// DJALMA BORGES 20/02/2017 - INÍCIO
			NVALOR1					:= aCols[_nx][_nPPRUNIT] * NPERC1
			aCols[_nx][_nPPRCVEN] 	:= NVALOR1
			aCols[_nx][_nPVALOR] 	:= NVALOR1 * aCols[_nx][_nPQTDVEN]
			
			NVALOR2					:= NVALOR1 * NPERC
			aCols[_nx][_nPPRCVEN] 	:= NVALOR2
			aCols[_nx][_nPVALOR] 	:= NVALOR2 * aCols[_nx][_nPQTDVEN]
			// DJALMA BORGES 20/02/2017 - FIM

			_nTotal += aCols[_nx][_nPVALOR]    

		Next
	Else
	
		//_nTotal := M->C5_XTOTPV1

	Endif

Return(_nTotal)