/*
    @author Christian Rondon
    @date 11/3/2019
    @description SymptomCheckerController  provides all of the functionality of the SymptomChecker feature.
    The diagnosis feature takes and input of symptoms from the user, asks follow-up questions, then provides
    conditions based on the evidence gathered.

 */

public class SymptomCheckerController {

    
    String url;

    //contact and contactId variables for patient.
    public Contact contact;
    public Id contactId;

    // Properties and their get and set methods for two-way data binding 
     public String symptomInput{get {
        if(symptomInput == null) return '';
        else return symptomInput;

    } set;}

    
    // Properties necessary for the search result portion of the application.
    public List<SearchResult> listOfResults {get; set;}
    public List<SelectOption> searchResults = new List<SelectOption>();
    public List<String> selectedSymptoms {get; set;}
    public Map<String, String> addedSymptoms = new Map<String, String>();
    
    
    // Properties necessary for the diagnosis and follow-up question portion of the application.
    DiagnosisRequest dr = new DiagnosisRequest();
    public QuestionResponse questionResponse {get; set;}
    public String symptomId {get; set;}
    public String answer {get; set;}
    public List<String> answers {get{
        if(answers == null) 
        return new List<String>();

        else return answers;
        } set;
    }

    // Properties necessary for the conditions page portion of the application.
    public List<Condition> likelyConditions;
    public String categoryToSend {get; set;}
    public List<SelectOption> answerOptions = new List<SelectOption>();
    
    //constructor
    public SymptomCheckerController(){
        contactId = ApexPages.currentPage().getParameters().get('Id');
        getContact();
        likelyConditions = new List<Condition>();
    }

