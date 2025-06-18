page 50162 "Consolidate Indent Lines"
{
    PageType = ListPart;
    SourceTable = "Consolidate indent Line";
    ApplicationArea = All;
    AutoSplitKey = true;
    MultipleNewLines = true;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {

                }
                field("Item No"; Rec."Item No")
                {
                    trigger OnValidate()
                    var
                        itemRec: Record Item;
                    begin
                        if itemRec.Get(rec."Item No") then begin
                            Rec."Item Name" := itemRec.Description;
                            Rec.UOM := itemRec."Indent Unit of Measure";
                        end;
                    end;
                }
                field("Item Name"; Rec."Item Name")
                {
                    Editable = false;
                }
                field("Quantity"; Rec."Quantity")
                {
                }
                field("UOM"; Rec."UOM")
                {
                    TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No"));
                }
                field("Store"; Rec."Store")
                {
                    TableRelation = Location;
                }////T64-NS
                field("Sourcing Method"; rec."Sourcing Method")
                {
                    ApplicationArea = all;
                }
                field("Source Location No."; rec."Source Location No.")
                {
                    ApplicationArea = all;
                } //T64-NS

                field("Referance No."; Rec."Referance No.")
                {
                    ApplicationArea = all;
                }

            }
        }
    }
}
