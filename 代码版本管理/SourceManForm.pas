unit SourceManForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls;

type
    TFindFileCallBack = function(const ADefineName, AFileName: string): Integer;

  TfrmSourceMan = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    edtSourceDir: TEdit;
    btnSelDir: TSpeedButton;
    btnSearch: TButton;
    btnReplace: TButton;
    edtDefines: TEdit;
    Label3: TLabel;
    edtFileMasks: TEdit;
    lvFileList: TListView;
    stat: TStatusBar;
    procedure edtSourceDirDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnReplaceClick(Sender: TObject);
  private
    procedure FindFileList(const APath, RootPath, ADefines: string; ACallBack: TFindFileCallBack);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSourceMan: TfrmSourceMan;

implementation

{$R *.dfm}

uses
    FileCtrl, StrUtils, CommonFun, WizConstUnit;

procedure TfrmSourceMan.FindFileList(const APath, RootPath, ADefines: string;
    ACallBack: TFindFileCallBack);
var
    ExtList: TStringList;
    sr: TSearchRec;
    fr, matchtimes: Integer;
    AItem: TListItem;
    SrFilePath: string;
begin
    ExtList := TStringList.Create;
    try
        ExtList.Delimiter := ';';
        ExtList.DelimitedText := Trim(edtFileMasks.Text);

        fr := FindFirst(APath + '\*.*', faAnyFile, sr);
        while fr = 0 do
        begin
            if ( sr.Attr = faDirectory ) and ( sr.Name <> '.' )
                and ( sr.Name <> '..' ) then
                FindFileList(APath + '\' + sr.Name, RootPath, ADefines, ACallBack)
            else
            begin
                if ExtList.IndexOf('*' + ExtractFileExt(sr.Name)) >= 0 then
                begin
                    matchtimes := ACallBack(ADefines, APath + '\' + sr.Name);
                    if matchtimes > 0 then
                    begin
                        stat.Tag := stat.Tag + matchtimes;
                        AItem := lvFileList.Items.Add;
                        AItem.Caption := IntToStr(lvFileList.Items.Count);
                        AItem.SubItems.Add(ExtractFileName(sr.Name));
                        AItem.SubItems.Add(IntToStr(matchtimes));

                        SrFilePath := '';
                        if not SameText(APath, RootPath) then
                            SrFilePath := StringReplace(ExtractFileDir(APath + '\' + sr.Name)
                                , RootPath + '\', '', []);
                        AItem.SubItems.Add(SrFilePath);

                        stat.Panels[0].Text := Format('match %d times in %d files.',
                            [stat.Tag, lvFileList.Items.Count]);
                    end;
                end;
            end;
            fr := FindNext(sr);
            Application.ProcessMessages;
        end;
        FindClose(sr);
    finally
        ExtList.Free;
    end;
end;

function SearchDefines(const ADefineName, AFileName: string): Integer;
var
    sl: TStringList;
    cPos, iLen: Integer;
begin
    Result := 0;
    iLen := Length(ADefineName);
    sl := TStringList.Create;
    try
        sl.LoadFromFile(AFileName);

        cPos := Pos(ADefineName, sl.Text);
        while cPos > 0 do
        begin
            Inc(Result);
            cPos := PosEx(ADefineName, sl.Text, cPos + iLen);
        end;         
    finally
        sl.Free;
    end;
end;

procedure ReplaceDefines(const ADefineName, AFileName: string);
var
    sl: TStringList;
    sPos, ePos, iLen, iTagLen: Integer;
    sFileStr, sFixStr, sEndTag: string;
begin
    iLen := Length(ADefineName);
    sEndTag := '#endif';
    iTagLen := Length(sEndTag);
    sl := TStringList.Create;
    try
        sl.LoadFromFile(AFileName);
        sFileStr := sl.Text;
        sPos := Pos(ADefineName, sFileStr);
        ePos := PosEx('#endif', sFileStr, sPos) + iTagLen;
        while (sPos > 0) and (ePos > 0) do
        begin
            sFixStr := Copy(sFileStr, sPos, ePos - sPos);
            // 处理编译开关
            if Pos('#else', sFixStr) > 0 then
                sFixStr := Copy(sFixStr, iLen + 1, Pos('#else', sFixStr) - iLen - 1)
            else
                sFixStr := Copy(sFixStr, iLen + 1, Pos(sEndTag, sFixStr) - iLen - 1);

            sFixStr := Trim(sFixStr);
            
            Delete(sFileStr, sPos, ePos - sPos);
            Insert(sFixStr, sFileStr, sPos);
            sPos := Pos(ADefineName, sFileStr);
            ePos := PosEx(sEndTag, sFileStr, sPos) + iTagLen;
        end;

        sl.Text := sFileStr;
        sl.SaveToFile(AFileName);
    finally
        sl.Free;
    end;
end;

procedure TfrmSourceMan.btnReplaceClick(Sender: TObject);
var
    I: Integer;
    AItem: TListItem;
    SrcDir, DevDefines: string;
begin
    stat.Panels[0].Text := '';
    stat.Panels[1].Text := '正在替换...';

    SrcDir := Trim(edtSourceDir.Text);
    DevDefines := Trim(edtDefines.Text);
    for I := 0 to lvFileList.Items.Count - 1 do
    begin
        AItem := lvFileList.Items[I];
        ReplaceDefines(DevDefines, SrcDir + '\'
            + IfThen(SameText(AItem.SubItems[2], ''), '', AItem.SubItems[2] + '\')
            + AItem.SubItems[0]);
        Application.ProcessMessages;
    end;

    stat.Panels[1].Text := '替换完毕.';
end;

procedure TfrmSourceMan.btnSearchClick(Sender: TObject);
var
    SrcDir, DevDefines: string;
    I: Integer;
    iCatchTimes, TotalTimes: Integer;
    AItem: TListItem;
begin
    SrcDir := Trim(edtSourceDir.Text);
    if not DirectoryExists(SrcDir) then
    begin
        ShowMessage('请先选择源码路径');
        Exit;
    end;

    DevDefines := Trim(edtDefines.Text);
    if SameText(DevDefines, '') then
    begin
        ShowMessage('请先设置好编译开关');
        Exit;
    end;

    stat.Panels[0].Text := '';
    stat.Panels[1].Text := '正在查找...';
    lvFileList.Items.Clear;
    stat.Tag := 0;
    FindFileList(SrcDir, SrcDir, DevDefines, SearchDefines);

    TotalTimes := 0;
    for I := 0 to lvFileList.Items.Count - 1 do
    begin
        AItem := lvFileList.Items[I];
        Inc(TotalTimes, StrToIntDef(AItem.SubItems[1], 0));
        Application.ProcessMessages;
    end;

    stat.Panels[1].Text := '查找完毕.';
end;

procedure TfrmSourceMan.edtSourceDirDblClick(Sender: TObject);
var
    SrcDir: string;
begin
    SrcDir := Trim(edtSourceDir.Text);
    if SelectDirectory('选择源码路径', '', SrcDir) then
    begin
        edtSourceDir.Text := SrcDir;
        SaveCfg('SrcDir', SrcDir, Sec_OtherSet);
    end;
end;

procedure TfrmSourceMan.FormCreate(Sender: TObject);
begin
    edtDefines.Text := '#ifdef ' + GetCfg(Cfg_CommonSet_CustDefines, 'DevVer', Sec_CommonSet);
    edtSourceDir.Text := GetCfg('SrcDir', '', Sec_OtherSet);
    edtFileMasks.Text := GetCfg('FileMasks', '*.cpp;*.h;*.hpp;*.pas', Sec_OtherSet);
end;

procedure TfrmSourceMan.FormDestroy(Sender: TObject);
begin
    SaveCfg('FileMasks', Trim(edtFileMasks.Text), Sec_OtherSet);
end;

end.