    //Getter methods
    public Map<String, String> getaddedSymptoms() {
        return addedSymptoms;
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

    public List<SelectOption> getAnswerOptions() {
        return answerOptions;
    }

    public List<Condition> getLikelyConditions() {
        System.debug('Likely Condition after refresh: ' + likelyConditions);
        if(likelyConditions == null) {
            return new List<Condition>();
        }else {
            return likelyConditions;
        }
    }

    public Contact getContact () {
        if (contact == null && contactId!=null){
            
            contact =[SELECT Id, Name, Age__c, Gender__c FROM Contact WHERE Id=:contactId];
            System.debug(contact);
            return contact;
        }else {
            if(contactId==null)
            	contact = [SELECT Id, Name, Age__c, Gender__c FROM Contact LIMIT 1];
            return contact;
        }
    }

    /*
        @description populateResults takes the users input in the search bar and uses it to 
        call the /search endpoint of the API.
     */
    public void populateResults() {
        
        //Calls to the API
        HttpResponse res = callToApi('search');

        if(res.getStatusCode() == 400){ //if the request was unsuccessful
            listOfResults = new List<SearchResult>();
        }else if(res.getStatusCode() == 200) {//if the request was successful
            listOfResults = (List<SearchResult>) JSON.deserialize(res.getBody(), List<SearchResult>.class);
        }
        
        /*
        Take each result and add it to a list of SelectOptions that are
        shown in the search results section.
        */
        for(SearchResult result : listOfResults) {
            String resultId = result.id;
            String resultLabel = result.label;
            // resultLabel = resultLabel.replace(',', '-');
            System.debug('result: ' + resultId + ' ' + resultLabel);
            if(resultId != null && resultLabel != null && searchResults != null) {
                searchResults.add(new SelectOption(resultId, resultLabel));
            }else{
                System.debug('Result Id null: ' + resultId);
                System.debug('Result Label null: ' + resultLabel);
            }     
        }
    }

    /*
        @description processPhrase replaces any spaces in the user input and replace them with an 
        underscore (_) to use in the URLs query parameter.
     */
    public String processPhrase(String input) {
        String processedString = input.replace(' ', '_');
        return processedString;
    }

    /*
        @description addSymptoms takes the selected results and adds them to a list 
        of reported symptoms for diagnosis.
     */
    public PageReference addSymptoms() {
        for(SelectOption result : searchResults) {
            for(String selected : selectedSymptoms) {
                if (result.getValue() == selected) {
                    addedSymptoms.put(selected, result.getLabel());
                }
            }
        }
        return null;
    }
    
    /*
        @description Method gets the gender of the patient and turns the string to lowercase
        so the API can process the request correctly.
     */
    public String getSex(String cgender)
    {
        if(cgender!=null)
        	return cgender.toLowerCase();
        else
            return 'male';
    }

    /*
        @description The main part of the SymptomChecker functionality. Method collects 
        a list of chosen symptoms from the earch results and adds them to the request. 
        Also flags the symptoms reported as initially chosen or reported as a result of 
        a question.
    
     */
    public PageReference diagnose() {

        // gets necessary information of the patient for proper diagnosis.
        dr.sex = getSex(contact.Gender__c);
        dr.age = (Integer) contact.Age__c;
        
        if(dr.evidence.size() == 0) {   //If the list of evidences (symptoms) is empty
            for(String test : addedSymptoms.keySet()) {
                Evidence newEvidence = new Evidence();
                newEvidence.id = test;  
                newEvidence.initial = true; //flag these new evidences as initial, then add.
                dr.evidence.add(newEvidence);
            }
        }else if(dr.evidence.size() > 0) { //If the list of evidences already has initial evidences..
            answerOptions.clear();
            // Figure out what kind of question was answered, then add the answer accordingly.
            if(questionResponse.question.type == 'group_single'){
                Evidence newEvidence = new Evidence();
                newEvidence.id = answer;
                newEvidence.choice_id = 'present';
                newEvidence.initial = false;
                dr.evidence.add(newEvidence);
            }else if (questionResponse.question.type == 'single') {
                Evidence newEvidence = new Evidence();
                symptomId = questionResponse.question.items[0].id;
                newEvidence.id = symptomId;
                newEvidence.choice_id = answer;
                newEvidence.initial = false;
                dr.evidence.add(newEvidence);
            }else if (questionResponse.question.type == 'group_multiple') {
                for(String answer : answers){
                    Evidence newEvidence = new Evidence();
                    newEvidence.id = answer;
                    newEvidence.choice_id = 'present';
                    newEvidence.initial=false;
                    dr.evidence.add(newEvidence);
                }
            }
        }

        //Make a call to the Api
        HttpResponse response = callToApi('diagnosis');
        questionResponse = (QuestionResponse) JSON.deserialize(response.getBody(), QuestionResponse.class);

        return checkShouldStop();
    }

    /*
        @description checkShouldStop evaluates the APIs response after the user answers the follow-up question. 
        If the response indicates that the application has gathered enough evidence, the conditions will 
        be displayed in a new page called ConditionsPage. If more questions need asked, render the next question.
     */
    public PageReference checkShouldStop() {

        if (questionResponse.should_stop == true) {
            for(Condition c : questionResponse.conditions) {
                HttpResponse conditionResponse = callToApi('condition', c.id);
                Condition conditionDetails = (Condition) JSON.deserialize(conditionResponse.getBody(), Condition.class);
                conditionDetails.probability = (c.probability * 100);
                likelyConditions.add(conditionDetails);
            }
            return Page.ConditionsPage;
        }else {
            populateChoices();
            return Page.FollowUpQuestion;
        }
    }

    /*
        @description adds the list of multiple-choice choices to the follow-up question page.
     */
    public void populateChoices() {
        if(questionResponse.question.type == 'single') {
            symptomId = questionResponse.question.items[0].id;
            for(Choice choice : questionResponse.question.items[0].choices) {
                answerOptions.add(new SelectOption(choice.id, choice.label));
            }
            
        }else if (questionResponse.question.type == 'group_single' || questionResponse.question.type == 'group_multiple') {
            for(Item item : questionResponse.question.items) {
                answerOptions.add(new SelectOption(item.id, item.name));
            }
        }
    }

    /*
        @description makes a call to the Infermedica API and returns a response for
        processing.
        @param requestType the request type needed, whether it be a search or diagnosis.
     */
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

    /*
        @description Method finds a specific condition in the API based on its ID.
        @param requestType request type for item (condition, symptom, or risk factor).
        @param id the id of the item being requestion
     */
    public HttpResponse callToApi(String requestType, String id) {
        
        Http httpClass = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('App-Id', '8af08433');    
        req.setHeader('App-Key', 'e30db1e14f9c0b84858fac698c2eeef6');

        if(requestType == 'condition') {
            url = 'https://api.infermedica.com/v2/conditions/' + id;
            req.setMethod('GET');
        }
        req.setEndpoint(url);
        HttpResponse response = httpClass.send(req);
        return response;
    }

    /*
        @description method redirects the user to the booking page after setting 
        query parameters for the BookAnAppointment page to recieve and assign 
        the patient to the appropriate doctors.
     */
    public PageReference bookingPage() {
        PageReference bookingPage = Page.BookAnAppointment;
        bookingPage.getParameters().put('Pat', contactId);
        bookingpage.getParameters().put('Con', categoryToSend);
        System.debug('going to bookingPage');
        return bookingPage;
    }
    
}