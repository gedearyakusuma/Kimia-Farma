CREATE TABLE rakamin-kf-analytics-472913.kimia_farma.kf_final_analysis AS
WITH laba AS (
  SELECT 
    a.transaction_id,
    a.price,
    a.discount_percentage,
    CASE
      WHEN a.price <= 50000 THEN 0.15
      WHEN a.price > 50000 AND a.price <= 100000 THEN 0.15
      WHEN a.price > 100000 AND a.price <= 300000 THEN 0.20
      WHEN a.price > 300000 AND a.price <= 500000 THEN 0.25
      WHEN a.price > 500000 THEN 0.30
    END AS persentase_gross_laba,
    (a.price * (1 - a.discount_percentage)) AS nett_sales
  FROM rakamin-kf-analytics-472913.kimia_farma.kf_final_transaction a
)

SELECT 
  t.transaction_id,
  t.date,
  c.branch_id,
  c.branch_name,
  c.kota,
  c.provinsi,
  c.rating AS rating_cabang,
  t.customer_name,
  p.product_id,
  p.product_name,
  t.price AS actual_price,
  t.discount_percentage,
  l.persentase_gross_laba,
  l.nett_sales,
  (l.nett_sales * l.persentase_gross_laba) AS nett_profit,
  t.rating AS rating_transaksi
FROM rakamin-kf-analytics-472913.kimia_farma.kf_final_transaction t
JOIN rakamin-kf-analytics-472913.kimia_farma.kf_product p 
  ON t.product_id = p.product_id
JOIN rakamin-kf-analytics-472913.kimia_farma.kf_kantor_cabang c 
  ON t.branch_id = c.branch_id
JOIN laba l 
  ON t.transaction_id = l.transaction_id;
