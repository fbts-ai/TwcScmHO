tableextension 50029 PurchaseLineExt extends "Purchase Line"
{
    fields
    {
        // Add changes to table fields here
        field(50110; Remarks; Text[1000])
        {
            Caption = 'Remarks';
        }
        field(50111; SelectforFixedAsset; Boolean)
        {
            Caption = 'Select for Fixed Asset';
        }
        field(50112; "FA Qty."; Decimal) //PT-FBTS
        {
            Caption = 'FA Qty.';

        }
        field(50116; "Document Date"; Date) //PT-FBTS 090425
        {

            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Header"."Document Date" where("No." = field("Document No.")));

        }
        field(50117; "Short Close"; Boolean) //PT-FBTS 180225
        {

            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Header".ShortClosed where("No." = field("Document No.")));

        }
        //AJ_Alle_25102023
        modify(Quantity)
        {
            trigger OnAfterValidate()
            var
                myInt: Integer;
                MultitaxAplicable: Record "Multiple Tax Applicable";
                ItemRec: Record Item;
                ItemNo: Code[20];
            begin
                if rec.Quantity <> 0 then begin
                    if ItemRec.Get(Rec."No.") then begin
                        if MultitaxAplicable.Get(rec."Buy-from Vendor No.", rec."No.") then begin //ALLENICK_131123
                            Rec.Validate("GST Group Code", MultitaxAplicable."GST Group Code");
                            Rec."HSN/SAC Code" := MultitaxAplicable."HSN/SAC CODE";
                            //   Rec.Modify();
                        end;
                    end;
                end;
            end;
            //end;
        }
        field(50000; "PI Qty."; Decimal)
        {

        }
        field(50001; "GRN Rate"; Decimal)
        {

        }
        field(50002; "DC No."; Code[20])
        {

        }
        field(50003; "DC Date"; Date)
        {

        }
        field(50004; "Purchase Order No."; Code[20])
        {

        }
        field(50005; "Extra Quantity"; Decimal)
        {

        }


        field(50006; "Extra Receipt No."; Code[20])
        {
            Editable = false;
        }
        field(50007; "Extra Receipt Line No."; Integer)
        {
            Editable = false;
        }
        field(50008; "Entry No."; Integer)
        {

        }



        //AJ_19102023
        //AJ_ALLE_25102023

        // modify("Direct Unit Cost")
        // {
        //     trigger OnAfterValidate()
        //     var
        //         myInt: Integer;
        //         InventorySetup: Record "Inventory Setup";
        //         ItemRec: Record Item;
        //         UserSetupRec: Record "User Setup";
        //     begin
        //         UserSetupRec.Get(UserId);
        //         if rec."Direct Unit Cost" <> 0 then begin
        //             if xRec."Direct Unit Cost" <> Rec."Direct Unit Cost" then begin
        //                 if (rec."No." <> '') and (rec.Quantity <> 0) then begin
        //                     InventorySetup.Get();
        //                     if Rec.Type = Rec.Type::"Fixed Asset" then begin
        //                         //if InventorySetup."FA Non Editable" = true then
        //                         if UserSetupRec."Fa Non Editable" = false then//PTFBTS
        //                             Error('FA- Direct Unit Cost is Uneditable');
        //                     end;
        //                     if Rec.Type = Rec.Type::Item then begin
        //                         if ItemRec.Get(Rec."No.") then   //AJ_ALLE_30012024
        //                             if ItemRec.Type = ItemRec.Type::Inventory then //AJ_ALLE_30012024
        //                                 //if InventorySetup."FA Non Editable" = true then
        //                             if UserSetupRec."Item Non Editable" = false then //PT-FBTS
        //                                     Error('Item Direct Unit Cost is Uneditable');
        //                     end;
        //                 end;
        //             end;
        //         end;
        //     end;
        // }

        //AJ_Alle_25102023
    }

    var
        myInt: Integer;
}