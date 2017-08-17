unit VersionForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Menus, ToolsAPI;

type
  TfrmVersion = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    grpVersion: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    edtMajor: TEdit;
    edtMinor: TEdit;
    edtRelease: TEdit;
    edtBuild: TEdit;
    udMajor: TUpDown;
    udMinor: TUpDown;
    udRelease: TUpDown;
    udBuild: TUpDown;
    chkOnlyActive: TCheckBox;
    chkModifiedDefines: TCheckBox;
    edtDefines: TEdit;
    btnLoadActive: TButton;
    btnEditActive: TButton;
    procedure edtMajorKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure chkOnlyActiveClick(Sender: TObject);
    procedure edtDefinesChange(Sender: TObject);
    procedure chkModifiedDefinesClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnLoadActiveClick(Sender: TObject);
    procedure btnEditActiveClick(Sender: TObject);
  private
    FProjList: TList;
    FGroup: IOTAProjectGroup;

    procedure LoadProjectInfo(const AProj: IOTAProject);
    procedure LoadProjectList;
    function GetProj(Index: Integer): IOTAProject;
    function GetActiveProj: IOTAProject;
    function GetProjCount: Integer;

    property ProjLists[Index: Integer]: IOTAProject read GetProj;
    property ProjCount: Integer read GetProjCount;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmVersion: TfrmVersion;

implementation

uses
    DateUtils, WizConstUnit, CommonFun;

{$R *.dfm}

procedure TfrmVersion.btnEditActiveClick(Sender: TObject);
var
    iProj: IOTAProject;
begin
    iProj := GetActiveProj;

    if Assigned(iProj) then
        iProj.ProjectOptions.EditOptions;
end;

procedure TfrmVersion.btnLoadActiveClick(Sender: TObject);
var
    iProj: IOTAProject;
begin
    iProj := GetActiveProj;

    if Assigned(iProj) then
        LoadProjectInfo(iProj);   
end;

procedure TfrmVersion.btnOKClick(Sender: TObject);
    procedure SetProjectVersion(var AProj: IOTAProject);
    begin
        AProj.ProjectOptions.Values[OptionIncludeVerInfo] := True;
        AProj.ProjectOptions.Values[OptionMajorVersion] := udMajor.Position;
        AProj.ProjectOptions.Values[OptionMinorVersion] := udMinor.Position;
        AProj.ProjectOptions.Values[OptionRelease] := udRelease.Position;
        AProj.ProjectOptions.Values[OptionBuild] := udBuild.Position;
    end;

    procedure SetProjectDefines(var AProj: IOTAProject);
    begin
        if chkModifiedDefines.Checked then
            AProj.ProjectOptions.Values[OptionConditionalDefines] := edtDefines.Text;
    end;
var
    iProj: IOTAProject;
    I: Integer;
begin
    if chkOnlyActive.Checked then
    begin
        iProj := GetActiveProj;

        if Assigned(iProj) then
        begin
            SetProjectVersion(iProj);
            SetProjectDefines(iProj);
        end;
    end
    else
    begin
        for I := 0 to ProjCount - 1 do
        begin
            iProj := ProjLists[I];

            if Assigned(iProj) then
            begin
                SetProjectVersion(iProj);
                SetProjectDefines(iProj);
            end;
        end;
    end;
end;

procedure TfrmVersion.chkModifiedDefinesClick(Sender: TObject);
begin
    SaveCfg(Cfg_Version_ModifyDefines, BoolToStr(chkModifiedDefines.Checked), Sec_Version);
end;

procedure TfrmVersion.chkOnlyActiveClick(Sender: TObject);
begin
    SaveCfg(Cfg_Version_OnlyActinve, BoolToStr(chkOnlyActive.Checked), Sec_Version);
end;

procedure TfrmVersion.edtDefinesChange(Sender: TObject);
begin
    SaveCfg(Cfg_Version_ConditDefines, edtDefines.Text, Sec_Version);
end;

procedure TfrmVersion.edtMajorKeyPress(Sender: TObject; var Key: Char);
begin
    if not (Key in ['0'..'9', #8]) then
        Key := #0;

end;

procedure TfrmVersion.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
    frmVersion := nil;
end;

procedure TfrmVersion.FormCreate(Sender: TObject);
begin
    FProjList := TList.Create;
    FGroup := nil;
    LoadProjectList;

    udMajor.Position := YearOf(Now);
    udMinor.Position := MonthOf(Now);
    udRelease.Position := DayOf(Now);
    udBuild.Position := 1;

    chkOnlyActive.Checked := StrToBoolDef(GetCfg(Cfg_Version_OnlyActinve, '-1', Sec_Version), False);
    chkModifiedDefines.Checked := StrToBoolDef(GetCfg(Cfg_Version_ModifyDefines, '-1', Sec_Version), False);
    edtDefines.Text := GetCfg(Cfg_Version_ConditDefines, '_DEBUG;NO_STRICT;DevVer', Sec_Version);
end;

procedure TfrmVersion.FormDestroy(Sender: TObject);
begin
    FreeAndNil(FProjList);
end;

function TfrmVersion.GetActiveProj: IOTAProject;
begin
    Result := nil;
    if Assigned(FGroup) then
        Result := FGroup.ActiveProject
    else if FProjList.Count > 0 then  
        Result := ProjLists[0];
end;

function TfrmVersion.GetProj(Index: Integer): IOTAProject;
begin
    Result := nil;

    if (Index < 0) or (Index >= FProjList.Count) then
        Exit;

    Result := IOTAProject(FProjList[Index]);
end;

function TfrmVersion.GetProjCount: Integer;
begin
    Result := FProjList.Count;
end;

procedure TfrmVersion.LoadProjectInfo(const AProj: IOTAProject);
begin
    udMajor.Position := AProj.ProjectOptions.Values[OptionMajorVersion];
    udMinor.Position := AProj.ProjectOptions.Values[OptionMinorVersion];
    udRelease.Position := AProj.ProjectOptions.Values[OptionRelease];
    udBuild.Position := AProj.ProjectOptions.Values[OptionBuild];

    edtDefines.Text := AProj.ProjectOptions.Values[OptionConditionalDefines];
end;

procedure TfrmVersion.LoadProjectList;
var
    i, j: Integer;
    iSrv: IOTAModuleServices;
    iModule: IOTAModule;
    iProj: IOTAProject;
    iGroup: IOTAProjectGroup;
begin
    FProjList.Clear;

    if not Supports(BorlandIDEServices, IOTAModuleServices, iSrv) then
        Exit;

    for i := 0 to iSrv.ModuleCount - 1 do
    begin
        iModule := iSrv.Modules[i];

        if Supports(iModule, IOTAProjectGroup, iGroup) then
        begin
            FGroup := iGroup;
            for j := 0 to FGroup.ProjectCount - 1 do
            begin
                FProjList.Add(Pointer(FGroup.Projects[j]));
            end;
            Break;
        end
        else if Supports(iModule, IOTAProject, iProj) then
        begin
            FProjList.Add(Pointer(iProj));
        end
    end;
end;

end.
