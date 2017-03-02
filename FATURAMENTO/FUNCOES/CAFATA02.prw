#Include 'Protheus.ch'

/*
Por : Luis Henrique
Em  : 09/01/2015
Obj : Recalculo de comissões
		Permite o recalculo das comissões por 
			Periodo
			Vendedor
			Nota Fiscal 

*/

User Function CAFATA02()

Local _cPerg := "CAFATA02"
Local _aQuery := {}

CriaSX1(_cPerg) 

Pergunte(_cPerg,.t.)

Processa( {|| U_CAFAT02a()  } , "Aguarde...", "Recalculando Comissões", .t.    )


Return

/*
Por : Luis Henrique
Em  : 09/01/2015
Obj : Recalculo de comissões - continuação
		Permite o recalculo das comissões por 
			Periodo
			Vendedor
			Nota Fiscal 

*/

User Function CAFAT02a()
Local _cAlias0 := GetNextAlias()
Local MV_DATADE := dtos(MV_PAR01)
Local MV_DATAATE := dtos(MV_PAR02)


BeginSql Alias _cAlias0

	%noparser%
	
	SELECT * 
FROM 
	( SELECT R_E_C_N_O_ SC6_REC, *
	FROM %Table:SC6% NOLOCK
	WHERE %NotDel%
		AND C6_NOTA >= %Exp:MV_PAR07%
		AND C6_NOTA <= %Exp:MV_PAR08%
		AND C6_SERIE >= %Exp:MV_PAR09%
		AND C6_SERIE <= %Exp:MV_PAR10%
	
	) SC6

INNER JOIN
	( SELECT R_E_C_N_O_ SC5_REC, *
	FROM %Table:SC5% NOLOCK
	WHERE %NotDel%
		AND C5_EMISSAO >= %Exp:MV_DATADE%
		AND C5_EMISSAO <= %Exp:MV_DATAATE%
		AND C5_VEND1 >= %Exp:MV_PAR03%
		AND C5_VEND1 <= %Exp:MV_PAR04%
		AND C5_CLIENTE >= %Exp:MV_PAR05%
		AND C5_CLIENTE <= %Exp:MV_PAR06%
		AND C5_NUM >= %Exp:MV_PAR11%
		AND C5_NUM <= %Exp:MV_PAR12%
	) SC5 ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM	


EndSql

_aQuery := GetLastQuery()

dbselectArea(_cAlias0)
(_cAlias0)->(dbGoTop()) 
While ! (_cAlias0)->(eof()) 
 
 	dbSelectArea("SC6")
 	SC6->(dbGoto( (_cAlias0)->SC6_REC    ))
 	dbSelectArea("SC5")
 	SC5->(dbGoto( (_cAlias0)->SC5_REC    ))

	U_MTA410T()
 
 	(_cAlias0)->(dbSkip())
End 

Return


/*
Por : Luis Henrique
Em  : 09/01/2015
Obj : Cria perguntas na tabela SX1 

*/

Static Function CriaSX1(_cPerg)

Local _ABrea := GetArea()
Local _aRegs := {}


_sAlias := Alias()
dbSelectArea("SX1")
SX1->(dbSetOrder(1))
_cPerg := padr(_cPerg,len(SX1->X1_GRUPO))

Aadd(_aRegs,{_cPerg,"01","Da Data	        	?"	,"mv_ch1","D",8,0,"G","mv_par01","","","","","",""})
Aadd(_aRegs,{_cPerg,"02","Ate Data 		       	?"	,"mv_ch2","D",8,0,"G","mv_par02","","","","","",""})
Aadd(_aRegs,{_cPerg,"03","Do Vendedor        	?"	,"mv_ch3","C",6,0,"G","mv_par03","SA3","","","","",""})
Aadd(_aRegs,{_cPerg,"04","Ate Vendedor       	?"	,"mv_ch4","C",6,0,"G","mv_par04","SA3","","","","",""})
Aadd(_aRegs,{_cPerg,"05","Do Cliente          	?"	,"mv_ch5","C",6,0,"G","mv_par05","SA1","","","","",""})
Aadd(_aRegs,{_cPerg,"06","Ate Cliente         	?"	,"mv_ch6","C",6,0,"G","mv_par06","SA1","","","","",""})
Aadd(_aRegs,{_cPerg,"07","Da Nota Fiscal       	?"	,"mv_ch7","C",9,0,"G","mv_par07","","","","","",""})
Aadd(_aRegs,{_cPerg,"08","Ate Nota Fiscal      	?"	,"mv_ch8","C",9,0,"G","mv_par08","","","","","",""})
Aadd(_aRegs,{_cPerg,"09","Da Serie          	?"	,"mv_ch9","C",3,0,"G","mv_par09","","","","","",""})
Aadd(_aRegs,{_cPerg,"10","Ate Serie         	?"	,"mv_chA","C",3,0,"G","mv_par10","","","","","",""})
Aadd(_aRegs,{_cPerg,"11","Do Pedido          	?"	,"mv_chB","C",6,0,"G","mv_par11","","","","","",""})
Aadd(_aRegs,{_cPerg,"12","Ate Pedido         	?"	,"mv_chC","C",6,0,"G","mv_par11","","","","","",""})

DbSelectArea("SX1")
SX1->(DbSetOrder(1))

For i := 1 To Len(_aRegs)
	IF  !DbSeek(_aRegs[i,1]+_aRegs[i,2])
		RecLock("SX1",.T.)
		Replace X1_GRUPO   with _aRegs[i,01]
		Replace X1_ORDEM   with _aRegs[i,02]
		
		Replace X1_PERGUNT with _aRegs[i,03]
		Replace X1_PERSPA  with _aRegs[i,03]
		Replace X1_PERENG  with _aRegs[i,03]
		
		Replace X1_VARIAVL 	with _aRegs[i,04]
		Replace X1_TIPO     with _aRegs[i,05]
		Replace X1_TAMANHO 	with _aRegs[i,06]
		Replace X1_DECIMAL  with _aRegs[i,07]
		Replace X1_GSC    	with _aRegs[i,08]
		Replace X1_VAR01   	with _aRegs[i,09]
		Replace X1_F3     	with _aRegs[i,10]
		Replace X1_DEF01   	with _aRegs[i,11]
		Replace X1_DEF02   	with _aRegs[i,12]
		Replace X1_DEF03   	with _aRegs[i,13]
		Replace X1_DEF04   	with _aRegs[i,14]
		Replace X1_DEF05   	with _aRegs[i,15]
		MsUnlock()
	EndIF
Next i

RestArea(_ABrea)

Return
