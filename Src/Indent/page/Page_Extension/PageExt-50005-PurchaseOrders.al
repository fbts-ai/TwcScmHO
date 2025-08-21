pageextension 50005 PurchaseOrders extends "Purchase Order List"
{
    layout
    {
        //ALLENick
        // modify("Location Code")
        // {
        //     Visible = false;
        // }
        // Add changes to page layout here
        addafter("Document Date")
        {
            field(CreatedBy; CreatedBy)
            {
                ApplicationArea = all;
                Caption = 'Created By';
            }
        }

        addafter("Amount Including VAT")
        {
            field("Indent No."; rec."Indent No.")
            {
                ApplicationArea = all;
                Caption = 'Indent No.';
                Visible = false;
            }
        }

        addafter("Vendor Authorization No.")
        {
            field("Creation Location"; "Creation Location")
            {
                ApplicationArea = all;
            }
        }

    }
    actions
    {
        // Add changes to page actions here
        //ALLENick091023_start
        modify(PostBatch)
        {
            Visible = false;
        }
        //ALLENick091023_End
    }
    trigger OnOpenPage()
    var
        TempUserSetup: Record "User Setup";
    begin
        IF TempUserSetup.Get(UserId) Then;
        Rec.FilterGroup(2);
        Rec.SetRange(Rec.ShortClosed, false);
        IF TempUserSetup."Location Code" <> '' then
            //ALLENick
            // Rec.SetRange("Creation Location", TempUserSetup."Location Code");
            Rec.SetRange("Location Code", TempUserSetup."Location Code");
        Rec.FilterGroup(0);
    end;


    var
        myInt: Integer;
        Seteditable: Boolean;
        CreatedBy: Text[100];


    trigger OnAfterGetCurrRecord() ///PT-FBTS
    var
        user: Record user;
    begin
        user.Reset();
        user.SetRange("User Security ID", Rec.SystemCreatedBy);
        if user.FindFirst() then
            CreatedBy := user."User Name";
        ///PT-FBTS
    end;

    trigger OnAfterGetRecord() ///PT-FBTS
    var
        user: Record user;
    begin
        user.Reset();
        user.SetRange("User Security ID", Rec.SystemCreatedBy);
        if user.FindFirst() then
            CreatedBy := user."User Name";
        ///PT-FBTS
    end;
}