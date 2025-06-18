page 50119 "Response Subform"
{
    PageType = ListPart;
    Caption = 'Response Subform';
    SourceTable = LogLine;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(internal_reference; Rec.internal_reference)
                {
                    ApplicationArea = All;
                    Caption = 'NO.';
                }
                field(product_description; Rec.product_description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                }
                field(quantity; Rec.quantity)
                {
                    ApplicationArea = All;
                }
                field(price_unit; Rec.price_unit)
                {
                    ApplicationArea = All;
                    Caption = 'Price';
                }
                field(Price_Subtotal; Rec.Price_Subtotal)
                {
                    ApplicationArea = All;
                    Caption = 'Line Amount';
                }
                field("TAx Type"; Rec."TAx Type")
                {
                    ApplicationArea = All;
                    Caption = 'Tax Type';
                }
                field("Tax name"; Rec."Tax name")
                {
                    ApplicationArea = All;
                    Caption = 'Tax Name';
                }
                field(product_hsn; Rec.product_hsn)
                {
                    ApplicationArea = All;
                    Caption = 'HSN/SAC Code';
                }
                field("Tax Amount"; Rec."Tax Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Tax Amount';
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

                trigger OnAction()
                begin

                end;
            }
        }
    }
}