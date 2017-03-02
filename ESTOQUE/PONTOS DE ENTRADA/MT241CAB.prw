#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MT241CAB ³ Autor ³ Raphael F. Araújo 	  ³ Data ³ 19.12.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Ponto de Entrada p/ incluir campo no cabecalho da         ³±±
±±³ Movimentação Interna ( Multipla )		              			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
/*/

User Function MT241CAB()

	Local oNewDialog	:= PARAMIXB[1]
	Public _aObs 		:= Array(1,2)
	
	_aObs[1][1] := "D3_XOBS"
	
	If PARAMIXB[2] == 3
	
        _aObs[1][2] := SPACE(60)
        @2.9,46.6 SAY "Observacao" OF oNewDialog
        @2.8,50.5 MSGET oOBs Var _aObs[1][2] SIZE 240,08 OF oNewDialog
        oOBs:bLostFocus :={|| FocusObs() }//RunTrigger(2,Len(aCols),,"D3_XOBS")}
       
	EndIf
	
return(_aObs[1][2])

/*****************************************
 Raphael Araújo - Global 
 FUNÇÃO CHAMADA NO GATILHO DO CAMPO D3_COD
******************************************/
User Function GatiObs()
	
	Local nPosObs 	:= GdFieldPos("D3_XOBS") //aScan(aHeader,{|x| Alltrim(x[2]) == "D3_XOBS"})
	Local nPosCod 	:= GdFieldPos("D3_COD") //ascan(aHeader,{|x| Alltrim(x[2]) == 'D3_COD'})
	
	If !empty(aCols[n][nPosCod])

		aCols[n][nPosObs] 	:= Alltrim(_aObs[1][2])
		GETDREFRESH()
   
	Endif
	
Return(_aObs[1][2])


/************************************************************
 Raphael Araújo - Global 21/12/2016
 FUNÇÃO CHAMADA NO LOSTFOCUS DO CAMPO OBSERVAÇÃO DO CABEÇALHO
*************************************************************/
Static Function FocusObs()
	
	Local nX 		:= 0
	Local nPosObs 	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D3_XOBS"})
	Local nPosCod 	:= ascan(aHeader,{|x| Alltrim(x[2]) == 'D3_COD'})
	
	For nX := 1 To Len(aCols) 
		If !empty(aCols[nX][nPosCod])
	
			aCols[nX][nPosObs] 	:= Alltrim(_aObs[1][2])
			GETDREFRESH()
		Endif
	Next nX	
	
Return(_aObs[1][2])
