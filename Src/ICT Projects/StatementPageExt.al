pageextension 50114 OpenStatementExt extends "LSC Open Statement"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
    }
    trigger OnOpenPage()
    var
        Retailset: Record "LSC Retail Setup";
        ICTPRocess: Codeunit "ICT Processes_Custom";
        ICTHeader: Record "LSC Retail ICT Header";
    begin
        Retailset.get();

        ICTHeader.Reset();
        ICTHeader.SetRange(Status, ICTHeader.Status::Open);
        ICTHeader.SetRange("Dist. Location To", Retailset."Distribution Location");
        Retailset."Pending ICT Process" := ICTHeader.Count;
        Retailset.Modify();

        // if Retailset."Pending ICT Process" <> 0 then
        //  ICTPRocess.run; //FBTS AA

        /* if Retailset."Max Pending ICT" <> 0 then begin
             if Retailset."Pending ICT Replication_W" > Retailset."Max Pending ICT" then
                 Error('ICT need to replicate from Warehouse DB: ' + Format(Retailset."Pending ICT Replication_W"));
             if Retailset."Pending ICT Replication_F" > Retailset."Max Pending ICT" then
                 Error('ICT need to replicate from Finance DB: ' + Format(Retailset."Pending ICT Replication_F"));

         end;
         if Retailset."Pending ICT Process" <> 0 then
             Error('ICT need to Process in current DB: ' + Format(Retailset."Pending ICT Process"));
 */
    end;

    var
        myInt: Integer;
}