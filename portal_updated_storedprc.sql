set define off;
insert into IPAS.APP_CONFIG values('IPAS_DEV_Webank','https://productapproval.dev.citigroup.net:7080/IPASDEV','IPAS DEV-SIT link','24-AUG-15');
insert into IPAS.APP_CONFIG values('IPAS_UAT_Webank','https://ipas-stg.webbank.ssmb.com/IPAS','IPAS UAT link','24-AUG-15');
insert into IPAS.APP_CONFIG values('IPAS_PROD_Webank','https://ipas.nj.ssmb.com','IPAS PROD link','24-AUG-15');

create or replace 
PACKAGE BODY IPAS.PKG_RPT_PORTAL
AS

FUNCTION fn_get_in_condition(
    pc_array number_arr,
    pv_column_name VARCHAR2,
    pv_condition_type VARCHAR2)
  RETURN VARCHAR2
AS
  lv_mod NUMBER;
  lv_cond_sql varchar2(30000);
  lv_val_sql varchar2(30000):= '';
BEGIN
-- AND ()
  lv_cond_sql := ' AND (';
  FOR i IN 1..pc_array.count
  LOOP
    lv_val_sql := lv_val_sql||pc_array(i);
    lv_mod := mod(i,1000);
    IF lv_mod = 0 OR i = pc_array.count THEN
      lv_cond_sql := lv_cond_sql||pv_column_name||pv_condition_type||'('||lv_val_sql||')'; 
      if i < pc_array.count then
         lv_cond_sql := lv_cond_sql||' OR ';
      end if;
      lv_val_sql :='';
    ELSE
      lv_val_sql := lv_val_sql||',';
     -- dbms_output.put(length(lv_val_sql));
    END IF;
  END LOOP;
  RETURN lv_cond_sql||')';
END fn_get_in_condition;

function fn_get_in_condition(pc_array varchar2_arr,
                             pv_column_name VARCHAR2,
                             pv_condition_type VARCHAR2)
  RETURN VARCHAR2
AS
  lv_mod NUMBER;
  lv_cond_sql varchar2(30000);
  lv_val_sql varchar2(30000):= '';
BEGIN
  lv_cond_sql := ' (';
  FOR i IN 1..pc_array.count
  LOOP
    lv_val_sql := lv_val_sql||''''||pc_array(i)||'''';
    lv_mod := mod(i,1000);
    IF lv_mod = 0 OR i = pc_array.count THEN
      lv_cond_sql := lv_cond_sql||pv_column_name||pv_condition_type||'('||lv_val_sql||')'; 
      if i < pc_array.count then
         lv_cond_sql := lv_cond_sql||' OR ';
      end if;
      lv_val_sql :='';
    ELSE
      lv_val_sql := lv_val_sql||',';
    END IF;
  END LOOP;
  RETURN lv_cond_sql||')';
END fn_get_in_condition;

/*FUNCTION fn_prod_prog_TYPE_CODE (p_prd_prg_id prod_program.prd_prg_id%TYPE)
    RETURN VARCHAR2
  As
    v_info  VARCHAR2 (1000);
BEGIN
  BEGIN
    v_info := NULL;

    select a.PRD_TYPE_CODE
        INTO v_info
        FROM PROD_PROG_TYPE a, lkp_prod_type lkp
       WHERE a.PRD_TYPE_CODE = lkp.PRD_TYPE_CODE
       AND a.PRD_PRG_ID = p_prd_prg_id;
       
    EXCEPTION
      WHEN OTHERS
      THEN
        RETURN NULL;
    END;

    RETURN v_info;
  END fn_prod_prog_TYPE_CODE;
  
FUNCTION fn_prod_prog_SUB_TYPE_CODE (p_prd_prg_id prod_program.prd_prg_id%TYPE)
    RETURN VARCHAR2
  AS
    v_info  VARCHAR2 (1000);
 BEGIN
  BEGIN
    v_info := NULL;

    select
    a.PRD_SUB_TYPE_CODE
        INTO v_info
        FROM PROD_PROG_SUB_TYPE a, lkp_prod_sub_type lkp
       WHERE a.PRD_SUB_TYPE_CODE = lkp.PRD_SUB_TYPE_CODE
       AND a.PRD_PRG_ID = p_prd_prg_id;

    EXCEPTION
      WHEN OTHERS
      THEN
        RETURN NULL;
    END;

    RETURN v_info;
  END fn_prod_prog_SUB_TYPE_CODE;*/

