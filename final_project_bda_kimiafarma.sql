CREATE TABLE `rakamin-kf-analytics-454603.kimia_farma.kf_table_analysis_dataset` AS 
WITH main AS (
  SELECT 
    t.transaction_id, 
    t.date, 
    t.branch_id, 
    c.branch_name, 
    c.kota, 
    c.provinsi, 
    c.rating AS rating_cabang,
    t.customer_name, 
    t.product_id, 
    p.product_name, 
    p.price AS actual_price, 
    t.discount_percentage,
    CASE 
      WHEN p.price <= 50000 THEN 0.1
      WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
      WHEN p.price > 100000 AND p.price <= 300000 THEN 0.2
      WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
      ELSE 0.3
    END AS persentase_gross_laba,
    p.price * (1 - t.discount_percentage) AS nett_sales
  FROM
    `rakamin-kf-analytics-454603.kimia_farma.kf_final_transaction_dataset` t
  LEFT JOIN 
    `rakamin-kf-analytics-454603.kimia_farma.kf_kantor_cabang_dataset` c ON t.branch_id = c.branch_id
  LEFT JOIN
    `rakamin-kf-analytics-454603.kimia_farma.kf_product_table` p ON t.product_id = p.product_id
)
SELECT
  DISTINCT main.*, 
  (actual_price * persentase_gross_laba) - (actual_price - nett_sales) AS nett_profit,
  t.rating AS rating_transaksi
FROM
  main
JOIN 
  `rakamin-kf-analytics-454603.kimia_farma.kf_final_transaction_dataset` t ON main.transaction_id = t.transaction_id
ORDER BY
  main.date DESC;
