tableextension 50065 Production extends "Production Order"
{
    fields
    {
        // Add changes to table fields here
        field(50000; Shortclose; Boolean) //PT-FBTS-10-09-2025
        {
            Caption = 'Short Close';
        }
        field(50001; ShortCloseRemarks; Text[100]) { }
        field(50102; "Automatically Finished"; Boolean)
        { } //ICT 
            //PT-FBTS-10-09-2025
            //PT-FBTS 10-11-2025 RepCounter
        field(50002; "Replication Counter"; Integer)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                // Transaction: Record "LSC Transaction Header";
                Transaction: Record "Production Order";
                ClientSessionUtility: Codeunit "LSC Client Session Utility";
            begin
                Transaction.SetCurrentKey("Replication Counter");
                if Transaction.FindLast then
                    "Replication Counter" := Transaction."Replication Counter" + 1
                else
                    "Replication Counter" := 1;
            end;
        }
        //PT-FBTS 10-11-2025 RepCounter


    }

    keys
    {
        // Add changes to keys here
        key(sec; "Replication Counter") //PT-FBTS 10-11-2025 RepCounter
        {

        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        ProdOrderLine: Record "Prod. Order Line";

    trigger OnBeforeDelete() /// PT-FBTS 17-05-24 
    var
        myInt: Integer;
    begin
        ProdOrderLine.Reset();
        ProdOrderLine.SetRange("Prod. Order No.", Rec."No.");
        ProdOrderLine.SetFilter("Finished Quantity", '<>%1', 0);
        if ProdOrderLine.FindFirst() then
            Error('You Cannot Delete After Finished Order %1', ProdOrderLine."Item No.");
    end;

    trigger OnInsert()
    var
        myInt: Integer;
    begin
        Validate("Replication Counter");
    end;

    trigger OnModify()
    var
        myInt: Integer;
    begin
        Validate("Replication Counter");
    end;
}