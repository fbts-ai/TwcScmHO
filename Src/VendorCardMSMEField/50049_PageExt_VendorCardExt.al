pageextension 50049 VendorMSMEExt extends "Vendor Card"
{
    layout
    {
        addlast(General)
        {
            field(MSMEFiled; Rec.MSMEFiled)
            {
                Caption = 'MSME Filed';
            }
            //PT-FBTS 10-07-24

            field("FSSAI Number"; Rec."FSSAI Number")
            {
                ApplicationArea = all;
            }
            field("FSSAI Expiry Date"; Rec."FSSAI Expiry Date")
            {
                ApplicationArea = all;
            }
            field("CIN No."; Rec."CIN No.")
            {
                ApplicationArea = all;
            }
            //PT-FBTS 10-07-24


            field(SDLinkVendor; Rec.SDLinkVendor)
            {
                Caption = 'SD Link Vendor';
                // TableRelation = Vendor;

                trigger OnLookup(var Text: Text): Boolean
                var
                    TempVendor: Record Vendor;
                    PurchRecSetup: Record "Purchases & Payables Setup";
                begin
                    // TempVendor.Reset();
                    //   TempVendor.SetRange("Vendor Posting Group", PurchRecSetup.SDVendPostingGrp);
                    //  IF TempVendor.FindSet() Then;
                    IF PAGE.RUNMODAL(50105, TempVendor) = ACTION::LookupOK THEN begin
                        Rec.SDLinkVendor := TempVendor."No.";

                    end;
                end;
            }
        }

    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;

    trigger OnQueryClosePage(action: Action): Boolean //PT-FBTS 10-07024
    var
        myInt: Integer;
    begin
        if Rec."Payment Terms Code" = '' then
            Message('Please enter The Payment Terms Code');

        if Rec."P.A.N. No." = '' then
            Message('Please Enter The P.A.N. No.');

        if Rec."Assessee Code" = 'COMPANY' then //PT-FBTS 10-07024
                                                // Rec.TestField("CIN No.");
            Message('Please Enter The CIN No.');
    end;
}