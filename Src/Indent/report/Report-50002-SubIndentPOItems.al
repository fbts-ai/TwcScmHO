report 50002 "Sub-Indent PO List"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    // ProcessingOnly = true;
    DefaultRenderingLayout = SubIndentPO;
    //DefaultLayout = Excel;
    //ExcelLayout = 'SubIndentPOList.xlsx';



    dataset
    {
        dataitem("Sub Indent PO"; "Sub Indent PO")
        {
            column(Location_Code; "Location Code")
            {

            }
            column(Item_No_; "Item No.")
            {

            }
            column(Item_Description; "Item Description")
            { }
            column(Quantity; "Indent Quantity")
            { }
            column(Remarks; Remarks) { }

            column(Store_No_; "Store No.") { }

            column(StoreName; StoreName) { }

            trigger OnAfterGetRecord()
            begin
                Clear(StoreName);
                IF storelist.Get("Store No.") then;

                StoreName := storelist.Name;

            end;
        }

    }

    rendering
    {
        layout(SubIndentPO)
        {
            Type = RDLC;
            LayoutFile = 'SubIndentPOList.rdl';


        }
    }
    var
        StoreName: Text[100];
        storelist: Record "LSC Store";

}