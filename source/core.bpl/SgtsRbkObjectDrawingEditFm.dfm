inherited SgtsRbkObjectDrawingEditForm: TSgtsRbkObjectDrawingEditForm
  Left = 471
  Top = 308
  Width = 322
  Height = 199
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1095#1077#1088#1090#1077#1078#1072' '#1086#1073#1098#1077#1082#1090#1072
  Constraints.MinHeight = 160
  Constraints.MinWidth = 300
  PixelsPerInch = 96
  TextHeight = 13
  inherited StatusBar: TStatusBar
    Top = 134
    Width = 314
  end
  inherited ToolBar: TToolBar
    Width = 35
    Height = 95
    inherited ToolButtonOk: TToolButton
      Wrap = True
    end
    inherited ToolButtonCancel: TToolButton
      Left = 0
      Top = 30
    end
    inherited ToolButtonDefault: TToolButton
      Top = 60
    end
  end
  inherited PanelEdit: TPanel
    Left = 35
    Width = 279
    Height = 95
    object LabelObject: TLabel
      Left = 22
      Top = 23
      Width = 41
      Height = 13
      Alignment = taRightJustify
      Caption = #1054#1073#1098#1077#1082#1090':'
      FocusControl = EditObject
    end
    object LabelDrawing: TLabel
      Left = 21
      Top = 50
      Width = 42
      Height = 13
      Alignment = taRightJustify
      Caption = #1063#1077#1088#1090#1077#1078':'
      FocusControl = EditDrawing
      WordWrap = True
    end
    object LabelPriority: TLabel
      Left = 111
      Top = 77
      Width = 47
      Height = 13
      Alignment = taRightJustify
      Caption = #1055#1086#1088#1103#1076#1086#1082':'
      FocusControl = EditPriority
    end
    object EditObject: TEdit
      Left = 73
      Top = 19
      Width = 171
      Height = 21
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 0
    end
    object ButtonObject: TButton
      Left = 250
      Top = 19
      Width = 21
      Height = 21
      Hint = #1042#1099#1073#1088#1072#1090#1100' '#1086#1073#1098#1077#1082#1090
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object EditDrawing: TEdit
      Left = 73
      Top = 46
      Width = 171
      Height = 21
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 2
    end
    object ButtonDrawing: TButton
      Left = 250
      Top = 46
      Width = 21
      Height = 21
      Hint = #1042#1099#1073#1088#1072#1090#1100' '#1095#1077#1088#1090#1077#1078
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
    end
    object EditPriority: TEdit
      Left = 166
      Top = 73
      Width = 78
      Height = 21
      TabOrder = 4
    end
  end
  inherited PanelButton: TPanel
    Top = 95
    Width = 314
    inherited ButtonCancel: TButton
      Left = 230
    end
    inherited ButtonOk: TButton
      Left = 148
    end
  end
  inherited MainMenu: TMainMenu
    Left = 168
  end
  inherited ImageList: TImageList
    Left = 208
  end
end