tableextension 50040 VendorMSMEExt extends Vendor
{
    fields
    {
        field(50100; MSMEFiled; Boolean)
        {
            Caption = 'MSME Filed';
        }
        field(50101; SDLinkVendor; Code[20])
        {
            Caption = 'SD Link Vendor';
        }
        //PT-FBTS
        field(50102; "FSSAI Number"; Code[20])
        {
            Caption = 'FSSAI Number';
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                if "FSSAI Number" <> '' then begin
                    if StrLen(Rec."FSSAI Number") <> 14 then
                        Error('FSSAI Number max in 14 digit');
                end;
            end;
        }
        field(50103; "FSSAI Expiry Date"; Date)
        {
            Caption = 'FSSAI Expiry Date';

        }
        field(50104; "CIN No."; code[30])
        {
            Caption = 'CIN No.';
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                if "CIN No." <> '' then begin
                    if StrLen(Rec."CIN No.") <> 21 then
                        Error('CIN Number max in 21 digit');
                end;
            end;
        }
        //PT-FBTS
        //PT-FBTS
        modify("Phone No.")
        {
            trigger OnAfterValidate() //PT-FBTS //08-08-24
            var
                Pan: Code[15];
                Pan1: Code[15];
            begin
                Clear(Pan);
                Clear(Pan1);
                if "Phone No." <> '' then begin
                    if StrLen(Rec."Phone No.") <> 10 then
                        Error('Enter the 10 Digit Valid Phone No'); //Enter the 10 Digit Valid Mobile No
                end;
            end; //else
        }
        modify("Mobile Phone No.")
        {
            trigger OnAfterValidate() //PT-FBTS //08-08-24
            var
                Pan: Code[15];
                Pan1: Code[15];
            begin
                Clear(Pan);
                Clear(Pan1);
                if "Mobile Phone No." <> '' then begin
                    if StrLen(Rec."Mobile Phone No.") <> 10 then
                        Error('Enter the 10 Digit Valid Mobile No'); //Enter the 10 Digit Valid Mobile No
                end;
            end; //else
        }
        modify("P.A.N. No.") ////PT-FBTS //08-08-24
        {
            trigger OnAfterValidate()
            var
                vedorRec: Record Vendor;
            begin
                if "P.A.N. No." <> '' then begin
                    if StrLen(Rec."P.A.N. No.") <> 10 then
                        Message('P.A.N. No. maximum 10 digit');
                end;
                if "P.A.N. No." <> '' then begin
                    vedorRec.Reset();
                    vedorRec.SetRange("P.A.N. No.", Rec."P.A.N. No.");
                    if vedorRec.FindSet() then
                        Message('Please check Pan no. is already use other Vendor');
                    //until vedorRec.Next() = 0;
                    // end;
                    //          if (Rec."P.A.N. Status" = Rec."P.A.N. Status"::" ") and (Rec."P.A.N. No." <> '') then
                    //     if StrLen(Rec."P.A.N. No.") <> 10 then
                    //         Error(PANNoErr);

                    // if (Vendor."P.A.N. No." = '') and (Vendor."P.A.N. Status" = Vendor."P.A.N. Status"::" ") then
                    //     Error(PANNoErr);

                    // if (Vendor."P.A.N. Status" <> Vendor."P.A.N. Status"::" ") and (Vendor."P.A.N. Reference No." = '') then
                    //     Error(PANNoErr);

                end;
            end;
        }
        modify("Post Code") //PT-FBTS 30-08-24

        {
            trigger OnAfterValidate()
            var
                //  Char: DotNet Char;
                i: Integer;
                Postcode: Code[6];
            begin
                if "Post Code" <> '' then begin
                    if StrLen(Rec."Post Code") <> 6 then
                        Error('Enter the 6 Digit Valid Post Code');

                end;
            end;
        }
    }

    var
        myInt: Integer;
}