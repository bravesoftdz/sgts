inherited SgtsRbkTestForm: TSgtsRbkTestForm
  Caption = #1058#1077#1089#1090#1086#1074#1099#1081' '#1089#1087#1088#1072#1074#1086#1095#1085#1080#1082
  ClientHeight = 423
  ClientWidth = 482
  Constraints.MinHeight = 450
  Constraints.MinWidth = 490
  ExplicitWidth = 490
  ExplicitHeight = 477
  PixelsPerInch = 96
  TextHeight = 13
  inherited BevelStatus: TBevel
    Top = 360
    Width = 482
    ExplicitTop = 360
    ExplicitWidth = 482
  end
  inherited StatusBar: TStatusBar
    Top = 402
    Width = 482
    ExplicitTop = 402
    ExplicitWidth = 482
  end
  inherited ToolBar: TToolBar
    Height = 360
    ExplicitHeight = 360
  end
  inherited PanelView: TPanel
    Width = 447
    Height = 360
    ExplicitWidth = 447
    ExplicitHeight = 360
    object Splitter: TSplitter [0]
      Left = 3
      Top = 289
      Width = 441
      Height = 3
      Cursor = crVSplit
      Align = alBottom
    end
    inherited GridPattern: TDBGrid
      Width = 441
      Height = 286
    end
    object PanelInfo: TPanel
      Left = 3
      Top = 292
      Width = 441
      Height = 65
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object GroupBoxInfo: TGroupBox
        Left = 0
        Top = 0
        Width = 441
        Height = 65
        Align = alClient
        Caption = ' '#1054#1087#1080#1089#1072#1085#1080#1077' '
        TabOrder = 0
        object PanelNote: TPanel
          Left = 2
          Top = 15
          Width = 437
          Height = 48
          Align = alClient
          BevelOuter = bvNone
          BorderWidth = 5
          TabOrder = 0
          object DBMemoNote: TDBMemo
            Left = 5
            Top = 5
            Width = 427
            Height = 38
            Align = alClient
            Color = clBtnFace
            DataField = 'DESCRIPTION'
            DataSource = DataSource
            ReadOnly = True
            TabOrder = 0
          end
        end
      end
    end
  end
  inherited PanelButton: TPanel
    Top = 363
    Width = 482
    ExplicitTop = 363
    ExplicitWidth = 482
    inherited ButtonCancel: TButton
      Left = 401
      ExplicitLeft = 401
    end
    inherited ButtonOk: TButton
      Left = 320
      ExplicitLeft = 320
    end
  end
end
