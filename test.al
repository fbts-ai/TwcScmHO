pageextension 50150 cust extends "Customer List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter("&Customer")
        {
            action("Process Order")
            {
                ApplicationArea = All;
                PromotedCategory = Process;
                Promoted = true;
                Image = Process;
                trigger OnAction()
                var
                    test: Codeunit 50004;
                    JobQueueEntry: Record "Job Queue Entry";
                    job: Record "Job Queue Log Entry";
                begin

                    //  SplitValues
                    //test.OnBeforeModifyLogEntrycaluclatestatment(job, JobQueueEntry);
                    //ConvertBase16('6fc2c6e4d35bf9e515d7cea5321e02fed64d4d5234955f03cec7e9c705fc1c13');
                    Message(ConvertBase16('{"aggregatorId": "J_00038", "callbackURL": "https://qa.phicommerce.com/rpos/api/invoice/createinvoice","chargeAmount": "315.00","currencyCode": "356","desc": "Invoice","customerMobileNo": "","posAppId": "SBD0001","posTillNo": "S052P3","referenceNo": "0000S052P3000001184","storeCode": "BIAL0002"}'));
                end;
            }
        }
    }
    procedure SplitValues(DelimitedText: Text)
    var
        UniqueValues: List of [Text];

        value: Text;
    begin
        DelimitedText := '12,34,56,24|12,56,89,56,23|12,34,22,34';
        UniqueValues := SplitUniqueValues(DelimitedText);

        foreach value in UniqueValues do
            Message(value);
    end;

    local procedure SplitUniqueValues(DelimitedText: Text): List of [Text]
    var
        UniqueValues: List of [Text];
        Values: List of [Text];
        Delimiters: Text;
        value: Text;
    begin
        Delimiters := ', |';
        Values := DelimitedText.Split(Delimiters.Split(' '));
        foreach value in Values do
            if not UniqueValues.Contains(value) then
                UniqueValues.Add(value);

        exit(UniqueValues);
    end;

    LOCAL procedure ConvertBase16(theInput: Text[512]) theOutput: Text[1024]
    var
        aIndex: Integer;
        aInt, aLeft, aRight : Integer;
    begin
        FOR aIndex := 1 TO STRLEN(theInput) DO BEGIN
            aInt := theInput[aIndex];
            aLeft := ROUND(aInt / 16, 1, '<');
            aRight := aInt MOD 16;
            theOutput += HexValue(aLeft) + HexValue(aRight);
        END;
    end;


    LOCAL procedure HexValue(theValue: Integer): Text[1]
    begin
        CASE theValue OF
            0 .. 9:
                EXIT(FORMAT(theValue));
            10:
                EXIT('A');
            11:
                EXIT('B');
            12:
                EXIT('C');
            13:
                EXIT('D');
            14:
                EXIT('E');
            15:
                EXIT('F');
        END;
    end;

    var
        myInt: Integer;
}