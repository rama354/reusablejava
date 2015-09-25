/**
 * 
 */
package com.citi.ipas.portal.integration.helpers;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;
import java.util.List;

import oracle.jdbc.OracleConnection;
import oracle.jdbc.OracleTypes;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.support.AbstractSqlTypeValue;

import com.citi.ipas.portal.integration.constants.SQLConstants;
import com.citi.ipas.portal.integration.rest.vo.SearchConditionVO;
import com.citi.ipas.portal.integration.rest.vo.SearchCriteriaVO;

/**
 * @author rr78158
 * 
 */
public class ProductProgramSearchSQLHelper {
    Log log = LogFactory.getLog(ProductProgramSearchSQLHelper.class);
    
    MapSqlParameterSource procInpMap = null;
    private SqlParameter[] procInpDefs;
    private JdbcTemplate jdbcTemplate;

    public ProductProgramSearchSQLHelper(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;     
    }

    public void init(SearchCriteriaVO srchCriteriaVO) {
        procInpDefs = new SqlParameter[19];
        procInpDefs[0] = new SqlParameter("pv_programsonly", Types.NUMERIC);
        procInpDefs[1] = new SqlParameter("pv_startidx", Types.NUMERIC);
        procInpDefs[2] = new SqlParameter("pv_endidx", Types.NUMERIC);
        // procInpDefs[3]=new SqlParameter("PV_PID_NOTIN",
        // OracleTypes.ARRAY,"NUMBER_ARR");
        // procInpDefs[4]=new SqlParameter("PV_PID_IN",
        // OracleTypes.ARRAY,"NUMBER_ARR");
        procInpDefs[3] = new SqlParameter("PV_PID_NOTIN", OracleTypes.ARRAY,
                "VARCHAR2_ARR");
        procInpDefs[4] = new SqlParameter("PV_PID_IN", OracleTypes.ARRAY,
                "VARCHAR2_ARR");
        procInpDefs[5] = new SqlParameter("PV_PNAME", Types.VARCHAR);
        procInpDefs[6] = new SqlParameter("PV_PTYPE", Types.VARCHAR);
        procInpDefs[7] = new SqlParameter("PV_PSUBTYPE", Types.VARCHAR);
        procInpDefs[8] = new SqlParameter("PV_PSTATUSCODE", Types.VARCHAR);
        procInpDefs[9] = new SqlParameter("PV_PGOVDPACODE", Types.VARCHAR);
        procInpDefs[10] = new SqlParameter("PV_PBUSCODE", Types.VARCHAR);
        procInpDefs[11] = new SqlParameter("PV_REGIONCODE", Types.VARCHAR);
        procInpDefs[12] = new SqlParameter("PV_COUNTRYCODE", Types.VARCHAR);
        procInpDefs[13] = new SqlParameter("PV_MGR_SOEID_IN",
                OracleTypes.ARRAY, "VARCHAR2_ARR");
        procInpDefs[14] = new SqlParameter("PV_MGR_SOEID_NOTIN",
                OracleTypes.ARRAY, "VARCHAR2_ARR");
        procInpDefs[15] = new SqlParameter("PV_SPNSR_SOEID_NOTIN",
                OracleTypes.ARRAY, "VARCHAR2_ARR");
        procInpDefs[16] = new SqlParameter("PV_SPNSR_SOEID_IN",
                OracleTypes.ARRAY, "VARCHAR2_ARR");
        procInpDefs[17] = new SqlParameter("PV_REVIEW_ID_IN",
                OracleTypes.ARRAY, "VARCHAR2_ARR");
        procInpDefs[18] = new SqlParameter("PV_REVIEW_ID_NOTIN",
                OracleTypes.ARRAY, "VARCHAR2_ARR");
  
        procInpMap = new MapSqlParameterSource();
        procInpMap.addValue("PV_PID_IN", new VarCharArray(new String[0]));
        procInpMap.addValue("PV_PID_NOTIN", new VarCharArray(new String[0]));
        procInpMap.addValue("PV_PNAME", null);
        procInpMap.addValue("PV_PTYPE", null);
        procInpMap.addValue("PV_PSUBTYPE", null);
        procInpMap.addValue("PV_PSTATUSCODE", null);
        procInpMap.addValue("PV_PGOVDPACODE", null);
        procInpMap.addValue("PV_PBUSCODE", null);
        procInpMap.addValue("PV_REGIONCODE", null);
        procInpMap.addValue("PV_COUNTRYCODE", null);
        procInpMap.addValue("PV_SPNSR_SOEID_IN",
                new VarCharArray(new String[0]));
        procInpMap.addValue("PV_SPNSR_SOEID_NOTIN", new VarCharArray(
                new String[0]));
        procInpMap.addValue("PV_MGR_SOEID_IN", new VarCharArray(new String[0]));
        procInpMap.addValue("PV_MGR_SOEID_NOTIN", new VarCharArray(
                new String[0]));
        procInpMap.addValue("PV_REVIEW_ID_IN", new VarCharArray(new String[0]));
        procInpMap.addValue("PV_REVIEW_ID_NOTIN", new VarCharArray(
                new String[0]));
    }

