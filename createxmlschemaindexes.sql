-- creates either binary or OR xml indexes on the workflow column
-- This procedure is run during the initial install of the repository as well as in upgrades.

EXECUTE dbms_output.put_line('Start Creation of XML Document Indexes.' || systimestamp);

-- Create Indexes on XML system generate tables to improve xml query performance
-- Node id indexes
DECLARE
  db_ver  VARCHAR2(30);
  SYS_TABLE_NAME  VARCHAR2(30);
BEGIN
  SELECT VERSION INTO db_ver FROM product_component_version WHERE product LIKE 'Oracle Database%' OR product like 'Personal Oracle Database %' ;
  IF (db_ver >= '11.2.0.4') THEN
    -- The binary xml indices are not dropped during a upgrade|migration.
    -- In order to allow this procedure to run during an upgrade, the index is dropped first.
    -- This will allow this index definition to change over time and be applied fresh
    -- each time a upgrade is performed.
    EXECUTE IMMEDIATE 'ALTER user ODMRSYS quota 200M on SYSTEM';
      
    BEGIN
      DBMS_XMLINDEX.DROPPARAMETER('ODMR$WF_XMLINDEX_PARAM');
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX ODMRSYS.ODMR$WORKFLOW_XMLINDEX' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    DBMS_XMLINDEX.REGISTERPARAMETER('ODMR$WF_XMLINDEX_PARAM',
      'XMLTable ODMR$WF_NODES_IDX XMLNAMESPACES(DEFAULT ''http://xmlns.oracle.com/odmr11''),
            ''/WorkflowProcess/Nodes/*''
            COLUMNS NodeType     VARCHAR2(30) PATH ''name()'',
                    NodeId       VARCHAR2(30) PATH ''@Id'',
                    NodeName     VARCHAR2(30) PATH ''@Name'',
                    NodeStatus   VARCHAR2(30) PATH ''@Status''
       GROUP MODEL_GROUP
       XMLTable ODMR$WF_MODELS_IDX XMLNAMESPACES(DEFAULT ''http://xmlns.oracle.com/odmr11''),
            ''/WorkflowProcess/Nodes/*/Models/*''
            COLUMNS ModelType     VARCHAR2(30) PATH ''name()'',
                    ModelId       VARCHAR2(30) PATH ''@Id'',
                    ModelName     VARCHAR2(30) PATH ''@Name'',
                    ModelStatus   VARCHAR2(30) PATH ''@Status''             
       GROUP LINK
       XMLTable ODMR$WF_LINK_IDX XMLNAMESPACES(DEFAULT ''http://xmlns.oracle.com/odmr11''),
            ''/WorkflowProcess/Links/Link''
            COLUMNS LinkId       VARCHAR2(30) PATH ''@Id'',
                    LinkName     VARCHAR2(30) PATH ''@Name'',
                    LinkFrom     VARCHAR2(30) PATH ''@From'',
                    LinkTo       VARCHAR2(30) PATH ''@To''
    ');
                  
    EXECUTE IMMEDIATE 'CREATE INDEX ODMRSYS.ODMR$WORKFLOW_XMLINDEX ON ODMRSYS.ODMR$WORKFLOWS(WORKFLOW_DATA) INDEXTYPE IS XDB.XMLIndex PARAMETERS(''param ODMR$WF_XMLINDEX_PARAM'')';
    DBMS_OUTPUT.PUT_LINE('Index ODMR$WORKFLOW_XMLINDEX created successfully.');
    
  ELSE

    -- The following indexes are generated for the OR xml storage.
    -- Since the column is dropped during upgrade|migration, there should be no need to drop these indices.
    -- However, the drops are added for robustness given that sys admins may need to run this script
    -- independently or the install and upgrade process.
    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."CLASSIFICATION_BUILD_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."CLASSIFICATION_BUILD_N_ID_IDX"
    ON "ODMRSYS"."CLASSIFICATION_BUILD_TAB" (extractValue(OBJECT_VALUE, ''/ClassificationBuild/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index CLASSIFICATION_BUILD_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."DATA_PROFILE_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."DATA_PROFILE_N_ID_IDX"
    ON "ODMRSYS"."DATA_PROFILE_TAB" (extractValue(OBJECT_VALUE, ''/DataProfile/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index DATA_PROFILE_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."DATA_SOURCE_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."DATA_SOURCE_N_ID_IDX"
    ON "ODMRSYS"."DATA_SOURCE_TAB" (extractValue(OBJECT_VALUE, ''/DataSource/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index DATA_SOURCE_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."CREATE_TABLE_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."CREATE_TABLE_N_ID_IDX"
    ON "ODMRSYS"."CREATE_TABLE_TAB" (extractValue(OBJECT_VALUE, ''/CreateTable/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index CREATE_TABLE_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."UPDATE_TABLE_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."UPDATE_TABLE_N_ID_IDX"
    ON "ODMRSYS"."UPDATE_TABLE_TAB" (extractValue(OBJECT_VALUE, ''/UpdateTable/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index UPDATE_TABLE_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."AGGREGATION_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."AGGREGATION_N_ID_IDX"
    ON "ODMRSYS"."AGGREGATION_TAB" (extractValue(OBJECT_VALUE, ''/Aggregation/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index AGGREGATION_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."TRANSFORMATION_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."TRANSFORMATION_N_ID_IDX"
    ON "ODMRSYS"."TRANSFORMATION_TAB" (extractValue(OBJECT_VALUE, ''/Transformation/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index TRANSFORMATION_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."JOIN_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."JOIN_N_ID_IDX"
    ON "ODMRSYS"."JOIN_TAB" (extractValue(OBJECT_VALUE, ''/Join/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index JOIN_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."BUILD_TEXT_REF_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."BUILD_TEXT_REF_N_ID_IDX"
    ON "ODMRSYS"."BUILD_TEXT_REF_TAB" (extractValue(OBJECT_VALUE, ''/BuildTextRef/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index JOIN_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."APPLY_TEXT_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."APPLY_TEXT_N_ID_IDX"
    ON "ODMRSYS"."APPLY_TEXT_TAB" (extractValue(OBJECT_VALUE, ''/ApplyText/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index APPLY_TEXT_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."BUILD_TEXT_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."BUILD_TEXT_N_ID_IDX"
    ON "ODMRSYS"."BUILD_TEXT_TAB" (extractValue(OBJECT_VALUE, ''/BuildText/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index BUILD_TEXT_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."SAMPLE_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."SAMPLE_N_ID_IDX"
    ON "ODMRSYS"."SAMPLE_TAB" (extractValue(OBJECT_VALUE, ''/Sample/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index SAMPLE_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."COLUMN_FILTER_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."COLUMN_FILTER_N_ID_IDX"
    ON "ODMRSYS"."COLUMN_FILTER_TAB" (extractValue(OBJECT_VALUE, ''/ColumnFilter/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index COLUMN_FILTER_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."ROW_FILTER_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."ROW_FILTER_N_ID_IDX"
    ON "ODMRSYS"."ROW_FILTER_TAB" (extractValue(OBJECT_VALUE, ''/RowFilter/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index ROW_FILTER_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."REGRESSION_BUILD_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."REGRESSION_BUILD_N_ID_IDX"
    ON "ODMRSYS"."REGRESSION_BUILD_TAB" (extractValue(OBJECT_VALUE, ''/RegressionBuild/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index REGRESSION_BUILD_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."CLUSTERING_BUILD_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."CLUSTERING_BUILD_N_ID_IDX"
    ON "ODMRSYS"."CLUSTERING_BUILD_TAB" (extractValue(OBJECT_VALUE, ''/ClusteringBuild/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index CLUSTERING_BUILD_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."ASSOCIATION_BUILD_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."ASSOCIATION_BUILD_N_ID_IDX"
    ON "ODMRSYS"."ASSOCIATION_BUILD_TAB" (extractValue(OBJECT_VALUE, ''/AssociationBuild/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index ASSOCIATION_BUILD_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."FEATURE_EXT_BUILD_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."FEATURE_EXT_BUILD_N_ID_IDX"
    ON "ODMRSYS"."FEATURE_EXT_BUILD_TAB" (extractValue(OBJECT_VALUE, ''/FeatureExtractionBuild/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index FEATURE_EXT_BUILD_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."ANOMALY_DET_BUILD_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."ANOMALY_DET_BUILD_N_ID_IDX"
    ON "ODMRSYS"."ANOMALY_DETECT_BUILD_TAB" (extractValue(OBJECT_VALUE, ''/AnomalyDetectionBuild/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index ANOMALY_DET_BUILD_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."MODEL_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."MODEL_N_ID_IDX"
    ON "ODMRSYS"."MODEL_TAB" (extractValue(OBJECT_VALUE, ''/Model/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index MODEL_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."APPLY_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."APPLY_N_ID_IDX"
    ON "ODMRSYS"."APPLY_TAB" (extractValue(OBJECT_VALUE, ''/Apply/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index APPLY_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."TEST_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."TEST_N_ID_IDX"
    ON "ODMRSYS"."TEST_TAB" (extractValue(OBJECT_VALUE, ''/Test/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index TEST_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."MODEL_DETAILS_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."MODEL_DETAILS_N_ID_IDX"
    ON "ODMRSYS"."MODEL_DETAILS_TAB" (extractValue(OBJECT_VALUE, ''/ModelDetails/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index MODEL_DETAILS_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."TEST_DETAILS_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."TEST_DETAILS_N_ID_IDX"
    ON "ODMRSYS"."TEST_DETAILS_TAB" (extractValue(OBJECT_VALUE, ''/TestDetails/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index TEST_DETAILS_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."FILTER_DETAILS_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."FILTER_DETAILS_N_ID_IDX"
    ON "ODMRSYS"."FILTER_DETAILS_TAB" (extractValue(OBJECT_VALUE, ''/FilterDetails/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index FILTER_DETAILS_N_ID_IDX created successfully.');

    -- indexes for model collection ids
    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."DECISION_TREE_M_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."DECISION_TREE_M_ID_IDX"
    ON "ODMRSYS"."DECISION_TREE_M_TAB" (extractValue(OBJECT_VALUE, ''/DecisionTreeModel/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index DECISION_TREE_M_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."NAIVE_BAYES_M_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."NAIVE_BAYES_M_ID_IDX"
    ON "ODMRSYS"."NAIVE_BAYES_M_TAB" (extractValue(OBJECT_VALUE, ''/NaiveBayesModel/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index NAIVE_BAYES_M_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."SUPT_VECTOR_MACH_C_M_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."SUPT_VECTOR_MACH_C_M_ID_IDX"
    ON "ODMRSYS"."SUPT_VECTOR_MACH_C_M_TAB" (extractValue(OBJECT_VALUE, ''/CSupportVectorMachineModel/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index SUPT_VECTOR_MACH_C_M_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."GEN_LINEAR_C_M_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."GEN_LINEAR_C_M_ID_IDX"
    ON "ODMRSYS"."GEN_LINEAR_C_M_TAB" (extractValue(OBJECT_VALUE, ''/CGeneralizedLinearModel/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index GEN_LINEAR_C_M_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."KMEANS_M_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."KMEANS_M_ID_IDX"
    ON "ODMRSYS"."KMEANS_M_TAB" (extractValue(OBJECT_VALUE, ''/KMeansModel/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index KMEANS_M_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."OCLUSTER_M_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."OCLUSTER_M_ID_IDX"
    ON "ODMRSYS"."OCLUSTER_M_TAB" (extractValue(OBJECT_VALUE, ''/OClusterModel/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index OCLUSTER_M_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."NON_NEG_MATRIX_M_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."NON_NEG_MATRIX_M_ID_IDX"
    ON "ODMRSYS"."NON_NEG_MATRIX_M_TAB" (extractValue(OBJECT_VALUE, ''/NonNegativeMatrixFactorModel/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index NON_NEG_MATRIX_M_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."SUPT_VECTOR_MACH_R_M_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
        
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."SUPT_VECTOR_MACH_R_M_ID_IDX"
    ON "ODMRSYS"."SUPT_VECTOR_MACH_R_M_TAB" (extractValue(OBJECT_VALUE, ''/RSupportVectorMachineModel/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index SUPT_VECTOR_MACH_R_M_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."GEN_LINEAR_R_M_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."GEN_LINEAR_R_M_ID_IDX"
    ON "ODMRSYS"."GEN_LINEAR_R_M_TAB" (extractValue(OBJECT_VALUE, ''/RGeneralizedLinearModel/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index GEN_LINEAR_R_M_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."ANOM_DETECT_M_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."ANOM_DETECT_M_ID_IDX"
    ON "ODMRSYS"."ANOM_DETECT_M_TAB" (extractValue(OBJECT_VALUE, ''/AnomalyDetectionModel/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index ANOM_DETECT_M_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."APRIORI_M_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."APRIORI_M_ID_IDX"
    ON "ODMRSYS"."APRIORI_M_TAB" (extractValue(OBJECT_VALUE, ''/AprioriModel/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index APRIORI_M_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."MINING_ATTRIBUTE_NM_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."MINING_ATTRIBUTE_NM_IDX"
    ON "ODMRSYS"."MINING_ATTRIBUTE_TAB" (extractValue(OBJECT_VALUE, ''/MiningAttribute/@Name''))';
    DBMS_OUTPUT.PUT_LINE('Index MINING_ATTRIBUTE_NM_IDX created successfully.');
    
    -- Create indexes on Link element
    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."LINKS_TAB_FROM_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."LINKS_TAB_FROM_IDX"
    ON "ODMRSYS"."LINKS_TAB" (extractValue(OBJECT_VALUE, ''/Link/@From''))';
    DBMS_OUTPUT.PUT_LINE('Index LINKS_TAB_FROM_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."LINKS_TAB_TO_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."LINKS_TAB_TO_IDX"
    ON "ODMRSYS"."LINKS_TAB" (extractValue(OBJECT_VALUE, ''/Link/@To''))';
    DBMS_OUTPUT.PUT_LINE('Index LINKS_TAB_TO_IDX created successfully.');

    -- create indexes for new nodes
    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."DYNAMIC_PREDICT_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."DYNAMIC_PREDICT_N_ID_IDX"
    ON "ODMRSYS"."DYNAMIC_PREDICT_TAB" (extractValue(OBJECT_VALUE, ''/DynamicPrediction/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index DYNAMIC_PREDICT_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."DYNAMIC_FEATURE_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."DYNAMIC_FEATURE_N_ID_IDX"
    ON "ODMRSYS"."DYNAMIC_FEATURE_TAB" (extractValue(OBJECT_VALUE, ''/DynamicFeature/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index DYNAMIC_FEATURE_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."DYNAMIC_CLUSTER_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."DYNAMIC_CLUSTER_N_ID_IDX"
    ON "ODMRSYS"."DYNAMIC_CLUSTER_TAB" (extractValue(OBJECT_VALUE, ''/DynamicCluster/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index DYNAMIC_CLUSTER_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."DYNAMIC_ANOMALY_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."DYNAMIC_ANOMALY_N_ID_IDX"
    ON "ODMRSYS"."DYNAMIC_ANOMALY_TAB" (extractValue(OBJECT_VALUE, ''/DynamicAnomaly/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index DYNAMIC_ANOMALY_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."SQL_QUERY_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."SQL_QUERY_N_ID_IDX"
    ON "ODMRSYS"."SQL_QUERY_TAB" (extractValue(OBJECT_VALUE, ''/SQLQuery/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index SQL_QUERY_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."GRAPH_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."GRAPH_N_ID_IDX"
    ON "ODMRSYS"."GRAPH_TAB" (extractValue(OBJECT_VALUE, ''/Graph/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index GRAPH_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."JSON_QUERY_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."JSON_QUERY_N_ID_IDX"
    ON "ODMRSYS"."JSON_QUERY_TAB" (extractValue(OBJECT_VALUE, ''/JSONQuery/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index JSON_QUERY_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."EM_M_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."EM_M_N_ID_IDX"
    ON "ODMRSYS"."EM_M_TAB" (extractValue(OBJECT_VALUE, ''/ExpectationMaximizationModel/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index EM_M_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."SVD_M_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."SVD_M_N_ID_IDX"
    ON "ODMRSYS"."SVD_M_TAB" (extractValue(OBJECT_VALUE, ''/SVDModel/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index SVD_M_N_ID_IDX created successfully.');

    BEGIN
      EXECUTE IMMEDIATE 'DROP INDEX "ODMRSYS"."PCA_M_N_ID_IDX"' ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE INDEX "ODMRSYS"."PCA_M_N_ID_IDX"
    ON "ODMRSYS"."PCA_M_TAB" (extractValue(OBJECT_VALUE, ''/PCAModel/@Id''))';
    DBMS_OUTPUT.PUT_LINE('Index PCA_M_N_ID_IDX created successfully.');
    
  END IF;
END;
/

EXECUTE dbms_output.put_line('End Creation of XML Document Indexes.' || systimestamp);
