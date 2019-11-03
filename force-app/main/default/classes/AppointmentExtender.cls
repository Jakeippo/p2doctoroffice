global with sharing class AppointmentExtender {
    //keep a reference to the standard set controller
    ApexPages.StandardSetController setController;
    public Id doctorId{get; set;}
    public Id patientId{get; set;}
    global Appointment__c appt {get; set;}
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

    public String getDoctorName(){
        Doctor__c d = [SELECT FirstName__c, LastName__C FROM Doctor__c WHERE Id =:doctorId][0];
        return d.FirstName__c + ' ' + d.LastName__C;
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
        doctorId = Id.valueOf(apexpages.currentpage().getparameters().get('Doc'));
        patientId = Id.valueOf(apexpages.currentpage().getparameters().get('Pat'));
        setController = new ApexPages.StandardSetController(
            [SELECT Doctor__c, DoctorName__c, AppointmentDate__c FROM Appointment__c WHERE Doctor__c = :doctorId]);
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
    global static List<List<boolean>> getValidDates(Integer weekOffset,Id doctorId){
        weekOffset*=7;
        List<List<Boolean>> selectable = new List<List<Boolean>>{ new List<Boolean>{True, True, True, True, True, True, True, True, True, True},
                                         new List<Boolean>{True, True, True, True, True, True, True, True, True, True},
                                         new List<Boolean>{True, True, True, True, True, True, True, True, True, True},
                                         new List<Boolean>{True, True, True, True, True, True, True, True, True, True},
                                         new List<Boolean>{True, True, True, True, True, True, True, True, True, True},
                                         new List<Boolean>{True, True, True, True, True, True, True, True, True, True},   
                                         new List<Boolean>{True, True, True, True, True, True, True, True, True, True}};
        List<Time> times = new List<Time>{Time.newInstance(8, 0, 0, 0),
                                Time.newInstance(9, 0, 0, 0),
                                Time.newInstance(10, 0, 0, 0),
                                Time.newInstance(11, 0, 0, 0),
                                Time.newInstance(12, 0, 0, 0),
                                Time.newInstance(13, 0, 0, 0),
                                Time.newInstance(14, 0, 0, 0),
                                Time.newInstance(15, 0, 0, 0),
                                Time.newInstance(16, 0, 0, 0),
                                Time.newInstance(17, 0, 0, 0)};
        Date startDate = Date.today().addDays(weekOffset).toStartOfWeek();
        dateTime beginDateTime = DateTime.newInstance(startDate,Time.newInstance(7, 0, 0, 0));
        dateTime endDateTime = DateTime.newInstance(startDate.addDays(7),Time.newInstance(19, 0, 0, 0));
        Integer weekDay = 0;
        Time compareTime = DateTime.now().Time();
        List<Appointment__c> appointments = [SELECT Doctor__c, DoctorName__c, AppointmentDate__c 
                                             FROM Appointment__c 
                                             WHERE Doctor__c = :doctorId AND
                                             AppointmentDate__c > :beginDateTime AND
                                             AppointmentDate__c < :endDateTime];
        //there are a number of ways that large amounts of week data can be made false, this is only if the user is viewing
        //the first week
        if(weekOffset==0){
            System.debug(startDate);
            System.debug(Date.today());
            weekDay = Math.mod(startDate.daysBetween(Date.today()),6);
            System.debug(weekDay);
            //removes whole days off
            for(Integer i = 0; i < weekDay; i++){
                for(Integer j = 0; j < (times.size()-1); j++){
                    System.debug(i + ' ' + j);
                    selectable[i][j] = False;
                }
            }
            //removes times until now
            if(compareTime >= times[0]){
                for(Integer j = 0; j < (times.size()-1); j++){
                    if(compareTime >= times[j]){
                        selectable[weekDay][j] = false;
                    }
                    else{
                        //if we can start scheduling appointments, theres no point to continuing this loop
                        j = times.size();
                    }
                }
            }
        }
        //we need to declare an index because we're about to simulate an indexof(object) method, something I thought would be in
        //by default
        Integer index = 0;
        Integer iterator = 0;
        for(Appointment__c a:appointments){
            weekDay = a.AppointmentDate__c.Date().daysBetween(a.AppointmentDate__c.Date().toStartOfWeek());
            compareTime = a.AppointmentDate__c.Time();
            while(iterator < (times.size()-1)){
                if(compareTime == times[iterator]){
                    index = iterator;
                    iterator = times.size();
                }
                iterator++;
            }
            iterator=0;
            selectable[weekDay][index] = false;
            index = 0;
        }
        return selectable;
    }

    /*
    @RemoteAction
    global static List<List<Boolean>> getValidDates(){
        return new List<List<Boolean>>{ new List<Boolean>{False, True, False, True, False, True, False, True, False, True},
                                         new List<Boolean>{True, False, True, False, True, False, True, False, True, False},
                                         new List<Boolean>{False, True, False, True, False, True, False, True, False, True},
                                         new List<Boolean>{True, False, True, False, True, False, True, False, True, False},
                                         new List<Boolean>{False, True, False, True, False, True, False, True, False, True},
                                         new List<Boolean>{True, False, True, False, True, False, True, False, True, False},   
                                         new List<Boolean>{False, True, False, True, False, True, False, True, False, True}};
    }
    */

    @RemoteAction
    global static List<List<String>> getWeekDates(Integer weekOffset){
        weekOffset*=7;
        List<List<String>> dates = new List<List<String>>();
        List<String> dateStrings = new List<String>();
        Date startDate = Date.today().addDays(weekOffset).toStartOfWeek();
        Date newDate = null;
        for(integer i = 0; i<7; i++){
            newDate = startDate.addDays(i);
            dateStrings.add( ''+newDate.month());
            dateStrings.add(''+newDate.day());
            dateStrings.add(''+newDate.year());
            dates.add(dateStrings.clone());
            dateStrings.clear();
        }
        return dates;
    }

    @RemoteAction
    global static void makeAppointment(Integer year, Integer month, Integer day, String visitTime, Id doctorId, Id patientId){
        Map<String, Time> times = new Map<String, Time>();
        times.put('8:00 AM - 9:00 AM',Time.newInstance(8, 0, 0, 0));                                
        times.put('9:00 AM - 10:00 AM',Time.newInstance(9, 0, 0, 0));                               
        times.put('10:00 AM - 11:00 AM',Time.newInstance(10, 0, 0, 0));                                
        times.put('11:00 AM - 12:00 PM',Time.newInstance(11, 0, 0, 0));                                
        times.put('12:00 PM - 1:00 PM',Time.newInstance(12, 0, 0, 0));                                
        times.put('1:00 PM - 2:00 PM',Time.newInstance(13, 0, 0, 0));                                
        times.put('2:00 PM - 3:00 PM',Time.newInstance(14, 0, 0, 0));                                
        times.put('3:00 PM - 4:00 PM',Time.newInstance(15, 0, 0, 0));                                
        times.put('4:00 PM - 5:00 PM',Time.newInstance(16, 0, 0, 0));                             
        times.put('5:00 PM - 6:00 PM',Time.newInstance(17, 0, 0, 0)); 
        Date insertDate = Date.newInstance(year, month, day);
        DateTime timeDate = DateTime.newInstance(insertDate, times.get(visitTime));
        Appointment__c appointment = new Appointment__c(Doctor__c = doctorId, Patient__c = patientId, AppointmentDate__c = timeDate);
        insert(appointment);
    }
}
