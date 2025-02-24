pageextension 50034 PurchaseReturnExt extends "Purchase Return Order"
{
    layout
    {
        // Add changes to page layout here
        modify("Buy-from Vendor No.")
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                tempvendor: Record "Vendor";
                tempusersetup: Record "User Setup";
                cashVendortext: Text[50];
                tempLocation: Record "Location";
            begin
                if tempusersetup.Get(UserId) then;
                tempLocation.Get(tempusersetup."Location Code");
                cashVendortext := tempLocation.PurchaseReturnVendor;
                //Message(tempLocation.CashVendor);
                tempvendor.Reset();
                tempvendor.SetFilter(tempvendor."No.", '=%1', cashVendortext);
                IF tempvendor.FindSet() then begin

                    IF PAGE.RUNMODAL(0, tempvendor) = ACTION::LookupOK THEN begin

                        Rec."Buy-from Vendor No." := tempvendor."No.";
                        Rec.Validate(Rec."Buy-from Vendor No.");
                    end;
                    exit(true);
                end
                else
                    exit(false);

            end;
        }
    }

    actions
    {
        // Add changes to page actions here
        modify(CopyDocument)
        {
            Enabled = False;
        }
        modify("Move Negative Lines")
        {
            Enabled = false;
        }
        modify(CalculateInvoiceDiscount)
        {
            Enabled = False;
        }
    }

    var
        myInt: Integer;
}