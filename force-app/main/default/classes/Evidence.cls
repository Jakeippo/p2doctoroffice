/*
    @description Wrapper class for the evidence JSON object nested inside a Diagnosis Request.
 */
public class Evidence {
    public String id{get; set;}
    public Boolean initial{get;set;}
    public String choice_id = 'present';
}