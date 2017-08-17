unit WizMan;

interface

uses
    SysUtils, Classes;

type
    TQueryInterface = procedure;
    TInitWiz = procedure (App: Pointer);

    TMenuType = (mtMain, mtPop);

    TWizObjectInfo = class
        WizName: string;
        WizCaption: string;
        WizDLL: string;
        WizHandle: THandle;
        WizShortCut: TShortCut;
        WizMenuType: string;
        WizQueryIntf: TQueryInterface;
        WizInitIntf: TInitWiz;
    end;

    TWizObject = class
    private 
        FObjectInfo: TWizObjectInfo;
    public
        constructor Create;
        destructor Destroy; override;

        procedure LoadWiz(SWizName: string);
        procedure OnClick(Sender: TObject);
        procedure GetObjectInfo(sWizName, sWizCaption, sWizDLL: string;
            sShortCut: TShortCut; sWizMenuType: string);

        property ObjectInfo: TWizObjectInfo read FObjectInfo;
    end;

    TWizObjects = class
    private
        FWizObjects: TList; 
        function GetCount: Integer;
        function GetWiz(Index: Integer): TWizObject;
        procedure SetWiz(Index: Integer; const Value: TWizObject);
    public
        constructor Create;
        destructor Destroy; override;

        function Add: Integer;
        procedure Delete(Index: Integer);
        procedure Clear;

        function IndexOfName(Name: string): Integer;
        function IndexOfCaption(Caption: string): Integer;

        procedure SaveCfg;

        property Count: Integer read GetCount;
        property Items[Index: Integer]: TWizObject read GetWiz write SetWiz; default;
    end;

implementation

uses
    Windows, CommonFun, WizConstUnit, Global;

const
    Sec_WizManHeader = Sec_WizMan + '_Detail_';

{ TWizObjects }

function TWizObjects.Add: Integer;
begin
    Result := FWizObjects.Add(TWizObject.Create);
end;

procedure TWizObjects.Clear;
var
    I: Integer;
begin
    for I := FWizObjects.Count - 1 downto 0 do
    begin
        TObject(FWizObjects[I]).Free;
    end;

    FWizObjects.Clear;
end;

constructor TWizObjects.Create;
begin
    FWizObjects := TList.Create;
end;

procedure TWizObjects.Delete(Index: Integer);
begin
    if ( Index > 0) and (Index < FWizObjects.Count) then
    begin
        TWizObject(FWizObjects[Index]).Free;
        FWizObjects.Delete(Index);
    end;
end;

destructor TWizObjects.Destroy;
begin
    Clear;
    FreeAndNil(FWizObjects);

    inherited;
end;

function TWizObjects.GetCount: Integer;
begin
    Result := FWizObjects.Count;
end;

function TWizObjects.GetWiz(Index: Integer): TWizObject;
begin
    Result := nil;

    if ( Index >= 0) and (Index < FWizObjects.Count) then
    begin
        Result := TWizObject(FWizObjects[Index]);
    end;
end;

function TWizObjects.IndexOfName(Name: string): Integer;
var
    I: Integer;
begin
    Result := -1;
    for I := 0 to Count - 1 do
    begin
        if SameText(Items[I].ObjectInfo.WizName, Name) then
            Result := I;
    end;
end;

function TWizObjects.IndexOfCaption(Caption: string): Integer;
var
    I: Integer;
begin
    Result := -1;
    for I := 0 to Count - 1 do
    begin
        if SameText(Items[I].ObjectInfo.WizCaption, Caption) then
            Result := I;
    end;
end;

procedure TWizObjects.SaveCfg;
var
    I: Integer;
    WizObject: TWizObject;
    sWizName: string;
