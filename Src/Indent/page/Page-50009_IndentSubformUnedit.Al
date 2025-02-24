page 50009 "Indent Line unedit"
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
                field("Location/StoreNo.From"; rec."Location/StoreNo.From")
                {
                    ApplicationArea = All;
                    //Visible = false;
                }
                field("Location/StoreNo.To"; Rec."Location/StoreNo.To")
                {
                    ApplicationArea = all;
                    //  Visible = false;
                }
                field("Request Delivery Date"; Rec."Request Delivery Date")
                {
                    ApplicationArea = all;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field("Item Code"; rec."Item Code")
                {
                    ApplicationArea = all;

                }
                field(Description; rec.Description)
                {
                    ApplicationArea = all;
                }
                field(Department; rec.Department)
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
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
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

    trigger OnAfterGetRecord()
    var
        ItemCategory: Record "Item Category";
        Indentheader: Record IndentHeader;
    begin
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

}