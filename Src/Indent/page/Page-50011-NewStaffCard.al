page 50011 "New Staff Card"
{
    Caption = 'New Store Staff Card';
    DataCaptionFields = ID, "First Name", "Last Name";
    PageType = Card;
    SourceTable = "LSC Staff";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        // if Rec.AssistEdit(xRec) then
                        // CurrPage.Update;
                    end;
                }
                field("Name on Receipt"; Rec."Name on Receipt")
                {
                    ApplicationArea = All;
                }
                field(Password; Rec.Password)
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                }
            }
        }
    }


    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if RetailUsers."Store No." <> '' then
            Rec."Store No." := RetailUsers."Store No.";
    end;

    trigger OnOpenPage()
    begin
        // PageOpenedInSmallBusiness;
        if not (RetailUsers.Get(UserId)) then
            RetailUsers.Init;
    end;

    var
        RetailUsers: Record "LSC Retail User";
        [InDataSet]
        "Sales PersonEditable": Boolean;
        [InDataSet]
        "Last Z-ReportEditable": Boolean;
        VisibleInSmallBusiness: Boolean;
        StoreNoEditable: Boolean;
}