/*FUNCTION FN_wf_prod_TYPE_CODE (p_wf_prod_id wf_product.wf_prod_id%TYPE)
    RETURN VARCHAR2
  AS
    v_info  VARCHAR2 (1000);
BEGIN
  BEGIN
     v_info := NULL;

    -- OTH_PROD_TYPE, OTH_PPG
  
    select a.PRD_TYPE_CODE
    INTO v_info
    FROM wf_prod_prog_TYPE a, lkp_prod_type lkp
    WHERE a.PRD_TYPE_CODE = lkp.PRD_TYPE_CODE
    AND a.WF_PROD_ID = p_wf_prod_id;

    EXCEPTION
      WHEN OTHERS
      THEN
        RETURN NULL;
    END;

    RETURN v_info;
  END FN_wf_prod_TYPE_CODE;
  
  
FUNCTION FN_wf_prod_SUB_TYPE_CODE (p_wf_prod_id wf_product.wf_prod_id%TYPE)
    RETURN VARCHAR2
  AS
    v_info  VARCHAR2 (1000);
 BEGIN 
  BEGIN
    v_info := NULL;

    select
    A.Prd_Sub_Type_Code
        INTO v_info
        FROM wf_prod_SUB_TYPE a, lkp_prod_sub_type lkp
       Where A.Prd_Sub_Type_Code = Lkp.Prd_Sub_Type_Code
    AND a.WF_PROD_ID = p_wf_prod_id;

    EXCEPTION
      WHEN OTHERS
      THEN
        RETURN NULL;
    END;

    RETURN v_info;
  END FN_wf_prod_SUB_TYPE_CODE;*/

PROCEDURE get_uniondata_portal(
    pv_programsonly NUMBER,
    pv_startidx     NUMBER,
    pv_endidx       NUMBER,
    PV_PID_NOTIN varchar2_arr,
    PV_PID_IN varchar2_arr,
    PV_PNAME       VARCHAR2,
    PV_PTYPE       VARCHAR2,
    PV_PSUBTYPE    VARCHAR2,
    PV_PSTATUSCODE VARCHAR2,
    PV_PGOVDPACODE VARCHAR2,
    PV_PBUSCODE    VARCHAR2,
    PV_REGIONCODE  VARCHAR2,
    PV_COUNTRYCODE VARCHAR2,
    PV_MGR_SOEID_IN varchar2_arr,
    PV_MGR_SOEID_NOTIN varchar2_arr,
    PV_SPNSR_SOEID_NOTIN varchar2_arr,
    PV_SPNSR_SOEID_IN varchar2_arr,
    PV_REVIEW_ID_IN varchar2_arr,
    PV_REVIEW_ID_NOTIN varchar2_arr,
    recordset OUT SYS_REFCURSOR)
AS
  lv_union_sql  VARCHAR2(30000);
  lv_prog_sql   VARCHAR2(30000);
  lv_prod_sql   VARCHAR2(30000);
  lv_select     VARCHAR2(8000);
  lv_search_sql VARCHAR2(30000);
  --lv_soeid_sql varchar2(30000);
BEGIN
  
lv_prog_sql :=
  'SELECT to_char(pg.prd_prg_id) AS PID,
