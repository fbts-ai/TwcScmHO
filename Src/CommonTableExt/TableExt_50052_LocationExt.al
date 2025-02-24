tableextension 50052 LocationCardExt extends Location
{
    fields
    {

        //indent
        field(50001; "Type"; Option)
        {
            OptionMembers = "","Purchase Order","Transfer Order";
        }
        field(50002; "Vendor Code"; Code[20])
        {
            TableRelation = Vendor."No.";
        }
        field(50003; "Transfer Location"; Boolean)
        {

        }
        //
        field(50100; CashVendor; Text[50])
        {
            Caption = 'cash vendor For Location';

        }
        field(50101; PurchaseReturnVendor; Text[50])
        {
            Caption = 'PurchaseReturnVendor';

        }
        // Add changes to table fields here
        field(50102; IsWarehouse; Boolean)
        {
            caption = 'Is Warehouse';
        }
        field(50103; BuddyStore; Text[50])
        {
            caption = 'BuddyStore';
        }
        field(50104; BuddyWarehouse; Text[50])
        {
            caption = 'BuddyWarehouse';
        }
        field(50105; IsStore; Boolean)
        {
            caption = 'Is Store';
        }
        field(50106; "Creation Location"; Boolean)
        {
            caption = 'Creation Location';

        }
        //AJ_Alle_1112023
        //TodayQuarantine
        field(50108; "Quarantine Location"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        //TodayQuarantine
        //AJ_Alle_1112023
        //ALLE_NICK_12_01_23
        field(50109; "Physical Group"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Location Group";
        }
        ///E-invoice----------------
        field(50121; "Hostbook Login ID"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(50122; "Hostbook Password"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(50020; "Hostbook ConnectorID"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(50110; "Hostbook UserAccNo"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(50111; "Company ID"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50112; "Eway Bill API User-ID"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(50113; "Eway bill API password"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(50114; "E-Way Bill Business ID"; Code[10])
        {
            DataClassification = ToBeClassified;
        }

        field(50115; "E-Way Bill Business GSTIN"; Code[10])
        {
            DataClassification = ToBeClassified;
        }

        field(50116; "HB Account user ID number"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(50117; "State-IN"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = State;
        }
        field(50118; "GST-Registration No."; Code[15])
        {
            DataClassification = ToBeClassified;
            TableRelation = "GST Registration Nos." WHERE("State Code" = FIELD("State-IN"));
        }
        // field(50015; "LSCIN GST Registration No"; Code[20])
        // {
        //     DataClassification = ToBeClassified;
        // }
        field(50119; "Distance in KM"; code[20])
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
    //AJ_Alle_09282023
    //NTCNFRM
    // trigger OnInsert()
    // var
    //     UserSetuprec: Record "User Setup";
    // begin
    //     if UserSetuprec.get(UserId) then begin
    //         if UserSetuprec."Allow Master Modification" = false then Error('You do not have permission to modify');

    //     end;

    // end;

    // trigger OnModify()
    // var
    //     UserSetuprec1: Record "User Setup";
    // begin
    //     if UserSetuprec1.get(UserId) then begin
    //         if UserSetuprec1."Allow Master Modification" = false then Error('You do not have permission to modify');

    //     end;

    // end;

    // trigger OnDelete()
    // var
    //     UserSetuprec2: Record "User Setup";
    // begin
    //     if UserSetuprec2.get(UserId) then begin
    //         if UserSetuprec2."Allow Master Modification" = false then Error('You do not have permission to modify');

    //     end;

    // end;

    // trigger OnRename()
    // var
    //     UserSetuprec3: Record "User Setup";
    // begin
    //     if UserSetuprec3.get(UserId) then begin
    //         if UserSetuprec3."Allow Master Modification" = false then Error('You do not have permission to modify');

    //     end;

    // end;
    // //NTCNFRM
    // //AJ_Alle_09282023
}