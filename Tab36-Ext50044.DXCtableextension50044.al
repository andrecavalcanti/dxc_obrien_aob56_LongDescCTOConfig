tableextension 50044 "DXCtableextension50044" extends "Sales Header" //36
{ 

  [Scope('Personalization')]
    procedure DXCPopulateCheckList();
    var
        CheckListLine : Record "Checklist Line";
        CheckListHeader : Record "Checklist Header";
        TextSplit : array [10] of Text;
        ATODescription : Text;
        i : Integer;
        NumberInsideParenthesis : Text;
        CodeOutsideParenthesis : Text;
        HeatModelNumber : Text;
        SalesLine : Record "Sales Line";
    begin

        // >> AOB-56

        SalesLine.SETRANGE("Document Type",SalesLine."Document Type"::Order);
        SalesLine.SETRANGE("Document No.","No.");
        SalesLine.SETRANGE(Type,SalesLine.Type::Item);
        SalesLine.SETFILTER("DXC ATO Description",'<>%1','');
        SalesLine.SETFILTER("Checklist No.",'<>%1','');
        IF SalesLine.FINDFIRST THEN REPEAT

          CheckListHeader.Reset;
          CheckListHeader.SETRANGE("No.",SalesLine."Checklist No.");
          CheckListHeader.FINDFIRST;

          ATODescription := SalesLine."DXC ATO Description";

          FOR i := 1 TO 10 DO
            TextSplit[i] := DXCSplitString(ATODescription,'-');

          COMPRESSARRAY(TextSplit);

          CheckListLine.SETRANGE("Document No.",CheckListHeader."No.");
          CheckListLine.SETRANGE("Checklist Type",CheckListHeader."Checklist Type");

          FOR i := 1 TO ARRAYLEN(TextSplit) DO BEGIN

            IF (TextSplit[i] <> '') THEN BEGIN
              CheckListLine.SETRANGE(Description);
              CheckListLine.SETRANGE("No.");
              CLEAR(HeatModelNumber);
              CLEAR(NumberInsideParenthesis);
              CLEAR(CodeOutsideParenthesis);

              IF (COPYSTR(TextSplit[i],1,3) = 'TES') OR (COPYSTR(TextSplit[i],1,3) = 'TS3') THEN BEGIN
                CheckListLine.SETRANGE(Description,'Heater Model Number');
                HeatModelNumber := TextSplit[i];
              END ELSE IF ((STRPOS(TextSplit[i],Text50000) <> 0) AND (STRPOS(TextSplit[i],Text50001) <> 0)) THEN BEGIN
                NumberInsideParenthesis := COPYSTR(TextSplit[i], STRPOS(TextSplit[i],Text50000) + 1, 1);
                CodeOutsideParenthesis := COPYSTR(TextSplit[i], 1, STRPOS(TextSplit[i],Text50000) - 1);
                CheckListLine.SETRANGE("No.",CodeOutsideParenthesis);
              END ELSE
                CheckListLine.SETRANGE("No.",TextSplit[i]);

              IF CheckListLine.FINDFIRST THEN BEGIN
                IF (CheckListLine.Description = 'Heater Model Number') THEN BEGIN
                  CheckListLine.VALIDATE(Input,HeatModelNumber);
                END ELSE IF (NumberInsideParenthesis <> '') THEN BEGIN
                  CheckListLine.VALIDATE(Input,NumberInsideParenthesis);
                END ELSE BEGIN
                  CheckListLine.VALIDATE(Selected,TRUE);
                END;
                CheckListLine.MODIFY(TRUE);
              END;
            END;
          END;

        UNTIL SalesLine.NEXT = 0;

        // << AOB-56
    end;

    local procedure DXCSplitString(var Text : Text[1024];Separator : Text[1]) Token : Text[1024];
    var
        Pos : Integer;
    begin
        // >> AOB-56
        Pos := STRPOS(Text,Separator);
        IF Pos > 0 THEN BEGIN
          Token := COPYSTR(Text,1,Pos-1);
          IF Pos+1 <= STRLEN(Text) THEN
            Text := COPYSTR(Text,Pos+1)
          ELSE
            Text := '';
        END ELSE BEGIN
          Token := Text;
          Text := '';
        END;
        // << AOB-56
    end;

    var
       
        Text50000 : Label '(';
        Text50001 : Label ')';
}

