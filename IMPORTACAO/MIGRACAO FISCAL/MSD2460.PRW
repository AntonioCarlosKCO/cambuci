#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MSD2460

Ponto de Entrada criado na gravação dos Itens da NF, para executar um execblock criado pelo usuário após a gravação da tabela SD2.

@author Allan Bonfim

@since 07/08/2015

@param

@obs  

@return

/*/
//-------------------------------------------------------------------
USER FUNCTION MSD2460() 

Local nItSD2 := 0
     
If SC5->C5_XIMPORT == "S" //Notas Importadas via XML (CAMBM006)

	SC6->C6_XIMPORT := SC5->C5_XIMPORT
	SF2->F2_XIMPORT := SC5->C5_XIMPORT
	SD2->D2_XIMPORT := SC5->C5_XIMPORT
 
  	//Atualizar os valores dos impostos
	If Type("aImpostx") == "A"
		
		nItSD2 := ASCAN(aImpostx, {|x| ALLTRIM(x[1]) == SD2->D2_ITEM})
		
		//ICMS
		If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2], "_ICMS")) == "O"
			If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS, "_ICMS00")) == "O"
	
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS00, "_VBC")) == "O"
					SD2->D2_BASEICM	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS00:_VBC:TEXT)
				  	MAFISALT("IT_BASEICM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS00:_VBC:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS00, "_PICMS")) == "O"
					SD2->D2_PICM 	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS00:_PICMS:TEXT)
				  	MAFISALT("IT_ALIQICM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS00:_PICMS:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS00, "_VICMS")) == "O"
					SD2->D2_VALICM 	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS00:_VICMS:TEXT)
				  	MAFISALT("IT_VALICM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS00:_VICMS:TEXT), nItSD2)
				EndIf
			  	
				//SD2->D2_ICMFRET	:= 60								
   				//aImpostx[nItSD2]:_ICMS:_ICMS00:_ORIG:TEXT //ORIGEM PRODUTO - 0 – Nacional, 1 – Estrangeira – Importação direta, 2 – Estrangeira – Adquirida no mercado interno. 
   				//aImpostx[nItSD2]:_ICMS:_ICMS00:_CST:TEXT //CST - 00 – Tributada integralmente
   				
			ElseIf VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS, "_ICMS10")) == "O"

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS10, "_VBC")) == "O"
					SD2->D2_BASEICM	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS10:_VBC:TEXT)
				  	MAFISALT("IT_BASEICM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS10:_VBC:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS10, "_PICMS")) == "O"
					SD2->D2_PICM 	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS10:_PICMS:TEXT)
				  	MAFISALT("IT_ALIQICM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS10:_PICMS:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS10, "_VICMS")) == "O"
					SD2->D2_VALICM 	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS10:_VICMS:TEXT)
				  	MAFISALT("IT_VALICM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS10:_VICMS:TEXT), nItSD2)
				EndIf

				//ICMS ST
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS10, "_VBCST")) == "O"
				  	SD2->D2_BRICMS	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS10:_VBCST:TEXT)
				  	MAFISALT("IT_BASESOL", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS10:_VBCST:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS10, "_PMVAST")) == "O"
					SD2->D2_MARGEM 	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS10:_PMVAST:TEXT)
				  	MAFISALT("IT_MARGEM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS10:_PMVAST:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS10, "_PICMSST")) == "O"
					SD2->D2_ALIQSOL := VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS10:_PICMSST:TEXT)
				  	MAFISALT("IT_ALIQSOL", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS10:_PICMSST:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS10, "_VICMSST")) == "O"
					SD2->D2_ICMSRET	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS10:_VICMSST:TEXT)
				  	MAFISALT("IT_VALSOL", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS10:_VICMSST:TEXT), nItSD2)
				EndIf

   				//aImpostx[nItSD2]:_ICMS:_ICMS10:_ORIG:TEXT //ORIGEM PRODUTO - 0 – Nacional, 1 – Estrangeira – Importação direta, 2 – Estrangeira – Adquirida no mercado interno. 
   				//aImpostx[nItSD2]:_ICMS:_ICMS10:_CST:TEXT //CST - 10 - Tributada e com cobrança do ICMS por substituição tributária

			ElseIf VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS, "_ICMS20")) == "O"

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS20, "_VBC")) == "O"
					SD2->D2_BASEICM	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS20:_VBC:TEXT)
				  	MAFISALT("IT_BASEICM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS20:_VBC:TEXT), nItSD2)
				EndIf
				
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS20, "_PICMS")) == "O"
					SD2->D2_PICM 	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS20:_PICMS:TEXT)
				  	MAFISALT("IT_ALIQICM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS20:_PICMS:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS20, "_VICMS")) == "O"
					SD2->D2_VALICM 	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS20:_VICMS:TEXT)
				  	MAFISALT("IT_VALICM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS20:_VICMS:TEXT), nItSD2)
				EndIf

   				//aImpostx[nItSD2]:_ICMS:_ICMS20:_ORIG:TEXT //ORIGEM PRODUTO - 0 – Nacional, 1 – Estrangeira – Importação direta, 2 – Estrangeira – Adquirida no mercado interno. 
   				//aImpostx[nItSD2]:_ICMS:_ICMS20:_CST:TEXT //CST - 20 - Com redução de base de cálculo

			ElseIf VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS, "_ICMS30")) == "O"
		
				SD2->D2_BASEICM	:= 0
				SD2->D2_PICM 	:= 0
				SD2->D2_VALICM 	:= 0
			
			  	MAFISALT("IT_BASEICM", 0, nItSD2)
			  	MAFISALT("IT_ALIQICM", 0, nItSD2)
			  	MAFISALT("IT_VALICM", 0, nItSD2)

				//ICMS ST

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS30, "_VBCST")) == "O"
					SD2->D2_BRICMS	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS30:_VBCST:TEXT)
				  	MAFISALT("IT_BASESOL", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS30:_VBCST:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS30, "_PMVAST")) == "O"
					SD2->D2_MARGEM 	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS30:_PMVAST:TEXT)
				  	MAFISALT("IT_MARGEM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS30:_PMVAST:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS30, "_PICMSST")) == "O"
					SD2->D2_ALIQSOL := VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS30:_PICMSST:TEXT)
				  	MAFISALT("IT_ALIQSOL", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS30:_PICMSST:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS30, "_VICMSST")) == "O"
					SD2->D2_ICMSRET	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS30:_VICMSST:TEXT)
				  	MAFISALT("IT_VALSOL", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS30:_VICMSST:TEXT), nItSD2)
				EndIf

   				//aImpostx[nItSD2]:_ICMS:_ICMS30:_ORIG:TEXT //ORIGEM PRODUTO - 0 – Nacional, 1 – Estrangeira – Importação direta, 2 – Estrangeira – Adquirida no mercado interno. 
   				//aImpostx[nItSD2]:_ICMS:_ICMS30:_CST:TEXT //CST - 30 - Isenta ou não tributada e com cobrança do ICMS por substituição tributária

			ElseIf VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS, "_ICMS40")) == "O"
		
				SD2->D2_BASEICM	:= 0
				SD2->D2_PICM 	:= 0
				SD2->D2_VALICM 	:= 0
			
			  	MAFISALT("IT_BASEICM", 0, nItSD2)
			  	MAFISALT("IT_ALIQICM", 0, nItSD2)
			  	MAFISALT("IT_VALICM", 0, nItSD2)

   				//aImpostx[nItSD2]:_ICMS:_ICMS40:_ORIG:TEXT //ORIGEM PRODUTO - 0 – Nacional, 1 – Estrangeira – Importação direta, 2 – Estrangeira – Adquirida no mercado interno. 
   				//aImpostx[nItSD2]:_ICMS:_ICMS40:_CST:TEXT //CST - 40 - Isenta, 41 - Não tributada, 50 - Suspensão

			ElseIf VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS, "_ICMS51")) == "O"
		
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS51, "_VBC")) == "O"
					SD2->D2_BASEICM	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS51:_VBC:TEXT)
				  	MAFISALT("IT_BASEICM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS51:_VBC:TEXT), nItSD2)
				EndIf
				
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS51, "_PICMS")) == "O"
					SD2->D2_PICM 	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS51:_PICMS:TEXT)	
				  	MAFISALT("IT_ALIQICM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS51:_PICMS:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS51, "_VICMS")) == "O"
					SD2->D2_VALICM 	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS51:_VICMS:TEXT)
				  	MAFISALT("IT_VALICM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS51:_VICMS:TEXT), nItSD2)
				EndIf
				
   				//aImpostx[nItSD2]:_ICMS:_ICMS51:_ORIG:TEXT //ORIGEM PRODUTO - 0 – Nacional, 1 – Estrangeira – Importação direta, 2 – Estrangeira – Adquirida no mercado interno. 
   				//aImpostx[nItSD2]:_ICMS:_ICMS51:_CST:TEXT //CST - 51 - Diferimento 

			ElseIf VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS, "_ICMS60")) == "O"

				//ICMS ST
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS60, "_VBCST")) == "O" 
					SD2->D2_BRICMS	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS60:_VBCST:TEXT)
				  	MAFISALT("IT_BASESOL", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS60:_VBCST:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS60, "_VICMSSTRET")) == "O"
					SD2->D2_ICMSRET	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS60:_VICMSSTRET:TEXT)
					MAFISALT("IT_VALSOL", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS60:_VICMSSTRET:TEXT), nItSD2)					
				EndIf
				
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS60, "_VICMSST")) == "O"
					SD2->D2_ICMSRET	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS60:_VICMSST:TEXT)
					MAFISALT("IT_VALSOL", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS60:_VICMSST:TEXT), nItSD2)
				EndIf				

   				//aImpostx[nItSD2]:_ICMS:_ICMS60:_ORIG:TEXT //ORIGEM PRODUTO - 0 – Nacional, 1 – Estrangeira – Importação direta, 2 – Estrangeira – Adquirida no mercado interno. 
   				//aImpostx[nItSD2]:_ICMS:_ICMS60:_CST:TEXT //CST -  ICMS cobrado anteriormente por substituição tributária

			ElseIf VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS, "_ICMS70")) == "O"
		
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS70, "_VBC")) == "O"
					SD2->D2_BASEICM	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS70:_VBC:TEXT)
				  	MAFISALT("IT_BASEICM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS70:_VBC:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS70, "_PICMS")) == "O"
					SD2->D2_PICM 	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS70:_PICMS:TEXT)
				  	MAFISALT("IT_ALIQICM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS70:_PICMS:TEXT), nItSD2)
				EndIf                

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS70, "_VICMS")) == "O"
					SD2->D2_VALICM 	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS70:_VICMS:TEXT)
				  	MAFISALT("IT_VALICM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS70:_VICMS:TEXT), nItSD2)
				EndIf
				
				//ICMS ST
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS70, "_VBCST")) == "O"
					SD2->D2_BRICMS	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS70:_VBCST:TEXT)
				  	MAFISALT("IT_BASESOL", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS70:_VBCST:TEXT), nItSD2)
    			EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS70, "_PMVAST")) == "O"
					SD2->D2_MARGEM 	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS70:_PMVAST:TEXT)
				  	MAFISALT("IT_MARGEM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS70:_PMVAST:TEXT), nItSD2)
				EndIf
					
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS70, "_PICMSST")) == "O"
					SD2->D2_ALIQSOL := VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS70:_PICMSST:TEXT)
				  	MAFISALT("IT_ALIQSOL", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS70:_PICMSST:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS70, "_VICMSST")) == "O"
					SD2->D2_ICMSRET	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS70:_VICMSST:TEXT)
				  	MAFISALT("IT_VALSOL", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS70:_VICMSST:TEXT), nItSD2)
				EndIf
    			
   				//aImpostx[nItSD2]:_ICMS:_ICMS70:_ORIG:TEXT //ORIGEM PRODUTO - 0 – Nacional, 1 – Estrangeira – Importação direta, 2 – Estrangeira – Adquirida no mercado interno. 
   				//aImpostx[nItSD2]:_ICMS:_ICMS70:_CST:TEXT //CST - 70 - Com redução de base de cálculo e cobrança do ICMS por substituição tributária ICMS por substituição tributária

			ElseIf VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS, "_ICMS90")) == "O"
		
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS90, "_VBC")) == "O"
					SD2->D2_BASEICM	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS90:_VBC:TEXT)
				  	MAFISALT("IT_BASEICM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS90:_VBC:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS90, "_PICMS")) == "O"
					SD2->D2_PICM 	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS90:_PICMS:TEXT)
				  	MAFISALT("IT_ALIQICM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS90:_PICMS:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS90, "_VICMS")) == "O"
					SD2->D2_VALICM 	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS90:_VICMS:TEXT)
				  	MAFISALT("IT_VALICM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS90:_VICMS:TEXT), nItSD2)
				EndIf

				//ICMS ST
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS90, "_VBCST")) == "O"
					SD2->D2_BRICMS	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS90:_VBCST:TEXT)
				  	MAFISALT("IT_BASESOL", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS90:_VBCST:TEXT), nItSD2)
    			EndIf
    							
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS90, "_PMVAST")) == "O"
					SD2->D2_MARGEM 	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS90:_PMVAST:TEXT)
				  	MAFISALT("IT_MARGEM", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS90:_PMVAST:TEXT), nItSD2)	
				EndIf
				
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS90, "_PICMSST")) == "O"
					SD2->D2_ALIQSOL := VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS90:_PICMSST:TEXT)
				  	MAFISALT("IT_ALIQSOL", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS90:_PICMSST:TEXT), nItSD2)
				EndIf
				
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ICMS:_ICMS90, "_VICMSST")) == "O"
					SD2->D2_ICMSRET	:= VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS90:_VICMSST:TEXT)
				  	MAFISALT("IT_VALSOL", VAL(aImpostx[nItSD2][2]:_ICMS:_ICMS90:_VICMSST:TEXT), nItSD2)
				EndIf
    			
   				//aImpostx[nItSD2][2]:_ICMS:_ICMS90:_ORIG:TEXT //ORIGEM PRODUTO - 0 – Nacional, 1 – Estrangeira – Importação direta, 2 – Estrangeira – Adquirida no mercado interno. 
   				//aImpostx[nItSD2][2]:_ICMS:_ICMS90:_CST:TEXT //CST - 90 - Outros
   				
			EndIf
		EndIf
		
		//IPI
		If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2], "_IPI")) == "O"
			If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_IPI, "_IPITRIB")) == "O"

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_IPI:_IPITRIB, "_VBC")) == "O"
					SD2->D2_BASEIPI	:= VAL(aImpostx[nItSD2][2]:_IPI:_IPITRIB:_VBC:TEXT)
			  		MAFISALT("IT_BASEIPI", VAL(aImpostx[nItSD2][2]:_IPI:_IPITRIB:_VBC:TEXT) , nItSD2)
			  	EndIf
	
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_IPI:_IPITRIB, "_PIPI")) == "O"
					SD2->D2_IPI 	:= VAL(aImpostx[nItSD2][2]:_IPI:_IPITRIB:_PIPI:TEXT)
		  			MAFISALT("IT_ALIQIPI", VAL(aImpostx[nItSD2][2]:_IPI:_IPITRIB:_PIPI:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_IPI:_IPITRIB, "_VIPI")) == "O"
					SD2->D2_VALIPI 	:= VAL(aImpostx[nItSD2][2]:_IPI:_IPITRIB:_VIPI:TEXT)
			  		MAFISALT("IT_VALIPI", VAL(aImpostx[nItSD2][2]:_IPI:_IPITRIB:_VIPI:TEXT), nItSD2)
				EndIf
				
   				//aImpostx[nItSD2][2]:_IPI:_IPITRIB:_CST:TEXT //CST - 00-Entrada com recuperação de crédito, 49-Outras entradas, 50-Saída tributada, 99-Outras saídas

			ElseIf VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_IPI, "_IPINT")) == "O"
				
				SD2->D2_BASEIPI	:= 0
				SD2->D2_IPI 	:= 0
				SD2->D2_VALIPI 	:= 0

		  		MAFISALT("IT_BASEIPI", 0 , nItSD2)
	  			MAFISALT("IT_ALIQIPI", 0, nItSD2)
		  		MAFISALT("IT_VALIPI", 0, nItSD2)


				//aImpostx[nItSD2][2]:_IPI:_IPINT:_CST:TEXT //CST - 01-Entrada tributada com alíquota zero, 02-Entrada isenta, 03-Entrada não-tributada, 04-Entrada imune, 05-Entrada com suspensão, 51-Saída tributada com alíquota zero, 52-Saída isenta, 53-Saída não-tributada, 54-Saída imune, 55-Saída com suspensão
			EndIf
		EndIf

/*
		//CSLL
		SD2->D2_BASIMP4	:= 400
		SD2->D2_ALQIMP4	:= 4
		SD2->D2_VALIMP4	:= 40
		SD2->D2_ALQCSL	:= 4
	    SD2->D2_VALCSL	:= 40
	
	  	MAFISALT("IT_BASECSL", 400, 1)    
	  	MAFISALT("IT_ALIQCSL", 4, 1)
	  	MAFISALT("IT_VALCSL", 40, 1)
*/	  	  	
		//COFINS
		If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2], "_COFINSST")) == "O"
				
			If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_COFINSST, "_VBC")) == "O"
				SD2->D2_BASIMP5	:= VAL(aImpostx[nItSD2][2]:_COFINSST:_VBC:TEXT)
		  		MAFISALT("IT_BASECF2", VAL(aImpostx[nItSD2][2]:_COFINSST:_VBC:TEXT), nItSD2)
		  		//SD2->D2_BASECOF	:= VAL(aImpostx[nItSD2][2]:_COFINSST:_VBC:TEXT)
		  		//MAFISALT("IT_BASECOF", VAL(aImpostx[nItSD2][2]:_COFINSST:_VBC:TEXT), nItSD2)
		  	EndIf
		  	
			If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_COFINSST, "_PCOFINS")) == "O"
				SD2->D2_ALQIMP5	:= VAL(aImpostx[nItSD2][2]:_COFINSST:_PCOFINS:TEXT)
				MAFISALT("IT_ALIQCF2", VAL(aImpostx[nItSD2][2]:_COFINSST:_PCOFINS:TEXT), nItSD2)
				//SD2->D2_ALQCOF	:= VAL(aImpostx[nItSD2][2]:_COFINSST:_PCOFINS:TEXT)
				//MAFISALT("IT_ALIQCOF", VAL(aImpostx[nItSD2][2]:_COFINSST:_PCOFINS:TEXT), nItSD2)				
			EndIf

			If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_COFINSST, "_VCOFINS")) == "O"
				SD2->D2_VALIMP5	:= VAL(aImpostx[nItSD2][2]:_COFINSST:_VCOFINS:TEXT)
				MAFISALT("IT_VALCF2", VAL(aImpostx[nItSD2][2]:_COFINSST:_VCOFINS:TEXT), nItSD2)
				//SD2->D2_VALCOF	:= VAL(aImpostx[nItSD2][2]:_COFINSST:_VCOFINS:TEXT)
			  	//MAFISALT("IT_VALCOF", VAL(aImpostx[nItSD2][2]:_COFINSST:_VCOFINS:TEXT), nItSD2)
			EndIf

		EndIf
		
		If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2], "_COFINS")) == "O"
			If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_COFINS, "_COFINSALIQ")) == "O"

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_COFINS:_COFINSALIQ, "_VBC")) == "O"
					SD2->D2_BASIMP5	:= VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSALIQ:_VBC:TEXT)
					MAFISALT("IT_BASECF2", VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSALIQ:_VBC:TEXT), nItSD2)
					//SD2->D2_BASECOF	:= VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSALIQ:_VBC:TEXT)
			  		//MAFISALT("IT_BASECOF", VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSALIQ:_VBC:TEXT), nItSD2)
			  	EndIf
			  	
			  	If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_COFINS:_COFINSALIQ, "_PCOFINS")) == "O"
					SD2->D2_ALQIMP5	:= VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSALIQ:_PCOFINS:TEXT)
					MAFISALT("IT_ALIQCF2", VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSALIQ:_PCOFINS:TEXT), nItSD2)
					//SD2->D2_ALQCOF	:= VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSALIQ:_PCOFINS:TEXT)
					//MAFISALT("IT_ALIQCOF", VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSALIQ:_PCOFINS:TEXT), nItSD2)
				EndIf
				
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_COFINS:_COFINSALIQ, "_VCOFINS")) == "O"
					SD2->D2_VALIMP5	:= VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSALIQ:_VCOFINS:TEXT)
					MAFISALT("IT_VALCF2", VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSALIQ:_VCOFINS:TEXT), nItSD2)
					//SD2->D2_VALCOF	:= VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSALIQ:_VCOFINS:TEXT)
					//MAFISALT("IT_VALCOF", VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSALIQ:_VCOFINS:TEXT), nItSD2)
				EndIf
   				//aImpostx[nItSD2][2]:_COFINS:_COFINSALIQ:_CST:REALNAME //CST - 01 – Operação Tributável (base de cálculo = valor da operação alíquota normal (cumulativo/não cumulativo)), 02 - Operação Tributável (base de cálculo = valor da operação

			ElseIf VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_COFINS, "_COFINSQTDE")) == "O"

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_COFINS:_COFINSQTDE, "_QBCPROD")) == "O"
					SD2->D2_BASIMP5	:= VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSQTDE:_QBCPROD:TEXT)
					MAFISALT("IT_BASECF2", VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSQTDE:_QBCPROD:TEXT), nItSD2)
					//SD2->D2_BASECOF	:= VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSQTDE:_QBCPROD:TEXT)
				  	//MAFISALT("IT_BASECOF", VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSQTDE:_QBCPROD:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_COFINS:_COFINSQTDE, "_VALIQPROD")) == "O"
					SD2->D2_ALQIMP5	:= VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSQTDE:_VALIQPROD:TEXT)
					MAFISALT("IT_ALIQCF2", VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSQTDE:_VALIQPROD:TEXT), nItSD2)
					//SD2->D2_ALQCOF	:= VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSQTDE:_VALIQPROD:TEXT)
			  		//MAFISALT("IT_ALIQCOF", VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSQTDE:_VALIQPROD:TEXT), nItSD2)
			  	EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_COFINS:_COFINSQTDE, "_VCOFINS")) == "O"
					SD2->D2_VALIMP5	:= VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSQTDE:_VCOFINS:TEXT)
					MAFISALT("IT_VALCF2", VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSQTDE:_VCOFINS:TEXT), nItSD2)
					//SD2->D2_VALCOF	:= VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSQTDE:_VCOFINS:TEXT)
				  	//MAFISALT("IT_VALCOF", VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSQTDE:_VCOFINS:TEXT), nItSD2)
			    EndIf
		
   				//aImpostx[nItSD2][2]:_COFINS:_COFINSQTDE:_CST:REALNAME //CST - 03 - Operação Tributável (base de cálculo = quantidade vendida x alíquota por unidade de produto)

			ElseIf VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_COFINS, "_COFINSNT")) == "O"
				
				SD2->D2_BASIMP5	:= 0
				SD2->D2_ALQIMP5	:= 0
				SD2->D2_VALIMP5	:= 0
				SD2->D2_BASECOF	:= 0
				SD2->D2_ALQCOF	:= 0
				SD2->D2_VALCOF	:= 0
			
			  	MAFISALT("IT_BASECOF", 0, nItSD2)
			  	MAFISALT("IT_ALIQCOF", 0, nItSD2)
			  	MAFISALT("IT_VALCOF", 0, nItSD2)		
			  	MAFISALT("IT_BASECF2", 0, nItSD2)
			  	MAFISALT("IT_ALIQCF2", 0, nItSD2)
			  	MAFISALT("IT_VALCF2", 0, nItSD2)		

   				//aImpostx[nItSD2][2]:_COFINS:_COFINSNT:_CST:REALNAME //CST - 04 - Operação Tributável (tributação monofásica (alíquota zero)), 06 - Operação Tributável (alíquota zero), 07 - Operação Isenta da Contribuição, 08 - Operação Sem Incidência da Contribuição, 09 - Operação com Suspensão da Contribuição   			

			ElseIf VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_COFINS, "_COFINSOUTR")) == "O"
				
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_COFINS:_COFINSOUTR, "_VBC")) == "O"
					SD2->D2_BASIMP5	:= VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSOUTR:_VBC:TEXT)
					MAFISALT("IT_BASECF2", VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSOUTR:_VBC:TEXT), nItSD2)
					//SD2->D2_BASECOF	:= VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSOUTR:_VBC:TEXT)
			  		//MAFISALT("IT_BASECOF", VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSOUTR:_VBC:TEXT), nItSD2)
			  	EndIf
			  
  				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_COFINS:_COFINSOUTR, "_PCOFINS")) == "O"
					SD2->D2_ALQIMP5	:= VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSOUTR:_PCOFINS:TEXT)
					MAFISALT("IT_ALIQCF2", VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSOUTR:_PCOFINS:TEXT), nItSD2)
					//SD2->D2_ALQCOF	:= VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSOUTR:_PCOFINS:TEXT)
					//MAFISALT("IT_ALIQCOF", VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSOUTR:_PCOFINS:TEXT), nItSD2)
				EndIf

  				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_COFINS:_COFINSOUTR, "_VCOFINS")) == "O"
					SD2->D2_VALIMP5	:= VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSOUTR:_VCOFINS:TEXT)
					MAFISALT("IT_VALCF2", VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSOUTR:_VCOFINS:TEXT), nItSD2)
					//SD2->D2_VALCOF	:= VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSOUTR:_VCOFINS:TEXT)
				  	//MAFISALT("IT_VALCOF", VAL(aImpostx[nItSD2][2]:_COFINS:_COFINSOUTR:_VCOFINS:TEXT), nItSD2)
				EndIf
				
   				//aImpostx[nItSD2][2]:_COFINS:_COFINSOUTR:_CST:REALNAME //CST - 99 - Outras Operações
			EndIf
		EndIf
	  						
		//PIS
		If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2], "_PISST")) == "O"

			If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_PISST, "_VBC")) == "O"
				SD2->D2_BASIMP6	:= VAL(aImpostx[nItSD2][2]:_PISST:_VBC:TEXT)
				MAFISALT("IT_BASEPS2", VAL(aImpostx[nItSD2][2]:_PISST:_VBC:TEXT), nItSD2)
				//SD2->D2_BASEPIS	:= VAL(aImpostx[nItSD2][2]:_PISST:_VBC:TEXT)
		  		//MAFISALT("IT_BASEPIS", VAL(aImpostx[nItSD2][2]:_PISST:_VBC:TEXT), nItSD2)
		  	EndIf

			If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_PISST, "_PPIS")) == "O"
				SD2->D2_ALQIMP6	:= VAL(aImpostx[nItSD2][2]:_PISST:_PPIS:TEXT)
				MAFISALT("IT_ALIQPS2", VAL(aImpostx[nItSD2][2]:_PISST:_PPIS:TEXT), nItSD2)
				//SD2->D2_ALQPIS	:= VAL(aImpostx[nItSD2][2]:_PISST:_PPIS:TEXT)
				//MAFISALT("IT_ALIQPIS", VAL(aImpostx[nItSD2][2]:_PISST:_PPIS:TEXT), nItSD2)
			EndIf
			
			If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_PISST, "_VPIS")) == "O"
				SD2->D2_VALIMP6	:= VAL(aImpostx[nItSD2][2]:_PISST:_VPIS:TEXT)
				MAFISALT("IT_VALPS2", VAL(aImpostx[nItSD2][2]:_PISST:_VPIS:TEXT), nItSD2)
				//SD2->D2_VALPIS	:= VAL(aImpostx[nItSD2][2]:_PISST:_VPIS:TEXT)
				//MAFISALT("IT_VALPIS", VAL(aImpostx[nItSD2][2]:_PISST:_VPIS:TEXT), nItSD2)
			EndIf
		EndIf

		If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2], "_PIS")) == "O"
			If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_PIS, "_PISALIQ")) == "O"

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_PIS:_PISALIQ, "_VBC")) == "O"
					SD2->D2_BASIMP6	:= VAL(aImpostx[nItSD2][2]:_PIS:_PISALIQ:_VBC:TEXT)
				  	MAFISALT("IT_BASEPS2", VAL(aImpostx[nItSD2][2]:_PIS:_PISALIQ:_VBC:TEXT), nItSD2)					
					//SD2->D2_BASEPIS	:= VAL(aImpostx[nItSD2][2]:_PIS:_PISALIQ:_VBC:TEXT)
				  	//MAFISALT("IT_BASEPIS", VAL(aImpostx[nItSD2][2]:_PIS:_PISALIQ:_VBC:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_PIS:_PISALIQ, "_PPIS")) == "O"
					SD2->D2_ALQIMP6	:= VAL(aImpostx[nItSD2][2]:_PIS:_PISALIQ:_PPIS:TEXT)
					MAFISALT("IT_ALIQPS2", VAL(aImpostx[nItSD2][2]:_PIS:_PISALIQ:_PPIS:TEXT), nItSD2)
					//SD2->D2_ALQPIS	:= VAL(aImpostx[nItSD2][2]:_PIS:_PISALIQ:_PPIS:TEXT)
				  	//MAFISALT("IT_ALIQPIS", VAL(aImpostx[nItSD2][2]:_PIS:_PISALIQ:_PPIS:TEXT), nItSD2)
				EndIf
				
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_PIS:_PISALIQ, "_VPIS")) == "O"
					SD2->D2_VALIMP6	:= VAL(aImpostx[nItSD2][2]:_PIS:_PISALIQ:_VPIS:TEXT)
					MAFISALT("IT_VALPS2", VAL(aImpostx[nItSD2][2]:_PIS:_PISALIQ:_VPIS:TEXT), nItSD2)
					//SD2->D2_VALPIS	:= VAL(aImpostx[nItSD2][2]:_PIS:_PISALIQ:_VPIS:TEXT)
					//MAFISALT("IT_VALPIS", VAL(aImpostx[nItSD2][2]:_PIS:_PISALIQ:_VPIS:TEXT), nItSD2)
				EndIf

   				//aImpostx[nItSD2][2]:_PIS:_PISALIQ:_CST:REALNAME //CST - 01 – Operação Tributável (base de cálculo = valor da operação alíquota normal (cumulativo/não cumulativo)), 02 - Operação Tributável (base decálculo = valor da operação (alíquota diferenciada))

			ElseIf VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_PIS, "_PISQTDE")) == "O"
				
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_PIS:_PISQTDE, "_QBCPROD")) == "O"
					SD2->D2_BASIMP6	:= VAL(aImpostx[nItSD2][2]:_PIS:_PISQTDE:_QBCPROD:TEXT)
			  		MAFISALT("IT_BASEPS2", VAL(aImpostx[nItSD2][2]:_PIS:_PISQTDE:_QBCPROD:TEXT), nItSD2)
					//SD2->D2_BASEPIS	:= VAL(aImpostx[nItSD2][2]:_PIS:_PISQTDE:_QBCPROD:TEXT)
			  		//MAFISALT("IT_BASEPIS", VAL(aImpostx[nItSD2][2]:_PIS:_PISQTDE:_QBCPROD:TEXT), nItSD2)
			  	EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_PIS:_PISQTDE, "_VALIQPROD")) == "O"
					SD2->D2_ALQIMP6	:= VAL(aImpostx[nItSD2][2]:_PIS:_PISQTDE:_VALIQPROD:TEXT)
					MAFISALT("IT_ALIQPS2", VAL(aImpostx[nItSD2][2]:_PIS:_PISQTDE:_VALIQPROD:TEXT), nItSD2)
					//SD2->D2_ALQPIS	:= VAL(aImpostx[nItSD2][2]:_PIS:_PISQTDE:_VALIQPROD:TEXT)
					//MAFISALT("IT_ALIQPIS", VAL(aImpostx[nItSD2][2]:_PIS:_PISQTDE:_VALIQPROD:TEXT), nItSD2)
				EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_PIS:_PISQTDE, "_VPIS")) == "O"
					SD2->D2_VALIMP6	:= VAL(aImpostx[nItSD2][2]:_PIS:_PISQTDE:_VPIS:TEXT)
					MAFISALT("IT_VALPS2", VAL(aImpostx[nItSD2][2]:_PIS:_PISQTDE:_VPIS:TEXT), nItSD2)
					//SD2->D2_VALPIS	:= VAL(aImpostx[nItSD2][2]:_PIS:_PISQTDE:_VPIS:TEXT)
					//MAFISALT("IT_VALPIS", VAL(aImpostx[nItSD2][2]:_PIS:_PISQTDE:_VPIS:TEXT), nItSD2)
				EndIf

   				//aImpostx[nItSD2][2]:_PIS:_PISQTDE:_CST:REALNAME //CST - 03 - Operação Tributável (base de cálculo = quantidade vendida x alíquota por unidade de produto)

			ElseIf VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_PIS, "_PISNT")) == "O"
			
				SD2->D2_BASIMP6	:= 0
				SD2->D2_ALQIMP6	:= 0
				SD2->D2_VALIMP6	:= 0
				SD2->D2_BASEPIS	:= 0
				SD2->D2_ALQPIS	:= 0
				SD2->D2_VALPIS	:= 0
			
			  	MAFISALT("IT_BASEPIS", 0, nItSD2)
			  	MAFISALT("IT_ALIQPIS", 0, nItSD2)
			  	MAFISALT("IT_VALPIS", 0, nItSD2)
			  	MAFISALT("IT_BASEPS2", 0, nItSD2)
			  	MAFISALT("IT_ALIQPS2", 0, nItSD2)
			  	MAFISALT("IT_VALPS2", 0, nItSD2)

   				//aImpostx[nItSD2][2]:_PIS:_PISNT:_CST: REALNAME //CST - 04 - Operação Tributável (tributação monofásica (alíquota zero)) 06 - Operação Tributável (alíquota zero) 07 - Operação Isenta da Contribuição 08 - Operação Sem Incidência da Contribuição 09 - Operação com Suspensão da Contribuição 				

			ElseIf VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_PIS, "_PISOUTR")) == "O"
				
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_PIS:_PISOUTR, "_VBC")) == "O"
					SD2->D2_BASIMP6	:= VAL(aImpostx[nItSD2][2]:_PIS:_PISOUTR:_VBC:TEXT)
			  		MAFISALT("IT_BASEPS2", VAL(aImpostx[nItSD2][2]:_PIS:_PISOUTR:_VBC:TEXT), nItSD2)
					//SD2->D2_BASIMP5	:= VAL(aImpostx[nItSD2][2]:_PIS:_PISOUTR:_VBC:TEXT)
			  		//MAFISALT("IT_BASEPIS", VAL(aImpostx[nItSD2][2]:_PIS:_PISOUTR:_VBC:TEXT), nItSD2)
			  	EndIf

				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_PIS:_PISOUTR, "_PPIS")) == "O"
					SD2->D2_ALQIMP6	:= VAL(aImpostx[nItSD2][2]:_PIS:_PISOUTR:_PPIS:TEXT)
					MAFISALT("IT_ALIQPS2", VAL(aImpostx[nItSD2][2]:_PIS:_PISOUTR:_PPIS:TEXT), nItSD2)
					//SD2->D2_ALQPIS	:= VAL(aImpostx[nItSD2][2]:_PIS:_PISOUTR:_PPIS:TEXT)
					//MAFISALT("IT_ALIQPIS", VAL(aImpostx[nItSD2][2]:_PIS:_PISOUTR:_PPIS:TEXT), nItSD2)
				EndIf
				
				If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_PIS:_PISOUTR, "_VPIS")) == "O"
					SD2->D2_VALIMP6	:= VAL(aImpostx[nItSD2][2]:_PIS:_PISOUTR:_VPIS:TEXT)
					MAFISALT("IT_VALPS2", VAL(aImpostx[nItSD2][2]:_PIS:_PISOUTR:_VPIS:TEXT), nItSD2)
					//SD2->D2_VALPIS	:= VAL(aImpostx[nItSD2][2]:_PIS:_PISOUTR:_VPIS:TEXT)
					//MAFISALT("IT_VALPIS", VAL(aImpostx[nItSD2][2]:_PIS:_PISOUTR:_VPIS:TEXT), nItSD2)
				EndIf

   				//aImpostx[nItSD2][2]:_PIS:_PISOUTR:_CST:REALNAME //CST - 99 - Outras Operações   				
			EndIf
		EndIf			  				
			
		//ISS		
		If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2], "_ISSQN")) == "O"
			If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ISSQN, "_VBC")) == "O"
				SD2->D2_BASEISS	:= VAL(aImpostx[nItSD2][2]:_ISSQN:_VBC:TEXT)
				MAFISALT("IT_BASEISS", VAL(aImpostx[nItSD2][2]:_ISSQN:_VBC:TEXT), nItSD2)
			EndIf	
			
			If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ISSQN, "_VALIQ")) == "O"
				SD2->D2_ALIQISS	:= VAL(aImpostx[nItSD2][2]:_ISSQN:_VALIQ:TEXT)
		  		MAFISALT("IT_ALIQISS", VAL(aImpostx[nItSD2][2]:_ISSQN:_VALIQ:TEXT), nItSD2)
		  	EndIf

			If VALTYPE(XMLCHILDEX(aImpostx[nItSD2][2]:_ISSQN, "_VISSQN")) == "O"
				SD2->D2_VALISS	:= VAL(aImpostx[nItSD2][2]:_ISSQN:_VISSQN:TEXT)
	    		MAFISALT("IT_VALISS", VAL(aImpostx[nItSD2][2]:_ISSQN:_VISSQN:TEXT), nItSD2)
	   		EndIf
		EndIf

/*		
		//IR

		SD2->D2_BASEIRR	:= 700
		SD2->D2_ALQIRRF	:= 7
		SD2->D2_VALIRRF	:= 70
	
	  	MAFISALT("IT_BASEIRR", 700, 1)
	  	MAFISALT("IT_ALIQIRR", 7, 1)
	  	MAFISALT("IT_VALIRR", 70, 1)
						
		//INSS
		SD2->D2_BASEINS	:= 800
		SD2->D2_ALIQINS	:= 8
		SD2->D2_VALINS	:= 80
	
	  	MAFISALT("IT_BASEINS", 800, 1)
	  	MAFISALT("IT_ALIQINS", 8, 1)
	  	MAFISALT("IT_VALINS", 80, 1)
  */
	EndIf  	    
EndIf
   
Return Nil