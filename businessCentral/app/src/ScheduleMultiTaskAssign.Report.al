report 82562 "ADLSEScheduleMultiTaskAssign"
{
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    Caption = 'Schedule Multi Company Export';
    ProcessingOnly = true;


    dataset
    {
        dataitem(ADLSETable; "ADLSE Table")
        {
            RequestFilterFields = ExportCategory;
            trigger OnPreDataItem()
            var
                JobQueueEntry: Record "Job Queue Entry";
                ADLSEMultiCompanyExport: Codeunit "ADLSE Multi Company Export";
            begin
                if CompanyNameFilter <> '' then
                    ADLSEMultiCompanyExport.SetCompanyFilter(CompanyNameFilter);
                if TableIdFilter <> '' then
                    ADLSEMultiCompanyExport.SetTableFilter(TableIdFilter);
                ADLSEMultiCompanyExport.Run(JobQueueEntry);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(Filters)
                {
                    Caption = 'Filters';
                    field(CompanyNameFilter; CompanyNameFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'CompanyName Filter';
                        ToolTip = 'filter Companies to be exported. Separate multiple entries with | character. Leave empty to include all companies.';

                        trigger OnAssistEdit()
                        var
                            ADLSESyncCompanies: Record "ADLSE Sync Companies";
                            ADLSECompanySetup: Page "ADLSE Company Setup";
                        begin
                            ADLSECompanySetup.LookupMode(true);
                            if ADLSECompanySetup.RunModal() = Action::LookupOK then begin
                                ADLSECompanySetup.SetSelectionFilter(ADLSESyncCompanies);
                                if ADLSESyncCompanies.FindSet() then
                                    repeat
                                        if CompanyNameFilter = '' then
                                            CompanyNameFilter := ADLSESyncCompanies."Sync Company"
                                        else
                                            CompanyNameFilter := CompanyNameFilter + '|' + ADLSESyncCompanies."Sync Company";
                                    until ADLSESyncCompanies.Next() < 1;
                            end;
                        end;


                    }
                    field(TableIdFilter; TableIdFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Table Id Filter';
                        ToolTip = 'Filter Table IDs to be exported. Separate multiple entries with | character. Leave empty to include all tables.';
                        trigger OnAssistEdit()
                        var
                            ADLSETable: Record "ADLSE Table";
                            ADLSESetupTables: Page "ADLSE Setup Tables";
                        begin
                            ADLSESetupTables.LookupMode(true);
                            if ADLSESetupTables.RunModal() = Action::LookupOK then begin
                                ADLSESetupTables.SetSelectionFilter(ADLSETable);
                                if ADLSETable.FindSet() then
                                    repeat
                                        if TableIdFilter = '' then
                                            TableIdFilter := Format(ADLSETable."Table ID")
                                        else
                                            TableIdFilter := TableIdFilter + '|' + Format(ADLSETable."Table ID");
                                    until ADLSETable.Next() < 1;
                            end;
                        end;
                    }

                }
                group(Options)
                {
                    Caption = 'Options';
                    field(JobQueueDescription; Description)
                    {
                        ApplicationArea = All;
                        Caption = 'Description';
                        ToolTip = 'Specifies the description that is displayed in the job queue.';
                    }
                    field(EarliestStartDateTimeControl; EarliestStartDateTime)
                    {
                        ApplicationArea = All;
                        Caption = 'Earliest Start Date / Time ';
                        ToolTip = 'Specifies the date and time when the job queue must be executed for the first time.';
                    }
                    field(NoofMinutesBetweeenRuns; NoofMinutesBetweenRuns)
                    {
                        ApplicationArea = All;
                        Caption = 'No of minutes between runs';
                        ToolTip = 'Specifies the minimum number of minutes that are to elapse between runs of a job queue entry. The value cannot be less than one minute.';
                    }
                }

                group(Recurrence)
                {
                    grid(Daysgrid)
                    {
                        Caption = 'Recurrence';
                        group(Recurrence1)
                        {
                            ShowCaption = false;
                            field(RunOnMondaysControl; RunOnMondays)
                            {
                                ApplicationArea = All;
                                Caption = 'Run On Mondays';
                                ToolTip = 'Specifies that the job queue entry runs on Mondays.';
                            }
                            field(RunOnTeusdaysControl; RunOnTeusdays)
                            {
                                ApplicationArea = All;
                                Caption = 'Run On Tuesdays';
                                ToolTip = 'Specifies that the job queue entry runs on Teusdays.';
                            }
                            field(RunOnWednesdayControl; RunOnWednesdays)
                            {
                                ApplicationArea = All;
                                Caption = 'Run On Wednesdays';
                                ToolTip = 'Specifies that the job queue entry runs on Wednesdays.';
                            }
                            field(RunOnThursdayControl; RunOnThursdays)
                            {
                                ApplicationArea = All;
                                Caption = 'Run On Thursdays';
                                ToolTip = 'Specifies that the job queue entry runs on Thursdays.';
                            }
                        }
                        group(Recurrence2)
                        {
                            ShowCaption = false;
                            field(RunOnFridayControl; RunOnFridays)
                            {
                                ApplicationArea = All;
                                Caption = 'Run On Fridays';
                                ToolTip = 'Specifies that the job queue entry runs on Fridays.';
                            }
                            field(RunOnSaturdayControl; RunOnSaturdays)
                            {
                                ApplicationArea = All;
                                Caption = 'Run On Saturdays';
                                ToolTip = 'Specifies that the job queue entry runs on Saturdays.';
                            }
                            field(RunOnSundaysControl; RunOnSundays)
                            {
                                ApplicationArea = All;
                                Caption = 'Run On Sundays';
                                ToolTip = 'Specifies that the job queue entry runs on Sundays.';
                            }
                        }
                    }
                }
            }
        }
    }

    var
        CompanyNameFilter: Text;
        TableIdFilter: Text;
        Description: Text[30];
        JobCategoryCodeTxt: Label 'ADLSE', Locked = true;
        EarliestStartDateTime: DateTime;
        NoofMinutesBetweenRuns: Integer;
        RunOnSundays: Boolean;
        RunOnMondays: Boolean;
        RunOnTeusdays: Boolean;
        RunOnWednesdays: Boolean;
        RunOnThursdays: Boolean;
        RunOnFridays: Boolean;
        RunOnSaturdays: Boolean;

    procedure CreateJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry")
    var
        JobQueueCategory: Record "Job Queue Category";
    begin
        Clear(JobQueueEntry);
        JobQueueCategory.InsertRec(JobCategoryCodeTxt, Description);
        JobQueueEntry.Init();
        JobQueueEntry.Validate("Object Type to Run", JobQueueEntry."Object Type to Run"::Report);
        JobQueueEntry.Validate("Object ID to Run", Report::ADLSEScheduleMultiTaskAssign);
        JobQueueEntry.Insert(true);

        JobQueueEntry.Description := Description;
        JobQueueEntry."No. of Minutes between Runs" := NoofMinutesBetweenRuns;
        JobQueueEntry.Validate("Run on Mondays", RunOnMondays);
        JobQueueEntry.Validate("Run on Tuesdays", RunOnTeusdays);
        JobQueueEntry.Validate("Run on Wednesdays", RunOnWednesdays);
        JobQueueEntry.Validate("Run on Thursdays", RunOnThursdays);
        JobQueueEntry.Validate("Run on Fridays", RunOnFridays);
        JobQueueEntry.Validate("Run on Saturdays", RunOnSaturdays);
        JobQueueEntry.Validate("Run on Sundays", RunOnSundays);

        JobQueueEntry.Validate("Earliest Start Date/Time", EarliestStartDateTime);
        JobQueueEntry."Report Output Type" := JobQueueEntry."Report Output Type"::"None (Processing only)";
        JobQueueEntry.Modify(true);
    end;
}

