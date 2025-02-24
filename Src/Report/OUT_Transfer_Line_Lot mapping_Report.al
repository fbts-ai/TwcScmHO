report 50010 "Pick List TO Report"
{
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Pick List TO Report';
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'Src/Report/LotMappingReport.rdl';
    dataset
    {
        dataitem("Transfer Header"; "Transfer Header")
        {
            DataItemTableView = where("Completely Shipped" = filter(false), "PARTIAL Shipped" = filter(false), Hide = filter(false));

            dataitem("Transfer Line"; "Transfer Line")
            {
                //RequestFilterFields = "Transfer-from Code";
                DataItemLink = "Document No." = field("No.");
                DataItemLinkReference = "Transfer Header";
                column(Document_No_; "Document No.")
                { }
                column(Quantity; Quantity)
                {
                }
                column(Item_No_; "Item No.")
                {
                }
                column(Description; Description)
                {
                }
                column(FixedAssetNo; FixedAssetNo)
                { }
                column(Indent_Qty_; "Indent Qty.")
                { }
                column(ItemInventory; ItemInventory)
                { }
                column(Amount; Amount)
                { }
                column(Transfer_Price; "Transfer Price")
                { }
                column(GST_Credit; "GST Credit")
                { }
                column(Remarks; Remarks)
                { }
                column(Reserved_Quantity_Inbnd_; "Reserved Quantity Inbnd.")
                { }
                column(Qty__to_Ship; "Qty. to Ship")
                { }
                column(Reserved_Quantity_Shipped; "Reserved Quantity Shipped")
                { }
                column(Unit_of_Measure_Code; "Unit of Measure Code")
                { }
                column(Qty__per_Unit_of_Measure; "Qty. per Unit of Measure")
                { }
                column(Quantity_Shipped; "Quantity Shipped")
                { }
                column(Qty__to_Receive; "Qty. to Receive")
                { }
                column(Quantity_Received; "Quantity Received")
                { }
                column(Shipment_Date; "Shipment Date")
                { }
                column(Receipt_Date; "Receipt Date")
                { }
                column(Custom_Duty_Amount; "Custom Duty Amount")
                { }
                column(GST_Assessable_Value; "GST Assessable Value")
                { }
                column(GST_Group_Code; "GST Group Code")
                { }
                column(HSN_SAC_Code; "HSN/SAC Code")
                { }

                column(LOTNO; LOTNO)
                { }
                column(ItemNO; ItemNO)
                { }
                dataitem("Reservation Entry"; "Reservation Entry")
                {
                    DataItemLink = "Source ID" = field("Document No."), "Item No." = field("Item No.");
                    DataItemLinkReference = "Transfer Line";
                    column(Lot_No_; "Lot No.")
                    {
                    }
                    column(Qty; Quantity)
                    { }
                }
                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                end;



                trigger OnPostDataItem()
                var
                    myInt: Integer;
                begin

                end;
            }
            trigger OnPreDataItem()
            var
                myInt: Integer;
            begin
                Clear(LocationCode);

                TempuserSetup.Get(UserId);
                LocationCode := TempuserSetup."Location Code";
                "Transfer Header".SetRange("Transfer-from Code", LocationCode);



                //"Transfer Line".FilterGroup(2);
                ///"Transfer Line".SetRange("Transfer-from Code", LocationCode);
                //"Transfer Line".FilterGroup(0);
            end;
        }

    }

    requestpage
    {
        AboutTitle = 'Teaching tip title';
        AboutText = 'Teaching tip content';
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(LocationCode; LocationCode)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Locaton Code';
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(LayoutName)
                {
                    ApplicationArea = All;
                }
            }
        }
        trigger OnInit()
        var
            myInt: Integer;
        begin
            TempuserSetup.Get(UserId);
            LocationCode := TempuserSetup."Location Code";
        end;
    }
    var
        TrackingSpecification: Record "Tracking Specification";
        ILE_Temp: Record "Item Ledger Entry";
        ReservationEntry: Record "Reservation Entry";
        LOTNO: Code[20];
        ItemNO: Code[20];
        TempuserSetup: Record "User Setup";
        LocationCode: Code[20];
}