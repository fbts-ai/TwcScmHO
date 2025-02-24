page 50003 "Indent Item"
{
    PageType = List;
    //ApplicationArea = All;
    // UsageCategory = Lists;
    SourceTable = "Item For Indent";
    InsertAllowed = false;
    DeleteAllowed = false;
    SaveValues = true;
    //SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;


                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = all;
                    Editable = false;

                }
                field("Item UOM"; rec."Item UOM")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Item UOM Qty.of measure"; rec."Item UOM Qty.of measure")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Unit of Measure"; Rec."Indent Unit of Measure")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Stock In Hand"; Rec."Stock In Hand")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("In-Transit"; Rec."In-Transit")
                {
                    ApplicationArea = all;

                }
                field("Indent Qty"; Rec."Indent Qty")
                {
                    ApplicationArea = all;
                    trigger OnValidate()
                    var
                        Item: Record Item;
                        IndentMappingsetup: Record "Indent Mapping";
                        usersetup: Record "User Setup";
                    begin
                        IF usersetup.Get(UserId) then;
                        IndentMappingsetup.Reset();
                        IndentMappingsetup.SetRange("Location Code", usersetup."Location Code");
                        IF IndentMappingsetup.FindFirst() then begin
                            IF "Indent Qty" < IndentMappingsetup."Min Qty." then
                                Error('Indent qty cannot be less than minimum qty.');
                        end;

                        IF Item.Get(rec."Item No.") then begin
                            IF Item.IsFixedAssetItem then
                                Rec.TestField("Indent Qty", 1);
                        end;


                    end;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = all;
                }
            }
        }

    }

    actions
    {
        area(Processing)
        {
            action("Process For Indent")
            {
                //ApplicationArea = All;
                Image = Process;
                ApplicationArea = all;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction();
                var
                    IndentLine: Record Indentline;
                    IndentLine1: Record Indentline;
                    IndentLineNew: Record Indentline;
                    IndetSubage: Page "Indent Line";
                    ItemIndent: Record "Item For Indent" temporary;
                    IndentHeader: Record IndentHeader;
                    Line: Integer;
                    indentmapp: Record "Indent Mapping";
                    ItemIndent1: Record "Item For Indent";
                    qty: Decimal;
                    indent: page IndentCard;
                    Item: Record Item;
                begin
                    IndentHeader.Reset(); //PT-FBTS -07-08-2024
                    IndentHeader.SetRange("No.", rec."Indent No.");
                    if IndentHeader.FindFirst() then begin
                        IF NOT (IndentHeader.Status = 1) OR (IndentHeader.Status = 0) Then
                            Error('Indent Status Must be Open.');
                    end;
                    //PT-FBTS -07-08-2024

                    if not Confirm('Do You want to Insert these lines in Indent Page?', false) then
                        exit
                    else begin
                        IndentHeader.Reset();
                        IndentHeader.SetRange("No.", rec."Indent No.");
                        if IndentHeader.FindFirst() then;

                        Line := 10000;
                        IndentLine.Reset();
                        IndentLine.SetRange("DocumentNo.", Rec."Indent No.");
                        if IndentLine.FindLast() then
                            Line := IndentLine."LineNo." + 10000;

                        Clear(qty);
                        ItemIndent1.Reset();
                        ItemIndent1.SetRange("Indent No.", "Indent No.");
                        IF ItemIndent1.FindSet() then begin
                            ItemIndent1.CalcSums("Indent Qty");
                            qty := ItemIndent1."Indent Qty";
                            // Message('%1', qty);
                            IF qty < 0 then
                                Error('Total qty should not be 0');
                        end;

                        Rec.SetCurrentKey("Indent Qty");
                        Rec.SetAscending("Indent Qty", true);

                        ItemIndent.Copy(Rec, true);
                        ItemIndent.Reset();
                        ItemIndent.SetRange("Indent No.", Rec."Indent No.");
                        ItemIndent.SetFilter("Indent Qty", '<>%1', 0);
                        if ItemIndent.FindFirst() then
                            // if rec."Indent Qty" <> 0 then
                            repeat

                                //  IF ite."Indent Qty" <> 0 then begin

                                IndentLine1.Reset();
                                IndentLine1.SetRange("DocumentNo.", rec."Indent No.");
                                IndentLine1.SetRange("Item Code", ItemIndent."Item No.");
                                IF IndentLine1.FindFirst() then begin
                                    IF Item.Get(rec."Item No.") then;
                                    IF not Item.IsFixedAssetItem then
                                        Error('Item already exist with quantity %1 on Indent.', IndentLine1."LineNo.");
                                end;
                                IndentLine.Init();
                                IndentLine."DocumentNo." := Rec."Indent No.";
                                IndentLine."LineNo." := Line;
                                IndentLine.Validate("Type Of Item", ItemIndent.Type);
                                IndentLine.Validate("Item Code", ItemIndent."Item No.");
                                IndentLine."Item Code" := ItemIndent."Item No.";
                                IndentLine.UOM := ItemIndent."Unit of Measure";
                                ItemIndent.CalcFields("Indent Unit of Measure");
                                ItemIndent.CalcFields("Item UOM Qty.of measure");

                                IndentLine.Quantity := ItemIndent."Indent Qty";
                                //  IndentLine."From Location" := IndentHeader."From Location Code";
                                // IndentLine."To Location" := IndentHeader."To Location code";
                                IndentLine."Location/StoreNo.To" := IndentHeader."To Location code";
                                IndentLine."Location/StoreNo.From" := IndentHeader."From Location Code";
                                //IndentLine."To Location" := IndentHeader."To Location code";
                                IndentLine.Status := IndentHeader.Status;
                                IndentLine.Department := IndentHeader.DepartmentCode;
                                IndentLine.Category := Rec."Item Category";
                                IndentLine.Remarks := ItemIndent.Remarks;
                                IndentLine."Indent Date" := IndentHeader."Created Date";
                                IndentLine."Request Delivery Date" := IndentHeader."Posting date";

                                //indentmapp.Reset();
                                indentmapp.SetRange("Location Code", IndentHeader."To Location code");
                                indentmapp.SetRange("Item No.", ItemIndent."Item No.");
                                //indentmapp.Get(IndentHeader."To Location code",ItemIndent."Item No.");
                                IF indentmapp.FindFirst() then;

                                IF indentmapp."Approval Required" then begin
                                    IndentLine.Validate("Approval Required", indentmapp."Approval Required");
                                    IndentLine.Validate("Approval Remarks", IndentLine."Approval Remarks"::"Specific Category need approval");
                                end;
                                IF indentmapp."Max Qty." <> 0 then begin
                                    IF indentmapp."Max Qty." < ItemIndent."Indent Qty" * ItemIndent."Item UOM Qty.of measure" then begin
                                        IndentLine.Validate("Approval Required", true);
                                        IndentLine.Validate("Approval Remarks", IndentLine."Approval Remarks"::"Submitted beyond min & max quantity");
                                    end;
                                end;
                                IF indentmapp."Min Qty." <> 0 then begin
                                    IF indentmapp."Min Qty." > ItemIndent."Indent Qty" * ItemIndent."Item UOM Qty.of measure" then begin
                                        IndentLine.Validate("Approval Required", true);
                                        IndentLine.Validate("Approval Remarks", IndentLine."Approval Remarks"::"Submitted beyond min & max quantity");
                                    end;
                                end;


                                IndentLine.Insert();
                                Line += 10000;
                            //    end;
                            until ItemIndent.Next() = 0;
                        //until Rec.Next() = 0;
                        indentline1.Reset();
                        indentline1.SetRange("DocumentNo.", IndentHeader."No.");
                        indentline1.SetRange("Approval Required", true);
                        IF indentline1.FindFirst() then;

                        IndentHeader."Approval Required" := indentline1."Approval Required";
                        //IndentHeader.Category := '';
                        // IndentHeader.Modify();

                        //  ItemIndent.DeleteAll(true);

                    end;
                    CurrPage.Close();
                end;
            }
        }
    }
    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        IndentLine: Record Indentline;
        IndentLineNew: Record Indentline;
        IndetSubage: Page "Indent Line";
        ItemIndent: Record "Item For Indent";
        IndentLineForValidation: Record Indentline;
        Line: Integer;
        ItemCategory: Record "Item Category";
        IndentHeader: Record IndentHeader;
    begin

        //IF Confirm('If you will leave the page then Indent Lines will not be created', true) then
        //  exit;
        /*
        if not Confirm('Do You want to Insert these lines in Indent Page?', false) then
            exit;

        if CloseAction = CloseAction::OK then begin

            Line := 10000;
            IndentLine.Reset();
            IndentLine.SetRange("DocumentNo.", Rec."Indent No.");
            if IndentLine.FindLast() then
                Line := IndentLine."LineNo." + 10000;
            ItemIndent.Reset();
            ItemIndent.SetFilter("Indent Qty", '<>%1', 0);
            if ItemIndent.FindFirst() then
                repeat

                    if ItemIndent.Type = ItemIndent.Type::Item then begin
                        IndentLineForValidation.SetRange("DocumentNo.", rec."Indent No.");
                        IndentLineForValidation.SetRange(IndentLineForValidation."Type Of Item", IndentLineForValidation."Type Of Item"::Item);
                        if IndentLineForValidation.FindSet() then begin

                            if Rec."Item Category" <> IndentLineForValidation.Category then begin
                                if ItemCategory.get(ItemIndent."Item Category") then begin
                                    if ItemCategory."Require Approval" then begin
                                        Error('Error');
                                    end;
                                end;
                            end;





                        end else
                            IndentLine.Init();
                        IndentLine."DocumentNo." := ItemIndent."Indent No.";
                        IndentLine."LineNo." := Line;
                        IndentLine.Validate("Type Of Item", IndentLine."Type Of Item"::Item);
                        IndentLine.Validate("Item Code", ItemIndent."Item No.");
                        IndentLine.UOM := ItemIndent."Unit of Measure";
                        IndentLine.Quantity := ItemIndent."Indent Qty";
                        IndentLine.Category := ItemIndent."Item Category";
                        IndentLine.Remarks := ItemIndent.Remarks;
                        IndentLine.Insert();
                        if ItemCategory.get(ItemIndent."Item Category") then begin
                            if ItemCategory."Require Approval" then begin
                                if IndentHeader.get(Rec."Indent No.") then begin
                                    IndentHeader."Require Approval" := true;
                                    //IndentHeader.Modify();
                                end;
                            end;

                        end;
                    end else
                        if ItemIndent.Type = ItemIndent.Type::"Fixed Asset" then begin
                            IndentLineForValidation.SetRange("DocumentNo.", rec."Indent No.");
                            IndentLineForValidation.SetRange(IndentLineForValidation."Type Of Item", IndentLineForValidation."Type Of Item"::Item);
                            if IndentLineForValidation.FindSet() then begin

                                if ItemCategory.get(IndentLineForValidation.Category) then begin
                                    if not ItemCategory."Require Approval" then begin
                                        Error('Error');
                                        CurrPage.Close();
                                    end;

                                end;


                            end else
                                IndentLine.Init();
                            IndentLine."DocumentNo." := ItemIndent."Indent No.";
                            IndentLine."LineNo." := Line;
                            IndentLine.Validate("Type Of Item", IndentLine."Type Of Item"::"Fixed Asset");
                            IndentLine.Validate("Item Code", ItemIndent."Item No.");
                            IndentLine.UOM := ItemIndent."Unit of Measure";
                            IndentLine.Quantity := ItemIndent."Indent Qty";
                            IndentLine.Category := ItemIndent."Item Category";
                            IndentLine.Remarks := ItemIndent.Remarks;
                            IndentLine.Insert();
                            if IndentHeader.get(Rec."Indent No.") then begin
                                IndentHeader."Require Approval" := true;
                                /// IndentHeader.Modify();
                            end;
                            if ItemIndent.Remarks <> '' then begin
                                if IndentHeader.get(Rec."Indent No.") then begin
                                    IndentHeader."Require Approval" := true;
                                    /// IndentHeader.Modify();
                                end;
                            end;
                        end;
                    Line += 10000;
                until ItemIndent.Next() = 0;

        end;
*/
    end;


}
