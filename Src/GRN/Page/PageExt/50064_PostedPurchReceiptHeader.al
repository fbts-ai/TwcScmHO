pageextension 50064 PostedPurchaseReceiptExt extends "Posted Purchase Receipt"
{
    layout
    {
        // Add changes to page layout here
        addafter("Vendor Shipment No.")
        {
            field(VendorInvoiceNo; rec.VendorInvoiceNo)
            {
                Caption = 'Vendor Invoice No';
            }
            field(VendorInvoiceDate; Rec.VendorInvoiceDate)
            {
                Caption = 'Vendor Invoice Date';
            }

            field(ProformaInvoice; rec.ProformaInvoice)
            {
                Caption = 'Proforma Invoice Nubmer';
            }
            field(FreightCost; Rec.FreightCost)
            {
                Caption = 'Freight Cost Included';
            }
            field("Indent No."; Rec."Indent No.")
            {
                Editable = false;
                ApplicationArea = all;//PT-FBTS 230524    
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
            tempUserSetup: Record "User Setup";

        begin
            IF tempUserSetup.Get(UserId) Then;
            IF tempUserSetup."Location Code" <> '' then begin
                Rec.FilterGroup(10);
                Rec.SetRange(Rec."Location Code", TempUsersetup."Location Code");
                Rec.FilterGroup(0);
            end;

        end;
        */

    var
        myInt: Integer;

    trigger OnDeleteRecord(): Boolean; /// PT-FBTS 11-09-024 
    var
        myInt: Integer;
    begin
        Error('You can not delete this documnet');
    end;
}