pageextension 50076 SalesOrderSubform extends "Sales Order Subform" ///PT-FBTS
{
    layout
    {
        // Add changes to page layout here

        modify("No.")
        {
            trigger OnAfterValidate() /////PT-FBTS
            var
                TempSalesOrderLine: Record "Sales Line";
                ItemRec: Record Item;
            begin
                // IF Rec.Type = Rec.Type::Item then begin
                //     IF Rec."No." <> '' then Begin
                //         if ItemRec.Get(Rec."No.") then begin
                //             if ItemRec.Type <> ItemRec.Type::Service then begin
                //                 TempSalesOrderLine.Reset();
                //                 TempSalesOrderLine.SetRange("No.", Rec."No.");
                //                 TempSalesOrderLine.SetRange("Document No.", Rec."Document No.");
                //                 IF TempSalesOrderLine.FindFirst() then
                //                     Error('You can not enter same article twice in Sales order');
                //             end;
                //         end;
                //     End;
                // end;
            end;
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                if Rec.Quantity > GetQtyIHandValue() then //*** PT-FBTS 
                    Error('Quantity Should be less or equal to Quantity in Hand.');
                CurrPage.Update();
            end;
        }
    }


    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;

    local procedure GetQtyIHandValue(): Decimal  //PT-FBTS
    var
        ItemCategory: Record "Item Category";
        TempILE: Record "Item Ledger Entry";
        qty: Decimal;
        TempSalesHeader: Record "Sales Header";

    begin
        TempSalesHeader.Reset();
        TempSalesHeader.SetRange("No.", Rec."Document No.");
        IF TempSalesHeader.FindFirst() Then;

        TempILE.Reset();
        TempILE.SetRange("Item No.", Rec."No.");
        TempILE.SetRange("Location Code", TempSalesHeader."Location Code");
        IF TempILE.FindSet() then
            repeat
                qty := qty + TempILE.Quantity;
            until TempILE.Next() = 0;
        exit(qty);
    end;
}