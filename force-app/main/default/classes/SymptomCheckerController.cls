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
    public QuestionResponse q {get; set;}
    public String answer {get; set;}
    public List<SelectOption> userChoices = new List<SelectOption>();

    public String testJson {get; set;}

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

    public class DiagnosisRequest {
        public String sex {get;set;}
        public Integer age {get; set;}
        public List<Evidence> evidence = new List<Evidence>();

        public List<Evidence> getEvidence() {
            return evidence;
        }
    }

    public class Evidence {
        public String id{get; set;}
        public Boolean initial{get;set;}
        public String choice_id = 'present';
    }

    public class Item {
        public String id {get; set;}
        public String name {get;set;}
        public List<Choice> choices {get; set;}
    }

    public class Choice {
        public String id {get; set;}
        public String label {get; set;}
    }
    
    public class Question {
        public String type {get; set;}
        public String text {get; set;}
        public List<Item> items {get; set;}
    }

    public class QuestionResponse {
        public Question question {get;set;}
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

    public List<SelectOption> getUserChoices() {
        System.debug('Choices after refresh: ' + userChoices);
        return userChoices;
    }

    public void populateResults() {
        Http http = new Http();
        if(contact != null && symptomInput != null){
            symptomInput = processPhrase(symptomInput);
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

    public String processPhrase(String input) {
        String processedString = input.replace(' ', '_');
        System.debug('Processed String: ' + processedString);
        return processedString;
    }

    public PageReference addSymptoms() {
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
        
        DiagnosisRequest dr = new DiagnosisRequest();
        dr.sex = 'male';
        dr.age = (Integer) contact.Age__c;
        for(String test : symptomMap.keySet()) {
            Evidence newEvidence = new Evidence();
            newEvidence.id = test;
            newEvidence.initial = true;
            System.debug(newEvidence);
            System.debug(dr.evidence);
            dr.evidence.add(newEvidence);
        }

        Http http = new Http();
        url = 'https://api.infermedica.com/v2/diagnosis';
        String requestBody = JSON.serialize(dr);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('App-Id', '8af08433');    
        req.setHeader('App-Key', 'e30db1e14f9c0b84858fac698c2eeef6');
        System.debug('body: ' + requestBody);
        req.setBody(requestBody);
        HttpResponse response = Http.send(req);
        System.debug('response: ' + response.getBody());
        testJson = response.getBody();

        if(response.getBody().contains('question')) {
            System.debug('This worked.');
            q = (QuestionResponse) JSON.deserialize(response.getBody(), QuestionResponse.class);
            //TODO: MAP THE CHOICES AND QUESTION
            for(Item item : q.question.items) {
                userChoices.add(new SelectOption(item.id, item.name));
            }
            System.debug('Choices: ' + userChoices);
            return Page.FollowUpQuestion;
        }else {
            return Page.FollowUpQuestion;
        }
    }

    public void answerQuestion() {
        System.debug('answer: ' + answer);

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