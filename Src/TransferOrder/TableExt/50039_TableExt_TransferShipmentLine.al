tableextension 50039 TransferShipmentExt extends "Transfer Shipment Line"
{
    fields
    {
        field(50000; "Requistion No."; Code[25])
        {
            DataClassification = ToBeClassified;
            Caption = 'Indent No.';
            //  Editable = false;
        }
        // Add changes to table fields here
        field(50100; Remarks; Text[100])
        {
            Caption = 'Remarks';
        }
        field(50101; FixedAssetNo; Code[20])
        {
            Caption = 'Fixed Asset No.';
        }


    }

    var
        myInt: Integer;

    trigger OnInsert() //PT-FBTS 
    var
        MyDecimal: Decimal;
        MyString: Text;
        amount1: Decimal;
    begin
        MyDecimal := Rec.Amount;
        MyString := FORMAT(MyDecimal, 0, 2);
        MyString := FORMAT(MyDecimal, 0, '<Precision,2:2><Standard Format,2>');
        // MESSAGE('%1', MyString);
        Evaluate(amount1, MyString);

        Rec.Validate(Amount, amount1);
        Rec.Modify();

    end;
}