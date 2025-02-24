//AJ_Alle_11102023
table 50037 "Multiple Tax Applicable"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(50001; "Vendor"; Code[20])
        {
            Caption = 'Vendor';
            TableRelation = Vendor."No.";
        }
        field(50002; "Item"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Item."No.";
        }
        field(50003; "GST Group Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "GST Group".Code;
        }
        field(50004; "HSN/SAC CODE"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "HSN/SAC".Code where("GST Group Code" = field("GST Group Code"));
        }
    }

    keys
    {
        key(Key1; Vendor, Item)
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;
        Purchaseline: Record "Purchase Line";
}