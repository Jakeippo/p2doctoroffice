/*
    @description Wrapper class for the Question JSON object returned by the Infermedica API.
 */
public class Question {
    public String type {get; set;}
    public String text {get; set;}
    public List<Item> items {get; set;}
}