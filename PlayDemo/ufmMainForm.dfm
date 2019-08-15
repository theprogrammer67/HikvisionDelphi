object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 486
  ClientWidth = 413
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
  DesignSize = (
    413
    486)
  PixelsPerInch = 120
  TextHeight = 16
  object pnlPictureBox: TPanel
    Left = 8
    Top = 134
    Width = 393
    Height = 305
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelKind = bkFlat
    BevelOuter = bvLowered
    Color = clSkyBlue
    ParentBackground = False
    TabOrder = 0
  end
  object lbledtAddress: TLabeledEdit
    Left = 32
    Top = 24
    Width = 169
    Height = 24
    EditLabel.Width = 77
    EditLabel.Height = 16
    EditLabel.Caption = 'lbledtAddress'
    TabOrder = 1
    Text = '172.20.162.43'
  end
  object lbledtPort: TLabeledEdit
    Left = 207
    Top = 24
    Width = 121
    Height = 24
    EditLabel.Width = 54
    EditLabel.Height = 16
    EditLabel.Caption = 'lbledtPort'
    NumbersOnly = True
    TabOrder = 2
    Text = '8000'
  end
  object lbledtUser: TLabeledEdit
    Left = 40
    Top = 64
    Width = 161
    Height = 24
    EditLabel.Width = 57
    EditLabel.Height = 16
    EditLabel.Caption = 'lbledtUser'
    TabOrder = 3
    Text = 'admin'
  end
  object lbledtPassword: TLabeledEdit
    Left = 207
    Top = 64
    Width = 121
    Height = 24
    EditLabel.Width = 86
    EditLabel.Height = 16
    EditLabel.Caption = 'lbledtPassword'
    TabOrder = 4
    Text = 'admin12345'
  end
  object btnPlay: TButton
    Left = 8
    Top = 445
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'btnPlay'
    TabOrder = 5
    OnClick = btnPlayClick
  end
  object btnStop: TButton
    Left = 89
    Top = 445
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'btnStop'
    TabOrder = 6
    OnClick = btnStopClick
  end
  object lbledtChannel: TLabeledEdit
    Left = 40
    Top = 104
    Width = 71
    Height = 24
    EditLabel.Width = 77
    EditLabel.Height = 16
    EditLabel.Caption = 'lbledtChannel'
    NumbersOnly = True
    TabOrder = 7
    Text = '2'
  end
end
