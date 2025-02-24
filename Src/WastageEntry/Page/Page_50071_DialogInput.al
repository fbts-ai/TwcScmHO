Page 50071 "InputDialogPage"
{
    Caption = 'Remarks';
    PageType = StandardDialog;
    SourceTable = "Integer";
    SourceTableView = where(number = filter(1));


    layout
    {
        area(content)
        {
            field(InputRejectionRemark; InputRejectionRemark)
            {
                Caption = 'Rejection Remark';
                trigger OnValidate()
                begin
                    //  Message(MyInputText);
                    IF InputRejectionRemark = '' then
                        Error('please enter value in Rejection Remark');

                    CurrWastageEntryHeader.RejectionRemark := InputRejectionRemark;
                    CurrWastageEntryHeader.Status := CurrWastageEntryHeader.Status::Rejected;
                    CurrWastageEntryHeader.Modify();
                    CurrPage.Update();
                end;
            }
        }
    }
    var
        MyInputText: text;
        InputRejectionRemark: Text;

        CurrWastageEntryHeader: Record "WastageEntryHeader";

    procedure setWastegeEntry(var TempWastgeEntryHead: Record WastageEntryHeader)
    begin
        CurrWastageEntryHeader := TempWastgeEntryHead;
    end;

    trigger OnOpenPage()
    begin

        Clear(InputRejectionRemark);
    end;
}