report 50007 WastageLocation
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(WastageEntryHeader; WastageEntryHeader)
        {
            trigger OnAfterGetRecord()
            var
                wastageline: Record WastageEntryLine;
            begin
                wastageline.SetRange("DocumentNo.", "No.");
                if wastageline.FindSet() then
                    repeat
                        wastageline."Location Code" := WastageEntryHeader."Location Code";
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