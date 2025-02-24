page 50096 TwcTransferOrderLineList
{
    PageType = List;
    Caption = 'Twc Transfer Order List';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Transfer Line";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    QueryCategory = 'Twc Transfer Order List';
    RefreshOnActivate = true;



    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("No."; Rec."Document No.")
                {
                    caption = 'Transfer Order No.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the item that will be transferred.';

                }
                field(Description; Description)
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies a description of the entry.';
                }

                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity of the item that will be processed as the document stipulates.';
                }
                field("Transfer-from Code"; Rec."Transfer-from Code")
                {
                    Caption = 'Transfer-from Code';
                }
                Field(transferFromName; transferFromName)
                {
                    Caption = 'Transfer-from Name';
                }
                //  field(;rec.transfer)
                field("Transfer-to Code"; Rec."Transfer-to Code")
                {
                    Caption = '"Transfer-to Code';
                }
                field(transfertoName; transfertoName)
                {
                    Caption = 'Transfer-To Name';
                }

                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                //added by Mahendra 14 Aug
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    Editable = false;
                }

                field("Qty. to Ship"; Rec."Qty. to Ship")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specifies the quantity of items that remain to be shipped.';
                }
                field("Quantity Shipped"; Rec."Quantity Shipped")
                {
                    ApplicationArea = All;

                    ToolTip = 'Specifies how many units of the item on the line have been posted as shipped.';


                }
                field("Qty. to Receive"; Rec."Qty. to Receive")
                {
                    ApplicationArea = Location;
                    BlankZero = true;

                }
                field("Quantity Received"; Rec."Quantity Received")
                {
                    ApplicationArea = Location;
                    BlankZero = true;
                    ToolTip = 'Specifies how many units of the item on the line have been posted as received.';


                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when items on the document are shipped or were shipped. A shipment date is usually calculated from a requested delivery date plus lead time.';
                }
                field("Receipt Date"; Rec."Receipt Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date that you expect the transfer-to location to receive the shipment.';
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

    trigger OnOpenPage()
    var
        TempuserSetup: Record "User Setup";
    begin
        IF TempuserSetup.Get(UserId) then;
        Rec.FilterGroup(2);
        Rec.SetRange("Transfer-from Code", TempuserSetup."Location Code");
        Rec.FilterGroup(0);
    end;

    trigger OnAfterGetCurrRecord()
    var
        templocation: Record Location;
    begin
        IF templocation.get(Rec."Transfer-from Code") Then;
        transferFromName := templocation.Name;
        IF templocation.get(Rec."Transfer-to Code") Then;
        transfertoName := templocation.Name;


    end;

    trigger OnAfterGetRecord()
    var
        templocation: Record Location;
    begin
        IF templocation.get(Rec."Transfer-from Code") Then;
        transferFromName := templocation.Name;
        IF templocation.get(Rec."Transfer-to Code") Then;
        transfertoName := templocation.Name;

    end;

    var
        myInt: Integer;
        transferFromName: Text[100];
        transfertoName: Text[100];
}