    public String buildProgramSearchClauses(
            List<SearchConditionVO> srchConditionVOList) {
        StringBuilder searchQuery = new StringBuilder();
        for (SearchConditionVO criteria : srchConditionVOList) {
            String searchKey = (String) criteria.searchKey;
            String searchValue = (String) criteria.searchValue;
            String searchType = (String) criteria.searchType;
            if (searchKey.equalsIgnoreCase("prd_prg_id")) {
                String[] values = searchValue.split(",");
                // final int[] idarr=new int[values.length];
                /*
                 * final int[] idarr=new int[values.length]; for (int
                 * i=0;i<values.length;i++) idarr[i]=values[i];
                 */
                if (searchType.equalsIgnoreCase("NOT_IN"))
                    procInpMap.addValue("PV_PID_NOTIN",
                            new VarCharArray(values));
                if (searchType.equalsIgnoreCase(SQLConstants.IN.trim())
                        || searchType.equalsIgnoreCase(SQLConstants.EXACT))
                    procInpMap.addValue("PV_PID_IN", new VarCharArray(values));
            }
            if (searchKey.equalsIgnoreCase("prd_prg_name")) {
                String prodProgName = searchValue.toUpperCase();
                if (searchType.equalsIgnoreCase(SQLConstants.EXACT))
                    procInpMap.addValue("PV_PNAME", prodProgName);
                if (searchType.equalsIgnoreCase(SQLConstants.ENDS))
                    procInpMap.addValue("PV_PNAME", "%" + prodProgName);
                if (searchType.equalsIgnoreCase(SQLConstants.CONTAINS))
                    procInpMap.addValue("PV_PNAME", "%" + prodProgName + "%");
                if (searchType.equalsIgnoreCase(SQLConstants.BEGINS))
                    procInpMap.addValue("PV_PNAME", prodProgName + "%");
            }
            if (searchKey.equalsIgnoreCase("prd_type_code")) {
                procInpMap.addValue("PV_PTYPE", searchValue);
            }
            if (searchKey.equalsIgnoreCase("prd_sub_type_code")) {
                procInpMap.addValue("PV_PSUBTYPE", searchValue);
            }
            if (searchKey.equalsIgnoreCase("PROD_STATUS_CODE")) {
                procInpMap.addValue("PV_PSTATUSCODE", searchValue);
            }
            if (searchKey.equalsIgnoreCase("GOV_DPAC_CODE")) {
                procInpMap.addValue("PV_PGOVDPACODE", searchValue);
            }
            if (searchKey.equalsIgnoreCase("bus_code")) {
                procInpMap.addValue("PV_PBUSCODE", searchValue);
            }
            if (searchKey.equalsIgnoreCase("region_cd")) {
                procInpMap.addValue("PV_REGIONCODE", searchValue);
            }
            if (searchKey.equalsIgnoreCase("country_cd")) {
                procInpMap.addValue("PV_COUNTRYCODE", searchValue);
            }
            if (searchKey.equalsIgnoreCase("MGR_SOEID_SPONSOR")) {
                String[] values = searchValue.split(",");
                final String[] soeidarr = new String[values.length];
                for (int i = 0; i < values.length; i++)
                    soeidarr[i] = values[i].toUpperCase();
                if (searchType.equalsIgnoreCase(SQLConstants.IN.trim())
                        || searchType.equalsIgnoreCase(SQLConstants.EXACT))
                    procInpMap.addValue("PV_SPNSR_SOEID_IN", new VarCharArray(
                            soeidarr));
                if (searchType.equalsIgnoreCase(SQLConstants.NOT_IN.trim()))
                    procInpMap.addValue("PV_SPNSR_SOEID_NOTIN",
                            new VarCharArray(soeidarr));
                searchQuery.append(SQLConstants.WHITESPACE + SQLConstants.AND)
                        .append("ppm1.mgr_role_code='SPONSOR'")
                        .append(SQLConstants.RIGHT_RND_BRKT);
            }
            if (searchKey.equalsIgnoreCase("mgr_soeid")) {
                String[] values = searchValue.split(",");
                final String[] soeidarr = new String[values.length];
                for (int i = 0; i < values.length; i++)
                    soeidarr[i] = values[i].toUpperCase();
                if (searchType.equalsIgnoreCase(SQLConstants.IN.trim())
                        || searchType.equalsIgnoreCase(SQLConstants.EXACT))
                    procInpMap.addValue("PV_MGR_SOEID_IN", new VarCharArray(
                            soeidarr));
                if (searchType.equalsIgnoreCase(SQLConstants.NOT_IN.trim()))
                    procInpMap.addValue("PV_MGR_SOEID_NOTIN", new VarCharArray(
                            soeidarr));
            }
            if (searchKey.equalsIgnoreCase("PRD_REVIEW_ID")) {
                String[] values = searchValue.split(",");
                final String[] soeidarr = new String[values.length];
                for (int i = 0; i < values.length; i++)
                    soeidarr[i] = values[i].toUpperCase();
                if (searchType.equalsIgnoreCase(SQLConstants.IN.trim())
                        || searchType.equalsIgnoreCase(SQLConstants.EXACT))
                    procInpMap.addValue("PV_REVIEW_ID_IN", new VarCharArray(
                            soeidarr));
                if (searchType.equalsIgnoreCase(SQLConstants.NOT_IN.trim()))
                    procInpMap.addValue("PV_REVIEW_ID_NOTIN", new VarCharArray(
                            soeidarr));
            }
        }
        return searchQuery.toString();
    }

