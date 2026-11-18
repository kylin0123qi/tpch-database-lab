USE TPCH;

-- 向 region 插入一个已存在的 regionkey（0 号地区已经有了）
INSERT INTO region (regionkey, name, comment)
VALUES (0, 'ASIA-DUP', '重复主键测试');

USE TPCH;

-- 向 nation 插入 regionkey = 9 的记录，但 region 表里没有 9 号地区
INSERT INTO nation (nationkey, name, regionkey, comment)
VALUES (99, 'ATLANTIS', 9, '外键插入冲突测试');

USE TPCH;

-- 先造一对合法的父子记录：9 号地区 + 属于它的 90 号国家
INSERT INTO region (regionkey, name, comment) VALUES (9, 'ANTARCTICA', '外键删除测试专用');
INSERT INTO nation (nationkey, name, regionkey, comment) VALUES (90, 'PENGUIN LAND', 9, '外键删除测试专用');

SELECT n.nationkey, n.name, n.regionkey, r.name AS region_name
FROM nation n JOIN region r ON n.regionkey = r.regionkey
WHERE n.regionkey = 9;

-- 直接删除被 nation 引用的 9 号地区
DELETE FROM region WHERE regionkey = 9;

USE TPCH;

-- 插入零售价为 -50 的零件
INSERT INTO part (partkey, name, mfgr, brand, type, size, container, retailprice, comment)
VALUES (99, '非法零件', '测试厂', 'TEST', '测试', 1, '盒装', -50.00, '检查约束测试');

-- 插入可用数量为 -5 的零件供应商关系
-- 用 (5, 101) 组合：part 5 只被 104 供过，(5,101) 不存在，
-- 因此只会撞 CHECK 约束，不会先撞主键重复
INSERT INTO partsupp (partkey, suppkey, availqty, supplycost, comment)
VALUES (5, 101, -5, 36.00, '负库存测试');

USE TPCH;

SELECT COUNT(*) AS '非法零件残留(应为0)' FROM part WHERE partkey = 99;
SELECT COUNT(*) AS '负库存残留(应为0)'   FROM partsupp WHERE availqty < 0;
SELECT COUNT(*) AS '重复地区残留(应为0)' FROM region WHERE name = 'ASIA-DUP';
