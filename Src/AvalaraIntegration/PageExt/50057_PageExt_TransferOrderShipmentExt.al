pageextension 50057 GSTTransferOrder extends "Posted Transfer Shipment"
{
    layout
    {

        modify("Vehicle No.")
        {
            ShowMandatory = true;
        }
        modify("Vehicle Type")
        {
            ShowMandatory = true;
        }
        modify("Mode of Transport")
        {
            ShowMandatory = true;
        }
        // Add changes to page layout here
        addlast(Shipment)
        {
            field("E-Way Bill No."; Rec."E-Way Bill No.")
            {

            }
            field("Acknowledgement No."; Rec."Acknowledgement No.")
            {

            }
            field("IRN Hash"; Rec."IRN Hash")
            {

            }
            field("QR Code"; Rec."QR Code")
            {

            }

        }
        addafter("Vehicle Type")
        {
            field(ShippingAgentCode; ShippingAgentCode)
            {
                Caption = 'Shiping Agent Code';
                TableRelation = "Shipping Agent";
                ShowMandatory = true;
                trigger OnValidate()
                begin
                    Rec."Shipping Agent Code" := ShippingAgentCode;
                    Rec.Modify();
                end;
            }
        }
    }

    actions
    {
        /*
        modify("&Print")
        {
            trigger OnBeforeAction()
            var
            begin
                IF Rec."E-Way Bill No." = '' then begin
                    Error('It is not allowed to take print out before Eway bill is generated');
                end;
            end;
        }
        */


        addLast(Processing)
        {

            action("Eway-bill")
            {
                ApplicationArea = all;
                //Promoted = true;
                Caption = 'Direct E-Way bill TWC';
                Promoted = true;
                PromotedCategory = Category4;
                Image = "Invoicing-MDL-RegisterPayment";
                // PromotedCategory = Process;
                trigger OnAction()
                var
                    TransferShipmetEway: Codeunit TransferOrderEway;
                    TransferShipmentLine: Record "Transfer Shipment Line";
                    Amount_l: Decimal;
                begin
                    Clear(Amount_l);
                    TransferShipmentLine.Reset();
                    TransferShipmentLine.SetRange("Document No.", Rec."No.");
                    if TransferShipmentLine.FindSet() then
                        TransferShipmentLine.CalcSums(Amount);
                    Amount_l := TransferShipmentLine.Amount;
                    //  Message('%1', Amount_l);
                    // if Amount_l < 50000 then
                    //     Error('E-Way Not Applicable Total Amount < 50000');
                    TransferShipmetEway.EwayGenerateIRNNumber(Rec);
                end;
            }
            action(CancelEWaybillonly)
            {
                ApplicationArea = All;
                Caption = 'Direct Cancel E-Way bill TWC';
                Promoted = true;
                PromotedCategory = Category4;
                Image = "Invoicing-MDL-RegisterPayment";
                trigger OnAction()
                var
                    EinvoiceC: codeunit TransferOrderEway;
                begin
                    EinvoiceC.EwayGenerateCancel(Rec);
                end;
            }
            action(PrintEInvoice)
            {
                ApplicationArea = All;
                Caption = 'Generate E-Invoice TWC';
                Promoted = true;
                PromotedCategory = Category4;
                Image = "Invoicing-MDL-RegisterPayment";
                trigger OnAction()
                var
                    EinvoiceCU: codeunit "Einvoice CU";
                begin
                    EinvoiceCU.GenerateIRNNumber(Rec."No.", Rec);
                end;
            }
            action(CancelEinvoice)
            {
                ApplicationArea = All;
                Caption = 'Cancel E-invoice TWC';
                Promoted = true;
                PromotedCategory = Category4;
                Image = "Invoicing-MDL-RegisterPayment";
                trigger OnAction()
                var
                    EinvoiceCU: codeunit "Einvoice CU";
                begin
                    EinvoiceCU.Cancel_EinvoiceTranfer(TransactionType::Sale, Rec."No.", Rec);
                end;
            }
            action("PirntE-wayBill")
            {
                ApplicationArea = All;
                Caption = 'Generate E-way Bill';
                Promoted = true;
                PromotedCategory = Category4;
                Image = "Invoicing-MDL-RegisterPayment";
                trigger OnAction()
                var
                    EinvoiceCU: codeunit "Einvoice CU";
                    TransferShipmentLine: Record "Transfer Shipment Line";
                    Amount_l: Decimal;
                begin
                    Clear(Amount_l);
                    TransferShipmentLine.Reset();
                    TransferShipmentLine.SetRange("Document No.", Rec."No.");
                    if TransferShipmentLine.FindSet() then
                        TransferShipmentLine.CalcSums(Amount);
                    Amount_l := TransferShipmentLine.Amount;
                    //  Message('%1', Amount_l);
                    // if Amount_l < 50000 then
                    //     Error('E-Way Not Applicable Total Amount < 50000');
                    EinvoiceCU.SaleInvoice_GenerateInvoiceTransfer(TransactionType::Sale, Rec."No.", Rec);
                end;
            }
            action(CancelEwaybill)
            {
                ApplicationArea = All;
                Caption = 'Cancel E-waybill TWC';
                Promoted = true;
                PromotedCategory = Category4;
                Image = "Invoicing-MDL-RegisterPayment";
                trigger OnAction()
                var
                    EinvoiceCU: codeunit "Einvoice CU";
                begin
                    EinvoiceCU.Cancel_EwaybillTranSfer(TransactionType::Sale, Rec."No.", Rec);
                end;
            }
            action(LogEinv)
            {
                ApplicationArea = All;
                Caption = 'Log E-InvLog';
                Promoted = true;
                PromotedCategory = Category4;
                Image = "Invoicing-MDL-RegisterPayment";
                RunObject = page "E-invlog";
                RunPageLink = "Document No." = field("No.");
            }
            //     action(GenerateEwayBill)
            //     {
            //         ApplicationArea = All;
            //         Image = ExportFile;
            //         Promoted = true;

            //         ToolTip = 'Specifies the function through which Json file will be generated.';

            //         trigger OnAction()
            //         var
            //             TransferShipHeader: Record "Transfer Shipment Header";
            //             eInvoiceJsonHandler: Codeunit "EInvoiceTransfer";
            //             EwayBillCodeunit: Codeunit "EwayBillNoTransfer";
            //             EwayBillFromIRN: Codeunit EInvoiceTransfer;
            //             //eInvoiceManagement: Codeunit "";
            //             TempLocation: Record Location;
            //             tempState: record State;
            //             TempLocation1: Record Location;
            //             tempState1: record State;
            //         begin
            //             /*
            //             if eInvoiceManagement.IsGSTApplicable(Rec."No.", Database::"Sales Invoice Header") then begin
            //                 SalesInvHeader.Reset();
            //                 SalesInvHeader.SetRange("No.", Rec."No.");
            //                 if SalesInvHeader.FindFirst() then begin
            //                     */

            //             if TempLocation.get(Rec."Transfer-from Code") then;
            //             if tempState.Get(TempLocation."State Code") then;

            //             if TempLocation1.get(Rec."Transfer-to Code") then;
            //             if tempState1.Get(TempLocation1."State Code") then;

            //             IF tempState.Code = tempState1.code Then Begin
            //                 Clear(EwayBillCodeunit);
            //                 TransferShipHeader.Mark(true);
            //                 EwayBillCodeunit.SetTransferHeader(Rec);
            //                 EwayBillCodeunit.Run();
            //             End
            //             Else begin

            //                 Clear(EwayBillCodeunit);
            //                 Rec.Mark(true);
            //                 eInvoiceJsonHandler.SetTransferShipmentHeader(Rec);
            //                 if Rec."Acknowledgement No." = '' then
            //                     eInvoiceJsonHandler.CreateTransfereInvoice();
            //                 CurrPage.Update();
            //                 CurrPage.SaveRecord();
            //                 Clear(EwayBillFromIRN);
            //                 Rec.Mark(true);
            //                 EwayBillFromIRN.SetTransferShipmentHeader(Rec);
            //                 EwayBillFromIRN.TransferEwayBillFromIRN();

            //                 CurrPage.Update();

            //             end;
            //             /*
            //         end;
            //     end else
            //         Error(eInvoiceNonGSTTransactionErr); */
            //         end;
            //     }
        }
    }
    /*
    trigger OnOpenPage()
    var
        TempUserSetup: Record "User Setup";
    begin
        //mahendra
        IF TempUserSetup.Get(UserId) Then;
        IF TempUserSetup."Location Code" <> '' then Begin
            Rec.FilterGroup(2);
            Rec.setfilter(Rec."Transfer-from Code", '=%1', TempUserSetup."Location Code");
            Rec.FilterGroup(0);
        End;
        //end
    end;
    */

    var
        myInt: Integer;
        ShippingAgentCode: Code[10];
        TransactionType: Option Sale,"Sale Retrun";

    trigger OnDeleteRecord(): Boolean; /// PT-FBTS 11-09-24 
    var
        myInt: Integer;
    begin
        Error('You can not delete this documnet');
    end;
}