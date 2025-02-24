pageextension 50072 PostedPurchCreditMemoGSTExt extends "Posted Purchase Credit Memo"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addlast(processing)
        {
            action(GenerateCreditMemoTwc)
            {
                ApplicationArea = All;
                Image = ExportFile;
                Promoted = true;
                Caption = 'Generate Einvoice-Eway Bill';
                // PromotedCategory = Category4;
                ToolTip = 'Specifies the function through which Json file will be generated.';

                trigger OnAction()
                var
                    PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
                    eInvoiceJsonHandler: Codeunit PurchaseCrMemoEwayBill;

                begin
                    // if eInvoiceManagement.IsGSTApplicable(Rec."No.", Database::"Sales Invoice Header") then begin
                    PurchCrMemoHeader.Reset();
                    PurchCrMemoHeader.SetRange("No.", Rec."No.");
                    if PurchCrMemoHeader.FindFirst() then begin
                        Clear(eInvoiceJsonHandler);
                        PurchCrMemoHeader.Mark(true);
                        eInvoiceJsonHandler.SetPurchCrMemoHeader(PurchCrMemoHeader);
                        IF PurchCrMemoHeader."Acknowledgement No." = '' then
                            eInvoiceJsonHandler.CreatePurchCrMemoEInvoice();
                        CurrPage.Update();
                        CurrPage.SaveRecord();

                        Clear(eInvoiceJsonHandler);
                        PurchCrMemoHeader.Mark(true);
                        eInvoiceJsonHandler.SetPurchCrMemoHeader(PurchCrMemoHeader);
                        eInvoiceJsonHandler.CreatePurchCrMemoEwayBill();
                        CurrPage.Update();



                    end;
                End;
            }
        }
    }

    var
        myInt: Integer;
}