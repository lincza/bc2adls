codeunit 82579 "ADLSE Multi Company Export"
{
    Permissions = tabledata "ADLSE Company Setup Table" = RIMD;
    TableNo = "Job Queue Entry";
    trigger OnRun()
    var
        ADLSECompanySetupTable: Record "ADLSE Company Setup Table";
        SessionId: Integer;
    begin
        ADLSECompanySetupTable.Reset();
        if Rec."Parameter String" <> '' then
            ADLSECompanySetupTable.SetFilter("Sync Company", Rec."Parameter String");
        ADLSECompanySetupTable.SetFilter("Table ID", GetFirstTableId());
        if ADLSECompanySetupTable.FindSet() then
            repeat
                Clear(SessionId);
                if session.StartSession(SessionId, Codeunit::"ADLSE Execution", ADLSECompanySetupTable."Sync Company") then begin
                    repeat
                        Sleep(10000);
                    until not Session.IsSessionActive(SessionId);
                    Commit();// Commit after each company is done. To prevent rollback of everything
                end;
            until ADLSECompanySetupTable.Next() = 0;
    end;

    local procedure GetFirstTableId(): Text
    var
        ADLSETable: Record "ADLSE Table";
    begin
        if ADLSETable.FindFirst() then
            exit(Format(ADLSETable."Table ID"));
    end;

}