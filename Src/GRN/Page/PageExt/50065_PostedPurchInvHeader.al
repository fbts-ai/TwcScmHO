pageextension 50065 PostedPurchInvext extends "Posted Purchase Invoice"
{
    layout
    {
        // Add changes to page layout here
        addafter("Vendor Invoice No.")
        {
            field(VendorInvoiceDate; Rec.VendorInvoiceDate)
            {
                Caption = 'Vendor Invoice Date';
            }
            // field("Order No"; Rec."Order No")
            // { ApplicationArea = all; }
            field(ProformaInvoice; rec.ProformaInvoice)
            {
                Caption = 'Proforma Invoice Nubmer';
            }
            field(FreightCost; Rec.FreightCost)
            {
                Caption = ' Freight Cost Included';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
    /*
        trigger OnOpenPage()
        var
            TempUserSetup: Record "User Setup";
        begin
            //mahendra
            IF TempUserSetup.Get(UserId) Then;
            IF TempUserSetup."Location Code" <> '' then Begin
                Rec.FilterGroup(2);
                Rec.setfilter(Rec."Location Code", '=%1', TempUserSetup."Location Code");
                Rec.FilterGroup(0);
            End;
            //end
        end;
        */

    var
        myInt: Integer;

    trigger OnDeleteRecord(): Boolean; /// PT-FBTS 11-09-24 
    var
        myInt: Integer;
    begin
        Error('You can not delete this documnet');
    end;
}