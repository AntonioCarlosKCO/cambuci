#INCLUDE "rwmake.CH"
#Include "COLORS.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "TopConn.ch" 
#INCLUDE "Protheus.ch"
#include "totvs.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CONTAINV º Autor ³ JOSMAR CASTIGLIONI º Data ³  15/02/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ PE PARA TAREFAS - INVENTÁRIO                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CAMBUCI                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CONTAINV()

DBSELECTAREA("ZZK")
DBSETORDER(3)
dbgotop()

bGera    := {|| PROCESSA({|| GERAREL()})}  
bBloq    := {|| PROCESSA({|| CABLOQ()})}   
bDesblq  := {|| PROCESSA({|| CADESBLQ()})} 
bImpcont := {|| RECONTA() } 			   
bImpqtd  := {|| REQTDE() }
bExclui  := {|| PROCESSA({|| ZKEXCLUI()})}               
bLegenda := {|| ZKLEGENDA() }              
bInvent  := {|| CAINVENT() }

aRotina := {{ "Relatorio Contagem",'Eval(bimpcont)', 0 , 1},;
			{ "Relatorio Quantidades",'Eval(bimpqtd)', 0 , 1},;
			{ "Bloquear Estoque",'Eval(bBloq)', 0 , 2},;
			{ "Gerar Documento",'Eval(bGera)' , 0 , 3},;
			{ "Lançar Inventario",'Eval(bInvent)' , 0 , 4},;
			{ "Desbloquear Estoque",'Eval(bDesblq)', 0 , 5},;
			{ "Excluir Documento",'Eval(bExclui)', 0 , 6},;
			{ "Legenda",'Eval(bLegenda)', 0 , 7} }
cCadastro:="Relação para Contagem de Inventário"

aCores := {{"ZZK_FLAG == 'N'",'BR_VERDE'},{"ZZK_FLAG == 'S'",'BR_VERMELHO'},{"ZZK_FLAG == 'I'",'BR_PRETO'},{"ZZK_FLAG == 'K'",'BR_AZUL'}}
                                           
mBrowse( 6, 1,22,75,'ZZK',,,,,,aCores)   

DBSELECTAREA("ZZK")
DBSETORDER(3)
dbgotop()


Return nil

*********************************************************************************************************

static function GERAREL()

PRIVATE cDoc := space(9)
Private cPerg:='CONTAINV'
Private _QtdRec := 0
AjustaSX1(cPerg)

If !Pergunte(cPerg,.T.)
   Return
End   
                   
DBSELECTAREA("ZZK")
DBSETORDER(1)

DBSELECTAREA("SBF")   
DBSETORDER(1)

cDoc := GETSXENUM("ZZK","ZZK_DOC")
CONFIRMSX8()    

cQuery := "SELECT "
cQuery += "SBF.BF_FILIAL FIL,"
cQuery += "SBF.BF_PRODUTO PROD,"
cQuery += "SBF.BF_LOCAL LOCPA, "
cQuery += "SBF.BF_LOCALIZ ENDE, "
cQuery += "SB1.B1_TIPO TIPO,"
cQuery += "SB1.B1_DESC DESCRI "
cQuery += "FROM "
cQuery += RetSqlName("SBF") + " SBF, "
cQuery += RetSqlName("SB1") + " SB1 "
cQuery += "WHERE BF_FILIAL = '" + xFilial("SBF") + "'"
cQuery += "AND SBF.BF_LOCALIZ >= '" + MV_PAR01 + "' "
cQuery += "AND SBF.BF_LOCALIZ <= '" + MV_PAR02 + "' "
cQuery += "AND SBF.BF_LOCAL = '" + MV_PAR03 + "' "
cQuery += "AND SBF.BF_PRODUTO = SB1.B1_COD "
cQuery += "AND SBF.D_E_L_E_T_ <> '*' "
cQuery += "AND SB1.D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY LOCPA,ENDE,DESCRI"
cQuery := ChangeQuery( cQuery )

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"AUXI", .F., .T.)

dbSelectArea("AUXI")
dbgotop()
while !EOF()
	_QtdRec++
	dbskip()
enddo

IF _QtdRec > 0
    dbselectarea("AUXI")
    dbgotop()
	ProcRegua(RECCOUNT())

	WHILE !Eof()
		DBSELECTAREA("ZZK")
		RECLOCK("ZZK",.T.)
		ZZK->ZZK_FILIAL := AUXI->FIL
		ZZK->ZZK_COD    := AUXI->PROD
		ZZK->ZZK_LOCAL  := AUXI->LOCPA
		_xLocPa         := AUXI->LOCPA
		ZZK->ZZK_TIPO   := AUXI->TIPO
		ZZK->ZZK_DOC    := cDoc
		ZZK->ZZK_DATA   := DDATABASE
		ZZK->ZZK_DESC   := AUXI->DESCRI
		ZZK->ZZK_LOCALI := AUXI->ENDE
		ZZK->ZZK_FLAG   := "N"
		ZZK->(MSUNLOCK())                  
		DBSELECTAREA("AUXI")
		DBSKIP()
		IncProc()
	ENDDO	


	DBSELECTAREA("ZZK")   //PROCURA ENDEREÇOS EM OUTROS ARMAZENS
	DBSETORDER(5)
	DBGOTOP()
	DBSEEK(xFilial("ZZK")+_xLOCPA+cDoc)
	_cFil := ZZK->ZZK_FILIAL
	_cLoc := ZZK->ZZK_LOCAL
	_cDoc := ZZK->ZZK_DOC

	ProcRegua(RECCOUNT())

	WHILE !Eof() .AND. ZZK->ZZK_FILIAL+ZZK->ZZK_LOCAL+ZZK->ZZK_DOC == _cFil+_cLoc+_cDoc
    	DBSELECTAREA("SBF")
    	DBSETORDER(2)
    	DBGOTOP()
    	IF _cLoc == "01"
    		DBSEEK(_cFil+ZZK->ZZK_COD+"02")
        	IF FOUND()
        		ZZK->(RECLOCK("ZZK",.F.))	
        		ZZK->ZZK_ENDA := SBF->BF_LOCALIZ
        		ZZK->(MSUNLOCK())                  
        	ENDIF
        	DBSEEK(_cFil+ZZK->ZZK_COD+"03")
        	IF FOUND()
        		ZZK->(RECLOCK("ZZK",.F.))	
        		ZZK->ZZK_ENDB := SBF->BF_LOCALIZ
        		ZZK->(MSUNLOCK())                  
        	ENDIF
    	ELSEIF _cLoc == "02"
    		DBSEEK(_cFil+ZZK->ZZK_COD+"01")
        	IF FOUND()
        		ZZK->(RECLOCK("ZZK",.F.))	
        		ZZK->ZZK_ENDA := SBF->BF_LOCALIZ
        		ZZK->(MSUNLOCK())                  
        	ENDIF
        	DBSEEK(_cFil+ZZK->ZZK_COD+"03")
        	IF FOUND()
        		ZZK->(RECLOCK("ZZK",.F.))	
        		ZZK->ZZK_ENDB := SBF->BF_LOCALIZ
        		ZZK->(MSUNLOCK())                  
        	ENDIF
    	ELSEIF _cLoc == "03"
    		DBSEEK(_cFil+ZZK->ZZK_COD+"01")
        	IF FOUND()
        		ZZK->(RECLOCK("ZZK",.F.))	
        		ZZK->ZZK_ENDA := SBF->BF_LOCALIZ
        		ZZK->(MSUNLOCK())                  
        	ENDIF
        	DBSEEK(_cFil+ZZK->ZZK_COD+"02")
        	IF FOUND()
        		ZZK->(RECLOCK("ZZK",.F.))	
        		ZZK->ZZK_ENDB := SBF->BF_LOCALIZ
        		ZZK->(MSUNLOCK())                  
        	ENDIF    
    	ENDIF     
    	DBSELECTAREA("ZZK")
    	DBSKIP()
		IncProc()
	ENDDO
    
	DBSELECTAREA("AUXI")	
	dbclosearea("AUXI")
    _QtdRec := 0
	MSGALERT("Documento "+alltrim(_cDoc)+" Armazem "+_cLoc+" Gerado com Sucesso!!!")

