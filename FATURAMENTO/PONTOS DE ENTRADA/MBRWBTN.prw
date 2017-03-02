#include 'rwmake.ch'
#include 'protheus.ch'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � MBRWBTN  � Autor �Walter Caetano da Silva� Data �04/10/2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de Entrada para controlar um botao pressionado na    ���
���          � MBROWSE. Sera acessado em qualquer programa que utilize    ���
���          � esta funcao.                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Enviado ao Ponto de Entrada um vetor com 3 informacoes:    ���
���          � PARAMIXB[1] = Alias atual;                                 ���
���          � PARAMIXB[2] = Registro atual;                              ���
���          � PARAMIXB[3] = Numero da opcao selecionada                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Se retornar .T. executa a funcao relacionada ao botao.     ���
�������������������������������������������������������������������������Ĵ��
���Obs.:     � Utilizar somente na 4.07. Na 2.07 nao executa este PE.     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MBRWBTN()                         

Local _cUser := AllTrim(UsrFullName(RetCodUsr()))
Local _lRet := .T.
Local _dDate := ''
Local _cCodUsr  := RetCodUsr()
Local _cUserOk	:= SUPERGETMV("CB_USERPED",, "000023") 

If !_cCodUsr $ _cUserOk
	If FUNNAME() == "MATA410"  //Pedido de Venda
	
	   If PARAMIXB[4] == "MA410PVNFS"    //Selecionado rotina de prepara��o de documento de saida
	  
	      ALERT("Prezado usu�rio "+_cUser+" contate o respons�vel para libera��o deste pedido.")
	  
	      _lRet := .F.
	  
	   EndIf
	
	   If PARAMIXB[4] == "A410PCOPIA"    //Inibi��o do bot�o c�pia
	  
	      ALERT("Prezado usu�rio "+_cUser+" esta fun��o n�o est� disponivel.")
	  
	      _lRet := .F.
	  
	  Endif   
	
	Endif 
EndIf
  
Return _lRet