page 50050 PurchaseCommentList
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = PurchCommentHeader;
    SourceTable = PurchCommentHeader;
    Caption = 'Purchase Comment Lists';

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(CommentCode; Rec.CommentCode)
                {
                    Caption = 'CommentCode';
                }
                field(Description; Rec.Description)
                {
                    caption = 'Description';
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

    var
        myInt: Integer;
}