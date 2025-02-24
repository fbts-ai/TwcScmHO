report 50008 inventoryLocation
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(StockAuditHeader; StockAuditHeader)
        {
            trigger OnAfterGetRecord()
            var
                wastageline: Record StockAuditLine;
            begin
                wastageline.SetRange("DocumentNo.", "No.");
                if wastageline.FindSet() then
                    repeat
                        wastageline."Location Code" := StockAuditHeader."Location Code";
                        wastageline.Modify();
                    until wastageline.Next() = 0;

            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {

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



    var
        myInt: Integer;
}