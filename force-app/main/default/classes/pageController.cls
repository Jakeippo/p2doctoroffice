public with sharing class pageController {

    //show if user has a patient record
    public boolean showPatient{
        get
        {
            return patient!=null;
        }
        set;
    }
    
    //show prompt if no age, gender
    public boolean showInfoPrompt{
        get{
            return showPatient && patient.Gender__c ==null && patient.Age__c == null;
        }set;
    }
    
    //contact record associated with the patient user
    public Contact patient{
        get;
        set;
    }
    public Id userId {get;set;}
    
    
    
    
    //for user switcher
    public String choice{get;set;}
    public List<SelectOption> options {
        get{
            options = new List<SelectOption>();
            List<User> users=[SELECT Id,Name FROM User];
            for(User u:users)
            {
                options.add(new SelectOption(u.id,u.Name));
            }
            return options;
        }
        set;
    }
    //appointments
    public List<Appointment__c> infuture{get;set;}
    public List<Appointment__c> inpast{get;set;}
    public List<Appointment__c> appts{
        get{
            appts = new List<Appointment__c>();
            if(patient!=null)
            	appts = [SELECT Doctor__c, Doctor__r.Name, Date__c 
                         FROM Appointment__c 
                         WHERE Patient__c =: patient.Id 
                         ORDER BY Date__c DESC];
            else
                appts = [SELECT Doctor__c, Doctor__r.Name, Date__c 
                         FROM Appointment__c
                         ORDER BY Date__c DESC];
            return appts;
        }
        set;
    }
    
    public pageController()
    {
        //default as current user
        userId=UserInfo.getUserId();
        init();
    }
    
    public void init()
    {
        fillPatient();
        fillTables();
    }
    
    public void fillPatient()
    {
        User u=getUser();
        if( u.ContactId==null)
        {
            patient= null;
            return;
        }
        Id c = u.ContactId;
        patient = [SELECT Id, Name, Email, Gender__c, Age__c FROM Contact WHERE Id =:c LIMIT 1];
    }
    
    
    //get user, with contactid, from user id
    public User getUser()
    {
        return [SELECT Id, ContactId FROM User WHERE Id =:userId LIMIT 1];
    }
    
    //for switching user
    public void changeUser()
    {
        if(choice!=null)
        {
            userId=(Id)(choice);
            init();
        }
    }

    //filling appointment tables depending on dates
    public void fillTables()
    {
        if(patient !=null)
        {
            infuture= new List<Appointment__c>();
            inpast= new List<Appointment__c>();
            DateTime rn = System.now();
            for(Appointment__c ap:appts)
            {
                if(ap.Date__c > rn)
                    infuture.add(ap);
                else
                    inpast.add(ap);
            }
        }
    }
    
    public PageReference updatePatient(){
        try{
            update patient;
        }catch(Exception e){
            
        }
        return null;
    }
    
    //Home
    public PageReference existingUser(){
        return Page.existingUser;
    }

    //Appointment Booker
    public Pagereference AppointmentBookingPage(){
        PageReference page = Page.AppointmentBookingPage;
        if(patient!=null)
        	page.getParameters().put('Pat',patient.Id);
        else
            page=null;
        return page;
    }

    //Symptom Checker
    public Pagereference SymptomCheckerPage(){
        PageReference page = Page.SymptomChecker;
        if(patient!=null)
        	page.getParameters().put('id',patient.Id);
        else
            page=null;
        return page;
    }

}