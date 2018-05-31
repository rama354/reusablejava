package main.java.fraud;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class Transaction {

	private String hashedCCNum;
	private LocalDateTime transTimeStamp;
	private Double transAmt;
	
	public Transaction(String[] elements) {
		hashedCCNum=elements[0];
		transTimeStamp=LocalDateTime.parse(elements[1],FraudConstants.TRANS_DATE_FORMAT);
		transAmt=Double.parseDouble(elements[2]);
	}

	public String getHashedCCNum() {
		return hashedCCNum;
	}

	public LocalDateTime getTransTimeStamp() {
		return transTimeStamp;
	}

	public Double getTransAmt() {
		return transAmt;
	}

	public LocalDate getTransDate(){
		return transTimeStamp.toLocalDate();
	}
	
}
