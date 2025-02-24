pageextension 50011 LSCStatementLines extends "LSC Statement Lines"
{

    layout
    {
        // Add changes to page layout here
        addafter("Trans. Amount")
        {
            field(CountedTransaction; Rec.CountedTransaction)
            {

                ApplicationArea = All;

                trigger OnDrillDown()
                begin
                    Rec.LookupTransAmount(false);
                end;
            }
            field(Remarks; Rec.Remarks)
            {
                Caption = 'Remarks';
            }
        }

        modify("Counted Amount")
        {
            Editable = true;
        }
    }

    trigger OnAfterGetRecord()
    begin
        "Counted AmountEditable" := true;
    end;


    var
        "Counted AmountEditable": Boolean;
}