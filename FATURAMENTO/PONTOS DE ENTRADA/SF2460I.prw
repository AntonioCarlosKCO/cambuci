#INCLUDE 'RWMAKE.CH'

User Function SF2460I          
	
	Local lCont	:= .T. // Raphael Ara�jo - 20/10/2016
	
	RecLock('SF2',.F.)
	SF2->F2_XTOTESP := SC5->C5_XTOTESP
	SF2->(MsUnlock())

	
	// Raphael Ara�jo - 20/10/2016 	
 	dbselectarea("SC6")
	DbSetOrder(1)
	dbSeek(xfilial('SC6')+C6_ITEM+SC6->C6_NUM)
     
    If SC6->C6_QTDVEN <> SC6->C6_QTDLIB
    	alert("N�o � permitido libera��o parcial. Favor liberar quantidade total! - M410PVNF")
    	lCont := .F. 
    Endif
    // **************************** 	
     
Return lCont // Raphael Ara�jo - 20/10/2016
