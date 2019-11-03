public with sharing class pageController {
    public String name {get;set;}
    public String email {get;set;}
    public String userName {get;set;}
    public String password {get;set;}
    public String checkUserName {get;set;}
    public String checkPassword {get;set;}
    public String retypePassword {get;set;}
    private Id doctorId;
    private Id patientId;
    public Appointment__c appt{
        get{
            appt = [SELECT Doctor__c, Doctor__r.Name, Date__c FROM Appointment__c LIMIT 1
            ];
            return appt;
        }
        set;
    }
    
    public Pagereference save(){
        insert appt;
        return null;
    }

    public Pagereference AppointmentBookingPage(){
        return Page.AppointmentBookingPage;
    }

    public PageReference existingUser(){
        return Page.existingUser;
    }

    //Appointment Booker


    //Symptom Checker
    






}
