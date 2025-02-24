pageextension 50054 PostedSalesCreditExtGST extends "Posted Sales Credit Memo"
{
    layout
    {
        // Add changes to page layout here
        addafter("Distance (Km)")
        {

        }

    }

    actions
    {
        addlast(processing)
        {
            //     action("Generate E-CreditMemo TWC")
            //     {
            //         ApplicationArea = All;
            //         Image = ExportFile;
            //         Promoted = true;
            //         PromotedCategory = Category4;
            //         ToolTip = 'Specifies the function through which Json file will be generated.';

            //         trigger OnAction()
            //         var
            //             SalesCrMemoHeader: Record "Sales Cr.Memo Header";
            //             eInvoiceJsonHandler: Codeunit SalesInvoiceCreditMemo;
            //             eInvoiceManagement: Codeunit "e-Invoice Management";

            //         begin
            //             // if eInvoiceManagement.IsGSTApplicable(Rec."No.", Database::"Sales Invoice Header") then begin
            //             SalesCrMemoHeader.Reset();
            //             SalesCrMemoHeader.SetRange("No.", Rec."No.");
            //             if SalesCrMemoHeader.FindFirst() then begin
            //                 Clear(eInvoiceJsonHandler);
            //                 SalesCrMemoHeader.Mark(true);
            //                 eInvoiceJsonHandler.SetCrMemoHeader(SalesCrMemoHeader);
            //                 IF SalesCrMemoHeader."Acknowledgement No." = '' then
            //                     eInvoiceJsonHandler.CreateSalesEInvoice();
            //                 CurrPage.Update();
            //                 CurrPage.SaveRecord();
            //                 /*
            //                                         Clear(eWaybillCrMemo);
            //                                         SalesCrMemoHeader.Mark(true);
            //                                         eWaybillCrMemo.SetSalesCreditMemo(SalesCrMemoHeader);
            //                                         eWaybillCrMemo.Run();
            //                                         CurrPage.Update();
            //                                         */


            //             end;
            //         End;
            //         /*

            //     end else
            //             Error('Error in generating file');
            //  //   end;*/
            //     }

        }
    }

    var
        myInt: Integer;
}