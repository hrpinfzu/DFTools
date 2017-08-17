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

// ���bds.exe�����Ƿ����
function CheckProcess(ProcessName: string): Boolean;
var
    hSnapshot: THandle; //���ڻ�ý����б�
    lppe: TProcessEntry32;//���ڲ��ҽ���
    Found: Boolean;     //�����жϽ��̱����Ƿ����
begin
    {$IFDEF ToolsDebug}
    Result := False;
    Exit;
    {$ENDIF}

    Result := True;

    hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);//���ϵͳ�����б�
    lppe.dwSize := SizeOf(TProcessEntry32);//�ڵ���Process32First API֮ǰ����Ҫ��ʼ��lppe��¼�Ĵ�С
    Found := Process32First(hSnapshot, lppe);//�������б�ĵ�һ��������Ϣ����ppe��¼��
    while Found do
    begin
        if ( SameText(LowerCase(ExtractFileName(lppe.szExeFile)), LowerCase(ProcessName))
            or (LowerCase(lppe.szExeFile ) = LowerCase(ProcessName)) ) then
        begin
            Exit;
        end;
        Found := Process32Next(hSnapshot, lppe);//�������б����һ��������Ϣ����lppe��¼��
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
            ShowMessage('δ��װCodeGear Rad Studio����װʧ�ܣ�');
            Exit;
        end;

        if CheckProcess('bds.exe') then
        begin
            ShowMessage('��װǰ�����ȹر�Rad Studio��');
            Exit;
        end;

        BDSRootDir := Reg.ReadString('RootDir');
        Reg.CloseKey;

        if not Reg.OpenKey(DKeyRoot + '\Experts', False) then
        begin
            ShowMessage('�޷�����Rad����б���װʧ�ܣ�');
            Exit;
        end;

        if Reg.ValueExists('DTools') then
        begin
            ShowMessage('ϵͳ�Ѱ�װDTools�����ظ���װ��');
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
        ShowMessage('DTools��װ�ɹ���');
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
            ShowMessage('δ��װCodeGear Rad Studio 2007��ж��ʧ�ܣ�');
            Exit;
        end;

        if CheckProcess('bds.exe') then
        begin
            ShowMessage('ж��ǰ�����ȹر�Rad Studio��');
            Exit;
        end;

        BDSRootDir := Reg.ReadString('RootDir');
        Reg.CloseKey;

        if not Reg.OpenKey('Software\Borland\BDS\5.0\Experts', False) then
        begin
            ShowMessage('�޷�����Rad����б�ж��ʧ�ܣ�');
            Exit;
        end;

        if not Reg.ValueExists('DTools') then
        begin
            ShowMessage('ϵͳδ��װDTools���������д�ڣ�');
            Exit;
        end;

        Reg.DeleteValue('DTools');
        DeleteFile(BDSRootDir + 'bin\Experts\DTools.dll');
        RemoveDir(BDSRootDir + 'bin\Experts\DLL');
        RemoveDir(BDSRootDir + 'bin\Experts\Ini');

        Reg.CloseKey;
        ShowMessage('DToolsж�سɹ���');
    finally
        FreeAndNil(Reg);
    end;
end;

end.
