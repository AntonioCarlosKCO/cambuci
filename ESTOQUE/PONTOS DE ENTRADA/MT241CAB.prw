#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MT241CAB � Autor � Raphael F. Ara�jo 	  � Data � 19.12.2016 ���
�������������������������������������������������������������������������Ĵ��
��� Descricao � Ponto de Entrada p/ incluir campo no cabecalho da         ���
��� Movimenta��o Interna ( Multipla )		              			      ���
�������������������������������������������������������������������������Ĵ��
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
 Raphael Ara�jo - Global 
 FUN��O CHAMADA NO GATILHO DO CAMPO D3_COD
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
 Raphael Ara�jo - Global 21/12/2016
 FUN��O CHAMADA NO LOSTFOCUS DO CAMPO OBSERVA��O DO CABE�ALHO
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