pg.prd_prg_name AS PName,             
pg.PRD_PRG_SUMMARY AS Description,             
pg.prod_status_code As Status,
pst.PROD_STATUS_DESC As StatusDesc,             
''productprogram'' as PType,              
NULL as ParentID, 
pg.GOV_DPAC_CODE as GOV_DPAC_CODE,
g.GROUP_NAME as GoverningDPAC,             
/*(case                
when (pg.REV_FREQ_MONTHS is not null) then pg.REV_FREQ_MONTHS             
END) AS Periodic Review Cycle,*/             
to_char(pg.NEXT_PER_REV_DATE, ''mm/dd/yyyy'') AS ReviewDueDate,             
to_char(pg.LAST_PER_REV_DATE, ''mm/dd/yyyy'') AS LastReviewDate,             
pkg_rpt_prod_prog.fn_get_all_prod_prog_bus(pg.prd_prg_id) AS DistributionChannel,             
NULL AS Approvers,             
NULL AS ApproverDate,              
pkg_rpt_prod_prog.fn_get_all_prod_prog_SUB_TYPE(pg.prd_prg_id) AS SubCategory,
--PKG_RPT_PORTAL.fn_prod_prog_SUB_TYPE_CODE(pg.prd_prg_id) AS SubCategoryCode,
pkg_rpt_prod_prog.fn_get_all_prod_prog_TYPE(pg.prd_prg_id) AS PCategory, 
--PKG_RPT_PORTAL.fn_prod_prog_TYPE_CODE(pg.prd_prg_id) AS PCategoryCode, 
pkg_rpt_prod_prog.fn_get_all_prod_sponsors(pg.prd_prg_id) AS Sponsors,             
pkg_rpt_prod_prog.fn_get_all_prod_managers(pg.prd_prg_id) AS Managers             
--pkg_rpt_prod_prog.fn_get_all_prod_prog_country(pg.prd_prg_id) AS Country             
/*pg.CLIENT_NET_REQ AS Specific Client Req,             
pg.BUS_RAT_TO_KEEP AS Bus Rationale to Offer,             
pg.OPEN_ISSUES AS Open Issues,             
pkg_rpt_prod_prog.fn_get_all_prod_METRICS1(pg.prd_prg_id)  AS Num of Clients: LastRepo;Curr,             
pkg_rpt_prod_prog.fn_get_all_prod_METRICS2(pg.prd_prg_id) AS Num Of Trans: LastRepo;Curr,             
pkg_rpt_prod_prog.fn_get_all_prod_METRICS3(pg.prd_prg_id) AS Assets: LastRepo;Curr,             
pkg_rpt_prod_prog.fn_get_all_prod_METRICS4(pg.prd_prg_id) AS Revenues: LastRepo;Curr,             
pkg_rpt_prod_prog.fn_get_all_prod_METRICS5(pg.prd_prg_id) AS Performance Overview,*/             
--pg.REV_STATUS_CODE AS Review Status Code              
FROM prod_program pg,               
lkp_prod_status pst,            
user_group g              
WHERE pg.GOV_DPAC_CODE = g.group_CODE
AND pg.prod_status_code=pst.prod_status_code'
;

  
lv_prod_sql :=
  'SELECT  wfi.wf_review_id AS PID,
wfp.product_name AS PName,             
wfp.product_desc AS Description,             
wfi.wf_STATUS_CODE As Status,             
lst.wf_STATUS_DESC As StatusDesc,           
''product'' as PType,             
wfp.prd_prg_id as ParentID,
wfp.GOV_DPAC_CODE as GOV_DPAC_CODE,
g.GROUP_NAME as GoverningDPAC,             
NULL AS ReviewDueDate,             
NULL AS LastReviewDate,              
/*(case                
when (pg.REV_FREQ_MONTHS is not null) then pg.REV_FREQ_MONTHS             
END) AS Periodic Review Cycle,*/             
--Rs.Rev_Status_Desc As Review Status,             
--Pg.Prod_Manufacturer As Product Manufacturer,             
pkg_rpt_wf_prod_prog.Fn_Get_Wf_Prod_Bus(wfp.wf_prod_id) AS DistributionChannel,             
pkg_workflow.fn_get_all_approvers(wfp.wf_instance_id) AS Approvers,             
pkg_workflow.get_approval_date(wfp.wf_instance_id) AS ApproverDate,             
pkg_rpt_wf_prod_prog.FN_GET_wf_prod_TYPE(wfp.wf_prod_id) AS PCategory, 
--PKG_RPT_PORTAL.FN_wf_prod_TYPE_CODE(wfp.prd_prg_id) AS PCategoryCode, 
pkg_rpt_wf_prod_prog.FN_GET_wf_prod_SUB_TYPE(wfp.wf_prod_id) AS SubCategory, 
--PKG_RPT_PORTAL.FN_wf_prod_SUB_TYPE_CODE(wfp.prd_prg_id) AS SubCategoryCode,
pkg_rpt_wf_prod_prog.fn_get_all_prod_sponsors(wfp.wf_prod_id) AS Sponsors,             
pkg_rpt_wf_prod_prog.fn_get_all_prod_managers(wfp.wf_prod_id) AS Managers             
--pkg_rpt_wf_prod_prog.FN_GET_wf_prod_cntry(wfp.wf_prod_id) AS Country          
FROM wf_product wfp,            
--wf_instance wfi,
(
        SELECT wf_review_id,
        wf_instance_id,
        WF_REASON_CODE,
        WF_STATE_CODE,
        WF_STATUS_CODE,
        WF_CODE
      FROM wf_instance
      WHERE wf_instance_id IN
        (SELECT MAX(wf_instance_id) wf_instance_id
        FROM wf_instance
        WHERE wf_review_id IS NOT NULL
        GROUP BY wf_review_id
        )
      ) wfi,
