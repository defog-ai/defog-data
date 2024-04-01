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
  ('Honda', 'Civic', 2021, 'platinum/grey', '2HGFC2F53MH522780', 'Inline 4', 'CVT', 22000.00),
  ('Ford', 'Mustang', 2023, 'blue', '1FA6P8TH4M5100001', 'V8', 'Manual', 45000.00),
  ('Tesla', 'Model 3', 2022, 'fuschia', '5YJ3E1EB7MF123456', 'Electric', 'Automatic', 41000.00),
  ('Chevrolet', 'Equinox', 2021, 'midnight blue', '2GNAXUEV1M6290124', 'Inline 4', 'Automatic', 26500.00),
  ('Nissan', 'Altima', 2022, 'Jet black', '1N4BL4BV4NN123456', 'V6', 'CVT', 25000.00),
  ('BMW', 'X5', 2023, 'Titan Silver', '5UXCR6C56M9A12345', 'V8', 'Automatic', 62000.00),
  ('Audi', 'A4', 2022, 'Blue', 'WAUBNAF47MA098765', 'Inline 4', 'Automatic', 39000.00),
  ('Lexus', 'RX350', 2021, 'Fiery red', '2T2BZMCA7MC143210', 'V6', 'Automatic', 45500.00),
  ('Subaru', 'Outback', 2022, 'Jade', '4S4BSANC2N3246801', 'Boxer 4', 'CVT', 28000.00),
  ('Mazda', 'CX-5', 2022, 'Royal Purple', 'JM3KE4DY4N0123456', 'Inline 4', 'Automatic', 29000.00),
  ('Hyundai', 'Tucson', 2023, 'black', 'KM8J3CAL3NU123456', 'Inline 4', 'Automatic', 32000.00),
  ('Kia', 'Sorento', 2021, 'ebony black', '5XYPH4A50MG987654', 'V6', 'Automatic', 32000.00),
  ('Jeep', 'Wrangler', 2022, 'Harbor Gray', '1C4HJXDG3NW123456', 'V6', 'Automatic', 38000.00),
  ('GMC', 'Sierra 1500', 2023, 'Snow White', '1GTU9CED3NZ123456', 'V8', 'Automatic', 45000.00),
  ('Ram', '1500', 2022, 'baby blue', '1C6SRFFT3NN123456', 'V8', 'Automatic', 42000.00),
  ('Mercedes-Benz', 'E-Class', 2021, 'Silver', 'W1KZF8DB1MA123456', 'Inline 6', 'Automatic', 62000.00),
  ('Volkswagen', 'Tiguan', 2022, 'Red', '3VV2B7AX1NM123456', 'Inline 4', 'Automatic', 32000.00),
  ('Volvo', 'XC90', 2023, 'black', 'YV4A22PK3N1234567', 'Inline 4', 'Automatic', 65000.00),
  ('Porsche', '911', 2022, 'white', 'WP0AA2A93NS123456', 'Flat 6', 'Automatic', 120000.00),
  ('Cadillac', 'Escalade', 2023, 'Black', '1GYS4HKJ3MR123456', 'V8', 'Automatic', 85000.00);

-- salespersons
INSERT INTO salespersons (first_name, last_name, email, phone, hire_date)
VALUES
  ('John', 'Doe', 'john.doe@autonation.com', '(555)-123-4567', NOW() - INTERVAL '2 years'),
  ('Jane', 'Smith', 'jane.smith@autonation.com', '(415)-987-6543', NOW() - INTERVAL '3 years'),
  ('Michael', 'Johnson', 'michael.johnson@autonation.com', '(555)-456-7890', NOW() - INTERVAL '1 year'),
  ('Emily', 'Brown', 'emily.brown@sonicauto.com', '(444)-111-2222', NOW() - INTERVAL '1 year'),
  ('David', 'Wilson', 'david.wilson@sonicauto.com', '(444)-333-4444', NOW() - INTERVAL '2 years'),
  ('Sarah', 'Taylor', 'sarah.taylor@sonicauto.com', '(123)-555-6666', '2018-09-01'),
  ('Daniel', 'Anderson', 'daniel.anderson@sonicauto.com', '(555)-777-8888', '2021-07-12'),
  ('Olivia', 'Thomas', 'olivia.thomas@pensake.com', '(333)-415-0000', '2023-01-25'),
  ('James', 'Jackson', 'james.jackson@pensake.com', '(555)-212-3333', '2019-04-30'),
  ('Sophia', 'White', 'sophia.white@pensake.com', '(555)-444-5555', '2022-08-18'),
  ('Robert', 'Johnson', 'robert.johnson@pensake.com', '(001)-415-5678', NOW() - INTERVAL '15 days'),
  ('Jennifer', 'Davis', 'jennifer.davis@directauto.com', '(555)-345-6789', NOW() - INTERVAL '20 days'),
  ('Jessica', 'Rodriguez', 'jessica.rodriguez@directauto.com', '(555)-789-0123', '2022-06-01');

