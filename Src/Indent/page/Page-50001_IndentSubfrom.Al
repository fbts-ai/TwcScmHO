page 50001 "Indent Line"
{
    PageType = ListPart;
    // ApplicationArea = All;
    // UsageCategory = Lists;
    SourceTable = Indentline;
    Caption = 'Indent Subform';
    //Editable = true;


    layout
    {
        area(Content)
        {
            repeater(Line)
            {
                field("Type Of Item"; Rec."Type Of Item")
                {
                    ApplicationArea = all;
                    Editable = false;

                    trigger OnValidate()
                    var
                        IndentHdr: Record IndentHeader;
                    begin

                    end;

                }
                field("Item Code"; rec."Item Code")
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
                field(UOM; rec.UOM)
                {
                    Caption = 'Indent UOM';
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Description; rec.Description)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("FA Subclass"; Rec."FA Subclass")
                {
                    ApplicationArea = all;
                    trigger OnValidate()
                    var
                        Item: Record Item;
                    begin
                        IF Item.Get(rec."Item Code") then;

                        IF not Item.IsFixedAssetItem then begin
                            Error('FA Subclass can only be there for FA Items');
                        end;
                    end;
                }
                field(Department; rec.Department)
                {
                    ApplicationArea = all;
                    Visible = false;
                }


                field("Sub-Indent"; rec."Sub-Indent")
                {
                    ApplicationArea = all;
                    Visible = false;

                }
                field(Select; rec.Select)
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field("Request Delivery Date"; Rec."Request Delivery Date")
                {
                    ApplicationArea = all;
                    Editable = false;
                    Visible = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = all;
                    Visible = false;
                }

                field(Error; rec.Error)
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field("LineNo."; Rec."LineNo.")
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = all;
                    Editable = EnableBool;//PT-FBTS 09-07-2024
                    trigger OnValidate()
                    var
                        Item: Record Item;
                    begin
                        IF Item.Get(rec."Item Code") then;

                        if rec.Quantity <= 0 then//ALLE_NICK_190124
                            Error('Quantity cannot be Zero')
                    end;

                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = all;

                }
                field("Approval Required"; rec."Approval Required")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Approval Remarks"; rec."Approval Remarks")
                {
                    ApplicationArea = all;
                    Editable = false;
                }


            }
        }

    }


    var
        ItemList: Page "Item List";

    // trigger OnAfterGetCurrRecord()
    // var
    //     ItemCategory: Record "Item Category";
    //     Indentheader: Record IndentHeader;
    // begin
    //     if ItemCategory.get(rec.Category) then begin
    //         if ItemCategory."Require Approval" then begin


    //             if Indentheader.Get(rec."DocumentNo.") then begin
    //                 Indentheader."Require Approval" := true;
    //                 Indentheader.Modify();
    //             end;
    //         end;
    //     end;
    // end; 
    trigger OnDeleteRecord(): Boolean
    var
        indenthdr: Record IndentHeader;
    begin
        indenthdr.Reset();
        indenthdr.SetRange("No.", Rec."DocumentNo.");
        IF indenthdr.FindFirst() then begin
            If indenthdr.Status <> indenthdr.Status::Open then //PT-FBTS 07-08-2024
                                                               // if (indenthdr.Status = 2) and (indenthdr.Status = 4) then //PT-FBTS 07-08-2024 Old Code
                Error('You do not delete the line you status is %1', indenthdr.Status)
        end;
    end;

    trigger OnAfterGetCurrRecord() //PT-FBTS 09-07-2024
    var
        ItemCategory: Record "Item Category";
        Indentheader: Record IndentHeader;
    begin


        Indentheader.Reset();
        Indentheader.SetRange("No.", Rec."DocumentNo.");
        IF Indentheader.FindFirst() then begin
            if (Indentheader.Status = Status::Released) or (Indentheader.Status = Status::Processed) then begin
                EnableBool := false
            end else
                EnableBool := true;
        end;
    end;

    trigger OnAfterGetRecord() //PT-FBTS 09-07-2024
    var
        ItemCategory: Record "Item Category";
        Indentheader: Record IndentHeader;
    begin

        Indentheader.Reset();
        Indentheader.SetRange("No.", Rec."DocumentNo.");
        IF Indentheader.FindFirst() then begin
            if (Indentheader.Status = Status::Released) or (Indentheader.Status = Status::Processed) then begin
                EnableBool := false
            end else
                EnableBool := true;
        end;
        /*
        if rec."Type Of Item" = rec."Type Of Item"::Item then begin
            if ItemCategory.get(rec.Category) then begin
                if ItemCategory."Require Approval" then begin


                    if Indentheader.Get(rec."DocumentNo.") then begin
                        Indentheader."Require Approval" := true;
                        Indentheader.Modify();
                    end;
                end;
            end;
        end else
            if Rec."Type Of Item" = Rec."Type Of Item"::"Fixed Asset" then begin
                if Indentheader.Get(rec."DocumentNo.") then begin
                    Indentheader."Require Approval" := true;
                    Indentheader.Modify();
                end;
            end;
        if rec.Remarks <> '' then begin
            if Indentheader.Get(rec."DocumentNo.") then begin
                Indentheader."Require Approval" := true;
                Indentheader.Modify();
            end;
        end;
    */

    end;

    var
        EnableBool: Boolean;
}