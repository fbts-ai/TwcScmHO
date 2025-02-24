Page 50061 "StkRejectionInputDialogPage"
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
                    //Message(MyInputText);
                    IF InputRejectionRemark = '' then
                        Error('please enter value in Rejection Remark');

                    CurrStockAuditHeader.RejectionRemark := InputRejectionRemark;
                    CurrStockAuditHeader.Status := CurrStockAuditHeader.Status::Rejected;
                    CurrStockAuditHeader.Modify();
                    CurrPage.Update();



                end;
            }
        }
    }
    var
        MyInputText: text;
        InputRejectionRemark: Text;

        CurrStockAuditHeader: Record StockAuditHeader;

    procedure setstockAudit(var TempStockAuditHead: Record StockAuditHeader)
    begin
        CurrStockAuditHeader := TempStockAuditHead;
    end;

    trigger OnOpenPage()
    begin

        Clear(InputRejectionRemark);
    end;


}