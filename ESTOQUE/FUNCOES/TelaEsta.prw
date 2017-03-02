#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

/*/{Protheus.doc} TelaEstA
//Tabela de precos
@author totvsremote
@since 07/01/2016
@version 

@type function
/*/
User Function TelaEstA(_cEmpPrcFI, cProd)

Local _aArea := GetArea()
Local nOpc := GD_INSERT+GD_DELETE+GD_UPDATE

// DJALMA BORGES 14/12/2016 - INCÍCIO
Local _cFieldOk := 'U_TelaEa(_cEmpPrcFI, cProd)' // PASSAGEM DA STRING DE FILIAIS POR PARÂMETRO
Local nCount := 0
Local _nPFilial := 0
Local _nPTab := 0
Private _aHeadCols := {}
Private cUFST     := "SP"
Private cFilAntBkp := cFilAnt
Private _lExcluiLi := .F.
SETKEY(VK_F4, {|| oDlgPreco:End()   })
// DJALMA BORGES 14/12/2016 - FIM

//dbSelectArea('DA0')


oDlgPreco      := MSDialog():New( 106,148,630,1166,"Tabela de Preços",,,.F.,,,,,,.T.,,,.T. )
oSayEnd := TSay():New( 002,004,{||" || F4 = FECHAR ||"},oDlgPreco,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,008)
//oSay1      := TSay():New( 020,032,{||"Estado"},oDlgPreco,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
//oGet1      := TGet():New( 020,072,{|u| If(PCount()>0,cUFST:=u,cUFST)},oDlgPreco,060,008,'@!',{|x| VldcUFST()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"12","cUFST",,)
// CAMPO ESTADO COMENTADO - DJALMA BORGES 13/12/2016

Processa( {|| CarregaTab()},"Calculando Tabela de Preços ...")

oGetDPreco := MsNewGetDados():New(040,004,240,500,nOpc,'U_EMPRLOGA()','AllwaysTrue()','',,0,99,_cFieldOk,'','AllwaysTrue()',oDlgPreco,_aHeadCols[1],_aHeadCols[2],'U_EMPRLOGA()')
oGetDPreco:Editcell("DA0_DESCRI") := .F.

If ! __CUSERID $ GETMV("CB_USMPRVE") // DJALMA BORGES 04/01/2017
	oGetDPreco:Disable ()
EndIf 

oDlgPreco:Activate(,,,.T.)

RestArea(_aArea)

cFilAnt := cFilAntBkp

_nPFilial := ascan(oGetDPreco:aHeader, {|x|  alltrim(x[2]) == 'DA0_FILIAL'      } )
_nPTab 	  := ascan(oGetDPreco:aHeader, {|x|  alltrim(x[2]) == 'DA0_CODTAB'      } )

DA1->(dbSetOrder(1))
For nCount := 1 to Len(oGetDPreco:aCols)
	If oGetDPreco:aCols[nCount][Len(oGetDPreco:aCols[oGetDPreco:nAt])] == .T.
		If DA1->(dbSeek(oGetDPreco:aCols[nCount][_nPFilial] + oGetDPreco:aCols[nCount][_nPTab] + cProd))
			RECLOCK("DA1", .F.)
				DA1->(dbDelete())
			DA1->(MSUNLOCK())
		EndIf
	EndIf
Next

Return

//________________________________________
Static Function VldcUFST()
Local _lRet := .t.

Processa( {|| CarregaTab()},"Calculando Tabela de Preços ...")

oGetDPreco:aCols := aClone(_aHeadCols[2])
oGetDPreco:refresh()
oDlgPreco:refresh()

Return(_lRet)



Static Function CarregaTab()
      
ProcRegua(10)
oDlgPreco:refresh()
      
_aHeadCols := U_MtHdCols("DA1","PRECO")          
           
For _nx := 1 to 10
	incProc()
Next
Return