   /*private class NumberArray extends AbstractSqlTypeValue {
        private int[] values;

        NumberArray(int[] values) {
            this.values = values;
        }

        public Object createTypeValue(Connection conn, int sqlType,
                String typeName) throws SQLException {
            OracleConnection oracle = null;
            try {
                if (conn instanceof OracleConnection){
                    oracle = (OracleConnection) conn;
                    System.out.println("Ram3...." + conn.getClass().toString());
                }
                else {
                    System.out.println("Ram1...."
                            + jdbcTemplate.getDataSource().getConnection()
                                    .getClass().toString());
                    conn = jdbcTemplate.getNativeJdbcExtractor()
                            .getNativeConnection(
                                    jdbcTemplate.getDataSource()
                                            .getConnection());
                    System.out.println("Ram2...." + conn.getClass().toString());
                    log.error("1...." + conn.getClass().toString());*/
                    // conn =
                    // jdbcTemplate.getDataSource().getConnection().unwrap(OracleConnection.class);
                    // oracle=(OracleConnection)WSCallHelper.getNativeConnection(conn);
                    /*
                     * conn=getAfsNativeConnection();
                     * System.out.println("Calling getAfsNativeConnection()...."
                     * +conn.getClass().toString());
                     */
      /*              oracle = (OracleConnection) conn;
                }
                oracle.sql.ArrayDescriptor desc = new oracle.sql.ArrayDescriptor(
                        typeName, oracle);
                return new oracle.sql.ARRAY(desc, oracle, values);
            } catch (ClassCastException ce) {
                log.error("Unable to get Native Connection in NumberArray...Connection object retrieved is "
                        + conn.getClass().toString());
                throw ce;
            } catch (SQLException ex) {
                log.error("Unable to get Oracle Connection in NumberArray for"
                        + typeName);
                throw ex;
            } catch (SecurityException e) {
                log.error("Access denied for parent PoolingDataSource instance");
                throw new RuntimeException(e);
            } catch (IllegalArgumentException e) {
                throw new RuntimeException(e);
            }
        }
    }*/

