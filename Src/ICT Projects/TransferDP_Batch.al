report 50011 TransferDPBatch
{
    // DefaultRenderingLayout = LayoutName;
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = false;
    dataset
    {
        dataitem(DPTransfer; DPTransfer)
        {

            trigger OnAfterGetRecord()
            var
                TransferRcpt: Record "Transfer Receipt Header";
                TransferHeader: Record "Transfer Header";
                TransferLine: Record "Transfer Line";
                TransferRcptLine: Record "Transfer Receipt Line";
            begin
                if TransferRcpt.Get(DPTransfer.DocNo) then begin
                    if not TransferHeader.get(TransferRcpt."Transfer Order No.") then begin
                        TransferHeader.Init();
                        TransferHeader.Validate("No.", TransferRcpt."Transfer Order No.");
                        TransferHeader.Validate("Transfer-from Code", TransferRcpt."Transfer-from Code");
                        TransferHeader.Validate("Transfer-to Code", TransferRcpt."Transfer-to Code");
                        TransferHeader."Direct Transfer" := true;
                        TransferHeader."Posting Date" := TransferRcpt."Posting Date";
                        TransferHeader."Direct Transfer Posted" := true;
                        TransferHeader.Insert();

                        TransferRcptLine.Reset();
                        TransferRcptLine.SetRange("Document No.", TransferRcpt."No.");
                        if TransferRcptLine.FindFirst() then
                            repeat
                                TransferLine.Init();
                                TransferLine.Validate("Document No.", TransferHeader."No.");
                                TransferLine."Transfer-from Code" := TransferRcptLine."Transfer-from Code";
                                TransferLine."Transfer-to Code" := TransferRcptLine."Transfer-to Code";
                                TransferLine."Item No." := TransferRcptLine."Item No.";
                                TransferLine."Line No." := TransferRcptLine."Line No.";
                                TransferLine.Quantity := TransferRcptLine.Quantity;
                                TransferLine.Insert();
                            until TransferRcptLine.next = 0;
                    end;
                end;
            end;
        }
    }

}