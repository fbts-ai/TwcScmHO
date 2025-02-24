pageextension 50107 PurchaseInvoicesExt extends 9308
{
    layout
    {
        // Add changes to page layout here

    }

    actions
    {
        // Add changes to page actions here
        //ALLENick091023_start
        modify(PostBatch)
        {
            Visible = false;
        }
        //ALLENick091023_End
    }

    var
        myInt: Integer;
}