ELSE
	DBSELECTAREA("AUXI")	
	dbclosearea("AUXI")      
	MSGALERT("Armazem "+MV_PAR03+" ou Endereços não existem, Impossivel Gerar Relatório!!!")
ENDIF

Return

*****************************************************************************

//Carrega multiline para a digitacao do inventario

Static function CAINVENT()

Local aArea   := GetArea()
nX := 0
Public _nOPCA := 2
PRIVATE cDoc := space(9)
PRIVATE cLoc := space(2)
Private cPerg:='BLQINV'

AjusSX1B(cPerg)

If !Pergunte(cPerg,.T.)
   Return
End   
    
cDoc := MV_PAR01
cLoc := MV_PAR02   
aCols:= {}
aHeader:= {}
dbSelectarea("SX3")    //MONTA aHeader em ordem especifica
DBSEEK("ZZK")
While !EOF() .and. X3_ARQUIVO=="ZZK"
	IF  alltrim(x3_campo)$"ZZK_DOC"
		AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, X3_VALID,;
		X3_USADO, X3_TIPO, X3_ARQUIVO, X3_VISUAL } )
		EXIT
	EndIf
    dbskip()
Enddo
dbSelectarea("SX3")
DBSEEK("ZZK")
While !EOF() .and. X3_ARQUIVO=="ZZK"
	IF  alltrim(x3_campo)$"ZZK_COD"
		AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, X3_VALID,;
		X3_USADO, X3_TIPO, X3_ARQUIVO, X3_VISUAL } )
		EXIT
	EndIf
    dbskip()
Enddo
dbSelectarea("SX3")
DBSEEK("ZZK")
While !EOF() .and. X3_ARQUIVO=="ZZK"
	IF  alltrim(x3_campo)$"ZZK_LOCAL"
		AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, X3_VALID,;
		X3_USADO, X3_TIPO, X3_ARQUIVO, X3_VISUAL } )
		EXIT
	EndIf                           
    dbskip()
Enddo
dbSelectarea("SX3")
DBSEEK("ZZK")
While !EOF() .and. X3_ARQUIVO=="ZZK"	
	IF  alltrim(x3_campo)$"ZZK_TIPO"
		AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, X3_VALID,;
		X3_USADO, X3_TIPO, X3_ARQUIVO, X3_VISUAL } )
		EXIT
	EndIf                           
    dbskip()
Enddo
dbSelectarea("SX3")
DBSEEK("ZZK")
While !EOF() .and. X3_ARQUIVO=="ZZK"	
	IF  alltrim(x3_campo)$"ZZK_QUANT"
		AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, X3_VALID,;
		X3_USADO, X3_TIPO, X3_ARQUIVO, X3_VISUAL } )
		EXIT
	EndIf                           
    dbskip()
Enddo
dbSelectarea("SX3")
DBSEEK("ZZK")
While !EOF() .and. X3_ARQUIVO=="ZZK"	
	IF  alltrim(x3_campo)=="ZZK_LOCALI"
		AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, X3_VALID,;
		X3_USADO, X3_TIPO, X3_ARQUIVO, X3_VISUAL } )
		EXIT
	EndIf                           
    dbskip()
Enddo        
dbSelectarea("SX3")
DBSEEK("ZZK")
While !EOF() .and. X3_ARQUIVO=="ZZK"	
	IF  alltrim(x3_campo)$"ZZK_DATA"
		AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, X3_VALID,;
		X3_USADO, X3_TIPO, X3_ARQUIVO, X3_VISUAL } )
		EXIT
	EndIf                           
    dbskip()
Enddo        
dbSelectarea("SX3")
DBSEEK("ZZK")
While !EOF() .and. X3_ARQUIVO=="ZZK"	
	IF  alltrim(x3_campo)$"ZZK_DESC"
		AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, X3_VALID,;
		X3_USADO, X3_TIPO, X3_ARQUIVO, X3_VISUAL } )
		EXIT
	EndIf
	dbSkip()	
EndDo

DBSELECTAREA("ZZK")   
DBSETORDER(3)
DBGOTOP()        
DBSEEK(xFilial("ZZK")+cLoc+cDoc)
IF FOUND()
	IF ZZK->ZZK_FLAG == "I" .OR. ZZK->ZZK_FLAG == "K"
		MSGALERT("Documento "+alltrim(ZZK->ZZK_DOC)+" Armazem "+ZZK->ZZK_LOCAL+" já Lançado no Inventário!!!")	
	    RETURN
	ELSEIF ZZK->ZZK_FLAG == "N"
		MSGALERT("Documento "+alltrim(ZZK->ZZK_DOC)+" Armazem "+ZZK->ZZK_LOCAL+" não bloquado, bloqueie o documento para lançaro Inventário!!!")	
	    RETURN
	ENDIF    
	cFil := ZZK->ZZK_FILIAL
	If lastrec() > 0          // Se ja existem dados no multiline, carrega as informacoes
		While !eof() .AND. ZZK->ZZK_FILIAL+ZZK->ZZK_LOCAL+ZZK->ZZK_DOC == cFil+cLoc+cDoc
			AADD(aCols,Array(Len(aHeader)+1))
			nLin := Len(aCols)
			aCols[nLin,Len(aHeader)+1] := .F.
			aCols[nLin,1]  := ZZK->ZZK_DOC
			aCols[nLin,2]  := ZZK->ZZK_COD
			aCols[nLin,3]  := ZZK->ZZK_LOCAL
			aCols[nLin,4]  := ZZK->ZZK_TIPO
			aCols[nLin,5]  := ZZK->ZZK_QUANT
			aCols[nLin,6]  := ZZK->ZZK_LOCALI
			aCols[nLin,7]  := ZZK->ZZK_DATA
			aCols[nLin,8]  := ZZK->ZZK_DESC
			DbSkip()
		Enddo
	Endif

	@ 150,035 To 650,1100 Dialog odlg1 Title "INVENTÁRIO - DOCUMENTO: "+ALLTRIM(cDoc)+" - ENDEREÇOS x PRODUTOS"
	@ 2,1  TO 220,535 MULTILINE MODIFY DELETE VALID DelLinOk(N) Object oMulti

	@ 230,420 BmpButton Type 1 Action (_nOPCA:=1,close(odlg1))
	@ 230,460 BmpButton Type 2 Action (_nOPCA:=2,ODLG1:end())

	Activate Dialog odlg1 Centered

	//Grava as informacoes digitadas no multiline
	IF _nOPCA == 1  //confirma gravação - GRAVA NO SB7
		DbSelectarea("SB7")
		DBSETORDER(3) //FILIAL+DOC+COD+LOCAL
		DBGOTOP()
		DBSEEK(xFilial("SB7")+aCols[N,1])
		IF FOUND()
			MSGALERT("Documento "+alltrim(aCols[nLin,1])+" Armazem "+aCols[nLin,3]+" já Lançado no Inventário!!!")
		    RETURN
		ELSE
			For nX := 1 To Len(aCols)	
				Reclock("SB7",.T.)
				SB7->B7_FILIAL  := xFilial("SB7")
				SB7->B7_COD     := aCols[nX,2]
				SB7->B7_LOCAL   := aCols[nX,3]
				SB7->B7_TIPO    := aCols[nX,4]
				SB7->B7_DOC     := aCols[nX,1]
				SB7->B7_QUANT   := aCols[nX,5]
				SB7->B7_DATA    := aCols[nX,7]
				SB7->B7_DTVALID := DDATABASE
				SB7->B7_LOCALIZ := aCols[nX,6]
				SB7->B7_STATUS  := "1"
				SB7->B7_ORIGEM  := "CAMBUCI"
		    	SB7->(MSUNLOCK())
            Next Nx

		    DBSELECTAREA("ZZK")   
			DBSETORDER(3)
			DBGOTOP()        
			DBSEEK(xFilial("ZZK")+cLoc+cDoc)
			While !EOF() .and. ZZK->ZZK_FILIAL+ZZK->ZZK_LOCAL+ZZK->ZZK_DOC == xFilial("ZZK")+cLoc+cDoc
            	RECLOCK("ZZK",.F.)
                ZZK->ZZK_FLAG := "I"
                ZZK->(MSUNLOCK())
                DBSKIP()
            ENDDO
			MSGALERT("Inventário do Docucmento: "+alltrim(cDoc)+" Armazem: "+cLoc+" Lançado com Sucesso !!!")		
		ENDIF
	ENDIF
