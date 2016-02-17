/**
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestSLA {

    static testMethod void myUnitTest() {
      Boolean alreadyLoaded = false;
      Trigger_On_off__c tr =  new Trigger_On_off__c(Lead__c = true, Task__C = true);
      try{
          insert tr;
      } catch (Exception ex){
            system.debug('### already loaded '+ex);
            alreadyLoaded =true;
      }
      
      Lead l = new Lead (company='Mike test', firstname='hello', lastname='there', lead_entry_date__c=system.now());
      insert l;
      
      List<Task> tList = new List<Task>();
      Task t1 = new TAsk(WhoId=l.id, Activity_Type__c='Outbound Call', status='Completed', logDateTime__c=system.now());
      insert t1;
      Task t2 = new TAsk(WhoId=l.id, Activity_Type__c='Outbound Call', status='Completed', logDateTime__c=system.now()+1);
       insert t2;
      Task t3 = new TAsk(WhoId=l.id, Activity_Type__c='Outbound Call', status='Completed', logDateTime__c=system.now());
      tList.add(t3);
      Task t4 = new TAsk(WhoId=l.id, Activity_Type__c='Outbound Call', status='Completed', logDateTime__c=system.now()+4);
      tList.add(t4); 
      if (tList.size()>0)
      {
         insert tList;
      }
      tList.clear();
      Lead l2 = new Lead (company='Mike test2', firstname='hello', lastname='there2', lead_entry_date__c=DateTime.newInstance(2016,2,13,10,0,0));
      insert l2;        
      Task t5 = new TAsk(WhoId=l2.id, Activity_Type__c='Outbound Call', status='Completed', logDateTime__c=system.now());
      tList.add(t5);
      Task t6 = new TAsk(WhoId=l2.id, Activity_Type__c='Outbound Call', status='Completed', logDateTime__c=system.now()+4);
      tList.add(t6);
      Task t7 = new TAsk(WhoId=l2.id, Activity_Type__c='Outbound Call', status='Completed', logDateTime__c=system.now());
      tList.add(t7); 
       if (tList.size()>0)
      {
         insert tList;
      }
        
    }
    static testMethod void myUnitTests() {
      Boolean alreadyLoaded = false;
      Trigger_On_off__c tr =  new Trigger_On_off__c(Lead__c = true, Task__C = true);
      try{
          insert tr;
      } catch (Exception ex){
            system.debug('### already loaded '+ex);
            alreadyLoaded =true;
      }
      // saturday
      Lead l1 = new Lead (company='Mike test', firstname='hello', lastname='there', lead_entry_date__c=DateTime.newInstance(2016, 2, 13, 10, 15, 0));
      insert l1;
      
      Task t1 = new TAsk(WhoId=l1.id, Activity_Type__c='Outbound Call', status='Completed', logDateTime__c=DateTime.newInstance(2016, 2, 13, 7, 30, 0));
      insert t1;
      ///////////////////////////////
      // within business hours
        Lead l2 = new Lead (company='Mike test2', firstname='hello', lastname='there2', lead_entry_date__c=DateTime.newInstance(2016, 2, 10, 8, 45, 0));
      insert l2;
      
      Task t2 = new TAsk(WhoId=l2.id, Activity_Type__c='Outbound Call', status='Completed', logDateTime__c=DateTime.newInstance(2016, 2, 10, 9, 0, 0));
      insert t2; 
      ///////////////////////////////
      // normal day outside business hours
      Lead l3 = new Lead (company='Mike test2', firstname='hello', lastname='there2', lead_entry_date__c=DateTime.newInstance(2016, 2, 10, 18, 45, 0));
      insert l3;
      
      Task t3 = new TAsk(WhoId=l3.id, Activity_Type__c='Outbound Call', status='Completed', logDateTime__c=DateTime.newInstance(2016, 2, 10, 18, 0, 0));
      insert t3; 
            
    }
}
