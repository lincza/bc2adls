codeunit 82579 "ADLSE Multi Company Export"
{
    Permissions = tabledata "ADLSE Company Setup Table" = RIMD;
    TableNo = "ADLSE Company Setup Table";
    trigger OnRun()
    var
        ADLSECompanySetupTable: Record "ADLSE Company Setup Table";
        SessionId: Integer;
    begin
        ADLSECompanySetupTable.Reset();
        if Rec.HasFilter then
            ADLSECompanySetupTable.CopyFilters(Rec);
        if ADLSECompanySetupTable.FindSet() then
            repeat
                Clear(SessionId);
                session.StartSession(SessionId, Codeunit::"ADLSE Execution", ADLSECompanySetupTable."Sync Company");
                repeat
                    Sleep(5000);
                until not Session.IsSessionActive(SessionId);
                Commit();// Commit after each company is done. To prevent rollback of everything
            until ADLSECompanySetupTable.Next() = 0;
    end;

}