-- customers
INSERT INTO customers (first_name, last_name, email, phone, address, city, state, zip_code, crtd_ts)
VALUES
  ('William', 'Davis', 'william.davis@example.com', '555-888-9999', '123 Main St', 'New York', 'NY', '10001', NOW() - INTERVAL '5 years'),
  ('Ava', 'Miller', 'ava.miller@example.com', '555-777-6666', '456 Oak Ave', 'Los Angeles', 'CA', '90001', NOW() - INTERVAL '4 years'),
  ('Benjamin', 'Wilson', 'benjamin.wilson@example.com', '555-666-5555', '789 Elm St', 'Chicago', 'IL', '60007', NOW() - INTERVAL '3 years'),
  ('Mia', 'Moore', 'mia.moore@example.com', '555-555-4444', '321 Pine Rd', 'Houston', 'TX', '77001', NOW() - INTERVAL '2 years'),
  ('Henry', 'Taylor', 'henry.taylor@example.com', '555-444-3333', '654 Cedar Ln', 'Phoenix', 'AZ', '85001', NOW() - INTERVAL '1 year'),
  ('Charlotte', 'Anderson', 'charlotte.anderson@example.com', '555-333-2222', '987 Birch Dr', 'Philadelphia', 'PA', '19019', NOW() - INTERVAL '5 years'),
  ('Alexander', 'Thomas', 'alexander.thomas@example.com', '555-222-1111', '741 Walnut St', 'San Antonio', 'TX', '78006', NOW() - INTERVAL '4 years'),
  ('Amelia', 'Jackson', 'amelia.jackson@gmail.com', '555-111-0000', '852 Maple Ave', 'San Diego', 'CA', '92101', NOW() - INTERVAL '3 years'),
  ('Daniel', 'White', 'daniel.white@youtube.com', '555-000-9999', '963 Oak St', 'Dallas', 'TX', '75001', NOW() - INTERVAL '2 years'),
  ('Abigail', 'Harris', 'abigail.harris@company.io', '555-999-8888', '159 Pine Ave', 'San Jose', 'CA', '95101', NOW() - INTERVAL '1 year'),
  ('Christopher', 'Brown', 'christopher.brown@ai.com', '555-456-7890', '753 Maple Rd', 'Miami', 'FL', '33101', NOW() - INTERVAL '5 months'),
  ('Sophia', 'Lee', 'sophia.lee@microsoft.com', '555-567-8901', '951 Oak Ln', 'Seattle', 'WA', '98101', NOW() - INTERVAL '6 months'),
  ('Michael', 'Chen', 'michael.chen@company.com', '(555)-456-7890', '123 Oak St', 'San Francisco', 'CA', '94101', NOW() - INTERVAL '3 months');

