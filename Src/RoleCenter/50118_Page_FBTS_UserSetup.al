page 50117 "User Location" ///PT-FBTS- 19-06-2024
{
    Caption = 'User Location';
    PageType = List;
    ApplicationArea = All;
    //Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = Lists;
    MultipleNewLines = false;
    SourceTable = "User Setup";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = all;
                    Editable = true;
                    // AssistEdit = true;
                    // Importance = Promoted;
                    // Editable = false;
                    // ShowMandatory = true;
                    TableRelation = "User Location Link Table"."Location Code" where("User Id" = field("User ID"));


                    trigger OnValidate()///(var Text: Text): Boolean 
                    var
                        myInt: Integer;

                        userLocationLink: Record "User Location Link Table";
                    begin
                        if userLocationLink.Get(Rec."User ID", Rec."Location Code") then;
                        if (Rec."Location Code" <> userLocationLink."Location Code") then
                            Error('This User is not allow in this location');
                        if (Rec."Location Code" = '') then
                            Error('Please do not blank location');
                    end;


                    // trigger OnValidate() //(var Text: Text): Boolean///PT-FBTS 30-05-2024 
                    // var
                    //     userLocationLink: Record "User Location Link Table";
                    //     UserLocationLinkList: Page "User Location Link";
                    // begin
                    //     //Rec.FilterGroup(2);
                    //     userLocationLink.Reset();
                    //     userLocationLink.SetRange("User ID", Rec."User ID");

                    //     UserLocationLinkList.LookupMode(true);
                    //     UserLocationLinkList.SetTableView(userLocationLink);
                    //     IF UserLocationLinkList.RunModal() = Action::LookupOK then begin
                    //         UserLocationLinkList.SetSelectionFilter(userLocationLink);
                    //         IF userLocationLink.FindFirst() then begin
                    //             ///  Rec.FilterGroup(2);
                    //             Rec.Validate("Location Code", userLocationLink."Location Code");
                    //             // Rec.FilterGroup(0);
                    //         end;
                    //     end;
                    // end;
                }
            }
        }
        area(Factboxes)
        {

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
        UserSetup: Record "User Setup";
    begin
        UserSetup.GET(USERID);
        IF UserSetup."User ID" <> '' THEN BEGIN
            Rec.FILTERGROUP(2);
            Rec.SetRange("User ID", UserSetup."User ID");
            Rec.FILTERGROUP(0);
        end;
    end;

    trigger OnQueryClosePage(dd: Action): Boolean
    var
    //     userLocationLink: Record "User Location Link Table";
    begin
        rec.TestField("Location Code");
        //     userLocationLink.Reset();
        //     userLocationLink.SetRange("User ID", Rec."User ID");
        //     // userLocationLink.SetFilter("Location Code", '<>%1', Rec."Location Code");
        //     if userLocationLink.FindFirst() then begin
        //         //repeat
        //         if Rec."Location Code" <> userLocationLink."Location Code" then
        //             Error('Please Check user Location');
        //         //until userLocationLink.Next() = 0;
        //     end;


    end;

    trigger OnInsertRecord(LL: Boolean): Boolean
    var
        myInt: Integer;

        userLocationLink: Record "User Location Link Table";
    begin
        // userLocationLink.Reset();
        // userLocationLink.SetRange("User ID", Rec."User ID");
        // // userLocationLink.SetFilter("Location Code", '<>%1', Rec."Location Code");
        // if userLocationLink.FindFirst() then begin
        //     //repeat
        //     if Rec."Location Code" <> userLocationLink."Location Code" then
        //         Error('Please Check user Location');
        //     //until userLocationLink.Next() = 0;
        // end;
    end;

}