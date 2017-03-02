#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'


User Function TelaEstC()

Local nOpc := GD_INSERT+GD_DELETE+GD_UPDATE
Private _aHeadCols := {}

SetPrvt("oDlg1","oBrw1")

_aHeadCols := U_MtHdCols("AIB","PRECOC")          

oDlg1      := MSDialog():New( 106,148,630,1166,"Tabela de Preços de Compra",,,.F.,,,,,,.T.,,,.T. )
oBrw1      := MsNewGetDados():New(004,004,248,500,nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',oDlg1,_aHeadCols[1],_aHeadCols[2] )

oDlg1:Activate(,,,.T.)

Return

