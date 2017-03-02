#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} CAFATA04
//Trigger para atualização do tipo de operação e tes inteligente
@author totvsremote
@since 26/04/2016
@version undefined

@type function
/*/
user function CAFATA04()
	Local _nPProduto := ascan(aHeader, {|x,y| alltrim(x[2]) == 'C6_PRODUTO'   })
	Local _cProduto := aCols[n][_nPProduto]

	_cRet := MaTesInt(2,padr(M->C5_XOPER,2),M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),alltrim(_cProduto),"C6_TES")

return(_cRet)


/*/{Protheus.doc} CAFATA05
//Gatilho para replicação do tipo de operação nas linhas do acols 
@author totvsremote
@since 26/04/2016
@version undefined

@type function
/*/
User Function CAFATA05()
Local _cRet := M->C5_XOPER
Local _nPProduto 	:= ascan( aHeader, {|x,y|  alltrim(x[2]) == 'C6_PRODUTO'})
Local _nPOper 		:= ascan( aHeader, {|x,y|  alltrim(x[2]) == 'C6_OPER'})
Local _lOk := .f.


	For _nx := 1 to len(aCols)

		if ! empty(aCols[_nx][_nPProduto])

			M->C6_PRODUTO 	:= aCols[_nx][_nPProduto]
			M->C6_OPER		:= aCols[_nx][_nPOper]
			RunTrigger(2,_nx,nil,,'C6_PRODUTO')
			RunTrigger(2,_nx,nil,,'C6_OPER')
			_lOk := .t.
		
		Endif	

	Next

	if _lOk
		
		If FunName() <>"XQGALTPV"
		
			GETDREFRESH()
			SetFocus(oGetDad:oBrowse:hWnd) // Atualizacao por linha
			oGetDad:Refresh()
			
		EndIf
			
	Endif	


Return(_cRet)



User Function CAFATA06()
Local _nPProduto 	:= ascan( aHeader, {|x,y|  alltrim(x[2]) == 'C6_PRODUTO'})
Local _nPOper 		:= ascan( aHeader, {|x,y|  alltrim(x[2]) == 'C6_OPER'})
Local _nPxCodRef	:= ascan( aHeader, {|x,y|  alltrim(x[2]) == 'C6_XCODREF'})
Local _lOk := .f.
Local _cRet := aCols[n][_nPxCodRef]

if ! empty(aCols[n][_nPProduto])

	M->C6_PRODUTO 	:= aCols[n][_nPProduto]
	M->C6_OPER		:= aCols[n][_nPOper]
	RunTrigger(2,n,nil,,'C6_PRODUTO')
	RunTrigger(2,n,nil,,'C6_OPER')
	_lOk := .t.
		
Endif	

if _lOk
	GETDREFRESH()
	SetFocus(oGetDad:oBrowse:hWnd) // Atualizacao por linha
	oGetDad:Refresh()
Endif	


Return(_cRet)
