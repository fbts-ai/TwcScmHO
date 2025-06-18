page 50129 "Date Range Dialog"
{
    PageType = StandardDialog;
    ApplicationArea = All;
    Caption = 'Select Date Range';

    layout
    {
        area(content)
        {
            group(Group)
            {
                field(StartDate; StartDate)
                {
                    ApplicationArea = All;
                    Caption = 'Start Date';
                }

                field(EndDate; EndDate)
                {
                    ApplicationArea = All;
                    Caption = 'End Date';
                }
            }
        }
    }

    var
        StartDate: Date;
        EndDate: Date;

    procedure GetDates(): Dictionary of [Text, Date]
    var
        Result: Dictionary of [Text, Date];
    begin
        Result.Add('StartDate', StartDate);
        Result.Add('EndDate', EndDate);
        exit(Result);
    end;
}
