
/*
report 50132 ItemIndentUpadateUpadte
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'ItemIndentUpadateUpadte';
    DefaultRenderingLayout = LayoutName;
    ProcessingOnly = true;
    Permissions = tabledata "Item" = rm;



    dataset
    {
        dataitem(Itemdata; Item)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            var
                Temptem: Record Item;
            begin
                Temptem.reset();
                Temptem.SetFilter("Indent Unit of Measure", '=%1', '');
                IF Temptem.FindSet() then
                    repeat
                        IF Temptem."Base Unit of Measure" <> '' then begin
                            Temptem."Indent Unit of Measure" := Temptem."Base Unit of Measure";
                            Temptem.Validate(Temptem."Indent Unit of Measure");
                            Temptem.Modify();
                        end;
                    until Temptem.next = 0;

                Message('Completed');
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

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'mylayout.rdl';
        }
    }

    var
        myInt: Integer;
}
*/