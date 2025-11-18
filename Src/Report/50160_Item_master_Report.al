report 50160 "Item master Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'Src/Report/ItemmasterCenteraligned.rdl';

    dataset
    {
        dataitem("Stockkeeping Unit"; "Stockkeeping Unit")
        {
            RequestFilterFields = "Location Code", "Item No.";
            column(Location_Code; "Location Code")
            {
            }
            column(CurrentDateTime; CurrentDateTime)
            { }
            column(userID; UserId)
            { }
            column(Location_Name; "Location Name")
            {
            }
            column(Item_ID; "Item No.")
            {
            }
            column(Item_Name; Description)
            {
            }
            column(Status; Status)
            {
            }
            column(BUOM; "Base Unit of Measure")
            { }
            // column(ItemCategory; ItemRec."Item Category Code")
            // { }
            column(ItemCategory; ItemCategory.Description)
            { }
            column(SuperCategory; InvPostingGroup.Description)
            { }
            column(HSNCode; ItemRec."HSN/SAC Code")
            { }
            column(Lotassignment; ItemTrakingcode)
            { }
            column(MAPbasedonBUOM; "Unit Cost")
            { }
            column(ActiveIndentUOM; ItemRec."Indent Unit of Measure")
            { }
            column(ConversionFactorwrtActiveIndentUOM; ItemqtyPer)
            { }
            column(ActivePurchaseUOM; ItemRec."Purch. Unit of Measure")
            { }
            column(ConversionFactorwrttoactivePurchaseUOM; PurchqtyPer)
            { }
            column(LeadTimeDays; "Lead Time Calculation")
            { }
            column(MinDOI; "Minimum Order Quantity")
            { }
            column(MaxDOI; "Maximum Order Quantity")
            { }
            column(LocationCode; LocationCode)
            { }
            column(Item; Item)
            { }
            column(SafetyDOI; "Safety Stock Quantity")
            { }

            trigger OnAfterGetRecord()
            var
                myInt: Integer;
            begin
                Clear(ItemqtyPer);
                if ItemRec.Get("Stockkeeping Unit"."Item No.") then begin
                    ItemUnitofMeasure.Reset();
                    ItemUnitofMeasure.SetRange("Item No.", ItemRec."No.");
                    ItemUnitofMeasure.SetRange(code, ItemRec."Indent Unit of Measure");
                    if ItemUnitofMeasure.FindFirst() then
                        ItemqtyPer := ItemUnitofMeasure."Qty. per Unit of Measure";
                end;
                Clear(PurchqtyPer);
                if ItemRec.Get("Stockkeeping Unit"."Item No.") then begin
                    ItemUnitofMeasure.Reset();
                    ItemUnitofMeasure.SetRange("Item No.", ItemRec."No.");
                    ItemUnitofMeasure.SetRange(code, ItemRec."Purch. Unit of Measure");
                    if ItemUnitofMeasure.FindFirst() then
                        PurchqtyPer := ItemUnitofMeasure."Qty. per Unit of Measure";
                end;


                Clear(Status);
                if ItemRec.Get("Stockkeeping Unit"."Item No.") then begin
                    if ItemRec.Blocked = true then
                        Status := 'Inactive'
                    else
                        if ItemRec.Blocked = false then
                            Status := 'active';
                end;
                if ItemRec.Get("Stockkeeping Unit"."Item No.") then begin
                    if ItemCategory.Get(ItemRec."Item Category Code") then;
                    if InvPostingGroup.Get(ItemRec."Inventory Posting Group") then;

                    Clear(ItemTrakingcode);
                    if ItemRec.Get("Stockkeeping Unit"."Item No.") then begin
                        if ItemRec."Item Tracking Code" = '' then
                            ItemTrakingcode := 'No'
                        else
                            if ItemRec."Item Tracking Code" <> '' then
                                ItemTrakingcode := 'Yes';
                    end
                end;

            end;

            trigger OnPreDataItem()
            var
                myInt: Integer;
            begin
                LocationCode := GetFilter("Stockkeeping Unit"."Location Code");
                Item := GetFilter("Stockkeeping Unit"."Item No.");

            end;
        }
    }

    requestpage
    {
        AboutTitle = 'Teaching tip title';
        AboutText = 'Teaching tip content';
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    // field(LocationCode; LocationCode)
                    // {
                    //     ApplicationArea = all;
                    // }
                    // field(Item; Item)
                    // {
                    //     ApplicationArea = all;

                    // }
                    // field(Item;Item)
                    // {
                    //     ApplicationArea = all;
                    // }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(LayoutName)
                {

                }
            }
        }
    }

    // rendering
    // {
    //     layout(LayoutName)
    //     {
    //         Type = RDLC;
    //         LayoutFile = 'Report/ItemmasterCenteraligned.rdl';
    //     }
    // }

    var
        myInt: Integer;
        ItemRec: Record Item;
        ItemCategory: Record "Item Category";
        InvPostingGroup: Record "Inventory Posting Group";
        Status: Text;
        ItemTrakingcode: Text;
        SuperCategoryFilter: Text[100];
        LocationCode: Code[50];
        Item: Code[50];
        SuperCategory: Code[50];
        ItemqtyPer: Decimal;
        PurchqtyPer: Decimal;
        ItemUnitofMeasure: Record "Item Unit of Measure";
}