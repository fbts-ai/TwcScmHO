pageextension 50045 PostedTransferShipmentExt extends "Posted Transfer Shpt. Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter(Amount)
        {
            field(Remarks; Remarks)
            {
                Caption = 'Remarks';
            }
            field(FixedAssetNo; Rec.FixedAssetNo)
            {
                Caption = 'FixedAssetNo';
            }
            field("Requistion No."; rec."Requistion No.")
            {
                Editable = false;
            }
        }
    }

    actions
    {
        // Add changes to page actions here

    }



    var
        myInt: Integer;

    trigger OnModifyRecord(): Boolean //PT-FBTS- 150524
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

    trigger OnInsertRecord(s: Boolean): Boolean ////PT-FBTS- 150524
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