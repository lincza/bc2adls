page 82566 "ADLSE Company Setup"
{
    Caption = 'Export Companies to Azure Data Lake Storage';
    ApplicationArea = all;
    UsageCategory = Lists;
    LinksAllowed = false;
    PageType = List;
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
                field("Table ID"; Rec."Table ID")
                {
                }

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
                field(ADLSTableName; ADLSEntityName)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Entity name';
                    ToolTip = 'Specifies the name of the entity corresponding to this table on the data lake. The value at the end indicates the table number in Dynamics 365 Business Central.';
                }
                field(ExportCategory; Rec.ExportCategory)
                {
                    Caption = 'Export Category';
                    ApplicationArea = All;
                }
            }
            part("Company Tables"; "ADLSE Company Setup Tables")
            {
                UpdatePropagation = Both;
                SubPageLink = "Table ID" = field("Table ID");
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
            action("Reset")
            {
                ApplicationArea = All;
                Caption = 'Reset';
                ToolTip = 'Set the selected tables to export all of its data again.';
                Image = ResetStatus;
                Enabled = NoExportInProgress;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;

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
        ADLSEUtil: Codeunit "ADLSE Util";
    begin
        if TableMetadata.Get(Rec."Table ID") then begin
            TableCaptionValue := ADLSEUtil.GetTableCaption(Rec."Table ID");
            ADLSEntityName := ADLSEUtil.GetDataLakeCompliantTableName(Rec."Table ID");
        end else begin
            TableCaptionValue := StrSubstNo(AbsentTableCaptionLbl, Rec."Table ID");
            ADLSEntityName := '';
            Rec.Modify(true);
        end;

        IssueNotificationIfInvalidFieldsConfiguredToBeExported();
    end;

    var
        TableCaptionValue: Text;
        ADLSEntityName: Text;
        AbsentTableCaptionLbl: Label 'Table%1', Comment = '%1 = Table ID';
        NoExportInProgress: Boolean;
        InvalidFieldConfiguredMsg: Label 'The following fields have been incorrectly enabled for exports in the table %1: %2', Comment = '%1 = table name; %2 = List of invalid field names';

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
