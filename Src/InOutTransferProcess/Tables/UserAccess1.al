//AJ_Alle_09282023
table 50038 "User Access1"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(50001; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User ID");
            end;
        }
        field(50002; "Location Code"; Text[1024])
        {
            DataClassification = ToBeClassified;
            // TableRelation = Location;
            // NotBlank = true;
            Caption = 'Location';


        }
    }

    keys
    {
        key(Key1; "User ID")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;
    //AJ_Alle_09282023
    //NTCNFRM
    trigger OnInsert()
    var
        UserSetuprec: Record "User Setup";
    begin
        if UserSetuprec.get("User ID") then begin
            if UserSetuprec."Allow Master Modification" = false then Error('You do not have permission to modify');

        end;

    end;

    trigger OnModify()
    var
        UserSetuprec1: Record "User Setup";
    begin
        if UserSetuprec1.get("User ID") then begin
            if UserSetuprec1."Allow Master Modification" = false then Error('You do not have permission to modify');

        end;

    end;

    trigger OnDelete()
    var
        UserSetuprec2: Record "User Setup";
    begin
        if UserSetuprec2.get("User ID") then begin
            if UserSetuprec2."Allow Master Modification" = false then Error('You do not have permission to modify');

        end;

    end;

    trigger OnRename()
    var
        UserSetuprec3: Record "User Setup";
    begin
        if UserSetuprec3.get("User ID") then begin
            if UserSetuprec3."Allow Master Modification" = false then Error('You do not have permission to modify');

        end;

    end;
    //NTCNFRM
    //AJ_Alle_09282023
}