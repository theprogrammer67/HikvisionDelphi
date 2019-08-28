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
    DesignSize = (
      633
      39)
    object btnRemoveParent: TButton
      Left = 504
      Top = 4
      Width = 115
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Remove parent'
      TabOrder = 0
      OnClick = btnRemoveParentClick
    end
    object btnPlayStop: TButton
      Left = 427
      Top = 4
      Width = 71
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'btnPlayStop'
      TabOrder = 1
      OnClick = btnPlayStopClick
    end
    object cbbMode: TComboBox
      Left = 11
      Top = 4
      Width = 145
      Height = 24
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 2
      Text = 'Single'
      OnChange = cbbModeChange
      Items.Strings = (
        'Single'
        '2 * 2'
        '3 * 3'
        '4 * 4')
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
  end
  object appev1: TApplicationEvents
    OnIdle = appev1Idle
    Left = 208
    Top = 128
  end
end
