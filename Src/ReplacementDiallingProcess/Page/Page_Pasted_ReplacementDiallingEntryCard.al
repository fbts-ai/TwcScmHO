page 50148 PostedConsumptionCard
{
    PageType = Document;
    //ApplicationArea = All;
    //UsageCategory = Administration;
    SourceTable = ReplacementDiallingEntry;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Caption = ' Posted Replacement & Dialling Entry';
    layout
    {
        area(Content)
        {

            group(GroupName)
            {
                Editable = EditBool;
                field("No."; "No.")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Posting date"; "Posting date")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Created Date"; "Created Date")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(CreatedBy; CreatedBy)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
            }
            part(ConsumptionLine; ConsumptionSubfrom)
            {
                ApplicationArea = all;
                SubPageLink = "DocumentNo." = field("No.");
                UpdatePropagation = Both;
                Editable = EditBool;
                // Enabled = ;
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
        EditBool: Boolean;
        Posted: Boolean;

    // trigger OnAfterGetRecord()
    // begin
    //     if Rec.Status = Rec.Status::Open then Begin
    //         CurrPage.Editable(true);
    //     End
    //     Else
    //         CurrPage.Editable(False);
    //     if Rec.Exploed then
    //         EditBool := false
    //     else
    //         EditBool := true;
    // end;


    // trigger OnAfterGetCurrRecord()
    // begin
    //     if Rec.Status = Rec.Status::Open then Begin
    //         CurrPage.Editable(true);
    //     End
    //     Else
    //         CurrPage.Editable(False);
    //     if Rec.Exploed then
    //         EditBool := false
    //     else
    //         EditBool := true;
    // end;


    trigger OnDeleteRecord(): Boolean;
    var
        myInt: Integer;
    begin
        if Rec.Status = Rec.Status::Posted then
            Error('You can not Delete this Document is Posted');
    end;

    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        if Rec.Status = Rec.Status::Posted then
            Posted := false
        else
            Posted := true;
    end;


}