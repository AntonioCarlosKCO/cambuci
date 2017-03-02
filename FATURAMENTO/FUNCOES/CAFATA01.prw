#Include 'Protheus.ch'
#include 'totvs.ch'

User Function CAFATA01()

//____________________________________ MONTAGEM DA MBROWSE

cCadastro := "REGRA DE COMISSÕES"

aRotina := {	{ "Pesquisar"    ,"AxPesqui", 0, 1},;
{ "Visualizar"   ,'U_CAFAT01a', 0, 2},;
{ "Incluir"      ,'U_CAFAT01a', 0, 3},;
{ "Alterar"      ,'U_CAFAT01a', 0, 4},;
{ "Excluir"      ,'U_CAFAT01a', 0, 5} }

dbSelectArea("SZ1")
mBrowse( 6,1,22,75,"SZ1")
//__________________________________________________________


Return

//___________________________
//Por : Luis Henrique - Global
//Em  : 02/01/15
//Objetivo : Tela com componenestes DIALOG, ENCHOICE, GETDADOS, ENCHOICEBAR
//____________________________
User Function CAFAT01a(cAlias, nReg, nOpc)

Local aHeader 	:= {}
Local aCols		:= {}

Local cAliasG	:= "SZ2"
Local _lTransparente := .T.
Local aCpoEnch := {}
Local aPos := {000,000,080,400}
Local nModelo := 3

Local nSuperior := 081
Local nEsquerda := 000
Local nInferior := 250
Local nDireita := 400

Local cLinOk := "U_CAFAT01C()"
Local cTudoOk := "AllwaysTrue"
Local cIniCpos := ""
Local nFreeze := 000
Local nMax := 999
Local cFieldOk := "U_CAFAT01B()"
Local cSuperDel := ""
Local cDelOk := "AllwaysTrue"

Local aButtons := {}
Local aAlterGda := {}

Local aSize := {}
Local aInfo := {}
Local aObjects := {}                      
Local aPosGet := {}


Private oDlg
Private oGetD
Private aAlterEnch := {}


//CARREGA VETORES DE TRATAMENTO DA ENCHOICE VIA MSMGET()
//______________________________________________________
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(cAlias)
While !Eof() .And. SX3->X3_ARQUIVO == cAlias
	If !("Z1_FILIAL" $ SX3->X3_CAMPO  ) .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)
		AADD(aCpoEnch,SX3->X3_CAMPO)
	EndIf
	DbSkip()
End

aAlterEnch := aClone(aCpoEnch)


DbSelectArea("SX3")
DbSetOrder(1)
MsSeek(cAliasG)
While !Eof() .And. SX3->X3_ARQUIVO == cAliasG
	If !(AllTrim(SX3->X3_CAMPO) $ "Z2_FILIAL") .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)
		AADD(aAlterGDa,SX3->X3_CAMPO)
	EndIf
	DbSkip()
End



//_____________________________
//PREENCHE VETOR AHEADER
//_____________________________
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAliasG)
While ! SX3->(eof()) .and. X3_ARQUIVO == cAliasG
	
	If X3USO(SX3->x3_usado).And. cNivel >= SX3->x3_nivel
		
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
//_____________________
IF INCLUI
	aCols := array(1,len(aHeader)+1)
	aCols[len(aCols)][ len(aHeader)+1 ] := .f.
	
	For _nx := 1 to len(aHeader)
		IF alltrim(aHeader[_nX,2]) == "Z2_ITEM"
			aCols[1,_nX]:= "0001"
		ELSE
			aCols[len(acols)][_nx] := CriaVar(aHeader[_nx][2])
		Endif
	Next
	
	
ELSE
	
	dbSelectArea(cAliasG)
	dbSetOrder(1)
	dbSeek(xfilial(cAliasG)+SZ1->Z1_CODIGO)
	While ! (cAliasG)->(EOF()) .AND. (cAliasG)->Z2_FILIAL == xfilial(cAliasG) .and. (cAliasG)->Z2_CODIGO == SZ1->Z1_CODIGO
		
		aadd(aCols,array(len(aHeader)+1) )
		
		For _nx := 1 to len(aHeader)
			aCols[ len(aCols) ][_nx] := FieldGet( FieldPos( aHeader[_nx,2] ) )
		Next
		
		aCols[len(aCols)][ len(aHeader)+1 ] := .f.
		
		(cAliasG)->(dbSkip())
	End
	
