object frmMainForm: TfrmMainForm
  Left = 0
  Top = 0
  Caption = 'Video panel test'
  ClientHeight = 438
  ClientWidth = 714
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
    Top = 397
    Width = 714
    Height = 41
    Align = alBottom
    BevelEdges = [beTop]
    BevelKind = bkFlat
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      714
      39)
    object btnPlayStop: TButton
      Left = 639
      Top = 4
      Width = 71
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'btnPlayStop'
      Default = True
      TabOrder = 0
      OnClick = btnPlayStopClick
    end
    object cbbMode: TComboBox
      Left = 11
      Top = 4
      Width = 145
      Height = 24
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 1
      Text = 'Single'
      OnChange = cbbModeChange
      Items.Strings = (
        'Single'
        '2 * 2'
        '3 * 3'
        '4 * 4')
    end
    object Button1: TButton
      Left = 496
      Top = 4
      Width = 137
      Height = 25
      Caption = 'Authorize user'
      TabOrder = 2
      OnClick = btnAuthorizeClick
    end
    object btnDestroyParentWindow: TButton
      Left = 288
      Top = 4
      Width = 169
      Height = 25
      Caption = 'btnDestroyParentWindow'
      TabOrder = 3
      OnClick = btnDestroyParentWindowClick
    end
  end
  object pgcPages: TPageControl
    Left = 0
    Top = 0
    Width = 714
    Height = 397
    ActivePage = tsSettings
    Align = alClient
    TabOrder = 1
    object tsVideo: TTabSheet
      Caption = 'Video'
      object pnlVideo: TPanel
        Left = 0
        Top = 0
        Width = 706
        Height = 366
        Align = alClient
        BevelOuter = bvNone
        Color = clSkyBlue
        ParentBackground = False
        TabOrder = 0
      end
    end
    object tsSettings: TTabSheet
      Caption = 'Settings'
      ImageIndex = 1
      OnShow = tsSettingsShow
      object lbledtAddress: TLabeledEdit
        Left = 32
        Top = 32
        Width = 161
        Height = 24
        EditLabel.Width = 46
        EditLabel.Height = 16
        EditLabel.Caption = 'Address'
        TabOrder = 0
        Text = '172.20.162.43'
      end
      object lbledtPort: TLabeledEdit
        Left = 199
        Top = 32
        Width = 121
        Height = 24
        EditLabel.Width = 23
        EditLabel.Height = 16
        EditLabel.Caption = 'Port'
        NumbersOnly = True
        TabOrder = 1
        Text = '8000'
      end
      object lbledtUser: TLabeledEdit
        Left = 32
        Top = 75
        Width = 161
        Height = 24
        EditLabel.Width = 26
        EditLabel.Height = 16
        EditLabel.Caption = 'User'
        TabOrder = 2
        Text = 'admin'
      end
      object lbledtPassword: TLabeledEdit
        Left = 199
        Top = 75
        Width = 121
        Height = 24
        EditLabel.Width = 55
        EditLabel.Height = 16
        EditLabel.Caption = 'Password'
        TabOrder = 3
        Text = 'admin12345'
      end
      object grpWindow: TGroupBox
        Left = 32
        Top = 105
        Width = 649
        Height = 240
        Caption = 'Video window'
        TabOrder = 4
        object cbbWIndow: TComboBox
          Left = 27
          Top = 25
          Width = 198
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
        object btnApply: TButton
          Left = 509
          Top = 204
          Width = 115
          Height = 25
          Caption = 'Apply'
          TabOrder = 1
          OnClick = btnApplyClick
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
          TabOrder = 2
          Text = '2'
        end
        object mmoText: TMemo
          Left = 248
          Top = 23
          Width = 374
          Height = 122
          Lines.Strings = (
            #1052#1086#1081' '#1076#1103#1076#1103' '#1089#1072#1084#1099#1093' '#1095#1077#1089#1090#1085#1099#1093' '#1087#1088#1072#1074#1080#1083','
            #1050#1086#1075#1076#1072' '#1085#1077' '#1074' '#1096#1091#1090#1082#1091' '#1079#1072#1085#1077#1084#1086#1075','
            #1054#1085' '#1091#1074#1072#1078#1072#1090#1100' '#1089#1077#1073#1103' '#1079#1072#1089#1090#1072#1074#1080#1083
            #1048' '#1083#1091#1095#1096#1077' '#1074#1099#1076#1091#1084#1072#1090#1100' '#1085#1077' '#1084#1086#1075'.'
            #1045#1075#1086' '#1087#1088#1080#1084#1077#1088' '#1076#1088#1091#1075#1080#1084' '#1085#1072#1091#1082#1072';'
            #1053#1086', '#1073#1086#1078#1077' '#1084#1086#1081', '#1082#1072#1082#1072#1103' '#1089#1082#1091#1082#1072
            #1057' '#1073#1086#1083#1100#1085#1099#1084' '#1089#1080#1076#1077#1090#1100' '#1080' '#1076#1077#1085#1100' '#1080' '#1085#1086#1095#1100','
            #1053#1077' '#1086#1090#1093#1086#1076#1103' '#1085#1080' '#1096#1072#1075#1091' '#1087#1088#1086#1095#1100'!')
          TabOrder = 3
        end
        object chkPrintText: TCheckBox
          Left = 27
          Top = 119
          Width = 152
          Height = 17
          Caption = 'Print overlay text'
          TabOrder = 4
        end
        object chkVisible: TCheckBox
          Left = 27
          Top = 151
          Width = 97
          Height = 17
          Caption = 'Visible'
          Checked = True
          State = cbChecked
          TabOrder = 5
        end
        object chkEnable: TCheckBox
          Left = 27
          Top = 184
          Width = 97
          Height = 17
          Caption = 'Enable'
          TabOrder = 6
        end
      end
      object btnAuthorize: TButton
        Left = 352
        Top = 74
        Width = 137
        Height = 25
        Caption = 'Authorize user'
        TabOrder = 5
        OnClick = btnAuthorizeClick
      end
    end
  end
  object appev1: TApplicationEvents
    OnIdle = appev1Idle
    Left = 592
    Top = 16
  end
end
