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

SHOW TABLES;

SELECT table_name, constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'TPCH'
ORDER BY table_name, constraint_type;
