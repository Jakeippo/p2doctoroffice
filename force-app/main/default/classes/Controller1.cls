public class Controller1{
    public Id doctorId { get; set; }
    public Id patientId { get; set; }

	public PageReference Transfer() {
		PageReference newPAge = page.BookAnAppointment;
		newPage.getParameters().put('Doc', doctorId);
        newPage.getParameters().put('Pat', patientId);
		return newPage;
	}
}
