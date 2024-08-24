report 70027 "Recu caisse paiement"
{
    RDLCLayout = 'Reports\RDLC\Report 70027 Ticket de caisse paiement.rdlc';
    Caption = 'Ticket de caisse paiement';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(Encaissement; Encaissement)
        {
            RequestFilterFields = "N°";
            column(No_Transaction; "N°")
            {

            }
            column(Code_caisse; "Code caisse")
            {

            }
            column(Client_No_; "N° client")
            {

            }
            column(Client_epargne; Client_epargne)
            {

            }
            column(Mode_reglement; "Mode de paiement")
            {

            }
            column(Sell_to_Customer_Name; "Nom client")
            {

            }
            column(Date; Date)
            {

            }
            column(Montant; Montant)
            {

            }
            column(Rendu; Monnaie)
            {

            }
            column(Reste; ResteAP)
            {

            }
            column(ticket; ticket)
            {

            }
            column(listing; listing)
            {
            }
            column(BL; BL)
            {

            }
            column(TVA; parcaisse."% TVA")
            {

            }
            column(AIRSI; parcaisse."% AIRSI")
            {

            }

            column(Epargne; Epargne)
            {

            }
            column("Sole_epargne"; "Solde epargne")
            {

            }

            column(printdate; printdate)
            {

            }
            dataitem("Sales Header"; 112)
            {
                DataItemLink = "No." = field("N° Commande");
                column(Order_Date; "Order Date")
                {

                }
                column(No_CMDE; "No.")
                {

                }
                column(Amount; Amount)
                {

                }

                column(Amount_Including_VAT; "Amount Including VAT")
                {

                }
                column(VAT_Base_Discount__; "VAT Base Discount %")
                {

                }
                column("Montant_payé"; ("Amount Including VAT" + timbre) - "Remaining Amount")
                {

                }
                column(Timbre; Timbre)
                {

                }
                dataitem("Sales Line"; 113)
                {
                    DataItemLink = "Document No." = field("No.");
                    column(No_; "No.")
                    {

                    }
                    column(Carton_effectif; "Carton effectif")
                    {

                    }
                    column(Description; Description)
                    {

                    }
                    column(Quantity__Base_; "Quantity")
                    {

                    }
                    column(Unit_Cost; "Unit Price")
                    {

                    }
                    column(Line_Amount; "Line Amount")
                    {

                    }

                    column(totalCartons; totalCartons)
                    {

                    }

                    column(totalC; totalC)
                    {

                    }
                    column(Line_No_; "Line No.")
                    {

                    }
                    column(UnitHt; UnitHt)
                    {

                    }
                    column(MontantHt; MontantHt)
                    {

                    }


                    dataitem(pesee; Pesse)
                    {
                        DataItemLink = "Document No." = field("Order No."), "Line No." = field("Line No."), "No." = field("No.");
                        DataItemTableView = where(Valid = Const(true));
                        column(Poids; Poids)
                        {

                        }
                        column(nombre; nombre)
                        {

                        }
                        column(Total; Total)
                        {

                        }
                        column(Line_No_P; "Line No.")
                        {

                        }

                        column(tour; tour)
                        {

                        }

                        column(UnitHtround; UnitHtround) { }

                        column(MontantHtround; MontantHtround) { }
                    }


                    trigger OnAfterGetRecord()
                    var
                        myInt: Integer;
                        compta: Record "General Ledger Setup";
                        ligne: Record 113;
                    begin
                        compta.Reset();
                        if compta.FindFirst() then begin
                            AIRSI := 1 + compta."% AIRSI" / 100;
                        end;

                        UnitHt := "Sales Line"."Unit price" / AIRSI;
                        UnitHtround := Round(UnitHt, 0.01, '=');
                        MontantHtround := UnitHtround * "Sales Line"."Quantity";
                        // MontantHtround:=Round(MontantHt,0.01,'=');

                        nbr += 1;
                        if nbr = 1 then
                            cible := "Sales Line"."Line No.";

                        if "Sales Line"."Line No." = cible then
                            tour += 1;

                    end;
                }

            }

            trigger OnAfterGetRecord()
            var
                Cust: Record Customer;
                epargne: Record "Depôt";
                parcaisse: Record 98;
                salesInvLines: record "Sales Invoice Line";
                salesheader: Record "Sales Invoice Header";
            begin
                printdate := Today;
                Cust.SetRange("No.", "N° client");
                epargne.SetRange("N° client", "N° client");
                epargne.SetRange(isBonus, false);
                epargne.SetRange(validated, true);
                epargne.CalcSums(epargne.Montant);
                Client_epargne := epargne.Montant;
                if Cust.FindFirst() then begin
                    "Nom client" := Cust.Name;
                    cust.CalcFields("Montant prime bonus");
                    "Solde epargne" := Cust."Montant prime bonus";
                end;

                salesInvLines.Reset();
                salesInvLines.SetRange("Document No.", "N° commande");
                if salesInvLines.FindFirst() then begin
                    repeat
                        totalC += salesInvLines."Carton effectif";
                    until salesInvLines.Next = 0;
                end;

                salesheader.Reset();
                salesheader.SetRange("No.", "N° commande");
                if salesheader.FindFirst() then begin
                    salesheader.CalcFields("Remaining Amount");
                    ResteAP := salesheader."Remaining Amount";

                end;


            end;


            trigger OnPreDataItem()
            var
            begin
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                field(ticket; "ticket")
                {
                    Caption = 'Imprimer le ticket';
                    Visible = false;
                }
                field(listing; "listing")
                {

                    Caption = 'Imprimer le listing';
                    Visible = false;
                }
                field(BL; "BL")
                {

                    Caption = 'Imprimer le Bon de livraison';
                    Visible = false;
                }
            }
        }

        actions
        {
            area(processing)
            {

            }
        }
        trigger OnOpenPage()
        var
            myInt: Integer;
        begin
            "ticket" := true;
            "listing" := true;
            "BL" := true;
            parcaisse.GET;

        end;
    }
    trigger OnPreReport()
    var
        myInt: Integer;
    begin
        parcaisse.GET;
        "ticket" := true;
        "listing" := true;
        "BL" := true;

    end;

    trigger OnPostReport()
    var
        expVEnr: Record 110;
        SalesHeader: Record 112;
        parcaisse: Record 98;

    begin
        parcaisse.GET;
    end;


    var
        parcaisse: Record 98;
        Client_epargne: Decimal;
        "Solde epargne": Decimal;
        totalCartons: Decimal;
        totalC: Decimal;
        "Nom client": Text[50];
        "ticket": Boolean;
        "listing": boolean;
        "BL": boolean;
        tour: Integer;
        cible: Integer;
        nbr: Integer;
        printdate: Date;
        AIRSI: Decimal;
        UnitHt: Decimal;
        MontantHt: Decimal;
        UnitHtround: Decimal;
        MontantHtround: Decimal;
        ResteAP: Decimal;

}