pageextension 50148 StockkeepingLists extends "Stockkeeping Unit List" //PT-FBTS 180225 
{
    layout
    {
        // Add changes to page layout here
        //PT-FBTS 180225 

        // modify("Location Code")
        // {
        //     // trigger OnAfterValidate()
        //     // var
        //     //     LocationRec: Record Location;
        //     // begin
        //     //     if LocationRec.Get(Rec."Location Code") then
        //     //         Rec."Location Name" := LocationRec.Name;
        //     // end;
        // }
        addafter("Location Code")
        {
            field("Location Name"; Rec."Location Name")
            {
                ApplicationArea = all;
            }
        }

        addafter("Replenishment System")
        {
            field("Unit Cost"; Rec."Unit Cost")
            {
                ApplicationArea = all;
            }
            field("Base Unit of Measure"; Rec."Base Unit of Measure")
            {
                ApplicationArea = all;
            }

            //PT-FBTS 180225 

        }
    }
    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;

    // trigger OnAfterGetCurrRecord()
    // var
    //     LocationRec: Record Location;
    // begin
    //     if LocationRec.Get(Rec."Location Code") then
    //         Rec."Location Name" := LocationRec.Name;
    // end;
}