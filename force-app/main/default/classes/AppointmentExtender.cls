public with sharing class AppointmentExtender {
    //keep a reference to the standard set controller
    ApexPages.StandardSetController setController;
    private Id doctorId;
    private Id patientId;
    public Appointment__c appt {get; set;}

    public AppointmentExtender(ApexPages.StandardSetController controller) {
        doctorId = Id.valueOf(apexpages.currentpage().getparameters().get('Doc'));
        patientId = Id.valueOf(apexpages.currentpage().getparameters().get('Pat'));
        appt = new Appointment__c(Doctor__c = doctorId, Patient__c = patientId);
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
    /**
    Doctor__c = [SELECT Id FROM Doctor__c WHERE Id = :doctorId][0], 
            Patient__c = [SELECT Id FROM Contact WHERE Id = :patientId][0]); */
}
