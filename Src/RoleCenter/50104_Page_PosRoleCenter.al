page 50104 PosRoleCenter
{
    Caption = 'TWC POS Role Center';
    PageType = RoleCenter;
    UsageCategory = None;
    layout
    {
        area(rolecenter)
        {
            group(Control1900724808)
            {
                ShowCaption = false;
                /*
                part(Control1907692008; "My Items")
                {
                    ApplicationArea = RelationshipMgmt;
                }
                */
            }
            group(Control1900724708)
            {
                ShowCaption = false;
                /*
                part(Control11; "My customers")
                {
                    ApplicationArea = RelationshipMgmt;
                }
                */

            }
        }
    }

    actions
    {
        area(reporting)
        {
            action(RunPOS)
            {

                ApplicationArea = All;
                Caption = 'Run POS';
                Image = Approval;
                RunObject = Page "LSC POS Client";
                ToolTip = 'Run POS';

            }

        }
        area(sections)
        {


        }
        area(processing)
        {
            separator(Action48)
            {
                Caption = 'Tasks';
                IsHeader = true;
            }





        }
    }
}

