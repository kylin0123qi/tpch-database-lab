USE TPCH;

-- 第 2 周探索任务 1：插入数据并验证实体 / 参照完整性

-- 先插父表，再插子表
INSERT INTO Region (regionkey, name, comment) VALUES (5, 'TEST_REGION', '测试新地区');
INSERT INTO Nation (nationkey, name, regionkey, comment) VALUES (10, 'TEST_NATION', 5, '属于新地区的国家');

-- regionkey 在 Region 中不存在，预期报错 1452
INSERT INTO Nation (nationkey, name, regionkey, comment) VALUES (11, 'INVALID_NATION', 99, '测试外键约束');

-- 主键重复，预期报错 1062
INSERT INTO Region (regionkey, name, comment) VALUES (5, 'DUPLICATE_REGION', '测试主键约束');


-- 第 3 周探索任务 2：条件查询

SELECT name, phone FROM Customer WHERE acctbal < 10000;


-- 第 4 周探索任务 3：派生表分组统计

SELECT C.name, B.order_count
FROM Customer C,
     (SELECT custkey, COUNT(*) AS order_count
      FROM Orders GROUP BY custkey HAVING COUNT(*) > 1) AS B
WHERE C.custkey = B.custkey;


-- 第 5 周实验 3.4 探索任务 1：外键约束验证

INSERT INTO Nation (nationkey, name, regionkey, comment) VALUES (99, 'TEST_NATION', 99, '测试外键约束');


-- 第 7 周探索任务 3：角色与权限管理
-- 重复执行前先执行：DROP USER IF EXISTS 'audit_user'@'localhost'; DROP ROLE IF EXISTS 'auditor';

CREATE ROLE 'auditor';
GRANT SELECT ON tpch.* TO 'auditor';
CREATE USER 'audit_user'@'localhost' IDENTIFIED BY '123456';
GRANT 'auditor' TO 'audit_user'@'localhost';
SET DEFAULT ROLE 'auditor' TO 'audit_user'@'localhost';
FLUSH PRIVILEGES;


-- 第 8 周探索任务 2：实体完整性（主键重复与空值）

INSERT INTO Supplier (suppkey, name, address, nationkey, phone, acctbal, comment)
VALUES (11, 'test1', 'test1', 1, '12345678', 0.0, 'test1');

-- 主码值重复，预期报错 1062
INSERT INTO Supplier (suppkey, name, address, nationkey, phone, acctbal, comment)
VALUES (11, 'test2', 'test2', 2, '23456789', 0.0, 'test2');

-- 主码值为空，预期报错 1048
INSERT INTO Supplier (suppkey, name, address) VALUES (NULL, 'test3', 'test3');