-- sales
INSERT INTO sales (car_id, salesperson_id, customer_id, sale_price, sale_date)
VALUES
  (1, 2, 3, 27500.00, '2023-03-15'),
  (3, 1, 5, 44000.00, '2023-03-20'),
  (6, 4, 2, 24500.00, '2023-03-22'),
  (8, 7, 9, 38000.00, '2023-03-25'),
  (2, 4, 7, 21500.00, '2023-03-28'),
  (10, 6, 1, 27000.00, '2023-04-01'),
  (5, 3, 6, 26000.00, '2023-04-05'),
  (7, 2, 10, 60000.00, '2023-04-10'),
  (4, 6, 8, 40000.00, '2023-04-12'),
  (9, 2, 4, 44500.00, '2023-04-15'),
  (1, 7, 11, 28000.00, NOW() - INTERVAL '32 days'),
  (3, 3, 12, 43500.00, NOW() - INTERVAL '10 days'),
  (6, 1, 11, 24000.00, NOW() - INTERVAL '15 days'),
  (2, 3, 1, 17200.00, NOW() - INTERVAL '30 days'),
  (8, 6, 12, 37500.00, NOW() - INTERVAL '3 days'),
  (10, 4, 2, 26500.00, NOW() - INTERVAL '5 days'),
  (3, 2, 3, 115000.00, DATE_TRUNC('week', NOW() - INTERVAL '1 week') + INTERVAL '1 day'),
  (3, 2, 7, 115000.00, DATE_TRUNC('week', NOW() - INTERVAL '1 week')),
  (3, 2, 10, 115000.00, DATE_TRUNC('week', NOW() - INTERVAL '1 week') - INTERVAL '1 day'),
  (4, 1, 3, 115000.00, DATE_TRUNC('week', NOW() - INTERVAL '8 week') + INTERVAL '1 day'),
  (4, 1, 7, 115000.00, DATE_TRUNC('week', NOW() - INTERVAL '8 week')),
  (4, 1, 10, 115000.00, DATE_TRUNC('week', NOW() - INTERVAL '8 week') - INTERVAL '1 day');


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
  (10, '2023-04-15', 44500.00, 'credit_card'),
  (11, NOW() - INTERVAL '30 days', 28000.00, 'cash'),
  (12, NOW() - INTERVAL '3 days', 43500.00, 'credit_card'),
  (13, NOW() - INTERVAL '6 days', 24000.00, 'debit_card'),
  (14, NOW() - INTERVAL '1 days', 17200.00, 'financing'),
  (15, NOW() - INTERVAL '1 days', 37500.00, 'credit_card'),
  (16, NOW() - INTERVAL '5 days', 26500.00, 'debit_card'),
  (17, DATE_TRUNC('week', NOW() - INTERVAL '1 week') + INTERVAL '1 day', 115000.00, 'financing'),
  (18, DATE_TRUNC('week', NOW() - INTERVAL '1 week'), 115000.00, 'credit_card'),
  (19, DATE_TRUNC('week', NOW() - INTERVAL '1 week') - INTERVAL '1 day', 115000.00, 'debit_card'),
  (20, DATE_TRUNC('week', NOW() - INTERVAL '8 week') + INTERVAL '1 day', 115000.00, 'cash'),
  (21, DATE_TRUNC('week', NOW() - INTERVAL '8 week'), 115000.00, 'check'),
  (22, DATE_TRUNC('week', NOW() - INTERVAL '8 week') - INTERVAL '1 day', 115000.00, 'credit_card');

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
  ('Cleaning Service', '2023-04-30', 2000.00, 'check', 'INV-012', '2023-04-25', '2023-05-25'),
  ('Toyota Auto Parts', NOW() - INTERVAL '5 days', 12500.00, 'bank_transfer', 'INV-013', NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days'),
  ('Honda Manufacturing', NOW() - INTERVAL '3 days', 18000.00, 'check', 'INV-014', NOW() - INTERVAL '8 days', NOW() + INTERVAL '22 days'),
  ('Ford Supplier Co', NOW() - INTERVAL '2 days', 22000.00, 'bank_transfer', 'INV-015', NOW() - INTERVAL '7 days', NOW() + INTERVAL '23 days'),
  ('Tesla Parts Inc', NOW() - INTERVAL '1 day', 15000.00, 'credit_card', 'INV-016', NOW() - INTERVAL '6 days', NOW() + INTERVAL '24 days'),
  ('Chevrolet Auto', NOW(), 20000.00, 'bank_transfer', 'INV-017', NOW() - INTERVAL '5 days', NOW() + INTERVAL '25 days');