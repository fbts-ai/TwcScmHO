tableextension 50003 "Sales Invoice Header Ext" extends "Sales Invoice Header"
{
    fields
    {
        // field(50000; "LR/RR No."; code[20])
        // {
        //     DataClassification = EndUserIdentifiableInformation;
        // }
        // field(50001; "LR/RR Date"; Date)
        // {
        //     DataClassification = EndUserIdentifiableInformation;
        // }
        field(60000; "DataLine_ICT"; Text[170]) //ICT
        { }
        field(60001; "FieldNo_ICT"; Integer) ////ICT
        { }
        field(50100; "Customer Type"; Option)
        {
            OptionMembers = " ",Distributor,Franchise;
        }
        field(50022; "Bill to Customer State"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = State;
        }
        field(50023; "IRN Number"; Text[250])
        {
            DataClassification = ToBeClassified;
            // TableRelation = State;
        }
        field(50024; "Einvoice Generated"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = False;
        }
        field(90008; "Trans Id"; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(90010; "Eway Bill No."; Code[20])
        {

            DataClassification = ToBeClassified;
        }


        field(90009; "Trans Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }

        field(50102; "Stock Req. No."; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50103; "RequestBoolean"; Boolean)
        {
            DataClassification = ToBeClassified;
        }


        field(50105; VehicleType; Option)
        {
            OptionMembers = " ","Vehicle 1","Vehicle 2","Vehicle 3","Vehicle 4";
            Caption = 'Vehicle Type';
        }
        field(50106; "Request To"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location;
        }
        field(50108; "Sales type"; Option)
        {
            OptionMembers = " ","Tax Invoice","Bill of Supply",Export,Transfer,"Rent Invoice";
            Caption = 'Sales Type';
        }
        field(50109; "Purchase Invoice No"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(50110; "CancelIrn"; text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50111; "CancelIrnDate"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(50112; "CancelE-Way Bill No."; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50000; IRNvALUE; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(50016; "Replication Counter"; Integer)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                // Transaction: Record "LSC Transaction Header";
                Transaction: Record "Sales Invoice Header";
                ClientSessionUtility: Codeunit "LSC Client Session Utility";
            begin
                Transaction.SetCurrentKey("Replication Counter");
                if Transaction.FindLast then
                    "Replication Counter" := Transaction."Replication Counter" + 1
                else
                    "Replication Counter" := 1;
            end;
        }
        // PT-FBTS 10-11-2025 RepCounter

    }
    keys
    {
        key(SK12; FieldNo_ICT) //ICT
        { }
        key(sec; "Replication Counter") //PT-FBTS 10-11-2025 RepCounter
        {

        }
        // Add changes to keys here
    }
    trigger OnInsert()
    var
        myInt: Integer;
    begin
        Validate("Replication Counter"); //PT-FBTS 10-11-2025 RepCounter
    end;

    trigger OnModify()
    var
        myInt: Integer;
    begin
        Validate("Replication Counter"); //PT-FBTS 10-11-2025 RepCounter
    end;
}
