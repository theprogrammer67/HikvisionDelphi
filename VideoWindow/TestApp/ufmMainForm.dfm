object frmMainForm: TfrmMainForm
  Left = 0
  Top = 0
  Caption = 'Video window test'
  ClientHeight = 370
  ClientWidth = 446
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
  object btnPlayStop: TButton
    Left = 344
    Top = 320
    Width = 71
    Height = 25
    Caption = 'btnPlayStop'
    TabOrder = 0
    OnClick = btnPlayStopClick
  end
  object lbledtAddress: TLabeledEdit
    Left = 32
    Top = 280
    Width = 161
    Height = 24
    EditLabel.Width = 46
    EditLabel.Height = 16
    EditLabel.Caption = 'Address'
    TabOrder = 1
    Text = '172.20.162.43'
  end
  object lbledtPort: TLabeledEdit
    Left = 199
    Top = 280
    Width = 121
    Height = 24
    EditLabel.Width = 23
    EditLabel.Height = 16
    EditLabel.Caption = 'Port'
    NumbersOnly = True
    TabOrder = 2
    Text = '8000'
  end
  object lbledtUser: TLabeledEdit
    Left = 32
    Top = 320
    Width = 161
    Height = 24
    EditLabel.Width = 26
    EditLabel.Height = 16
    EditLabel.Caption = 'User'
    TabOrder = 3
    Text = 'admin'
  end
  object lbledtPassword: TLabeledEdit
    Left = 199
    Top = 320
    Width = 121
    Height = 24
    EditLabel.Width = 55
    EditLabel.Height = 16
    EditLabel.Caption = 'Password'
    TabOrder = 4
    Text = 'admin12345'
  end
  object lbledtChannel: TLabeledEdit
    Left = 344
    Top = 280
    Width = 71
    Height = 24
    EditLabel.Width = 46
    EditLabel.Height = 16
    EditLabel.Caption = 'Channel'
    NumbersOnly = True
    TabOrder = 5
    Text = '2'
  end
  object appev1: TApplicationEvents
    OnIdle = appev1Idle
    Left = 208
    Top = 128
  end
end
