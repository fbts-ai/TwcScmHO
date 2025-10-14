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
                        GLAcount: Record "G/L Account";
                        fixedAsset: Record "Fixed Asset";
                    begin
                        if itemRec.Get(rec."Item No") then begin
                            Rec."Item Name" := itemRec.Description;
                            Rec.UOM := itemRec."Indent Unit of Measure";
                        end else
                            if GLAcount.Get(rec."Item No") then
                                Rec."Item Name" := GLAcount.Name
                            else
                                if fixedAsset.Get(rec."Item No") then
                                    Rec."Item Name" := fixedAsset.Description;




                    end;
                }
                field("Item Name"; Rec."Item Name")
                {
                    Editable = false;
                }
                field("Quantity"; Rec."Quantity")
                {
                }
                field("UOM"; Rec."UOM")//PT-FBTS-10/10/25
                {
                    TableRelation = if (Type = const(Item)) "Item Unit of Measure".Code where("Item No." = field("Item No"))
                    else
                    if (Type = const("G/L Account")) "Unit of Measure"
                    else
                    if (Type = const("Fixed Assets")) "Unit of Measure";
                }
                field("Store"; Rec."Store")
                {


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
