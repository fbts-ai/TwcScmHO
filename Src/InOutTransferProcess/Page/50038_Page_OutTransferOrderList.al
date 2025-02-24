
Page 50038 "OutTransferOrderList"
{
    PageType = List;
    ApplicationArea = All;
    Caption = 'Out Transfer Order List ';
    UsageCategory = Lists;
    SourceTable = "Transfer Header";

    CardPageID = "Out Transfer Order";
    Editable = false;
    DeleteAllowed = false;
    ShowFilter = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater("Transfer - Out")
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Transfer-from Code"; Rec."Transfer-from Code")
                {
                    ApplicationArea = All;
                }
                field("Transfer-from Name"; Rec."Transfer-from Name")
                {
                    ApplicationArea = All;
                }
                field("Transfer-to Code"; Rec."Transfer-to Code")
                {
                    ApplicationArea = All;
                }
                field("Transfer-to Name"; Rec."Transfer-to Name")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Direct Transfer"; Rec."Direct Transfer")
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
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        UserSetupRec: Record "User Setup";
        LocationVal: Text;
    begin
        UserSetupRec.Get(UserId);
        LocationVal := Format(UserSetupRec."Location Code");
        //AJ_ALLE_04122023
        Rec.SetRange(Hide, false);
        //AJ_ALLE_04122023
        Rec.FilterGroup(2);
        Rec.SetRange(Rec."Transfer-from Code", UserSetupRec."Location Code");
        Rec.SetRange(Rec."Completely Shipped", false); //Mahendra added on 14 Aug 
        rec.SetRange("PARTIAL Shipped",false); //ALLE_NICK_220224
        // Rec.SetRange(Rec.Status, Rec.Status::Released);
        Rec.FilterGroup(0);
    end;
}
