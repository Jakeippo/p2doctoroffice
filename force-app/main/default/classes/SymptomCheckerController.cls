public class SymptomCheckerController {

    String url;
    public List<String> listOfSymptoms {get; set;}
    public List<SearchResult> listOfResults {get; set;}
    public List<SelectOption> searchResults = new List<SelectOption>();
    public List<String> selectedSymptoms {get; set;}
    public Map<String, String> symptomMap = new Map<String, String>();
    public Contact contact;
    public Id contactId;
    public String symptomInput{get {
        if(symptomInput == null) return '';
        else return symptomInput;

    } set;}
    public QuestionResponse q {get; set;}
    public String answer {get; set;}
    public List<String> answers {get{
        if(answers == null) 
        return new List<String>();

        else return answers;
        } set;
    }

    public Map<String, String> likelyConditions = new Map<String, String>();
    public List<SelectOption> userChoices = new List<SelectOption>();
    DiagnosisRequest dr = new DiagnosisRequest();
    public String userChoice {get; set;}
    public String symptomId {get; set;}

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
        return userChoices;
    }

    public void populateResults() {
        // Http http = new Http();
    
        // symptomInput = processPhrase(symptomInput);
        // url = 'https://api.infermedica.com/v2/search?phrase=' + symptomInput + 
        //         '&sex=' + contact.Gender__c + '&type=symptom';
        // HttpRequest req = new HttpRequest();
        // req.setEndpoint(url);
        // req.setMethod('GET');
        // req.setHeader('Content-Type', 'application/json');
        // req.setHeader('App-Id', '8af08433');    
        // req.setHeader('App-Key', 'e30db1e14f9c0b84858fac698c2eeef6');
        // HttpResponse res = http.send(req);
        // System.debug('Search Response: ' + res.getBody());

        HttpResponse res = callToApi('search');
        System.debug(res.getStatusCode());
        if(res.getStatusCode() == 400){
            listOfResults = new List<SearchResult>();
        }else if(res.getStatusCode() == 200) {
            listOfResults = (List<SearchResult>) JSON.deserialize(res.getBody(), List<SearchResult>.class);
        }
        
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

    public String processPhrase(String input) {
        String processedString = input.replace(' ', '_');
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
        dr.sex = 'male';
        dr.age = (Integer) contact.Age__c;
        System.debug('Firing diagnose');
        
        if(dr.evidence.size() == 0) {
            for(String test : symptomMap.keySet()) {
                Evidence newEvidence = new Evidence();
                newEvidence.id = test;  
                newEvidence.initial = true;
                dr.evidence.add(newEvidence);
                System.debug('evidence list size after update: ' + dr.evidence.size());
            }
        }else if(dr.evidence.size() > 0) {
            userChoices.clear();
            if(q.question.type == 'group_single'){
                System.debug('group single condition triggered');
                Evidence newEvidence = new Evidence();
                newEvidence.id = answer;
                newEvidence.choice_id = 'present';
                newEvidence.initial = false;
                dr.evidence.add(newEvidence);
                System.debug('evidence list size after update: ' + dr.evidence.size());
            }else if (q.question.type == 'single') {
                System.debug('single condition triggered');
                Evidence newEvidence = new Evidence();
                symptomId = q.question.items[0].id;
                newEvidence.id = symptomId;
                newEvidence.choice_id = answer;
                newEvidence.initial = false;
                dr.evidence.add(newEvidence);
                System.debug('evidence list size after update: ' + dr.evidence.size());
            }else if (q.question.type == 'group_multiple') {
                System.debug('group multiple condition triggered');
                for(String answer : answers){
                    Evidence newEvidence = new Evidence();
                    newEvidence.id = answer;
                    newEvidence.choice_id = 'present';
                    newEvidence.initial=false;
                    dr.evidence.add(newEvidence);
                }
                System.debug('evidence list size after update: ' + dr.evidence.size());
            }
        }

        // Http http = new Http();
        // url = 'https://api.infermedica.com/v2/diagnosis';
        // String requestBody = JSON.serialize(dr);
        // HttpRequest req = new HttpRequest();
        // req.setEndpoint(url);
        // req.setMethod('POST');
        // req.setHeader('Content-Type', 'application/json');
        // req.setHeader('App-Id', '8af08433');    
        // req.setHeader('App-Key', 'e30db1e14f9c0b84858fac698c2eeef6');
        // System.debug('body: ' + requestBody);
        // req.setBody(requestBody);
        // HttpResponse response = Http.send(req);
        // System.debug('response: ' + response.getBody());

        HttpResponse response = callToApi('diagnosis');
        

        
        q = (QuestionResponse) JSON.deserialize(response.getBody(), QuestionResponse.class);
        return checkShouldStop();
    }

    public PageReference checkShouldStop() {
        if (q.should_stop == false) {
            System.debug('This is still false');
            populateChoices();
            return Page.FollowUpQuestion;
        }else {
            for(Condition c : q.conditions) {
                if(c.probability > 0.50) {
                    System.debug(c.common_name + ' is a probable condition. Adding to likely conditions');
                    
                    likelyConditions.put(c.id, c.common_name);
                }
            }
            System.debug('likelyConditions: ' + likelyConditions);
            return Page.ConditionsPage;
        }
    }

    public void showConditions() {

    }
    public void populateChoices() {
        //TODO: MAP THE CHOICES AND QUESTION
        if(q.question.type == 'single') {
            symptomId = q.question.items[0].id;
            for(Choice choice : q.question.items[0].choices) {
                userChoices.add(new SelectOption(choice.id, choice.label));
            }
            
        }else if (q.question.type == 'group_single' || q.question.type == 'group_multiple') {
            for(Item item : q.question.items) {
                userChoices.add(new SelectOption(item.id, item.name));
            }
        }
    }

    public HttpResponse callToApi(String requestType) {
        
        Http httpClass = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('App-Id', '8af08433');    
        req.setHeader('App-Key', 'e30db1e14f9c0b84858fac698c2eeef6');

        if(requestType == 'diagnosis') {
            url = 'https://api.infermedica.com/v2/diagnosis';
            req.setMethod('POST');
            req.setBody(JSON.serialize(dr));
        }else if(requestType == 'search') {
            symptomInput = processPhrase(symptomInput);
            req.setMethod('GET');
            url = 'https://api.infermedica.com/v2/search?phrase=' + symptomInput + 
                    '&sex=' + contact.Gender__c + '&type=symptom';
        }

        req.setEndpoint(url);
        HttpResponse response = httpClass.send(req);
        return response;
    }
    public void answerQuestion() {
        diagnose();
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