User function TelaEa(_cEmpPrcFI, cProd)

	Local _lret 	:= .t.
	Local _aArea 	:= GetArea()
	Local _nPTab	:= ascan(oGetDPreco:aHeader, {|x|  alltrim(x[2]) == 'DA0_CODTAB'      } )
	Local _nPDesc	:= ascan(oGetDPreco:aHeader, {|x|  alltrim(x[2]) == 'DA0_DESCRI'      } )
	Local _nPIPI	:= ascan(oGetDPreco:aHeader, {|x|  alltrim(x[2]) == 'B1_IPI'      } )
	Local _nPPRCI	:= ascan(oGetDPreco:aHeader, {|x|  alltrim(x[2]) == 'DA1_PRCIMP'      } )

	Local _nLi		:= oGetDPreco:nAt
	Local _cCodTab 	:= oGetDPreco:aCols[_nLi][_nPTAB]
	Local _cMaxItem := MaxDA1(_cCodTab)
	
	// DJALMA BORGES 13/12/2016 - INÍCIO
	Local nCount := 0 
	Local nAtAnt := 0
	Local _nPFilial := ascan(oGetDPreco:aHeader, {|x|  alltrim(x[2]) == 'DA0_FILIAL'      } )
	Local cItemDA1 := ""
	// DJALMA BORGES 13/12/2016 - FIM
	
	if ReadVar() = 'M->DA1_PRCVEN'
	
		// DJALMA BORGES 14/12/2016 - INÍCIO
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		dbSeek(xFilial("SB1") + cProd )
		// DJALMA BORGES 14/12/2016 - FIM
		
		oGetDPreco:aCols[oGetDPreco:nAt][_nPIPI] 	:= SB1->B1_IPI
		//oGetDPreco:aCols[oGetDPreco:nAt][_nPPRCI] 	:= M->DA1_PRCVEN / ( ( 100 - SB1->B1_IPI ) / 100)
		// RETIRADO CÁLCULO PARA SOMAR IPI AO PREÇO DE VENDA - DJALMA BORGES 13/12/2016
	
		DA1->(dbSetOrder(1))
		if ! DA1->(dbSeek(xfilial('DA1')+_cCodTab+cProd))
			If DA1->(dbSeek(xfilial('DA1')+_cCodTab)) // DJALMA BORGES 14/12/2016
				cItemDA1 := Soma1(DA1->DA1_ITEM)
			EndIf
			Reclock('DA1',.t.)
			DA1->DA1_FILIAL := xfilial('DA1')
			DA1->DA1_CODPRO := cProd
			DA1->DA1_CODTAB := _cCodTab
			DA1->DA1_ITEM   := cItemDA1 // DJALMA BORGES 14/12/2016
			DA1->DA1_ATIVO 	:= '1'
			DA1->DA1_TPOPER := '4'
			DA1->DA1_QTDLOT := 999999.99
			DA1->DA1_ITEM   := _cMaxItem
		Else
			Reclock('DA1',.F.)
		Endif
		DA1->DA1_PRCVEN := M->DA1_PRCVEN
		DA1->(MsUnlock())
	
	
	elseif ReadVar() = 'M->DA0_CODTAB'
	
	 	nAtAnt := n
	
//		DA0->(dbSeek(xfilial()+M->DA0_CODTAB))
		If DA0->(dbSeek(oGetDPreco:aCols[oGetDPreco:nAt][_nPFilial] + M->DA0_CODTAB)) // DJALMA BORGES 13/12/2016
			
			oGetDPreco:aCols[oGetDPreco:nAt][_nPDesc] := DA0->DA0_DESCRI
			
			For nCount := 1 to Len(oGetDPreco:aCols) // DJALMA BORGES 13/12/2016
				If oGetDPreco:aCols[nCount][_nPTab] == M->DA0_CODTAB 
					MsgAlert("Esta lista já está cadastrada para este produto.")
					_lRet := .F.
				EndIf
			Next
			
		Else

			MsgAlert("Lista não cadastrada para esta empresa.")
			_lRet := .F.
			
		EndIf
		
		n := nAtAnt
	
	ElseIf ReadVar() = 'M->DA0_FILIAL' // DJALMA BORGES 13/12/2016
	
		If ! ALLTRIM(M->DA0_FILIAL) $ _cEmpPrcFI
			MsgAlert("Não é permitido incluir uma lista nesta empresa porque ela não está selecionada.")
			_lRet := .F.
		Else
			cFilAnt := M->DA0_FILIAL
			dbSelectArea("DA0")
			DA0->(dbSetOrder(1))
			DA0->(dbSeek(cFilAnt))
		EndIf
		
	Endif
	
	oGetDPreco:ForceRefresh(.T.)
	
	oGetDPreco:refresh()
	oDlgPreco:refresh()
	
	RestArea(_aArea)
	
Return(_lRet)



/*/{Protheus.doc} MaxDA1
//TODO Descrição auto-gerada.
@author totvsremote
@since 02/06/2016
@version undefined
@param _cCodTab, , descricao
@type function
/*/
Static Function MaxDA1(_cCodTab)
Local _cAlias := GetNextalias()
Local _cMaxItem := '0'

BeginSql Alias _cAlias

select MAX(DA1_ITEM)  AS cMAXITEM
// FROM DA1010
FROM %Table:DA1% (Nolock) // DJALMA BORGES 14/12/2016
WHERE D_E_L_E_T_ = ''
AND DA1_CODTAB = %Exp:_cCodTab%


EndSql

(_cAlias)->(dbGoTop())
if ! (_cAlias)->(eof())

	_cMaxItem := (_cAlias)->cMAXITEM

Endif

_cMaxItem := val((_cAlias)->cMAXITEM)
_cMaxItem += 1
_cMaxItem := strzero(_cMaxItem,4)

(_cAlias)->(dbCloseArea())


Return(_cMaxItem)

// FUNÇÃO PARA LOGAR NA FILIAL DO ACOLS E RETORNAR A CONSULT PADRÃO DAS TABELAS DE PREÇO POR FILIAL
// DJALMA BORGES 14/12/2016
User Function EMPRLOGA()

	Local _nPFilial := ascan(oGetDPreco:aHeader, {|x|  alltrim(x[2]) == 'DA0_FILIAL'      } )

	If ALLTRIM(oGetDPreco:aCols[oGetDPreco:nAt][_nPFilial]) <> ""
		cFilAnt := oGetDPreco:aCols[oGetDPreco:nAt][_nPFilial]
		dbSelectArea("DA0")
		DA0->(dbSetOrder(1))
		DA0->(dbSeek(cFilAnt))
	EndIf

Return .T.
