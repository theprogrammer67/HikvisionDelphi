object frmMainForm: TfrmMainForm
  Left = 0
  Top = 0
  Caption = 'Video device test'
  ClientHeight = 567
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
    Top = 448
    Width = 831
    Height = 119
    Align = alBottom
    TabOrder = 0
    ExplicitLeft = 8
    ExplicitTop = 440
    object btnEnable: TButton
      Left = 24
      Top = 72
      Width = 75
      Height = 25
      Caption = 'Enable'
      TabOrder = 0
      OnClick = btnEnableClick
    end
    object btnDisable: TButton
      Left = 105
      Top = 72
      Width = 75
      Height = 25
      Caption = 'Disable'
      TabOrder = 1
      OnClick = btnDisableClick
    end
    object chkBuiltin: TCheckBox
      Left = 24
      Top = 32
      Width = 97
      Height = 17
      Caption = 'Builtin'
      TabOrder = 2
    end
    object cbbMode: TComboBox
      Left = 105
      Top = 28
      Width = 120
      Height = 24
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 3
      Text = 'Single'
      OnChange = cbbModeChange
      Items.Strings = (
        'Single'
        '2 * 2'
        '3 * 3'
        '4 * 4')
    end
    object lbledtAddress: TLabeledEdit
      Left = 328
      Top = 32
      Width = 161
      Height = 24
      EditLabel.Width = 46
      EditLabel.Height = 16
      EditLabel.Caption = 'Address'
      TabOrder = 4
      Text = '172.20.162.43'
    end
    object lbledtPort: TLabeledEdit
      Left = 495
      Top = 32
      Width = 121
      Height = 24
      EditLabel.Width = 23
      EditLabel.Height = 16
      EditLabel.Caption = 'Port'
      NumbersOnly = True
      TabOrder = 5
      Text = '8000'
    end
    object lbledtUser: TLabeledEdit
      Left = 328
      Top = 75
      Width = 161
      Height = 24
      EditLabel.Width = 26
      EditLabel.Height = 16
      EditLabel.Caption = 'User'
      TabOrder = 6
      Text = 'admin'
    end
    object lbledtPassword: TLabeledEdit
      Left = 495
      Top = 75
      Width = 121
      Height = 24
      EditLabel.Width = 55
      EditLabel.Height = 16
      EditLabel.Caption = 'Password'
      TabOrder = 7
      Text = 'admin12345'
    end
    object btnAuthorize: TButton
      Left = 648
      Top = 74
      Width = 137
      Height = 25
      Caption = 'Authorize user'
      TabOrder = 8
    end
  end
  object pnlRight: TPanel
    Left = 624
    Top = 0
    Width = 207
    Height = 448
    Align = alRight
    TabOrder = 1
    ExplicitHeight = 464
  end
  object pnlVideo: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 448
    Align = alClient
    TabOrder = 2
    ExplicitHeight = 464
  end
end
