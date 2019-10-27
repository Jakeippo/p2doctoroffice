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
            appt = [SELECT Doctor__c, AppointmentDate__c FROM Appointment__c LIMIT 1
            ];
            return appt;
        }
        set;
    }
    // public pageController(){
    //     doctorId = Id.valueOf(apexpages.currentpage().getparameters().get('Doc'));
    //     patientId = Id.valueOf(apexpages.currentpage().getparameters().get('Pat'));
    //     appt = new Appointment__c(Doctor__c = doctorId, Patient__c = patientId);
    // }
    
    public Pagereference save(){
        insert appt;
        return null;
    }

    public Pagereference AppointmentBookingPage(){
        return Page.AppointmentBookingPage;
    }

    public Pagereference loginPage(){
        return Page.loginPage;
    }

    public PageReference newUser(){
        return Page.newUser;
    }

    public PageReference existingUser(){
        if(checkPassword != password || checkUserName!=userName){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Wrong Username or Password'));
                    return null;
        } else {
                    return Page.existingUser;
         }
    }

    //Appointment Booker


    //Symptom Checker
    






}
