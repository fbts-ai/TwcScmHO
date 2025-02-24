page 50150 "User Location Link" ///PT- FBTS 19-06-2024
{
    ApplicationArea = All;
    Caption = 'User Location Link';
    // AA_18.03.23_+++
    PageType = List;
    // AA_18.03.23_+++
    UsageCategory = Administration;
    SourceTable = "User Location Link Table";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("S.No."; REc."S.No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("User Id"; Rec."User Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User Id field.';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transfer From Code field.';
                    // trigger OnValidate()
                    // var
                    //     myInt: Integer;
                    //     Vednor_REc: Record Vendor;
                    //     transLocLink: Record "Transfer Location Link Table";
                    // begin
                    //     CurrPage.SETSELECTIONFILTER(transLocLink);
                    //     if Rec."Transfer From Code" <> '' then
                    //         transLocLink.SetFilter("Transfer From Code", '<>%1', Rec."Transfer to Code ");
                    //     transLocLink.SetRange("Transfer From Code", Rec."Transfer to Code ");
                    //     if transLocLink.FindFirst() then
                    //         Error('GST No. is Already Exist in Vendor No. %1', transLocLink."Transfer to Code ");
                    // end;

                }
                field("Location Name"; "Location Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transfer From Name field.';
                }

                field(SystemCreatedAt; REc.SystemCreatedAt)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Created At';
                }
                field(SystemCreatedBy; REc.SystemCreatedBy)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Created by';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Modify At';
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Modify by';

                }
            }
        }
    }
}
