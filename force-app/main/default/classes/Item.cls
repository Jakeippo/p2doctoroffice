/*
    @description Wrapper class for an item JSON Object returned in the QuestionResponse 
    from the Infermedica API.
 */
public class Item {
    public String id {get; set;}
    public String name {get;set;}
    public List<Choice> choices {get; set;}
}