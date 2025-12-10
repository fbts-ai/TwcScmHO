table 51115 "Tracking_Specification"
{
    Caption = 'Tracking Specification';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(3; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(4; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;

            // trigger OnValidate()
            // var
            //     IsHandled: Boolean;
            // begin
            //     if ("Quantity (Base)" * "Quantity Handled (Base)" < 0) or
            //        (Abs("Quantity (Base)") < Abs("Quantity Handled (Base)"))
            //     then
            //         FieldError("Quantity (Base)", StrSubstNo(Text002, FieldCaption("Quantity Handled (Base)")));

            //     "Quantity (Base)" := UOMMgt.RoundAndValidateQty("Quantity (Base)", "Qty. Rounding Precision (Base)", FieldCaption("Quantity (Base)"));

            //     IsHandled := false;
            //     OnValidateQuantityBaseOnBeforeCheckItemTrackingChange(Rec, CurrFieldNo, IsHandled);
            //     if not IsHandled then
            //         WMSManagement.CheckItemTrackingChange(Rec, xRec);

            //     InitQtyToShip();
            //     CheckSerialNoQty();

            //     ClearApplyToEntryIfQuantityToInvoiceIsNotSufficient();
            // end;
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(8; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
        }
        field(10; "Source Type"; Integer)
        {
            Caption = 'Source Type';
        }
        field(11; "Source Subtype"; Option)
        {
            Caption = 'Source Subtype';
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10";
        }
        field(12; "Source ID"; Code[20])
        {
            Caption = 'Source ID';
        }
        field(13; "Source Batch Name"; Code[10])
        {
            Caption = 'Source Batch Name';
        }
        field(14; "Source Prod. Order Line"; Integer)
        {
            Caption = 'Source Prod. Order Line';
        }
        field(15; "Source Ref. No."; Integer)
        {
            Caption = 'Source Ref. No.';
        }
        field(16; "Item Ledger Entry No."; Integer)
        {
            Caption = 'Item Ledger Entry No.';
            TableRelation = "Item Ledger Entry";
        }
        field(17; "Transfer Item Entry No."; Integer)
        {
            Caption = 'Transfer Item Entry No.';
            TableRelation = "Item Ledger Entry";
        }
        field(24; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';

            // trigger OnValidate()
            // begin
            //     if "Serial No." <> xRec."Serial No." then begin
            //         TestField("Quantity Handled (Base)", 0);
            //         TestField("Appl.-from Item Entry", 0);
            //         if IsReclass() then
            //             "New Serial No." := "Serial No.";
            //         WMSManagement.CheckItemTrackingChange(Rec, xRec);
            //         CheckSerialNoQty();
            //         InitExpirationDate();
            //     end;
            // end;
        }
        field(28; Positive; Boolean)
        {
            Caption = 'Positive';
        }
        field(29; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(31; "Qty. Rounding Precision (Base)"; Decimal)
        {
            Caption = 'Qty. Rounding Precision (Base)';
            InitValue = 0;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 1;
            Editable = false;
        }
        field(38; "Appl.-to Item Entry"; Integer)
        {
            Caption = 'Appl.-to Item Entry';

            // trigger OnLookup()
            // var
            //     ItemLedgEntry: Record "Item Ledger Entry";
            // begin
            //     ItemLedgEntry.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code");
            //     ItemLedgEntry.SetRange("Item No.", "Item No.");
            //     ItemLedgEntry.SetRange(Positive, true);
            //     ItemLedgEntry.SetRange("Location Code", "Location Code");
            //     ItemLedgEntry.SetRange("Variant Code", "Variant Code");
            //     ItemLedgEntry.SetTrackingFilterFromSpec(Rec);
            //     ItemLedgEntry.SetRange(Open, true);
            //     if PAGE.RunModal(PAGE::"Item Ledger Entries", ItemLedgEntry) = ACTION::LookupOK then
            //         Validate("Appl.-to Item Entry", ItemLedgEntry."Entry No.");
            // end;

            // trigger OnValidate()
            // var
            //     ItemLedgEntry: Record "Item Ledger Entry";
            // begin
            //     if "Appl.-to Item Entry" = 0 then
            //         exit;

            //     if not TrackingExists() then
            //         TestTrackingFieldsAreBlank();

            //     ItemLedgEntry.Get("Appl.-to Item Entry");

            //     TestApplyToItemLedgEntryNo(ItemLedgEntry);

            //     if Abs("Quantity (Base)" - "Quantity Handled (Base)") > Abs(ItemLedgEntry."Remaining Quantity") then
            //         Error(
            //           RemainingQtyErr,
            //           ItemLedgEntry.FieldCaption("Remaining Quantity"), ItemLedgEntry."Entry No.");
            // end;
        }
        field(40; "Warranty Date"; Date)
        {
            Caption = 'Warranty Date';
        }
        field(41; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';

            // trigger OnValidate()
            // var
            //     ItemTrackingMgt: Codeunit "Item Tracking Management";
            //     IsHandled: Boolean;
            // begin
            //     WMSManagement.CheckItemTrackingChange(Rec, xRec);

            //     IsHandled := false;
            //     OnValidateExpirationDateOnBeforeResetExpirationDate(Rec, xRec, IsHandled);
            //     If not IsHandled then
            //         if "Buffer Status2" = "Buffer Status2"::"ExpDate blocked" then begin
            //             "Expiration Date" := xRec."Expiration Date";
            //             Message(Text004);
            //         end;

            //     if "Expiration Date" <> xRec."Expiration Date" then
            //         ItemTrackingMgt.UpdateExpirationDateForLot(Rec);
            // end;
        }
        field(50; "Qty. to Handle (Base)"; Decimal)
        {
            Caption = 'Qty. to Handle (Base)';
            DecimalPlaces = 0 : 5;

            // trigger OnValidate()
            // var
            // begin
            //     if ("Qty. to Handle (Base)" * "Quantity (Base)" < 0) or
            //        (Abs("Qty. to Handle (Base)") > Abs("Quantity (Base)")
            //         - "Quantity Handled (Base)")
            //     then
            //         Error(Text001, "Quantity (Base)" - "Quantity Handled (Base)");

            //     OnValidateQtyToHandleOnBeforeInitQtyToInvoice(Rec, xRec, CurrFieldNo);

            //     "Qty. to Handle (Base)" := UOMMgt.RoundAndValidateQty("Qty. to Handle (Base)", "Qty. Rounding Precision (Base)", FieldCaption("Qty. to Handle (Base)"));

            //     InitQtyToInvoice();
            //     "Qty. to Handle" := CalcQty("Qty. to Handle (Base)");
            //     CheckSerialNoQty();
            // end;
        }
        field(51; "Qty. to Invoice (Base)"; Decimal)
        {
            Caption = 'Qty. to Invoice (Base)';
            DecimalPlaces = 0 : 5;

            // trigger OnValidate()
            // begin
            //     if ("Qty. to Invoice (Base)" * "Quantity (Base)" < 0) or
            //        (Abs("Qty. to Invoice (Base)") > Abs("Qty. to Handle (Base)"
            //           + "Quantity Handled (Base)" - "Quantity Invoiced (Base)"))
            //     then
            //         Error(
            //           Text000,
            //           "Qty. to Handle (Base)" + "Quantity Handled (Base)" - "Quantity Invoiced (Base)");

            //     "Qty. to Invoice (Base)" := UOMMgt.RoundAndValidateQty("Qty. to Invoice (Base)", "Qty. Rounding Precision (Base)", FieldCaption("Qty. to Invoice (Base)"));

            //     "Qty. to Invoice" := CalcQty("Qty. to Invoice (Base)");
            //     CheckSerialNoQty();
            // end;
        }
        field(52; "Quantity Handled (Base)"; Decimal)
        {
            Caption = 'Quantity Handled (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(53; "Quantity Invoiced (Base)"; Decimal)
        {
            Caption = 'Quantity Invoiced (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(60; "Qty. to Handle"; Decimal)
        {
            Caption = 'Qty. to Handle';
            DecimalPlaces = 0 : 5;
        }
        field(61; "Qty. to Invoice"; Decimal)
        {
            Caption = 'Qty. to Invoice';
            DecimalPlaces = 0 : 5;
        }
        field(70; "Buffer Status"; Option)
        {
            Caption = 'Buffer Status';
            Editable = false;
            OptionCaption = ' ,MODIFY,INSERT';
            OptionMembers = " ",MODIFY,INSERT;
        }
        field(71; "Buffer Status2"; Option)
        {
            Caption = 'Buffer Status2';
            Editable = false;
            OptionCaption = ',ExpDate blocked';
            OptionMembers = ,"ExpDate blocked";
        }
        field(72; "Buffer Value1"; Decimal)
        {
            Caption = 'Buffer Value1';
            Editable = false;
        }
        field(73; "Buffer Value2"; Decimal)
        {
            Caption = 'Buffer Value2';
            Editable = false;
        }
        field(74; "Buffer Value3"; Decimal)
        {
            Caption = 'Buffer Value3';
            Editable = false;
        }
        field(75; "Buffer Value4"; Decimal)
        {
            Caption = 'Buffer Value4';
            Editable = false;
        }
        field(76; "Buffer Value5"; Decimal)
        {
            Caption = 'Buffer Value5';
            Editable = false;
        }
        field(80; "New Serial No."; Code[50])
        {
            Caption = 'New Serial No.';

            // trigger OnValidate()
            // begin
            //     WMSManagement.CheckItemTrackingChange(Rec, xRec);
            //     CheckSerialNoQty();
            // end;
        }
        field(81; "New Lot No."; Code[50])
        {
            Caption = 'New Lot No.';

            // trigger OnValidate()
            // begin
            //     WMSManagement.CheckItemTrackingChange(Rec, xRec);
            // end;
        }
        field(900; "Prohibit Cancellation"; Boolean)
        {
            Caption = 'Prohibit Cancellation';
        }
        field(5400; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';

            // trigger OnValidate()
            // begin
            //     if "Lot No." <> xRec."Lot No." then begin
            //         TestField("Quantity Handled (Base)", 0);
            //         TestField("Appl.-from Item Entry", 0);
            //         if IsReclass() then
            //             "New Lot No." := "Lot No.";
            //         WMSManagement.CheckItemTrackingChange(Rec, xRec);
            //         InitExpirationDate();
            //     end;
            // end;
        }
        field(5401; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(5402; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
        }
        field(5811; "Appl.-from Item Entry"; Integer)
        {
            Caption = 'Appl.-from Item Entry';
            MinValue = 0;

            // trigger OnLookup()
            // var
            //     ItemLedgEntry: Record "Item Ledger Entry";
            // begin
            //     ItemLedgEntry.SetCurrentKey("Item No.", Positive, "Location Code", "Variant Code");
            //     ItemLedgEntry.SetRange("Item No.", "Item No.");
            //     ItemLedgEntry.SetRange(Positive, false);
            //     if "Location Code" <> '' then
            //         ItemLedgEntry.SetRange("Location Code", "Location Code");
            //     ItemLedgEntry.SetRange("Variant Code", "Variant Code");
            //     ItemLedgEntry.SetTrackingFilterFromSpec(Rec);
            //     ItemLedgEntry.SetFilter("Shipped Qty. Not Returned", '<0');
            //     OnAfterLookupApplFromItemEntrySetFilters(ItemLedgEntry, Rec);
            //     if PAGE.RunModal(PAGE::"Item Ledger Entries", ItemLedgEntry) = ACTION::LookupOK then
            //         Validate("Appl.-from Item Entry", ItemLedgEntry."Entry No.");
            // end;

            // trigger OnValidate()
            // var
            //     ItemLedgEntry: Record "Item Ledger Entry";
            // begin
            //     if "Appl.-from Item Entry" = 0 then
            //         exit;

            //     CheckApplyFromItemEntrySourceType();

            //     if not TrackingExists() then
            //         TestTrackingFieldsAreBlank();

            //     ItemLedgEntry.Get("Appl.-from Item Entry");
            //     ItemLedgEntry.TestField("Item No.", "Item No.");
            //     ItemLedgEntry.TestField(Positive, false);
            //     if ItemLedgEntry."Shipped Qty. Not Returned" + Abs("Qty. to Handle (Base)") > 0 then
            //         ItemLedgEntry.FieldError("Shipped Qty. Not Returned");
            //     ItemLedgEntry.TestField("Variant Code", "Variant Code");
            //     ItemLedgEntry.TestTrackingEqualToTrackingSpec(Rec);

            //     OnAfterValidateApplFromItemEntry(Rec, ItemLedgEntry, IsReclass());
            // end;
        }
        field(5817; Correction; Boolean)
        {
            Caption = 'Correction';
        }
        field(6505; "New Expiration Date"; Date)
        {
            Caption = 'New Expiration Date';

            // trigger OnValidate()
            // begin
            //     WMSManagement.CheckItemTrackingChange(Rec, xRec);
            // end;
        }
        field(6515; "Package No."; Code[50])
        {
            Caption = 'Package No.';
            CaptionClass = '6,1';

            // trigger OnValidate()
            // begin
            //     if "Package No." <> xRec."Package No." then begin
            //         CheckPackageNo("Package No.");
            //         TestField("Quantity Handled (Base)", 0);
            //         if IsReclass() then
            //             "New Package No." := "Package No.";
            //         WMSManagement.CheckItemTrackingChange(Rec, xRec);
            //         InitExpirationDate();
            //     end;
            // end;
        }
        field(6516; "New Package No."; Code[50])
        {
            Caption = 'New Package No.';
            CaptionClass = '6,2';

            // trigger OnValidate()
            // begin
            //     if "New Package No." <> xRec."New Package No." then begin
            //         CheckPackageNo("New Package No.");
            //         TestField("Quantity Handled (Base)", 0);
            //         WMSManagement.CheckItemTrackingChange(Rec, xRec);
            //     end;
            // end;
        }
        field(7300; "Quantity actual Handled (Base)"; Decimal)
        {
            Caption = 'Quantity actual Handled (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(6517; "New Entry No."; Code[50])
        { }
        field(6518; Updated; Boolean)
        { }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Source ID", "Source Type", "Source Subtype", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.")
        {
            IncludedFields = "Qty. to Handle (Base)", "Qty. to Invoice (Base)", "Quantity Handled (Base)", "Quantity Invoiced (Base)";
        }
#pragma warning disable AS0009
        key(Key3; "Lot No.", "Serial No.", "Package No.")
#pragma warning restore AS0009
        {
        }
#pragma warning disable AS0009
        key(Key4; "New Lot No.", "New Serial No.", "New Package No.")
#pragma warning restore AS0009
        {
        }
    }

    fieldgroups
    {
    }

    // trigger OnDelete()
    // var
    //     IsHandled: Boolean;
    // begin
    //     IsHandled := false;
    //     OnBeforeOnDelete(Rec, xRec, IsHandled);
    //     if IsHandled then
    //         exit;

    //     TestField("Quantity Handled (Base)", 0);
    //     TestField("Quantity Invoiced (Base)", 0);
    // end;
}