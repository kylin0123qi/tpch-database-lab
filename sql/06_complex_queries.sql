USE TPCH;

SELECT n.name                          AS `国家的名称`,
       COUNT(DISTINCT s.suppkey)       AS `供应商的数量`,
       COUNT(DISTINCT ps.partkey)      AS `零件种类数量`,
       SUM(ps.availqty)                AS `总可用库存量`,
       ROUND(AVG(ps.supplycost), 2)    AS `平均供应价格`
FROM nation n
         JOIN supplier s  ON s.nationkey = n.nationkey
         JOIN partsupp ps ON ps.suppkey  = s.suppkey
GROUP BY n.nationkey, n.name
ORDER BY `总可用库存量` DESC;

SELECT n.name                          AS `国家名称`,
       COUNT(DISTINCT s.suppkey)       AS `供应商数量`,
       COUNT(DISTINCT ps.partkey)      AS `零件种类数`,
       SUM(ps.availqty)                AS `总可用库存量`,
       ROUND(AVG(ps.supplycost), 2)    AS `平均供应价格`
FROM nation n
         JOIN supplier s  ON s.nationkey = n.nationkey
         JOIN partsupp ps ON ps.suppkey  = s.suppkey
GROUP BY n.nationkey, n.name
HAVING SUM(ps.availqty) > 500
ORDER BY `总可用库存量` DESC;

USE TPCH;

SELECT c.name       AS `顾客姓名`,
       n.name       AS `国家名称`,
       c.acctbal    AS `顾客账户余额`
FROM customer c
         JOIN nation n ON c.nationkey = n.nationkey
WHERE c.acctbal > (
        SELECT AVG(c2.acctbal)
        FROM customer c2
        WHERE c2.nationkey = c.nationkey     -- 关键：与外层关联
      )
ORDER BY `顾客账户余额` DESC;

SELECT n.name                       AS `国家名称`,
       COUNT(*)                     AS `顾客数`,
       ROUND(AVG(c.acctbal), 2)     AS `该国平均余额`,
       MAX(c.acctbal)               AS `该国最高余额`
FROM customer c
         JOIN nation n ON c.nationkey = n.nationkey
GROUP BY n.nationkey, n.name
ORDER BY `该国平均余额` DESC;

SELECT c.custkey      AS `顾客编号`,
       c.name         AS `顾客姓名`,
       n.name         AS `国家名称`,
       c.acctbal      AS `账户余额`,
       c.mktsegment   AS `市场分区`
FROM customer c
         JOIN nation n ON c.nationkey = n.nationkey
WHERE NOT EXISTS (
        SELECT 1 FROM orders o WHERE o.custkey = c.custkey
      )
ORDER BY c.custkey;
