codeunit 50037 "TransferInOut"
{
    TableNo = "Transfer Header";

    trigger OnRun()
    begin
        //TransHeader.Copy(Rec);
        //  Code();
        //  Rec := TransHeader;
    end;

    procedure TransferInoutPost(var Rec: Record "Transfer Header"; transferout: boolean; transferin: Boolean)
    var
    begin
        TransHeader.Copy(Rec);
        Code(transferout, transferin);
        Rec := TransHeader;
    end;

    var
        TransHeader: Record "Transfer Header";

        Text000: Label '&Ship,&Receive';
        Text001: Label '&Ship';
        Text002: Label '&Receive';

    local procedure "Code"(var transferout: boolean; var transferin: Boolean)
    var
        InvtSetup: Record "Inventory Setup";
        TransLine: Record "Transfer Line";
        TransferPostShipment: Codeunit "TransferOrder-Post Shipment";
        //  TransferPostReceipt: Codeunit "TransferOrder-Post Receipt";//ALLE_NICK_261223
        TransferPostReceipt: Codeunit "TransferOrder-Post Receipt1";
        TransferOrderPostTransfer: Codeunit "TransferOrder-Post Transfer";
        DefaultNumber: Integer;
        Selection: Option " ",Shipment,Receipt;
        IsHandled: Boolean;
    begin
        //OnBeforePost(TransHeader, IsHandled, TransferPostShipment, TransferPostReceipt);
        if IsHandled then
            exit;

        InvtSetup.Get();

        DefaultNumber := 0;
        TransLine.SetRange("Document No.", TransHeader."No.");
        if TransLine.Find('-') then
            repeat
                if (TransLine."Quantity Shipped" < TransLine.Quantity) and
                    (DefaultNumber = 0)
                then
                    DefaultNumber := 1;
                if (TransLine."Quantity Received" < TransLine.Quantity) and
                    (DefaultNumber = 0)
                then
                    DefaultNumber := 2;
            until (TransLine.Next() = 0) or (DefaultNumber > 0);

        IsHandled := false;
        //   OnCodeOnBeforePostTransferOrder(TransHeader, DefaultNumber, Selection, IsHandled);
        if not IsHandled then
            if TransHeader."Direct Transfer" then
                case InvtSetup."Direct Transfer Posting" of
                    InvtSetup."Direct Transfer Posting"::"Receipt and Shipment":
                        begin
                            TransferPostShipment.Run(TransHeader);
                            TransferPostReceipt.Run(TransHeader);
                        end;
                    InvtSetup."Direct Transfer Posting"::"Direct Transfer":
                        TransferOrderPostTransfer.Run(TransHeader);
                end
            else begin
                if DefaultNumber = 0 then
                    DefaultNumber := 1;

                IF transferout then
                    Selection := StrMenu(Text001, 1)
                else
                    IF transferin then Begin
                        Selection := StrMenu(Text002, 1);
                        Selection := Selection::Receipt
                    End
                    else
                        Selection := StrMenu(Text000, DefaultNumber);

                case Selection of
                    0:
                        exit;
                    Selection::Shipment:
                        TransferPostShipment.Run(TransHeader);
                    Selection::Receipt:
                        TransferPostReceipt.Run(TransHeader);
                end;
            end;

        //OnAfterPost(TransHeader, Selection);
    end;

}

