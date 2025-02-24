pageextension 50058 GSTAvalaraExt extends "Tax Type Setup"
{
    layout
    {
        // Add changes to page layout here
        addlast(General)
        {
            field(AvalaraEinvoiceApi; Rec.AvalaraEinvoiceApi)
            {
                Caption = 'Avalara E-Invoice Api';
            }
            field(EinvoiceSecurityToken; Rec.EinvoiceSecurityToken)
            {
                Caption = 'E-Invoice Security Token';

            }
            field(IRNtoEwayBillApi; Rec.IRNtoEwayBillApi)
            {
                Caption = 'IRN to EWay Bill Api';
            }
            field(IRNtoEwayBillSecurityToken; Rec.IRNtoEwayBillSecurityToken)
            {
                Caption = 'IRN to Eway Bill Security Token';
            }
            field(EwayBillApi; Rec.EwayBillApi)
            {
                Caption = 'Eway Bill Api';
            }
            field(EwayBillSecurityToken; rec.EwayBillSecurityToken)
            {
                Caption = 'Eway Bill Security Token';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
    //AlleNick_Start
    // trigger OnOpenPage()
    // var
    //     usersetup: Record "User Setup";
    // begin
    //     if Usersetup."Allow Master Modification" = false then begin
    //         Error('You are not authorized to Access the page');
    //         CurrPage.Close();
    //     end;
    // end;
    //AlleNick_Start

    var
        myInt: Integer;
}