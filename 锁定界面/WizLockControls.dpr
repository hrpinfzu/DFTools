library WizLockControls;

uses
  ShareMem,
  SysUtils,
  Classes,
  Forms,
  Global,
  LockControls;

{$R *.res}

procedure QueryInterface;
begin
    DoLockControls;
end;

procedure InitWiz(Cache: Pointer);
begin
    GlobalCache := TGlobalCache(Cache);
end;

exports QueryInterface;

exports InitWiz;

begin
end.
