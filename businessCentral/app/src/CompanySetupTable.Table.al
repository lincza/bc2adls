// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License. See LICENSE in the project root for license information.
#pragma warning disable LC0015
table 82572 "ADLSE Company Setup Table"
#pragma warning restore
{
    Access = Internal;
    Caption = 'ADLSE Company Setup Table';
    DataClassification = CustomerContent;
    DataPerCompany = false;
    Permissions = tabledata "ADLSE Field" = rd,
                  tabledata "ADLSE Table Last Timestamp" = d,
                  tabledata "ADLSE Deleted Record" = d;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            AllowInCustomizations = Always;
            Editable = false;
            Caption = 'Table ID';
        }
        field(20; "Table Caption"; Text[249])
        {
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(table), "Object ID" = field("Table ID")));
        }
        field(25; "Sync Company"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Sync Company';
            TableRelation = Company.Name where("Evaluation Company" = const(false));
        }
        field(40; "Updated Last Timestamp"; BigInteger)
        {
            Caption = 'Last timestamp';
        }
        field(45; "Last Timestamp Deleted"; BigInteger)
        {
            Caption = 'Last timestamp deleted';
        }
        field(50; "Last Run State"; Enum "ADLSE Run State")
        {
            Caption = 'Last exported state';
        }
        field(55; "Last Started"; DateTime)
        {
            Caption = 'Last started at';
        }
        field(60; "Last Error"; Text[2048])
        {
            Caption = 'Last error';
        }

    }

    keys
    {
        key(PK; "Table ID", "Sync Company")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
    begin
        UpsertAllTableIds(0);
    end;

    trigger OnDelete()
    var
    begin
        UpsertAllTableIds(2);
    end;

    trigger OnModify()
    var
    begin
        UpsertAllTableIds(1);
    end;

    procedure GetNoOfDatabaseRecordsText(): Text
    var
        RecRef: RecordRef;
    begin

        if Rec."Table ID" = 0 then
            exit;

        RecRef.Open(Rec."Table ID", false, Rec."Sync Company");
        exit(Format(RecRef.Count()));
    end;

    local procedure UpsertAllTableIds(Rowmarker: Integer)
    var
        ADLSETable: Record "ADLSE Table";
        ADLSECompanySetupTable: Record "ADLSE Company Setup Table";
        RenameADLSECompanySetupTable: Record "ADLSE Company Setup Table";
        SyncCompany: Text[30];
        xSyncCompany: Text[30];
    begin
        // Rowmarker semantics used here:
        // 0 = Insert -> add missing rows for this Sync Company across ALL table IDs (do not update existing rows)
        // 1 = Modify -> update existing rows for this Sync Company across ALL table IDs (do not insert missing rows)
        // 2 = Delete -> remove ALL rows for this Sync Company across ALL table IDs (except current row already being deleted)

        SyncCompany := Rec."Sync Company";
        xSyncCompany := xRec."Sync Company";
        if SyncCompany = '' then
            exit;

        case Rowmarker of
            2: // Delete: remove this company entry for all other tables (current one is already being deleted)
                begin
                    ADLSECompanySetupTable.Reset();
                    ADLSECompanySetupTable.SetRange("Sync Company", SyncCompany);
                    ADLSECompanySetupTable.SetFilter("Table ID", '<>%1', Rec."Table ID");
                    // Avoid re-entrancy by suppressing triggers
                    ADLSECompanySetupTable.DeleteAll(false);
                end;

            0: // Insert: add missing rows only
                begin
                    ADLSETable.SetFilter("Table ID", '<>%1', Rec."Table ID");
                    if ADLSETable.FindSet() then
                        repeat
                            ADLSECompanySetupTable.Init();
                            ADLSECompanySetupTable."Table ID" := ADLSETable."Table ID";
                            ADLSECompanySetupTable."Sync Company" := SyncCompany;
                            ADLSECompanySetupTable.Insert(false);
                        until ADLSETable.Next() = 0;
                end;
            1: // Modify: update existing rows only
                begin

                    if xSyncCompany = SyncCompany then
                        exit;

                    ADLSECompanySetupTable.SetFilter("Table ID", '<>%1', Rec."Table ID");
                    ADLSECompanySetupTable.SetRange("Sync Company", xSyncCompany);
                    if ADLSECompanySetupTable.FindSet() then
                        repeat
                            if RenameADLSECompanySetupTable.Get(ADLSECompanySetupTable."Table ID", ADLSECompanySetupTable."Sync Company") then
                                RenameADLSECompanySetupTable.Rename(ADLSECompanySetupTable."Table ID", SyncCompany);
                        until ADLSECompanySetupTable.Next() < 1;
                end;
        end;
    end;
}