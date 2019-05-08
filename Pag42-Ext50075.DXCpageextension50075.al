pageextension 50075 "DXCpageextension50075" extends "Sales Order" //42
{       
    actions
    {    
        addafter("Take over Measurements")
        {           
            action(DXCAutoPopulateCheckList)
            {
                Caption = 'Auto Populate CheckList';
                Image = Recalculate;

                trigger OnAction();
                begin
                    // >> AOB-56
                    DXCPopulateCheckList;
                    // << AOB-56
                end;
            }
        }   
    }

}

