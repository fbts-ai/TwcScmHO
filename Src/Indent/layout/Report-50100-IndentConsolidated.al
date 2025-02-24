report 50100 "Indent Consolidated"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    RDLCLayout = 'IndentReport.rdl';

    dataset
    {
        dataitem(Indentline; Indentline)
        {
            column(DocumentNo_; "DocumentNo.")
            {

            }
            column(From_Location; location.Name)
            {

            }
            column(To_Location; tolocation.Name)
            {

            }
            column(Quantity; Quantity)
            {

            }
            column(Item_Code; "Item Code")
            {

            }
            column(Category; Category)
            {

            }
            column(Description; Description)
            {

            }
            column(UOM; UOM)
            {

            }
            trigger OnAfterGetRecord()
            var

            begin

            end;

            trigger OnPreDataItem()
            begin
                Indentline.CalcFields("Indent Date");
                Indentline.SetRange("Indent Date", SDate, EDate);
            end;

        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group("Date Filter")
                {
                    field(SDate; SDate)
                    {
                        ApplicationArea = all;
                        Caption = 'Start Date';
                    }
                    field(EDate; EDate)
                    {
                        ApplicationArea = all;
                        Caption = 'End Date';
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    // rendering
    // {
    //     // layout(LayoutName)
    //     // {
    //     //     Type = RDLC;
    //     //     LayoutFile = 'mylayout.rdl';
    //     // }
    // }

    var
        SDate: date;
        EDate: date;
        location: Record Location;
        ToLocation: Record Location;

}