lkp_wf_status lst,
user_group g            
WHERE wfp.GOV_DPAC_CODE = g.group_code
and wfp.prd_prg_id is not null
AND wfp.wf_instance_id=wfi.wf_instance_id
and wfi.wf_status_code=lst.wf_status_code
AND wfi.WF_REASON_CODE IN (''NEW_PRD_PRG_EXS'') 
AND wfi.WF_STATE_CODE=''CLOSED'' AND wfi.WF_STATUS_CODE=''APPR''
AND wfi.WF_CODE IN (''DPAC_REVIEW'',''ALT_HANDL_PRES'')'
;
  lv_search_sql := ' where 1 = 1 ';
  IF PV_PID_IN  IS NOT empty THEN
    --lv_prog_sql := lv_prog_sql ||fn_get_in_condition(PV_PID_IN,'pg.prd_prg_id',' IN ');
    --lv_prod_sql := lv_prod_sql || ' AND wfi.review_id in (select * from table(PV_PID_IN))';
    lv_search_sql := lv_search_sql||' AND'||fn_get_in_condition(PV_PID_IN,'pid',' IN ');
    
    END IF;
    IF PV_PID_NOTIN IS NOT empty THEN
      --lv_prog_sql := lv_prog_sql ||fn_get_in_condition(PV_PID_NOTIN,'pg.prd_prg_id',' NOT IN ');
      --lv_prod_sql := lv_prod_sql || ' AND wfi.review_id not in (select * from table(PV_PID_NOTIN))';
      lv_search_sql := lv_search_sql||' AND'||fn_get_in_condition(PV_PID_NOTIN,'pid',' NOT IN ');
    END IF;
    IF PV_PNAME IS NOT NULL THEN
      --lv_prog_sql := lv_prog_sql || ' AND upper(pg.prd_prg_name) like ''' || PV_PNAME || '''';
      --lv_prod_sql := lv_prod_sql || ' AND upper(wfp.product_name) like ''' || PV_PNAME || '''';
      lv_search_sql := lv_search_sql||' AND upper(pname) like ''' || PV_PNAME || '''';
    END IF;
    IF PV_PTYPE IS NOT NULL THEN
      lv_prog_sql := lv_prog_sql || ' AND pg.prd_prg_id in (SELECT prd_prg_id from prod_prog_type ppt where ppt.prd_type_code='''|| PV_PTYPE||''')';
      lv_prod_sql := lv_prod_sql || ' AND wfp.wf_prod_id in (SELECT wf_prod_id from wf_prod_prog_type wft where wft.prd_type_code='''|| PV_PTYPE||''')';
      --lv_search_sql := lv_search_sql || ' AND PCategoryCode ='''||PV_PTYPE||'''';
    END IF;
    IF PV_PSUBTYPE IS NOT NULL THEN
      lv_prog_sql := lv_prog_sql || ' AND pg.prd_prg_id in (SELECT prd_prg_id from prod_prog_sub_type ppst where ppst.prd_sub_type_code='''|| PV_PSUBTYPE||''')';
      lv_prod_sql := lv_prod_sql || ' AND wfp.wf_prod_id in (SELECT wf_prod_id from wf_prod_sub_type wfst where wfst.prd_sub_type_code='''|| PV_PSUBTYPE||''')';
      --lv_search_sql := lv_search_sql || ' AND SubCategoryCode ='''||PV_PSUBTYPE||'''';
    END IF;
    IF PV_PSTATUSCODE IS NOT NULL THEN
      --lv_prog_sql := lv_prog_sql || ' AND upper(pg.prod_status_code)=' || PV_PSTATUSCODE;
      --lv_prod_sql := lv_prod_sql || ' AND upper(wfp.product_name)=' || PV_PSTATUSCODE;
      lv_search_sql := lv_search_sql || ' AND Status ='''||PV_PSTATUSCODE||'''';
    END IF;
    IF PV_PGOVDPACODE IS NOT NULL THEN
      --lv_prog_sql := lv_prog_sql || ' AND upper(g.group_code)=' || PV_PGOVDPACODE;
      --lv_prod_sql := lv_prod_sql || ' AND upper(g.group_code)=' || PV_PGOVDPACODE;
      lv_search_sql := lv_search_sql || ' AND GOV_DPAC_CODE ='''||PV_PGOVDPACODE||'''';
    END IF;
    if PV_PBUSCODE IS NOT NULL then
      lv_prog_sql := lv_prog_sql || ' AND pg.prd_prg_id in (SELECT prd_prg_id from prod_prog_bus ppb where ppb.bus_code='''||PV_PBUSCODE||''')';
      lv_prod_sql := lv_prod_sql || ' AND wfp.wf_prod_id in (SELECT wf_prod_id from wf_prod_bus wfb where wfb.bus_code='''||PV_PBUSCODE||''')';
    END IF;
    if PV_REGIONCODE IS NOT NULL then
       lv_prog_sql := lv_prog_sql || ' AND pg.prd_prg_id in (SELECT prd_prg_id from prod_prog_region ppr where ppr.region_cd='''||PV_REGIONCODE||''')';
       lv_prod_sql := lv_prod_sql || ' AND wfp.wf_prod_id in (SELECT wf_prod_id from wf_prod_region wpr where wpr.region_cd='''||PV_REGIONCODE||''')';
    END IF;
    if PV_COUNTRYCODE IS NOT NULL then
        lv_prog_sql := lv_prog_sql || ' AND pg.prd_prg_id in (SELECT prd_prg_id from prod_prog_country ppc where ppc.country_cd='''|| PV_COUNTRYCODE||''')';
        lv_prod_sql := lv_prod_sql || ' AND wfp.wf_prod_id in (SELECT wf_prod_id from wf_prod_country wpc where wpc.country_cd='''|| PV_COUNTRYCODE||''')';
    END IF;
    IF PV_MGR_SOEID_IN IS NOT empty THEN
      lv_prog_sql :=  lv_prog_sql||' AND pg.prd_prg_id in (SELECT prd_prg_id from prod_prog_manager ppm where';
      lv_prog_sql := lv_prog_sql || fn_get_in_condition(PV_MGR_SOEID_IN,'upper(ppm.mgr_soeid)',' IN ')||' AND ppm.mgr_role_code=''MANAGER'')';
      lv_prod_sql := lv_prod_sql||' AND wfp.wf_prod_id in (SELECT wf_prod_id from wf_prod_manager wpm where';
      lv_prod_sql := lv_prod_sql || fn_get_in_condition(PV_MGR_SOEID_IN,'upper(wpm.mgr_soeid)',' IN ')||' AND wpm.mgr_role_code=''MANAGER'')';
    END IF;
    IF PV_MGR_SOEID_NOTIN IS NOT empty THEN
      lv_prog_sql :=  lv_prog_sql||' AND pg.prd_prg_id in (SELECT prd_prg_id from prod_prog_manager ppm where';
      lv_prog_sql := lv_prog_sql || fn_get_in_condition(PV_MGR_SOEID_NOTIN,'upper(ppm.mgr_soeid)',' NOT IN ')||' AND ppm.mgr_role_code=''MANAGER'')';
      lv_prod_sql := lv_prod_sql||' AND wfp.wf_prod_id in (SELECT wf_prod_id from wf_prod_manager wpm where';
      lv_prod_sql := lv_prod_sql || fn_get_in_condition(PV_MGR_SOEID_NOTIN,'upper(wpm.mgr_soeid)',' NOT IN ')||' AND wpm.mgr_role_code=''MANAGER'')';
    END IF;
    IF PV_SPNSR_SOEID_IN IS NOT empty THEN
      lv_prog_sql :=  lv_prog_sql||' AND pg.prd_prg_id in (SELECT prd_prg_id from prod_prog_manager ppm where';
      lv_prog_sql := lv_prog_sql || fn_get_in_condition(PV_SPNSR_SOEID_IN,'upper(ppm.mgr_soeid)',' IN ')||' AND ppm.mgr_role_code=''SPONSOR'')';
      lv_prod_sql := lv_prod_sql||' AND wfp.wf_prod_id in (SELECT wf_prod_id from wf_prod_manager wpm where';
      lv_prod_sql := lv_prod_sql || fn_get_in_condition(PV_SPNSR_SOEID_IN,'upper(wpm.mgr_soeid)',' IN ')||' AND wpm.mgr_role_code=''SPONSOR'')';
    END IF;
    IF PV_SPNSR_SOEID_NOTIN IS NOT empty THEN
      lv_prog_sql :=  lv_prog_sql||' AND pg.prd_prg_id in (SELECT prd_prg_id from prod_prog_manager ppm where';
      lv_prog_sql           := lv_prog_sql || fn_get_in_condition(PV_SPNSR_SOEID_NOTIN,'upper(ppm.mgr_soeid)',' NOT IN ')||' AND ppm.mgr_role_code=''SPONSOR'')';
      lv_prod_sql := lv_prod_sql||' AND wfp.wf_prod_id in (SELECT wf_prod_id from wf_prod_manager wpm where';
      lv_prod_sql           := lv_prod_sql || fn_get_in_condition(PV_SPNSR_SOEID_NOTIN,'upper(wpm.mgr_soeid)',' NOT IN ')||' AND wpm.mgr_role_code=''SPONSOR'')';
    END IF;
  /* IF PV_REVIEW_ID_IN IS NOT empty THEN
      --lv_prog_sql :=  lv_prog_sql||' AND pg.prd_prg_id in (SELECT prd_prg_id from prod_prog_manager ppm where';
      --lv_prog_sql := lv_prog_sql || fn_get_in_condition(PV_SPNSR_SOEID_IN,'ppm.mgr_soeid',' IN ')||' AND ppm.mgr_role_code=''SPONSOR'')';
      lv_prod_sql := lv_prod_sql||' AND'||fn_get_in_condition(PV_REVIEW_ID_IN,'wfi.wf_review_id',' IN ');
     -- lv_prod_sql := lv_prod_sql || fn_get_in_condition(PV_SPNSR_SOEID_IN,'wpm.mgr_soeid',' IN ');
    END IF;
    IF PV_REVIEW_ID_NOTIN IS NOT empty THEN
      --lv_prog_sql :=  lv_prog_sql||' AND pg.prd_prg_id in (SELECT prd_prg_id from prod_prog_manager ppm where';
     -- lv_prog_sql := lv_prog_sql || fn_get_in_condition(PV_SPNSR_SOEID_NOTIN,'ppm.mgr_soeid',' NOT IN ')||' AND ppm.mgr_role_code=''SPONSOR'')';
      lv_prod_sql := lv_prod_sql||' AND'||fn_get_in_condition(PV_REVIEW_ID_NOTIN,'wfi.wf_review_id',' NOT IN ');
      --lv_prod_sql := lv_prod_sql || fn_get_in_condition(PV_SPNSR_SOEID_NOTIN,'wpm.mgr_soeid',' NOT IN ')||' AND wpm.mgr_role_code=''SPONSOR'')';
    END IF;*/
    
    lv_union_sql      := lv_prog_sql;
    IF pv_programsonly = 0 THEN
      lv_union_sql    := lv_union_sql || ' UNION ALL ' || lv_prod_sql;
    END IF;
    
    lv_union_sql := 'SELECT rownum AS SR_NO_1,prod_prog_all.*,LAST_VALUE(ROWNUM) OVER ( ORDER BY NULL) AS MAX_CNT FROM (' || lv_union_sql || ' ORDER BY pid DESC)prod_prog_all'||lv_search_sql;
    
    lv_select    :='SELECT PID,PName,StatusDesc,PType,ParentID,GoverningDPAC,ReviewDueDate,LastReviewDate,DistributionChannel,Approvers,ApproverDate,rtrim(PCategory,'';'') PCategory,rtrim(Sponsors,'';'') Sponsors,rtrim(Managers,'';'') Managers,MAX_CNT';
    
    lv_union_sql := lv_select || ' FROM (' || lv_union_sql || ') prod_prog_pg WHERE SR_NO_1 BETWEEN '|| pv_startidx ||' AND '||pv_endidx;
    
    DBMS_OUTPUT.PUT_LINE(lv_union_sql);
    --insert into ram_temp(sql_text) values(lv_union_sql);
    commit;
    OPEN Recordset FOR lv_union_sql;
    
  END get_uniondata_portal;
  
  
PROCEDURE get_dpacproducts_portal(
    recordset OUT SYS_REFCURSOR)
AS
BEGIN
  OPEN Recordset FOR SELECT wfp.wf_prod_id
AS
  PID, wfp.product_name
AS
  PName, wfp.product_desc
AS
  Description, NULL
AS
  Status,
  --pst.PROD_STATUS_DESC As Program Type,
  'product'
AS
  PType, wfp.prd_prg_id
AS
  ParentID, g.GROUP_NAME
AS
  GoverningDPAC, NULL
AS
  ReviewDueDate, NULL
AS
  LastReviewDate,
  /*(case
  when (pg.REV_FREQ_MONTHS is not null) then pg.REV_FREQ_MONTHS
  END) AS Periodic Review Cycle,*/
  --to_char(pg.NEXT_PER_REV_DATE, 'mm/dd/yyyy') AS Review Due Date,
  --to_char(pg.LAST_PER_REV_DATE, 'mm/dd/yyyy') AS Last Review Date,
  --Rs.Rev_Status_Desc As Review Status,
  --Pg.Prod_Manufacturer As Product Manufacturer,
  pkg_rpt_wf_prod_prog.Fn_Get_Wf_Prod_Bus(wfp.wf_prod_id)
AS
  DistributionChannel, pkg_workflow.fn_get_all_approvers(wfp.wf_instance_id)
AS
  Approvers, pkg_workflow.get_approval_date(wfp.wf_instance_id)
AS
  ApproverDate, pkg_rpt_wf_prod_prog.FN_GET_wf_prod_TYPE(wfp.wf_prod_id)
AS
  PCategory, pkg_rpt_wf_prod_prog.FN_GET_wf_prod_SUB_TYPE(wfp.wf_prod_id)
AS
  PSubType, pkg_rpt_wf_prod_prog.fn_get_all_prod_sponsors(wfp.wf_prod_id)
AS
  Sponsors, pkg_rpt_wf_prod_prog.fn_get_all_prod_managers(wfp.wf_prod_id)
AS
  Managers
  --pkg_rpt_wf_prod_prog.FN_GET_wf_prod_cntry(wfp.wf_prod_id) AS Country
  --pg.REV_STATUS_CODE AS Review Status Code
  --rs.REV_STATUS_DESC AS Review Status Code
  FROM wf_product wfp, wf_instance wfi, lkp_prod_status pst, user_group g WHERE wfp.GOV_DPAC_CODE = g.group_code AND wfp.wf_instance_id=wfi.wf_instance_id
  --And Pg.Prod_Status_Code = Pst.Prod_Status_Code
  AND wfi.WF_REASON_CODE IN ('NEW_PRD_PRG_EXS');
END get_dpacproducts_portal;

END PKG_RPT_PORTAL;
/

commit;