page 50007 "Sub Indent List unedit"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = IndentHeader;
    SourceTableView = where("Sub-Indent" = const(true));
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    CardPageId = IndentCardunedit;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; rec."No.")
                {
                    ApplicationArea = All;

                }
                field("To Location Name"; rec."To Location Name")
                {
                    ApplicationArea = all;
                }
                field("From Location Name"; rec."From Location Name")
                {
                    ApplicationArea = all;
                }
                field("Main Indent No."; rec."Main Indent No.")
                {
                    ApplicationArea = all;
                }
                field("Created Date"; rec."Created Date")
                {
                    ApplicationArea = all;
                }

            }
        }

    }


    var
        usersetup: Record "User Setup";

}