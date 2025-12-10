codeunit 50130 "ICT Functions_Custom"
{
    Access = Internal;

    var
        TempFieldRec: Record "Field" temporary;
        gConStrReady: Boolean;
        gConStrFrom: Text[250];
        gConStrTo: Text[250];
        Text001: Label 'Wrong filter';
        Text002: Label 'For option files enter its number, not text value';
        Text003: Label 'Not valid option no., valid no. are 0 to %1';
        Text004: Label 'Wrong date';
        Text005: Label 'Wrong integer';
        Text006: Label 'Wrong decimal';
        Text007: Label 'Wrong Boolean';
        Text008: Label 'Translation of decimal field';
        Text009: Label 'Translation of date field';
        Text010: Label 'Translation of time field';
        Text011: Label 'Translation of option field';
        Text012: Label 'Translation of boolean field';
        Text013: Label 'Translation of integer field';
        Text014: Label 'Translation of dateformule field';
        Text015: Label 'Translation of datetime field';

    procedure FormatFieldValue(TableNumber: Integer; var pFLdRef: FieldRef): Text[230]
    var
        FieldRec: Record "Field";
        xDate: Date;
        xTime: Time;
        xDateF: DateFormula;
        xDateTime: DateTime;
        xDecimal: Decimal;
        xCode: Code[101];
        xText: Text[250];
        xBoolean: Boolean;
        xInteger: Integer;
        xBigInteger: BigInteger;
        xOption: Option;
    begin
        if not TempFieldRec.Get(TableNumber, pFLdRef.Number) then begin
            FieldRec.Get(TableNumber, pFLdRef.Number);
            TempFieldRec := FieldRec;
            TempFieldRec.Insert();
        end;

        case TempFieldRec.Type of
            TempFieldRec.Type::Code:
                begin
                    ;
                    xCode := pFLdRef.Value;
                    exit(Code2Txt(xCode));
                end;
            TempFieldRec.Type::Text:
                begin
                    ;
                    xText := pFLdRef.Value;
                    exit(TEXT2TXT(xText));
                end;
            TempFieldRec.Type::Date:
                begin
                    ;
                    xDate := pFLdRef.Value;
                    exit(Date2Txt(xDate));
                end;
            TempFieldRec.Type::Time:
                begin
                    ;
                    xTime := pFLdRef.Value;
                    exit(Time2Txt(xTime));
                end;
            TempFieldRec.Type::Decimal:
                begin
                    ;
                    xDecimal := pFLdRef.Value;
                    exit(Dec2Txt(xDecimal, 5));
                end;
            TempFieldRec.Type::Boolean:
                begin
                    ;
                    xBoolean := pFLdRef.Value;
                    exit(Bool2Txt(xBoolean));
                end;
            TempFieldRec.Type::Integer:
                begin
                    ;
                    xInteger := pFLdRef.Value;
                    exit(Integer2Txt(xInteger));
                end;
            TempFieldRec.Type::BigInteger:
                begin
                    ;
                    xBigInteger := pFLdRef.Value;
                    exit(BigInteger2Txt(xBigInteger));
                end;
            TempFieldRec.Type::Option:
                begin
                    ;
                    xOption := pFLdRef.Value;
                    exit(Opt2Txt(xOption));
                end;
            TempFieldRec.Type::DateFormula:
                begin
                    ;
                    xDateF := pFLdRef.Value;
                    exit(DateF2Txt(xDateF));
                end;
            TempFieldRec.Type::DateTime:
                begin
                    ;
                    xDateTime := pFLdRef.Value;
                    exit(DateTime2Txt(xDateTime));
                end;
            else begin
                ;
                exit(Format(pFLdRef.Value) + ';');
            end;
        end;
    end;

    procedure GetFieldValue(TableNumber: Integer; var pFLdRef: FieldRef; var pLine: Text[250]; var pValue: Variant): Text[250]
    var
        FieldRec: Record "Field";
        lAnswer: Text[250];
        lValue: Text[250];
        lDateF: DateFormula;
    begin
        if not TempFieldRec.Get(TableNumber, pFLdRef.Number) then begin
            FieldRec.Get(TableNumber, pFLdRef.Number);
            TempFieldRec := FieldRec;
            TempFieldRec.Insert();
        end;

        case TempFieldRec.Type of
            TempFieldRec.Type::Code:
                pValue := Txt2Code(pLine, lAnswer);
            TempFieldRec.Type::Text:
                pValue := Txt2Txt(pLine, lAnswer);
            TempFieldRec.Type::Date:
                pValue := Txt2Date(pLine, lAnswer, pFLdRef.Name);
            TempFieldRec.Type::Time:
                pValue := Txt2Time(pLine, lAnswer, pFLdRef.Name);
            TempFieldRec.Type::Decimal:
                pValue := Txt2Dec(pLine, lAnswer, pFLdRef.Name, 5);
            TempFieldRec.Type::Boolean:
                pValue := Txt2Bool(pLine, lAnswer, pFLdRef.Name);
            TempFieldRec.Type::Integer:
                pValue := Txt2Integer(pLine, lAnswer, pFLdRef.Name);
            TempFieldRec.Type::BigInteger:
                pValue := Txt2BigInteger(pLine, lAnswer, pFLdRef.Name);
            TempFieldRec.Type::Option:
                pValue := Txt2Opt(pLine, lAnswer, pFLdRef.Name);
            TempFieldRec.Type::DateFormula:
                begin
                    ;
                    lValue := Txt2DateF(pLine, lAnswer, pFLdRef.Name);
                    if not Evaluate(lDateF, lValue) then
                        Evaluate(lDateF, '');
                    pValue := lDateF;
                end;
            TempFieldRec.Type::DateTime:
                begin
                    ;
                    pValue := Txt2DateTime(pLine, lAnswer, pFLdRef.Name);
                end;
            TempFieldRec.Type::GUID:
                begin
                    ;
                    pValue := Txt2GUID(pLine, lAnswer, pFLdRef.Name);
                end;
            TempFieldRec.Type::Media:
                begin
                    ;
                    pValue := Txt2GUID(pLine, lAnswer, pFLdRef.Name);
                end;
            TempFieldRec.Type::MediaSet:
                begin
                    ;
                    pValue := Txt2GUID(pLine, lAnswer, pFLdRef.Name);
                end;
            else
                pValue := Txt2Txt(pLine, lAnswer);
        end;

        exit(lAnswer);
    end;

    procedure GetConStr(var pConStrFrom: Text[250]; var pConStrTo: Text[250])
    var
        i: Integer;
        Ch: Char;
    begin
        if not gConStrReady then begin
            gConStrFrom := ';';
            gConStrTo := ' ';
            for i := 1 to 31 do begin
                Ch := i;
                gConStrFrom := gConStrFrom + Format(Ch);
                gConStrTo := gConStrTo + ' ';
            end;
            gConStrReady := true;
        end;

        pConStrFrom := gConStrFrom;
        pConStrTo := gConStrTo;
    end;

    procedure Dec2Txt(pDec: Decimal; pDecimalPlaces: Integer): Text[100]
    begin

        case pDecimalPlaces of
            0:
                pDec := Round(pDec, 1, '<');
            1:
                pDec := Round(pDec * 10, 1, '<');
            2:
                pDec := Round(pDec * 100, 1, '<');
            3:
                pDec := Round(pDec * 1000, 1, '<');
            4:
                pDec := Round(pDec * 10000, 1, '<');
            5:
                pDec := Round(pDec * 100000, 1, '<');
        end;

        exit(Format(pDec, 0, '<Sign><Integer><Decimals>') + ';');
    end;

    procedure Date2Txt(pDate: Date): Text[100]
    begin
        if pDate = 0D then
            exit(';')
        else
            exit(Format(pDate, 0, '<Day,2><Month,2><Year4>') + ';');
    end;

    procedure Time2Txt(pTime: Time): Text[100]
    var
        lTxt: Text[100];
    begin
        if pTime = 0T then
            exit('0;')
        else begin
            lTxt := Format(pTime, 0, '<Hours24,2><Minutes,2><Seconds,2>');
            lTxt := DelChr(lTxt, '<', ' ');
            if StrLen(lTxt) < 6 then
                lTxt := '0' + lTxt;
            exit(lTxt + ';');
        end;
    end;

    procedure Opt2Txt(pOption: Option): Text[100]
    var
        xInt: Integer;
    begin
        xInt := pOption;
        exit(Format(xInt, 0, '<Integer>') + ';');
    end;

    procedure Bool2Txt(pBoolean: Boolean): Text[100]
    begin
        exit(Format(pBoolean, 0, '<Number>') + ';');
    end;

    procedure Integer2Txt(pInteger: Integer): Text[100]
    begin
        exit(Format(pInteger, 0, '<Sign><Integer>') + ';');
    end;

    procedure BigInteger2Txt(pBigInteger: BigInteger): Text[100]
    begin
        exit(Format(pBigInteger, 0, '<Sign><Integer>') + ';');
    end;

    procedure TEXT2TXT(pText: Text[250]): Text[230]
    begin
        exit(Format(CleanUpString(CopyStr(pText, 1, 229)), 0, '<Text>') + ';');
    end;

    procedure Code2Txt(pCode: Code[100]): Text[101]
    begin
        exit(Format(CleanUpString(CopyStr(pCode, 1, 100)), 0, '<Text>') + ';');
    end;

    procedure DateF2Txt(pDateF: DateFormula): Text[100]
    begin
        exit(Format(pDateF, 0, 2) + ';');
    end;

    procedure DateTime2Txt(pDateTime: DateTime): Text[100]
    var
        lDate: Date;
        lTime: Time;
        lDateTxt: Text[30];
        lTimeTxt: Text[30];
    begin
        if pDateTime = 0DT then
            exit('0;')
        else begin
            lDate := DT2Date(pDateTime);
            lDateTxt := Format(lDate, 0, '<Day,2><Month,2><Year4>');
            lTime := DT2Time(pDateTime);
            lTimeTxt := Format(lTime, 0, '<Hours24,2><Minutes,2><Seconds,2>');
            lTimeTxt := DelChr(lTimeTxt, '<', ' ');
            if StrLen(lTimeTxt) < 6 then
                lTimeTxt := '0' + lTimeTxt;
            exit(lDateTxt + lTimeTxt + ';');
        end;
    end;

    procedure Txt2Dec(var pLine: Text[260]; var pErrorLine: Text[100]; pFieldName: Text[30]; pDecimalPlaces: Integer): Decimal
    var
        lAnswer: Decimal;
        lTxt: Text[260];
        lTxtHigh: Text[260];
        lLen: Integer;
        lDecHigh: Decimal;
    begin

        lTxt := '';
        if StrPos(pLine, ';') > 0 then begin
            ;
            lTxt := CopyStr(pLine, 1, StrPos(pLine, ';') - 1);
            pLine := CopyStr(pLine, StrPos(pLine, ';') + 1, 260);
            lLen := StrLen(lTxt);
        end;
        if lLen > 15 then begin
            ;
            lTxtHigh := CopyStr(lTxt, 1, lLen - 15);
            lTxt := CopyStr(lTxt, lLen - 15 + 1, 15);
        end;

        if Evaluate(lAnswer, lTxt) then begin
            ;
            case pDecimalPlaces of
                0:
                    lAnswer := lAnswer;
                1:
                    lAnswer := lAnswer / 10;
                2:
                    lAnswer := lAnswer / 100;
                3:
                    lAnswer := lAnswer / 1000;
                4:
                    lAnswer := lAnswer / 10000;
                5:
                    lAnswer := Round(lAnswer / 100000, 0.00001, '<');
            end;
            if lTxtHigh <> '' then begin
                ;
                if lTxtHigh = '-' then
                    lAnswer := -lAnswer
                else begin
                    lTxtHigh := lTxtHigh + CopyStr('00000000000000000', 1, 15 - pDecimalPlaces);
                    lDecHigh := 0;
                    if Evaluate(lDecHigh, lTxtHigh) then
                        lAnswer := lAnswer + lDecHigh;
                end;
            end;
        end
        else begin
            ;
            lAnswer := 0;
            pErrorLine := 'C01;' + Text008 + ' / ' + pFieldName + ' / ' + lTxt + ';';
        end;

        exit(lAnswer);
    end;

    procedure Txt2Date(var pLine: Text[260]; var pErrorLine: Text[100]; pFieldName: Text[30]): Date
    var
        lAnswer: Date;
        lTxt: Text[260];
        DD: Integer;
        MM: Integer;
        YY: Integer;
    begin

        lTxt := '';
        if StrPos(pLine, ';') > 0 then begin
            ;
            lTxt := CopyStr(pLine, 1, StrPos(pLine, ';') - 1);
            pLine := CopyStr(pLine, StrPos(pLine, ';') + 1, 260);
        end;
        if lTxt = '01010001' then
            lAnswer := 0D
        else begin
            if Evaluate(DD, CopyStr(lTxt, 1, 2)) then
                if Evaluate(MM, CopyStr(lTxt, 3, 2)) then
                    if Evaluate(YY, CopyStr(lTxt, 5, 4)) then
                        lAnswer := DMY2Date(DD, MM, YY);

            if (lAnswer = 0D) and (lTxt <> '') then begin
                ;
                lAnswer := 0D;
                pErrorLine := 'C02;' + Text009 + ' / ' + pFieldName + ' / ' + lTxt + ';';
            end;
        end;

        exit(lAnswer);
    end;

    procedure Txt2Time(var pLine: Text[260]; var pErrorLine: Text[100]; pFieldName: Text[30]): Time
    var
        lAnswer: Time;
        lTxt: Text[260];
    begin

        lTxt := '';
        if StrPos(pLine, ';') > 0 then begin
            ;
            lTxt := CopyStr(pLine, 1, StrPos(pLine, ';') - 1);
            pLine := CopyStr(pLine, StrPos(pLine, ';') + 1, 260);
        end;

        if not Evaluate(lAnswer, lTxt) then begin
            ;
            lAnswer := 0T;
            pErrorLine := 'C03;' + Text010 + ' / ' + pFieldName + ' / ' + lTxt + ';';
        end;

        if (lTxt = '0') then
            lAnswer := 0T;

        exit(lAnswer);
    end;

    procedure Txt2Opt(var pLine: Text[260]; var pErrorLine: Text[100]; pFieldName: Text[30]): Integer
    var
        lAnswer: Integer;
        lTxt: Text[260];
    begin

        lTxt := '';
        if StrPos(pLine, ';') > 0 then begin
            ;
            lTxt := CopyStr(pLine, 1, StrPos(pLine, ';') - 1);
            pLine := CopyStr(pLine, StrPos(pLine, ';') + 1, 260);
        end;

        if not Evaluate(lAnswer, lTxt) then begin
            ;
            lAnswer := 0;
            pErrorLine := 'C04;' + Text011 + ' / ' + pFieldName + ' / ' + lTxt + ';';
        end;
        exit(lAnswer);
    end;

    procedure Txt2Bool(var pLine: Text[260]; var pErrorLine: Text[100]; pFieldName: Text[30]): Boolean
    var
        lAnswer: Boolean;
        lTxt: Text[260];
    begin

        lTxt := '';
        if StrPos(pLine, ';') > 0 then begin
            ;
            lTxt := CopyStr(pLine, 1, StrPos(pLine, ';') - 1);
            pLine := CopyStr(pLine, StrPos(pLine, ';') + 1, 260);
        end;

        if not Evaluate(lAnswer, lTxt) then begin
            ;
            lAnswer := false;
            pErrorLine := 'C05;' + Text012 + ' / ' + pFieldName + ' / ' + lTxt + ';';
        end;
        exit(lAnswer);
    end;

    procedure Txt2Integer(var pLine: Text[260]; var pErrorLine: Text[100]; pFieldName: Text[30]): Integer
    var
        lAnswer: Integer;
        lTxt: Text[260];
    begin

        lTxt := '';
        if StrPos(pLine, ';') > 0 then begin
            ;
            lTxt := CopyStr(pLine, 1, StrPos(pLine, ';') - 1);
            pLine := CopyStr(pLine, StrPos(pLine, ';') + 1, 260);
        end;

        if not Evaluate(lAnswer, lTxt) then begin
            ;
            lAnswer := 0;
            pErrorLine := 'C06;' + Text013 + ' / ' + pFieldName + ' / ' + lTxt + ';';
        end;
        exit(lAnswer);
    end;

    procedure Txt2BigInteger(var pLine: Text[260]; var pErrorLine: Text[100]; pFieldName: Text[30]): BigInteger
    var
        lAnswer: BigInteger;
        lTxt: Text[260];
    begin
        lTxt := '';
        if StrPos(pLine, ';') > 0 then begin
            ;
            lTxt := CopyStr(pLine, 1, StrPos(pLine, ';') - 1);
            pLine := CopyStr(pLine, StrPos(pLine, ';') + 1, 260);
        end;

        if not Evaluate(lAnswer, lTxt) then begin
            ;
            lAnswer := 0;
            pErrorLine := 'C06;' + Text013 + ' / ' + pFieldName + ' / ' + lTxt + ';';
        end;
        exit(lAnswer);
    end;

    procedure Txt2Code(var pLine: Text[260]; var pErrorNr: Text[100]): Code[260]
    var
        lAnswer: Text[100];
    begin

        lAnswer := '';
        if StrPos(pLine, ';') > 0 then begin
            ;
            lAnswer := CopyStr(pLine, 1, StrPos(pLine, ';') - 1);
            if StrLen(lAnswer) > 230 then
                lAnswer := CopyStr(lAnswer, 1, 230);
            pLine := CopyStr(pLine, StrPos(pLine, ';') + 1, 260);
        end;

        exit(lAnswer);
    end;

    procedure Txt2Txt(var pLine: Text[260]; var pErrorNr: Text[100]): Text[260]
    var
        lAnswer: Text[260];
    begin

        lAnswer := '';
        if StrPos(pLine, ';') > 0 then begin
            ;
            lAnswer := CopyStr(pLine, 1, StrPos(pLine, ';') - 1);
            if StrLen(lAnswer) > 230 then
                lAnswer := CopyStr(lAnswer, 1, 230);
            pLine := CopyStr(pLine, StrPos(pLine, ';') + 1, 260);
        end;

        exit(lAnswer);
    end;

    procedure Txt2DateF(var pLine: Text[260]; var pErrorLine: Text[100]; pFieldName: Text[30]): Text[260]
    var
        lAnswer: Text[100];
        lDateF: DateFormula;
    begin

        lAnswer := '';
        if StrPos(pLine, ';') > 0 then begin
            ;
            lAnswer := CopyStr(pLine, 1, StrPos(pLine, ';') - 1);
            pLine := CopyStr(pLine, StrPos(pLine, ';') + 1, 260);
        end;

        if not Evaluate(lDateF, lAnswer) then begin
            ;
            lAnswer := '';
            pErrorLine := 'C07;' + Text014 + ' / ' + pFieldName + ' / ' + lAnswer + ';';
        end;

        exit(lAnswer);
    end;

    procedure Txt2DateTime(var pLine: Text[260]; var pErrorLine: Text[100]; pFieldName: Text[30]): DateTime
    var
        lAnswer: DateTime;
        lTxt: Text[260];
        lDate: Date;
        lTime: Time;
        DD: Integer;
        MM: Integer;
        YY: Integer;
    begin
        lTxt := '';
        if StrPos(pLine, ';') > 0 then begin
            ;
            lTxt := CopyStr(pLine, 1, StrPos(pLine, ';') - 1);
            pLine := CopyStr(pLine, StrPos(pLine, ';') + 1, 260);
        end;

        if lTxt = '01010001000000' then begin
            lDate := 0D;
            lTxt := '0';
        end else begin
            if Evaluate(DD, CopyStr(lTxt, 1, 2)) then
                if Evaluate(MM, CopyStr(lTxt, 3, 2)) then
                    if Evaluate(YY, CopyStr(lTxt, 5, 4)) then
                        lDate := DMY2Date(DD, MM, YY);
            if (lDate = 0D) and (lTxt <> '0') then
                pErrorLine := 'C08;' + Text015 + ' / ' + pFieldName + ' / ' + lTxt + ';';
        end;

        if (lTxt = '0') then
            lTime := 0T
        else
            if not Evaluate(lTime, CopyStr(lTxt, 9)) then
                pErrorLine := 'C08;' + Text015 + ' / ' + pFieldName + ' / ' + lTxt + ';';

        if pErrorLine = '' then
            lAnswer := CreateDateTime(lDate, lTime);

        exit(lAnswer);
    end;

    procedure Txt2GUID(var pLine: Text[260]; var pErrorLine: Text[100]; pFieldName: Text[30]): Guid
    var
        lAnswer: Guid;
        lTxt: Text[260];
    begin
        lTxt := '';
        if StrPos(pLine, ';') > 0 then begin
            lTxt := CopyStr(pLine, 1, StrPos(pLine, ';') - 1);
            pLine := CopyStr(pLine, StrPos(pLine, ';') + 1, 260);
        end;

        if not Evaluate(lAnswer, lTxt) then begin
            Clear(lAnswer);
            pErrorLine := 'C09;' + Text014 + ' / ' + pFieldName + ' / ' + lTxt + ';';
        end;

        exit(lAnswer);
    end;

    procedure ErrorCodes(pErrorLine: Text[250]; var pErrorNr: Code[3]; var pErrorDesc: Text[250]): Text[100]
    var
        lLen: Integer;
        lErrorLine: Text[260];
    begin
        pErrorNr := '';
        pErrorDesc := '';

        lErrorLine := pErrorLine;
        if pErrorLine <> '' then begin
            ;
            pErrorNr := CopyStr(pErrorLine, 1, StrPos(pErrorLine, ';') - 1);
            lErrorLine := CopyStr(lErrorLine, StrPos(pErrorLine, ';') + 1, 260);

            if lErrorLine <> '' then begin
                ;
                lLen := StrPos(lErrorLine, ';') - 1;
                if lLen < 1 then
                    lLen := 0;
                pErrorDesc := CopyStr(lErrorLine, 1, lLen);
            end;
        end;
    end;

    procedure CleanUpString(pString: Text[260]): Text[260]
    var
        lString: Text[260];
        ConStr1: Text[50];
        ConStr2: Text[50];
    begin
        lString := pString;

        GetConStr(ConStr1, ConStr2);
        lString := DelChr(ConvertStr(lString, ConStr1, ConStr2), '>', ' ');

        exit(lString);
    end;

    procedure ValidateFilter(pTableNo: Integer; pFieldNo: Integer; pFilter: Text[250]): Text[250]
    var
        FieldRec: Record "Field";
        xValue: Text[250];
        i: Integer;
        NextToken: Text[250];
        LastToken: Text[250];
        xFilter: Text[250];
    begin
        FieldRec.Get(pTableNo, pFieldNo);

        xFilter := '';
        for i := 1 to StrLen(pFilter) do begin
            if NextToken <> '' then begin
                if (NextToken = 'x') then begin
                    if (CopyStr(pFilter, i, 1) = '.') or (CopyStr(pFilter, i, 1) = '|') then
                        Error(Text001);
                end
                else
                    if CopyStr(pFilter, i, 1) <> NextToken then
                        Error(Text001);
            end;

            if CopyStr(pFilter, i, 1) = '.' then begin
                if LastToken <> '' then begin
                    if LastToken <> '|' then
                        Error(Text001);
                end;

                if NextToken <> '' then begin
                    NextToken := 'x';
                    LastToken := '.';
                    xFilter := xFilter + '..';
                end
                else begin
                    xFilter := xFilter + TestValue(FieldRec, xValue);
                    xValue := '';
                    NextToken := '.';
                end
            end
            else
                if CopyStr(pFilter, i, 1) = '|' then begin
                    LastToken := '|';
                    xFilter := xFilter + TestValue(FieldRec, xValue);
                    xValue := '';
                    NextToken := 'x';
                    xFilter := xFilter + '|';
                end
                else begin
                    xValue := xValue + CopyStr(pFilter, i, 1);
                    NextToken := '';
                end;
        end;

        if NextToken <> '' then
            Error(Text001);
        if xValue <> '' then
            xFilter := xFilter + TestValue(FieldRec, xValue);

        exit(xFilter);
    end;

    procedure TestValue(var pFieldRec: Record "Field"; pValue: Text[250]): Text[250]
    var
        xNumber: Integer;
        xDate: Date;
        xDecimal: Decimal;
        xBoolean: Boolean;
        xRecRef: RecordRef;
        xFieldRef: FieldRef;
        xOptionString: Text[250];
        xPreLen: Integer;
        xPostLen: Integer;
    begin
        case pFieldRec.Type of
            pFieldRec.Type::Option:
                begin
                    ;
                    if not Evaluate(xNumber, pValue) then
                        Error(Text002);

                    xRecRef.Open(pFieldRec.TableNo);
                    xFieldRef := xRecRef.Field(pFieldRec."No.");
                    xOptionString := xFieldRef.OptionMembers;
                    xPreLen := StrLen(xOptionString);
                    xOptionString := DelChr(xOptionString, '=', ',');
                    xPostLen := StrLen(xOptionString);
                    if (xNumber < 0) or (xNumber > (xPreLen - xPostLen)) then
                        Error(Text003, (xPreLen - xPostLen));

                    pValue := Format(xNumber);
                end;
            pFieldRec.Type::Date:
                begin
                    ;
                    if not Evaluate(xDate, pValue) then
                        Error(Text004);
                    pValue := Format(xDate, 0, '<Day,2><Month,2><Year4>');
                end;
            pFieldRec.Type::Integer:
                begin
                    ;
                    if not Evaluate(xNumber, pValue) then
                        Error(Text005);
                    pValue := Format(xNumber);
                end;
            pFieldRec.Type::Decimal:
                begin
                    ;
                    if not Evaluate(xDecimal, pValue) then
                        Error(Text006);
                    pValue := Format(xDecimal);
                end;
            pFieldRec.Type::Boolean:
                begin
                    ;
                    if not Evaluate(xBoolean, pValue) then
                        Error(Text007);
                    pValue := Format(xBoolean);
                end;
        end;

        exit(pValue);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnSetOrderAdjmtPropertiesOnBeforeSetCostIsAdjusted', '', false, false)]
    local procedure "Item Jnl.-Post Line_OnSetOrderAdjmtPropertiesOnBeforeSetCostIsAdjusted"(
        var InvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)";
    var ModifyOrderAdjmt: Boolean; var IsHandled: Boolean; OriginalPostingDate: Date)
    var
        ItemRec: Record Item;
    begin
        // ItemRec.GET(InvtAdjmtEntryOrder."Item No.");
        // IF ItemRec."Enable Manual Costing" THEN BEGIN
        IsHandled := true;
        // if InvtAdjmtEntryOrder."Cost adjusted Manual" then begin
        InvtAdjmtEntryOrder."Cost adjusted Manual" := true;
        InvtAdjmtEntryOrder."Cost is Adjusted" := true;
        ModifyOrderAdjmt := true;
        //end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnSetOrderAdjmtPropertiesOnBeforeSetAllowOnlineAdjustment', '', false, false)]
    local procedure "Item Jnl.-Post Line_OnSetOrderAdjmtPropertiesOnBeforeSetAllowOnlineAdjustment"(
        var InvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)";
        var ModifyOrderAdjmt: Boolean; var IsHandled: Boolean; OriginalPostingDate: Date)
    var
        ItemRec: Record Item;
    begin
        // ItemRec.GET(InvtAdjmtEntryOrder."Item No.");
        // IF ItemRec."Enable Manual Costing" THEN BEGIN
        IsHandled := true;
        InvtAdjmtEntryOrder."Allow online Adjust Manual" := true;
        InvtAdjmtEntryOrder."Allow Online Adjustment" := true;
        ModifyOrderAdjmt := true;
        //end;
    END;

}