ELSE
	MSGALERT("Docucmento: "+alltrim(cDoc)+" Armazem: "+cLoc+" não encontrado !!!")
ENDIF

RETURN

****************************************************************************

static function CABLOQ()  

Local aArea   := GetArea()
PRIVATE cDoc := space(9)
PRIVATE cLoc := space(2)
Private cPerg:='BLQINVA'

AjusSX1A(cPerg)

If !Pergunte(cPerg,.T.)
   Return
End   
    
cDoc  := MV_PAR01
cLoc  := MV_PAR02   
cDias := MV_PAR03
                   
DBSELECTAREA("ZZK")   
DBSETORDER(5)
DBGOTOP()        
DBSEEK(xFilial("ZZK")+cLoc+cDoc)

IF FOUND()
	IF ZZK->ZZK_FLAG == "S"
		ALERT("Documento já Bloqueados !!!")
		RESTAREA(aAREA)
    	RETURN
	ELSEIF ZZK->ZZK_FLAG == "I" .OR. ZZK->ZZK_FLAG == "K"
		ALERT("Documento com inventário já lançado !!!")
		RESTAREA(aAREA)	
		RETURN
	ENDIF
	cFil := ZZK->ZZK_FILIAL
	ProcRegua(RECCOUNT())
	WHILE !Eof() .AND. ZZK->ZZK_FILIAL+ZZK->ZZK_LOCAL+ZZK->ZZK_DOC == cFil+cLoc+cDoc
    	DBSELECTAREA("SB2")
    	DBSETORDER(2)
    	DBGOTOP()
    	DBSEEK(cFil+cLoc+ZZK->ZZK_COD)
	    IF FOUND()
	      	SB2->(RECLOCK("SB2",.F.))	
	       	SB2->B2_DINVFIM := DDATABASE + cDias  //FIM DO BLOQUEIO
	       	SB2->B2_DTINV   := DDATABASE          //INICIO DO BLOQUEIO
   		   	SB2->(MSUNLOCK())
   		   	DBSELECTAREA("ZZK")
   		   	ZZK->(RECLOCK("ZZK",.F.))	
	       	ZZK->ZZK_FLAG := "S"
   		   	ZZK->(MSUNLOCK()) 
    	ELSE
    	    MSGALERT("Armazem: "+cLoc+" Produto: "+alltrim(ZZK->ZZK_COD)+" não encontrados no estoque para bloqueio!!")
    	    RestArea(aArea)
    	    RETURN
    	ENDIF     
    	DBSELECTAREA("ZZK")
    	DBSKIP()
		IncProc()
	ENDDO
ELSE
	MSGALERT("Armazem: "+cLoc+" e Docucmento: "+alltrim(cDoc)+" não encontrados!!")
    RestArea(aArea)
    RETURN
ENDIF

MSGALERT("Docucmento: "+alltrim(cDoc)+" Armazem: "+cLoc+" Bloqueado com Sucesso !!!")

RestArea(aArea)

Return

*****************************************************************************

static function CADESBLQ()  

Local aArea   := GetArea()
PRIVATE cDoc := space(9)
PRIVATE cLoc := space(2)
Private cPerg:='BLQINV'

AjusSX1B(cPerg)

If !Pergunte(cPerg,.T.)
   Return
End   
    
cDoc := MV_PAR01
cLoc := MV_PAR02   
                   
DBSELECTAREA("ZZK")   
DBSETORDER(5)
DBGOTOP()        
DBSEEK(xFilial("ZZK")+cLoc+cDoc)

IF FOUND()
	IF ZZK->ZZK_FLAG == "N"
		ALERT("Documento já Desbloqueados !!!")
		RESTAREA(aAREA)
    	RETURN
	ELSEIF ZZK->ZZK_FLAG == "K"
		ALERT("Documento com o inventário já lançado e Desbloquado !!!")
		RESTAREA(aAREA)	
		RETURN
	ENDIF
	cFil := ZZK->ZZK_FILIAL
	ProcRegua(RECCOUNT())
	WHILE !Eof() .AND. ZZK->ZZK_FILIAL+ZZK->ZZK_LOCAL+ZZK->ZZK_DOC == cFil+cLoc+cDoc
    	DBSELECTAREA("SB2")
    	DBSETORDER(2)
    	DBGOTOP()
    	DBSEEK(cFil+cLoc+ZZK->ZZK_COD)
	    IF FOUND()
	      	SB2->(RECLOCK("SB2",.F.))	
	       	SB2->B2_DINVFIM := CTOD("  /  /  ")
	       	SB2->B2_DTINV   := CTOD("  /  /  ")
   		   	SB2->(MSUNLOCK())
   		   	DBSELECTAREA("ZZK")
   		   	ZZK->(RECLOCK("ZZK",.F.))	
	       	IF ZZK->ZZK_FLAG == "S"
	       		ZZK->ZZK_FLAG := "N"
   		   	ELSEIF ZZK->ZZK_FLAG == "I"
   		   		ZZK->ZZK_FLAG := "K"
   		   	ENDIF
   		   	ZZK->(MSUNLOCK()) 
    	ELSE
    	    MSGALERT("Armazem: "+cLoc+" Produto: "+alltrim(ZZK->ZZK_COD)+" não encontrados no estoque para desbloqueio!!")
    	    RestArea(aArea)
    	    RETURN
    	ENDIF     
    	DBSELECTAREA("ZZK")
    	DBSKIP()
		IncProc()
	ENDDO
ELSE
	MSGALERT("Armazem: "+cLoc+" e Docucmento: "+alltrim(cDoc)+" não encontrados!!")
    RestArea(aArea)
    RETURN
