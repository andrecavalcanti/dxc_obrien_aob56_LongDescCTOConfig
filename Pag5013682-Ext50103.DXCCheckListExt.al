pageextension 50103 "DXCCheckListExt" extends "Checklist" //5013682
{   
    actions
    {
        addlast("&Checklist")
        {
            action(DXCAutoPopulateCheckList)
            {
                Caption = 'Auto Populate CheckList';
                Image = Recalculate; 
                Promoted = true;
                PromotedCategory = Process;             
            }
        }
    } 

}

