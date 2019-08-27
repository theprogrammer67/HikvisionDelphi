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
    ExplicitTop = 252
    object btn1: TButton
      Left = 544
      Top = 4
      Width = 75
      Height = 25
      Caption = 'btn1'
      TabOrder = 0
      OnClick = btn1Click
    end
    object btn2: TButton
      Left = 464
      Top = 8
      Width = 75
      Height = 25
      Caption = 'btn2'
      TabOrder = 1
      OnClick = btn2Click
    end
    object btn3: TButton
      Left = 383
      Top = 4
      Width = 75
      Height = 25
      Caption = 'btn3'
      TabOrder = 2
      OnClick = btn3Click
    end
    object btn4: TButton
      Left = 312
      Top = 8
      Width = 75
      Height = 25
      Caption = 'btn4'
      TabOrder = 3
      OnClick = btn4Click
    end
    object btnPlayStop: TButton
      Left = 17
      Top = 4
      Width = 71
      Height = 25
      Caption = 'btnPlayStop'
      TabOrder = 4
      OnClick = btnPlayStopClick
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
  object appev1: TApplicationEvents
    OnIdle = appev1Idle
    Left = 208
    Top = 128
  end
end
