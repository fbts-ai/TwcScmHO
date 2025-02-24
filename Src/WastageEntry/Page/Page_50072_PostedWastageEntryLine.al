page 50072 "PostedWastageEntrySubform"
{
    PageType = ListPart;
    // ApplicationArea = All;
    // UsageCategory = Lists;
    SourceTable = WastageEntryLine;
    Caption = 'Wastage Entry Subform';
    //Editable = true;
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;


    layout
    {
        area(Content)
        {
            repeater(Line)
            {

                field("Item Code"; Rec."Item Code")
                {
                    ApplicationArea = all;

                }
                field(Description; Rec.Description)
                {

                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = all;
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {

                }
                field(UnitPrice; Rec.UnitPrice)
                {
                    ApplicationArea = all;
                }
                field(Amount; rec.Amount)
                {

                }



                field(Status; Rec.Status)
                {
                    ApplicationArea = all;
                    Visible = false;
                }



                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = all;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    TableRelation = "Reason Code";
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


    trigger OnAfterGetRecord()
    var
        ItemCategory: Record "Item Category";

    begin

    end;

}