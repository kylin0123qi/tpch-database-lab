-- 阶段一：建库
-- 步骤 1：创建数据库 TPCH，字符集 utf8mb4
DROP DATABASE IF EXISTS TPCH;
CREATE DATABASE TPCH CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE TPCH;

SHOW CREATE DATABASE TPCH;


-- 阶段一：建表
USE TPCH;

-- 1. 地区表（无外键依赖，最先创建）
CREATE TABLE region (
    regionkey   INT          NOT NULL COMMENT '地区编号',
    name        VARCHAR(25)  NOT NULL COMMENT '地区名称',
    comment     VARCHAR(152)          COMMENT '备注',
    CONSTRAINT pk_region PRIMARY KEY (regionkey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='地区表';

-- 2. 国家表（外键 → region）
CREATE TABLE nation (
    nationkey   INT          NOT NULL COMMENT '国家编号',
    name        VARCHAR(25)  NOT NULL COMMENT '国家名称',
    regionkey   INT          NOT NULL COMMENT '所属地区',
    comment     VARCHAR(152)          COMMENT '备注',
    CONSTRAINT pk_nation PRIMARY KEY (nationkey),
    CONSTRAINT fk_nation_region FOREIGN KEY (regionkey)
        REFERENCES region (regionkey) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='国家表';

-- 3. 零件表（无外键；检查约束：零售价必须大于 0）
CREATE TABLE part (
    partkey     INT           NOT NULL COMMENT '零件编号',
    name        VARCHAR(55)   NOT NULL COMMENT '零件名称',
    mfgr        VARCHAR(25)            COMMENT '制造厂',
    brand       VARCHAR(10)            COMMENT '品牌',
    type        VARCHAR(25)            COMMENT '类型',
    size        INT                    COMMENT '尺寸',
    container   VARCHAR(10)            COMMENT '包装',
    retailprice DECIMAL(10,2) NOT NULL COMMENT '零售价',
    comment     VARCHAR(23)            COMMENT '备注',
    CONSTRAINT pk_part PRIMARY KEY (partkey),
    CONSTRAINT ck_part_price CHECK (retailprice > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='零件表';

-- 4. 供应商表（外键 → nation）
CREATE TABLE supplier (
    suppkey     INT           NOT NULL COMMENT '供应商编号',
    name        VARCHAR(25)   NOT NULL COMMENT '供应商名称',
    address     VARCHAR(40)            COMMENT '地址',
    nationkey   INT           NOT NULL COMMENT '所在国家',
    phone       VARCHAR(15)            COMMENT '电话',
    acctbal     DECIMAL(10,2)          COMMENT '账户余额',
    comment     VARCHAR(101)           COMMENT '备注',
    CONSTRAINT pk_supplier PRIMARY KEY (suppkey),
    CONSTRAINT fk_supplier_nation FOREIGN KEY (nationkey)
        REFERENCES nation (nationkey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='供应商表';

-- 5. 零件供应商表（复合主键；双外键；检查约束：可用数量 >= 0）
CREATE TABLE partsupp (
    partkey     INT           NOT NULL COMMENT '零件编号',
    suppkey     INT           NOT NULL COMMENT '供应商编号',
    availqty    INT           NOT NULL COMMENT '可用数量',
    supplycost  DECIMAL(10,2)          COMMENT '供应价格',
    comment     VARCHAR(199)           COMMENT '备注',
    CONSTRAINT pk_partsupp PRIMARY KEY (partkey, suppkey),
    CONSTRAINT fk_partsupp_part FOREIGN KEY (partkey) REFERENCES part (partkey),
    CONSTRAINT fk_partsupp_supplier FOREIGN KEY (suppkey) REFERENCES supplier (suppkey),
    CONSTRAINT ck_partsupp_availqty CHECK (availqty >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='零件供应商联系表';

-- 6. 顾客表（外键 → nation）
CREATE TABLE customer (
    custkey     INT           NOT NULL COMMENT '顾客编号',
    name        VARCHAR(25)   NOT NULL COMMENT '顾客姓名',
    address     VARCHAR(40)            COMMENT '地址',
    nationkey   INT           NOT NULL COMMENT '国籍',
    phone       VARCHAR(15)            COMMENT '电话',
    acctbal     DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '账户余额',
    mktsegment  VARCHAR(10)            COMMENT '市场分区',
    comment     VARCHAR(117)           COMMENT '备注',
    CONSTRAINT pk_customer PRIMARY KEY (custkey),
    CONSTRAINT fk_customer_nation FOREIGN KEY (nationkey) REFERENCES nation (nationkey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='顾客表';

-- 7. 订单表（外键 → customer）
CREATE TABLE orders (
    orderkey      INT           NOT NULL COMMENT '订单编号',
    custkey       INT           NOT NULL COMMENT '顾客编号',
    orderstatus   CHAR(1)                COMMENT '订单状态',
    totalprice    DECIMAL(10,2)          COMMENT '订单总金额',
    orderdate     DATE                   COMMENT '下单日期',
    orderpriority VARCHAR(15)            COMMENT '优先级',
    clerk         VARCHAR(15)            COMMENT '记账员',
    shippriority  INT                    COMMENT '运输优先级',
    comment       VARCHAR(79)            COMMENT '备注',
    CONSTRAINT pk_orders PRIMARY KEY (orderkey),
    CONSTRAINT fk_orders_customer FOREIGN KEY (custkey) REFERENCES customer (custkey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- 8. 订单明细表（复合主键；外键 → orders，复合外键 → partsupp）
CREATE TABLE lineitem (
    orderkey      INT           NOT NULL COMMENT '订单编号',
    partkey       INT           NOT NULL COMMENT '零件编号',
    suppkey       INT           NOT NULL COMMENT '供应商编号',
    linenumber    INT           NOT NULL COMMENT '行号',
    quantity      DECIMAL(10,2)          COMMENT '数量',
    extendedprice DECIMAL(10,2)          COMMENT '明细金额',
    discount      DECIMAL(10,2)          COMMENT '折扣',
    tax           DECIMAL(10,2)          COMMENT '税率',
    returnflag    CHAR(1)                COMMENT '退货标记',
    linestatus    CHAR(1)                COMMENT '明细状态',
    shipdate      DATE                   COMMENT '装运日期',
    commitdate    DATE                   COMMENT '委托日期',
    receiptdate   DATE                   COMMENT '签收日期',
    shipinstruct  VARCHAR(25)            COMMENT '装运说明',
    shipmode      VARCHAR(10)            COMMENT '装运方式',
    comment       VARCHAR(44)            COMMENT '备注',
    CONSTRAINT pk_lineitem PRIMARY KEY (orderkey, linenumber),
    CONSTRAINT fk_lineitem_orders FOREIGN KEY (orderkey) REFERENCES orders (orderkey),
    CONSTRAINT fk_lineitem_partsupp FOREIGN KEY (partkey, suppkey)
        REFERENCES partsupp (partkey, suppkey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单明细表';


-- 阶段一：插入测试数据
USE TPCH;

-- ① 地区（5 条）
INSERT INTO region (regionkey, name, comment) VALUES
(0, 'AFRICA',      '非洲'),
(1, 'AMERICA',     '美洲'),
(2, 'ASIA',        '亚洲'),
(3, 'EUROPE',      '欧洲'),
(4, 'MIDDLE EAST', '中东');

-- ② 国家（6 条，依赖 region）
INSERT INTO nation (nationkey, name, regionkey, comment) VALUES
(0, 'CHINA',   2, '亚洲'),
(1, 'JAPAN',   2, '亚洲'),
(2, 'GERMANY', 3, '欧洲'),
(3, 'FRANCE',  3, '欧洲'),
(4, 'USA',     1, '美洲'),
(5, 'KENYA',   0, '非洲');

-- ③ 零件（5 条，零售价均大于 0）
INSERT INTO part (partkey, name, mfgr, brand, type, size, container, retailprice, comment) VALUES
(1, '六角螺栓M10', '恒信紧固件', 'HX-BOLT',  '标准件', 10, '盒装',     14.80, '常用'),
(2, '行星齿轮组',  '恒信传动',   'HX-GEAR',  '传动件', 28, '木箱',     96.00, '减速用'),
(3, '控制电路板',  '明远电子',   'MY-PCB',   '电子件', 16, '防静电袋',  8.40, '飞控主板'),
(4, '碳纤维连杆',  '明远结构',   'MY-ARM',   '结构件', 32, '纸箱',     52.00, '轻量化'),
(5, '比例阀',      '德瑞液压',   'DR-VALVE', '液压件', 45, '木箱',     72.00, '高压');

-- ④ 供应商（6 条，依赖 nation；中国放 3 家，其余各 1 家）
INSERT INTO supplier (suppkey, name, address, nationkey, phone, acctbal, comment) VALUES
(101, '东山精密',     '广东省广州市黄埔区', 0, '020-8801-0001',  88000.00, '综合件'),
(102, '华电辽能',     '广东省深圳市宝安区', 0, '0755-8802-0002', 142000.00, '电子件'),
(103, '光迅精密',     '日本大阪府',         1, '06-8803-0003',    69000.00, '精密加工'),
(104, '莱茵河制造',   '德国北威州',         2, '0211-8804-0004',  57000.00, '液压件'),
(105, '湾区智造',     '广东省珠海市香洲区', 0, '0756-8805-0005', 195000.00, '结构件'),
(106, '北美联合供应', '美国伊利诺伊州',     4, '312-8806-0006',   41000.00, '分销');

-- ⑤ 零件供应商（11 条）
--   零件 1 由 101/102/103 供货，零件 2 由 101/102/106 供货
--   (2,102)=50、(2,101)=15 留作触发器测试；(4,102)=5 是要求构造的低库存记录
INSERT INTO partsupp (partkey, suppkey, availqty, supplycost, comment) VALUES
(1, 101, 520, 14.80, '常备'),
(1, 102, 310, 13.60, '常备'),
(1, 103, 130, 15.20, '进口件'),
(2, 101,  15, 48.00, '小批量'),
(2, 102,  50, 47.00, '小批量'),
(2, 106, 210, 45.50, '北美仓'),
(3, 102, 820,  8.40, '主供'),
(3, 104,  65,  9.10, '欧洲仓'),
(4, 105, 250, 10.90, '主供'),
(4, 102,   5, 11.50, '库存告急'),
(5, 104,  95, 35.60, '欧洲仓');

-- ⑥ 顾客（8 条，依赖 nation）
INSERT INTO customer (custkey, name, address, nationkey, phone, acctbal, mktsegment, comment) VALUES
(201, '陈嘉禾', '广东省广州市天河区', 0, '020-9901-0001',  5000.00, 'BUILDING',   '老客户'),
(202, '林晓棠', '广东省深圳市福田区', 0, '0755-9902-0002', 1200.00, 'AUTOMOBILE', '普通'),
(203, '黄启明', '北京市海淀区',       0, '010-9903-0003',  9000.00, 'MACHINERY',  '重点客户'),
(204, '周叙白', '日本东京都',         1, '03-9904-0004',   3000.00, 'HOUSEHOLD',  '日本客户'),
(205, '苏静姝', '德国巴伐利亚州',     2, '089-9905-0005',  2500.00, 'FURNITURE',  '欧洲客户'),
(206, '何书言', '上海市浦东新区',     0, '021-9906-0006',  3000.00, 'BUILDING',   '注册未下单'),
(207, '梁景行', '日本大阪府',         1, '06-9907-0007',   1000.00, 'HOUSEHOLD',  '日本客户'),
(208, '许听雨', '德国北威州',         2, '0221-9908-0008', 2500.00, 'FURNITURE',  '欧洲客户');

-- ⑦ 订单（7 条，依赖 customer；顾客 201 有两笔，206/207 从未下单）
INSERT INTO orders (orderkey, custkey, orderstatus, totalprice, orderdate, orderpriority, clerk, shippriority, comment) VALUES
(301, 201, 'O', 1200.50, '2024-03-10', '1-URGENT',        'Clerk#001', 0, '第一笔'),
(302, 201, 'F',  800.00, '2024-05-22', '3-MEDIUM',        'Clerk#001', 0, '第二笔'),
(303, 202, 'O', 2500.00, '2024-06-01', '2-HIGH',          'Clerk#002', 0, ''),
(304, 203, 'F', 4300.00, '2024-07-15', '1-URGENT',        'Clerk#003', 0, ''),
(305, 204, 'O',  900.00, '2024-08-08', '4-NOT SPECIFIED', 'Clerk#004', 0, ''),
(306, 205, 'F', 1500.00, '2024-09-12', '3-MEDIUM',        'Clerk#005', 0, ''),
(307, 208, 'O',  600.00, '2024-10-30', '5-LOW',           'Clerk#006', 0, '');

-- ⑧ 订单明细（10 条，依赖 orders 与 partsupp）
INSERT INTO lineitem (orderkey, partkey, suppkey, linenumber, quantity, extendedprice, discount, tax,
                      returnflag, linestatus, shipdate, commitdate, receiptdate, shipinstruct, shipmode, comment)
VALUES
(301, 1, 101, 1, 10, 148.00, 0.05, 0.02, 'N', 'O', '2024-03-15', '2024-03-20', '2024-03-25', 'DELIVER IN PERSON', 'TRUCK', ''),
(301, 3, 102, 2, 50, 420.00, 0.03, 0.02, 'N', 'O', '2024-03-16', '2024-03-21', '2024-03-26', 'TAKE BACK RETURN',  'AIR',   ''),
(302, 2, 101, 1,  5, 240.00, 0.02, 0.01, 'R', 'F', '2024-05-28', '2024-06-02', '2024-06-08', 'DELIVER IN PERSON', 'SHIP',  ''),
(303, 1, 102, 1, 20, 272.00, 0.04, 0.02, 'N', 'O', '2024-06-06', '2024-06-11', '2024-06-16', 'DELIVER IN PERSON', 'TRUCK', ''),
(303, 4, 105, 2, 10, 109.00, 0.01, 0.01, 'N', 'O', '2024-06-07', '2024-06-12', '2024-06-17', 'NONE',              'MAIL',  ''),
(304, 2, 106, 1,  8, 364.00, 0.06, 0.03, 'N', 'F', '2024-07-20', '2024-07-25', '2024-07-30', 'DELIVER IN PERSON', 'RAIL',  ''),
(304, 5, 104, 2,  4, 142.40, 0.00, 0.02, 'N', 'F', '2024-07-21', '2024-07-26', '2024-07-31', 'NONE',              'SHIP',  ''),
(305, 1, 103, 1,  3,  45.60, 0.02, 0.01, 'N', 'O', '2024-08-14', '2024-08-19', '2024-08-24', 'DELIVER IN PERSON', 'AIR',   ''),
(306, 3, 104, 1, 12, 109.20, 0.03, 0.02, 'R', 'F', '2024-09-18', '2024-09-23', '2024-09-28', 'TAKE BACK RETURN',  'TRUCK', ''),
(307, 4, 102, 1,  2,  23.00, 0.00, 0.00, 'N', 'O', '2024-11-05', '2024-11-10', '2024-11-15', 'NONE',              'MAIL',  '');


-- 阶段三：聚合分组与相关子查询
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


-- 阶段四：库存预警触发器
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

-- 注：任务3（故意报错）与任务4（修改外键）会中断执行或改变表结构，
--     分别放在 04、05 两个文件中，需要时单独执行。