    private class VarCharArray extends AbstractSqlTypeValue {
        private String[] values;

        VarCharArray(String[] values) {
            this.values = values;
        }

        public Object createTypeValue(Connection conn, int sqlType,
                String typeName) throws SQLException {
            OracleConnection oracle = null;
            try {
                if (conn instanceof OracleConnection){
                    //System.out.println("Ram3...." + conn.getClass().toString());
                    oracle = (OracleConnection) conn;                   
                }
                else {
                    //System.out.println("Ram1...."+ jdbcTemplate.getDataSource().getConnection().getClass().toString());
                    conn = jdbcTemplate.getNativeJdbcExtractor()
                            .getNativeConnection(
                                    jdbcTemplate.getDataSource()
                                            .getConnection());
                   // System.out.println("Ram2...." + conn.getClass().toString());
                    log.error("1...." + conn.getClass().toString());
                    /*
                     * conn=getAfsNativeConnection();
                     * System.out.println("Calling getAfsNativeConnection()...."
                     * +conn.getClass().toString());
                     */
                    oracle = (OracleConnection) conn;
                }
                oracle.sql.ArrayDescriptor desc = new oracle.sql.ArrayDescriptor(
                        typeName, oracle);
                return new oracle.sql.ARRAY(desc, oracle, values);
            } catch (ClassCastException ce) {
                log.error("Unable to get Native Connection in NumberArray...Connection object retrieved is "
                        + conn.getClass().toString());
                throw ce;
            } catch (SQLException ex) {
                log.error("Unable to get Oracle Connection in VarCharArray for"
                        + typeName);
                throw ex;
            } catch (SecurityException e) {
                log.error("Access denied for parent PoolingDataSource instance");
                throw new RuntimeException(e);
            } catch (IllegalArgumentException e) {
                 
                throw new RuntimeException(e);
            }
        }
    }

    public SqlParameter[] getProcInpDefs() {
        return procInpDefs;
    }

    public void setProcInpDefs(SqlParameter[] procInpDefs) {
        this.procInpDefs = procInpDefs;
    }

    public MapSqlParameterSource getProcInpMap() {
        return procInpMap;
    }

    public void setProcInpMap(MapSqlParameterSource procInpMap) {
        this.procInpMap = procInpMap;
    }

    /*private Connection getAfsNativeConnection() throws SQLException {
        Connection con = null;
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            String url = "jdbc:oracle:thin:@vm-6fc4-350e.nam.nsroot.net:1522:cloudapp";
            String username = "bpc_merge_uat";
            String password = "bpc_merge_uat";
            con = DriverManager.getConnection(url, username, password);
        } catch (SQLException sqlEx) {
            sqlEx.printStackTrace();
        } catch (Exception e1) {
            e1.printStackTrace();
        }
        return con;
    }*/
}
