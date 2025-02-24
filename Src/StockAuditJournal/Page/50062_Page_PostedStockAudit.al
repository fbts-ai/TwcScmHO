page 50062 PostedStockAuditHeader
{
    PageType = Document;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = StockAuditHeader;
    Caption = 'Posted Inventory Counting Card';
    PromotedActionCategories = 'New," "," ",Process,Approval';
    RefreshOnActivate = true;



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
                field(TotalStockValue; Rec.TotalStockValue)
                {
                    ApplicationArea = All;
                    Visible = false;
                    Caption = 'TotalStockValue';
                    Editable = false;
                }


            }


            part(StockLine; PostedStockAuditSubform)
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




        }
    }
    var
        [InDataSet]
        IsStockLinesEditable: Boolean;
        ispageEtitable: Boolean;

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

    trigger OnAfterGetCurrRecord()
    begin
        if Rec.Status = Rec.Status::Open then Begin
        End
        Else
            CurrPage.Editable(False);

    end;

    trigger OnModifyRecord(): Boolean
    begin
        if Rec.Status = Rec.Status::Open then Begin
        End
        Else
            CurrPage.Editable(False);

        //  Message('onmodify');
    end;





    trigger OnNewRecord(BelowxRec: Boolean)
    var
        tempStockAuditHeader: Record StockAuditHeader;
        tempusersetup: Record "User Setup";
    begin
        /*
        if tempusersetup.get(UserId) then;
        tempStockAuditHeader.Reset();
        tempStockAuditHeader.SetRange("Posting date", Today);
        tempStockAuditHeader.SetRange("Location Code", 'BLUE');
        if tempStockAuditHeader.FindFirst() then begin
            error('You can only craete one watage entry record per day per location')
        end;
        */



    end;

    local procedure ActivateFields()
    begin
        IsStockLinesEditable := Rec.StockAuditLineEditable();

    end;









}