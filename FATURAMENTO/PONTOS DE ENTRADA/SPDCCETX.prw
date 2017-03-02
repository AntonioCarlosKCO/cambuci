#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} SPDCCETX
//PONTO DE ENTRADA PARA OFERECER POSSIBILIDADE DE ALTERAR VOLUME/ESPÉCIE/PESO AO EMITIR CARTA DE CORREÇÃO
@author Djalma Borges - Global
@since 15/02/2017
@type function
/*/

user function SPDCCETX()

	Private oDlg
	Private oVolume1
	Private oVolume2
	Private oVolume3
	Private oVolume4
	Private oVolume5
	Private oVolume6
	Private nVolume1 := SF2->F2_VOLUME1
	Private nVolume2 := SF2->F2_VOLUME2
	Private nVolume3 := SF2->F2_VOLUME3
	Private nVolume4 := SF2->F2_VOLUME4
	Private nVolume5 := SF2->F2_VOLUME5
	Private nVolume6 := SF2->F2_VOLUME6
	Private oEspeci1
	Private oEspeci2
	Private oEspeci3
	Private oEspeci4
	Private oEspeci5
	Private oEspeci6
	Private cEspeci1 := SF2->F2_ESPECI1
	Private cEspeci2 := SF2->F2_ESPECI2
	Private cEspeci3 := SF2->F2_ESPECI3
	Private cEspeci4 := SF2->F2_ESPECI4
	Private cEspeci5 := SF2->F2_ESPECI5
	Private cEspeci6 := SF2->F2_ESPECI6
	Private oPesoBruto
	Private nPesoBruto := SF2->F2_PBRUTO
	
	If MsgYesNo("Deseja alterar [ VOLUME / ESPÉCIE / PESO BRUTO ] para a Nota Fiscal " + SF2->F2_DOC + " Série " + SF2->F2_SERIE + " ?") == .F.
		Return .T.
	EndIf
	
	Define MSDialog oDlg Title "ALTERAÇÃO DE [ VOLUME / ESPÉCIE / PESO BRUTO ]" From 0,0 To 337,363 Pixel
		
		@10,10 Say "VOLUME 1: " Pixel Of oDlg
		@10,40 MSGet oVolume1 Var nVolume1 Size 20,10 Pixel PICTURE PesqPict("SF2","F2_VOLUME6") Of oDlg
		
		@10,090 Say "ESPÉCIE 1: " Pixel Of oDlg
		@10,120 MSGet oEspeci1 Var cEspeci1 Size 50,10 Pixel PICTURE PesqPict("SF2","F2_ESPECI1") F3 "SZ3x" VALID ExistCpo('SZ3',cEspeci1,2) Of oDlg
		
		@25,10 Say "VOLUME 2: " Pixel Of oDlg
		@25,40 MSGet oVolume2 Var nVolume2 Size 20,10 Pixel PICTURE PesqPict("SF2","F2_VOLUME6")  Of oDlg
		
		@25,090 Say "ESPÉCIE 2: " Pixel Of oDlg
		@25,120 MSGet oEspeci2 Var cEspeci2 Size 50,10 Pixel PICTURE PesqPict("SF2","F2_ESPECI1") F3 "SZ3x" VALID ExistCpo('SZ3',cEspeci2,2) Of oDlg

		@40,10 Say "VOLUME 3: " Pixel Of oDlg
		@40,40 MSGet oVolume3 Var nVolume3 Size 20,10 Pixel PICTURE PesqPict("SF2","F2_VOLUME6") Of oDlg
		
		@40,090 Say "ESPÉCIE 3: " Pixel Of oDlg
		@40,120 MSGet oEspeci3 Var cEspeci3 Size 50,10 Pixel PICTURE PesqPict("SF2","F2_ESPECI1") F3 "SZ3x" VALID ExistCpo('SZ3',cEspeci3,2) Of oDlg
		
		@55,10 Say "VOLUME 4: " Pixel Of oDlg
		@55,40 MSGet oVolume4 Var nVolume4 Size 20,10 Pixel PICTURE PesqPict("SF2","F2_VOLUME6") Of oDlg
		
		@55,090 Say "ESPÉCIE 4: " Pixel Of oDlg
		@55,120 MSGet oEspeci4 Var cEspeci4 Size 50,10 Pixel PICTURE PesqPict("SF2","F2_ESPECI1") F3 "SZ3x" VALID ExistCpo('SZ3',cEspeci4,2) Of oDlg¢

		@70,10 Say "VOLUME 5: " Pixel Of oDlg
		@70,40 MSGet oVolume5 Var nVolume5 Size 20,10 Pixel PICTURE PesqPict("SF2","F2_VOLUME6") Of oDlg
		
		@70,090 Say "ESPÉCIE 5: " Pixel Of oDlg
		@70,120 MSGet oEspeci5 Var cEspeci5 Size 50,10 Pixel PICTURE PesqPict("SF2","F2_ESPECI1") F3 "SZ3x" VALID ExistCpo('SZ3',cEspeci5,2) Of oDlg
		
		@85,10 Say "VOLUME 6: " Pixel Of oDlg
		@85,40 MSGet oVolume6 Var nVolume6 Size 20,10 Pixel PICTURE PesqPict("SF2","F2_VOLUME6") Of oDlg				
		
		@85,090 Say "ESPÉCIE 6: " Pixel Of oDlg
		@85,120 MSGet oEspeci6 Var cEspeci6 Size 50,10 Pixel PICTURE PesqPict("SF2","F2_ESPECI1") F3 "SZ3x" VALID ExistCpo('SZ3',cEspeci6,2) Of oDlg

		@110,10 Say "PESO BRUTO: " Pixel Of oDlg
		@110,50 MSGet oPesoBruto Var nPesoBruto Size 50,10 PICTURE PesqPict("SF2","F2_PBRUTO") Pixel Of oDlg

		@140,10 Button oBtnOk     Prompt "Ok"       Size 30,15 Pixel Action {||ALTESPVLPB(), oDlg:End()} Of oDlg
		@140,70 Button oBtnCancel Prompt "Cancelar" Size 30,15 Pixel Action {||oDlg:End()} Of oDlg
		

	Activate MSDialog oDlg Centered
	
return .T.

Static Function ALTESPVLPB()

	RECLOCK("SF2", .F.)
		SF2->F2_VOLUME1 := nVolume1
		SF2->F2_VOLUME2 := nVolume2
		SF2->F2_VOLUME3 := nVolume3
		SF2->F2_VOLUME4 := nVolume4
		SF2->F2_VOLUME5 := nVolume5
		SF2->F2_VOLUME6 := nVolume6
		SF2->F2_ESPECI1 := cEspeci1
		SF2->F2_ESPECI2 := cEspeci2
		SF2->F2_ESPECI3 := cEspeci3
		SF2->F2_ESPECI4 := cEspeci4
		SF2->F2_ESPECI5 := cEspeci5
		SF2->F2_ESPECI6 := cEspeci6
		SF2->F2_PBRUTO  := nPesoBruto
	SF2->(MSUNLOCK())

Return