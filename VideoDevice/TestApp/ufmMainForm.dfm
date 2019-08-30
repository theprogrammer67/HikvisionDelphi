object frmMainForm: TfrmMainForm
  Left = 0
  Top = 0
  Caption = 'Video device test'
  ClientHeight = 567
  ClientWidth = 903
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
    Width = 903
    Height = 119
    Align = alBottom
    TabOrder = 0
    ExplicitLeft = -8
    ExplicitTop = 416
    ExplicitWidth = 831
    DesignSize = (
      903
      119)
    object btnEnable: TButton
      Left = 664
      Top = 71
      Width = 97
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Enable'
      TabOrder = 0
      OnClick = btnEnableClick
      ExplicitLeft = 592
    end
    object btnDisable: TButton
      Left = 767
      Top = 71
      Width = 98
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Disable'
      TabOrder = 1
      OnClick = btnDisableClick
      ExplicitLeft = 695
    end
    object chkBuiltin: TCheckBox
      Left = 664
      Top = 32
      Width = 97
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Built-In'
      Checked = True
      State = cbChecked
      TabOrder = 2
      ExplicitLeft = 592
    end
    object cbbMode: TComboBox
      Left = 745
      Top = 28
      Width = 120
      Height = 24
      Style = csDropDownList
      Anchors = [akTop, akRight]
      ItemIndex = 1
      TabOrder = 3
      Text = '2 * 2'
      OnChange = cbbModeChange
      Items.Strings = (
        'Single'
        '2 * 2'
        '3 * 3'
        '4 * 4')
      ExplicitLeft = 673
    end
    object lbledtAddress: TLabeledEdit
      Left = 19
      Top = 28
      Width = 161
      Height = 24
      EditLabel.Width = 46
      EditLabel.Height = 16
      EditLabel.Caption = 'Address'
      TabOrder = 4
      Text = '172.20.162.43'
    end
    object lbledtPort: TLabeledEdit
      Left = 186
      Top = 28
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
      Left = 19
      Top = 71
      Width = 161
      Height = 24
      EditLabel.Width = 26
      EditLabel.Height = 16
      EditLabel.Caption = 'User'
      TabOrder = 6
      Text = 'admin'
    end
    object lbledtPassword: TLabeledEdit
      Left = 186
      Top = 71
      Width = 121
      Height = 24
      EditLabel.Width = 55
      EditLabel.Height = 16
      EditLabel.Caption = 'Password'
      TabOrder = 7
      Text = 'admin12345'
    end
    object btnPlayAll: TButton
      Left = 560
      Top = 27
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Play all'
      Default = True
      TabOrder = 8
      OnClick = btnPlayAllClick
    end
    object btnStopAll: TButton
      Left = 560
      Top = 72
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Stop all'
      TabOrder = 9
      OnClick = btnStopAllClick
    end
  end
  object pnlRight: TPanel
    Left = 608
    Top = 0
    Width = 295
    Height = 448
    Align = alRight
    TabOrder = 1
    DesignSize = (
      295
      448)
    object cbbWIndow: TComboBox
      Left = 27
      Top = 25
      Width = 238
      Height = 24
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
      Text = 'Video window 1'
      OnChange = cbbWIndowChange
      Items.Strings = (
        'Video window 1'
        'Video window 2'
        'Video window 3'
        'Video window 4'
        'Video window 5'
        'Video window 6'
        'Video window 7'
        'Video window 8'
        'Video window 9'
        'Video window 10'
        'Video window 11'
        'Video window 12'
        'Video window 13'
        'Video window 14'
        'Video window 15'
        'Video window 16')
    end
    object lbledtChannel: TLabeledEdit
      Left = 27
      Top = 80
      Width = 71
      Height = 24
      EditLabel.Width = 46
      EditLabel.Height = 16
      EditLabel.Caption = 'Channel'
      NumbersOnly = True
      TabOrder = 1
      Text = '2'
    end
    object chkPrintText: TCheckBox
      Left = 27
      Top = 248
      Width = 152
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Print overlay text'
      TabOrder = 2
    end
    object chkVisible: TCheckBox
      Left = 27
      Top = 119
      Width = 97
      Height = 17
      Caption = 'Visible'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object chkEnable: TCheckBox
      Left = 27
      Top = 152
      Width = 97
      Height = 17
      Caption = 'Enable'
      TabOrder = 4
    end
    object mmoText: TMemo
      Left = 27
      Top = 271
      Width = 238
      Height = 122
      Anchors = [akLeft, akBottom]
      Lines.Strings = (
        #1052#1086#1081' '#1076#1103#1076#1103' '#1089#1072#1084#1099#1093' '#1095#1077#1089#1090#1085#1099#1093' '#1087#1088#1072#1074#1080#1083','
        #1050#1086#1075#1076#1072' '#1085#1077' '#1074' '#1096#1091#1090#1082#1091' '#1079#1072#1085#1077#1084#1086#1075','
        #1054#1085' '#1091#1074#1072#1078#1072#1090#1100' '#1089#1077#1073#1103' '#1079#1072#1089#1090#1072#1074#1080#1083
        #1048' '#1083#1091#1095#1096#1077' '#1074#1099#1076#1091#1084#1072#1090#1100' '#1085#1077' '#1084#1086#1075'.'
        #1045#1075#1086' '#1087#1088#1080#1084#1077#1088' '#1076#1088#1091#1075#1080#1084' '#1085#1072#1091#1082#1072';'
        #1053#1086', '#1073#1086#1078#1077' '#1084#1086#1081', '#1082#1072#1082#1072#1103' '#1089#1082#1091#1082#1072
        #1057' '#1073#1086#1083#1100#1085#1099#1084' '#1089#1080#1076#1077#1090#1100' '#1080' '#1076#1077#1085#1100' '#1080' '#1085#1086#1095#1100','
        #1053#1077' '#1086#1090#1093#1086#1076#1103' '#1085#1080' '#1096#1072#1075#1091' '#1087#1088#1086#1095#1100'!')
      TabOrder = 5
    end
    object btnApply: TButton
      Left = 160
      Top = 411
      Width = 105
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Apply'
      TabOrder = 6
      OnClick = btnApplyClick
    end
  end
  object pnlVideo: TPanel
    Left = 0
    Top = 0
    Width = 608
    Height = 448
    Align = alClient
    TabOrder = 2
    ExplicitWidth = 624
    ExplicitHeight = 464
  end
  object appev1: TApplicationEvents
    OnIdle = appev1Idle
    Left = 288
    Top = 65528
  end
end
