# TPC-H 数据库综合实验

《数据库原理与应用》课程综合实验 · 中山大学网络空间安全学院

| 项目 | 内容 |
|---|---|
| 学号 | 25345077 |
| 姓名 | 鲁蕙萌 |
| 指导教师 | 张亮 |
| 环境 | MySQL 8.0.46 + Navicat Premium Lite 17.3 |
| 数据库 | `TPCH`（字符集 utf8mb4） |

本仓库存放综合实验（任务 1–7）与第 2、3、4、5、7、8 周探索实验的 SQL 脚本。
实验报告（PDF）另行提交，不在本仓库内。

---

## 实验内容

### 综合实验：TPC-H 数据库构建、完整性验证与复杂查询

| 阶段 | 任务 | 内容 | 分值 |
|---|---|---|---|
| 一 | 任务 1 | 建库 TPCH，按外键依赖顺序创建 8 张表，主键/外键/检查约束显式命名 | 15 |
| 一 | 任务 2 | 按依赖顺序插入测试数据，构造四类关联场景 | 10 |
| 二 | 任务 3 | 故意触发 4 类约束冲突（主键、外键插入、外键删除、检查约束） | 16 |
| 二 | 任务 4 | 设计 Nation→Region 的级联删除方案并验证效果 | 4 |
| 三 | 任务 5 | 按供应商所在国家聚合统计（GROUP BY + HAVING） | 15 |
| 三 | 任务 6 | 查询余额高于本国平均的顾客（相关子查询）+ NOT EXISTS 加分项 | 15 |
| 四 | 任务 7 | 库存预警日志表与 AFTER UPDATE 行级触发器 | 25 |

### 周探索实验（每周选做一道，共 6 道）

| 周次 | 考察内容 | 结果 |
|---|---|---|
| 第 2 周 | 数据插入 + 实体/参照完整性 | `1452`、`1062` |
| 第 3 周 | 条件查询 WHERE | 8 行 |
| 第 4 周 | 派生表 + 分组统计 | 1 行 |
| 第 5 周 | 外键插入约束 | `1452` |
| 第 7 周 | 角色与权限管理 | 6 条全部成功 |
| 第 8 周 | 实体完整性：主键重复与空值 | `1062`、`1048` |

---

## 脚本说明

| 文件 | 内容 |
|---|---|
| `01_create_database.sql` | 建库 TPCH（utf8mb4） |
| `02_create_tables.sql` | 8 张表及具名约束 |
| `03_insert_data.sql` | 测试数据与场景自检 |
| `04_constraint_tests.sql` | 5 条约束冲突演示（预期报错） |
| `05_cascade_design.sql` | 级联删除改造、验证与还原 |
| `06_complex_queries.sql` | 聚合分组、相关子查询、NOT EXISTS |
| `07_trigger.sql` | 预警日志表、触发器与两组测试 |
| `08_full_script.sql` | 一键执行的合并脚本 |
| `09_weekly_tasks.sql` | 六周探索题代码 |

## 执行顺序

```sql
-- 建库建表
source sql/01_create_database.sql
source sql/02_create_tables.sql
source sql/03_insert_data.sql

-- 约束验证（04 中每条语句都会报错，属预期结果，需逐条执行）
source sql/04_constraint_tests.sql
source sql/05_cascade_design.sql

-- 查询与触发器
source sql/06_complex_queries.sql
source sql/07_trigger.sql
```

也可直接执行 `sql/08_full_script.sql` 一次性搭建环境（该文件不含故意报错的部分）。

> `04_constraint_tests.sql` 里的语句是**故意触发约束冲突**的演示，报错是预期结果，
> 请逐条选中执行，不要在"遇错即停"的模式下整体运行。

## 数据库对象

- 主键：`pk_region`、`pk_nation`、`pk_part`、`pk_supplier`、`pk_partsupp`、`pk_customer`、`pk_orders`、`pk_lineitem`
- 外键：`fk_nation_region`、`fk_supplier_nation`、`fk_partsupp_part`、`fk_partsupp_supplier`、`fk_customer_nation`、`fk_orders_customer`、`fk_lineitem_orders`、`fk_lineitem_partsupp`
- 检查约束：`ck_part_price`（零售价 > 0）、`ck_partsupp_availqty`（可用数量 ≥ 0）
- 触发器：`trg_partsupp_lowstock`（AFTER UPDATE，库存跌破 10 时写入 `StockAlert_Log`）
