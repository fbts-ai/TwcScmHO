//AJAlle_11102023
//NTCNFRM
page 50191 "Multiple Tax Applicable"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Multiple Tax Applicable";
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Vendor; rec.Vendor)
                {
                    ApplicationArea = All;

                }
                field(Item; rec.Item)
                {
                    ApplicationArea = all;
                }
                field("GST Group Code"; Rec."GST Group Code")
                {
                    ApplicationArea = all;
                }
                field("HSN/SAC CODE"; Rec."HSN/SAC CODE")
                {
                    ApplicationArea = all;
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

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}