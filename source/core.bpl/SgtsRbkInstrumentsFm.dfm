inherited SgtsRbkInstrumentsForm: TSgtsRbkInstrumentsForm
  Left = 640
  Top = 0
  Caption = #1055#1088#1080#1073#1086#1088#1099
  ClientHeight = 429
  ClientWidth = 632
  Constraints.MinHeight = 475
  Constraints.MinWidth = 600
  ExplicitWidth = 640
  ExplicitHeight = 475
  PixelsPerInch = 96
  TextHeight = 13
  inherited BevelStatus: TBevel
    Top = 366
    Width = 632
    ExplicitTop = 363
    ExplicitWidth = 632
  end
  inherited StatusBar: TStatusBar
    Top = 408
    Width = 632
    ExplicitTop = 403
    ExplicitWidth = 632
  end
  inherited ToolBar: TToolBar
    Height = 366
    ExplicitHeight = 361
  end
  inherited PanelView: TPanel
    Width = 597
    Height = 366
    ExplicitWidth = 597
    ExplicitHeight = 361
    object Splitter: TSplitter [0]
      Left = 3
      Top = 269
      Width = 591
      Height = 3
      Cursor = crVSplit
      Align = alBottom
      ExplicitTop = 266
    end
    inherited GridPattern: TDBGrid
      Width = 591
      Height = 266
    end
    object PanelInfo: TPanel
      Left = 3
      Top = 272
      Width = 591
      Height = 91
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      ExplicitTop = 267
      object GroupBoxInfo: TGroupBox
        Left = 0
        Top = 0
        Width = 591
        Height = 91
        Align = alClient
        Caption = ' '#1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1086' '
        TabOrder = 0
        object PanelNote: TPanel
          Left = 2
          Top = 15
          Width = 587
          Height = 74
          Align = alClient
          BevelOuter = bvNone
          BorderWidth = 5
          TabOrder = 0
          DesignSize = (
            587
            74)
          object LabelZ: TLabel
            Left = 10
            Top = 8
            Width = 106
            Height = 13
            Alignment = taRightJustify
            Caption = #1048#1085#1074#1077#1085#1090#1072#1088#1085#1099#1081' '#1085#1086#1084#1077#1088':'
            FocusControl = DBEditInventoryNumber
          end
          object LabelDescription: TLabel
            Left = 63
            Top = 32
            Width = 53
            Height = 13
            Alignment = taRightJustify
            Caption = #1054#1087#1080#1089#1072#1085#1080#1077':'
            FocusControl = DBMemoDescription
          end
          object DBMemoDescription: TDBMemo
            Left = 123
            Top = 32
            Width = 456
            Height = 36
            Anchors = [akLeft, akTop, akRight, akBottom]
            Color = clBtnFace
            DataField = 'DESCRIPTION'
            DataSource = DataSource
            ReadOnly = True
            TabOrder = 1
          end
          object DBEditInventoryNumber: TDBEdit
            Left = 123
            Top = 4
            Width = 130
            Height = 21
            Color = clBtnFace
            DataField = 'INVENTORY_NUMBER'
            DataSource = DataSource
            ReadOnly = True
            TabOrder = 0
          end
        end
      end
    end
  end
  inherited PanelButton: TPanel
    Top = 369
    Width = 632
    ExplicitTop = 364
    ExplicitWidth = 632
    inherited ButtonCancel: TButton
      Left = 551
      ExplicitLeft = 551
    end
    inherited ButtonOk: TButton
      Left = 469
      ExplicitLeft = 469
    end
  end
end