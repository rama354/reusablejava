package test.java;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;

import org.junit.Before;
import org.junit.Test;
import org.junit.experimental.runners.Enclosed;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import static org.junit.runners.Parameterized.*;

import main.java.fraud.FraudDetector;

@RunWith(Enclosed.class)
public class TestFraudDetector {

	@RunWith(Parameterized.class)
	public static class TestFraudTransactions {

		private FraudDetector fraudDetector;
		private int expectedResult;

		public TestFraudTransactions(FraudDetector fraudDetector, int expectedResult) {
			this.fraudDetector = fraudDetector;
			this.expectedResult = expectedResult;
		}

		@Parameters
		public static Collection<Object[]> transLists() {
			return Arrays.asList(new Object[][] {
					{ new FraudDetector(createSingleCCDiffDateTransactions(), "2014-04-26T13:15:54", "15.00"), 1 },
					{ new FraudDetector(createSingleCCDiffDateTransactions(), "2014-04-26T13:15:54", "30.00"), 0 },
					{ new FraudDetector(createMultipleCCDiffDateTransactions(), "2014-04-26T13:15:54", "18.05"), 2 },
					{ new FraudDetector(createMultipleCCDiffDateTransactions(), "2014-04-26T13:15:54", "21.00"), 1 },
					{ new FraudDetector(createMultipleCCDiffDateTransactions(), "2014-04-26T13:15:54", "25.04"), 0 },
					{ new FraudDetector(createMultipleCCSameDateTransactions(), "2014-04-26T13:15:54", "20.00"), 2 } });
		}

		@Test
		public void testFraudDetection() {
			// assert
			assertEquals(expectedResult, fraudDetector.detectFraudTransactions().size());
		}

		private static List<String> createMultipleCCDiffDateTransactions() {
			List<String> transactions = new ArrayList<>();
			transactions.add("11d7ce2f43e35fa57d1bbf8b2e2, 2014-04-26T13:15:54, 10.00");
			transactions.add("11d7ce2f43e35fa57d1bbf8b2e2, 2014-04-16T13:15:54, 15.17");
			transactions.add("11d7ce2f43e35fa57d1bbf8b2e2, 2014-04-26T13:15:54, 12.30");

			transactions.add("10d7ce2f43e35fa57d1bbf8b1e2, 2014-04-26T13:15:54, 20.00");
			transactions.add("10d7ce2f43e35fa57d1bbf8b1e2, 2014-04-25T13:15:54, 12.05");
			transactions.add("10d7ce2f43e35fa57d1bbf8b1e2, 2014-04-29T13:15:54, 15.00");

			return transactions;

		}

		private static List<String> createSingleCCDiffDateTransactions() {
			List<String> transactions = new ArrayList<>();
			transactions.add("10d7ce2f43e35fa57d1bbf8b1e2, 2014-04-26T13:15:54, 10.18");
			transactions.add("10d7ce2f43e35fa57d1bbf8b1e2, 2014-04-25T13:15:54, 12.00");
			transactions.add("10d7ce2f43e35fa57d1bbf8b1e2, 2014-01-25T13:15:54, 10.40");
			transactions.add("10d7ce2f43e35fa57d1bbf8b1e2, 2014-04-26T13:15:54, 15.09");
			return transactions;
		}

		private static List<String> createMultipleCCSameDateTransactions() {
			List<String> transactions = new ArrayList<>();
			transactions.add("10d7ce2f43e35fa57d1bbf8b1e2, 2014-04-26T13:15:54, 10.00");
			transactions.add("11d7ce2f43e35fa57d1bbf8b2e2, 2014-04-26T13:15:54, 12.00");
			transactions.add("11d7ce2f43e35fa57d1bbf8b2e2, 2014-04-26T13:15:54, 10.06");
			transactions.add("10d7ce2f43e35fa57d1bbf8b1e2, 2014-04-26T13:15:54, 15.00");
			return transactions;

		}

	}

	public static class NegativeTests {

		List<String> transactions;

		@Before
		public void setUp() throws Exception {
			transactions = new ArrayList<>();
		}

		@Test
		public void testEmptyTransactionList() {
			FraudDetector detector = new FraudDetector(transactions, "2014-04-26T13:15:54", "15.00");
			assertNull(detector.detectFraudTransactions());
		}

		@Test
		public void testInvalidThresholdPrice() {
			FraudDetector detector = new FraudDetector(transactions, "2014-04-26T13:15:54", "15:00");
			assertNull(detector.detectFraudTransactions());
		}
		
		@Test
		public void testInvalidTargetDate() {
			FraudDetector detector = new FraudDetector(transactions, "2014-04-26T33:15:54", "17.00");
			assertNull(detector.detectFraudTransactions());
		}
	}

}
