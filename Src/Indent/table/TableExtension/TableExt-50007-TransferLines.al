tableextension 50007 TransLine extends "Transfer Line"
{
    fields
    {
        field(50000; "Indent Qty."; Integer)
        {
            Editable = false;
        }
        field(50002; "FA Subclass"; Code[20])
        {
            TableRelation = "FA Subclass".Code;
        }

        //scm start
        // Add changes to table fields here
        field(50099; ItemInventory; Decimal)
        {
            Editable = false;
            Caption = 'Transfer-From location stock';
            FieldClass = FlowField;
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = Field("Item No."),
                                                            "Location Code" = FIELD("Transfer-from Code")
                                                            ));

        }
        field(50100; Remarks; Text[100])
        {
            Caption = 'Remarks';
        }
        field(50101; FixedAssetNo; Code[20])
        {
            Caption = 'Fixed Asset No.';
            //TodayFixedasset
            TableRelation = "Fixed Asset"."No." where("Location Code" = field("Transfer-from Code"), "PO Item" = const(false), "Used To" = const(false));//AJ_ALLE_03022024 - No need
            //TableRelation = "Fixed Asset"."No.";//AJ_ALLE_12122023 (As PEr req)
            trigger OnValidate()
            var
                TempItem: Record "Item";
                TempFixedAsset: Record "Fixed Asset";
                TempFALedgerEntries: Record "FA Ledger Entry";
                BookValue: Decimal;
                TempDepericationCode: Record "Depreciation Book";
                TempFADepriBooK: Record "FA Depreciation Book";
                FAPostingGroups: Record "FA Posting Group";
                Itempos: Record 27;
                LastFANo: Code[20];
                ForupdateFA: Record "Fixed Asset";
                ForupdateFA2: Record "Fixed Asset";
                FADepreciationBook: Record "FA Depreciation Book";

            Begin
                //TodayFixedasset
                if ForupdateFA2.Get(FixedAssetNo) then
                    rec."Parent Fixed Asset" := ForupdateFA2."Parent Fixed Asset";
                ForupdateFA2."Used To" := true;
                ForupdateFA2.Modify();
                FADepreciationBook.SetRange("FA No.", FixedAssetNo);
                if FADepreciationBook.FindFirst() then
                    FADepreciationBook.CalcFields("Book Value");
                rec.Amount := FADepreciationBook."Book Value";
                rec."Transfer Price" := FADepreciationBook."Book Value";
                rec.Description := ForupdateFA2.Description;
                rec.Modify();
                // //AJ_ALLE_02012024
                LastFANo := '';
                if xRec.FixedAssetNo <> '' then begin
                    LastFANo := xRec.FixedAssetNo;
                    if ForupdateFA.Get(LastFANo) then begin
                        ForupdateFA."Used To" := false;
                        ForupdateFA.Modify();
                    end;

                end;
                //AJ_ALLE_02012024
                Rec.TestField("Item No.");

                IF TempItem.Get(Rec."Item No.") Then;
                IF Rec.FixedAssetNo <> '' then Begin
                    IF Not TempItem.IsFixedAssetItem then
                        Error('You can not enter the value in Fixed Asset No as articles selected is not fixed Item');
                    IF TempFixedAsset.Get(Rec.FixedAssetNo) Then;


                    // TempFixedAsset.TestField(TempFixedAsset.d);
                    TempDepericationCode.Reset();
                    TempDepericationCode.SetRange("G/L Integration - Acq. Cost", true);
                    IF TempDepericationCode.FindFirst() Then;

                    TempFADepriBooK.Reset();
                    TempFADepriBooK.SetRange("FA No.", Rec.FixedAssetNo);
                    TempFADepriBooK.SetRange("Depreciation Book Code", TempDepericationCode.Code);
                    IF TempFADepriBooK.FindFirst() Then;
                    TempFADepriBooK.TestField(TempFADepriBooK."FA Posting Group");

                    FAPostingGroups.Reset();
                    FAPostingGroups.SetRange(Code, TempFADepriBooK."FA Posting Group");
                    IF FAPostingGroups.FindFirst() Then;
                    IF FAPostingGroups.CWIP then
                        Error('You cannot select Fixed asset with CWIP');


                    //FALedgEntry.SetRange("FA No.", "FA No.");
                    //   FALedgEntry.SetRange("Depreciation Book Code", "Depreciation Book Code");

                    TempFALedgerEntries.Reset();
                    TempFALedgerEntries.SetRange("FA No.", Rec.FixedAssetNo);
                    TempFALedgerEntries.SetRange("Depreciation Book Code", TempDepericationCode.Code);
                    IF TempFALedgerEntries.FindSet() then
                        repeat
                            BookValue := BookValue + TempFALedgerEntries.Amount;
                        Until TempFALedgerEntries.Next() = 0;

                    IF BookValue = 0 then
                        Error('Booked value must be greater Than 0');
                    Rec.Description := TempFixedAsset.Description;
                    Rec."Transfer Price" := BookValue;
                    Rec.Validate(Rec."Transfer Price");


                End;
            end;
        }

        //AJ_ALLE_19122023
        //TodayFixedasset
        field(50102; "Parent Fixed Asset"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        //AJ_ALLE_19122023



    }

    var
        myInt: Integer;
}