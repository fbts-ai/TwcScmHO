codeunit 50120 deletecodeunit
{
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;

    [EventSubscriber(ObjectType::Page, page::"Location List", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent41(var AllowDelete: Boolean; var Rec: Record Location)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete location list.');
    end;


    [EventSubscriber(ObjectType::Page, Page::"Location List", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent1()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin
        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission to Insert.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Location List", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent(var Rec: Record Location)
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin
            Error('You do not have a permission to open.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Location List", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent(var AllowModify: Boolean; var Rec: Record Location; var xRec: Record Location)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    //AssemblyBom

    [EventSubscriber(ObjectType::Page, Page::"Assembly BOM", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent42(var AllowDelete: Boolean; var Rec: Record "BOM Component")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Assembly BOM.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Assembly BOM", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent0()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin
        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Assembly BOM", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent1(var Rec: Record "BOM Component")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin
            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Assembly BOM", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent1(var AllowModify: Boolean; var Rec: Record "BOM Component"; var xRec: Record "BOM Component")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    //Customer

    [EventSubscriber(ObjectType::Page, Page::"Customer List", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent1(var AllowDelete: Boolean; var Rec: Record Customer)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Customer list.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Customer List", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent2()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin
        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Customer List", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent2(var Rec: Record Customer)
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin
            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Customer List", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent2(var AllowModify: Boolean; var Rec: Record Customer; var xRec: Record Customer)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    //No Series


    [EventSubscriber(ObjectType::Page, Page::"No. Series", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent43(var AllowDelete: Boolean; var Rec: Record "No. Series")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete No Series.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"No. Series", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent3()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin
        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"No. Series", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent3(var Rec: Record "No. Series")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin
            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"No. Series", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent3(var AllowModify: Boolean; var Rec: Record "No. Series"; var xRec: Record "No. Series")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;


    //No series Lines

    [EventSubscriber(ObjectType::Page, Page::"No. Series Lines", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent44(var AllowDelete: Boolean; var Rec: Record "No. Series Line")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete No series Lines.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"No. Series Lines", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent4()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin
        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"No. Series Lines", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent4(var Rec: Record "No. Series Line")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin
            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"No. Series Lines", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent4(var AllowModify: Boolean; var Rec: Record "No. Series Line"; var xRec: Record "No. Series Line")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    //UserSetup 

    [EventSubscriber(ObjectType::Page, Page::"User Setup", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent46(var AllowDelete: Boolean; var Rec: Record "User Setup")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Assembly BOM.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"User Setup", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent33()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin

        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission to create User Setup');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"User Setup", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent33(var Rec: Record "User Setup")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin
            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"User Setup", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent5(var AllowModify: Boolean; var Rec: Record "User Setup"; var xRec: Record "User Setup")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;
    //Inventory Posting Group      

    [EventSubscriber(ObjectType::Page, Page::"Inventory Posting Groups", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent47(var AllowDelete: Boolean; var Rec: Record "Inventory Posting Group")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Inventory Posting Groups.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Inventory Posting Groups", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent34()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin

        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Inventory Posting Groups", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent34(var Rec: Record "Inventory Posting Group")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin
            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Inventory Posting Groups", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent6(var AllowModify: Boolean; var Rec: Record "Inventory Posting Group"; var xRec: Record "Inventory Posting Group")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;
    //Gen Pro Post Group     

    [EventSubscriber(ObjectType::Page, Database::"Gen. Business Posting Group", 'OnDeleteRecordEvent', '', true, true)]
    local procedure OnBeforeDeleteEventIuom5()

    var
        usersetup: Record "User Setup";
    begin
        Usersetup.get(UserId);
        if Usersetup."Master Delete allow" = false then
            Error('Do not a Prmission delete please contect');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Gen. Business Posting Groups", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent48(var AllowDelete: Boolean; var Rec: Record "Gen. Business Posting Group")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete gen business posting groups.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Gen. Business Posting Groups", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent5()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin

        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Gen. Business Posting Groups", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent5(var Rec: Record "Gen. Business Posting Group")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin
            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Gen. Business Posting Groups", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent7(var AllowModify: Boolean; var Rec: Record "Gen. Business Posting Group"; var xRec: Record "Gen. Business Posting Group")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    //Lsc Cash Declaration setup


    [EventSubscriber(ObjectType::Page, Page::"LSC Cash Declaration Setup", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent49(var AllowDelete: Boolean; var Rec: Record "LSC Cash Declaration Setup")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Lsc Cash Declartion Setup.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Cash Declaration Setup", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent6()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin
        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Cash Declaration Setup", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent6(var Rec: Record "LSC Cash Declaration Setup")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin
            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Cash Declaration Setup", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent8(var AllowModify: Boolean; var Rec: Record "LSC Cash Declaration Setup"; var xRec: Record "LSC Cash Declaration Setup")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    //LSC Store Price Groups


    [EventSubscriber(ObjectType::Page, Page::"LSC Store Price Groups", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent51(var AllowDelete: Boolean; var Rec: Record "LSC Store Price Group")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Lsc Store Price Groups.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Store Price Groups", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent7()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin

        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Store Price Groups", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent7(var Rec: Record "LSC Store Price Group")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin
            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Store Price Groups", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent9(var AllowModify: Boolean; var Rec: Record "LSC Store Price Group"; var xRec: Record "LSC Store Price Group")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    //Dimensions 

    [EventSubscriber(ObjectType::Page, Page::"Dimension List", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent52(var AllowDelete: Boolean; var Rec: Record Dimension)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Dimension List.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Dimension List", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent8()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin

        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Dimension List", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent8(var Rec: Record Dimension)
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin
            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Dimension List", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent10(var AllowModify: Boolean; var Rec: Record Dimension; var xRec: Record Dimension)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    //Default dimension


    [EventSubscriber(ObjectType::Page, Page::"Default Dimensions", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent53(var AllowDelete: Boolean; var Rec: Record "Default Dimension")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Default Dimension.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Default Dimensions", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent9()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin

        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Default Dimensions", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent9(var Rec: Record "Default Dimension")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin
            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Default Dimensions", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent11(var AllowModify: Boolean; var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    //Dimension values

    [EventSubscriber(ObjectType::Page, Page::"Dimension Values", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent54(var AllowDelete: Boolean; var Rec: Record "Dimension Value")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Dimension Value.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Dimension Values", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent35()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin

        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Dimension Values", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent35(var Rec: Record "Dimension Value")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin
            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Dimension Values", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent12(var AllowModify: Boolean; var Rec: Record "Dimension Value"; var xRec: Record "Dimension Value")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;
    //Inventory posting setup      

    [EventSubscriber(ObjectType::Page, Page::"Inventory Posting Setup", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent55(var AllowDelete: Boolean; var Rec: Record "Inventory Posting Setup")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Inventory Posting Setup.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Inventory Posting Setup", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent36()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin
        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Inventory Posting Setup", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent36(var Rec: Record "Inventory Posting Setup")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin
            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Inventory Posting Setup", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent13(var AllowModify: Boolean; var Rec: Record "Inventory Posting Setup"; var xRec: Record "Inventory Posting Setup")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;
    //production bom version      


    [EventSubscriber(ObjectType::Page, Page::"Prod. BOM Version List", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent56(var AllowDelete: Boolean; var Rec: Record "Production BOM Version")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Prod. BOM Version List.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Prod. BOM Version List", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent10()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin

        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Prod. BOM Version List", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent10(var Rec: Record "Production BOM Version")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin
            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Prod. BOM Version List", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent14(var AllowModify: Boolean; var Rec: Record "Production BOM Version"; var xRec: Record "Production BOM Version")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    //Journal voucher posting setup


    [EventSubscriber(ObjectType::Page, Page::"Journal Voucher Posting Setup", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent57(var AllowDelete: Boolean; var Rec: Record "Journal Voucher Posting Setup")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Journal Voucher Posting Setup.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Journal Voucher Posting Setup", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent11()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Journal Voucher Posting Setup", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent11(var Rec: Record "Journal Voucher Posting Setup")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Journal Voucher Posting Setup", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent15(var AllowModify: Boolean; var Rec: Record "Journal Voucher Posting Setup"; var xRec: Record "Journal Voucher Posting Setup")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    //Lsc Tender Type Card


    [EventSubscriber(ObjectType::Page, Page::"LSC Tender Type List", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent58(var AllowDelete: Boolean; var Rec: Record "LSC Tender Type")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete LSC Tender Type List.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Tender Type List", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent12()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Tender Type List", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent12(var Rec: Record "LSC Tender Type")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Tender Type List", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent16(var AllowModify: Boolean; var Rec: Record "LSC Tender Type"; var xRec: Record "LSC Tender Type")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    //Sales prize list

    [EventSubscriber(ObjectType::Page, Page::"Sales Price List", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent61(var AllowDelete: Boolean; var Rec: Record "Price List Header")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Sales Price List.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Price List", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent37()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Price List", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent37(var Rec: Record "Price List Header")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Price List", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent17(var AllowModify: Boolean; var Rec: Record "Price List Header"; var xRec: Record "Price List Header")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;
    //Customer      



    [EventSubscriber(ObjectType::Page, Page::"Customer Card", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent62(var AllowDelete: Boolean; var Rec: Record Customer)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Customer Card.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Customer Card", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent13()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Customer Card", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent13(var Rec: Record Customer)
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Customer Card", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent18(var AllowModify: Boolean; var Rec: Record Customer; var xRec: Record Customer)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    //Item Card


    [EventSubscriber(ObjectType::Page, Page::"Item Card", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent63(var AllowDelete: Boolean; var Rec: Record Item)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Item Card.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Card", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent14()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Card", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent14(var Rec: Record Item)
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Card", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent19(var AllowModify: Boolean; var Rec: Record Item; var xRec: Record Item)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    //Chart of Accounts  


    [EventSubscriber(ObjectType::Page, Page::"Chart of Accounts", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent64(var AllowDelete: Boolean; var Rec: Record "G/L Account")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Chart Of Accounts.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Chart of Accounts", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent38()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Chart of Accounts", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent38(var Rec: Record "G/L Account")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Chart of Accounts", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent20(var AllowModify: Boolean; var Rec: Record "G/L Account"; var xRec: Record "G/L Account")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;
    //Custom bom list      

    [EventSubscriber(ObjectType::Page, Page::"Custom Bom List", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent65(var AllowDelete: Boolean; var Rec: Record "Custom BOM_Header")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Custom Bom List.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Custom Bom List", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent15()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Custom Bom List", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent15(var Rec: Record "Custom BOM_Header")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Custom Bom List", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent21(var AllowModify: Boolean; var Rec: Record "Custom BOM_Header"; var xRec: Record "Custom BOM_Header")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    //Custom bom


    [EventSubscriber(ObjectType::Page, Page::"Custom Bom", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent66(var AllowDelete: Boolean; var Rec: Record "Custom BOM Line")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Custom BOM.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Custom Bom", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent16()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Custom Bom", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent16(var Rec: Record "Custom BOM Line")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Custom Bom", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent22(var AllowModify: Boolean; var Rec: Record "Custom BOM Line"; var xRec: Record "Custom BOM Line")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;


    //FA posting Groups     

    [EventSubscriber(ObjectType::Page, Page::"FA Posting Groups", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent67(var AllowDelete: Boolean; var Rec: Record "FA Posting Group")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete FA Posting Groups.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"FA Posting Groups", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent17()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"FA Posting Groups", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent17(var Rec: Record "FA Posting Group")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"FA Posting Groups", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent23(var AllowModify: Boolean; var Rec: Record "FA Posting Group"; var xRec: Record "FA Posting Group")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;
    //Fixed Assest card     



    [EventSubscriber(ObjectType::Page, Page::"Fixed Asset Card", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent68(var AllowDelete: Boolean; var Rec: Record "Fixed Asset")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Fixed Asset Card.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Fixed Asset Card", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent18()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Fixed Asset Card", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent18(var Rec: Record "Fixed Asset")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Fixed Asset Card", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent24(var AllowModify: Boolean; var Rec: Record "Fixed Asset"; var xRec: Record "Fixed Asset")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;
    //Location card      



    [EventSubscriber(ObjectType::Page, Page::"Location Card", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent69(var AllowDelete: Boolean; var Rec: Record Location)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Location Card.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Location Card", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent19()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin
        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Location Card", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent19(var Rec: Record Location)
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission to View Location Master');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Location Card", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent25(var AllowModify: Boolean; var Rec: Record Location; var xRec: Record Location)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;
    //LSC Store Card      


    [EventSubscriber(ObjectType::Page, Page::"LSC Store Card", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent71(var AllowDelete: Boolean; var Rec: Record "LSC Store")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Lsc Store Card.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Store Card", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent20()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Store Card", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent20(var Rec: Record "LSC Store")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Store Card", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent26(var AllowModify: Boolean; var Rec: Record "LSC Store"; var xRec: Record "LSC Store")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    //Lsc Retail Item List

    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Item List", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent72(var AllowDelete: Boolean; var Rec: Record Item)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete LSC Retail Item List.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Item List", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent21()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Item List", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent21(var Rec: Record Item)
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Item List", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent27(var AllowModify: Boolean; var Rec: Record Item; var xRec: Record Item)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    //LSC Retail item Card


    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Item Card", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent73(var AllowDelete: Boolean; var Rec: Record Item)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete LSC Retail Item Card.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Item Card", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent22()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Item Card", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent22(var Rec: Record Item)
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Item Card", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent28(var AllowModify: Boolean; var Rec: Record Item; var xRec: Record Item)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;
    //Lsc Store List     

    [EventSubscriber(ObjectType::Page, Page::"LSC Store List", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent74(var AllowDelete: Boolean; var Rec: Record "LSC Store")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete LSC Store List.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Store List", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent23()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Store List", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent23(var Rec: Record "LSC Store")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Store List", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent31(var AllowModify: Boolean; var Rec: Record "LSC Store"; var xRec: Record "LSC Store")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;
    //user Card      

    [EventSubscriber(ObjectType::Page, Page::"User Card", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent76(var AllowDelete: Boolean; var Rec: Record User)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete User Card.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"User Card", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent24()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"User Card", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent24(var Rec: Record User)
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"User Card", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent32(var AllowModify: Boolean; var Rec: Record User; var xRec: Record User)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;
    //Vat product posting groups      

    [EventSubscriber(ObjectType::Page, Page::"VAT Product Posting Groups", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent77(var AllowDelete: Boolean; var Rec: Record "VAT Product Posting Group")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Vat Product Posting Groups.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"VAT Product Posting Groups", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent25()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"VAT Product Posting Groups", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent25(var Rec: Record "VAT Product Posting Group")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"VAT Product Posting Groups", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent33(var AllowModify: Boolean; var Rec: Record "VAT Product Posting Group"; var xRec: Record "VAT Product Posting Group")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;
    //Lsc Retail Users     


    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Users", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent78(var AllowDelete: Boolean; var Rec: Record "LSC Retail User")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Lsc Retail Users.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Users", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent26()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Users", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent26(var Rec: Record "LSC Retail User")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Users", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent34(var AllowModify: Boolean; var Rec: Record "LSC Retail User"; var xRec: Record "LSC Retail User")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;
    //Prodcution order list      

    [EventSubscriber(ObjectType::Page, Page::"Production Order List", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent79(var AllowDelete: Boolean; var Rec: Record "Production Order")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Production Order List.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Production Order List", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent27()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Production Order List", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent27(var Rec: Record "Production Order")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Production Order List", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent35(var AllowModify: Boolean; var Rec: Record "Production Order"; var xRec: Record "Production Order")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    //production bom lines

    [EventSubscriber(ObjectType::Page, Page::"Production BOM Lines", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent81(var AllowDelete: Boolean; var Rec: Record "Production BOM Line")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Production BOM Lines.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Production BOM Lines", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent28()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Production BOM Lines", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent28(var Rec: Record "Production BOM Line")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Production BOM Lines", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent37(var AllowModify: Boolean; var Rec: Record "Production BOM Line"; var xRec: Record "Production BOM Line")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;
    //Production Bom      

    [EventSubscriber(ObjectType::Page, Page::"Production BOM", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent82(var AllowDelete: Boolean; var Rec: Record "Production BOM Header")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Production BOM.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Production BOM", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent29()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Production BOM", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent29(var Rec: Record "Production BOM Header")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Production BOM", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent38(var AllowModify: Boolean; var Rec: Record "Production BOM Header"; var xRec: Record "Production BOM Header")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;
    //Vendor Card     


    [EventSubscriber(ObjectType::Page, Page::"Vendor Card", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent83(var AllowDelete: Boolean; var Rec: Record Vendor)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Vendor.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Card", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent30()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Card", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent30(var Rec: Record Vendor)
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Card", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent39(var AllowModify: Boolean; var Rec: Record Vendor; var xRec: Record Vendor)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    //Vendor list


    [EventSubscriber(ObjectType::Page, Page::"Vendor Bank Account Card", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent(var AllowDelete: Boolean; var Rec: Record "Vendor Bank Account")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Vendor.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Bank Account Card", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent(var AllowInsert: Boolean)
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin
        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Bank Account Card", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEventVBA(var Rec: Record "Vendor Bank Account")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Bank Account Card", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEventVBA(var AllowModify: Boolean; var xRec: Record "Vendor Bank Account")
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor List", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent84(var AllowDelete: Boolean; var Rec: Record Vendor)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete Vendor list.');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor List", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent31()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin


        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor List", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent31(var Rec: Record Vendor)
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor List", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent40(var AllowModify: Boolean; var Rec: Record Vendor; var xRec: Record Vendor)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;
    //TwcPurchasePrices
    [EventSubscriber(ObjectType::Page, Page::TwcPurchasePrices, 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent85(var AllowDelete: Boolean; var Rec: Record TWCPurchasePrice)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Master Delete allow" then
            Error('You are not authorized to Delete TwcPurchasePrices.');
    end;

    [EventSubscriber(ObjectType::Page, Page::TwcPurchasePrices, 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent32()
    var
        UserSetup: Record "User Setup";
        EnableBool: Boolean;
    begin
        Usersetup.get(UserId);
        if Usersetup."Edit Master Enable" = false then begin
            Error('You Do not have permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::TwcPurchasePrices, 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent32(var Rec: Record TWCPurchasePrice)
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Edit Master view" = false then begin

            Error('You do not have a permission.');
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::TwcPurchasePrices, 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent41(var AllowModify: Boolean; var Rec: Record TWCPurchasePrice; var xRec: Record TWCPurchasePrice)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup."Allow Master Modification" then
            Error('You do not have permission to modify.');
    end;
    //Vendor Bank Account Details 
}