--    DESCRIPTION
--      This script grants SELECT on SH tables 
--      required to support Data Miner Cue Card demos
--      
--      The script is to be run in SYS account
--    NOTES
--       &&1    Name of the DM user
--    MODIFIED   (MM/DD/YY)
--       mbkelly     07/31/10 - copied and revised from rbms/demo to support
--                               Data Miner 
-- Example:
-- @dmshgrants.sql DMUSER
--------------------------------------------------------------------------------

DEFINE USER_ACCOUNT = &&1
SET SERVEROUTPUT ON
EXECUTE dbms_output.put_line('');
EXECUTE dbms_output.put_line('Grant access to SH schema objects FOR: ' || Q'[&USER_ACCOUNT]');
EXECUTE dbms_output.put_line('');

DECLARE
v_sql varchar2(100);
BEGIN
-- unlock SH Account (MK:prompts for new password so I have commented this out)
--PASSWORD SH UNLOCK;
BEGIN
v_sql := q'[GRANT SELECT ON sh.customers TO "&USER_ACCOUNT"]';
EXECUTE IMMEDIATE v_sql;
DBMS_OUTPUT.PUT_LINE (v_sql ||': succeeded');
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE (v_sql ||': sh.customers - no table/view exists');
END;
BEGIN
v_sql := q'[GRANT SELECT ON sh.sales TO "&USER_ACCOUNT"]';
EXECUTE IMMEDIATE v_sql;
DBMS_OUTPUT.PUT_LINE (v_sql ||': succeeded');
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE (v_sql ||': sh.sales - no table/view exists');
END;
BEGIN
v_sql := q'[GRANT SELECT ON sh.products TO "&USER_ACCOUNT"]';
EXECUTE IMMEDIATE v_sql;
DBMS_OUTPUT.PUT_LINE (v_sql ||': succeeded');
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE (v_sql ||': sh.products - no table/view exists');
END;
BEGIN
v_sql := q'[GRANT SELECT ON sh.supplementary_demographics TO "&USER_ACCOUNT"]';
EXECUTE IMMEDIATE v_sql;
DBMS_OUTPUT.PUT_LINE (v_sql ||': succeeded');
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE (v_sql ||': sh.supplementary_demographics - no table/view exists');
END;
BEGIN
v_sql := q'[GRANT SELECT ON sh.countries TO "&USER_ACCOUNT"]';
EXECUTE IMMEDIATE v_sql;
DBMS_OUTPUT.PUT_LINE (v_sql ||': succeeded');
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE (v_sql ||': sh.countries - no table/view exists');
END;
BEGIN
v_sql := q'[GRANT SELECT ON sh.cal_month_sales_mv TO "&USER_ACCOUNT"]';
EXECUTE IMMEDIATE v_sql;
DBMS_OUTPUT.PUT_LINE (v_sql ||': succeeded');
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE (v_sql ||': sh.cal_month_sales_mv - no table/view exists');
END;
BEGIN
v_sql := q'[GRANT SELECT ON sh.channels TO "&USER_ACCOUNT"]';
EXECUTE IMMEDIATE v_sql;
DBMS_OUTPUT.PUT_LINE (v_sql ||': succeeded');
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE (v_sql ||': sh.channels - no table/view exists');
END;
BEGIN
v_sql := q'[GRANT SELECT ON sh.costs TO "&USER_ACCOUNT"]';
EXECUTE IMMEDIATE v_sql;
DBMS_OUTPUT.PUT_LINE (v_sql ||': succeeded');
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE (v_sql ||': sh.costs - no table/view exists');
END;
BEGIN
v_sql := q'[GRANT SELECT ON sh.FWEEK_PSCAT_SALES_MV TO "&USER_ACCOUNT"]';
EXECUTE IMMEDIATE v_sql;
DBMS_OUTPUT.PUT_LINE (v_sql ||': succeeded');
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE (v_sql ||': sh.FWEEK_PSCAT_SALES_MV - no table/view exists');
END;
BEGIN
v_sql := q'[GRANT SELECT ON sh.promotions TO "&USER_ACCOUNT"]';
EXECUTE IMMEDIATE v_sql;
DBMS_OUTPUT.PUT_LINE (v_sql ||': succeeded');
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE (v_sql ||': sh.promotions - no table/view exists');
END;
BEGIN
v_sql := q'[GRANT SELECT ON sh.times TO "&USER_ACCOUNT"]';
EXECUTE IMMEDIATE v_sql;
DBMS_OUTPUT.PUT_LINE (v_sql ||': succeeded');
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE (v_sql ||': sh.times - no table/view exists');
END;

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE ('Exiting early from process of GRANTING demo data');
END;
/