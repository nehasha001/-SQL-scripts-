--script to validate if a xml schema migration should be performed
--This is a script is a hold over to deal with a XMLDB db version dependent bug.
--Its usefulness will decrease as users are using more recent versions of db.
-- detects:
--   if xml schema version is less than new schema version
--   if the db and other conditions (see details below) are acceptable to allow a migration to be performed.
-- Example:
-- @isMigrationAllowed.sql

WHENEVER SQLERROR EXIT SQL.SQLCODE;

@@version.sql

EXECUTE dbms_output.put_line('Start is migration allowed. ' || systimestamp);

DEFINE MAXIMUM_DB_VERSION = '11.2.0.3'
DEFINE NEW_WF_SCHEMA_VERSION = '&WORKFLOW_VERSION'


ALTER session set current_schema = "SYS";
/

EXECUTE dbms_output.put_line('Start Data Miner Validation to determine a migration is allowed');


-- Check DB Version. Must be MINIMUM_DB_VERSION or greater.
DECLARE
  v_version VARCHAR(30);
BEGIN
  SELECT DISTINCT DB.VERSION INTO v_version FROM PRODUCT_COMPONENT_VERSION DB;
  IF( v_version > '&MAXIMUM_DB_VERSION') THEN
      RAISE_APPLICATION_ERROR(-20000, 'Database version is ' || v_version || ' which is higher than the db version requirement of  ' || '&MAXIMUM_DB_VERSION' || ' or less.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Datbase version is ' || v_version || ' which meets the requirement of ' || '&MAXIMUM_DB_VERSION' || ' or less.');
  END IF;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Failed database version test, unable to proceed with migration.');
  RAISE;

END;
/

DECLARE
  patch        VARCHAR2(30);
  ver_num      VARCHAR2(30);
  db_ver       VARCHAR2(30);
  valid        NUMBER := 0;
  XMLDiff      XMLType;
  schema_data  CLOB;
  pos          NUMBER;
  startPos     NUMBER;
  endPos       NUMBER;
  v_schema_31  NUMBER;
  maintaindom  NUMBER;
BEGIN
-- Query to determine what db version
  SELECT version INTO db_ver FROM product_component_version WHERE product LIKE 'Oracle Database%' OR product like 'Personal Oracle Database%';
  dbms_output.put_line('Database version: ' || db_ver);
  IF ( INSTR(db_ver, '11.2.0.3') > 0 
    OR INSTR(db_ver, '11.2.0.2') > 0 
    OR INSTR(db_ver, '11.2.0.1') > 0 
    OR INSTR(db_ver, '11.2.0.0') > 0) THEN
  -- Query to determine if the xmlschema has maintaindom setting = true
    SELECT XMLSerialize(CONTENT SCHEMA AS CLOB) INTO schema_data
    FROM DBA_XML_SCHEMAS WHERE schema_url = 'http://xmlns.oracle.com/odmr11/odmr.xsd' AND owner = 'ODMRSYS';
    maintaindom := INSTR(schema_data, 'xdb:maintainDOM="false"', 1, 1);
    dbms_output.put_line('maintaindom result =  ' || to_char(maintaindom) || '(where 0 = maintainDom is set to true)');
    
  -- Query to determine what version of workflow xml schema is currently installed in repository
    BEGIN
      SELECT PROPERTY_STR_VALUE INTO ver_num FROM ODMRSYS.ODMR$REPOSITORY_PROPERTIES WHERE PROPERTY_NAME = 'WF_VERSION';
      dbms_output.put_line('Current xml schema version in database: ' || to_char(ver_num));
    EXCEPTION WHEN NO_DATA_FOUND THEN
      ver_num := '11.2.0.1.9'; -- if it doesn't exist, assume 11.2.0.1.9
      dbms_output.put_line('Schema version did not exist in properties so it will be added : ' || to_char(ver_num));
      INSERT INTO ODMRSYS.ODMR$REPOSITORY_PROPERTIES (PROPERTY_NAME, PROPERTY_STR_VALUE, "COMMENT") VALUES ('WF_VERSION', ver_num, 'Supported workflow version');
      COMMIT;
    END;
  
  -- Query to determine if the maintainDOM patch is installed
    BEGIN
      SELECT PROPERTY_STR_VALUE INTO patch FROM ODMRSYS.ODMR$REPOSITORY_PROPERTIES WHERE PROPERTY_NAME = 'MAINTAIN_DOM_PATCH_INSTALLED';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      patch := 'FALSE';
    END;
    dbms_output.put_line('MaintainDom Patch Installed: ' || patch);
  
    IF (ver_num != '&NEW_WF_SCHEMA_VERSION') THEN -- only check for migration if schema is not equal to schema contained in this release
     dbms_output.put_line('XML Schema migration required.');  
     IF ((INSTR(db_ver, '11.2.0.2') = 0 AND INSTR(db_ver, '11.2.0.1') = 0) OR (maintaindom = 0)) THEN
        dbms_output.put_line('Migration allowed, since db is not 11.2.0.1/11.2.0.2 OR maintainDOM is set to true');
     ELSIF (patch = 'TRUE') then
        dbms_output.put_line('Migration allowed, since the maintainDOM patch is installed.');
     ELSE 
        dbms_output.put_line('Migration not allowed. Stop migration.');
        RAISE_APPLICATION_ERROR(-20000, 'Workflow schema migration not allowed. See log for details.');
     END IF;
    ELSE
     dbms_output.put_line('Migration not required. XML Schema version matches new installation.');
    END IF;
  ELSE
    RAISE_APPLICATION_ERROR(-20000, 'Object Relational xml migration is allowed only for database 11.2.0.3 and earlier.');
  END IF;
END;
/

EXECUTE dbms_output.put_line('Finished is migration allowed. ' || systimestamp);
