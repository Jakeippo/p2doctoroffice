public class DiagnosisRequest {
    public String sex {get; set;}
    public Integer age {get; set;}
    public List<Evidence> evidence = new List<Evidence>();

    public List<Evidence> getEvidence() {
        return evidence;
    }
}