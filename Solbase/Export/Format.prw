#Include 'Protheus.ch'
#Include 'Totvs.ch'

//--------------------------------------------------------------
/*/{Protheus.doc} Format
(long_description)
@author 	Carlos Eduardo Saturnino
@since		25/09/2015
@version 	1.0
@param 		_xVariable, ${param_type}	, (Descrição do parâmetro)
@param 		_cFormat, ${param_type}	, (Descrição do parâmetro)
@param 		_nTam, ${param_type}		, (Descrição do parâmetro)
@return 	${return}					, ${return_description}
@example
(examples)
@see (links_or_references)			
//--------------------------------------------------------------
/*/User Function Format(_xVariable, _cFormat, _nTam)

	Local _nNumber := 0
	Local _cAux	 := ''
	
	Do case
		
	Case _cFormat == 'R$'
		_nNumber 	:= strzero(int(_xVariable),13) + "." + Substr(Transform(int(_xVariable)-_xVariable,"@E 9.99"),3,2)
		_xVariable	:= _nNumber
	Case _cFormat == 'XD'
		_xVariable	:= SubStr(alltrim(_xVariable),1,_nTam)
		_xVariable	:= _xVariable + SPACE(_ntam - len(_xVariable))
	Case _cFormat == 'XE'
		_xVariable	:= alltrim(_xVariable)
		_xVariable	:= SPACE(_ntam - len(_xVariable)) + _xVariable  	
	Case _cFormat == 'N'
		_xVariable	:= alltrim(_xVariable)
		If _xVariable == ''
			_xVariable	:= '0'
		Endif
		_xVariable	:= val(_xVariable)
		_xVariable	:= strzero(_xVariable,_nTam)
	Case _cFormat == 'NZ'
		_xVariable	:= alltrim(str(_xVariable))
		_xVariable	+= replicate('0',_nTam - Len(_xVariable))
	Case _cFormat == 'ZN'
		_xVariable	:= alltrim(str(_xVariable))
		_xVariable	:= replicate('0',_nTam - Len(_xVariable)) + _xVariable
	Case _cFormat == 'ZC'
		_cAux		:= _xVariable
		If ValType(_xVariable) == 'N'
			_xVariable	:= replicate('0',_nTam - Len(Alltrim(Str(_cAux))))
			_xVariable	+= Alltrim(Str(_cAux))
		Else
			_xVariable	:= replicate('0',_nTam - Len(Alltrim(_cAux)))
			_xVariable	+= alltrim(_cAux)
		Endif

	Case _cFormat	== 'DATA'
		_xVariable	:= dtos(_xVariable)
		_cTmpAno	:= substr(_xVariable,1,4)
		_cTmpMes	:= substr(_xVariable,5,2)
		_xVariable	:= substr(_xVariable,7,2) + "/" + alltrim(_cTmpMes) + "/" + alltrim(_cTmpAno)
	End Case

Return (_xVariable)