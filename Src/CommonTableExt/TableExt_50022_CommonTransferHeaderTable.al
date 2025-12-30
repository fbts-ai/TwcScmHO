tableextension 50022 TransferOrderSCMExt extends "Transfer Header"
{
    fields
    {

        //indent start
        // Add changes to table fields here


        field(50000; "Requistion No."; Code[25])
        {
            DataClassification = ToBeClassified;
            Caption = 'Indent No.';
            //  Editable = false;
        }
        field(50001; "Refrence No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50002; "From Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50003; "To Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50004; "Department Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        //End
        field(50100; InStoreTransfer; Boolean)
        {
            Caption = 'Instore Transfer';
        }
        field(50101; OutTransfer; Boolean)
        {
            Caption = 'OutTransfer';
        }
        field(50102; InTransfer; Boolean)
        {
            Caption = 'InTransfer';
        }
        field(50103; TransferOrderReferenceNo; Code[20])
        {
            Caption = 'TransferOrderReferenceNo';
            TableRelation = "Transfer Receipt Header"."No.";
        }
        field(50110; QuantityShipped; Boolean)
        {

        }
        //AJ_ALLE_04122023
        field(50111; Hide; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = true;
        }

        //AJ_ALLE_22012023

        field(50112; "FA Transfer"; Boolean)
        {

        }
        field(50113; "Quaratine Location"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(50114; Status_; Option)
        {
            //DataClassification = ToBeClassified;
            OptionMembers = Open,Release,"Sent For Approval",Approved,Rejected;
        }
        field(50115; Remarks; Text[200])
        {
            DataClassification = ToBeClassified;
            // OptionMembers = Open,Release,"Sent For Approval",Approved,Rejected;
        }
        field(50006; "IntransitExist"; Boolean) //PT-FBTS 09-10-2025
        {
            CalcFormula = exist("Transfer Line" WHERE("Document No." = FIELD("No."),
                                                                            "Qty. in Transit" = FILTER(> 0)));
            Caption = 'IntransitExist';
            Editable = false;
            FieldClass = FlowField;

        }
        //TodayQuarantine
        //AJ_ALLE_22012023
        //ALLE_NICK_130224-RSTN
        field(50116; RSTN; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = true;
        }
        //ALLE_NICK_220124
        field(50117; "PARTIAL Shipped"; Boolean)
        {
            CalcFormula = exist("Transfer Line" WHERE("Document No." = FIELD("No."),
                                                                          "Shipment Date" = FIELD("Date Filter"),
                                                                          "Transfer-from Code" = FIELD("Location Filter"),
                                                                          "Quantity Shipped" = FILTER(<> 0)));
            Caption = 'Partial Shipped';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50118; "PARTIAL Received"; Boolean)
        {
            CalcFormula = exist("Transfer Line" WHERE("Document No." = FIELD("No."),
                                                                           "Receipt Date" = FIELD("Date Filter"),
                                                                           "Transfer-to Code" = FIELD("Location Filter"),
                                                                            "Quantity Received" = FILTER(<> 0)));
            Caption = 'Partial Shipped';
            Editable = false;
            FieldClass = FlowField;
        }
        //ICT
        field(51117; "Direct Transfer Posted"; Boolean)
        { }
        //ICT
    }
    //ALLE_NICK_261223
    procedure CheckTransferLines(Ship: Boolean)
    var
        TransferLine: Record "Transfer Line";
        ErrorContextElement: Codeunit "Error Context Element";
    begin
        TransferLine.SetRange("Document No.", Rec."No.");
        TransferLine.SetRange("Derived From Line No.", 0);
        if TransferLine.FindSet() then
            repeat
                ErrorMessageMgt.PushContext(ErrorContextElement, TransferLine.RecordId(), 0, CheckTransferLineMsg);
                TestTransferLine(TransferLine, Ship);
            until TransferLine.Next() = 0;
        ErrorMessageMgt.PopContext(ErrorContextElement);
    end;

    procedure TestTransferLine(TransferLine: Record "Transfer Line"; Ship: Boolean)
    var
        DummyTrackingSpecification: Record "Tracking Specification";
    begin
        if Ship then
            DummyTrackingSpecification.CheckItemTrackingQuantity(Database::"Transfer Line", 0, "No.", TransferLine."Line No.",
                TransferLine."Qty. to Ship (Base)", TransferLine."Qty. to Ship (Base)", true, false)
        else
            DummyTrackingSpecification.CheckItemTrackingQuantity(Database::"Transfer Line", 1, "No.", GetSourceRefNo(TransferLine),
                TransferLine."Qty. to Receive (Base)", TransferLine."Qty. to Receive (Base)", true, false);
    end;

    local procedure GetSourceRefNo(TransferLine: Record "Transfer Line"): Integer
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationEntry.SetLoadFields("Source Ref. No.");
        ReservationEntry.SetSourceFilter(Database::"Transfer Line", 1, TransferLine."Document No.", 0, true);
        ReservationEntry.SetRange("Item No.", TransferLine."Item No.");
        ReservationEntry.SetRange("Source Prod. Order Line", TransferLine."Line No.");
        if ReservationEntry.FindFirst() then
            exit(ReservationEntry."Source Ref. No.");
    end;


    var
        ErrorMessageMgt: Codeunit "Error Message Management";

        CheckTransferLineMsg: Label 'Check transfer document line.';


}