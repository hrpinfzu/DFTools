unit CommonFun;

interface

function GetCfg(sKey: string; sDefValue: string = ''; sSection: string = 'WizardCfg'): string;
procedure SaveCfg(sKey: string; sValue: string; sSection: string = 'WizardCfg');

procedure SaveToIni(ComponentName, ComponentValue, FormName: string);
function GetFromIni(ComponentName, FormName: string; DefaultValue: string = ''): string;

implementation

uses
    SysUtils, IniFiles, Forms, Dialogs, Global, WizConstUnit;

procedure SaveCfg(sKey: string; sValue: string; sSection: string = 'WizardCfg');
var
    iFile: TIniFile;
begin
    sSection := Trim(sSection);
    if SameText(sSection, '') then
        sSection := 'WizardCfg';

    iFile := TIniFile.Create(GlobalCache.WizIniPath + 'Config.ini');
    with iFile do
    try
        WriteString(sSection, sKey, sValue);
        UpdateFile;
    finally
        FreeAndNil(iFile);
    end;
end;

function GetCfg(sKey: string; sDefValue: string = ''; sSection: string = 'WizardCfg'): string;
var
    iFile: TIniFile;
begin
    Result := '';
    sSection := Trim(sSection);
    if SameText(sSection, '') then
        sSection := 'WizardCfg';

    iFile := TIniFile.Create(GlobalCache.WizIniPath + 'Config.ini');
    with iFile do
    try
        Result := ReadString(sSection, sKey, sDefValue); 
    finally
        FreeAndNil(iFile);
    end;
end;

procedure SaveToIni(ComponentName, ComponentValue, FormName: string);
var
    iFile: TIniFile;
begin
    FormName := Trim(FormName);

    iFile := TIniFile.Create(GlobalCache.WizIniPath + 'Config.ini');
    with iFile do
    try
        WriteString(Sec_PageSet + '_' + FormName, ComponentName, ComponentValue);
        UpdateFile;
    finally
        FreeAndNil(iFile);
    end;
end;

function GetFromIni(ComponentName, FormName: string; DefaultValue: string = ''): string;
var
    iFile: TIniFile;
begin
    Result := '';
    FormName := Trim(FormName);

    iFile := TIniFile.Create(GlobalCache.WizIniPath + 'Config.ini');
    with iFile do
    try
        Result := ReadString(Sec_PageSet + '_' + FormName, ComponentName, DefaultValue);
    finally
        FreeAndNil(iFile);
    end;
end; 

end.