ENDIF


aSize := MsAdvSize()

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
AAdd( aObjects, { 100, 30, .t., .t. } ) // enchoice
AAdd( aObjects, { 100, 60, .t., .t. } ) // getdados
AAdd( aObjects, { 100, 10, .t., .f. } ) // getdados

aPosObj := MsObjSize( aInfo, aObjects,.T.)
aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{003,033}} )

nGetLin := aPosObj[3,1]


RegToMemory(cAlias, nOpc == 3 )

oDlg := MSDIALOG():New(aSize[7],000,aSize[6],aSize[5], "Regra de Comissionamento - CAFAT01",,,,,,,,,.T.,,,,_lTransparente)

oEnch := MsMGet():New(cAlias,nReg,nOpc,/*aCRA*/,/*cLetra*/, /*cTexto*/,;
aCpoEnch,aPosObj[1], aAlterEnch, nModelo, /*nColMens*/, /*cMensagem*/,;
cTudoOk,oDlg)

oGetD:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], GD_INSERT + GD_UPDATE + GD_DELETE,;
cLinOk,cTudoOk,cIniCpos,aAlterGDa,nFreeze,nMax,cFieldOk, cSuperDel,;
cDelOk, oDLG, aHeader, aCols)

/*
@ nGetLin,aPosGet[1,01] SAY oSay PROMPT "TOTAL DO PEDIDO" 		SIZE 060,009 PIXEL OF oDlg
@ nGetLin,aPosGet[1,02] SAY oSay1 PROMPT 0  	SIZE 040,009  PIXEL OF oDlg
oSay1:Cargo := "Total do Pedido"
*/                                                        


// Tratamento para definição de cores específicas,
// logo após a declaração da MsNewGetDados

//oGetD:oBrowse:lUseDefaultColors := .F.
//oGetD:oBrowse:SetBlkBackColor({|| GETDCLR(oGetD:aCols,oGetD:nAt,aHeader)})

oDlg:bInit := {|| EnchoiceBar(oDlg, {|| U_FIM(nOpc, aCpoEnch, oGetd) }, {||oDlg:End()},,aButtons)}

oDlg:lCentered := .T.
oDlg:Activate()

Return

//______________________
//Finaliza Dialog
User Function Fim(nOpc, aCpoEnch, oGetd)
Local _nx


