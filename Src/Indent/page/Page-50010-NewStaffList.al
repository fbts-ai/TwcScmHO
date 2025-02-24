page 50010 "New Staff List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "LSC Staff";
    DataCaptionFields = "Store No.";
    Editable = false;
    CardPageId = "New Staff Card";

    layout
    {
        area(Content)
        {
            //ShowCaption = false;
            repeater(GroupName)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = All;
                }
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = All;
                }


            }
        }
    }

    trigger OnInit()
    begin
        StoreNoVisible := true;
    end;

    trigger OnOpenPage()
    var
        RetailUsers: Record "LSC Retail User";
    begin
        if RetailUsers.Get(UserId) then
            if RetailUsers."Store No." <> '' then
                if RetailUsers."Store No." <> 'HO' then begin
                    Rec.FilterGroup(2);
                    Rec.SetRange("Store No.", RetailUsers."Store No.");
                    Rec.FilterGroup(0);
                    StoreNoVisible := false;
                end;
    end;





    var
        VisibleInSmallBusiness: Boolean;
        StoreNoVisible: Boolean;

}