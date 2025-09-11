page 50135 ConsumptionCard
{
    PageType = Card;
    //ApplicationArea = All;
    //UsageCategory = Administration;
    SourceTable = ReplacementDiallingEntry;
    Caption = 'Replacement & Dialling Entry';
    layout
    {
        area(Content)
        {

            group(GroupName)
            {
                Editable = EditBool;
                field("No."; "No.")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Posting date"; "Posting date")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Created Date"; "Created Date")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(CreatedBy; CreatedBy)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
            }
            part(ConsumptionLine; ConsumptionSubfrom)
            {
                ApplicationArea = all;
                SubPageLink = "DocumentNo." = field("No.");
                UpdatePropagation = Both;
                Editable = EditBool;
                // Enabled = ;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Post)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Post;
                Caption = 'Post';
                Visible = Posted;
                trigger OnAction()
                var
                    ConsLine: Record ConsumptionLine;
                    Posted: Boolean;
                    BOMCompRec: Record "BOM Component";
                    ItemJnlLine: Record "Item Journal Line";
                    ItemJnlTemplate: Code[10];
                    ItemJnlBatch: Code[10];
                    QtyPer: Decimal;
                    RequiredQty: Decimal;
                    ItemNo: Code[20];
                    ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
                    NextLineNo: Integer;
                begin
                    ItemJnlTemplate := 'ITEM';
                    ItemJnlBatch := 'DEFAULT';
                    if Rec.Status = Rec.Status::Posted then
                        Error('Do not post this document doncuemt is Already Posted');
                    ConsLine.Reset();
                    ConsLine.SetRange("DocumentNo.", Rec."No.");
                    ConsLine.SetRange(Remarks, ConsLine.Remarks);
                    if ConsLine.FindSet() then
                        Error('Please Select Remarks %1', ConsLine."Item Code");

                    ConsLine.Reset();
                    ConsLine.SetRange("DocumentNo.", rec."No.");
                    if not ConsLine.FindFirst() then
                        //if not ConsLine."DocumentNo."then
                            Error('Please Select Item No. is blank');

                    ConsLine.Reset();
                    ConsLine.SetRange("DocumentNo.", Rec."No.");
                    ConsLine.SetRange("Reason Code", ConsLine."Reason Code"::Replacement);
                    ConsLine.SetRange("Original Bill No", '');
                    if ConsLine.FindSet() then
                        Error('Please enter Original Bill No %1', ConsLine."Item Code");
                    ConsLine.Reset();
                    ConsLine.SetRange("DocumentNo.", Rec."No.");
                    if ConsLine.FindSet() then
                        repeat
                            Clear(QtyPer);
                            Clear(ItemNo);
                            Clear(RequiredQty);
                            Clear(NextLineNo);
                            BOMCompRec.Reset();
                            BOMCompRec.SetRange("Parent Item No.", ConsLine."Item Code");
                            //BOMCompRec.SetRange("Assembly BOM", true);
                            if BOMCompRec.FindSet() then
                                repeat
                                    QtyPer := BOMCompRec."Quantity per";
                                    ItemNo := BOMCompRec."No.";
                                    RequiredQty := ConsLine.Quantity * QtyPer;
                                    //Message('%1', ItemNo);
                                    NextLineNo := GetNextLineNo(ItemJnlTemplate, ItemJnlBatch);
                                    Clear(ItemJnlLine);
                                    ItemJnlLine.Init();
                                    ItemJnlLine.Validate("Journal Template Name", ItemJnlTemplate);
                                    ItemJnlLine.Validate("Journal Batch Name", ItemJnlBatch);
                                    ItemJnlLine.Validate("Line No.", NextLineNo);
                                    ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");
                                    ItemJnlLine.Validate("Document No.", Rec."No.");
                                    ItemJnlLine.Validate("Item No.", ItemNo);
                                    ItemJnlLine.Validate(Description, BOMCompRec.Description);
                                    //ItemJnlLine.Validate(Remarks, Format(ConsLine.Remarks));
                                    ItemJnlLine.Validate(Remarks, Format(ConsLine."Reason Code"));
                                    ItemJnlLine.Validate("Posting Date", Rec."Posting Date");
                                    ItemJnlLine.Validate("Location Code", Rec."Location Code");
                                    ItemJnlLine.Validate("Unit of Measure Code", BOMCompRec."Unit of Measure Code");
                                    ItemJnlLine.Validate(Quantity, RequiredQty);
                                    ItemJnlLine.Insert(true);
                                    ItemJnlPostLine.RunWithCheck(ItemJnlLine);

                                until BOMCompRec.Next() = 0;

                            Rec.Status := Rec.Status::Posted;
                            Rec.Exploed := true;
                            Message('Consumption Posted successfully. Item Ledger Entries created.');
                        until ConsLine.Next() = 0;



                    ItemJnlLine.Reset();
                    ItemJnlLine.SetRange("Document No.", Rec."No.");
                    if ItemJnlLine.FindFirst() then begin
                        ItemJnlLine.DeleteAll();
                    end;


                    CurrPage.Close();//Gaurav_FBTS 090125
                end;
            }

        }
    }
    var
        EditBool: Boolean;
        Posted: Boolean;

    local procedure GetNextLineNo(TemplateName: Code[10]; BatchName: Code[10]): Integer
    var
        ItemJnlLineLocal: Record "Item Journal Line";
        NewLineNo: Integer;
    begin
        ItemJnlLineLocal.Reset();
        ItemJnlLineLocal.SetRange("Journal Template Name", TemplateName);
        ItemJnlLineLocal.SetRange("Journal Batch Name", BatchName);
        if ItemJnlLineLocal.FindLast() then
            NewLineNo := ItemJnlLineLocal."Line No." + 10000
        else
            NewLineNo := 10000;
        exit(NewLineNo);
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec.Status = Rec.Status::Open then Begin
            CurrPage.Editable(true);
        End
        Else
            CurrPage.Editable(False);
        if Rec.Exploed then
            EditBool := false
        else
            EditBool := true;
    end;


    trigger OnAfterGetCurrRecord()
    begin
        if Rec.Status = Rec.Status::Open then Begin
            CurrPage.Editable(true);
        End
        Else
            CurrPage.Editable(False);
        if Rec.Exploed then
            EditBool := false
        else
            EditBool := true;
    end;


    trigger OnDeleteRecord(): Boolean;
    var
        myInt: Integer;
    begin
        if Rec.Status = Rec.Status::Posted then
            Error('You can not Delete this Document is Posted');
    end;

    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        if Rec.Status = Rec.Status::Posted then
            Posted := false
        else
            Posted := true;
    end;


}