if nOpc <> 2
	
	BEGIN TRANSACTION
	
	
	if nOpc <> 3 // INCLUSAO
		
		// apagar os registros no disco
		
		//APAGANDO REGISTROS DA SZ1
		dbSelectArea("SZ1")
		dbSetOrder(1)
		if dbSeek(xfilial("SZ1")+M->Z1_CODIGO)
			
			Reclock("SZ1",.F.)
			SZ1->(dbDelete())
			SZ1->(MsUnlock())
			
		Endif
		
		//APAGANDO REGISTROS DA SZ2
		dbSelectArea("SZ2")
		dbSetOrder(1)
		dbSeek(xfilial("SZ2")+M->Z1_CODIGO)
		While ! SZ2->(eof()) .and. SZ2->Z2_CODIGO == M->Z1_CODIGO
			
			Reclock("SZ2",.F.)
			SZ2->(dbDelete())
			SZ2->(MsUnlock())
			SZ2->(dbSkip())
		End
		
	Endif
	
	if nOpc <> 5 // EXCLUSAO
		
		//incluir registros no disco
		
		//GRAVA SZ1
		Reclock("SZ1",.T.)
		SZ1->Z1_FILIAL := xfilial("SZ1")
		For _nx := 1 to len(aCpoEnch)
			_cVar 	:= "M->"+aCpoEnch[_nx]
			_cCampo := "SZ1->"+aCpoEnch[_nx]
			
			//PROCURA O CAMPO aCpoEnch[_nx] em SX3
			dbSelectArea("SX3")
			dbSetOrder(2)
			if dbSeek(	aCpoEnch[_nx] )
				
				//SE O CAMPO NAO FOR VIRTUAL - GRAVA
				if SX3->X3_CONTEXT != "V"
					&_cCampo := &_cVar
				Endif
			Endif
		Next
		SZ1->(MsUnlock())
		
		if nOpc == 3
			SZ1->(ConfirmSx8()	)	
		Endif
		
		//GRAVA SZ2
		For _ny := 1 to len(oGetD:Acols)
			
			if ! oGetD:aCols[_ny][len(oGetD:aHeader)+1]    //SOMENTE INCLUI O REGISTRO SE A LINHA DO ACOLS NAO ESTIVER DELETADA
				
				Reclock("SZ2",.T.)
				SZ2->Z2_FILIAL 	:= xfilial("SZ2")
				SZ2->Z2_CODIGO	:= M->Z1_CODIGO
				For _nx := 1 to len(oGetD:aHeader)
					
					if oGetD:aHeader[_nx][10] != "V"
						FieldPut( FieldPos(oGetD:aHeader[_nx][2]) ,oGetD:aCols[_ny][_nx]  )
					Endif
					
				Next
				SZ2->(MsUnlock())
				
			Endif
			
		Next
		
	Endif
	
	END TRANSACTION
	
Endif

oDlg:end()

Return


//________________________
// Por : Luis Henrique 
// Em  : 23/08/14
// Obj : Validação FIELDOK da getdados
//________________________
User Function CAFAT01b()
Local _lRet := .t.
Local _cCampo := ""    
Local _nPZ2_ORDEM 	:= Ascan( oGetD:aHeader, {|x| alltrim(x[2]) == "Z2_ORDEM"   } )
Local _nPZ2_SEQ 	:= Ascan( oGetD:aHeader, {|x| alltrim(x[2]) == "Z2_SEQUENC"   } )
Local _cSeq, _nLinSeq

For _nx := 1 to len(aAlterEnch)
        
	_cCampo := aAlterEnch[_nx]    
    if x3Obrigat(_cCampo)  
    	_cCampo := "M->"+_cCampo       
		_cConteudo := &_cCampo
		if empty(_cConteudo)		         
			_lRet :=.f.  
			exit                                
		Endif
	Endif

Next

if ! _lRet
	MsgAlert("Existe campo obrigatório da Enchoice não preenchido.")
Endif

//---------------------------------------------------

IF READVAR() = "M->Z2_ORDEM" 
	oGetD:aCols[oGetD:nAt][_nPZ2_ORDEM] := M->Z2_ORDEM
	_cSeq := oGetD:aCols[oGetD:nAt][_nPZ2_SEQ]
	aSort(oGetD:aCols,,, {|x,y|  x[_nPZ2_ORDEM] < y[_nPZ2_ORDEM] } )
	
	_nLinSeq := ascan(oGetD:aCols, {|x| x[_nPZ2_SEQ] == _cSeq   })

	oGetD:Goto(_nLinSeq)
	oGetD:Refresh(.t.)
	oGetD:nAt := _nLinSeq	
	oGetD:oBrowse:nAt := _nLinSeq
	oGetD:oBrowse:nRowPos := _nLinSeq
	oGetD:ForceRefresh()
	
ENDIF	
	
oDlg:refresh(.t.)


Return(_lRet)


//________________________
// Por : Luis Henrique 
// Em  : 23/08/14
// Obj : Validação LINHAOK da getdados
//________________________
User Function CAFAT01c()
Local _lRet := .t.
Local _nx
Local _ntotal := 0                  
Local _cTotal := ""

/*                   
_cTotal := Transform(_nTotal, "@E 99,999,999.99")             
oSay1:SetText(_cTotal)
*/

oDlg:refresh()             

Return(_lRet)


