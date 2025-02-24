page 50006 "Sub-Indent PO List"
{
    PageType = List;
    ApplicationArea = All;

    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = Administration;
    SourceTable = "Sub Indent PO";

    layout
    {
        area(Content)
        {
            repeater(List)
            {
                field("Location Code"; rec."Location Code")
                {
                    ApplicationArea = All;

                }
                field("Store No."; rec."Store No.")
                {
                    ApplicationArea = all;
                }
                field("PO NO."; rec."PO NO.")
                {
                    ApplicationArea = all;
                }
                field("Vendor No."; rec."Vendor No.")
                {
                    ApplicationArea = all;
                }
                field("Vendor Name"; rec."Vendor Name")
                {
                    ApplicationArea = all;
                }
                field("Item No."; rec."Item No.")
                {
                    ApplicationArea = all;
                }
                field("Item Description"; rec."Item Description")
                {
                    ApplicationArea = all;
                }
                field(Quantity; rec.Quantity)
                {
                    ApplicationArea = all;
                }
                field(Remarks; rec.Remarks)
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("PO List Report")
            {
                ApplicationArea = All;
                RunObject = report "Sub-Indent PO List";
                RunPageOnRec = true;

                trigger OnAction()
                begin

                end;
            }
            action("Mail PO")
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    CU50002: Report "Create Consolidation Orders";

                begin
                    //  CU50002.SendMail(Rec);
                end;
            }
        }
    }

    var
        myInt: Integer;
}