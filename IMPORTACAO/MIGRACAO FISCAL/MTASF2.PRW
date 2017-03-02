#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MTASF2

Ponto de Entrada executado apos a atualizacao de quase todos os campos do SF2 localizado na funcao A460GeraF2 (Gera Registros em SF2 e acumula valores).

@author Allan Bonfim

@since 07/08/2015

@param

@obs  

@return

/*/
//-------------------------------------------------------------------
USER FUNCTION MTASF2() 
     
If SC5->C5_XIMPORT == "S" //Notas Importadas via XML (CAMBM006)

	SF2->F2_XIMPORT := SC5->C5_XIMPORT
	 
  	//Atualizar os valores dos impostos
	If Type("aTotImpx") == "A"		
		If LEN(aTotImpx) > 0
			If VALTYPE(XMLCHILDEX(aTotImpx[1], "_ICMSTOT")) == "O"
			
				SF2->F2_BASEICM	:= VAL(aTotImpx[1]:_ICMSTOT:_VBC:TEXT)
				SF2->F2_VALICM 	:= VAL(aTotImpx[1]:_ICMSTOT:_VICMS:TEXT)
				SF2->F2_BRICMS 	:= VAL(aTotImpx[1]:_ICMSTOT:_VBCST:TEXT)
				SF2->F2_ICMSRET	:= VAL(aTotImpx[1]:_ICMSTOT:_VST:TEXT)
				SF2->F2_VALMERC	:= VAL(aTotImpx[1]:_ICMSTOT:_VPROD:TEXT)
				SF2->F2_FRETE	:= VAL(aTotImpx[1]:_ICMSTOT:_VFRETE:TEXT)
				SF2->F2_SEGURO	:= VAL(aTotImpx[1]:_ICMSTOT:_VSEG:TEXT)
				SF2->F2_DESCONT	:= VAL(aTotImpx[1]:_ICMSTOT:_VDESC:TEXT)
				SF2->F2_VALIPI	:= VAL(aTotImpx[1]:_ICMSTOT:_VIPI:TEXT)
				SF2->F2_VALIMP6	:= VAL(aTotImpx[1]:_ICMSTOT:_VPIS:TEXT)
				//SF2->F2_VALPIS	:= VAL(aTotImpx[1]:_ICMSTOT:_VPIS:TEXT)
				SF2->F2_VALIMP5	:= VAL(aTotImpx[1]:_ICMSTOT:_VCOFINS:TEXT)
				//SF2->F2_VALCOFI	:= VAL(aTotImpx[1]:_ICMSTOT:_VCOFINS:TEXT)
				SF2->F2_DESPESA	:= VAL(aTotImpx[1]:_ICMSTOT:_VOUTRO:TEXT)
				SF2->F2_VALBRUT	:= VAL(aTotImpx[1]:_ICMSTOT:_VNF:TEXT)
			  	
	   		EndIf
	
			If VALTYPE(XMLCHILDEX(aTotImpx[1], "_ISSQNTOT")) == "O"

				SF2->F2_BASEISS	:= VAL(aTotImpx[1]:_ISSQNTOT:_VBC:TEXT)
				SF2->F2_VALISS	:= VAL(aTotImpx[1]:_ISSQNTOT:_VISS:TEXT)
				SF2->F2_VALIMP6	:= VAL(aTotImpx[1]:_ISSQNTOT:_VPIS:TEXT)
				//SF2->F2_VALPIS	:= VAL(aTotImpx[1]:_ISSQNTOT:_VPIS:TEXT)
				SF2->F2_VALIMP5	:= VAL(aTotImpx[1]:_ISSQNTOT:_VCOFINS:TEXT)
				//SF2->F2_VALCOFI	:= VAL(aTotImpx[1]:_ISSQNTOT:_VCOFINS:TEXT)

	   		EndIf 
	   		
			If VALTYPE(XMLCHILDEX(aTotImpx[1], "_RETTRIB")) == "O"
			
				SF2->F2_VALIMP5	:= VAL(aTotImpx[1]:_RETTRIB:_VRETPIS:TEXT)
				//SF2->F2_VALPIS	:= VAL(aTotImpx[1]:_RETTRIB:_VRETPIS:TEXT)
				SF2->F2_VALIMP6	:= VAL(aTotImpx[1]:_RETTRIB:_VRETCOFINS:TEXT)
				//SF2->F2_VALCOFI	:= VAL(aTotImpx[1]:_RETTRIB:_VRETCOFINS:TEXT)
				SF2->F2_VALIMP4	:= VAL(aTotImpx[1]:_RETTRIB:_VRETCSLL:TEXT)
				SF2->F2_BASEIRR	:= VAL(aTotImpx[1]:_RETTRIB:_VBCIRRF:TEXT)
				SF2->F2_VALIRRF	:= VAL(aTotImpx[1]:_RETTRIB:_VIRRF:TEXT)
				SF2->F2_BASEINS	:= VAL(aTotImpx[1]:_RETTRIB:_VBCRETPREV:TEXT)
				SF2->F2_VALINSS	:= VAL(aTotImpx[1]:_RETTRIB:_VRETPREV:TEXT)				
				
			EndIf   		  		
		EndIf  	    
	EndIf
EndIf
   
Return Nil