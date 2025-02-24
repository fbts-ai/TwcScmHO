page 50051 PurchCommentHeader
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = PurchCommentHeader;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(CommentCode; Rec.CommentCode)
                {
                    ApplicationArea = All;
                    Caption = 'Code';

                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';

                }
                field(Mandatory; Rec.Mandatory)
                {
                    ApplicationArea = All;
                    Caption = 'Mandatory';

                }
            }
            part(PurchCommentLine; PurchCommentLine)
            {
                ApplicationArea = All;
                Editable = true;
                Enabled = true;
                SubPageLink = CommentCode = FIELD(CommentCode);
                UpdatePropagation = Both;
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

    var
        myInt: Integer;
}