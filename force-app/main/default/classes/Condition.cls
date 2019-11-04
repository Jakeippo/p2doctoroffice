/*
    @description Wrapper class for the condition JSON object returned by the Infermedica API.
 */
public with sharing class Condition {
    public String id {get; set;}
    public String name {get; set;}
    public String common_name {get; set;}
    public Decimal probability {get; set;}
    public List<String> categories {get;set;}
    }
