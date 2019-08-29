object frmMainForm: TfrmMainForm
  Left = 0
  Top = 0
  Caption = 'Video device test'
  ClientHeight = 534
  ClientWidth = 831
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
  PixelsPerInch = 120
  TextHeight = 16
  object pnlBottom: TPanel
    Left = 0
    Top = 464
    Width = 831
    Height = 70
    Align = alBottom
    Caption = 'pnlBottom'
    TabOrder = 0
  end
  object pnlRight: TPanel
    Left = 624
    Top = 0
    Width = 207
    Height = 464
    Align = alRight
    Caption = 'pnlRight'
    TabOrder = 1
  end
  object pnlVideo: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 464
    Align = alClient
    Caption = 'pnlVideo'
    TabOrder = 2
    ExplicitLeft = 248
    ExplicitTop = 80
    ExplicitWidth = 185
    ExplicitHeight = 41
  end
end
