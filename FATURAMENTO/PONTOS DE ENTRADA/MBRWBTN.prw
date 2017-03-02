#include 'rwmake.ch'
#include 'protheus.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MBRWBTN  ³ Autor ³Walter Caetano da Silva³ Data ³04/10/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Ponto de Entrada para controlar um botao pressionado na    ³±±
±±³          ³ MBROWSE. Sera acessado em qualquer programa que utilize    ³±±
±±³          ³ esta funcao.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Enviado ao Ponto de Entrada um vetor com 3 informacoes:    ³±±
±±³          ³ PARAMIXB[1] = Alias atual;                                 ³±±
±±³          ³ PARAMIXB[2] = Registro atual;                              ³±±
±±³          ³ PARAMIXB[3] = Numero da opcao selecionada                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Se retornar .T. executa a funcao relacionada ao botao.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs.:     ³ Utilizar somente na 4.07. Na 2.07 nao executa este PE.     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MBRWBTN()                         

Local _cUser := AllTrim(UsrFullName(RetCodUsr()))
Local _lRet := .T.
Local _dDate := ''
Local _cCodUsr  := RetCodUsr()
Local _cUserOk	:= SUPERGETMV("CB_USERPED",, "000023") 

If !_cCodUsr $ _cUserOk
	If FUNNAME() == "MATA410"  //Pedido de Venda
	
	   If PARAMIXB[4] == "MA410PVNFS"    //Selecionado rotina de preparação de documento de saida
	  
	      ALERT("Prezado usuário "+_cUser+" contate o responsável para liberação deste pedido.")
	  
	      _lRet := .F.
	  
	   EndIf
	
	   If PARAMIXB[4] == "A410PCOPIA"    //Inibição do botão cópia
	  
	      ALERT("Prezado usuário "+_cUser+" esta função não está disponivel.")
	  
	      _lRet := .F.
	  
	  Endif   
	
	Endif 
EndIf
  
Return _lRet