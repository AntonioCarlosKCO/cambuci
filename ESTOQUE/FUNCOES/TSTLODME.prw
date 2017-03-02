#include 'protheus.ch'
#include 'parmtype.ch'

user function TSTLODME()

	LOCAL cTxtEtq	 := ""
	LOCAL oFile		 := ""				
	LOCAL cDirTmp	 := GETMV( "PR_DIRETQ",, "C:\TEMP\" )	// diretorio 
	LOCAL cArqSaida_ := ""									// 
	LOCAL cSaida	 := "EtqSaida.prn"						// arquivo de saida
	LOCAL cEofTXT	 := Chr(13) + Chr(10)					// indicador de Final de Linha
	LOCAL cPorta_  	 := "LPT1" 								// define a porta  de impressao

	cTxtEtq += 'DOWNLOAD F,"LAYOUT E.BAS"' + cEofTXT
	cTxtEtq += 'OPEN "LAYOUT E.DAT" FOR INPUT AS #1' + cEofTXT
	cTxtEtq += 'FOUT 0,1,415' + cEofTXT
	cTxtEtq += 'CLOSE #1' + cEofTXT
	cTxtEtq += 'EOP' + cEofTXT
	cTxtEtq += 'DOWNLOAD F,"LAYOUT E.DAT",415,' + cEofTXT
	cTxtEtq += 'n' + cEofTXT
	cTxtEtq += 'M1500' + cEofTXT
	cTxtEtq += 'd' + cEofTXT
	cTxtEtq += 'L' + cEofTXT
	cTxtEtq += 'D11' + cEofTXT
	cTxtEtq += 'R0000' + cEofTXT
	cTxtEtq += 'ySW1' + cEofTXT
	cTxtEtq += 'FB+' + cEofTXT
	cTxtEtq += 'A2' + cEofTXT
	cTxtEtq += '4911S0100180162P028P022GIROPAZE IND. E COM. LTDA - EPP' + cEofTXT
	cTxtEtq += 'FI+' + cEofTXT
	cTxtEtq += '4911S0103250263P025P026NF-e: 147479' + cEofTXT
	cTxtEtq += '1X1100003260265L001218' + cEofTXT
	cTxtEtq += 'FI-' + cEofTXT
	cTxtEtq += '4911S0100280216P011P010RUA PAULO STEOLA 128' + cEofTXT
	cTxtEtq += '4911S0100280251P016P015GUARULHOS - SP' + cEofTXT
	cTxtEtq += '4911S0100280281P012P010TRANSP:' + cEofTXT
	cTxtEtq += '4911S0100280311P017P015PRсPRIO !! RETIRA !!' + cEofTXT
	cTxtEtq += '4911S0103930373P009P007quinta-feira, 4 de outubro de 2012 13:32:23' + cEofTXT
	cTxtEtq += 'Q0001' + cEofTXT
	cTxtEtq += 'E' + cEofTXT
	
	/*
	cTxtEtq += 'DOWNLOAD F,"LAYOUT E.BAS"' + cEofTXT
	cTxtEtq += 'OPEN "LAYOUT E.DAT" FOR INPUT AS #1' + cEofTXT
	cTxtEtq += 'FOUT 0,1,1743' + cEofTXT
	cTxtEtq += 'CLOSE #1' + cEofTXT
	cTxtEtq += 'EOP' + cEofTXT
	cTxtEtq += 'DOWNLOAD F,"LAYOUT E.DAT",1743,' + cEofTXT
	cTxtEtq += 'n' + cEofTXT
	cTxtEtq += 'M1500' + cEofTXT
	cTxtEtq += 'd' + cEofTXT
	cTxtEtq += 'ICPgfx0' + cEofTXT
	cTxtEtq += '    R T ,,   ЪЪЪ                                                                                                       дЪаЭsфЪдЪpаОеЪцЪаР0ацеЪцЪ'
	cTxtEtq += chr(144)+'AеЪбЪаЧ8аЦ▌8еЪбЪаЭa├gдЪбЪаЯ├a├дЪбЪаЯагqагдЪбЪ╟ац0аццЪбЪAAцЪбЪ▌8аЦ▌8аЦ'
	cTxtEtq += chr(143)+'цЪаЪаЫ├a├a┤цЪаЪаЬa├a├cцЪаЪаЛqагqагqцЪаЪал0ац0ац0цЪаЪааAAбЪаЪаЦ▌8аЦ▌8аЦ▌?бЪаЪa├a├a├?бЪаЧa├a├a÷бЪаЪqагqагqаобЪаЩ0ац0ац0аобЪаЬAAAбЪаЬаЦ▌8аЦ▌8аЦ▌;бЪаПa├a├a├бЪаФa├a├a┐бЪаГqагqагqагбЪаЦ0ац0ац0ацбЪаПAAAбЪаьаЦ▌8аЦ▌8аЦ▌8бЪаьa├a├a├бЪ├a├a├a├аЪагqагqагqагаЪ┐0ац0ац0ац?аЪAAAаЪ8аЦ▌8аЦ▌8аЦ▌8бЪa├a├a├аЪ├a├a├a├?аЪагqагqагqаг?аЪац0ац0ац0ац?аЪAAAаЪ8аЦ▌8аЦ▌8аЦ▌8бЪa├a├a├аЪ├a├a├a├аЪагqагqагqагаЪац0ац0ац0ац?аЪAAAаЪ8аЦ▌8аЦ▌8аЦ▌8бЪa├a├a├аЪ├a├a├a├?аЪагqагqагqаг?аЪац0ац0ац0ац?аЪAAAаЪ8аЦ▌8аЦ▌8аЦ▌8аЪ≤a├a├a├аЪафa├a├a├аЪагqагqагqагаЪац0ац0ац0аббЪаПAAAбЪаЬаЦ▌8аЦ▌8аЦ▌8бЪаХa├a├a├бЪаФa├a├a┐бЪаВqагqагqагбЪаШ0ац0ац0ацбЪаЬAAAбЪаЬаЦ▌8аЦ▌8аЦ▌?бЪаЭa├a├a├бЪаЧa├a├a'
	cTxtEtq += chr(143)+'бЪаЪqагqагqаъбЪаЪ0ац0ац0©бЪаЪааAAбЪаЪац▌8аЦ▌8аЦ▌бЪаЪаА├a├a┘цЪаЪаЬa├a├aцЪаЪаЭqагqагsцЪаЪаЭ0ац0ац/цЪбЪAAцЪбЪ▌8аЦ▌8аЦ©цЪбЪафa├`дЪбЪаА├a├дЪбЪаЫагqагдЪбЪаЭац0ацдЪцЪAдЪцЪаЬаЦ▌8еЪцЪаЭA└еЪдЪ≤!фЪ' + cEofTXT
	cTxtEtq += 'L' + cEofTXT
	cTxtEtq += 'D11' + cEofTXT
	cTxtEtq += 'R0000' + cEofTXT
	cTxtEtq += 'ySW1' + cEofTXT
	cTxtEtq += 'FB+' + cEofTXT
	cTxtEtq += 'A2' + cEofTXT
	cTxtEtq += '4911S0100180162P028P022GIROPAZE IND. E COM. LTDA - EPP' + cEofTXT
	cTxtEtq += 'FI+' + cEofTXT
	cTxtEtq += '4911S0103250263P025P026NF-e: 147479' + cEofTXT
	cTxtEtq += '1X1100003260265L001218' + cEofTXT
	cTxtEtq += 'FI-' + cEofTXT
	cTxtEtq += '4911S0100280216P011P010RUA PAULO STEOLA 128' + cEofTXT
	cTxtEtq += '4911S0100280251P016P015GUARULHOS - SP' + cEofTXT
	cTxtEtq += '4911S0100280281P012P010TRANSP:' + cEofTXT
	cTxtEtq += '4911S0100280311P017P015PRсPRIO !! RETIRA !!' + cEofTXT
	cTxtEtq += '4911S0103930373P009P007quinta-feira, 4 de outubro de 2012 13:32:23' + cEofTXT
	cTxtEtq += '1Y1100004700039gfx0' + cEofTXT
	cTxtEtq += 'Q0001' + cEofTXT
	cTxtEtq += 'E' + cEofTXT
	cTxtEtq += 'xCGgfx0' + cEofTXT
	cTxtEtq += 'zC' + cEofTXT
	*/

	/* ------------------------------------------------------------------------------------------------
	( TXT ) Gera o arquivo fisico
	------------------------------------------------------------------------------------------------ */
	If !FILE( cDirTmp )
			MAKEDIR( cDirTmp )
	EndIf
	
	cArqSaida_ := cDirTmp + cSaida	// Diretorio + Arquivo de Saida 

	oFile := Fcreate( cArqSaida_, 0 )

	FWrite( oFile , cTxtEtq, LEN( cTxtEtq ) )
						
	FClose( oFile )

	/* ------------------------------------------------------------------------------------------------
	( Envio ) ENVIO DO ARQUIVO DO CсDIGO DA(S) ETIQUETA(S) PARA A IMPRESSORA LPT1
	------------------------------------------------------------------------------------------------ */
	Copy FILE &cArqSaida_ TO &cPorta_
	ALERT( "ENVIOU ETIQUETA" )		
				
	/* ------------------------------------------------------------------------------------------------
	( FIM ) FECHA O ARQUIVO E APAGA
	------------------------------------------------------------------------------------------------ */
	FClose( cArqSaida_ )	// Fecha o arquivo de saida
	FErase( cArqSaida_ )	// aPaga o arquivo de saida

return