ENDIF

MSGALERT("Docucmento: "+alltrim(cDoc)+" Armazem: "+cLoc+" Desbloqueado com Sucesso !!!")

RestArea(aArea)

Return

***********************************************************

Static Function ZKLegenda()

BrwLegenda("Situação dos Documentos","Legenda",{{"BR_VERDE","Estoque Desbloqueado" },;
{"BR_VERMELHO","Estoque Bloqueado"},{"BR_PRETO","Inventário Lançado e Bloqueado"},{"BR_AZUL","Inventário Lançado e Desbloqueado"}}) 

Return .T.

************************************************************

Static Function RECONTA()

Public oPrn
Public cString := "ZZK"            
Public li      := 0
Public _wDoc    := space(9)
Public _wLocp   := space(2)
Public mPag      := 0
Private cPerg:='BLQINV'

AjusSX1B(cPerg)

If !Pergunte(cPerg,.T.)
   Return
End   
    
_wDoc  := MV_PAR01
_wLocP := MV_PAR02   

oFont1  :=    TFont():New("Arial Black"     ,09,12,,.T.,,,,,.F.)
oFont2  :=    TFont():New("Arial"           ,09,12,,.F.,,,,,.F.)
oFont3  :=    TFont():New("Arial Black"		,09,16,,.T.,,,,,.F.)
oFont4  := 	  TFont():New("Arial"      		,09,12,,.T.,,,,,.F.)
oFont5  := 	  TFont():New("Arial"      		,09,18,,.T.,,,,,.F.)
oFont6  := 	  TFont():New("Arial"      	    ,09,14,,.T.,,,,,.F.)
oFont7  := 	  TFont():New("Arial"           ,09,08,,.T.,,,,,.F.) 
oFont8  := 	  TFont():New("Arial"           ,09,09,,.F.,,,,,.F.)
oFont9  := 	  TFont():New("Times New Roman" ,09,13,,.T.,,,,,.F.)
oFont10 :=    TFont():New("Arial"           ,09,09,,.F.,,,,,.F.)    
oFont11 := 	  TFont():New("Arial"           ,09,07,,.F.,,,,,.F.)  
oFont12 := 	  TFont():New("Arial"           ,09,10,,.T.,,,,,.F.)
oFont13 := 	  TFont():New("Arial"           ,09,08,,.F.,,,,,.F.)
oFont14 := 	  TFont():New("Arial"           ,09,11,,.T.,,,,,.F.)

dbSelectArea(cString)
dbSetOrder(3) //FILIAL+LOCAL+DOCUMENTO+ENDEREÇO+DESC
DBGOTOP()
dbSeek(xFilial()+_wLocp+_wDoc)
IF !FOUND()
	MSGALERT("Docucmento: "+alltrim(_wDoc)+" Armazem: "+_wLocP+" não encontrado !!!")
    return
ELSE
	IF ZZK->ZZK_FLAG == "N"   	
   		MSGALERT("Não esqueça de bloquear o Docucmento: "+alltrim(_wDoc)+" Armazem: "+_wLocP+" para iniciar o inventário !!!")
	ENDIF
ENDIF

oPrn:=TMSPrinter():New()
oPrn:SetPORTRAIT()  //RETRATO
oPrn:SetPage(9) //A4
oprn:setup()
oprn:startpage()

PROCESSA({|| ZKIMPDET()})

oprn:endpage()
oprn:PREVIEW()
oprn:end()


Return(.T.)

****************************************************************************

Static Function ZKIMPDET()

nQuantos := 0
_Cabec(_wLocP,_wDoc)

While !Eof() .And. ZZK->ZZK_FILIAL+ZZK->ZZK_LOCAL+ZZK->ZZK_DOC == xFilial()+_wLocp+_wDoc
	_xEnd := ZZK->ZZK_LOCALI
	_xDoc := ZZK->ZZK_DOC
	_xArm := ZZK->ZZK_LOCAL
	_xFil := ZZK->ZZK_FILIAL
	oPrn:Line(li-40,0010,li-40,2530)
	oPrn:Line(li-30,0010,li-30,2530)
	oPrn:Say(li-20,0010,"Endereço: "+ALLTRIM(ZZK->ZZK_LOCALI),oFont6,100)
	oPrn:Line(li+36,0010,li+36,2530)
	li+=50
	While !EOF() .and. ZZK->ZZK_FILIAL+ZZK->ZZK_LOCAL+ZZK->ZZK_DOC+ZZK->ZZK_LOCALI == _xFil+_xArm+_xDoc+_xEnd
		oPrn:Say(li,0010,substr(ALLTRIM(ZZK->ZZK_DESC),1,55),oFont13,100)
		oPrn:Line(li-14,1004,li+33,1004)
		oPrn:Line(li-14,1010,li+33,1010)
		oPrn:Say(li-8,1020,ALLTRIM(ZZK->ZZK_COD),oFont14,100)
		oPrn:Line(li-14,1385,li+33,1385)
		oPrn:Line(li-14,1390,li+33,1390)
		oPrn:Say(li,1400,ALLTRIM(ZZK->ZZK_ENDA),oFont13,100)
		oPrn:Line(li-14,1705,li+33,1705)
		oPrn:Line(li-14,1710,li+33,1710)
		oPrn:Say(li,1720,ALLTRIM(ZZK->ZZK_ENDB),oFont13,100)
		oPrn:Line(li-14,2010,li+33,2010)
		oPrn:Line(li-14,2015,li+33,2015)
		oPrn:Say(li-14,2030,"<                >",oFont6,100)
		oPrn:Line(li+35,0010,li+35,2530)
		li += 50
		nQuantos++
		IF nQuantos > 55 .or. li >3099 
			_Rodape()
			_Cabec(_wLocP,_wDoc)
			oPrn:Say(0110,1070,ALLTRIM(_xDoc),oFont9,,,,3)
			oPrn:Say(0110,2060,alltrim(_xArm),oFont9,,,,3)
			oPrn:Line(li-40,0010,li-40,2530)
			oPrn:Line(li-30,0010,li-30,2530)
			li  := 320
			oPrn:Say(li-20,0010,"Endereço: "+ALLTRIM(ZZK->ZZK_LOCALI),oFont6,100)
			oPrn:Line(li+36,0010,li+36,2530)
			li+=50
			nQuantos := 0
		ENDIF
		dbSkip()
	EndDo
    li+=35
	IF nQuantos > 55 .or. li >3099
		_Rodape()
		_Cabec(_wLocP,_wDoc)
		oPrn:Say(0110,1070,ALLTRIM(_xDoc),oFont9,,,,3)
		oPrn:Say(0110,2060,alltrim(_xArm),oFont9,,,,3)
		li  := 320
		oPrn:Line(li-40,0010,li-40,2530)
		oPrn:Line(li-30,0010,li-30,2530)
		oPrn:Say(li-20,0010,"Endereço: "+ALLTRIM(ZZK->ZZK_LOCALI),oFont6,100)
		oPrn:Line(li+36,0010,li+36,2530)
		li+=50
		nQuantos := 0
	ENDIF
ENDDO         
    
_Rodape()

Return(.T.)

*************************************************************

STATIC FUNCTION _Cabec(_wLocP,_wDoc)
mPag := mPag + 1
oPrn:StartPage()
oPrn:Say(0,0,"",,,,,3)

