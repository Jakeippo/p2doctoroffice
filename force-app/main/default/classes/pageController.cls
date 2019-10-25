public with sharing class pageController {
    public String name {get;set;}
    public String email {get;set;}
    public String userName {get;set;}
    public String password {get;set;}
    public String checkUserName {get;set;}
    public String checkPassword {get;set;}
    public String retypePassword {get;set;}
    public Appointment__c appt {get;set;}

    public pageController(){

        

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
