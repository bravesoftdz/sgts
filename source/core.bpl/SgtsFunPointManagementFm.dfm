inherited SgtsFunPointManagementForm: TSgtsFunPointManagementForm
  Left = 460
  Top = 198
  Caption = #1042#1074#1086#1076' '#1080#1079#1084#1077#1088#1080#1090#1077#1083#1100#1085#1099#1093' '#1090#1086#1095#1077#1082
  ClientHeight = 443
  ClientWidth = 692
  Constraints.MinHeight = 470
  Constraints.MinWidth = 700
  ExplicitLeft = 460
  ExplicitTop = 198
  ExplicitWidth = 700
  ExplicitHeight = 470
  PixelsPerInch = 96
  TextHeight = 13
  inherited BevelStatus: TBevel
    Top = 380
    Width = 692
    ExplicitTop = 380
    ExplicitWidth = 692
  end
  inherited StatusBar: TStatusBar
    Top = 422
    Width = 692
    ExplicitTop = 422
    ExplicitWidth = 692
  end
  inherited ToolBar: TToolBar
    Height = 380
    ExplicitHeight = 380
  end
  inherited PanelView: TPanel
    Width = 657
    Height = 380
    ExplicitWidth = 657
    ExplicitHeight = 380
    object Splitter: TSplitter [0]
      Left = 253
      Top = 3
      Height = 374
      MinSize = 200
    end
    object PanelInfo: TPanel [1]
      Left = 256
      Top = 3
      Width = 398
      Height = 374
      Align = alClient
      BevelOuter = bvNone
      Caption = #1053#1077#1090' '#1076#1086#1089#1090#1091#1087#1085#1086#1081' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1080
      TabOrder = 0
      object PageControlInfo: TPageControl
        Left = 0
        Top = 19
        Width = 398
        Height = 355
        ActivePage = TabSheetRoute
        Align = alClient
        Style = tsButtons
        TabOrder = 0
        Visible = False
        object TabSheetMeasureType: TTabSheet
          Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1086' '#1074#1080#1076#1077' '#1080#1079#1084#1077#1088#1077#1085#1080#1103
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object PageControlMeasureType: TPageControl
            Left = 0
            Top = 0
            Width = 390
            Height = 324
            ActivePage = TabSheetMeasureTypeGeneral
            Align = alClient
            HotTrack = True
            Style = tsFlatButtons
            TabOrder = 0
            object TabSheetMeasureTypeGeneral: TTabSheet
              Caption = #1054#1073#1097#1072#1103
              DesignSize = (
                382
                293)
              object LabelMeasureTypeName: TLabel
                Left = 12
                Top = 9
                Width = 77
                Height = 13
                Alignment = taRightJustify
                Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077':'
                FocusControl = DBEditMeasureTypeName
              end
              object LabelMeasureTypeDesc: TLabel
                Left = 36
                Top = 55
                Width = 53
                Height = 13
                Alignment = taRightJustify
                Caption = #1054#1087#1080#1089#1072#1085#1080#1077':'
                FocusControl = DBMemoMeasureTypeDesc
              end
              object LabelMeasureTypeDate: TLabel
                Left = 20
                Top = 150
                Width = 69
                Height = 13
                Alignment = taRightJustify
                Caption = #1044#1072#1090#1072' '#1085#1072#1095#1072#1083#1072':'
                FocusControl = EditMeasureTypeDate
              end
              object DBEditMeasureTypeName: TDBEdit
                Left = 96
                Top = 6
                Width = 285
                Height = 21
                Anchors = [akLeft, akTop, akRight]
                Color = clBtnFace
                DataField = 'NAME'
                DataSource = DataSource
                ReadOnly = True
                TabOrder = 0
              end
              object DBMemoMeasureTypeDesc: TDBMemo
                Left = 96
                Top = 52
                Width = 285
                Height = 89
                Anchors = [akLeft, akTop, akRight]
                Color = clBtnFace
                DataField = 'DESCRIPTION'
                DataSource = DataSource
                ReadOnly = True
                TabOrder = 2
              end
              object CheckBoxMeasureTypeIsActive: TCheckBox
                Left = 96
                Top = 172
                Width = 85
                Height = 17
                Caption = #1040#1082#1090#1080#1074#1085#1086#1089#1090#1100
                Checked = True
                Enabled = False
                State = cbChecked
                TabOrder = 4
              end
              object EditMeasureTypeDate: TEdit
                Left = 96
                Top = 147
                Width = 121
                Height = 21
                Color = clBtnFace
                ReadOnly = True
                TabOrder = 3
                Text = 'EditMeasureTypeDate'
              end
              object CheckBoxMeasureTypeIsVisual: TCheckBox
                Left = 96
                Top = 31
                Width = 185
                Height = 17
                Caption = #1069#1090#1086' '#1074#1080#1079#1091#1072#1083#1100#1085#1099#1081' '#1074#1080#1076' '#1080#1079#1084#1077#1088#1077#1085#1080#1103
                Enabled = False
                TabOrder = 1
              end
              object CheckBoxMeasureTypeIsBase: TCheckBox
                Left = 96
                Top = 190
                Width = 145
                Height = 17
                Caption = #1041#1072#1079#1086#1074#1099#1081' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102
                Enabled = False
                TabOrder = 5
              end
            end
            object TabSheetMeasureTypeParams: TTabSheet
              Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099
              ImageIndex = 2
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
            end
            object TabSheetMeasureTypeAlgorithms: TTabSheet
              Caption = #1040#1083#1075#1086#1088#1080#1090#1084#1099
              ImageIndex = 3
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
            end
            object TabSheetMeasureTypeGraphs: TTabSheet
              Caption = #1055#1077#1088#1080#1086#1076#1080#1095#1085#1086#1089#1090#1100' '#1085#1072#1073#1083#1102#1076#1077#1085#1080#1081
              ImageIndex = 4
              TabVisible = False
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
              object CheckBoxJanuary: TCheckBox
                Left = 12
                Top = 13
                Width = 76
                Height = 17
                Caption = #1071#1085#1074#1072#1088#1100
                TabOrder = 0
                OnClick = CheckBoxJanuaryClick
              end
              object CheckBoxFebruary: TCheckBox
                Left = 12
                Top = 31
                Width = 76
                Height = 17
                Caption = #1060#1077#1074#1088#1072#1083#1100
                TabOrder = 1
                OnClick = CheckBoxJanuaryClick
              end
              object CheckBoxMarch: TCheckBox
                Left = 12
                Top = 49
                Width = 76
                Height = 17
                Caption = #1052#1072#1088#1090
                TabOrder = 2
                OnClick = CheckBoxJanuaryClick
              end
              object CheckBoxApril: TCheckBox
                Left = 12
                Top = 68
                Width = 76
                Height = 17
                Caption = #1040#1087#1088#1077#1083#1100
                TabOrder = 3
                OnClick = CheckBoxJanuaryClick
              end
              object CheckBoxMay: TCheckBox
                Left = 12
                Top = 87
                Width = 76
                Height = 17
                Caption = #1052#1072#1081
                TabOrder = 4
                OnClick = CheckBoxJanuaryClick
              end
              object CheckBoxJune: TCheckBox
                Left = 12
                Top = 105
                Width = 76
                Height = 17
                Caption = #1048#1102#1085#1100
                TabOrder = 5
                OnClick = CheckBoxJanuaryClick
              end
              object CheckBoxJuly: TCheckBox
                Left = 100
                Top = 13
                Width = 76
                Height = 17
                Caption = #1048#1102#1083#1100
                TabOrder = 6
                OnClick = CheckBoxJanuaryClick
              end
              object CheckBoxAugust: TCheckBox
                Left = 100
                Top = 31
                Width = 76
                Height = 17
                Caption = #1040#1074#1075#1091#1089#1090
                TabOrder = 7
                OnClick = CheckBoxJanuaryClick
              end
              object CheckBoxSeptember: TCheckBox
                Left = 100
                Top = 49
                Width = 76
                Height = 17
                Caption = #1057#1077#1085#1090#1103#1073#1088#1100
                TabOrder = 8
                OnClick = CheckBoxJanuaryClick
              end
              object CheckBoxOctober: TCheckBox
                Left = 100
                Top = 68
                Width = 76
                Height = 17
                Caption = #1054#1082#1090#1103#1073#1088#1100
                TabOrder = 9
                OnClick = CheckBoxJanuaryClick
              end
              object CheckBoxNovember: TCheckBox
                Left = 100
                Top = 87
                Width = 76
                Height = 17
                Caption = #1053#1086#1103#1073#1088#1100
                TabOrder = 10
                OnClick = CheckBoxJanuaryClick
              end
              object CheckBoxDecember: TCheckBox
                Left = 100
                Top = 105
                Width = 76
                Height = 17
                Caption = #1044#1077#1082#1072#1073#1088#1100
                TabOrder = 11
                OnClick = CheckBoxJanuaryClick
              end
            end
          end
        end
        object TabSheetRoute: TTabSheet
          Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1086' '#1084#1072#1088#1096#1088#1091#1090#1077
          ImageIndex = 1
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object PageControlRoute: TPageControl
            Left = 0
            Top = 0
            Width = 390
            Height = 324
            ActivePage = TabSheetRoutePersonnels
            Align = alClient
            Style = tsFlatButtons
            TabOrder = 0
            object TabSheetRouteGeneral: TTabSheet
              Caption = #1054#1073#1097#1072#1103
              DesignSize = (
                382
                293)
              object LabelRouteName: TLabel
                Left = 12
                Top = 9
                Width = 77
                Height = 13
                Alignment = taRightJustify
                Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077':'
                FocusControl = DBEditRouteName
              end
              object LabelRouteDesc: TLabel
                Left = 36
                Top = 36
                Width = 53
                Height = 13
                Alignment = taRightJustify
                Caption = #1054#1087#1080#1089#1072#1085#1080#1077':'
                FocusControl = DBMemoRouteDesc
              end
              object Label1: TLabel
                Left = 59
                Top = 131
                Width = 30
                Height = 13
                Alignment = taRightJustify
                Caption = #1044#1072#1090#1072':'
                FocusControl = EditRouteDate
              end
              object DBEditRouteName: TDBEdit
                Left = 96
                Top = 6
                Width = 285
                Height = 21
                Anchors = [akLeft, akTop, akRight]
                Color = clBtnFace
                DataField = 'NAME'
                DataSource = DataSource
                ReadOnly = True
                TabOrder = 0
              end
              object DBMemoRouteDesc: TDBMemo
                Left = 96
                Top = 33
                Width = 285
                Height = 89
                Anchors = [akLeft, akTop, akRight]
                Color = clBtnFace
                DataField = 'DESCRIPTION'
                DataSource = DataSource
                ReadOnly = True
                TabOrder = 1
              end
              object EditRouteDate: TEdit
                Left = 96
                Top = 128
                Width = 121
                Height = 21
                Color = clBtnFace
                ReadOnly = True
                TabOrder = 2
                Text = 'EditRouteDate'
              end
              object CheckBoxRouteIsActive: TCheckBox
                Left = 95
                Top = 153
                Width = 85
                Height = 17
                Caption = #1040#1082#1090#1080#1074#1085#1086#1089#1090#1100
                Checked = True
                Enabled = False
                State = cbChecked
                TabOrder = 3
              end
            end
            object TabSheetRoutePoints: TTabSheet
              Caption = #1058#1086#1095#1082#1080
              ImageIndex = 1
              ParentShowHint = False
              ShowHint = False
              TabVisible = False
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
            end
            object TabSheetRoutePersonnels: TTabSheet
              Caption = #1055#1077#1088#1089#1086#1085#1072#1083
              ImageIndex = 2
              ParentShowHint = False
              ShowHint = False
            end
          end
        end
        object TabSheetPoint: TTabSheet
          Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1086' '#1080#1079#1084#1077#1088#1080#1090#1077#1083#1100#1085#1086#1081' '#1090#1086#1095#1082#1077
          ImageIndex = 2
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object PageControlPoint: TPageControl
            Left = 0
            Top = 0
            Width = 390
            Height = 324
            ActivePage = TabSheetPointGeneral
            Align = alClient
            Style = tsFlatButtons
            TabOrder = 0
            object TabSheetPointGeneral: TTabSheet
              Caption = #1054#1073#1097#1072#1103
              DesignSize = (
                382
                293)
              object LabelPointName: TLabel
                Left = 47
                Top = 9
                Width = 35
                Height = 13
                Alignment = taRightJustify
                Caption = #1053#1086#1084#1077#1088':'
                FocusControl = DBEditPointName
              end
              object LabelPointDesc: TLabel
                Left = 29
                Top = 36
                Width = 53
                Height = 13
                Alignment = taRightJustify
                Caption = #1054#1087#1080#1089#1072#1085#1080#1077':'
                FocusControl = DBMemoPointDesc
              end
              object LabelPointType: TLabel
                Left = 27
                Top = 131
                Width = 55
                Height = 13
                Alignment = taRightJustify
                Caption = #1058#1080#1087' '#1090#1086#1095#1082#1080':'
                FocusControl = EditPointType
              end
              object LabelPointObject: TLabel
                Left = 6
                Top = 154
                Width = 76
                Height = 26
                Alignment = taRightJustify
                Caption = #1056#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1077' '#1086#1073#1098#1077#1082#1090#1072':'
                FocusControl = MemoPointObject
                WordWrap = True
              end
              object LabelPointCoordinateX: TLabel
                Left = 7
                Top = 219
                Width = 75
                Height = 13
                Alignment = taRightJustify
                Caption = #1050#1086#1086#1088#1076#1080#1085#1072#1090#1072' X:'
                FocusControl = EditPointCoordinateX
              end
              object LabelPointCoordinateY: TLabel
                Left = 153
                Top = 219
                Width = 10
                Height = 13
                Alignment = taRightJustify
                Caption = 'Y:'
                FocusControl = EditPointCoordinateY
              end
              object LabelPointCoordinateZ: TLabel
                Left = 232
                Top = 219
                Width = 64
                Height = 13
                Alignment = taRightJustify
                Caption = #1054#1090#1084#1077#1090#1082#1072' '#1048#1058':'
                FocusControl = EditPointCoordinateZ
              end
              object LabelPointDateEnter: TLabel
                Left = 18
                Top = 245
                Width = 64
                Height = 13
                Alignment = taRightJustify
                Caption = #1044#1072#1090#1072' '#1074#1074#1086#1076#1072':'
                FocusControl = EditPointDateEnter
              end
              object DBEditPointName: TDBEdit
                Left = 89
                Top = 6
                Width = 292
                Height = 21
                Anchors = [akLeft, akTop, akRight]
                Color = clBtnFace
                DataField = 'NAME'
                DataSource = DataSource
                ReadOnly = True
                TabOrder = 0
              end
              object DBMemoPointDesc: TDBMemo
                Left = 89
                Top = 33
                Width = 292
                Height = 89
                Anchors = [akLeft, akTop, akRight]
                Color = clBtnFace
                DataField = 'DESCRIPTION'
                DataSource = DataSource
                ReadOnly = True
                TabOrder = 1
              end
              object EditPointType: TEdit
                Left = 89
                Top = 128
                Width = 292
                Height = 21
                Anchors = [akLeft, akTop, akRight]
                Color = clBtnFace
                ReadOnly = True
                TabOrder = 2
                Text = 'EditPointType'
              end
              object EditPointCoordinateX: TEdit
                Left = 89
                Top = 215
                Width = 50
                Height = 21
                Color = clBtnFace
                ReadOnly = True
                TabOrder = 5
              end
              object EditPointCoordinateY: TEdit
                Left = 170
                Top = 215
                Width = 50
                Height = 21
                Color = clBtnFace
                ReadOnly = True
                TabOrder = 6
              end
              object EditPointCoordinateZ: TEdit
                Left = 303
                Top = 215
                Width = 50
                Height = 21
                Color = clBtnFace
                ReadOnly = True
                TabOrder = 7
              end
              object EditPointDateEnter: TEdit
                Left = 89
                Top = 242
                Width = 131
                Height = 21
                Color = clBtnFace
                ReadOnly = True
                TabOrder = 8
                Text = 'EditMeasureTypeDate'
              end
              object ButtonPointObject: TButton
                Left = 359
                Top = 155
                Width = 21
                Height = 21
                Hint = #1055#1086#1089#1084#1086#1090#1088#1077#1090#1100' '#1086#1073#1098#1077#1082#1090
                Anchors = [akTop, akRight]
                Caption = '...'
                ParentShowHint = False
                ShowHint = True
                TabOrder = 4
                OnClick = ButtonPointObjectClick
              end
              object MemoPointObject: TMemo
                Left = 89
                Top = 155
                Width = 264
                Height = 54
                Anchors = [akLeft, akTop, akRight]
                Color = clBtnFace
                ReadOnly = True
                ScrollBars = ssVertical
                TabOrder = 3
                WordWrap = False
              end
            end
            object TabSheetPointInstruments: TTabSheet
              Caption = #1055#1088#1080#1073#1086#1088#1099
              ImageIndex = 3
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
            end
            object TabSheetPointDocuments: TTabSheet
              Caption = #1044#1086#1082#1091#1084#1077#1085#1090#1099
              ImageIndex = 2
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
            end
            object TabSheetPointPassports: TTabSheet
              Caption = #1055#1072#1089#1087#1086#1088#1090
              ImageIndex = 2
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
            end
          end
        end
        object TabSheetConverter: TTabSheet
          Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1086' '#1087#1088#1077#1086#1073#1088#1072#1079#1086#1074#1072#1090#1077#1083#1077
          ImageIndex = 3
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object PageControlConverter: TPageControl
            Left = 0
            Top = 0
            Width = 390
            Height = 324
            ActivePage = TabSheetConverterGeneral
            Align = alClient
            Style = tsFlatButtons
            TabOrder = 0
            object TabSheetConverterGeneral: TTabSheet
              Caption = #1054#1073#1097#1072#1103
              DesignSize = (
                382
                293)
              object LabelConverterName: TLabel
                Left = 5
                Top = 9
                Width = 77
                Height = 13
                Alignment = taRightJustify
                Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077':'
                FocusControl = DBEditConverterName
              end
              object LabelConverterDesc: TLabel
                Left = 29
                Top = 36
                Width = 53
                Height = 13
                Alignment = taRightJustify
                Caption = #1054#1087#1080#1089#1072#1085#1080#1077':'
                FocusControl = DBMemoConverterDesc
              end
              object LabelConverterDate: TLabel
                Left = 18
                Top = 131
                Width = 64
                Height = 13
                Alignment = taRightJustify
                Caption = #1044#1072#1090#1072' '#1074#1074#1086#1076#1072':'
                FocusControl = EditConverterDate
              end
              object DBEditConverterName: TDBEdit
                Left = 89
                Top = 6
                Width = 292
                Height = 21
                Anchors = [akLeft, akTop, akRight]
                Color = clBtnFace
                DataField = 'NAME'
                DataSource = DataSource
                ReadOnly = True
                TabOrder = 0
              end
              object DBMemoConverterDesc: TDBMemo
                Left = 89
                Top = 33
                Width = 292
                Height = 89
                Anchors = [akLeft, akTop, akRight]
                Color = clBtnFace
                DataField = 'DESCRIPTION'
                DataSource = DataSource
                ReadOnly = True
                TabOrder = 1
              end
              object EditConverterDate: TEdit
                Left = 89
                Top = 128
                Width = 121
                Height = 21
                Color = clBtnFace
                ReadOnly = True
                TabOrder = 2
                Text = 'EditConverterDate'
              end
              object CheckBoxConverterNotOperation: TCheckBox
                Left = 89
                Top = 152
                Width = 128
                Height = 17
                Caption = #1053#1077' '#1092#1091#1085#1082#1094#1080#1086#1085#1080#1088#1091#1077#1090
                Checked = True
                Enabled = False
                State = cbChecked
                TabOrder = 3
              end
            end
            object TabSheetConverterComponents: TTabSheet
              Caption = #1050#1086#1084#1087#1086#1085#1077#1085#1090#1099
              ImageIndex = 1
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
            end
            object TabSheetConverterPassports: TTabSheet
              Caption = #1055#1072#1089#1087#1086#1088#1090
              ImageIndex = 2
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
            end
          end
        end
      end
      object PanelTop: TPanel
        Left = 0
        Top = 0
        Width = 398
        Height = 19
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object PanelCaption: TPanel
          Left = 0
          Top = 0
          Width = 398
          Height = 19
          Align = alClient
          BevelOuter = bvNone
          BorderWidth = 3
          Color = clInactiveCaption
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindow
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          object LabelCaption: TLabel
            Left = 3
            Top = 3
            Width = 392
            Height = 13
            Align = alClient
            Caption = #1053#1077#1090' '#1076#1086#1089#1090#1091#1087#1085#1086#1081' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1080
            Transparent = False
            Layout = tlCenter
            ExplicitWidth = 162
          end
        end
      end
    end
    inherited TreePattern: TTreeView
      Width = 250
      Height = 374
      Align = alLeft
      Constraints.MinWidth = 200
      TabOrder = 1
      ExplicitWidth = 250
      ExplicitHeight = 374
    end
  end
  inherited PanelButton: TPanel
    Top = 383
    Width = 692
    ExplicitTop = 383
    ExplicitWidth = 692
    inherited ButtonCancel: TButton
      Left = 612
      ExplicitLeft = 612
    end
    inherited ButtonOk: TButton
      Left = 530
      ExplicitLeft = 530
    end
  end
  inherited PopupMenuFilter: TPopupMenu
    Left = 224
    Top = 226
  end
  inherited PopupMenuReport: TPopupMenu
    Left = 120
    Top = 234
  end
  inherited DataSource: TDataSource
    Left = 208
    Top = 154
  end
end
