unit WizSettingForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, WizMan;

type
  TfrmWizSetting = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    edtWizCaption: TEdit;
    edtWizName: TEdit;
    edtWizDLL: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    hkWizShortCut: THotKey;
    btnSave: TButton;
    btnCancel: TButton;
    dlgOpen: TOpenDialog;
    rbMainMenu: TRadioButton;
    rbPopMenu: TRadioButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure edtWizDLLKeyPress(Sender: TObject; var Key: Char);
    procedure edtWizDLLDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FLinkWiz: TWizObject;
    FLinkWizList: TWizObjects;
  end;

var
  frmWizSetting: TfrmWizSetting;

implementation

uses
    Global;

{$R *.dfm}

procedure TfrmWizSetting.btnSaveClick(Sender: TObject);
var
    sWizCaption, sWizName, sWizDLL, sWizMenuType: string;
    skWizHotKey: TShortCut; 
begin
    sWizCaption := Trim(edtWizCaption.Text);
    sWizName := Trim(edtWizName.Text);
    sWizDLL := Trim(edtWizDLL.Text);
    skWizHotKey := hkWizShortCut.HotKey;

    if SameText(sWizCaption, '') then
    begin
        ShowMessage('专家名称不能为空！');
        Exit;
    end;

    if not Assigned(FLinkWiz) then
    begin
        if FLinkWizList.IndexOfCaption(sWizCaption) >= 0 then
        begin
            ShowMessage('专家名称不能重复！');
            Exit;
        end;

        if FLinkWizList.IndexOfName(sWizName) >= 0 then
        begin
            ShowMessage('专家英文别名不能重复！');
            Exit;
        end;
    end;

    if SameText(sWizName, '') then
    begin
        ShowMessage('专家英文别名不能为空！');
        Exit;
    end;

    if not (FileExists(sWizDLL) or FileExists(GlobalCache.WizDLLPath + sWizDLL)) then
    begin
        ShowMessage('必须设置专家DLL文件！');
        Exit;
    end
    else
    begin
        // 接口测试
        
    end;

    CopyFile(PChar(sWizDLL), PChar(GlobalCache.WizDLLPath + ExtractFileName(sWizDLL)), False);
    sWizDLL := ExtractFileName(sWizDLL);

    if rbMainMenu.Checked then
        sWizMenuType := 'main'
    else
        sWizMenuType := 'pop';

    if not Assigned(FLinkWiz) then
    begin
        FLinkWiz := FLinkWizList.Items[FLinkWizList.Add];
    end;

    FLinkWiz.GetObjectInfo(sWizName, sWizCaption, sWizDLL, skWizHotKey, sWizMenuType);
    FLinkWizList.SaveCfg;

    ShowMessage('专家设置成功，重启IDE后生效！');

    ModalResult := mrOk;
end;

procedure TfrmWizSetting.edtWizDLLDblClick(Sender: TObject);
begin
    if dlgOpen.Execute then
        edtWizDLL.Text := dlgOpen.FileName;
end;

procedure TfrmWizSetting.edtWizDLLKeyPress(Sender: TObject; var Key: Char);
begin
    if Key = #8 then
        edtWizDLL.Clear;
end;

procedure TfrmWizSetting.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
    frmWizSetting := nil;
end;

procedure TfrmWizSetting.FormCreate(Sender: TObject);
begin
    FLinkWiz := nil;
    FLinkWizList := nil;
end;

procedure TfrmWizSetting.FormShow(Sender: TObject);
begin
    if Assigned(FLinkWiz) then
    begin
        edtWizCaption.Text := FLinkWiz.ObjectInfo.WizCaption;
        edtWizName.Text := FLinkWiz.ObjectInfo.WizName;
        edtWizDLL.Text := FLinkWiz.ObjectInfo.WizDLL;
        hkWizShortCut.HotKey := FLinkWiz.ObjectInfo.WizShortCut;
        
        if SameText(FLinkWiz.ObjectInfo.WizMenuType, 'main') then
            rbMainMenu.Checked := True
        else
            rbPopMenu.Checked := True;
    end;

end;

end.
