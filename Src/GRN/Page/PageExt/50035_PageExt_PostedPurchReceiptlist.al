pageextension 50035 PostedpurchReceiptListext extends "Posted Purchase Receipts"
{
    layout
    {
        // addlast(content)
        // {
        //     field("Indent No."; Rec."Indent No.")
        //     {
        //         Editable = false;
        //         ApplicationArea = all;
        //     }

        // }
        addafter("No. Printed")///PT-FBTS-16-08-24
        {
            field("Indent No."; "Indent No.")
            {
                Editable = false;
            }
            field(VendorInvoiceNo; VendorInvoiceNo)
            {
                ApplicationArea = all;
            }
            field(SystemCreatedAt; SystemCreatedAt)
            {
                ApplicationArea = all;
            }
            field("Order No."; "Order No.")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
    trigger OnOpenPage()
    var
        tempUserSetup: Record "User Setup";

    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Location Code" <> '' then begin
            Rec.FilterGroup(10);
            Rec.SetRange(Rec."Location Code", TempUsersetup."Location Code");
            Rec.FilterGroup(0);
        end;

    end;

    var
        myInt: Integer;
}