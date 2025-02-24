codeunit 50006 PurchasePriceExt
{

    //Vendor Purchase Price By Location

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnUpdateDirectUnitCostOnBeforeFindPrice', '', true, true)]
    local procedure RunOnUpdateDirectUnitCostOnBeforeFindPrice(var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean; PurchaseHeader: Record "Purchase Header"; CallingFieldNo: Integer; xPurchaseLine: Record "Purchase Line"
     )
    var
        // tempPurchPrice: Record "Purchase Price";
        tempPurchPrice: Record TWCPurchasePrice;
    begin
        /*
        if PurchaseLine.Type = PurchaseLine.Type::Item then begin
            tempPurchPrice.Reset();
            tempPurchPrice.SetRange(tempPurchPrice."Item No.", PurchaseLine."No.");
            tempPurchPrice.SetRange(tempPurchPrice."Vendor No.", PurchaseHeader."Pay-to Vendor No.");
            tempPurchPrice.SetRange(tempPurchPrice.LocationCode, PurchaseHeader."Location Code");
            tempPurchPrice.SetFilter(tempPurchPrice."Starting Date", '<=%1', PurchaseHeader."Document Date");
            tempPurchPrice.SetFilter(tempPurchPrice."Ending Date", '=%1', 0D);
            IF tempPurchPrice.FindFirst() then begin
                IsHandled := true;
                PurchaseLine.Validate("Direct Unit Cost", tempPurchPrice."Direct Unit Cost");
                //Message(format(PurchaseLine."Direct Unit Cost"));
                //Message(Format(tempPurchPrice."Direct Unit Cost"));
            end
            else
                Message('Purchase price is not define for this location ,kindly check it with system adminstrator');
        end;
        */
        //Customization create with new table for purchase price
        if PurchaseLine.Type = PurchaseLine.Type::Item then begin
            tempPurchPrice.Reset();
            tempPurchPrice.SetRange(tempPurchPrice.PurchPricetype, tempPurchPrice.PurchPricetype::Item);
            tempPurchPrice.SetRange(tempPurchPrice."Item No.", PurchaseLine."No.");
            tempPurchPrice.SetRange(tempPurchPrice."Vendor No.", PurchaseHeader."Pay-to Vendor No.");
            tempPurchPrice.SetRange(tempPurchPrice."Location Code", PurchaseHeader."Location Code");
            IF PurchaseLine."Unit of Measure Code" <> '' Then
                tempPurchPrice.SetRange(tempPurchPrice."Unit of Measure Code", PurchaseLine."Unit of Measure Code");
            tempPurchPrice.SetFilter(tempPurchPrice."Starting Date", '<=%1', PurchaseHeader."Document Date");
            //   tempPurchPrice.SetFilter(tempPurchPrice."Ending Date", '=%1', 0D);
            tempPurchPrice.SetFilter(tempPurchPrice."Ending Date", '=%1|>=%2', 0D, PurchaseHeader."Document Date");
            IF tempPurchPrice.FindFirst() then begin
                IsHandled := true;
                PurchaseLine.Validate("Direct Unit Cost", tempPurchPrice."Direct Unit Cost");
                //Message(format(PurchaseLine."Direct Unit Cost"));
                //Message(Format(tempPurchPrice."Direct Unit Cost"));
            end
            else begin
                IF Not PurchaseHeader.LocalPurchase then
                    Message('Purchase price is not define for this location ,kindly check it with system adminstrator');
            end;
        end;



    end;


    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeUpdateDirectUnitCost', '', true, true)]
    local procedure RunOnBeforeUpdateDirectUnitCost(var PurchLine: Record "Purchase Line"; xPurchLine: Record "Purchase Line";
    CalledByFieldNo: Integer; CurrFieldNo: Integer; var Handled: Boolean)
    var
        // tempPurchPrice: Record "Purchase Price";
        tempTwcPurchPrice: Record TWCPurchasePrice;
        TempPurchHeader: Record "Purchase Header";
    begin
        TempPurchHeader.Reset();
        TempPurchHeader.setrange(TempPurchHeader."No.", PurchLine."Document No.");
        IF TempPurchHeader.FindFirst() then;


        if PurchLine.Type = PurchLine.Type::"Fixed Asset" then begin

            TempPurchHeader.TestField(TempPurchHeader."Posting Date");

            tempTwcPurchPrice.Reset();
            tempTwcPurchPrice.SetRange(tempTwcPurchPrice.PurchPricetype, tempTwcPurchPrice.PurchPricetype::"Fixed Asset");
            tempTwcPurchPrice.SetRange(tempTwcPurchPrice."Item No.", PurchLine."No.");
            tempTwcPurchPrice.SetRange(tempTwcPurchPrice."Vendor No.", TempPurchHeader."Pay-to Vendor No.");
            tempTwcPurchPrice.SetRange(tempTwcPurchPrice."Location Code", TempPurchHeader."Location Code");
            tempTwcPurchPrice.SetFilter(tempTwcPurchPrice."Starting Date", '<=%1', TempPurchHeader."Posting Date");
            tempTwcPurchPrice.SetFilter(tempTwcPurchPrice."Ending Date", '=%1|>=%2', 0D, TempPurchHeader."Posting Date");
            IF tempTwcPurchPrice.FindFirst() then begin
                Handled := true;
                PurchLine.Validate("Direct Unit Cost", tempTwcPurchPrice."Direct Unit Cost");
                //Message(format(PurchaseLine."Direct Unit Cost"));
                //Message(Format(tempPurchPrice."Direct Unit Cost"));
            end
            else
                Message('Purchase price is not define for this location ,kindly check it with system adminstrator');
        end;
    End;




    //Vendor Purchase Price By Location


    var
        myInt: Integer;
}