oPrn:Say(0025,0010,"Hora: "+LEFT(TIME(),5),oFont12,,,,3)
oPrn:Say(0008,0630,"CAMBUCI METALURGICA LTDA",oFont3,,,,3)
oPrn:Say(0025,2050,"Data: "+DTOC(ddatabase),oFont12,,,,3)
oPrn:Line(0080,0010,0080,2530)
oPrn:Line(0090,0010,0090,2530)

oPrn:Say(0110,0010,"Contagem de Balanço",oFont9,,,,3)
oPrn:Say(0110,0810,"Documento:",oFont9,,,,3)
oPrn:Say(0110,1070,ALLTRIM(_wDoc),oFont9,,,,3)
oPrn:Say(0110,1810,"Armazem:",oFont9,,,,3) 
oPrn:Say(0110,2060,alltrim(_wLocP),oFont9,,,,3)

oPrn:Line(0180,0010,0180,2530)
oPrn:Line(0190,0010,0190,2530)

oPrn:Say(0205,0010,"Descrição",oFont9,,,,3)
oPrn:Line(0192,1004,0280,1004)
oPrn:Line(0192,1010,0280,1010)
oPrn:Say(0205,1020,"Produto",oFont9,,,,3)

IF _wLocP == "01"
	oPrn:Line(0192,1385,0280,1385)
	oPrn:Line(0192,1390,0280,1390)
	oPrn:Say(0200,1405,"Armazem 02",oFont9,,,,3)
	oPrn:Line(0192,1705,0280,1705)
	oPrn:Line(0192,1710,0280,1710)
	oPrn:Say(0200,1725,"Armazem 03 ",oFont9,,,,3)
ELSEIF _wLocP == "02"            
	oPrn:Line(0192,1385,0280,1385)
	oPrn:Line(0192,1390,0280,1390)
	oPrn:Say(0200,1405,"Armazem 01",oFont9,,,,3)
	oPrn:Line(0192,1705,0280,1705)
	oPrn:Line(0192,1710,0280,1710)
	oPrn:Say(0200,1725,"Armazem 03",oFont9,,,,3)
ELSEIF _wLocP == "03"            
	oPrn:Line(0192,1385,0280,1385)
	oPrn:Line(0192,1390,0280,1390)
	oPrn:Say(0200,1405,"Armazem 01",oFont9,,,,3)
	oPrn:Line(0192,1705,0280,1705)
	oPrn:Line(0192,1710,0280,1710)
	oPrn:Say(0200,1725,"Armazem 02",oFont9,,,,3)
ENDIF                            

oPrn:Line(0192,2010,0280,2010)
oPrn:Line(0192,2015,0280,2015)
oPrn:Say(0200,2030,"Qtd.Contagem",oFont9,,,,3)

li := 320

RETURN

************************************************************************************

STATIC FUNCTION _Rodape

oPrn:Line(3250,0010,3250,2530)
oPrn:Say(3260,0010,"Cambuci Metalurgica Ltda",oFont12,,,,3)
oPrn:Say(3260,2050,"Folha: "+TRANSFORM(mPag,"@E 99"),oFont12,,,,3)
oPrn:Line(3310,0010,3310,2530)
oPrn:EndPage()

RETURN

**********************************************************************************

STATIC FUNCTION ZKEXCLUI()

LOCAL _aAREA := GETAREA()
PRIVATE cDoc := space(9)
PRIVATE cLocP := space(2)
Private cPerg:='BLQINV'

AjusSX1B(cPerg)

If !Pergunte(cPerg,.T.)
   Return
End   
    
cDoc := MV_PAR01
cLocP := MV_PAR02   

DBSELECTAREA("ZZK")
DBSETORDER(5)
DBGOTOP()
ProcRegua(RECCOUNT())
DBSEEK(xFilial()+cLocp+cDoc)

IF FOUND()
	IF ZZK->ZZK_FLAG == "S"
		ALERT("Exclusão não permitida, documento Bloqueado, Desbloqueie o documento para excluir !!!")
		RESTAREA(_aAREA)
    	RETURN
	ELSEIF ZZK->ZZK_FLAG == "I" .OR. ZZK->ZZK_FLAG == "K"
		ALERT("Exclusão não permitida, inventário já lançado !!!")
		RESTAREA(_aAREA)	
	ENDIF

	IF MSGYESNO("Confirma Exclusão do Documento "+cDoc+" Armazem "+cLocP+" ?")

		DO WHILE !EOF() .AND. ZZK->ZZK_FILIAL+ZZK->ZZK_LOCAL+ZZK->ZZK_DOC == xFilial()+cLocp+cDoc
			ZZK->(RECLOCK("ZZK",.F.))
			DBDELETE()
			ZZK->(MSUNLOCK())
			DBSKIP()
			IncProc()
		ENDDO

	ENDIF

ELSE
	MSGALERT("Docucmento: "+alltrim(cDoc)+" Armazem: "+cLocP+" não encontrado !!!")
	RESTAREA(_aAREA)
	RETURN
ENDIF

MSGALERT("Docucmento: "+alltrim(cDoc)+" Armazem: "+cLocP+" Excluido com Sucesso !!!")

RESTAREA(_aAREA)

RETURN                                    

***************************************************************************

static Function DelLinOk(N)
                  
Local lDel := .T.

IF aCols[N,Len(aHeader)+1] <> .F.
	MSGALERT("EXCLUSÃO NÃO PERMITIDA, RECUPERE O ITEM PARA CONTINUAR !!")
	lDel := .F.
ENDIF

RETURN(lDel)

**************************************************************************** 

Static Function REQTDE()

Public oPrn
Public cString := "ZZK"            
Public li      := 0
Public _wDoc    := space(9)
Public _wLocp   := space(2)
Public mPag      := 0
Private cPerg:='BLQINV'

AjusSX1B(cPerg)

If !Pergunte(cPerg,.T.)
   Return
End   
    
_wDoc  := MV_PAR01
_wLocP := MV_PAR02   

oFont1  :=    TFont():New("Arial Black"     ,09,12,,.T.,,,,,.F.)
oFont2  :=    TFont():New("Arial"           ,09,12,,.F.,,,,,.F.)
oFont3  :=    TFont():New("Arial Black"		,09,16,,.T.,,,,,.F.)
oFont4  := 	  TFont():New("Arial"      		,09,12,,.T.,,,,,.F.)
oFont5  := 	  TFont():New("Arial"      		,09,18,,.T.,,,,,.F.)
oFont6  := 	  TFont():New("Arial"      	    ,09,11,,.T.,,,,,.F.)
oFont7  := 	  TFont():New("Arial"           ,09,08,,.T.,,,,,.F.) 
oFont8  := 	  TFont():New("Arial"           ,09,09,,.F.,,,,,.F.)
oFont9  := 	  TFont():New("Times New Roman" ,08,11,,.T.,,,,,.F.)
oFont10 :=    TFont():New("Arial"           ,09,09,,.F.,,,,,.F.)    
oFont11 := 	  TFont():New("Arial"           ,09,07,,.F.,,,,,.F.)  
oFont12 := 	  TFont():New("Arial"           ,09,10,,.T.,,,,,.F.)
oFont13 := 	  TFont():New("Arial"           ,09,08,,.F.,,,,,.F.)
oFont14 := 	  TFont():New("Arial"           ,09,09,,.T.,,,,,.F.)

