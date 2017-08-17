library WizAutoClassFunc;

uses
  ShareMem,
  Forms,
  Dialogs,
  SysUtils,
  Classes,
  Global,
  AutoClassFuncImpl in 'AutoClassFuncImpl.pas';

{$R *.res}

procedure QueryInterface;
begin
    AutoMakeDevSource;
end;

procedure InitWiz(Cache: Pointer);
begin
    GlobalCache := TGlobalCache(Cache);
end;

exports QueryInterface;

exports InitWiz;

begin
end.
