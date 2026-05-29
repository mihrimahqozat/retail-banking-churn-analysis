DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    row_number          INTEGER,
    customer_id         INTEGER,
    surname             TEXT,
    credit_score        INTEGER,
    geography           TEXT,
    gender              TEXT,
    age                 INTEGER,
    tenure              INTEGER,
    balance             NUMERIC(15, 2),
    num_of_products     INTEGER,
    has_cr_card         INTEGER,
    is_active_member    INTEGER,
    estimated_salary    NUMERIC(15, 2),
    exited              INTEGER
);