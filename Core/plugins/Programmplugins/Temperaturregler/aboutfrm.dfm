object About: TAbout
  Left = 505
  Top = 108
  BorderStyle = bsToolWindow
  Caption = 'Info...'
  ClientHeight = 153
  ClientWidth = 281
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 170
    Height = 16
    Caption = 'Temperaturregler-Plugin'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 24
    Width = 217
    Height = 13
    Caption = 'ATtiny2313 Temperaturerfassung mit TSiC206'
  end
  object Label3: TLabel
    Left = 8
    Top = 48
    Width = 250
    Height = 13
    Caption = 'Copyrights (c) 2011-2017 by Dr.-Ing. Christian N'#246'ding'
  end
  object Label4: TLabel
    Left = 8
    Top = 72
    Width = 171
    Height = 13
    Caption = 'Infos unter http://www.pcdimmer.de'
  end
  object Bevel1: TBevel
    Left = 0
    Top = 112
    Width = 281
    Height = 9
    Shape = bsTopLine
  end
  object Label5: TLabel
    Left = 8
    Top = 88
    Width = 134
    Height = 13
    Caption = 'christian@noeding-online.de'
  end
  object Button1: TButton
    Left = 8
    Top = 120
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
  end
end
