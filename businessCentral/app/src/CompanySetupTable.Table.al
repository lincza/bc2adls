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
        field(10; ExportCategory; Code[50])
        {
            TableRelation = "ADLSE Export Category Table";
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the Export Category which can be linked to tables which are part of the export to Azure Datalake. The Category can be used to schedule the export.';
        }
        field(15; ExportFileNumber; Integer)
        {
            Caption = 'Export File Number';
            AllowInCustomizations = Always;
        }
    }

    keys
    {
        key(Key1; "Table ID")
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

}