package main.java.fraud;
import java.time.DateTimeException;
import java.time.LocalDateTime;

public class FraudUtils {

	public static boolean isValidDateFormat(String date) {
		try{
			LocalDateTime.parse(date,FraudConstants.TRANS_DATE_FORMAT);
		}
		catch(DateTimeException dte){
			return false;
		}
     	return true;	
	}

	public static boolean isValidPrice(String price) {
		try{
			Double.parseDouble(price);
			String[] elems=price.split("\\.");
			return elems[1].length()==FraudConstants.TRANS_AMT_PRECISION?true:false;
		}
		catch(NumberFormatException nfe){
			return false;
		}
		
	}

	
}
