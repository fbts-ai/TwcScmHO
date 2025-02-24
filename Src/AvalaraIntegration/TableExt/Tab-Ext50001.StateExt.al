tableextension 50001 "State Ext" extends State
{
    fields
    {
        field(50000; "State Code (Einvoice)"; Code[10])
        {
            DataClassification = ToBeClassified;
        }

    }
}
