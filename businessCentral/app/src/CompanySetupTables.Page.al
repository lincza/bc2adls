// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License. See LICENSE in the project root for license information.
page 82565 "ADLSE Company Setup Tables"
{
    Caption = 'Company Tables';
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "ADLSE Company Setup Table";
    InsertAllowed = false;
    DeleteAllowed = false;
    

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


            }
        }
    }

    actions
    {
        area(Processing)
        {

        }
    }
}
