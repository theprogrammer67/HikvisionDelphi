object frmMainForm: TfrmMainForm
  Left = 0
  Top = 0
  Caption = 'Video panel test'
  ClientHeight = 389
  ClientWidth = 633
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object pnlControls: TPanel
    Left = 0
    Top = 348
    Width = 633
    Height = 41
    Align = alBottom
    BevelEdges = [beTop]
    BevelKind = bkFlat
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 252
    object btnSIngle: TButton
      Left = 24
      Top = 8
      Width = 75
      Height = 25
      Caption = 'btnSIngle'
      TabOrder = 0
    end
    object btnMulti: TButton
      Left = 112
      Top = 8
      Width = 75
      Height = 25
      Caption = 'btnMulti'
      TabOrder = 1
    end
  end
  object pnlVideo: TPanel
    Left = 0
    Top = 0
    Width = 633
    Height = 348
    Align = alClient
    BevelOuter = bvNone
    Color = clSkyBlue
    ParentBackground = False
    TabOrder = 1
    ExplicitTop = 4
  end
end
