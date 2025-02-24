page 50069 WastageEntryLotNoList
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;

    SourceTable = WastageEntryLotNo;

    layout
    {
        area(Content)
        {

            repeater(Control1100409000)
            {
                field(WastageEntryNo; Rec.WastageEntryNo)
                {
                    ApplicationArea = All;
                    Caption = 'wastageEntryNo';

                }
                field(ItemNo; Rec.ItemNo)
                {
                    ApplicationArea = All;
                }
                field(LotNo; Rec.LotNo)
                {
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ILE: Record "Item Ledger Entry";
                        PageILE: Page ILELotPage;
                        wastageEntryHead: Record WastageEntryHeader;
                    begin

                        wastageEntryHead.Reset();
                        wastageEntryHead.SetRange("No.", LotWastageEntry."DocumentNo.");
                        IF wastageEntryHead.FindFirst() then;

                        ILE.Reset();
                        ILE.SetCurrentKey("Entry No.");
                        ILE.SetAscending("Entry No.", true);
                        ILE.SetRange("Item No.", LotWastageEntry."Item Code");
                        //ILE.SetRange("Location Code", );
                        ILE.SetRange(Open, true);
                        ILE.SetRange("Location Code", wastageEntryHead."Location Code");
                        ILE.SetFilter("Remaining Quantity", '>%1', 0);

                        ILE.SetFilter("Lot No.", '<>%1', '');
                        IF ILE.FindSet() then;

                        PageILE.SetTableView(ILE);
                        PageILE.SetRecord(ILE);
                        if PageILE.RunModal = Action::OK then begin
                            PageILE.GetRecord(ILE);
                            // Message(ILE."Lot No.");
                            Rec.LotNo := ILE."Lot No.";
                        end;
                    end;

                }
                field(Quantity; Rec.Quantity)
                {

                }

            }

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }
    procedure setwastageentryhead(var WastageEntry: Record WastageEntryLine)
    var
    begin
        LotWastageEntry := WastageEntry;
    end;



    trigger OnOpenPage()
    var

    begin
    end;



    //local procedure setWastageEntryNo()


    var
        myInt: Integer;
        LotWastageEntry: Record WastageEntryLine;
}