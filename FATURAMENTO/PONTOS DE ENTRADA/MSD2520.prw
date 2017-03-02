#INCLUDE 'RWMAKE.CH'

User Function MSD2520

If SC6->C6_XPRCESP > 0
	Reclock('SC6',.F.)
    SC6->C6_PRCVEN := SC6->C6_XPRCESP
    SC6->C6_PRUNIT := SC6->C6_XPRCESP  
    SC6->C6_VALOR  := SC6->(C6_QTDVEN*C6_PRCVEN)
	SC6->C6_XPRCESP:= 0                         
	SC6->C6_XDESESP:= 0                         
	SC6->C6_XTOTESP:= 0                         
	SC6->(MsUnlock())
End

Return