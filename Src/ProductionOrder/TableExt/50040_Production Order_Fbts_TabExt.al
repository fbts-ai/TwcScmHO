tableextension 50065 Production extends "Production Order"
{
    fields
    {
        // Add changes to table fields here

    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        ProdOrderLine: Record "Prod. Order Line";

    trigger OnBeforeDelete() /// PT-FBTS 17-05-24 
    var
        myInt: Integer;
    begin
        ProdOrderLine.Reset();
        ProdOrderLine.SetRange("Prod. Order No.", Rec."No.");
        ProdOrderLine.SetFilter("Finished Quantity", '<>%1', 0);
        if ProdOrderLine.FindFirst() then
            Error('You Cannot Delete After Finished Order %1', ProdOrderLine."Item No.");
    end;
}