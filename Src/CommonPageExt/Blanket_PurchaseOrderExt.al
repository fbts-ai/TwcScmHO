pageextension 50190 BlanketPurchOrdrExt extends "Blanket Purchase Order"
{
    layout
    {
        // Add changes to page layout here
        // modify("Location Code") //PT-FBTS 28-11-25
        // {
        //     trigger OnAfterValidate()
        //     var
        //         LocationRec: Record Location;
        //     begin
        //         if LocationRec.Get(Rec."Location Code") then begin
        //             if LocationRec."Use As In-Transit" then
        //                 Error('This location %1 is marked as In-Transit and cannot be used.', Rec."Location Code");
        //         end;
        //     end;
        //PT-FBTS 28-11-25
        //}
        addafter(Status)
        {
            field("Sub-Location"; Rec."Sub-Location")
            { ApplicationArea = all; }

        }
        addafter("Document Date")
        {
            field("Posting Date"; Rec."Posting Date")
            { ApplicationArea = all; }


        }
        modify("Buy-from Vendor No.")
        {
            // trigger OnAfterValidate()
            // var
            //     vendor: Record Vendor;
            // begin
            //     if vendor.Get(rec."Buy-from Vendor No.") then begin
            //         if vendor."Privacy Blocked" then
            //             Error('This vendor is blocked due to privacy compliance and cannot be selected.');
            //         ;
            //     end;
            // end;
            trigger OnLookup(var Text: Text): Boolean   ///PT-FBTS-27-11/25
            var
                Tempvendor: Record vendor;
            begin
                Tempvendor.Reset();
                Tempvendor.SetFilter("Privacy Blocked", '%1', false);
                IF Tempvendor.FindSet() then;
                IF PAGE.RUNMODAL(0, Tempvendor) = ACTION::LookupOK THEN begin
                    Rec."Buy-from Vendor No." := Tempvendor."No.";
                    Rec.Validate(Rec."Buy-from Vendor No.");
                end;

            end;
            ///PT-FBTS-27-11/25
        }


    }

    actions
    {
        // Add changes to page actions here
        modify(MakeOrder)
        {
            trigger OnBeforeAction()//PT-FBTS-12-01-26  
            var
                PurchLine: Record "Purchase Line";
            begin
                //if Rec."Sub-Location" = '' then
                rec.TestField("Sub-Location");
                PurchLine.Reset();
                PurchLine.SetRange("Document No.", Rec."No.");
                PurchLine.SetFilter(Type, '<>%1', PurchLine.Type::"Fixed Asset");
                if PurchLine.FindFirst() then
                    repeat
                        Error('Only Fixed Asset type lines are allowed. Please remove or correct the non-Fixed Asset lines before proceeding.');
                    until PurchLine.Next() = 0;

                PurchLine.Reset();
                PurchLine.SetRange("Document No.", Rec."No.");
                if PurchLine.FindSet() then
                    repeat
                        // PurchLine.Validate("Converted Qty.", PurchLine."Qty. to Receive");
                        if PurchLine.Quantity = PurchLine."Converted Qty." then
                            Error('Qty. to Receive must be greater than zero for Item %1.', PurchLine."No.");
                        PurchLine.Modify();
                    until PurchLine.Next() = 0;
            end;

            trigger OnAfterAction()
            var
                PurchLine: Record "Purchase Line";
            begin

                Rec.Validate("Sub-Location", '');
                PurchLine.Reset();
                PurchLine.SetRange("Document No.", Rec."No.");
                if PurchLine.FindSet() then
                    repeat
                        //   PurchLine.Validate("Converted Qty.", PurchLine."Qty. to Receive" + PurchLine."Qty. to Receive");
                        // if PurchLine.Quantity = PurchLine."Converted Qty." then
                        // //     Error('Qty. to Receive must be greater than zero for Item %1.', PurchLine."No.");
                        PurchLine.Modify();
                    until PurchLine.Next() = 0;
            end;
        }
    }

    var
        myInt: Integer;
}