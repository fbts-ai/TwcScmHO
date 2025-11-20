pageextension 50002 TransferOrder extends "Transfer Order"
{
    layout
    {
        // Add changes to page layout here
        addafter("Assigned User ID")
        {
            field("Requistion No."; rec."Requistion No.")
            {
                ApplicationArea = all;
                Caption = 'Indent No.';
                Editable = false;
            }
        }

        addlast(General)
        {
            field(TransferOrderReferenceNo; Rec.TransferOrderReferenceNo)
            {
                Caption = 'Transfer Order Reference';
            }
        }
    }
    actions
    {
        addafter(PostAndPrint)
        {
            action("Qty. to Receive") //PT-FBTS 19-11-25
            {
                ApplicationArea = Dimensions;
                Caption = 'Update Qty. to Receive';
                Image = UpdateDescription;
                trigger OnAction()
                var
                    TransferLine: Record "Transfer Line";
                begin
                    // if not Confirm('Do you want to update Qty. to Receive from Qty. in Transit?', false) then
                    //     exit;

                    TransferLine.SetRange("Document No.", Rec."No.");
                    TransferLine.SetRange("Derived From Line No.", 0);
                    if TransferLine.FindSet() then
                        repeat
                            TransferLine.Validate("Qty. to Receive", TransferLine."Qty. in Transit");
                            TransferLine.Modify(true);
                        until TransferLine.Next() = 0;

                    Message('Qty. to Receive updated successfully.');
                end;
            }

            action("Update Entry No")
            {
                Image = UpdateShipment;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea = All;
                Caption = 'Update Entry No';

                trigger OnAction();
                var
                    TrackingSpecification: Record "Tracking Specification";
                    ItemLedgEntry: Record "Item Ledger Entry";
                    reserent: Record "Reservation Entry";
                begin
                    reserent.Reset();
                    //TrackingSpecification.SETCURRENTKEY("Source ID");
                    //TrackingSpecification.SETRANGE("Source ID");
                    reserent.SETRANGE("Source ID", Rec."No.");
                    //TrackingSpecification.SetFilter("Source ID", Rec."No.");
                    IF reserent.FindSet() then
                        repeat
                            ItemLedgEntry.Reset();
                            ItemLedgEntry.SetRange("Lot No.", reserent."Lot No.");
                            ItemLedgEntry.SetRange("Item No.", reserent."Item No.");
                            ItemLedgEntry.SetRange("Order No.", reserent."Source ID");
                            ItemLedgEntry.SetRange("Remaining Quantity", reserent."Quantity (Base)");
                            // ItemLedgEntry.SetRange("Location Code", 'INTRANSIT');//AsPerREQ12102023
                            ItemLedgEntry.SetRange("Location Code", 'INTRANSIT1');
                            if ItemLedgEntry.FindFirst() then begin
                                //reserent."Appl.-to Item Entry" := ItemLedgEntry."Entry No.";
                                reserent."Reservation Status" := reserent."Reservation Status"::Prospect;
                                reserent.Modify();
                            end;
                        until reserent.Next() = 0;
                    Message('Application to Item Entry updated!');
                end;
            }

        }

    }
    var

}