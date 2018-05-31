package main.java.fraud;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import static java.util.stream.Collectors.*;

public class FraudDetector {
	
	private final List<Transaction> transactions=new ArrayList<>();
	private final String targetDate;
	private final String priceThreshold;

	public FraudDetector(List<String> transactions,String targetDate,String priceThreshold)
	{
		this.targetDate=targetDate;
		this.priceThreshold=priceThreshold;
		createTransactions(transactions);		
	}
	
	
	/**
	 * method filters out transactions not done on input date, then groups by hashed 
	 * creditcard number & then sums the transaction amt. Then proceeds to add only
	 * those cc numbers whose transaction sum exceeds input threshold
	 * 
	 * @return list of fraud transactions
	 */
	public List<String> detectFraudTransactions() 
	{
		if (transactions.size()==0)
			return null;
		
		LocalDate date=LocalDate.parse(targetDate,FraudConstants.TRANS_DATE_FORMAT);
		Double thresholdPrice=Double.parseDouble(priceThreshold);
		
		final ArrayList<String> fraudTransactions=new ArrayList<>();
		transactions.stream().filter(trx -> trx.getTransDate().isEqual(date))
				             .collect(groupingBy(Transaction::getHashedCCNum,
									  summingDouble(Transaction::getTransAmt)))
				             .forEach((k,v) -> { 
				            	 if (v > thresholdPrice)
				            		 fraudTransactions.add(k);
				            	 
				             });
				             
		
		return fraudTransactions;
		
	}
	
	
	private void createTransactions(List<String> transactions) 
	{
	   if (!FraudUtils.isValidDateFormat(targetDate) || !FraudUtils.isValidPrice(priceThreshold) ||
			transactions.size()==0 )
			return;
		
		transactions.forEach(x -> {
			String[] elements=x.split(FraudConstants.TRANS_DELIMITER);
			if (isValidTransaction(elements)){
				this.transactions.add(new Transaction(elements));
			}
			else{
				 System.out.println("Invalid Transaction");
			}
		});
		
	}


	/**
	 * //Transaction Validation Rules
	 * @param elements
	 * @return
	 */
	private boolean isValidTransaction(String[] elements) {
		if (elements.length!=FraudConstants.TRANS_ELEMENTS_COUNT)
			return false;
		
		if (!FraudUtils.isValidDateFormat(elements[1]=elements[1].trim()))
			return false;
		
		if (!FraudUtils.isValidPrice(elements[2]=elements[2].trim()))
			return false;
		
		return true;
		
	}

}
