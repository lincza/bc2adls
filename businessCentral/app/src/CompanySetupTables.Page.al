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
                    ToolTip = 'Specifies the internal ID of the table to export.';
                }
                field("Table Caption"; Rec."Table Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the caption of the table to export.';
                }
                field("Sync Company"; Rec."Sync Company")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the company this table is synced for.';
                }
                field(FieldsChosen; NumberFieldsChosenValue)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = '# Fields selected';
                    ToolTip = 'Specifies if any field has been chosen to be exported. Click on Choose Fields action to add fields to export.';
                }
                field(Status; Rec."Last Run State")
                {
                    ApplicationArea = All;
                    Caption = 'Last exported state';
                    Editable = false;
                    ToolTip = 'Specifies the status of the last export from this table in this company.';
                }
                field("Last Started"; Rec."Last Started")
                {
                    ApplicationArea = All;
                    Caption = 'Last started at';
                    Editable = false;
                    ToolTip = 'Specifies the time of the last export from this table in this company.';
                }
                field("Last Error"; Rec."Last Error")
                {
                    ApplicationArea = All;
                    Caption = 'Last error';
                    Editable = false;
                    ToolTip = 'Specifies the error message from the last export of this table in this company.';
                }
                field("Updated Last Timestamp"; Rec."Updated Last Timestamp")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the timestamp of the record in this table that was exported last.';
                    Caption = 'Last timestamp';
                    Visible = false;
                }
                field("Last Timestamp Deleted"; Rec."Last Timestamp Deleted")
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
        ADLSETable: Record "ADLSE Table";
        NewSessionId: Integer;
    begin
        if ADLSETable.Get(Rec."Table ID") then
            if TableMetadata.Get(Rec."Table ID") then
                NumberFieldsChosenValue := ADLSETable.FieldsChosen()
            else
                NumberFieldsChosenValue := 0;
        Session.StartSession(NewSessionId, Codeunit::"ADLSE Company Run", Rec."Sync Company", Rec);
    end;

    var
        NumberFieldsChosenValue: Integer;
}
