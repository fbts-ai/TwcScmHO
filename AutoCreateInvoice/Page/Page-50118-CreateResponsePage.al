page 50118 "Create Response Page"
{
    PageType = Document;
    Caption = 'Create Response Page';
    // UsageCategory = Documents;
    SourceTable = LogHeader;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Vendor_ID; Rec.Vendor_ID)
                {
                    ApplicationArea = All;
                }
                field(REF; Rec.REF)
                {
                    ApplicationArea = All;
                    caption = 'Vendor No.';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                }
                field("Vendor Address"; Rec."Vendor Address")
                {
                    ApplicationArea = All;
                    Caption = 'Address';
                }
                field(PIN; Rec.PIN)
                {
                    ApplicationArea = All;
                }
                field(GST; Rec.GST)
                {
                    ApplicationArea = All;
                }
                field("Period From"; Rec."Period From")
                {
                    ApplicationArea = All;
                }
                field("Period To"; Rec."Period To")
                {
                    ApplicationArea = All;
                }
                field("Bill Date"; Rec."Bill Date")
                {
                    ApplicationArea = All;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                }
                field("Place of Supply"; Rec."Place of Supply")
                {
                    ApplicationArea = All;
                }
                field("Store Code"; Rec."Store Code")
                {
                    ApplicationArea = All;
                }
                field("Untaxed Amont"; Rec."Untaxed Amont")
                {
                    ApplicationArea = All;
                }
                field("Payment State"; Rec."Payment State")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field(bill_reference; Rec.bill_reference)
                {
                    ApplicationArea = All;
                }
                field(Created; Rec.Created)
                {
                    ApplicationArea = All;
                }
                field("Created Error"; Rec."Created Error")
                {
                    ApplicationArea = All;
                }
            }
            part(Lines; "Response Subform")
            {
                ApplicationArea = All;
                SubPageLink = ID = field(ID);
                UpdatePropagation = Both;
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {

                trigger OnAction()
                begin

                end;
            }
        }
    }
}