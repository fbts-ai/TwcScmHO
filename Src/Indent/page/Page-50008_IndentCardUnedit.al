page 50008 IndentCardunedit
{
    PageType = Card;
    //ApplicationArea = All;
    //  UsageCategory = Lists;
    SourceTable = IndentHeader;
    Caption = 'Indent Card';
    PromotedActionCategories = 'New," "," ",Process,Approval';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field("To Location code"; Rec."To Location code")
                {
                    ApplicationArea = ALL;
                    Editable = false;
                }
                field("To Location Name"; Rec."To Location Name")
                {
                    ApplicationArea = all;

                }

                field("From Location Code"; Rec."From Location Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("From Location Name"; Rec."From Location Name")
                {
                    ApplicationArea = all;
                    Visible = false;
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field(DepartmentCode; Rec."DepartmentCode")
                {
                    ApplicationArea = All;
                    Caption = 'Department Code';
                }
                field("Posting date"; Rec."Posting date")
                {
                    ApplicationArea = All;
                    Caption = 'Indent Date';

                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    Caption = 'Created Date';
                    Editable = false;
                }
                field("CreatedBy"; Rec."CreatedBy")
                {
                    ApplicationArea = All;
                    Caption = 'Created By';
                    Editable = false;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field("Main Indent No."; rec."Main Indent No.")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Sub-Indent"; rec."Sub-Indent")
                {
                    ApplicationArea = all;
                    Editable = false;
                }



            }
            part(IndentLine; "Indent Line unedit")
            {
                ApplicationArea = all;
                SubPageLink = "DocumentNo." = field("No.");
                UpdatePropagation = Both;
                Editable = false;
                // Editable = rec.Status = rec.Status::Open;


            }


        }
        area(Factboxes)
        {

        }
    }

    var
        IndentHdr: Record IndentHeader;
    // end;
}