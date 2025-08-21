pageextension 50003 "Location Extension" extends "Location Card"
{
    layout
    {
        addafter("Address 2")
        {
            field("Transfer Location"; rec."Transfer Location")
            {
                ApplicationArea = all;
            }
            field("Creation Location"; "Creation Location")
            {
                ApplicationArea = all;
            }
            //AJ_Alle_1112023
            //TodayQuarantine
            field("Quarantine Location"; rec."Quarantine Location")
            {
                ApplicationArea = all;
            }
            //TodayQuarantine
            //AJ_Alle_1112023
        }
        // Add changes to page layout here
        /*
          addafter("Use As In-Transit")
          {
              field(Region; Rec.Region)
              {
                  ApplicationArea = all;

              }
              field(Type; Rec.Type)
              {
                  ApplicationArea = all;
              }
              field("Vendor Code"; Rec."Vendor Code")
              {
                  ApplicationArea = all;
              }

          }
          */
        addlast(General)
        {
            field(CashVendor; Rec.CashVendor)
            {
                Caption = 'Cash vendor';
            }
            field(PurchaseReturnVendor; Rec.PurchaseReturnVendor)
            {
                Caption = 'PurchaseReturnVendor';
            }
            field(IsWarehouse; Rec.IsWarehouse)
            {
                Caption = 'IsWarehouse';
            }
            field(BuddyStore; Rec.BuddyStore)
            {
                Caption = 'Buddy Store';
            }
            field(BuddyWarehouse; Rec.BuddyWarehouse)
            {
                Caption = 'Buddy Warehouse';
            }
            //ALLE_NICK_130124
            field("Physical Group"; "Physical Group")
            {
                ApplicationArea = all;
            }
            field(IsStore; rec.IsStore)
            {
                Caption = 'IsStore';
            }
            //////E-invoice

            group("E-invoice")
            {
                field("Hostbook Login ID"; Rec."Hostbook Login ID")
                {
                    ApplicationArea = ALL;
                }
                field("Hostbook Password"; Rec."Hostbook Password")
                {
                    ApplicationArea = ALL;
                }
                field("Hostbook ConnectorID"; Rec."Hostbook ConnectorID")
                {
                    ApplicationArea = ALL;
                }
                field("Company ID"; Rec."Company ID")
                {
                    ApplicationArea = ALL;
                }

                field("Hostbook UserAccNo"; Rec."Hostbook UserAccNo")
                {
                    ApplicationArea = ALL;
                }

                field("Eway Bill API User-ID"; Rec."Eway Bill API User-ID")
                {
                    ApplicationArea = ALL;
                }
                field("Eway bill API password"; Rec."Eway bill API password")
                {
                    ApplicationArea = ALL;
                }
                field("E-Way Bill Business ID"; Rec."E-Way Bill Business ID")
                {
                    ApplicationArea = ALL;
                }
                field("E-Way Bill Business GSTIN"; Rec."E-Way Bill Business GSTIN")
                {
                    ApplicationArea = ALL;
                }
                field("HB Account user ID number"; Rec."HB Account user ID number")
                {
                    ApplicationArea = ALL;
                }
                field("Distance in KM"; "Distance in KM")
                {
                    ApplicationArea = all;
                }
                field("Consumption Qty change Allow"; "Consumption Qty change Allow") //PT-FBTS 060325
                {
                    ApplicationArea = all;
                }
            }

        }

    }
    actions
    {
        // Add changes to page actions here
        addafter("&Location")
        {
            action("E-invoice-Login") //PT-FBTS
            {
                ApplicationArea = all;
                Promoted = true;
                trigger OnAction()
                var
                    EinvCodeunit: Codeunit "Einvoice CU";
                begin
                    EinvCodeunit.HostbookLogin(Rec);
                    ;
                end;
            }
            action("E-Way-Login") //PT-FBTS
            {
                ApplicationArea = all;
                Promoted = true;
                trigger OnAction()
                var
                    EinvCodeunit: Codeunit TransferOrderEway;
                    Resposns: Text;
                begin
                    Resposns := EinvCodeunit.HostbookLoginEWAYBill(Rec);
                    Message('%1', Resposns);
                end;
            }
        }
    }
    // trigger OnOpenPage()
    // var
    //     usersetup: Record "User Setup";
    // begin
    //     if usersetup.Get(UserId) then
    //         if Usersetup."Allow Master Modification" = false then begin
    //             Error('You are not authorized to Access the page');
    //             // CurrPage.Close();
    //             //CurrPage.Editable(false);

    //         end;
    // end;




    var
        myInt: Integer;
}