begin
    CommonFun.SaveCfg('WizCount', IntToStr(Count), Sec_WizMan);

    for I := 0 to Count - 1 do
    begin
        WizObject := Items[I];
        sWizName := WizObject.ObjectInfo.WizName;
        CommonFun.SaveCfg('Item' + IntToStr(I), sWizName, Sec_WizMan);

        CommonFun.SaveCfg('WizCaption', WizObject.ObjectInfo.WizCaption, Sec_WizManHeader + sWizName);
        CommonFun.SaveCfg('WizDLL', WizObject.ObjectInfo.WizDLL, Sec_WizManHeader + sWizName);
        CommonFun.SaveCfg('WizShortCut', IntToStr(WizObject.ObjectInfo.WizShortCut), Sec_WizManHeader + sWizName);
        CommonFun.SaveCfg('WizMenuType', WizObject.ObjectInfo.WizMenuType, Sec_WizManHeader + sWizName);
    end;
end;

procedure TWizObjects.SetWiz(Index: Integer; const Value: TWizObject);
begin
    if ( Index >= 0) and (Index < FWizObjects.Count) then
    begin
        FWizObjects[Index] := Value;
    end;
end;

{ TWizObject }

constructor TWizObject.Create;
begin
    FObjectInfo := TWizObjectInfo.Create;

    FObjectInfo.WizName := '';
    FObjectInfo.WizCaption := '';
    FObjectInfo.WizDLL := '';
    FObjectInfo.WizHandle := 0;
    FObjectInfo.WizShortCut := 0;
    FObjectInfo.WizMenuType := '';
    FObjectInfo.WizQueryIntf := nil;
    FObjectInfo.WizInitIntf := nil;
end;

destructor TWizObject.Destroy;
begin
    if FObjectInfo.WizHandle > 0 then
        FreeLibrary(FObjectInfo.WizHandle);

    FObjectInfo.WizName := '';
    FObjectInfo.WizCaption := '';
    FObjectInfo.WizDLL := '';
    FObjectInfo.WizHandle := 0;
    FObjectInfo.WizShortCut := 0;
    FObjectInfo.WizMenuType := '';
    FObjectInfo.WizQueryIntf := nil;
    FObjectInfo.WizInitIntf := nil;

    FObjectInfo.Free;

    inherited;
end;

procedure TWizObject.GetObjectInfo(sWizName, sWizCaption, sWizDLL: string;
    sShortCut: TShortCut; sWizMenuType: string);
begin
    FObjectInfo.WizName := sWizName;
    FObjectInfo.WizCaption := sWizCaption;
    FObjectInfo.WizDLL := sWizDLL;
    FObjectInfo.WizShortCut := sShortCut;
    FObjectInfo.WizMenuType := sWizMenuType;
end;

procedure TWizObject.LoadWiz(sWizName: string);
var
    sWizDLL: string;
begin
    FObjectInfo.WizName := sWizName;
    FObjectInfo.WizCaption := GetCfg('WizCaption', '', Sec_WizManHeader + sWizName);
    FObjectInfo.WizMenuType := GetCfg('WizMenuType', 'main', Sec_WizManHeader + SWizName);

    sWizDLL := GetCfg('WizDLL', '', Sec_WizManHeader + sWizName);
    FObjectInfo.WizDLL := sWizDLL;

    // ¼æÈÝ¾ÉÅäÖÃÎÄ¼þ
    if not FileExists(sWizDLL) then
        sWizDLL := GlobalCache.WizDLLPath + ExtractFileName(sWizDLL);

    if FileExists(sWizDLL) then
    begin
        FObjectInfo.WizHandle := LoadLibrary(PChar(sWizDLL));
        if FObjectInfo.WizHandle > 0 then
        begin
            @FObjectInfo.WizQueryIntf := GetProcAddress(FObjectInfo.WizHandle, 'QueryInterface');
            @FObjectInfo.WizInitIntf := GetProcAddress(FObjectInfo.WizHandle, 'InitWiz');

            FObjectInfo.WizShortCut := StrToIntDef(GetCfg('WizShortCut', '0', Sec_WizManHeader + SWizName), 0);
        end;
    end;
end;

procedure TWizObject.OnClick(Sender: TObject);
begin
    if Assigned(FObjectInfo.WizQueryIntf) then
        FObjectInfo.WizQueryIntf();
end;

end.
