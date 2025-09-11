page 50134 ConsumptionSubfrom
{
    ApplicationArea = All;
    Caption = 'Replacement&Dialling Subfrom';
    PageType = ListPart;
    SourceTable = ConsumptionLine;
    MultipleNewLines = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {

                field("Reason Code"; "Reason Code")
                {
                    ToolTip = 'Specifies the value of the Remarks field.', Comment = '%';
                    trigger OnValidate()
                    var
                        myInt: Integer;
                    begin
                        if Rec."Reason Code" = Rec."Reason Code"::Dialing then
                            Rec."Item Code" := '';
                        if Rec."Reason Code" = Rec."Reason Code"::Replacement then
                            Rec."Item Code" := '';
                    end;
                }
                field("Item Code"; Rec."Item Code")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemRec: Record Item;
                        TempVendor: Record Vendor;
                    begin
                        if Rec."Reason Code" = Rec."Reason Code"::Replacement then begin
                            ItemRec.Reset();
                            ItemRec.SetFilter("BI Super Category", '%1|%2', 'Food', 'BEVERAGE');
                            if ItemRec.FindFirst() then
                                if PAGE.RunModal(PAGE::"Item List", ItemRec) = ACTION::LookupOK then
                                    Rec.Validate("Item Code", ItemRec."No.");
                        end else
                            if Rec."Reason Code" = Rec."Reason Code"::Dialing then begin
                                ItemRec.Reset();
                                ItemRec.SetRange("No.", 'FG000353');
                                if ItemRec.FindFirst() then
                                    if PAGE.RunModal(PAGE::"Item List", ItemRec) = ACTION::LookupOK then
                                        Rec.Validate("Item Code", ItemRec."No.");
                            end;
                    end;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.', Comment = '%';
                }
                field("Original Bill No"; "Original Bill No")
                {
                    ToolTip = 'Specifies the value of the Remarks field.', Comment = '%';
                    ShowMandatory = true;

                }
                field(Remarks; Rec.Remarks)
                {
                    ToolTip = 'Specifies the value of the Remarks field.', Comment = '%';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Specifies the value of the Unit of Measure Code field.', Comment = '%';
                }
            }
        }
    }
}
