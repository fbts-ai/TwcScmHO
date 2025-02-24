
//AJ_ALLE_22012024
page 50125 "Quarantine Discard"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Item Journal Line";
    SourceTableView = where("Journal Template Name" = filter('ICT'), "Journal Batch Name" = filter('QUARANTINE'));
    Permissions = tabledata "Item Ledger Entry" = rimd;
    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                // field(Select; rec.Select)
                // {
                //     ApplicationArea = all;
                // }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date for the entry.';
                    Editable = true;//PT-FBTS 12 02 2024
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the related document was created.';
                    Visible = false;
                    Editable = false;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Entry Type';
                    ToolTip = 'Specifies the type of transaction that will be posted from the item journal line.';
                    Visible = false;
                    Editable = false;
                }
                // field(EntryType; EntryType)
                // {
                //     ApplicationArea = Basic, Suite;
                //     Caption = 'Entry Type';
                //     ToolTip = 'Specifies the type of transaction that will be posted from the item journal line.';

                //     trigger OnValidate()
                //     begin
                //         Rec."Entry Type" := EntryType;
                //         CheckEntryType();
                //         Rec.Validate("Entry Type");
                //     end;
                // }
                // field("Price Calculation Method"; Rec."Price Calculation Method")
                // {
                //     Visible = ExtendedPriceEnabled;
                //     ApplicationArea = Basic, Suite;
                //     ToolTip = 'Specifies the method that will be used for price calculation in the journal line.';
                // }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number for the journal line.';
                    ShowMandatory = true;
                    Editable = false;
                }
                // field("Approval Status"; rec."Approval Status")
                // {
                //     ApplicationArea = all;
                // }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the item on the journal line.';

                    trigger OnValidate()
                    begin
                        // ItemNoOnAfterValidate();
                    end;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the item on the journal line.';
                    Editable = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the code for the inventory location where the item on the journal line will be registered.';
                    Editable = false;
                    trigger OnValidate()
                    var
                        Item: Record Item;
                        WMSManagement: Codeunit "WMS Management";
                    begin
                        if Item.Get("Item No.") then
                            if Item.IsNonInventoriableType() then
                                exit;
                        WMSManagement.CheckItemJnlLineLocation(Rec, xRec);
                    end;
                }
                field("Rejection Remarks"; rec."Rejection Remarks")
                {
                    ApplicationArea = all;
                }
                field(Remarks; rec.Remarks)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the bin where the items are picked or put away.';
                    Visible = false;
                }
                field("Salespers./Purch. Code"; Rec."Salespers./Purch. Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code for the salesperson or purchaser who is linked to the sale or purchase on the journal line.';
                    Visible = false;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the vendor''s or customer''s trade type to link transactions made for this business partner with the appropriate general ledger account according to the general posting setup.';
                    Visible = false;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the item''s product type to link transactions made for this item with the appropriate general ledger account according to the general posting setup.';
                    Visible = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of units of the item to be included on the journal line.';
                    Editable = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                    Editable = false;
                }
                field("Unit Amount"; Rec."Unit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the price of one unit of the item on the journal line.';
                    Editable = false;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line''s net amount.';
                    Editable = false;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the discount amount of this entry on the line.';
                    Editable = false;
                }
                field("Indirect Cost %"; Rec."Indirect Cost %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the percentage of the item''s last purchase cost that includes indirect costs, such as freight that is associated with the purchase of the item.';
                    Visible = false;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the cost of one unit of the item or resource on the line.';
                    Editable = false;
                }
                field("Applies-to Entry"; Rec."Applies-to Entry")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the quantity on the journal line must be applied to an already-posted entry. In that case, enter the entry number that the quantity will be applied to.';
                    Editable = false;
                }
                field("Applies-from Entry"; Rec."Applies-from Entry")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the outbound item ledger entry, whose cost is forwarded to the inbound item ledger entry.';
                    Visible = false;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = BasicEU, BasicNO;
                    ToolTip = 'Specifies the type of transaction that the document represents, for the purpose of reporting to INTRASTAT.';
                    Visible = false;
                }
                field("Transport Method"; Rec."Transport Method")
                {
                    ApplicationArea = BasicEU, BasicNO;
                    ToolTip = 'Specifies the transport method, for the purpose of reporting to INTRASTAT.';
                    Visible = false;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region of the address.';
                    Visible = false;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reason code, a supplementary source code that enables you to trace the entry.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = true;
                    Editable = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = true;
                    Editable = false;
                }
                // field(LotNo; rec.LotNo)
                // {
                //     ApplicationArea = all;
                //     Editable = false;
                // }

            }

        }
    }

    actions
    {
        area(Processing)
        {
            // action(Approve)
            // {
            //     ApplicationArea = All;

            //     trigger OnAction();
            //     begin

            //     end;
            // }
            action(Reject)
            {
                ApplicationArea = All;

                trigger OnAction();
                Var
                    ItemLedgerEntry: Record "Item Ledger Entry";
                    ReservationEntry: Record "Reservation Entry";
                begin
                    if rec."Rejection Remarks" = '' then Error('Rejection Remarks can not be Empty');
                    // rec."Approval Status" := rec."Approval Status"::Rejected;
                    ItemLedgerEntry.SetRange("Entry No.", Rec."ILE Entry No");
                    if ItemLedgerEntry.FindFirst() then begin
                        ItemLedgerEntry.Completed := false;
                        ItemLedgerEntry.Modify();
                    end;
                    ReservationEntry.SetRange("ILE No.", Rec."ILE Entry No");
                    if ReservationEntry.FindFirst() then
                        ReservationEntry.Delete();
                    rec.Delete();
                end;
            }
            action(Approve)
            {
                ApplicationArea = All;

                trigger OnAction();
                var
                    ItemJounline: Record "Item Journal Line";
                begin
                    //SetSelectionFilter(Rec);
                    ItemJounline.SetRange("ILE Entry No", Rec."ILE Entry No");
                    if ItemJounline.FindFirst() then
                        CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post", ItemJounline);
                end;
            }
        }
    }


    trigger OnOpenPage()
    var
        usersetup: Record "User Setup";
    begin
        usersetup.Get(UserId);
        rec.SetFilter(Approver, '%1', usersetup."User ID");
        rec.SetFilter("Entry Type", '%1', Rec."Entry Type"::"Negative Adjmt.");


    end;

    var
        test: Codeunit 22;
}