pageextension 50143 "State Ext" extends States
{
    layout
    {
        addafter("State Code for eTDS/TCS")
        {
            field("State Code (Einvoice)"; Rec."State Code (Einvoice)")
            {
                ApplicationArea = all;
            }

        }
    }
}
