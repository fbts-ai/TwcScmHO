page 50120 "Quarantine Transfer List"
{
    PageType = List;
    caption = 'Quarantine Transfer List';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Transfer Header";
    CardPageId = "Quarantine Card";
    InsertAllowed = false;
    DeleteAllowed = false;
    //ShowFilter = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Transfer-from Code"; Rec."Transfer-from Code")
                {
                    ApplicationArea = All;
                }
                field("Transfer-to Code"; Rec."Transfer-to Code")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; rec."Posting Date")
                {
                    ApplicationArea = all;
                }
                field("Direct Transfer"; Rec."Direct Transfer")
                {
                    ApplicationArea = All;
                }
                field("Quaratine Location"; rec."Quaratine Location")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    // actions
    // {
    //     area(Processing)
    //     {
    //         action(ActionName)
    //         {
    //             ApplicationArea = All;

    //             trigger OnAction();
    //             begin

    //             end;
    //         }
    //     }
    // }




    trigger OnOpenPage()
    var
        UserSetupRec: Record "User Setup";
    begin
        UserSetupRec.Get(UserId);
        rec.SetRange(Hide, false);
        Rec.FilterGroup(2);
        Rec.SetRange(Rec."Transfer-from Code", UserSetupRec."Location Code");
        Rec.SetRange(Rec."Quaratine Location", true);
        Rec.FilterGroup(0);
    end;
}