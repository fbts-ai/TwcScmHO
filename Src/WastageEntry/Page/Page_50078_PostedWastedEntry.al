page 50078 PostedWastageEntryCard
{
    PageType = Document;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = WastageEntryHeader;
    Caption = 'Posted Wastage Entry Card';
    PromotedActionCategories = 'New," "," ",Process,Approval';
    layout
    {

        area(Content)
        {

            group(General)
            {

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update();
                    end;

                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = ALL;
                    Editable = false;

                }
                field("Posting Date"; Rec."Posting date")
                {
                    ApplicationArea = all;

                }



                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;

                }

                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    Caption = 'Created Date';
                    Editable = false;
                }
                field("CreatedBy"; Rec."CreatedBy")
                {
                    ApplicationArea = All;
                    Caption = 'Created By';
                    Editable = false;
                }
                field(Totalvalue; Rec.TotalWastageValue)
                {
                    ApplicationArea = All;
                    Caption = 'Total value';
                    Editable = false;
                }


            }


            part(WastageLine; PostedWastageEntrySubform)
            {
                ApplicationArea = all;
                SubPageLink = "DocumentNo." = field("No.");
                UpdatePropagation = Both;
                Editable = false;

            }


        }
    }
    actions
    {

        area(Processing)
        {


            action(ItemLedgerEntry)
            {
                ApplicationArea = all;

                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Process;
                trigger OnAction()
                var
                    ItemledgerEntry: Record "Item Ledger Entry";
                    TempILE: Page "Item Ledger Entries";

                begin
                    ItemledgerEntry.Reset();
                    ItemledgerEntry.SetRange("Document No.", Rec."No.");
                    IF ItemledgerEntry.FindSet() then;

                    Clear(TempILE);


                    TempILE.SetRecord(ItemledgerEntry);
                    TempILE.RunModal();

                end;

            }

        }
    }
    var
        [InDataSet]
        IsWastageLinesEditable: Boolean;


        IsWastageHeaderEditable: Boolean;

    trigger OnOpenPage()
    begin
        ActivateFields();
        if Rec.Status = Rec.Status::Open then Begin
        End
        Else
            CurrPage.Editable(False);
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec.Status = Rec.Status::Open then Begin
        End
        Else
            CurrPage.Editable(False);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        tempWastageHeader: Record WastageEntryHeader;
        tempusersetup: Record "User Setup";
    begin
        /*
        if tempusersetup.get(UserId) then;
        tempWastageHeader.Reset();
        tempWastageHeader.SetRange("Posting date", Today);
        tempWastageHeader.SetRange("Location Code", 'BLUE');
        if tempWastageHeader.FindFirst() then begin
            error('You can only craete one watage entry record per day per location')
        end;
       */


    end;

    local procedure ActivateFields()
    begin
        IsWastageLinesEditable := Rec.WastageEntryLineEditable();

        if Rec.Status = Rec.Status::open then begin
            IsWastageHeaderEditable := true;
        end
        else
            IsWastageHeaderEditable := False;

    end;




}