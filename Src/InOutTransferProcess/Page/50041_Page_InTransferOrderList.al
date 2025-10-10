page 50041 "InTransferOrderList"
{
    PageType = List;
    caption = 'In Transfer Order List';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Transfer Header";
    CardPageId = "In Transfer Order";

    InsertAllowed = false;
    DeleteAllowed = false;
    ShowFilter = false;

    layout
    {
        area(Content)
        {
            repeater("Transfer - In")
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Transfer-from Code"; Rec."Transfer-from Code")
                {
                    ApplicationArea = All;
                }
                field("Transfer-from Name"; Rec."Transfer-from Name")
                {
                    ApplicationArea = All;
                }
                field("Transfer-to Code"; Rec."Transfer-to Code")
                {
                    ApplicationArea = All;
                }
                field("Transfer-to Name"; Rec."Transfer-to Name")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Direct Transfer"; Rec."Direct Transfer")
                {
                    ApplicationArea = All;
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

                trigger OnAction();
                begin

                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        UserSetupRec: Record "User Setup";
        LocationVal: Text;
        //UnComment
        UserAccess: Record "User Access1";
        //UnComment
        Locations: Code[1024];
        // userAccess: Record user ac
        i: Integer;
        Filtercode: Code[2048];
    begin
        Clear(Filtercode);
        //AJ_Alle_09252023
        //Have To Comment Later On+
        //OLD

        UserSetupRec.Get(UserId);
        //LocationVal := Format(UserSetupRec."Location Code");
        //AJ_Alle_04122023
        rec.SetRange(Hide, false);
        //AJ_Alle_04122023
        Rec.FilterGroup(2);
        // Rec.SetRange(Rec."Transfer-to Code", UserSetupRec."Location Code");
        // Rec.SetRange(Rec.Status, Rec.Status::Released);
        // rec.SetRange("PARTIAL Received",false); //ALLE_NICK_220224
        // Rec.SetFilter(Rec."Last Shipment No.", '<>%1', ''); //Mahendra adedd 14 Aug
        Rec.SetRange(Rec."Transfer-to Code", UserSetupRec."Location Code");
        Rec.SetRange(Rec.Status, Rec.Status::Released);
        Rec.SetFilter(rec."Posting Date", '>%1', 20250401D);
        // rec.SetRange("PARTIAL Received",false); //ALLE_NICK_220224 //PT-FBTS-18-09-25
        Rec.SetFilter(Rec."Last Shipment No.", '<>%1', ''); //Mahendra adedd 14 Aug
        rec.SetRange(IntransitExist, true);
        Rec.FilterGroup(0);

        //AJ_Alle_09252023


        //AJ_Alle_09122023
        //NTCNFRM

        // UserSetupRec.Get(UserId);
        // Locations := '';
        // UserAccess.SetRange("User ID", UserSetupRec."User ID");
        // if UserAccess.FindFirst() then;
        // if UserSetupRec."Is Admin" = true then begin
        //     Rec.FilterGroup(2);
        //     Rec.SetRange(Rec.Status, Rec.Status::Released);
        //     Rec.SetFilter(Rec."Last Shipment No.", '<>%1', '');
        //     Rec.FilterGroup(0);
        // end else begin
        //     if UserSetupRec."Multiple Location Access" = true then begin
        //         for i := 1 to 2048 do begin
        //             if i = 1 then
        //                 if Strlen(Filtercode) = 0 then
        //                     Filtercode := format(UserAccess."Location Code");
        //         end;
        //         Rec.FilterGroup(2);
        //         Rec.SetFilter(Rec."Transfer-to Code", Filtercode);
        //         Rec.SetRange(Rec.Status, Rec.Status::Released);
        //         Rec.SetFilter(Rec."Last Shipment No.", '<>%1', '');
        //         Rec.FilterGroup(0);
        //     end else begin
        //         Rec.FilterGroup(2);
        //         Rec.SetRange(Rec."Transfer-to Code", UserSetupRec."Location Code");
        //         Rec.SetRange(Rec.Status, Rec.Status::Released);
        //         Rec.SetFilter(Rec."Last Shipment No.", '<>%1', '');
        //         Rec.FilterGroup(0);
        //     end;

        // end;
        //NTCNFRM
        //AJ_Alle_09122023

    end;
}