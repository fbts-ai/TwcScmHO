pageextension 50036 ReleasedProdOrderLinesExt extends "Released Prod. Order Lines"
{
    layout
    {
        // Add changes to page layout here
        modify(Control1)
        {
            Editable = False;
        }
    }

    actions
    {
        // Add changes to page actions here
        modify(Components)
        {
            trigger OnBeforeAction()
            var
                myInt: Integer;
            begin
                UserSetup.Get(UserId);
                if UserSetup."Production Component" = false then
                    Error('You do not have Permission');

            end;
        }
        modify(ProductionJournal)///PT-FBTS 23/10/20204
        {
            trigger OnBeforeAction()
            var
                myInt: Integer;
                ProdComBOM: Record 5407;
            begin
                ProdComBOM.Reset();
                ProdComBOM.SetRange("Prod. Order No.", "Prod. Order No.");
                ProdComBOM.SetRange("Prod. Order Line No.", "Line No.");
                if not ProdComBOM.FindFirst() then
                    Error('Production Component Must have a value,Please Upate Production BOM and Refresh Again');
            end;
        }
    }

    var
        UserSetup: Record "User Setup";
}