pageextension 50062 ReleaseProudctionOrderExt extends "Released Production Order"
{
    layout
    {
        // Add changes to page layout here
        modify(Posting)//PT-FBTS
        {
            Editable = false;
        }
        // Add changes to page layout here
        modify("Shortcut Dimension 1 Code") //PT-FBTS -  16-10-24
        {
            Editable = false;
        }
        modify("Shortcut Dimension 2 Code") //PT-FBTS   16-10-24
        {
            Editable = false;
        }
        modify("Location Code") //PT-FBTS  16-10-24
        {
            Editable = false;
        }
        modify("Source No.")
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                TempItem: Record Item;
                TempLocation: Record Location;
            begin
                if Rec."Source Type" = Rec."Source Type"::Item then Begin
                    IF TempLocation.get(Rec."Location Code") then;

                    IF TempLocation.IsStore then begin
                        TempItem.Reset();
                        TempItem.SetFilter(TempItem."No.", '<>%1', '');
                        IF TempItem.FindSet() then
                            repeat

                                IF TempItem.IsStoreProductionItem then
                                    TempItem.Mark(true);

                            until TempItem.Next() = 0;


                        TempItem.MarkedOnly(true);

                        IF PAGE.RUNMODAL(0, TempItem) = ACTION::LookupOK THEN begin
                            Rec."Source No." := TempItem."No.";
                            Rec.Validate(Rec."Source No.");

                        end;
                    end
                    else begin
                        TempItem.Reset();
                        TempItem.SetFilter(TempItem."No.", '<>%1', '');
                        IF TempItem.FindSet() then;

                        IF PAGE.RUNMODAL(0, TempItem) = ACTION::LookupOK THEN begin
                            Rec."Source No." := TempItem."No.";
                            Rec.Validate(Rec."Source No.");

                        end;
                    end;
                End;
            end;
        }
    }

    actions
    {
        // Add changes to page actions here
        modify("Change &Status") //PT-FBTS 16-10-24
        {
            ApplicationArea = all;
            trigger OnBeforeAction()
            var
                myInt: Integer;
            begin
                ProdOrderLine.Reset();
                ProdOrderLine.SetRange("Prod. Order No.", Rec."No.");
                ProdOrderLine.SetFilter("Finished Quantity", '=%1', 0);
                if ProdOrderLine.FindFirst() then
                    Error('Please check Finished Quantity is Zero %1', ProdOrderLine."Item No.");

                ProdOrderLine.Reset();
                ProdOrderLine.SetRange("Prod. Order No.", Rec."No.");
                if NOT ProdOrderLine.FindFirst() then
                    Error('Please Create Production order Line');
                // IF ProdOrderLine."Prod. Order No." = '' then
                //     Error('ABCE');
            end;
            //PT-FBTS 16-10-24
        }
    }
    var
        myInt: Integer;
        ProdOrderLine: Record "Prod. Order Line";

    trigger OnDeleteRecord(): Boolean; /// PT-FBTS 11-65-24 
    var
        myInt: Integer;
    begin
        Error('You can not delete this documnet');
    end;
}