dbSelectArea(cString)
dbSetOrder(3) //FILIAL+LOCAL+DOCUMENTO+ENDEREÇO+DESC
DBGOTOP()
dbSeek(xFilial()+_wLocp+_wDoc)
IF !FOUND()
	MSGALERT("Docucmento: "+alltrim(_wDoc)+" Armazem: "+_wLocP+" não encontrado !!!")
    return
ELSE
	IF ZZK->ZZK_FLAG == "N"   	
   		MSGALERT("Não esqueça de bloquear o Docucmento: "+alltrim(_wDoc)+" Armazem: "+_wLocP+" para iniciar o inventário !!!")
	ENDIF
ENDIF

oPrn:=TMSPrinter():New()
oPrn:SetLANDSCAPE()  //PAISAGEM
oPrn:SetPage(9) //A4
oprn:setup()
oprn:startpage()

PROCESSA({|| IMPDETQ()})

oprn:endpage()
oprn:PREVIEW()
oprn:end()


Return(.T.)

****************************************************************************

Static Function IMPDETQ()

Local _QCTB  := 0
Local _QEMP  := 0
Local _QDIS  := 0
Local _QCTBA := 0
Local _QCTBB := 0
Local _TQCTB := 0

nQuantos := 0
_CabecQ(_wLocP,_wDoc)

While !Eof() .And. ZZK->ZZK_FILIAL+ZZK->ZZK_LOCAL+ZZK->ZZK_DOC == xFilial()+_wLocp+_wDoc
	_xEnd := ZZK->ZZK_LOCALI
	_xDoc := ZZK->ZZK_DOC
	_xArm := ZZK->ZZK_LOCAL
	_xFil := ZZK->ZZK_FILIAL
	oPrn:Line(li-40,0010,li-40,3400)
	oPrn:Line(li-30,0010,li-30,3400)
	oPrn:Say(li-20,0010,"Endereço: "+ALLTRIM(ZZK->ZZK_LOCALI),oFont6,100)
	oPrn:Line(li+36,0010,li+36,3400)
	li+=50
	While !EOF() .and. ZZK->ZZK_FILIAL+ZZK->ZZK_LOCAL+ZZK->ZZK_DOC+ZZK->ZZK_LOCALI == _xFil+_xArm+_xDoc+_xEnd
		oPrn:Say(li,0010,substr(ALLTRIM(ZZK->ZZK_DESC),1,45),oFont13,100)
		oPrn:Line(li-14,1004,li+33,1004)
		oPrn:Line(li-14,1010,li+33,1010)
		oPrn:Say(li-8,1020,ALLTRIM(ZZK->ZZK_COD),oFont14,100)
		
		_QCTB := Posicione("SBF",1,xFilial("SBF")+_xArm+_xEnd+zzk->zzk_cod,"BF_QUANT")
		_QEMP := Posicione("SBF",1,xFilial("SBF")+_xArm+_xEnd+zzk->zzk_cod,"BF_EMPENHO")
		_QDIS := _QCTB - _QEMP
		
		oPrn:Line(li-14,1370,li+33,1370)
		oPrn:Line(li-14,1375,li+33,1375)		
		oPrn:Say(li-8,1405,TRANSFORM(_QCTB,"@E 9999"),oFont10,,,,3)  //qt.ctb      

		oPrn:Line(li-14,1505,li+33,1505)
		oPrn:Line(li-14,1510,li+33,1510)
		oPrn:Say(li-8,1555,TRANSFORM(_QEMP,"@E 9999"),oFont10,,,,3) //qt.emp

		oPrn:Line(li-14,1660,li+33,1660)
		oPrn:Line(li-14,1665,li+33,1665)
		oPrn:Say(li-8,1690,TRANSFORM((_QCTB-_QEMP),"@E 9999"),oFont10,,,,3) //qt.dis
		
		IF _xArm == "01
			_QCTBA := Posicione("SBF",1,xFilial("SBF")+"02"+zzk->zzk_enda+zzk->zzk_cod,"BF_QUANT")
			_QCTBB := Posicione("SBF",1,xFilial("SBF")+"03"+zzk->zzk_endb+zzk->zzk_cod,"BF_QUANT")
		ELSEIF _xArm == "02
			_QCTBA := Posicione("SBF",1,xFilial("SBF")+"01"+zzk->zzk_enda+zzk->zzk_cod,"BF_QUANT")
			_QCTBB := Posicione("SBF",1,xFilial("SBF")+"03"+zzk->zzk_endb+zzk->zzk_cod,"BF_QUANT")
		ELSEIF _xArm == "03
			_QCTBA := Posicione("SBF",1,xFilial("SBF")+"01"+zzk->zzk_enda+zzk->zzk_cod,"BF_QUANT")
			_QCTBB := Posicione("SBF",1,xFilial("SBF")+"02"+zzk->zzk_endb+zzk->zzk_cod,"BF_QUANT")
		ENDIF
		
		_TQCTB := _TQCTB + _QCTB + _QCTBA + _QCTBB
		_TQEMP := _QEMP
		_TQDIS := _TQCTB - _TQEMP
		
		oPrn:Line(li-14,1785,li+33,1785)
		oPrn:Line(li-14,1790,li+33,1790)
		oPrn:Say(li-8,1800,ALLTRIM(ZZK->ZZK_ENDA),oFont13,100)
		
		oPrn:Line(li-14,2060,li+33,2060)
		oPrn:Line(li-14,2065,li+33,2065)
		oPrn:Say(li-8,2100,TRANSFORM(_QCTBA,"@E 9999"),oFont10,,,,3)  //qt enda

		oPrn:Line(li-14,2195,li+33,2195)
		oPrn:Line(li-14,2200,li+33,2200)
		oPrn:Say(li-8,2215,ALLTRIM(ZZK->ZZK_ENDB),oFont13,100)

		oPrn:Line(li-14,2475,li+33,2475)
		oPrn:Line(li-14,2480,li+33,2480)
		oPrn:Say(li-8,2515,TRANSFORM(_QCTBB,"@E 9999"),oFont10,,,,3)  //qt end b

		oPrn:Line(li-14,2615,li+33,2615)
		oPrn:Line(li-14,2620,li+33,2620)
		oPrn:Line(li-14,2625,li+33,2625)
		oPrn:Line(li-14,2630,li+33,2630)
		oPrn:Say(li-8,2690,TRANSFORM(_TQCTB,"@E 9999"),oFont10,,,,3) //tot ctb
        
		oPrn:Line(li-14,2775,li+33,2775)
		oPrn:Line(li-14,2780,li+33,2780)
		oPrn:Line(li-14,2785,li+33,2785)
		oPrn:Line(li-14,2790,li+33,2790)
		oPrn:Say(li-8,2855,TRANSFORM(_TQEMP,"@E 9999"),oFont10,,,,3) //tot emp
		                                
   		oPrn:Line(li-14,2955,li+33,2955)
		oPrn:Line(li-14,2960,li+33,2960)
		oPrn:Line(li-14,2965,li+33,2965)
		oPrn:Line(li-14,2970,li+33,2970)
		oPrn:Say(li-8,3025,TRANSFORM(_TQDIS,"@E 9999"),oFont10,,,,3) //tot disp
                                         
		oPrn:Line(li-14,3100,li+33,3100)
		oPrn:Line(li-14,3105,li+33,3105)
		oPrn:Line(li-14,3110,li+33,3110)
		oPrn:Line(li-14,3115,li+33,3115)
		oPrn:Say(li-14,3150,"<                >",oFont6,100)
		oPrn:Line(li+35,0010,li+35,3400)
		li += 50
		nQuantos++
		IF nQuantos > 32 .or. li > 2150 
			_RodapeQ()                                             
			_CabecQ(_wLocP,_wDoc)
			oPrn:Say(0110,1520,ALLTRIM(_xDoc),oFont9,,,,3)
			oPrn:Say(0110,3110,alltrim(_xArm),oFont9,,,,3)
			oPrn:Line(li-40,0010,li-40,3400)
			oPrn:Line(li-30,0010,li-30,3400)
			li  := 310
			oPrn:Say(li-20,0010,"Endereço: "+ALLTRIM(ZZK->ZZK_LOCALI),oFont6,100)
			oPrn:Line(li+36,0010,li+36,3400)
			li+=50
			nQuantos := 0
		ENDIF		
		dbSkip()
		_QCTB  := 0
		_QEMP  := 0
		_QDIS  := 0
		_QCTBA := 0
		_QCTBB := 0
		_TQCTB := 0
	EndDo
    li+=35
	IF nQuantos > 32 .or. li > 2150
		_RodapeQ()
		_CabecQ(_wLocP,_wDoc)
		oPrn:Say(0110,1520,ALLTRIM(_xDoc),oFont9,,,,3)
		oPrn:Say(0110,3110,alltrim(_xArm),oFont9,,,,3)
		li  := 310
		oPrn:Line(li-40,0010,li-40,3400)
		oPrn:Line(li-30,0010,li-30,3400)
		oPrn:Say(li-20,0010,"Endereço: "+ALLTRIM(ZZK->ZZK_LOCALI),oFont6,100)
		oPrn:Line(li+36,0010,li+36,3400)
		li+=50
		nQuantos := 0
	ENDIF
