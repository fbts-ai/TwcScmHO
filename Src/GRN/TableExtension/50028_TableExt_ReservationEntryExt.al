tableextension 50028 ReservationEntryExt extends "Reservation Entry"
{
    fields
    {
        field(50001; BrandName; Text[20])
        {
            Caption = 'Brand Name';
        }
        field(50002; AutoLotDocumentNo; Code[20])
        {
            Caption = 'AutoLotDocumentNo';
        }
        field(50105; ManufacturingDate; Date)
        {
            Caption = 'Manufacturing Date';
        }
        field(50106; "ILE No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}