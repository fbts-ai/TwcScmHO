page 50014 "Reject Indent List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = IndentHeader;
    CardPageId = IndentCard;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTableView = sorting("No.") order(descending) where("Sub-Indent" = const(false), Status = filter(Rejected));


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                Editable = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("To Location code"; "To Location code")
                {
                    ApplicationArea = all;
                }
                field("Reject Reason"; rec."Reject Reason")
                {
                    ApplicationArea = all;
                }


                field(Status; Rec.Status)
                {
                    ApplicationArea = all;
                }
                field("Posting date"; rec."Posting date")
                {
                    ApplicationArea = all;
                    Caption = 'Requested Delivery Date';
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = all;
                }
                field("CreatedBy"; Rec."CreatedBy")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Sub-Indent"; rec."Sub-Indent")
                {
                    ApplicationArea = all;
                }

            }
        }

    }
}