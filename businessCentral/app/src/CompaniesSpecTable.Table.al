#pragma warning disable LC0015
table 82574 "ADLSE Companies Spec Table"
#pragma warning restore
{
    Access = Internal;
    Caption = 'ADLSE Company-Specific Table';
    DataPerCompany = false;
    DataClassification = CustomerContent;
    Permissions = tabledata "ADLSE Field" = rd,
                  tabledata "ADLSE Table Last Timestamp" = d,
                  tabledata "ADLSE Deleted Record" = d;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            TableRelation = "ADLSE Table"."Table ID";
            AllowInCustomizations = Always;
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
            Editable = false;
            Caption = 'Sync Company';
            TableRelation = Company.Name where("Evaluation Company" = const(false));
        }
    }

    keys
    {
        key(PK; "Table ID", "Sync Company")
        {
            Clustered = true;
        }
    }

    procedure GetTableIdFilter(Company: Text) TableIdFilter: Text
    var
        ADLSECompaniesSpecTable: Record "ADLSE Companies Spec Table";
    begin
        ADLSECompaniesSpecTable.SetFilter("Sync Company", Company);
        if ADLSECompaniesSpecTable.FindSet(false) then begin
            TableIdFilter := '';
            repeat
                if TableIdFilter <> '' then
                    TableIdFilter += '|';
                TableIdFilter += Format(ADLSECompaniesSpecTable."Table ID");
            until ADLSECompaniesSpecTable.Next() = 0;
            exit(TableIdFilter);
        end;
    end;






}