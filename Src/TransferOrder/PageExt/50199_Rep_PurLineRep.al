report 50199 UPD_PurchLineRep
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;
    //DefaultRenderingLayout = LayoutName;

    dataset
    {
        // dataitem("Purchase Header"; "Purchase Header")
        // {
        dataitem("Purchase Line"; "Purchase Line")
        {
            // DataItemLink = "Document No." = field("No.");

            trigger OnAfterGetRecord()
            var
                myInt: Integer;
                PurHeader: Record "Purchase Header";
            begin
                PurHeader.SetRange("No.", "Purchase Line"."Document No.");
                if PurHeader.FindFirst() then begin
                    if PurHeader.Status = PurHeader.Status::Open then
                        "Purchase Line".Validate(Quantity);
                end;

            end;

            trigger OnPreDataItem()
            var
                myInt: Integer;

            begin
                //"Purchase Header".SetFilter(Status, '<>%1', "Purchase Header".Status::Open);
            end;
        }
        // }
    }


    var
        myInt: Integer;
}