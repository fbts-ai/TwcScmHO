page 50092 VendorEdit
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Reservation Entry";
    Caption = 'Alle RN Entry';


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(SourceID; Rec."Source ID")
                {
                    ApplicationArea = all;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = all;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = all;
                }
                field("Source Ref No."; Rec."Source Ref. No.")
                {
                    ApplicationArea = all;
                }
                field("Quantity (Base)"; "Quantity (Base)")
                {
                    ApplicationArea = all;
                }
                field("Source Prod. Order Line"; "Source Prod. Order Line")
                {
                    ApplicationArea = all;
                }
                field(SOurceType; Rec."Source Type")
                {
                    ApplicationArea = all;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    trigger OnDeleteRecord(): Boolean
    var
        TranOrde: Record "Transfer Line";
    begin
        iF usersetup.Get(UserId) then;
        if usersetup."User ID" = 'ALLE' then begin
            TranOrde.Reset();
            TranOrde.SetRange("Document No.", Rec."Source ID");
            TranOrde.SetRange("Line No.", rec."Source Ref. No.");
            TranOrde.SetRange("Qty. to Ship", 0);
            IF TranOrde.FindFirst() then begin
                Error('You cannot delete the line as order is shipped');
            end;
        end
        else
            Error('Not authorised');

    end;

    trigger OnOpenPage()
    begin
        iF usersetup.Get(UserId) then;
        if usersetup."User ID" <> 'ALLE' then
            Error('Not authorised');
        CurrPage.Close();

    end;

    var
        usersetup: Record "User Setup";
}