#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'TBICONN.ch'
//------------------------------------------------------------------------
/*/{Protheus.doc} User Function SB_CRETSIT
Geração Registro Situações de Crédito
@author 	Carlos Eduardo Saturnino
@since 		15/09/2016
@version 	1.0
@param 		_cLocal	, ${param_type}, (Caminho para gravação do Arquivo)
@param 		_cFileName	, ${param_type}, (Nome do Arquivo)
@param 		lJob		, ${param_type}, ((Job))
@return 	${return}, ${return_description}
@example	

@see (links_or_references)
//------------------------------------------------------------------------
/*/User Function SB_CRETSIT( _cLocal, _cFileName, lJob )
	
	Local _cLFile, _n
	Local _lPrim		:= .T.
	Local _aCrdSid	:= {}
	Local _cFile		:= ''
	Local _xVarTmp	:= ""
	Local _nHandle	:= 0
	Local _aArea		:= GetArea()
		
	_cLFile  	:= _cLocal + _cFileName
	_nHandle 	:= FCreate(_cLFile)

	_aCrdSid	:= { 	{'B','Credito Bloqueado'		}	,;             
						{'E','Excluido'				}	,;                      
						{'G','Bloq. GARANTIA'		}	,;                
						{'I','Inativo'				}	,;                       
						{'L','Com Limite'				}	,;                    
						{'P','Pre-Cadastro'			}	,;                  
						{'S','Livre s/Bloqueio'		}	 }              
		

	If _nHandle == -1 
		If !lJob
			MsgAlert('Erro de gravação do arquivo no disco. Arquivo ' + _cFileName )
		Else
			Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Erro de gravação do arquivo no disco')
		Endif
	Else
		For _n := 1 To Len(_aCrdSid)
		
			// Inclui a quebra de linha 
			If _lPrim 
				_lPrim := .F.
			Else
				_cFile 	+= CHR(13) + CHR(10)														// QUEBRA DE LINHA
			Endif
			
			_cFile 	+= _aCrdSid[_n][01] + Space(03 - Len(_aCrdSid[_n][01]))					// A | TXTID 		- Codigo								(Pos.001 - N,08 	- 			)
			_cFile 	+= _aCrdSid[_n][02] + Space(30 - Len(_aCrdSid[_n][02]))					// B | TXTDES 	- Descrição							(Pos.004 - C,15 	- 			)
			
		Next _n
		Conout(_cFileName + Space( 17 - Len(_cFileName) ) + '. Arquivo Gravado com sucesso as ' + Time())
	Endif

	FWRITE(_nHandle,_cFile) // GRAVA TEXTO

	_aCrdSid 	:= {}
	_cFile 	:= ''
	FCLOSE(_nHandle)
	RestArea(_aArea)

Return