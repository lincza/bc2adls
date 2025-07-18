// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License. See LICENSE in the project root for license information.
page 82561 "ADLSE Setup Tables"
{
    Caption = 'Tables';
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "ADLSE Table";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                ShowCaption = false;

                field("TableCaption"; TableCaptionValue)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Table';
                    ToolTip = 'Specifies the caption of the table whose data is to exported.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    Editable = true;
                    Caption = 'Enabled';
                }
                field(FieldsChosen; NumberFieldsChosenValue)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = '# Fields selected';
                    ToolTip = 'Specifies if any field has been chosen to be exported. Click on Choose Fields action to add fields to export.';

                    trigger OnDrillDown()
                    begin
                        DoChooseFields();
                    end;
                }
                field(ADLSTableName; ADLSEntityName)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Entity name';
                    ToolTip = 'Specifies the name of the entity corresponding to this table on the data lake. The value at the end indicates the table number in Dynamics 365 Business Central.';
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
                field(ExportCategory; Rec.ExportCategory)
                {
                    Caption = 'Export Category';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AddTable)
            {
                ApplicationArea = All;
                Caption = 'Add';
                ToolTip = 'Add a table to be exported.';
                Image = New;
                Enabled = NoExportInProgress;

                trigger OnAction()
                var
                    ADLSESetup: Codeunit "ADLSE Setup";
                begin
                    ADLSESetup.AddTableToExport();
                    CurrPage.Update();
                end;
            }

            action(DeleteTable)
            {
                ApplicationArea = All;
                Caption = 'Delete';
                ToolTip = 'Removes a table that had been added to the list meant for export.';
                Image = Delete;
                Enabled = NoExportInProgress;

                trigger OnAction()
                begin
                    Rec.Delete(true);
                    CurrPage.Update();
                end;
            }

            action(ChooseFields)
            {
                ApplicationArea = All;
                Caption = 'Choose fields';
                ToolTip = 'Select the fields of this table to be exported.';
                Image = SelectEntries;
                Enabled = NoExportInProgress;

                trigger OnAction()
                begin
                    DoChooseFields();
                end;
            }

            action("Reset")
            {
                ApplicationArea = All;
                Caption = 'Reset';
                ToolTip = 'Set the selected tables to export all of its data again.';
                Image = ResetStatus;
                Enabled = NoExportInProgress;

                trigger OnAction()
                var
                    SelectedADLSETable: Record "ADLSE Table";
                    ADLSESetup: Record "ADLSE Setup";
                    Options: Text[50];
                    OptionStringLbl: Label 'Current Company,All Companies';
                    ResetTablesForAllCompaniesQst: Label 'Do you want to reset the selected tables for all companies?';
                    ResetTablesQst: Label 'Do you want to reset the selected tables for the current company or all companies?';
                    ChosenOption: Integer;
                begin
                    Options := OptionStringLbl;
                    ADLSESetup.GetSingleton();
                    if ADLSESetup."Storage Type" = ADLSESetup."Storage Type"::"Open Mirroring" then begin
                        if Confirm(ResetTablesForAllCompaniesQst, true) then
                            ChosenOption := 2
                        else
                            exit;
                    end else
                        ChosenOption := Dialog.StrMenu(Options, 1, ResetTablesQst);
                    CurrPage.SetSelectionFilter(SelectedADLSETable);
                    case ChosenOption of
                        0:
                            exit;
                        1:
                            SelectedADLSETable.ResetSelected(false);
                        2:
                            SelectedADLSETable.ResetSelected(true);
                        else
                            Error('Chosen option is not valid');
                    end;
                    CurrPage.Update();
                end;
            }

            action(Logs)
            {
                ApplicationArea = All;
                Caption = 'Execution logs';
                ToolTip = 'View the execution logs for this table in the currently opened company.';
                Image = Log;

                trigger OnAction()
                var
                    ADLSERun: Page "ADLSE Run";
                begin
                    ADLSERun.SetDisplayForTable(Rec."Table ID");
                    ADLSERun.Run();
                end;

            }
            action(ImportBC2ADLS)
            {
                ApplicationArea = All;
                Caption = 'Import';
                Image = Import;
                ToolTip = 'Import a file with BC2ADLS tables and fields.';

                trigger OnAction()
                var
                    ADLSETable: Record "ADLSE Table";
                begin
                    XmlPort.Run(XmlPort::"BC2ADLS Import", false, true, ADLSETable);
                    CurrPage.Update(false);
                end;
            }
            action(ExportBC2ADLS)
            {
                ApplicationArea = All;
                Caption = 'Export';
                Image = Export;
                ToolTip = 'Exports a file with BC2ADLS tables and fields.';

                trigger OnAction()
                var
                    ADLSETable: Record "ADLSE Table";
                begin
                    ADLSETable.Reset();
                    XmlPort.Run(XmlPort::"BC2ADLS Export", false, false, ADLSETable);
                    CurrPage.Update(false);
                end;
            }
            action(AssignExportCategory)
            {
                ApplicationArea = All;
                Caption = 'Assign Export Category';
                Image = Apply;
                ToolTip = 'Assign an Export Category to the Table.';

                trigger OnAction()
                var
                    ADLSETable: Record "ADLSE Table";
                    AssignExportCategory: Page "ADLSE Assign Export Category";
                begin
                    CurrPage.SetSelectionFilter(ADLSETable);
                    AssignExportCategory.LookupMode(true);
                    if AssignExportCategory.RunModal() = Action::LookupOK then
                        ADLSETable.ModifyAll(ExportCategory, AssignExportCategory.GetExportCategoryCode());
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnInit()
    var
        ADLSECurrentSession: Record "ADLSE Current Session";
    begin
        NoExportInProgress := not ADLSECurrentSession.AreAnySessionsActive();
    end;

    trigger OnAfterGetRecord()
    var
        TableMetadata: Record "Table Metadata";
        ADLSETableLastTimestamp: Record "ADLSE Table Last Timestamp";
        ADLSERun: Record "ADLSE Run";
        ADLSEUtil: Codeunit "ADLSE Util";
    begin
        if TableMetadata.Get(Rec."Table ID") then begin
            TableCaptionValue := ADLSEUtil.GetTableCaption(Rec."Table ID");
            NumberFieldsChosenValue := Rec.FieldsChosen();
            UpdatedLastTimestamp := ADLSETableLastTimestamp.GetUpdatedLastTimestamp(Rec."Table ID");
            DeletedRecordLastEntryNo := ADLSETableLastTimestamp.GetDeletedLastEntryNo(Rec."Table ID");
            ADLSEntityName := ADLSEUtil.GetDataLakeCompliantTableName(Rec."Table ID");
        end else begin
            TableCaptionValue := StrSubstNo(AbsentTableCaptionLbl, Rec."Table ID");
            NumberFieldsChosenValue := 0;
            UpdatedLastTimestamp := 0;
            DeletedRecordLastEntryNo := 0;
            ADLSEntityName := '';
            Rec.Modify(true);
        end;
        ADLSERun.GetLastRunDetails(Rec."Table ID", LastRunState, LastStarted, LastRunError);

        IssueNotificationIfInvalidFieldsConfiguredToBeExported();
    end;

    var
        TableCaptionValue: Text;
        NumberFieldsChosenValue: Integer;
        ADLSEntityName: Text;
        UpdatedLastTimestamp: BigInteger;
        DeletedRecordLastEntryNo: BigInteger;
        AbsentTableCaptionLbl: Label 'Table%1', Comment = '%1 = Table ID';
        LastRunState: Enum "ADLSE Run State";
        LastStarted: DateTime;
        LastRunError: Text[2048];
        NoExportInProgress: Boolean;
        InvalidFieldConfiguredMsg: Label 'The following fields have been incorrectly enabled for exports in the table %1: %2', Comment = '%1 = table name; %2 = List of invalid field names';
        WarnOfSchemaChangeQst: Label 'Data may have been exported from this table before. Changing the export schema now may cause unexpected side- effects. You may reset the table first so all the data shall be exported afresh. Do you still wish to continue?';

    local procedure DoChooseFields()
    var
        ADLSETableLastTimestamp: Record "ADLSE Table Last Timestamp";
        ADLSESetup: Codeunit "ADLSE Setup";
    begin
        if ADLSETableLastTimestamp.ExistsUpdatedLastTimestamp(Rec."Table ID") then
            if not Confirm(WarnOfSchemaChangeQst, false) then
                exit;
        ADLSESetup.ChooseFieldsToExport(Rec);
        CurrPage.Update();
    end;

    local procedure IssueNotificationIfInvalidFieldsConfiguredToBeExported()
    var
        ADLSEUtil: Codeunit "ADLSE Util";
        InvalidFieldNotification: Notification;
        InvalidFieldList: List of [Text];
    begin
        InvalidFieldList := Rec.ListInvalidFieldsBeingExported();
        if InvalidFieldList.Count() = 0 then
            exit;
        InvalidFieldNotification.Message := StrSubstNo(InvalidFieldConfiguredMsg, TableCaptionValue, ADLSEUtil.Concatenate(InvalidFieldList));
        InvalidFieldNotification.Scope := NotificationScope::LocalScope;
        InvalidFieldNotification.Send();
    end;
}
