pageextension 50187 AssemblyOrdersExt extends "Assembly Orders"
{
    layout
    {
        // Add changes to page layout here
        addafter("Assemble to Order")     //PT-FBTS Ticket-568
        {
            field("Order Posted"; Rec."Order Posted")
            {
                ApplicationArea = all;
            }
        }
        //PT-FBTS Ticket-568
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}