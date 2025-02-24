page 50016 "Processed Indent"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = IndentHeader;
    SourceTableView = where("Sub-Indent" = const(true), Status = const(Processed));
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    CardPageId = IndentProcessingCard;


    layout
    {
        area(Content)
        {

            repeater(GroupName)
            {
                // Editable = rec.Status <> Rec.Status::Release;

                field("No."; rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field("To Location Name"; rec."To Location Name")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("From Location Name"; rec."From Location Name")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Main Indent No."; rec."Main Indent No.")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Indent Date"; rec."Created Date")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Processed By"; rec."Processed By")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Processed Date & time"; rec."Processed Date & time")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Status; rec.Status)
                {
                    ApplicationArea = all;
                    Editable = false;
                }

            }
        }

    }


    trigger OnOpenPage()
    var

    begin
        IF usersetup.Get(UserId) then;
        //rec.SetRange("From Location Code", usersetup."Location Code");
        /*
        Rec.FilterGroup(2);
        Rec.Setfilter("From Location code", '=%1|=%2', UserSetup."Location Code", '');
        Rec.FilterGroup(1);
        */
        IF usersetup."Location Code" <> '' then ///added mahendra 14 aug
        begin
            Rec.FilterGroup(2);
            Rec.SetRange("From Location Code", UserSetup."Location Code");
            // Rec.Setfilter("From Location code", '=%1|=%2', UserSetup."Location Code", '');
            Rec.FilterGroup(1);
        end;
    end;


    var
        usersetup: Record "User Setup";

}