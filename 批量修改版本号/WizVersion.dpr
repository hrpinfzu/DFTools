library WizVersion;

uses
    ShareMem,
    SysUtils,
    Classes,
    Forms,
    Global,
    VersionForm in 'VersionForm.pas' {frmVersion};

{$R *.res}

procedure QueryInterface;
begin
    frmVersion := TfrmVersion.Create(Application);
    try
        frmVersion.ShowModal;
    finally
        FreeAndNil(frmVersion);
    end;   
end;

procedure InitWiz(Cache: Pointer);
begin
    GlobalCache := TGlobalCache(Cache);
end;

exports QueryInterface;

exports InitWiz;

begin
end.
