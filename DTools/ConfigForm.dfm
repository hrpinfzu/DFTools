object frmConfig: TfrmConfig
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #35774#32622
  ClientHeight = 245
  ClientWidth = 693
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pgcMain: TPageControl
    Left = 0
    Top = 0
    Width = 693
    Height = 245
    ActivePage = tsMainWiz
    Align = alClient
    MultiLine = True
    Style = tsFlatButtons
    TabOrder = 0
    object tsMainWiz: TTabSheet
      Caption = 'MainMenuWiz'
      object lvMainWiz: TListView
        Left = 0
        Top = 0
        Width = 685
        Height = 214
        Align = alClient
        Columns = <
          item
            Caption = 'Caption'
            Width = 125
          end
          item
            Caption = 'Name'
            Width = 125
          end
          item
            Caption = 'HotKey'
            Width = 100
          end
          item
            Caption = 'FileName'
            Width = 300
          end>
        Ctl3D = False
        ReadOnly = True
        RowSelect = True
        PopupMenu = pmWizList
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = lvMainWizDblClick
      end
    end
    object tsPopWiz: TTabSheet
      Caption = 'PopMenuWiz'
      ImageIndex = 1
      object lvPopWiz: TListView
        Left = 0
        Top = 0
        Width = 685
        Height = 214
        Align = alClient
        Columns = <
          item
            Caption = 'Caption'
            Width = 125
          end
          item
            Caption = 'Name'
            Width = 125
          end
          item
            Caption = 'HotKey'
            Width = 100
          end
          item
            Caption = 'FileName'
            Width = 300
          end>
        Ctl3D = False
        ReadOnly = True
        RowSelect = True
        PopupMenu = pmWizList
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = lvPopWizDblClick
      end
    end
    object tsCommon: TTabSheet
      Caption = 'CommonSet'
      ImageIndex = 2
      OnShow = tsCommonShow
      object Label4: TLabel
        Left = 8
        Top = 6
        Width = 84
        Height = 13
        Caption = #21491#38190#33756#21333#24555#25463#38190
      end
      object lblCustDefine: TLabel
        Left = 8
        Top = 32
        Width = 84
        Height = 13
        Caption = #33258#23450#20041#32534#35793#24320#20851
      end
      object hkWizShortCut: THotKey
        Left = 97
        Top = 4
        Width = 121
        Height = 19
        HotKey = 0
        Modifiers = []
        TabOrder = 0
      end
      object btnSave: TButton
        Left = 8
        Top = 186
        Width = 68
        Height = 25
        Caption = #20445'  '#23384
        TabOrder = 1
        OnClick = btnSaveClick
      end
      object edtCustDefine: TEdit
        Left = 97
        Top = 29
        Width = 121
        Height = 21
        TabOrder = 2
      end
    end
  end
  object pmWizList: TPopupMenu
    OnPopup = pmWizListPopup
    Left = 160
    Top = 144
    object mniAddWiz: TMenuItem
      Caption = #28155#21152'(&A)'
      OnClick = mniWizClick
    end
    object mniAlterWiz: TMenuItem
      Caption = #20462#25913'(&M)'
      OnClick = mniWizClick
    end
    object mniDelWiz: TMenuItem
      Caption = #21024#38500'(&D)'
      OnClick = mniWizClick
    end
  end
end
