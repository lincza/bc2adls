page 82565 "ADLSE Company Setup Tables"
{
    Caption = 'Company Tables';
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "ADLSE Company Setup Table";


    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                }
                field("Table Caption"; Rec."Table Caption")
                {
                    ApplicationArea = All;
                }
                field("Sync Company"; Rec."Sync Company")
                {
                    ApplicationArea = All;
                }
                field("Last Sync"; Rec."Last Sync")
                {
                    ApplicationArea = All;
                }
                field(FieldsChosen; NumberFieldsChosenValue)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = '# Fields selected';
                    ToolTip = 'Specifies if any field has been chosen to be exported. Click on Choose Fields action to add fields to export.';
                }
                field(Status; LastRunState)
                {
                    ApplicationArea = All;
                    Caption = 'Last exported state';
                    Editable = false;
                    ToolTip = 'Specifies the status of the last export from this table in this company.';
                }
                field(LastRanAt; LastStarted)
                {
                    ApplicationArea = All;
                    Caption = 'Last started at';
                    Editable = false;
                    ToolTip = 'Specifies the time of the last export from this table in this company.';
                }
                field(LastError; LastRunError)
                {
                    ApplicationArea = All;
                    Caption = 'Last error';
                    Editable = false;
                    ToolTip = 'Specifies the error message from the last export of this table in this company.';
                }
                field(LastTimestamp; UpdatedLastTimestamp)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the timestamp of the record in this table that was exported last.';
                    Caption = 'Last timestamp';
                    Visible = false;
                }
                field(LastTimestampDeleted; DeletedRecordLastEntryNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the timestamp of the deleted records in this table that was exported last.';
                    Caption = 'Last timestamp deleted';
                    Visible = false;
                }


            }
        }
    }

    actions
    {
        area(Processing)
        {

        }
    }
    trigger OnAfterGetRecord()
    var
        TableMetadata: Record "Table Metadata";
        ADLSETableLastTimestamp: Record "ADLSE Table Last Timestamp";
        ADLSERun: Record "ADLSE Run";
        ADLSETable: Record "ADLSE Table";
    begin
        if ADLSETable.Get(Rec."Table ID") then begin
            if TableMetadata.Get(Rec."Table ID") then begin
                NumberFieldsChosenValue := ADLSETable.FieldsChosen();
                UpdatedLastTimestamp := ADLSETableLastTimestamp.GetUpdatedLastTimestamp(Rec."Table ID");
                DeletedRecordLastEntryNo := ADLSETableLastTimestamp.GetDeletedLastEntryNo(Rec."Table ID");
            end else begin
                NumberFieldsChosenValue := 0;
                UpdatedLastTimestamp := 0;
                DeletedRecordLastEntryNo := 0;
                Rec.Modify(true);
            end;
            ADLSERun.GetLastRunDetailsPerCompany(Rec."Table ID", LastRunState, LastStarted, LastRunError, Rec."Sync Company");
        end;
    end;

    var
        UpdatedLastTimestamp: BigInteger;
        DeletedRecordLastEntryNo: BigInteger;
        LastRunState: Enum "ADLSE Run State";
        LastStarted: DateTime;
        LastRunError: Text[2048];
        NumberFieldsChosenValue: Integer;
}
