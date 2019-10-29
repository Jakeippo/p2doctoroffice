public class SymptomCheckerController {

    String url;
    public List<String> listOfSymptoms {get; set;}
    public List<SearchResult> listOfResults {get; set;}
    public List<SelectOption> searchResults = new List<SelectOption>();
    public List<String> selectedSymptoms {get; set;}
    public Map<String, String> symptomMap = new Map<String, String>();
    public Contact contact;
    public Id contactId;
    public String symptomInput{get; set;}

    // public class Symptom {
    //     public String id{get; set;}
    //     public String name{get; set;}
    //     public String common_name{get; set;}
    //     public String sex_filter{get; set;}
    //     public String category{get; set;}
    //     public String seriousness{get; set;}
    // }

    public SymptomCheckerController(){
        contactId = ApexPages.currentPage().getParameters().get('Id');
    }

    public class SearchResult {
        public String id{get; set;}        
        public String label{get; set;}
    }

    public Map<String, String> getSymptomMap() {
        return symptomMap;
    }

    public List<SelectOption> getResults() {
        if (searchResults == null || searchResults.size() == 0){
            populateResults();
        }else {
            searchResults.clear();
            populateResults();
        }
        return searchResults;
    }

    public void populateResults() {
        Http http = new Http();
        url = 'https://api.infermedica.com/v2/search?phrase=' + symptomInput + 
                '&sex=' + contact.Gender__c + '&type=symptom';
        System.debug(url);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('App-Id', '8af08433');    
        req.setHeader('App-Key', 'e30db1e14f9c0b84858fac698c2eeef6');
        HttpResponse res = http.send(req);
        System.debug('Search Response: ' + res.getBody());

        listOfResults = (List<SearchResult>) JSON.deserialize(res.getBody(), List<SearchResult>.class);
        
        for(SearchResult result : listOfResults) {
            String resultId = result.id;
            String resultLabel = result.label;
            resultLabel = resultLabel.replace(',', '-');
            System.debug('result: ' + resultId + ' ' + resultLabel);
            if(resultId != null && resultLabel != null && searchResults != null) {
                searchResults.add(new SelectOption(resultId, resultLabel));
            }else{
                System.debug('Result Id null: ' + resultId);
                System.debug('Result Label null: ' + resultLabel);
            }     
        }
    }

 

    public Contact getContact () {
        if (contact == null) {
            contact =[SELECT Id, Name, Age__c, Gender__c FROM Contact WHERE id=:contactId];
            System.debug(contact);
            return contact;
        }else {
            return contact;
        }
    }

    public PageReference addSymptoms() {
        System.debug('Selected Symptoms: ' + selectedSymptoms);
        for(SelectOption result : searchResults) {
            for(String selected : selectedSymptoms) {
                if (result.getValue() == selected) {
                    symptomMap.put(selected, result.getLabel());
                }
            }
        }
        return null;
    }

    public PageReference diagnose() {
        return Page.FollowUpQuestion;
    }

    public PageReference goToConditionsPage () {
        return Page.ConditionsPage;
    }

    public PageReference goToBookingPage() {
        PageReference bookingPage = Page.BookAnAppointment;
        bookingPage.getParameters().put('Pat', contactId);
        return bookingPage;
    }
}