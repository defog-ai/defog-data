CREATE TABLE cars (
  id SERIAL PRIMARY KEY,
  make TEXT NOT NULL, -- manufacturer of the car
  model TEXT NOT NULL, -- model name of the car
  year INTEGER NOT NULL, -- year of manufacture
  color TEXT NOT NULL, -- color of the car
  vin_number VARCHAR(17) NOT NULL UNIQUE, -- Vehicle Identification Number
  engine_type TEXT NOT NULL, -- type of engine (e.g., V6, V8, Electric)
  transmission TEXT NOT NULL, -- type of transmission (e.g., Automatic, Manual)
  price NUMERIC(10, 2) NOT NULL, -- selling price of the car
  is_sold BOOLEAN NOT NULL DEFAULT FALSE, -- indicates if the car has been sold
  crtd_ts TIMESTAMP NOT NULL DEFAULT NOW() -- timestamp when the car was added to the system
);

CREATE TABLE salespersons (
  id SERIAL PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(20) NOT NULL,
  hire_date DATE NOT NULL,
  termination_date DATE,
  crtd_ts TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(20) NOT NULL,
  address TEXT NOT NULL,
  city TEXT NOT NULL,
  state TEXT NOT NULL,
  zip_code VARCHAR(10) NOT NULL,
  crtd_ts TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE sales (
  id SERIAL PRIMARY KEY,
  car_id INTEGER NOT NULL REFERENCES cars(id),
  salesperson_id INTEGER NOT NULL REFERENCES salespersons(id),
  customer_id INTEGER NOT NULL REFERENCES customers(id),
  sale_price NUMERIC(10, 2) NOT NULL,
  sale_date DATE NOT NULL,
  crtd_ts TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE inventory_snapshots (
  id SERIAL PRIMARY KEY,
  snapshot_date DATE NOT NULL,
  car_id INTEGER NOT NULL REFERENCES cars(id),
  is_in_inventory BOOLEAN NOT NULL,
  crtd_ts TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE payments_received (
  id SERIAL PRIMARY KEY,
  sale_id INTEGER NOT NULL REFERENCES sales(id),
  payment_date DATE NOT NULL,
  payment_amount NUMERIC(10, 2) NOT NULL,
  payment_method TEXT NOT NULL, -- values: cash, check, credit_card, debit_card, financing
  crtd_ts TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE payments_made (
  id SERIAL PRIMARY KEY,
  vendor_name TEXT NOT NULL,
  payment_date DATE NOT NULL,
  payment_amount NUMERIC(10, 2) NOT NULL,
  payment_method TEXT NOT NULL, -- values: check, bank_transfer, credit_card
  invoice_number VARCHAR(50) NOT NULL,
  invoice_date DATE NOT NULL,
  due_date DATE NOT NULL,
  crtd_ts TIMESTAMP NOT NULL DEFAULT NOW()
);


-- cars
INSERT INTO cars (make, model, year, color, vin_number, engine_type, transmission, price)
VALUES
  ('Toyota', 'Camry', 2022, 'Silver', '4T1BF1FK3CU510984', 'V6', 'Automatic', 28500.00),
  ('Honda', 'Civic', 2021, 'Red', '2HGFC2F53MH522780', 'Inline 4', 'CVT', 22000.00),
  ('Ford', 'Mustang', 2023, 'Blue', '1FA6P8TH4M5100001', 'V8', 'Manual', 45000.00),
  ('Tesla', 'Model 3', 2022, 'White', '5YJ3E1EB7MF123456', 'Electric', 'Automatic', 41000.00),
  ('Chevrolet', 'Equinox', 2021, 'Gray', '2GNAXUEV1M6290124', 'Inline 4', 'Automatic', 26500.00),
  ('Nissan', 'Altima', 2022, 'Black', '1N4BL4BV4NN123456', 'V6', 'CVT', 25000.00),
  ('BMW', 'X5', 2023, 'Silver', '5UXCR6C56M9A12345', 'V8', 'Automatic', 62000.00),
  ('Audi', 'A4', 2022, 'Blue', 'WAUBNAF47MA098765', 'Inline 4', 'Automatic', 39000.00),
  ('Lexus', 'RX350', 2021, 'White', '2T2BZMCA7MC143210', 'V6', 'Automatic', 45500.00),
  ('Subaru', 'Outback', 2022, 'Green', '4S4BSANC2N3246801', 'Boxer 4', 'CVT', 28000.00);

-- salespersons
INSERT INTO salespersons (first_name, last_name, email, phone, hire_date)
VALUES
  ('John', 'Doe', 'john.doe@example.com', '555-123-4567', '2020-01-01'),
  ('Jane', 'Smith', 'jane.smith@example.com', '555-987-6543', '2019-06-15'),
  ('Michael', 'Johnson', 'michael.johnson@example.com', '555-456-7890', '2021-03-10'),
  ('Emily', 'Brown', 'emily.brown@example.com', '555-111-2222', '2022-02-20'),
  ('David', 'Wilson', 'david.wilson@example.com', '555-333-4444', '2020-11-05'),
  ('Sarah', 'Taylor', 'sarah.taylor@example.com', '555-555-6666', '2018-09-01'),
  ('Daniel', 'Anderson', 'daniel.anderson@example.com', '555-777-8888', '2021-07-12'),
  ('Olivia', 'Thomas', 'olivia.thomas@example.com', '555-999-0000', '2023-01-25'),
  ('James', 'Jackson', 'james.jackson@example.com', '555-222-3333', '2019-04-30'),
  ('Sophia', 'White', 'sophia.white@example.com', '555-444-5555', '2022-08-18');

-- customers
INSERT INTO customers (first_name, last_name, email, phone, address, city, state, zip_code)
VALUES
  ('William', 'Davis', 'william.davis@example.com', '555-888-9999', '123 Main St', 'New York', 'NY', '10001'),
  ('Ava', 'Miller', 'ava.miller@example.com', '555-777-6666', '456 Oak Ave', 'Los Angeles', 'CA', '90001'),
  ('Benjamin', 'Wilson', 'benjamin.wilson@example.com', '555-666-5555', '789 Elm St', 'Chicago', 'IL', '60007'),
  ('Mia', 'Moore', 'mia.moore@example.com', '555-555-4444', '321 Pine Rd', 'Houston', 'TX', '77001'),
  ('Henry', 'Taylor', 'henry.taylor@example.com', '555-444-3333', '654 Cedar Ln', 'Phoenix', 'AZ', '85001'),
  ('Charlotte', 'Anderson', 'charlotte.anderson@example.com', '555-333-2222', '987 Birch Dr', 'Philadelphia', 'PA', '19019'),
  ('Alexander', 'Thomas', 'alexander.thomas@example.com', '555-222-1111', '741 Walnut St', 'San Antonio', 'TX', '78006'),
  ('Amelia', 'Jackson', 'amelia.jackson@example.com', '555-111-0000', '852 Maple Ave', 'San Diego', 'CA', '92101'),
  ('Daniel', 'White', 'daniel.white@example.com', '555-000-9999', '963 Oak St', 'Dallas', 'TX', '75001'),
  ('Abigail', 'Harris', 'abigail.harris@example.com', '555-999-8888', '159 Pine Ave', 'San Jose', 'CA', '95101');

-- sales
INSERT INTO sales (car_id, salesperson_id, customer_id, sale_price, sale_date)
VALUES
  (1, 2, 3, 27500.00, '2023-03-15'),
  (3, 1, 5, 44000.00, '2023-03-20'),
  (6, 4, 2, 24500.00, '2023-03-22'),
  (8, 7, 9, 38000.00, '2023-03-25'),
  (2, 5, 7, 21500.00, '2023-03-28'),
  (10, 9, 1, 27000.00, '2023-04-01'),
  (5, 3, 6, 26000.00, '2023-04-05'),
  (7, 8, 10, 60000.00, '2023-04-10'),
  (4, 6, 8, 40000.00, '2023-04-12'),
  (9, 10, 4, 44500.00, '2023-04-15');

-- inventory_snapshots
INSERT INTO inventory_snapshots (snapshot_date, car_id, is_in_inventory)
VALUES
  ('2023-03-15', 1, TRUE),
  ('2023-03-15', 2, TRUE),
  ('2023-03-15', 3, TRUE),
  ('2023-03-15', 4, TRUE),
  ('2023-03-15', 5, TRUE),
  ('2023-03-15', 6, TRUE),
  ('2023-03-15', 7, TRUE),
  ('2023-03-15', 8, TRUE),
  ('2023-03-15', 9, TRUE),
  ('2023-03-15', 10, TRUE),
  ('2023-03-20', 1, FALSE),
  ('2023-03-20', 3, FALSE),
  ('2023-03-22', 6, FALSE),
  ('2023-03-25', 8, FALSE),
  ('2023-03-28', 2, FALSE),
  ('2023-04-01', 10, FALSE),
  ('2023-04-05', 5, FALSE),
  ('2023-04-10', 7, FALSE),
  ('2023-04-12', 4, FALSE),
  ('2023-04-15', 9, FALSE);

-- payments_received
INSERT INTO payments_received (sale_id, payment_date, payment_amount, payment_method)
VALUES
  (1, '2023-03-15', 5000.00, 'check'),
  (1, '2023-03-20', 22500.00, 'financing'),
  (2, '2023-03-20', 44000.00, 'credit_card'),
  (3, '2023-03-22', 24500.00, 'debit_card'),
  (4, '2023-03-25', 38000.00, 'financing'),
  (5, '2023-03-28', 21500.00, 'cash'),
  (6, '2023-04-01', 27000.00, 'credit_card'),
  (7, '2023-04-05', 26000.00, 'debit_card'),
  (8, '2023-04-10', 60000.00, 'financing'),
  (9, '2023-04-12', 40000.00, 'check'),
  (10, '2023-04-15', 44500.00, 'credit_card');

-- payments_made
INSERT INTO payments_made (vendor_name, payment_date, payment_amount, payment_method, invoice_number, invoice_date, due_date)
VALUES
  ('Car Manufacturer Inc', '2023-03-01', 150000.00, 'bank_transfer', 'INV-001', '2023-02-25', '2023-03-25'),
  ('Auto Parts Supplier', '2023-03-10', 25000.00, 'check', 'INV-002', '2023-03-05', '2023-04-04'),
  ('Utility Company', '2023-03-15', 1500.00, 'bank_transfer', 'INV-003', '2023-03-01', '2023-03-31'),
  ('Marketing Agency', '2023-03-20', 10000.00, 'credit_card', 'INV-004', '2023-03-15', '2023-04-14'),
  ('Insurance Provider', '2023-03-25', 5000.00, 'bank_transfer', 'INV-005', '2023-03-20', '2023-04-19'),
  ('Cleaning Service', '2023-03-31', 2000.00, 'check', 'INV-006', '2023-03-25', '2023-04-24'),
  ('Car Manufacturer Inc', '2023-04-01', 200000.00, 'bank_transfer', 'INV-007', '2023-03-25', '2023-04-24'),
  ('Auto Parts Supplier', '2023-04-10', 30000.00, 'check', 'INV-008', '2023-04-05', '2023-05-05'),
  ('Utility Company', '2023-04-15', 1500.00, 'bank_transfer', 'INV-009', '2023-04-01', '2023-04-30'),
  ('Marketing Agency', '2023-04-20', 15000.00, 'credit_card', 'INV-010', '2023-04-15', '2023-05-15'),
  ('Insurance Provider', '2023-04-25', 5000.00, 'bank_transfer', 'INV-011', '2023-04-20', '2023-05-20'),
  ('Cleaning Service', '2023-04-30', 2000.00, 'check', 'INV-012', '2023-04-25', '2023-05-25');