ENDDO         
    
_RodapeQ()

Return(.T.)

*************************************************************

STATIC FUNCTION _CabecQ(_wLocP,_wDoc)
mPag := mPag + 1
oPrn:StartPage()
oPrn:Say(0,0,"",,,,,3)

oPrn:Say(0025,0010,"Hora: "+LEFT(TIME(),5),oFont12,,,,3)
oPrn:Say(0008,1165,"CAMBUCI METALURGICA LTDA",oFont3,,,,3)
oPrn:Say(0025,3100,"Data: "+DTOC(ddatabase),oFont12,,,,3)
oPrn:Line(0080,0010,0080,3400)
oPrn:Line(0090,0010,0090,3400)

oPrn:Say(0110,0010,"Contagem de Balanço",oFont9,,,,3)
oPrn:Say(0110,1260,"Documento:",oFont9,,,,3)
oPrn:Say(0110,1520,ALLTRIM(_wDoc),oFont9,,,,3)
oPrn:Say(0110,2910,"Armazem:",oFont9,,,,3) 
oPrn:Say(0110,3110,alltrim(_wLocP),oFont9,,,,3)

oPrn:Line(0180,0010,0180,3400)
oPrn:Line(0190,0010,0190,3400)

oPrn:Say(0205,0010,"Descrição",oFont9,,,,3)
oPrn:Line(0192,1004,0270,1004)
oPrn:Line(0192,1010,0270,1010)
oPrn:Say(0205,1020,"Produto",oFont9,,,,3)

oPrn:Line(0192,1370,0270,1370)
oPrn:Line(0192,1375,0270,1375)
oPrn:Say(0200,1380,"Qt.Ctb",oFont9,,,,3)

oPrn:Line(0192,1505,0270,1505)
oPrn:Line(0192,1510,0270,1510)
oPrn:Say(0200,1515,"Qt.Emp",oFont9,,,,3)

oPrn:Line(0192,1660,0270,1660)
oPrn:Line(0192,1665,0270,1665)
oPrn:Say(0200,1670,"Qt.Dis",oFont9,,,,3)


IF _wLocP == "01"
	oPrn:Line(0192,1785,0270,1785)
	oPrn:Line(0192,1790,0270,1790)
	oPrn:Say(0200,1820,"Armazem 02",oFont9,,,,3)
	
	oPrn:Line(0192,2060,0270,2060)
	oPrn:Line(0192,2065,0270,2065)
	oPrn:Say(0200,2070,"Qt.Ctb",oFont9,,,,3)
	
	oPrn:Line(0192,2195,0270,2195)
	oPrn:Line(0192,2200,0270,2200)
	oPrn:Say(0200,2225,"Armazem 03 ",oFont9,,,,3) 
	
	oPrn:Line(0192,2475,0270,2475)
	oPrn:Line(0192,2480,0270,2480)
	oPrn:Say(0200,2485,"Qt.Ctb",oFont9,,,,3)
	

ELSEIF _wLocP == "02"            
	oPrn:Line(0192,1785,0270,1785)
	oPrn:Line(0192,1790,0270,1790)
	oPrn:Say(0200,1820,"Armazem 01",oFont9,,,,3)
	
	oPrn:Line(0192,2060,0270,2060)
	oPrn:Line(0192,2065,0270,2065)
	oPrn:Say(0200,2070,"Qt.Ctb",oFont9,,,,3)
	
	oPrn:Line(0192,2195,0270,2195)
	oPrn:Line(0192,2200,0270,2200)
	oPrn:Say(0200,2225,"Armazem 03 ",oFont9,,,,3) 
	
	oPrn:Line(0192,2475,0270,2475)
	oPrn:Line(0192,2480,0270,2480)
	oPrn:Say(0200,2485,"Qt.Ctb",oFont9,,,,3)

ELSEIF _wLocP == "03"            
	oPrn:Line(0192,1785,0270,1785)
	oPrn:Line(0192,1790,0270,1790)
	oPrn:Say(0200,1820,"Armazem 01",oFont9,,,,3)
	
	oPrn:Line(0192,2060,0270,2060)
	oPrn:Line(0192,2065,0270,2065)
	oPrn:Say(0200,2070,"Qt.Ctb",oFont9,,,,3)
	
	oPrn:Line(0192,2195,0270,2195)
	oPrn:Line(0192,2200,0270,2200)
	oPrn:Say(0200,2225,"Armazem 02 ",oFont9,,,,3) 
	
	oPrn:Line(0192,2475,0270,2475)
	oPrn:Line(0192,2480,0270,2480)
	oPrn:Say(0200,2485,"Qt.Ctb",oFont9,,,,3)

ENDIF                            

oPrn:Line(0192,2615,0270,2615)
oPrn:Line(0192,2620,0270,2620)
oPrn:Line(0192,2625,0270,2625)
oPrn:Line(0192,2630,0270,2630)
oPrn:Say(0200,2635,"Tot.Ctb",oFont9,,,,3)
                              
oPrn:Line(0192,2775,0270,2775)
oPrn:Line(0192,2780,0270,2780)
oPrn:Line(0192,2785,0270,2785)
oPrn:Line(0192,2790,0270,2790)
oPrn:Say(0200,2795,"Tot.Emp",oFont9,,,,3)
                              
oPrn:Line(0192,2955,0270,2955)
oPrn:Line(0192,2960,0270,2960)
oPrn:Line(0192,2965,0270,2965)
oPrn:Line(0192,2970,0270,2970)
oPrn:Say(0200,2975,"Tot.Dis",oFont9,,,,3)

