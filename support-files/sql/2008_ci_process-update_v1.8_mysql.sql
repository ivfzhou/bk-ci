USE devops_ci_process;
SET NAMES utf8mb4;

DROP PROCEDURE IF EXISTS ci_process_schema_update;

DELIMITER <CI_UBF>

CREATE PROCEDURE ci_process_schema_update()
BEGIN

    DECLARE db VARCHAR(100);
    SET AUTOCOMMIT = 0;
    SELECT DATABASE() INTO db;

	IF NOT EXISTS(SELECT 1
                      FROM information_schema.COLUMNS
                      WHERE TABLE_SCHEMA = db
                        AND TABLE_NAME = 'T_PIPELINE_INFO'
                        AND COLUMN_NAME = 'LATEST_START_TIME') THEN
        ALTER TABLE T_PIPELINE_INFO ADD COLUMN `LATEST_START_TIME` datetime(3) DEFAULT NULL COMMENT '最近启动时间';
    END IF;

    IF EXISTS(SELECT 1
              FROM information_schema.COLUMNS
              WHERE TABLE_SCHEMA = db
                AND TABLE_NAME = 'T_TEMPLATE'
                AND COLUMN_NAME = 'CREATED_TIME') THEN
        ALTER table T_TEMPLATE  MODIFY CREATED_TIME datetime(3) DEFAULT NULL COMMENT '创建时间';
    END IF;

    IF NOT EXISTS(SELECT 1
                  FROM information_schema.COLUMNS
                  WHERE TABLE_SCHEMA = db
                    AND TABLE_NAME = 'T_TEMPLATE'
                    AND COLUMN_NAME = 'UPDATE_TIME') THEN
        ALTER table T_TEMPLATE add column `UPDATE_TIME` datetime(3) DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '更新时间';
    END IF;

    IF NOT EXISTS(SELECT 1
                  FROM information_schema.COLUMNS
                  WHERE TABLE_SCHEMA = db
                    AND TABLE_NAME = 'T_PIPELINE_BUILD_HISTORY'
                    AND COLUMN_NAME = 'UPDATE_TIME') THEN
        ALTER table T_PIPELINE_BUILD_HISTORY add column `UPDATE_TIME` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间';
    END IF;


    IF EXISTS(SELECT 1
                  FROM information_schema.COLUMNS
                  WHERE TABLE_SCHEMA = db
                    AND TABLE_NAME = 'T_PIPELINE_BUILD_HISTORY'
                    AND COLUMN_NAME = 'UPDATE_TIME'
                    AND IS_NULLABLE='YES') THEN
        ALTER table T_PIPELINE_BUILD_HISTORY MODIFY COLUMN `UPDATE_TIME` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间';
    END IF;

    IF NOT EXISTS(SELECT 1
                  FROM information_schema.statistics
                  WHERE TABLE_SCHEMA = db
                    AND TABLE_NAME = 'T_PIPELINE_MODEL_TASK'
                    AND INDEX_NAME = 'INX_TPMT_ATOM_UPDATE_TIME') THEN
        ALTER TABLE T_PIPELINE_MODEL_TASK ADD INDEX `INX_TPMT_ATOM_UPDATE_TIME` (`ATOM_CODE`, `UPDATE_TIME`);
    END IF;

    IF NOT EXISTS(SELECT 1
                  FROM information_schema.statistics
                  WHERE TABLE_SCHEMA = db
                    AND TABLE_NAME = 'T_TEMPLATE_PIPELINE'
                    AND INDEX_NAME = 'INX_TTP_PROJECT_TEMPLATE_VERSION') THEN
        ALTER TABLE T_TEMPLATE_PIPELINE ADD INDEX `INX_TTP_PROJECT_TEMPLATE_VERSION` (`PROJECT_ID`, `TEMPLATE_ID`, `VERSION`);
    END IF;

    IF NOT EXISTS(SELECT 1
                  FROM information_schema.statistics
                  WHERE TABLE_SCHEMA = db
                    AND TABLE_NAME = 'T_PIPELINE_SETTING_VERSION'
                    AND INDEX_NAME = 'UNI_INX_TPSV_PROJECT_PIPELINE_VERSION') THEN
        ALTER TABLE T_PIPELINE_SETTING_VERSION ADD UNIQUE INDEX `UNI_INX_TPSV_PROJECT_PIPELINE_VERSION` (`PROJECT_ID`, `PIPELINE_ID`, `VERSION`);
    END IF;

    IF NOT EXISTS(SELECT 1
                  FROM information_schema.statistics
                  WHERE TABLE_SCHEMA = db
                    AND TABLE_NAME = 'T_PIPELINE_WEBHOOK'
                    AND INDEX_NAME = 'UNI_INX_TPW_PROJECT_PIPELINE_TASK') THEN
        ALTER TABLE T_PIPELINE_WEBHOOK ADD UNIQUE INDEX `UNI_INX_TPW_PROJECT_PIPELINE_TASK` (`PROJECT_ID`, `PIPELINE_ID`,`TASK_ID`);
    END IF;

    IF NOT EXISTS(SELECT 1
                  FROM information_schema.statistics
                  WHERE TABLE_SCHEMA = db
                    AND TABLE_NAME = 'T_PIPELINE_FAVOR'
                    AND INDEX_NAME = 'UNI_INX_TPF_PROJECT_PIPELINE_USER') THEN
        ALTER TABLE T_PIPELINE_FAVOR ADD UNIQUE INDEX `UNI_INX_TPF_PROJECT_PIPELINE_USER` (`PROJECT_ID`, `PIPELINE_ID`,`CREATE_USER`);
    END IF;

    IF NOT EXISTS(SELECT 1
                  FROM information_schema.statistics
                  WHERE TABLE_SCHEMA = db
                    AND TABLE_NAME = 'T_PIPELINE_LABEL_PIPELINE'
                    AND INDEX_NAME = 'UNI_INX_TPLP_PROJECT_PIPELINE_LABEL') THEN
        ALTER TABLE T_PIPELINE_LABEL_PIPELINE ADD UNIQUE INDEX `UNI_INX_TPLP_PROJECT_PIPELINE_LABEL` (`PROJECT_ID`, `PIPELINE_ID`,`LABEL_ID`);
    END IF;

    IF NOT EXISTS(SELECT 1
                  FROM information_schema.statistics
                  WHERE TABLE_SCHEMA = db
                    AND TABLE_NAME = 'T_PIPELINE_LABEL'
                    AND INDEX_NAME = 'UNI_INX_TPL_PROJECT_GROUP_NAME') THEN
        ALTER TABLE T_PIPELINE_LABEL ADD UNIQUE INDEX `UNI_INX_TPL_PROJECT_GROUP_NAME` (`PROJECT_ID`, `GROUP_ID`,`NAME`);
    END IF;

    IF NOT EXISTS(SELECT 1
                  FROM information_schema.statistics
                  WHERE TABLE_SCHEMA = db
                    AND TABLE_NAME = 'T_PIPELINE_WEBHOOK_QUEUE'
                    AND INDEX_NAME = 'UNI_INX_TPWQ_PROJECT_BUILD') THEN
        ALTER TABLE T_PIPELINE_WEBHOOK_QUEUE ADD UNIQUE INDEX `UNI_INX_TPWQ_PROJECT_BUILD` (`PROJECT_ID`, `BUILD_ID`);
    END IF;

    IF NOT EXISTS(SELECT 1
                  FROM information_schema.statistics
                  WHERE TABLE_SCHEMA = db
                    AND TABLE_NAME = 'T_PIPELINE_BUILD_HISTORY'
                    AND INDEX_NAME = 'INX_TPBH_PROJECT_PIPELINE_NUM') THEN
        ALTER TABLE T_PIPELINE_BUILD_HISTORY ADD INDEX `INX_TPBH_PROJECT_PIPELINE_NUM` (`PROJECT_ID`, `PIPELINE_ID`, `BUILD_NUM`);
    END IF;

    IF NOT EXISTS(SELECT 1
                  FROM information_schema.statistics
                  WHERE TABLE_SCHEMA = db
                    AND TABLE_NAME = 'T_PIPELINE_BUILD_HISTORY'
                    AND INDEX_NAME = 'INX_TPBH_PROJECT_PIPELINE_START_TIME') THEN
        ALTER TABLE T_PIPELINE_BUILD_HISTORY ADD INDEX `INX_TPBH_PROJECT_PIPELINE_START_TIME` (`PROJECT_ID`, `PIPELINE_ID`, `START_TIME`);
    END IF;

    IF NOT EXISTS(SELECT 1
                  FROM information_schema.statistics
                  WHERE TABLE_SCHEMA = db
                    AND TABLE_NAME = 'T_PIPELINE_BUILD_TASK'
                    AND INDEX_NAME = 'INX_TPBT_PROJECT_BUILD_CONTAINER_SEQ') THEN
        ALTER TABLE T_PIPELINE_BUILD_TASK ADD INDEX `INX_TPBT_PROJECT_BUILD_CONTAINER_SEQ` (`PROJECT_ID`, `BUILD_ID`, `CONTAINER_ID`, `TASK_SEQ`);
    END IF;

    IF NOT EXISTS(SELECT 1
                  FROM information_schema.statistics
                  WHERE TABLE_SCHEMA = db
                    AND TABLE_NAME = 'T_PIPELINE_BUILD_CONTAINER'
                    AND INDEX_NAME = 'INX_TPBC_PROJECT_BUILD_SEQ') THEN
        ALTER TABLE T_PIPELINE_BUILD_CONTAINER ADD INDEX `INX_TPBC_PROJECT_BUILD_SEQ` (`PROJECT_ID`, `BUILD_ID`, `SEQ`);
    END IF;

    IF EXISTS(SELECT 1
              FROM information_schema.statistics
              WHERE TABLE_SCHEMA = db
                AND TABLE_NAME = 'T_PIPELINE_MODEL_TASK'
                AND INDEX_NAME = 'ATOM_CODE') THEN
        ALTER TABLE T_PIPELINE_MODEL_TASK DROP INDEX `ATOM_CODE`;
    END IF;

    IF EXISTS(SELECT 1
              FROM information_schema.statistics
              WHERE TABLE_SCHEMA = db
                AND TABLE_NAME = 'T_PIPELINE_SETTING_VERSION'
                AND INDEX_NAME = 'IDX_PIPELINE_ID_VER') THEN
        ALTER TABLE T_PIPELINE_SETTING_VERSION DROP INDEX `IDX_PIPELINE_ID_VER`;
    END IF;

    IF EXISTS(SELECT 1
              FROM information_schema.statistics
              WHERE TABLE_SCHEMA = db
                AND TABLE_NAME = 'T_PIPELINE_WEBHOOK'
                AND INDEX_NAME = 'UNIQ_PIPELINE_ID_TASK_ID') THEN
        ALTER TABLE T_PIPELINE_WEBHOOK DROP INDEX `UNIQ_PIPELINE_ID_TASK_ID`;
    END IF;

    IF EXISTS(SELECT 1
              FROM information_schema.statistics
              WHERE TABLE_SCHEMA = db
                AND TABLE_NAME = 'T_PIPELINE_FAVOR'
                AND INDEX_NAME = 'PIPELINE_ID') THEN
        ALTER TABLE T_PIPELINE_FAVOR DROP INDEX `PIPELINE_ID`;
    END IF;

    IF EXISTS(SELECT 1
              FROM information_schema.statistics
              WHERE TABLE_SCHEMA = db
                AND TABLE_NAME = 'T_PIPELINE_LABEL_PIPELINE'
                AND INDEX_NAME = 'PIPELINE_ID') THEN
        ALTER TABLE T_PIPELINE_LABEL_PIPELINE DROP INDEX `PIPELINE_ID`;
    END IF;

    IF EXISTS(SELECT 1
              FROM information_schema.statistics
              WHERE TABLE_SCHEMA = db
                AND TABLE_NAME = 'T_PIPELINE_LABEL'
                AND INDEX_NAME = 'GROUP_ID') THEN
        ALTER TABLE T_PIPELINE_LABEL DROP INDEX `GROUP_ID`;
    END IF;

    IF EXISTS(SELECT 1
              FROM information_schema.statistics
              WHERE TABLE_SCHEMA = db
                AND TABLE_NAME = 'T_PIPELINE_WEBHOOK_QUEUE'
                AND INDEX_NAME = 'UNIQ_BUILD_ID') THEN
        ALTER TABLE T_PIPELINE_WEBHOOK_QUEUE DROP INDEX `UNIQ_BUILD_ID`;
    END IF;

    IF EXISTS(SELECT 1
              FROM information_schema.statistics
              WHERE TABLE_SCHEMA = db
                AND TABLE_NAME = 'T_PIPELINE_BUILD_HISTORY'
                AND INDEX_NAME = 'LATEST_BUILD_KEY') THEN
        ALTER TABLE T_PIPELINE_BUILD_HISTORY DROP INDEX `LATEST_BUILD_KEY`;
    END IF;
	
	IF NOT EXISTS(SELECT 1
			  FROM information_schema.COLUMNS
			  WHERE TABLE_SCHEMA = db
				AND TABLE_NAME = 'T_PIPELINE_BUILD_COMMITS'
				AND COLUMN_NAME = 'URL') THEN
        ALTER table T_PIPELINE_BUILD_COMMITS add column `URL` varcher(255) NOT NULL COMMENT "仓库url";
    END IF;
	
	IF NOT EXISTS(SELECT 1
		  FROM information_schema.COLUMNS
		  WHERE TABLE_SCHEMA = db
			AND TABLE_NAME = 'T_PIPELINE_BUILD_COMMITS'
			AND COLUMN_NAME = 'EVENT_TYPE') THEN
        ALTER table T_PIPELINE_BUILD_COMMITS add column `EVENT_TYPE` varcher(32) NOT NULL COMMENT "触发事件类型";
    END IF;

    COMMIT;
END <CI_UBF>
DELIMITER ;
COMMIT;
CALL ci_process_schema_update();
