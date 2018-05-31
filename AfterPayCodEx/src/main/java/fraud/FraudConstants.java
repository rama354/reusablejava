package main.java.fraud;
import java.math.RoundingMode;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

public class FraudConstants {

	public static final int TRANS_ELEMENTS_COUNT = 3;
	public static final String TRANS_DELIMITER=",";
    public static final DateTimeFormatter TRANS_DATE_FORMAT=DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");
    public static final Locale TRANS_LOCALE=Locale.US;
    public static final int TRANS_AMT_PRECISION=2;
	public static final RoundingMode TRANS_AMT_ROUNDING = RoundingMode.HALF_DOWN;
}
