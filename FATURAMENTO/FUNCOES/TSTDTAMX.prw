#include 'protheus.ch'
#include 'parmtype.ch'

user function TSTDTAMX()

	Local nX := 0
	Local cPorta := "LPT1"
	Local cModelo := "DMX"
	Local nLin := 0

	/*
	configuracoes mais utilizadas de porta
	cPorta := “COM2:9600,n,8,1”
	cPorta := “COM2:9600,n,8,2”
	cPorta := “COM2:9600,n,7,1”
	cPorta := “COM2:9600,n,7,2”
	cPorta := “COM2:9600,e,8,1”
	cPorta := “COM2:9600,e,8,2”
	cPorta := “COM2:9600,e,7,1”
	cPorta := “COM2:9600,e,7,2”
	cPorta := “LPT1”
	*/

	MSCBPRINTER(cModelo, cPorta, , 156.5, .F.)
	MSCBCHKStatus(.F.)
	MSCBLOADGRF("c:\logo\DANFE010102.pcx")
	
	MSCBBEGIN(1,6)
	
	MSCBSAY(10, 10, "DJALMA", "B", "5", "20")
	
	MSCBGRAFIC(50,50,"DANFE010102")                   
	
	/*
	For nx:=1 to 3
		
			MSCBSAY(10,06,"CODIGO","N","A","015,008")
			
			MSCBSAY(33,09, Strzero(nX,10), "N", "0", "032,035")
			
			MSCBSAY(05,17,"IMPRESSORA DATAMAX","N", "0", "020,030")
		
	Next*/
	
	ALERT("ANTES DO MSCBEND()")
	
	MSCBEND()
	
	ALERT("DEPOIS DO MSCBEND()")
	
	MSCBCLOSEPRINTER()
	
return