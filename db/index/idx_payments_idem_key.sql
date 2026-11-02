\c payment_db;

CREATE UNIQUE INDEX idx_payments_idem_key ON payments (idem_key);
