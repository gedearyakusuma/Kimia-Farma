-- 1) Buat tabel baru kf_final_analysis dari hasil SELECT di bawah
CREATE OR REPLACE TABLE `rakamin-kf-analytics-472913.kimia_farma.kf_final_analysis` AS -- Fungsi REPLACE untuk update jika ada pembaruan data

-- 2) CTE (Common Table Expression) bernama 'laba'
--    CTE ini fokus hanya pada perhitungan yang pakai CASE WHEN dan nett_sales,
--    sehingga perhitungan itu bisa dipanggil ulang di SELECT utama tanpa menulis ulang CASE.
WITH laba AS (
  SELECT 
    a.transaction_id,                     -- sebagai kunci unik supaya nanti bisa JOIN ke tabel transaksi
    a.price,                              -- harga asli (sebelum diskon)
    a.discount_percentage,                -- diskon (HARUS dalam bentuk desimal: 0.1 = 10%)
    CASE                                  -- CASE hitung persentase gross laba berdasarkan range harga
      WHEN a.price <= 50000 THEN 0.10
      WHEN a.price > 50000 AND a.price <= 100000 THEN 0.15
      WHEN a.price > 100000 AND a.price <= 300000 THEN 0.20
      WHEN a.price > 300000 AND a.price <= 500000 THEN 0.25
      WHEN a.price > 500000 THEN 0.30
    END AS persentase_gross_laba,
    (a.price * (1 - a.discount_percentage)) AS nett_sales  -- harga setelah diskon
  FROM `rakamin-kf-analytics-472913.kimia_farma.kf_final_transaction` a
)

-- 3) SELECT:  ambil kolom-kolom dari tabel lain untuk dimasukkan ke tabel baru
SELECT 
  t.transaction_id,
  t.date,                            
  c.branch_id,
  c.branch_name,
  c.kota,
  c.provinsi,
  c.rating AS rating_cabang,             -- ubah nama kolom rating menggunakan AS(alias) -> rating_cabang
  t.customer_name,
  p.product_id,
  p.product_name,
  t.price AS actual_price,               -- ubah nama kolom price menggunakan AS(alias) -> actual_price
  t.discount_percentage,

  l.persentase_gross_laba,               -- ambil hasil CASE dari CTE
  l.nett_sales,                          -- ambil harga setelah diskon dari CTE

  -- hitung nett_profit dengan mengalikan nett_sales (nilai rupiah) * persentase_gross_laba (koefisien)
  (l.nett_sales * l.persentase_gross_laba) AS nett_profit,

  t.rating AS rating_transaksi
FROM `rakamin-kf-analytics-472913.kimia_farma.kf_final_transaction` t

-- 4) JOIN ke tabel produk & cabang supaya bisa ambil nama produk dan info cabang
JOIN `rakamin-kf-analytics-472913.kimia_farma.kf_product` p 
  ON t.product_id = p.product_id

JOIN `rakamin-kf-analytics-472913.kimia_farma.kf_kantor_cabang` c 
  ON t.branch_id = c.branch_id

-- 5) JOIN ke CTE 'laba' berdasarkan transaction_id supaya tiap baris transaksi dapat kolom hasil perhitungan
JOIN laba l 
  ON t.transaction_id = l.transaction_id;

