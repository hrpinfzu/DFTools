unit WizEntryUnit;

interface

uses
    ToolsAPI, InitWiz;

function InitWizard(const Services: IBorlandIDEServices;
    RegisterProc: TWizardRegisterProc;
    var TerminateProc: TWizardTerminateProc): Boolean; stdcall;

implementation

var
    iWizIndex: Integer;

procedure Terminate;
var
    WizardServices: IOTAWizardServices;
begin
    WizardServices := BorlandIDEServices as IOTAWizardServices;
    WizardServices.RemoveWizard(iWizIndex);
end;

function InitWizard(const Services: IBorlandIDEServices;
    RegisterProc: TWizardRegisterProc;
    var TerminateProc: TWizardTerminateProc): Boolean; stdcall;
var
    WizardServices: IOTAWizardServices;
begin
    BorlandIDEServices := Services;
    WizardServices := BorlandIDEServices as IOTAWizardServices;
    iWizIndex := WizardServices.AddWizard(TDTools.Create);

    TerminateProc := Terminate;
    Result := True;
end;

exports InitWizard name WizardEntryPoint;

end.
