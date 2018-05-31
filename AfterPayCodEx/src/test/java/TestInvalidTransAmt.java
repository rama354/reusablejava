package test.java;

import static org.junit.Assert.*;

import java.util.Arrays;
import java.util.Collection;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import main.java.fraud.FraudUtils;

@RunWith(Parameterized.class)
public class TestInvalidTransAmt {

	private String transAmt;
	private Boolean expectedResult;

	public TestInvalidTransAmt(String transAmt, Boolean expectedResult) 
	{
	      this.transAmt = transAmt;
	      this.expectedResult = expectedResult;
	   
	}

	
	@Parameterized.Parameters
    public static Collection<Object[]> transAmts() {
      return Arrays.asList(new Object[][] {
    	  {"234.2",false},{"25.1245",false},{"2678.12",true},{"28.00",true},{"234A5.00",false}, 
    	  {"234.0F",false},{"0.5",false},{"0.50",true},{"34,5600.05",false}
      });
    }

	@Test
	public void tesInvalidTransAmt() {
		System.out.println("Transaction Amt is : " + transAmt);
		assertEquals(expectedResult, FraudUtils.isValidPrice(transAmt));
	}

}
