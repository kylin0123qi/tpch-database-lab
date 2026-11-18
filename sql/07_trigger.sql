USE TPCH;

DROP TABLE IF EXISTS StockAlert_Log;

CREATE TABLE StockAlert_Log (
    alert_id   INT       NOT NULL AUTO_INCREMENT COMMENT '报警流水号',
    partkey    INT       NOT NULL                COMMENT '零件编号',
    suppkey    INT       NOT NULL                COMMENT '供应商编号',
    alert_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '报警时间',
    CONSTRAINT pk_stockalert_log PRIMARY KEY (alert_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存预警日志表';

USE TPCH;

DROP TRIGGER IF EXISTS trg_partsupp_lowstock;

DELIMITER $$

CREATE TRIGGER trg_partsupp_lowstock
    AFTER UPDATE
    ON partsupp
    FOR EACH ROW
BEGIN
    IF NEW.availqty < 10 AND OLD.availqty >= 10 THEN
        INSERT INTO StockAlert_Log (partkey, suppkey)
        VALUES (NEW.partkey, NEW.suppkey);
    END IF;
END$$

DELIMITER ;

SELECT trigger_name      AS 触发器名,
       event_manipulation AS 事件名字,
       event_object_table AS 所在表,
       action_timing      AS 发生时机
FROM information_schema.triggers
WHERE trigger_schema = 'TPCH';

USE TPCH;

-- 测试前复位：恢复安全值并清空日志
UPDATE partsupp SET availqty = 50 WHERE partkey = 2 AND suppkey = 102;
UPDATE partsupp SET availqty = 15 WHERE partkey = 2 AND suppkey = 101;
DELETE FROM StockAlert_Log;

SELECT partkey, suppkey, availqty FROM partsupp
WHERE partkey = 2 AND suppkey IN (101, 102) ORDER BY suppkey;

-- 测试一：50 -> 5，跌破阈值，应当触发
UPDATE partsupp SET availqty = 5 WHERE partkey = 2 AND suppkey = 102;

-- 测试二：15 -> 12，新值仍 >= 10，不应当触发
UPDATE partsupp SET availqty = 12 WHERE partkey = 2 AND suppkey = 101;

SELECT partkey, suppkey, availqty FROM partsupp
WHERE partkey = 2 AND suppkey IN (101, 102) ORDER BY suppkey;

-- 查看预警日志
SELECT * FROM StockAlert_Log;

-- 本来就在预警区的 (4,102) 库存为 5，再降到 4，不应重复报警
UPDATE partsupp SET availqty = 4 WHERE partkey = 4 AND suppkey = 102;

SELECT COUNT(*) AS '日志条数(应为1)' FROM StockAlert_Log;
