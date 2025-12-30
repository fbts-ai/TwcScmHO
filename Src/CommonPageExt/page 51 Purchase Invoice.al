pageextension 50115 PurchaseInvoiceExt extends 51
{
    layout
    {
        // Add changes to page layout here
        addafter("Vendor Invoice No.")
        {
            field("Vendor Bill No."; Rec."Vendor Bill No.")
            {
                ApplicationArea = all;
            }
            field("Order No"; Rec."Order No")
            {
                ApplicationArea = all;
            }

        }
    }

    actions
    {
        // Add changes to page actions here
        //ALLENick091023_start
        modify(PostBatch)
        {
            Visible = true; //Aashish
        }
        //ALLENick091023_End


    }



    var
        myInt: page "Purch. Invoice Subform";
}