package test.java;

import static org.junit.Assert.*;

import java.util.Arrays;
import java.util.Collection;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import main.java.fraud.FraudUtils;

@RunWith(Parameterized.class)
public class TestInvalidDate {

	private String transDate;
	private Boolean expectedResult;
	
	public TestInvalidDate(String transDate, Boolean expectedResult) 
	{
	      this.transDate = transDate;
	      this.expectedResult = expectedResult;   
	}


	@Parameterized.Parameters
    public static Collection<Object[]> transAmts() {
      return Arrays.asList(new Object[][] {
    	  {"2014-04T13:15:54",false},{"2014-04-26:13:15:54",false},{"2014-04-26T13:15:54",true},{"2014-04-26T13:15:AA",false}, 
    	  {"2014-04-26T13:15",false},{"2014-04-26:43:15:54",false}
      });
    }

    
	@Test
	public void testInvalidDate() {
		System.out.println("Transaction Date is : " + transDate);
		assertEquals(expectedResult, FraudUtils.isValidDateFormat(transDate));
	}

}
