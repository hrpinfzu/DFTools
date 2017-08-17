unit ConfigForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Menus, ExtCtrls, WizMan;

type
  TfrmConfig = class(TForm)
    pmWizList: TPopupMenu;
    mniAddWiz: TMenuItem;
    mniDelWiz: TMenuItem;
    pgcMain: TPageControl;
    tsMainWiz: TTabSheet;
    tsPopWiz: TTabSheet;
    lvPopWiz: TListView;
    lvMainWiz: TListView;
    mniAlterWiz: TMenuItem;
    tsCommon: TTabSheet;
    Label4: TLabel;
    hkWizShortCut: THotKey;
    btnSave: TButton;
    lblCustDefine: TLabel;
    edtCustDefine: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure pmWizListPopup(Sender: TObject);
    procedure mniWizClick(Sender: TObject);
    procedure lvMainWizDblClick(Sender: TObject);
    procedure lvPopWizDblClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure tsCommonShow(Sender: TObject);
  private
    { Private declarations }
    FWizList: TWizObjects;
    procedure UpdateWiz(AMenuItem: TMenuItem);
    procedure LoadWizList;
  public
    { Public declarations }
  end;

var
  frmConfig: TfrmConfig;

implementation

uses
    CommonFun, WizConstUnit, WizSettingForm;

{$R *.dfm}

procedure TfrmConfig.btnSaveClick(Sender: TObject);
begin
    if hkWizShortCut.HotKey = 0 then
    begin
        ShowMessage('右键菜单快捷方式不能为空！');
        hkWizShortCut.SetFocus;
        hkWizShortCut.HotKey := ShortCut(Ord('X'), [ssCtrl, ssShift]);
    end;

    if (Trim(edtCustDefine.Text) = '') then
    begin
        ShowMessage('右键菜单快捷方式不能为空！');
        edtCustDefine.SetFocus;
        edtCustDefine.Text := 'DevVer';
    end;
    

    SaveCfg(Cfg_CommonSet_PopMenuShortCut, IntToStr(hkWizShortCut.HotKey), Sec_CommonSet);
    SaveCfg(Cfg_CommonSet_CustDefines, Trim(edtCustDefine.Text), Sec_CommonSet);

    ShowMessage('设置保存成功，重启IDE后生效！');
end;

procedure TfrmConfig.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
    frmConfig := nil;
end;

procedure TfrmConfig.FormCreate(Sender: TObject);
begin
    FWizList := TWizObjects.Create;

    pgcMain.ActivePageIndex := StrToIntDef(GetFromIni(pgcMain.Name, Self.Name), 0);
end;

procedure TfrmConfig.FormDestroy(Sender: TObject);
begin
    FreeAndNil(FWizList);

    SaveToIni(pgcMain.Name, IntToStr(pgcMain.ActivePageIndex), Self.Name);
end;

procedure TfrmConfig.FormShow(Sender: TObject);
begin
    LoadWizList;
end;

procedure TfrmConfig.LoadWizList;
var
    I: Integer;
    iWizCount: Integer;
    sWizName: string;
    WizObject: TWizObject;

    liItem: TListItem;
begin
    lvMainWiz.Items.Clear;
    lvPopWiz.Items.Clear;
    FWizList.Clear;

    iWizCount := StrToIntDef(GetCfg('WizCount', '-1', Sec_WizMan), -1);
    for I := 0 to iWizCount - 1 do
    begin
        sWizName := GetCfg('Item' + IntToStr(I), '', Sec_WizMan);

        WizObject := FWizList[FWizList.Add];
        WizObject.LoadWiz(sWizName);

        if SameText(WizObject.ObjectInfo.WizMenuType, 'main') then
            liItem := lvMainWiz.Items.Add
        else
            liItem := lvPopWiz.Items.Add;
            
        with liItem do
        begin
            Caption := WizObject.ObjectInfo.WizCaption;
            SubItems.Add(WizObject.ObjectInfo.WizName);
            SubItems.Add(ShortCutToText(WizObject.ObjectInfo.WizShortCut));
            SubItems.Add(WizObject.ObjectInfo.WizDLL);
            Data := WizObject;
        end;
    end;
end;

procedure TfrmConfig.lvMainWizDblClick(Sender: TObject);
begin
    mniWizClick(mniAlterWiz);
end;

procedure TfrmConfig.lvPopWizDblClick(Sender: TObject);
begin
    mniWizClick(mniAlterWiz);
end;

procedure TfrmConfig.mniWizClick(Sender: TObject);
begin
    UpdateWiz(Sender as TMenuItem);
end;

procedure TfrmConfig.pmWizListPopup(Sender: TObject);
var
    lvActive: TListView;
begin
    lvActive := lvMainWiz;
    if lvPopWiz.Focused then
        lvActive := lvPopWiz;

    mniDelWiz.Visible := True;
    mniAlterWiz.Visible := True;
    if not Assigned(lvActive.Selected) then
    begin
        mniDelWiz.Visible := False;
        mniAlterWiz.Visible := False;
    end;
end;

procedure TfrmConfig.tsCommonShow(Sender: TObject);
begin
    hkWizShortCut.HotKey := StrToIntDef(GetCfg(Cfg_CommonSet_PopMenuShortCut,
        '', Sec_CommonSet), ShortCut(Ord('X'), [ssCtrl, ssShift]));

    edtCustDefine.Text := GetCfg(Cfg_CommonSet_CustDefines, 'DevVer', Sec_CommonSet);
end;

procedure TfrmConfig.UpdateWiz(AMenuItem: TMenuItem);
var
    lvActive: TListView;
begin
    lvActive := lvMainWiz;
    if lvPopWiz.Focused then
        lvActive := lvPopWiz;

    if not Assigned(lvActive.Selected) then
        Exit;

    with TfrmWizSetting.Create(nil) do
    try
        FLinkWizList := FWizList;

        if AMenuItem = mniAlterWiz then
        begin
            FLinkWiz := TWizObject(lvActive.Selected.Data);
        end
        else if AMenuItem = mniDelWiz then
        begin
            FLinkWiz := TWizObject(lvActive.Selected.Data);
            if Application.MessageBox(PChar('确定要删除专家[' + FLinkWiz.ObjectInfo.WizCaption
                + ']?'), '提示', MB_OKCANCEL or MB_ICONQUESTION or MB_DEFBUTTON2) = IDCANCEL then
                Exit;

            FLinkWizList.Delete(FLinkWizList.IndexOfName(FLinkWiz.ObjectInfo.WizName));
            FLinkWizList.SaveCfg;
            lvActive.DeleteSelected;
            Exit;
        end;

        if ShowModal = mrOk then
            LoadWizList;
    finally
        Free;
    end;
end;

end.
