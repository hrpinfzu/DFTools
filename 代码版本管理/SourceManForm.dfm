object frmSourceMan: TfrmSourceMan
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #20195#30721#29256#26412#31649#29702
  ClientHeight = 435
  ClientWidth = 534
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 60
    Height = 13
    Caption = #28304#30721#36335#24452#65306
  end
  object Label2: TLabel
    Left = 8
    Top = 35
    Width = 60
    Height = 13
    Caption = #32534#35793#24320#20851#65306
  end
  object btnSelDir: TSpeedButton
    Left = 344
    Top = 4
    Width = 23
    Height = 22
    Caption = #8230
    OnClick = edtSourceDirDblClick
  end
  object Label3: TLabel
    Left = 177
    Top = 35
    Width = 60
    Height = 13
    Caption = 'File Masks'#65306
  end
  object edtSourceDir: TEdit
    Left = 69
    Top = 5
    Width = 278
    Height = 21
    Color = cl3DLight
    ReadOnly = True
    TabOrder = 0
    OnDblClick = edtSourceDirDblClick
  end
  object btnSearch: TButton
    Left = 372
    Top = 5
    Width = 75
    Height = 48
    Caption = #26597' '#25214
    TabOrder = 1
    OnClick = btnSearchClick
  end
  object btnReplace: TButton
    Left = 453
    Top = 5
    Width = 75
    Height = 48
    Caption = #26367' '#25442
    TabOrder = 2
    OnClick = btnReplaceClick
  end
  object edtDefines: TEdit
    Left = 69
    Top = 32
    Width = 100
    Height = 21
    TabOrder = 3
  end
  object edtFileMasks: TEdit
    Left = 238
    Top = 32
    Width = 129
    Height = 21
    TabOrder = 4
    Text = '*.cpp;*.h;*.hpp'
  end
  object lvFileList: TListView
    Left = 8
    Top = 59
    Width = 520
    Height = 357
    Columns = <
      item
        Caption = #24207#21495
      end
      item
        Caption = #25991#20214#21517
        Width = 200
      end
      item
        Caption = #20986#29616#27425#25968
        Width = 60
      end
      item
        Caption = #25152#22312#30446#24405
        Width = 200
      end>
    Ctl3D = False
    RowSelect = True
    TabOrder = 5
    ViewStyle = vsReport
  end
  object stat: TStatusBar
    Left = 0
    Top = 416
    Width = 534
    Height = 19
    Panels = <
      item
        Width = 250
      end
      item
        Width = 50
      end>
  end
end
