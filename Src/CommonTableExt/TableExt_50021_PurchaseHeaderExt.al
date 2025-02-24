tableextension 50021 PurchaseOrderShortClosedExt extends "Purchase Header"
{
    fields
    {

        //indent
        field(50001; "Ship to Code"; Option)
        {
            OptionMembers = "Default (Company Address)",Location,"Custom Address";


        }
        field(50002; "Email Sent"; Boolean)
        {

        }
        field(50003; "Indent No."; Code[25])
        {

        }
        //
        field(50100; "ReceviedAgainstDC"; Boolean)
        {
            Caption = 'Recevied Against DC Challan';
        }
        field(50101; "GRNInvoiceAmount"; Decimal)
        {
            Caption = 'GRN Invoice Amount';
        }
        field(50102; ShortClosed; Boolean)
        {
            Caption = 'Short Closed';
        }
        field(50103; CommentCode; Code[20])
        {
            Caption = 'Purch Comment Code';
            TableRelation = PurchCommentHeader;

            trigger OnValidate()
            var
                TempPurchCommentLine: Record "Purch. Comment Line";
                TempPurchCommentHead: Record PurchCommentHeader;
                TempCommentLine: Record PurchCommentLine;
                TempCommentLine1: Record "Purch. Comment Line";
                LineNo: Integer;

            begin
                TempPurchCommentHead.Reset();
                TempPurchCommentHead.SetRange(TempPurchCommentHead.CommentCode, Rec.CommentCode);
                IF TempPurchCommentHead.FindFirst() then begin
                    TempCommentLine1.Reset();
                    TempCommentLine1.SetRange(TempCommentLine1."No.", Rec."No.");
                    IF TempCommentLine1.FindLast() then
                        LineNo := TempCommentLine1."Line No.";


                    TempCommentLine.Reset();
                    TempCommentLine.SetRange(TempCommentLine.CommentCode, TempPurchCommentHead.CommentCode);
                    IF TempCommentLine.FindSet() then
                        repeat
                            lineNo := lineNo + 10000;
                            TempPurchCommentLine.Init();
                            TempPurchCommentLine."No." := Rec."No.";
                            TempPurchCommentLine."Document Type" := Rec."Document Type"::Order;
                            TempPurchCommentLine.PurchCommentLine := TempCommentLine.Comment;
                            TempPurchCommentLine."Line No." := TempCommentLine.LineNo + lineNo;
                            TempPurchCommentLine.Insert();
                        until TempCommentLine.Next() = 0;
                end;


            end;
        }
        field(50104; LocalPurchase; Boolean)
        {
            Caption = 'LocalPurchase';
        }
        field(50105; ProformaInvoice; Code[20])
        {
            Caption = 'Proforma Invoice Number';
        }
        field(50106; FreightCost; Boolean)
        {
            Caption = 'Freight Cost Included';
        }
        field(50107; VendorInvoiceDate; Date)
        {
            Caption = 'Vendor Invoice Date';
            trigger OnValidate() //PT-FBTS
            var
                myInt: codeunit "Einvoice CU";
            begin
                myInt.InsertDate(True);
                Rec.Validate("Document Date", VendorInvoiceDate);
            end;
        }
        field(50109; "Creation Location"; code[20])
        {
            Caption = 'Creation Location';
            TableRelation = Location WHERE("Creation Location" = CONST(true));
        }
        field(50108; "Created userId"; code[50])
        {

        }
        field(50113; "Thrid Party vendor"; Code[20]) //PT-FBTS 02-08-24
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor where(Subcontractor = filter(true));
        }
        modify("Buy-from Vendor No.")
        {
            trigger OnAfterValidate()
            var
                usersetup: Record "User Setup";
            begin
                if usersetup.Get(UserId) then
                    rec."Creation Location" := usersetup."Location Code";
                rec.Modify();
            end;
        }

    }

    var
        myInt: Integer;
}