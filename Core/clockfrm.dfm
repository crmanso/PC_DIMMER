object clockform: Tclockform
  Left = 611
  Top = 107
  Width = 348
  Height = 377
  Caption = 'Uhrzeit'
  Color = clBtnFace
  TransparentColorValue = clFuchsia
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001001010000001002000680400001600000028000000100000002000
    0000010020000000000000000000120B0000120B000000000000000000000000
    0000000000000000000000000000B9B1B126A39393759F8888A6A69595B39F8B
    8BAE91787895928181549C95950C000000000000000000000000000000000000
    000000000000DEDCDC01BFB3B392B8A8A8F5C2B2B3FFBFAEAEFFB9A9A9FFB3A0
    A0FFAB9596FFA1898BFF947C7DD9938686520000000000000000000000000000
    0000E9E9E905BDB0B0A0CCBFC0FFCDC0BFFFD1C1B7FFE1D9D0FFDEB8B4FFE2C4
    BCFFD7CCBEFFB8A299FFA48C8DFF977D7DFF9485858800000000000000000000
    0000CBBFBF95D4CACCFFD0C0BBFFE8D5B8FFFFF9DDFFFFFFF2FFF8DCD6FFFCE7
    DCFFFFFFE8FFFEF2CEFFD0B297FFA28888FF957A7BFF9C93936E00000000DDD6
    D635D1C7C8FDDACDCAFFE9C29BFFFFEBC2FFFFF4D5FFFFF6E0FFFFFCEBFFFFFA
    E5FFFFF4D8FFFFEDC7FFFFDDADFFCD9F7FFFA08789FF937A7AF2ACABAB1FD4CA
    CAB4E2DDE0FFDCB193FFFCC690FFFBDAAFFFFEEBC6FFFFF3D2FFFFF8DAFFFFF5
    D6FFFFEECAFFFDE0B6FFFACC9CFFF8B67CFFB28978FF9C8588FF988B8B7AD4CA
    CBEEE3D7D4FFEAA46DFFF7B87EFFF8C898FFFBD8ACFFD1BB98FF5C5444FF8779
    63FF786A55FF78624CFFC4966CFFFAAE6EFFCF8B60FFA38D90FF937E7EA3DBD5
    D7EFE5CEC0FFE68B59FFF1A774FFF6B982FFFEC790FF524434FF030303FF0908
    06FF040302FF050402FF19120BFFEE8A4FFFD57240FFAA9392FF9D8A8BB4DFDB
    DDEFE7CBBAFFE4865BFFF2B78EFFFAD0A1FFFFCF9DFFBE9E7AFF1D1C1BFF0C0A
    07FF978168FFD5AC81FFF9B275FFE87237FFD05A27FFB09B99FFA08E8FAFDCD5
    D7EFE8D3CBFFF1B986FFFDDCAFFFFCE0B6FFFDE7C0FFFFEEC7FFC7BC9BFF1816
    13FF191511FFB8A181FFFCD4A6FFFBBC82FFD4804BFFB3A0A1FFA19090A8DFD6
    D7C1EBE5E6FFE7B790FFFFE4B9FFFEEBC6FFFFF0CEFFFFF2D2FFFFF8D7FFFEF7
    D4FF3A3830FF110F0DFFCEB491FFFECE99FFC6957BFFB7A8ABFFA495956EE8E3
    E354E5E1E4FFE5CEC1FFF7D6ACFFFFF6D6FFFFF4D9FFFFF5DEFFFFFAE4FFFFFC
    E1FFFBEECFFF918873FFBAAB8BFFE1AE83FFC3ADA9FFB09E9FEDB8B1B114FBFA
    FA06DCD3D4CFEEEBEDFFE2C6B4FFF7E2C3FFFFFCE8FFFFFEF1FFF3CFC5FFF8DD
    CDFFFFFFE5FFFFFCD7FFE8C49EFFC7AEA5FFC3B5B7FFAFA1A176000000000000
    0000F6F4F43EDAD1D1F3EEEAECFFE5D3CAFFE9D5C4FFF5EBE2FFEDC0B6FFF0CE
    BEFFF0E1CBFFDBC1AAFFD3C0BBFFCDC2C4FFB8AAAAADD7D5D501000000000000
    000000000000F4F2F238DBD2D2CBE5E0E1FFEBE4E3FFE6DAD5FFE7DAD2FFE4D6
    CEFFDFD0CCFFDBD2D4FFCBC0C1FFBAABAB8FDEDCDC0800000000000000000000
    00000000000000000000F5F3F304DDD5D54FD7CDCDB1D9D1D2E9DAD3D4EED6CD
    CEEECFC4C5EECCC0C0AFCCC2C24000000000000000000000000000000000FC3F
    0000E00F0000C003000080030000800100000001000000000000000000000000
    000000000000000100008001000080030000C0030000E007FFFFF81FFFFF}
  OldCreateOrder = False
  Position = poDefaultPosOnly
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDeactivate = FormDeactivate
  OnHide = FormHide
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object clock: TPLNClock
    Left = 0
    Top = 0
    Width = 340
    Height = 347
    Date = True
    TimeSet = 39428.874598333340000000
    SpiderClock = False
    HrStyle = hsNumber
    HrSize = 10
    MinSize = 1
    MinFontSize = 16
    ColorHr = clBlack
    ColorMin = clBlack
    ColorHandHr = clBlack
    ColorHandMin = clBlack
    ColorHandSec = clBlue
    WidthHandMin = 5
    WidthHr = 0
    WidthMin = 5
    CenterSize = 7
    CenterCol = clBlack
    Align = alClient
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    PopupMenu = PopupMenu1
    ShowHint = False
    TabOrder = 0
    OnChangeSec = clockChangeSec
    OnMouseDown = clockMouseDown
    BevelWidth = 3
    BevelInner = bvNone
    BevelOuter = bvNone
    object timelbl: TLabel
      Left = 66
      Top = 220
      Width = 208
      Height = 62
      Caption = '23:55:00'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -53
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
      OnClick = CHLed1Click
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 304
    Top = 8
    object ransparenteinaus1: TMenuItem
      Caption = 'Transparenz ein/aus'
      OnClick = ransparenteinaus1Click
    end
    object Rahmeneinaus1: TMenuItem
      Caption = 'Rahmen ein/aus'
      OnClick = Rahmeneinaus1Click
    end
    object Sekundenflieendnormal1: TMenuItem
      Caption = 'Sekunden flie'#223'end/normal'
      OnClick = Sekundenflieendnormal1Click
    end
    object Digitaluhreinaus1: TMenuItem
      Caption = 'Digitaluhr ein/aus'
      OnClick = Digitaluhreinaus1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Uhrschlieen1: TMenuItem
      Caption = 'Uhr schlie'#223'en'
      OnClick = Uhrschlieen1Click
    end
  end
end
