USE TPCH;

SELECT constraint_name AS 外键名,
       table_name      AS 子表,
       referenced_table_name AS 父表,
       delete_rule     AS 删除规则,
       update_rule     AS 更新规则
FROM information_schema.referential_constraints
WHERE constraint_schema = 'TPCH'
  AND table_name = 'nation';

ALTER TABLE nation DROP FOREIGN KEY fk_nation_region;

ALTER TABLE nation
    ADD CONSTRAINT fk_nation_region FOREIGN KEY (regionkey)
        REFERENCES region (regionkey)
        ON DELETE CASCADE
        ON UPDATE CASCADE;

USE TPCH;

SELECT constraint_name AS 外键名,
       table_name      AS 子表,
       referenced_table_name AS 父表,
       delete_rule     AS 删除规则,
       update_rule     AS 更新规则
FROM information_schema.referential_constraints
WHERE constraint_schema = 'TPCH'
  AND table_name = 'nation';

USE TPCH;

SELECT n.nationkey, n.name AS 国家, n.regionkey, r.name AS 地区
FROM nation n JOIN region r ON n.regionkey = r.regionkey
WHERE r.regionkey = 9;

DELETE FROM region WHERE regionkey = 9;

SELECT COUNT(*) AS '残留国家数(应为0)' FROM nation WHERE regionkey = 9;

ALTER TABLE nation DROP FOREIGN KEY fk_nation_region;

ALTER TABLE nation
    ADD CONSTRAINT fk_nation_region FOREIGN KEY (regionkey)
        REFERENCES region (regionkey)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT;

USE TPCH;

SELECT constraint_name AS 外键名,
       table_name      AS 子表,
       referenced_table_name AS 父表,
       delete_rule     AS 删除规则,
       update_rule     AS 更新规则
FROM information_schema.referential_constraints
WHERE constraint_schema = 'TPCH'
  AND table_name = 'nation';
