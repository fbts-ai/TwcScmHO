pageextension 50191 BlanketPurcOrderSub extends "Blanket Purchase Order Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter(Quantity)
        {
            field("Converted Qty."; Rec."Converted Qty.")
            {
                ApplicationArea = all;
                Editable = false;
            }
        }
        modify("Qty. to Receive")
        {
            trigger OnAfterValidate()
            var
                RemainingQty: Decimal;
            begin
                Clear(RemainingQty);
                RemainingQty := Rec.Quantity - Rec."Converted Qty.";
                if Rec."Qty. to Receive" > RemainingQty then
                    Error('Qty. to Receive (%1) cannot be greater than remaining quantity (%2).', Rec."Qty. to Receive", RemainingQty);
            end;
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            var
                myInt: Integer;
            begin
                //PT-FBTS 11-12-25
                if Rec.Type = Rec.Type::"Fixed Asset" then begin
                    Rec.Validate("Qty. to Receive", 0);
                    Rec.Modify();
                end;
            end;

        }
        modify("Unit of Measure Code")
        {
            trigger OnAfterValidate()
            var
                myInt: Integer;
            begin
                //PT-FBTS 11-12-25
                if Rec.Type = Rec.Type::"Fixed Asset" then begin
                    Rec.Validate("Qty. to Receive", 0);
                    Rec.Modify();
                end;
            end;

        }
        modify("No.")
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                TempItem: Record "Item";
                tempPurchPrice: Record TWCPurchasePrice;
                TempPurchHead: Record "Purchase Header";
                TempFixedAsset: Record "Fixed Asset";
                TempGLAccount: Record "G/L Account";

            begin
                IF Type = Rec.Type::Item then begin
                    TempPurchHead.Reset();
                    TempPurchHead.SetRange("No.", Rec."Document No.");
                    IF TempPurchHead.FindFirst() then;

                    if Rec.Type = Rec.Type::Item then Begin

                        TempItem.Reset();
                        TempItem.SetFilter(TempItem."No.", '<>%1', '');
                        IF TempItem.FindSet() then
                            repeat

                                tempPurchPrice.Reset();
                                tempPurchPrice.SetRange(tempPurchPrice.PurchPricetype, tempPurchPrice.PurchPricetype::Item);
                                tempPurchPrice.SetRange(tempPurchPrice."Item No.", TempItem."No.");
                                tempPurchPrice.SetRange(tempPurchPrice."Vendor No.", TempPurchHead."Buy-from Vendor No.");
                                tempPurchPrice.SetRange(tempPurchPrice."Location Code", TempPurchHead."Location Code");
                                tempPurchPrice.SetFilter(tempPurchPrice."Starting Date", '<=%1', TempPurchHead."Document Date");
                                tempPurchPrice.SetFilter(tempPurchPrice."Ending Date", '=%1', 0D);
                                IF tempPurchPrice.FindFirst() then
                                    TempItem.Mark(true);


                            until TempItem.Next() = 0;

                        //  TempItem.Reset();
                        TempItem.MarkedOnly(true);
                        //IF TempItem.FindSet() then;
                        IF PAGE.RUNMODAL(0, TempItem) = ACTION::LookupOK THEN begin
                            Rec."No." := TempItem."No.";
                            Rec.Validate(Rec."No.");
                        end;
                    End;
                end;

                IF Type = Rec.Type::"Fixed Asset" then begin
                    TempFixedAsset.Reset();
                    TempFixedAsset.SetFilter("No.", '<>%1', '');
                    TempFixedAsset.SetRange("PO Item", true);
                    TempFixedAsset.SetFilter("GST Group Code", '<>%1', ''); //Aashish 27-09-2025
                    TempFixedAsset.SetFilter("HSN/SAC Code", '<>%1', ''); //Aashish 27-09-2025
                    TempFixedAsset.SetFilter("GST Credit", '<>%1', "GST Credit"::" "); //Aashish 27-09-2025
                    IF TempFixedAsset.FindSet() then;

                    // IF PAGE.RUNMODAL(0, TempFixedAsset) = ACTION::LookupOK THEN begin
                    IF PAGE.RUNMODAL(50112, TempFixedAsset) = ACTION::LookupOK THEN begin//ALLE_NICK_140224
                        Rec."No." := TempFixedAsset."No.";
                        Rec.Validate(Rec."No.");
                    end;
                end;

                IF Type = Rec.Type::"G/L Account" then begin
                    TempGLAccount.Reset();
                    TempGLAccount.SetFilter("No.", '<>%1', '');
                    IF TempGLAccount.FindSet() then;

                    IF PAGE.RUNMODAL(0, TempGLAccount) = ACTION::LookupOK THEN begin
                        Rec."No." := TempGLAccount."No.";
                        Rec.Validate(Rec."No.");
                    end;

                end;


            end;


        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}