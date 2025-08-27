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
        field(30; "Last Sync"; DateTime)
        {
            Editable = false;
        }
        field(15; ExportFileNumber; Integer)
        {
            Caption = 'Export File Number';
            AllowInCustomizations = Always;
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

    end;

    trigger OnDelete()
    var
    begin
    end;

    trigger OnModify()
    var
    begin
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
}