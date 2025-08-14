page 82565 "ADLSE Company Setup Tables"
{
    Caption = 'Company Tables';
    LinksAllowed = false;
    PageType = ListPlus;
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
            action(ExportNow)
            {
                ApplicationArea = All;
                Caption = 'Export All Companies';
                ToolTip = 'Starts the export process by spawning different sessions for each table. The action is disabled in case there are export processes currently running, also in other companies.';
                Image = Start;
                Enabled = not ExportInProgress;

                trigger OnAction()
                var
                    // ADLSEExecution: Codeunit "ADLSE Execution";
                    ADLSECurrentSession: Record "ADLSE Current Session";
                    NewSessionID: Integer;
                // ExportInProgress: Boolean;
                begin
                    // ExportInProgress := ADLSECurrentSession.AreAnySessionsActive();
                    if not ADLSECurrentSession.AreAnySessionsActive() then
                        if Rec.FindSet() then
                            repeat
                                Session.StartSession(NewSessionID, Codeunit::"ADLSE Execution", Rec."Sync Company");
                            until Rec.Next() < 1;
                    // ADLSEExecution.StartExport();
                    CurrPage.Update();
                end;
            }

            action(StopExport)
            {
                ApplicationArea = All;
                Caption = 'Stop export';
                ToolTip = 'Tries to stop all sessions that are exporting data, including those that are running in other companies.';
                Image = Stop;

                trigger OnAction()
                var
                    ADLSEExecution: Codeunit "ADLSE Execution";
                begin
                    ADLSEExecution.StopExport();
                    CurrPage.Update();
                end;
            }
            action(SchemaExport)
            {
                ApplicationArea = All;
                Caption = 'Schema export';
                ToolTip = 'This will export the schema of the tables selected in the setup to the lake. This is a one-time operation and should be done before the first export of data.';
                Image = Start;

                trigger OnAction()
                var
                    ADLSEExecution: Codeunit "ADLSE Execution";
                begin
                    ADLSEExecution.SchemaExport();
                    CurrPage.Update();
                end;
            }
            action(ClearSchemaExported)
            {
                ApplicationArea = All;
                Caption = 'Clear schema export date';
                ToolTip = 'This will clear the schema exported on field. If this is cleared you can change the schema and export it again.';
                Image = ClearLog;

                trigger OnAction()
                var
                    ADLSEExecution: Codeunit "ADLSE Execution";
                begin
                    ADLSEExecution.ClearSchemaExportedOn();
                    CurrPage.Update();
                end;
            }

            action(Schedule)
            {
                ApplicationArea = All;
                Caption = 'Schedule export';
                ToolTip = 'Schedules the export process as a job queue entry.';
                Image = Timesheet;

                trigger OnAction()
                var
                    ADLSEExecution: Codeunit "ADLSE Execution";
                begin
                    ADLSEExecution.ScheduleExport();
                end;
            }

            action(ClearDeletedRecordsList)
            {
                ApplicationArea = All;
                Caption = 'Clear tracked deleted records';
                ToolTip = 'Removes the entries in the deleted record list that have already been exported. The codeunit ADLSE Clear Tracked Deletions may be invoked using a job queue entry for the same end.';
                Image = ClearLog;
                Enabled = TrackedDeletedRecordsExist;

                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"ADLSE Clear Tracked Deletions");
                    CurrPage.Update();
                end;
            }

            action(DeleteOldRuns)
            {
                ApplicationArea = All;
                Caption = 'Clear execution log';
                ToolTip = 'Removes the history of the export executions. This should be done periodically to free up storage space.';
                Image = History;
                Enabled = OldLogsExist;

                trigger OnAction()
                var
                    ADLSERun: Record "ADLSE Run";
                begin
                    ADLSERun.DeleteOldRuns();
                    CurrPage.Update();
                end;
            }

            action(FixIncorrectData)
            {
                ApplicationArea = All;
                Caption = 'Fix incorrect data';
                ToolTip = 'Fixes incorrect tables and fields in the setup. This should be done if you have deleted some tables and fields and you cannot disable them.';
                Image = Error;

                trigger OnAction()
                var
                    ADLSESetup: Codeunit "ADLSE Setup";
                begin
                    ADLSESetup.FixIncorrectData();
                end;
            }
        }
        area(Navigation)
        {
            action(EnumTranslations)
            {
                ApplicationArea = All;
                Caption = 'Enum translations';
                ToolTip = 'Show the translations for the enums used in the selected tables.';
                Image = Translations;
                RunObject = page "ADLSE Enum Translations";
            }
            action(DeletedTablesNotToSync)
            {
                ApplicationArea = All;
                Caption = 'Deleted tables not to sync';
                ToolTip = 'Shows all the tables that are specified not to be tracked for deletes.';
                Image = Delete;
                RunObject = page "Deleted Tables Not To Sync";
            }
            action("Job Queue")
            {
                Caption = 'Job Queue';
                ApplicationArea = All;
                ToolTip = 'Specifies the scheduled Job Queues for the export to Datalake.';
                Image = BulletList;
                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                begin
                    JobQueueEntry.SetFilter("Object ID to Run", '%1|%2', Codeunit::"ADLSE Execution", Report::"ADLSE Schedule Task Assignment");
                    Page.Run(Page::"Job Queue Entries", JobQueueEntry);
                end;
            }
            action("Export Category")
            {
                Caption = 'Export Category';
                ApplicationArea = All;
                ToolTip = 'Specifies the Export Categories available for scheduling the export to Datalake.';
                Image = Export;
                RunObject = page "ADLSE Export Categories";
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                group(Export)
                {
                    ShowAs = SplitButton;
                    actionref(ExportNow_Promoted; ExportNow) { }
                    actionref(StopExport_Promoted; StopExport) { }
                    actionref(SchemaExport_Promoted; SchemaExport) { }
                    actionref(Schedule_Promoted; Schedule) { }
                    actionref(ClearSchemaExported_Promoted; ClearSchemaExported) { }
                }
                actionref(ClearDeletedRecordsList_Promoted; ClearDeletedRecordsList) { }
                actionref(DeleteOldRuns_Promoted; DeleteOldRuns) { }
            }
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
