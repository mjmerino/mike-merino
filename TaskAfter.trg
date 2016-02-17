/***********************************************
Trigger: TaskAfter 
    This trigger puts tasks not modified by MAU that are complete into SyncQ object
Latest Revisions
Date         By             Remarks  
================================================================================
02-08-2016   Mike Merino    created
================================================================================
*/
trigger TaskAfter1 on Task (after insert, after update) {
Trigger_on_off__c TriggerOnOff = Trigger_on_off__c.getInstance();
if (TriggerOnOff.task__c==true)
{   
BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];

    Set<Id> ParentIdSet = new Set<Id>();
    for (Task t: trigger.new)
{
    // exclude contacts
    if(t.WhoId!=null && t.WhoId.getSobjectType() == Lead.sObjectType)
    {
        ParentIdSet.add(t.WhoId); // only do this for Leads
    }
}
Map<id,Lead> leadmap = new  Map<id,Lead>([select id, OwnerId,
              First_Call_Target_Response_Time__c, Second_Call_Target_Response_Time__c,Third_Call_Target_Response_Time__c 
              from Lead where Id in : ParentIdSet]);
Map<id,Integer> leadmapAR = new Map<id,Integer>();
List<Task> myTasks = new List<Task>();          
Map<Id, Lead> SLALeadMap = new Map<Id,Lead>();

for(AggregateResult ar :[SELECT WhoId who, COUNT(Id) cnt
                       FROM Task 
                       WHERE status=:system.label.Completed
                       AND  Activity_Type__c=:'Outbound Call'
                       and  WhoId in :ParentIdSet
                       and  CreatedDate = LAST_N_DAYS:60
                       GROUP BY WhoId ]) 
           {
                system.debug('### ProcLead2=='+ar);
                Integer Ccounter = Integer.valueOf(ar.get('cnt'));
                Id myWhoId = (Id)ar.get('who');
                leadMapAR.put(myWhoId, Ccounter);
           }
for (Task t: trigger.new)   {
     Integer cnt = leadmapAR.get(t.WhoId);
     system.debug('### TaskAfter status='+t.status+' lastModBy '+t.lastModifiedById+' WhatId='+t.WhatId+' WhoId '+t.WhoId+' count '+cnt);
     if(t.Status==system.label.Completed && t.Activity_Type__c=='Outbound Call')
     {
         if(cnt == 1 ) 
         {
            Datetime firstTarg = leadmap.get(t.WhoId).First_Call_Target_Response_Time__c;
            if(firstTarg!=null)
            {
                long First_Call = BusinessHours.diff(bh.Id, firstTarg, t.LogDateTime__c);
                Decimal First_Call_SLA = (Decimal)first_call/ 1000 / 3600; // convert into hours  
                system.debug('### first_call '+first_call+' first call sla '+first_call_sla);
                Lead l1 = new Lead(id = t.WhoId, First_Call_Actual_Response_Time__c  = t.LogDateTime__c, First_SLA__c= First_Call_SLA);
                SLALeadMap.put(t.WhoId,l1);
            }
         }
         else if(cnt == 2 )
         {
            Datetime secondTarg = leadmap.get(t.WhoId).Second_Call_Target_Response_Time__c;
            if(secondTarg!=null)
            {
                long Second_Call = BusinessHours.diff(bh.Id, secondTarg, t.LogDateTime__c);
                Decimal Second_Call_SLA = (Decimal)Second_call/ 1000 / 3600; // convert into hours        
                Lead l1 = new Lead(id = t.WhoId, Second_Call_Actual_Response_Time__c  = t.LogDateTime__c, Second_SLA__c= Second_Call_SLA);
                SLALeadMap.put(t.WhoId,l1);
            }
         }
         else if(cnt == 3 )
         {
            Datetime thirdTarg = leadmap.get(t.WhoId).Third_Call_Target_Response_Time__c;
            if(thirdTarg!=null)
            {
                long Third_Call = BusinessHours.diff(bh.Id, ThirdTarg, t.LogDateTime__c);
                Decimal Third_Call_SLA = (Decimal)Third_call/ 1000 / 3600; // convert into hours        
                Lead l1 = new Lead(id = t.WhoId, Third_Call_Actual_Response_Time__c  = t.LogDateTime__c, Third_SLA__c= Third_Call_SLA);
                SLALeadMap.put(t.WhoId,l1);
            }
         } 
     }      
     if(SLALeadMap.size()>0)
     {  
        system.debug('### update leads '+SLALeadMap.values());
        update SLALeadMap.values();
     }  
   }
}
}
