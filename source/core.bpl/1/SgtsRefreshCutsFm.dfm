inherited SgtsRefreshCutsForm: TSgtsRefreshCutsForm
  Left = 377
  Top = 225
  Caption = #1054#1073#1085#1086#1074#1083#1077#1085#1080#1077' '#1089#1088#1077#1079#1086#1074
  ClientHeight = 273
  ClientWidth = 392
  Constraints.MinHeight = 300
  Constraints.MinWidth = 400
  OnCloseQuery = FormCloseQuery
  ExplicitLeft = 377
  ExplicitTop = 225
  ExplicitWidth = 400
  ExplicitHeight = 300
  PixelsPerInch = 96
  TextHeight = 13
  object PanelGrid: TPanel
    Left = 0
    Top = 0
    Width = 392
    Height = 234
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 3
    TabOrder = 0
    object GroupBoxOption: TGroupBox
      Left = 3
      Top = 3
      Width = 386
      Height = 228
      Align = alClient
      Caption = ' '#1053#1072#1089#1090#1088#1086#1081#1082#1072' '
      TabOrder = 0
      object PanelOption: TPanel
        Left = 2
        Top = 15
        Width = 382
        Height = 211
        Align = alClient
        BevelOuter = bvNone
        BorderWidth = 5
        TabOrder = 0
      end
    end
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 234
    Width = 392
    Height = 39
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      392
      39)
    object ButtonRefresh: TButton
      Left = 204
      Top = 8
      Width = 100
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      Default = True
      TabOrder = 0
      OnClick = ButtonRefreshClick
    end
    object ButtonClose: TButton
      Left = 311
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1047#1072#1082#1088#1099#1090#1100
      TabOrder = 1
      OnClick = ButtonCloseClick
    end
  end
  object DataSource: TDataSource
    Left = 245
    Top = 124
  end
  object PopupMenu: TPopupMenu
    OnPopup = PopupMenuPopup
    Left = 125
    Top = 122
    object MenuItemRefreshCurrent: TMenuItem
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100' '#1090#1077#1082#1091#1097#1080#1081' '#1089#1088#1077#1079
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100' '#1090#1077#1082#1091#1097#1080#1081' '#1089#1088#1077#1079
      OnClick = MenuItemRefreshCurrentClick
    end
  end
end
