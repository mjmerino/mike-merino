/***************************************************************************
    This trigger creates the SLA target fields
      
    Author – Mike Merino
    Date – 02/08/2016   
    
Change History: 
Date        Person Responsible        Details 
02/08/2016  Mike Merino               created
02/12/2016  Mike Merino               Business Hours on Sat/Sun lead entry

 *************************************************************************/
 
trigger LeadBefore1 on Lead (before insert, before update) {
Trigger_on_off__c TriggerOnOff = Trigger_on_off__c.getInstance();

BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];

if (1==2)
{
    for (Lead l: Trigger.new)
    {
        if(l.lead_entry_date__c!=null)
        {
            Datetime dt;
            String dt1;
            // in case lead entry date on sat/sun or holiday
            Boolean iswithin = BusinessHours.isWithin(bh.id, l.lead_entry_date__c);
            dt= iswithin ? l.lead_entry_date__c : BusinessHours.nextStartDate(bh.id, l.lead_entry_date__c);
            if(dt.hour()>15)
            {
              dt1 = dt.format('yyyy-MM-dd');
              l.first_call_target_response_time__c = DATETIME.ValueOf(dt1 + ' 9:00:00');
            }
            // option 2 put in this line
            else if(dt.hour()<=15 && iswithin)
            {
              dt1 = dt.format('yyyy-MM-dd');
              l.first_call_target_response_time__c = DATETIME.ValueOf(dt1 + ' 17:00:00');
            }
            else 
            {
              dt = BusinessHours.nextStartDate(bh.id, l.lead_entry_date__c);
              dt1 = dt.format('yyyy-MM-dd');
              l.first_call_target_response_time__c = DATETIME.ValueOf(dt1 + ' 9:00:00');
            }

            // number milliseconds in an hour * number business hours * days apart
            Long TWODAYS =  3600000 * 9 * 2;
            Long FIVEDAYS = 3600000 * 9 * 5;
            system.debug('###  firstTarget '+ l.first_call_target_response_time__c);
        
            l.second_call_target_response_time__c = BusinessHours.add(bh.id, l.first_call_target_response_time__c,TWODAYS);
            l.third_call_target_response_time__c = BusinessHours.add(bh.id, l.first_call_target_response_time__c,FIVEDAYS);
            system.debug('### SLA '+l.lead_entry_date__c+'--'+l.first_call_target_response_time__c+'--'+l.second_call_target_response_time__c+'--'+l.third_call_target_response_time__c);
            }
            }
}
}
