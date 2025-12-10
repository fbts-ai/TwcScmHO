codeunit 50132 "Job Queue Entry-ICT"
{
    trigger OnRun()
    var
        JobList: Record "Job Queue Entry";
    begin
        JobList.Reset();
        JobList.SetRange("Object Type to Run", JobList."Object Type to Run"::Codeunit);
        JobList.SetFilter("Object ID to Run", '%1|%2', 50129, 50011);
        JobList.SetFilter(Status, '%1|%2', JobList.Status::Error, JobList.Status::Finished);
        if JobList.FindFirst() then
            JobList.SetStatus(JobList.Status::Ready);
    end;

}