oPrn:Line(0192,3100,0270,3100)
oPrn:Line(0192,3105,0270,3105)
oPrn:Line(0192,3110,0270,3110)
oPrn:Line(0192,3115,0270,3115)
oPrn:Say(0200,3125,"Qtd.Contagem",oFont9,,,,3)

li := 310

RETURN

************************************************************************************

STATIC FUNCTION _RodapeQ

oPrn:Line(2250,0010,2250,3400)
oPrn:Say(2260,0010,"Cambuci Metalurgica Ltda",oFont12,,,,3)
oPrn:Say(2260,3130,"Folha: "+TRANSFORM(mPag,"@E 99"),oFont12,,,,3)
oPrn:Line(2310,0010,2310,3400)
oPrn:EndPage()

RETURN

**********************************************************************************

Static Function AjustaSx1 (cPerg)

Local _ABrea := GetArea()
Local _aRegs := {}

_sAlias := Alias()
dbSelectArea("SX1")
SX1->(dbSetOrder(1))
_cPerg := padr(cPerg,len(SX1->X1_GRUPO))

Aadd(_aRegs,{_cPerg,"01","Endereço  De ?","mv_ch1","C",15,0,"G",""        ,"mv_par01","SBE","","","","",""})
Aadd(_aRegs,{_cPerg,"02","Endereço Ate ?","mv_ch2","C",15,0,"G","NAOVAZIO","mv_par02","SBE","","","","",""})
Aadd(_aRegs,{_cPerg,"03","Armazem ?","mv_ch3","C", 2,0,"G","NAOVAZIO","mv_par03","NNR","","","","",""})

DbSelectArea("SX1")
SX1->(DbSetOrder(1))

For i := 1 To Len(_aRegs)
	IF  !DbSeek(_aRegs[i,1]+_aRegs[i,2])
		RecLock("SX1",.T.)
		Replace X1_GRUPO   with _aRegs[i,01]
		Replace X1_ORDEM   with _aRegs[i,02]
		
		Replace X1_PERGUNT with alltrim(_aRegs[i,03])
		Replace X1_PERSPA  with alltrim(_aRegs[i,03])
		Replace X1_PERENG  with alltrim(_aRegs[i,03])
		
		Replace X1_VARIAVL 	with _aRegs[i,04]
		Replace X1_TIPO     with _aRegs[i,05]
		Replace X1_TAMANHO 	with _aRegs[i,06]
		Replace X1_DECIMAL  with _aRegs[i,07]
		Replace X1_GSC    	with _aRegs[i,08]
		Replace X1_VALID   	with _aRegs[i,09]
		Replace X1_VAR01   	with _aRegs[i,10]
		Replace X1_F3     	with _aRegs[i,11]
		Replace X1_DEF01   	with _aRegs[i,12]
		Replace X1_DEF02   	with _aRegs[i,13]
		Replace X1_DEF03   	with _aRegs[i,14]
		Replace X1_DEF04   	with _aRegs[i,15]
		Replace X1_DEF05   	with _aRegs[i,16]
		MsUnlock()
	EndIF
Next i

RestArea(_ABrea)

Return

****************************************************************************

Static Function AjusSx1A(cPerg)

Local _ABrea := GetArea()
Local _aRegs := {}

_sAlias := Alias()
dbSelectArea("SX1")
SX1->(dbSetOrder(1))
_cPerg := padr(cPerg,len(SX1->X1_GRUPO))

Aadd(_aRegs,{_cPerg,"01","No.Documento ?","mv_ch1","C",9,0,"G","NAOVAZIO","mv_par01","","","","","",""})
Aadd(_aRegs,{_cPerg,"02","Armazem ?","mv_ch2","C",2,0,"G","NAOVAZIO","mv_par02","NNR","","","","",""})
Aadd(_aRegs,{_cPerg,"03","Dias de Bloqueio ?","mv_ch3","N",2,0,"G","","mv_par03","","","","","",""})

DbSelectArea("SX1")
SX1->(DbSetOrder(1))

For i := 1 To Len(_aRegs)
	IF  !DbSeek(_aRegs[i,1]+_aRegs[i,2])
		RecLock("SX1",.T.)
		Replace X1_GRUPO   with _aRegs[i,01]
		Replace X1_ORDEM   with _aRegs[i,02]
		
		Replace X1_PERGUNT with alltrim(_aRegs[i,03])
		Replace X1_PERSPA  with alltrim(_aRegs[i,03])
		Replace X1_PERENG  with alltrim(_aRegs[i,03])
		
		Replace X1_VARIAVL 	with _aRegs[i,04]
		Replace X1_TIPO     with _aRegs[i,05]
		Replace X1_TAMANHO 	with _aRegs[i,06]
		Replace X1_DECIMAL  with _aRegs[i,07]
		Replace X1_GSC    	with _aRegs[i,08]
		Replace X1_VALID   	with _aRegs[i,09]
		Replace X1_VAR01   	with _aRegs[i,10]
		Replace X1_F3     	with _aRegs[i,11]
		Replace X1_DEF01   	with _aRegs[i,12]
		Replace X1_DEF02   	with _aRegs[i,13]
		Replace X1_DEF03   	with _aRegs[i,14]
		Replace X1_DEF04   	with _aRegs[i,15]
		Replace X1_DEF05   	with _aRegs[i,16]
		MsUnlock()
	EndIF
Next i

RestArea(_ABrea)

Return

****************************************************************************

Static Function AjusSx1B(cPerg)

Local _ABrea := GetArea()
Local _aRegs := {}

_sAlias := Alias()
dbSelectArea("SX1")
SX1->(dbSetOrder(1))
_cPerg := padr(cPerg,len(SX1->X1_GRUPO))

Aadd(_aRegs,{_cPerg,"01","No.Documento ?","mv_ch1","C",9,0,"G","NAOVAZIO","mv_par01","","","","","",""})
Aadd(_aRegs,{_cPerg,"02","Armazem ?","mv_ch2","C",2,0,"G","NAOVAZIO","mv_par02","NNR","","","","",""})

DbSelectArea("SX1")
SX1->(DbSetOrder(1))

For i := 1 To Len(_aRegs)
	IF  !DbSeek(_aRegs[i,1]+_aRegs[i,2])
		RecLock("SX1",.T.)
		Replace X1_GRUPO   with _aRegs[i,01]
		Replace X1_ORDEM   with _aRegs[i,02]
		
		Replace X1_PERGUNT with alltrim(_aRegs[i,03])
		Replace X1_PERSPA  with alltrim(_aRegs[i,03])
		Replace X1_PERENG  with alltrim(_aRegs[i,03])
		
		Replace X1_VARIAVL 	with _aRegs[i,04]
		Replace X1_TIPO     with _aRegs[i,05]
		Replace X1_TAMANHO 	with _aRegs[i,06]
		Replace X1_DECIMAL  with _aRegs[i,07]
		Replace X1_GSC    	with _aRegs[i,08]
		Replace X1_VALID   	with _aRegs[i,09]
		Replace X1_VAR01   	with _aRegs[i,10]
		Replace X1_F3     	with _aRegs[i,11]
		Replace X1_DEF01   	with _aRegs[i,12]
		Replace X1_DEF02   	with _aRegs[i,13]
		Replace X1_DEF03   	with _aRegs[i,14]
		Replace X1_DEF04   	with _aRegs[i,15]
		Replace X1_DEF05   	with _aRegs[i,16]
		MsUnlock()
	EndIF
Next i

RestArea(_ABrea)

Return

****************************************************************************