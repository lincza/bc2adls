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
            ADLSECompanySetupTable.SetFilter("Sync Company", Rec."Parameter String")
        else
            ADLSECompanySetupTable.SetFilter("Sync Company", '%1', GetDistinctCompanyNames());
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

    local procedure GetDistinctCompanyNames(): Text
    var
        ADLSECompanySetupTable: Record "ADLSE Company Setup Table";
        CompanyNames: Text;
    begin
        if ADLSECompanySetupTable.FindSet() then
            repeat
                if not CompanyNames.Contains(ADLSECompanySetupTable."Sync Company") then
                    if CompanyNames = '' then
                        CompanyNames := ADLSECompanySetupTable."Sync Company"
                    else
                        CompanyNames := CompanyNames + '|' + ADLSECompanySetupTable."Sync Company";
            until ADLSECompanySetupTable.Next() < 1;
    end;

}