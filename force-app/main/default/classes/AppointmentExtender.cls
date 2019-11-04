global with sharing class AppointmentExtender {
    //keep a reference to the standard set controller
    ApexPages.StandardSetController setController;
    public Id doctorId;
    public Id patientId;
    global Appointment__c appt {get; set;}
    global List<Time> times;
    global List<List<Boolean>> Booleans;
    private Integer timeCreationCounter = 0;
    public List<String> values = new List<String>{'8:00 AM - 9:00 AM',
         '9:00 AM - 10:00 AM',
         '10:00 AM - 11:00 AM',
         '11:00 AM - 12:00 PM',
         '12:00 PM - 1:00 PM',
         '1:00 PM - 2:00 PM',
         '2:00 PM - 3:00 PM',
         '3:00 PM - 4:00 PM',
         '4:00 PM - 5:00 PM',
         '5:00 PM - 6:00 PM'};
    private List<Integer> myS = new List<Integer>{1, 2, 3, 4, 5, 6, 7};

    public List<Integer> getMyS() {
        return myS;
    }

    public List<String> getValues() {
        return values;
    }
    public Integer getTimeCreationCounter(){
        incrementCounter();
        return timeCreationCounter;
    }
    public List<List<List<Boolean>>> selectableTimes;

    public void setSelectableTimes(Integer week){
        if(SelectableTimes[week].isEmpty()){

        }
    }

    public void getSelectableTimes(){

    }

    public Component.Apex.PageBlock getWeekButtons(){
        Component.Apex.PageBlock dynWeekButtons = new Component.Apex.PageBlock();
        
        Component.Apex.CommandButton timeButton = new Component.Apex.CommandButton();
        timeButton.value = 'Matt';
        timeButton.expressions.action = '{!Save}';
        timeButton.Id = 'DT580';
        dynWeekButtons.childComponents.add(timeButton);
        return dynWeekButtons;
    }

    public Component.Apex.CommandButton getTestButton(){
        Component.Apex.CommandButton bestTutton = new Component.Apex.CommandButton();
        bestTutton.value = 'counter: ' + timeCreationCounter + ' Counter Modulated: ' + math.mod(timeCreationCounter,values.size());
        bestTutton.expressions.action = '{!Save}';
        bestTutton.Id = 'DT'+timeCreationCounter;
        incrementCounter();
        return bestTutton;
    }

    public PageReference incrementCounter(){
        timeCreationCounter+=1;
        return null;
    }

    public List<List<Boolean>> getBooleans(){
        return new List<List<Boolean>>{ new List<Boolean>{False, True, False, True, False, True, False},
                                         new List<Boolean>{True, False, True, False, True, False, True},
                                         new List<Boolean>{False, True, False, True, False, True, False},
                                         new List<Boolean>{True, False, True, False, True, False, True},
                                         new List<Boolean>{False, True, False, True, False, True, False},
                                         new List<Boolean>{True, False, True, False, True, False, True},   
                                         new List<Boolean>{False, True, False, True, False, True, False},
                                         new List<Boolean>{True, False, True, False, True, False, True},   
                                         new List<Boolean>{False, True, False, True, False, True, False}
        };
    }
 

    public AppointmentExtender(ApexPages.StandardSetController controller) {
        //no null ids!
        try{
            doctorId = Id.valueOf(apexpages.currentpage().getparameters().get('Doc'));
        	patientId = Id.valueOf(apexpages.currentpage().getparameters().get('Pat'));
        }catch(Exception e)
        {
            System.debug('!');
        }finally{
            if(doctorId==null)
            {
                doctorId=[SELECT Id FROM Doctor__c LIMIT 1].Id;
            }
            if(patientId==null)
            {
                patientId=[SELECT Id FROM Contact LIMIT 1].Id;
            }
        }
        
        appt = new Appointment__c(Doctor__c = doctorId, Patient__c = patientId);
        times = new List<Time>{Time.newInstance(8, 0, 0, 0),
                                Time.newInstance(9, 0, 0, 0),
                                Time.newInstance(10, 0, 0, 0),
                                Time.newInstance(11, 0, 0, 0),
                                Time.newInstance(12, 0, 0, 0),
                                Time.newInstance(13, 0, 0, 0),
                                Time.newInstance(14, 0, 0, 0),
                                Time.newInstance(15, 0, 0, 0),
                                Time.newInstance(16, 0, 0, 0),
                                Time.newInstance(17, 0, 0, 0)};
        setController = new ApexPages.StandardSetController(
            [SELECT Doctor__c, Doctor__r.Name, Date__c FROM Appointment__c WHERE Doctor__c = :doctorId]);
    }

    public List<Appointment__c> displayedAppointments {
        get {
            return setController.getRecords();
        }
        set;
    }

    public pageReference save(){
        insert appt;
        return null;
    }

    
    @RemoteAction
    global static List<List<Boolean>> getValidDates(){
        return new List<List<Boolean>>{ new List<Boolean>{False, True, False, True, False, True, False},
                                         new List<Boolean>{True, False, True, False, True, False, True},
                                         new List<Boolean>{False, True, False, True, False, True, False},
                                         new List<Boolean>{True, False, True, False, True, False, True},
                                         new List<Boolean>{False, True, False, True, False, True, False},
                                         new List<Boolean>{True, False, True, False, True, False, True},   
                                         new List<Boolean>{False, True, False, True, False, True, False},
                                         new List<Boolean>{True, False, True, False, True, False, True},   
                                         new List<Boolean>{False, True, False, True, False, True, False}
        };
    }
}