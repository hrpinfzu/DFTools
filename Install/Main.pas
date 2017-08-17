{-$DEFINE ToolsDebug}

unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmMain = class(TForm)
    btnInstall: TButton;
    btnUninstall: TButton;
    cbbDelphiVer: TComboBox;
    procedure btnInstallClick(Sender: TObject);
    procedure btnUninstallClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
    Registry, Tlhelp32;

{$R *.dfm}

var
    BDSRootDir: string;

// 检测bds.exe进程是否存在
function CheckProcess(ProcessName: string): Boolean;
var
    hSnapshot: THandle; //用于获得进程列表
    lppe: TProcessEntry32;//用于查找进程
    Found: Boolean;     //用于判断进程遍历是否完成
begin
    {$IFDEF ToolsDebug}
    Result := False;
    Exit;
    {$ENDIF}

    Result := True;

    hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);//获得系统进程列表
    lppe.dwSize := SizeOf(TProcessEntry32);//在调用Process32First API之前，需要初始化lppe记录的大小
    Found := Process32First(hSnapshot, lppe);//将进程列表的第一个进程信息读入ppe记录中
    while Found do
    begin
        if ( SameText(LowerCase(ExtractFileName(lppe.szExeFile)), LowerCase(ProcessName))
            or (LowerCase(lppe.szExeFile ) = LowerCase(ProcessName)) ) then
        begin
            Exit;
        end;
        Found := Process32Next(hSnapshot, lppe);//将进程列表的下一个进程信息读入lppe记录中
    end;

    Result := False;
end;


procedure TfrmMain.btnInstallClick(Sender: TObject);
var
    Reg: TRegistry;
    DVer: string;
    DKeyRoot: string;
begin
    DVer := cbbDelphiVer.Text;
    Reg := TRegistry.Create;
    try
        Reg.RootKey := HKEY_CURRENT_USER;
        if DVer = 'Delphi 2007' then
        begin
            DKeyRoot := 'Software\Borland\BDS\5.0';
        end
        else if DVer = 'Delphi 2010' then
        begin
            DKeyRoot := 'Software\CodeGear\BDS\7.0';
        end;

        if not Reg.OpenKey(DKeyRoot, False) then
        begin
            ShowMessage('未安装CodeGear Rad Studio，安装失败！');
            Exit;
        end;

        if CheckProcess('bds.exe') then
        begin
            ShowMessage('安装前必须先关闭Rad Studio！');
            Exit;
        end;

        BDSRootDir := Reg.ReadString('RootDir');
        Reg.CloseKey;

        if not Reg.OpenKey(DKeyRoot + '\Experts', False) then
        begin
            ShowMessage('无法加载Rad插件列表，安装失败！');
            Exit;
        end;

        if Reg.ValueExists('DTools') then
        begin
            ShowMessage('系统已安装DTools，勿重复安装！');
            Exit;
        end;

        ForceDirectories(BDSRootDir + 'bin\Experts');
        ForceDirectories(BDSRootDir + 'bin\Experts\DLL');
        ForceDirectories(BDSRootDir + 'bin\Experts\ini');
        CopyFile('DTools.dll', PChar(BDSRootDir + 'bin\Experts\DTools.dll'), False);
        CopyFile('WizAutoClassFunc.dll', PChar(BDSRootDir + 'bin\Experts\DLL\WizAutoClassFunc.dll'), False);
        CopyFile('WizFindComp.dll', PChar(BDSRootDir + 'bin\Experts\DLL\WizFindComp.dll'), False);
        CopyFile('WizVersion.dll', PChar(BDSRootDir + 'bin\Experts\DLL\WizVersion.dll'), False);
        CopyFile('SrcVerMan.dll', PChar(BDSRootDir + 'bin\Experts\DLL\SrcVerMan.dll'), False);
        CopyFile('Config.ini', PChar(BDSRootDir + 'bin\Experts\Ini\Config.ini'), False);

        Reg.WriteString('DTools', BDSRootDir + 'bin\Experts\DTools.dll');
        Reg.CloseKey;
        ShowMessage('DTools安装成功！');
    finally
        FreeAndNil(Reg);
    end;
end;

procedure TfrmMain.btnUninstallClick(Sender: TObject);
var
    Reg: TRegistry;
begin
    Reg := TRegistry.Create;
    try
        Reg.RootKey := HKEY_CURRENT_USER;
        if not Reg.OpenKey('Software\Borland\BDS\5.0', False) then
        begin
            ShowMessage('未安装CodeGear Rad Studio 2007，卸载失败！');
            Exit;
        end;

        if CheckProcess('bds.exe') then
        begin
            ShowMessage('卸载前必须先关闭Rad Studio！');
            Exit;
        end;

        BDSRootDir := Reg.ReadString('RootDir');
        Reg.CloseKey;

        if not Reg.OpenKey('Software\Borland\BDS\5.0\Experts', False) then
        begin
            ShowMessage('无法加载Rad插件列表，卸载失败！');
            Exit;
        end;

        if not Reg.ValueExists('DTools') then
        begin
            ShowMessage('系统未安装DTools，无需进行写在！');
            Exit;
        end;

        Reg.DeleteValue('DTools');
        DeleteFile(BDSRootDir + 'bin\Experts\DTools.dll');
        RemoveDir(BDSRootDir + 'bin\Experts\DLL');
        RemoveDir(BDSRootDir + 'bin\Experts\Ini');

        Reg.CloseKey;
        ShowMessage('DTools卸载成功！');
    finally
        FreeAndNil(Reg);
    end;
end;

end.
