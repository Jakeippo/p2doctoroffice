public class QuestionResponse {
    public Question question {get;set;}
    public Boolean should_stop {get; set;}
    public List<Condition> conditions {get; set;}
}