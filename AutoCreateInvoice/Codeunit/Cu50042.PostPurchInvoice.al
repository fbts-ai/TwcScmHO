codeunit 50042 "Post Purchase Invoice"
{
    TableNo = LogHeader;

    trigger OnRun()
    begin
        ClearLastError;
        PostInvoiceFromLogHeader(Rec)

    end;

    procedure PostInvoiceFromLogHeader(LogHeader: Record LogHeader): Boolean
    var
        PurchHeader: Record "Purchase Header";
        PurchPost: Codeunit "Purch.-Post";
        purchInvHeader: Record "Purch. Inv. Header";
        l: Report "Adjust Cost - Item Entries";
    begin


        // Find the purchase invoice based on the Response ID
        PurchHeader.Reset();
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Invoice);
        PurchHeader.SetRange("No.", LogHeader."Invoice No.");
        PurchHeader.SetRange("Response ID", LogHeader.ID);

        if PurchHeader.FindFirst() then begin
            if PurchHeader.Status = PurchHeader.Status::Open then begin
                // Post the invoice
                PurchPost.Run(PurchHeader);
                LogHeader.Posted := true;
                LogHeader."Posted Error" := '';

                //Retrieve posted invoice No on LogHeader
                purchInvHeader.Reset();
                purchInvHeader.SetRange("Pre-Assigned No.", LogHeader."Invoice No.");
                if purchInvHeader.FindFirst() then
                    LogHeader."Posted Invoice No." := purchInvHeader."No.";

                LogHeader.Modify;
            end;
        end;
    end;

    var
        myInt: Integer;
        NoSeriesCode: Code[20];
}