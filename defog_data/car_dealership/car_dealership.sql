CREATE TABLE cars (
  id SERIAL PRIMARY KEY,
  make TEXT NOT NULL, -- manufacturer of the car
  model TEXT NOT NULL, -- model name of the car
  year INTEGER NOT NULL, -- year of manufacture
  color TEXT NOT NULL, -- color of the car
  vin_number VARCHAR(17) NOT NULL UNIQUE, -- Vehicle Identification Number
  engine_type TEXT NOT NULL, -- type of engine (e.g., V6, V8, Electric)
  transmission TEXT NOT NULL, -- type of transmission (e.g., Automatic, Manual)
  cost NUMERIC(10, 2) NOT NULL, -- cost of the car
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
INSERT INTO cars (id, make, model, year, color, vin_number, engine_type, transmission, cost)
VALUES
  (1, 'Toyota', 'Camry', 2022, 'Silver', '4T1BF1FK3CU510984', 'V6', 'Automatic', 28500.00),
  (2, 'Honda', 'Civic', 2021, 'platinum/grey', '2HGFC2F53MH522780', 'Inline 4', 'CVT', 22000.00),
  (3, 'Ford', 'Mustang', 2023, 'blue', '1FA6P8TH4M5100001', 'V8', 'Manual', 45000.00),
  (4, 'Tesla', 'Model 3', 2022, 'fuschia', '5YJ3E1EB7MF123456', 'Electric', 'Automatic', 41000.00),
  (5, 'Chevrolet', 'Equinox', 2021, 'midnight blue', '2GNAXUEV1M6290124', 'Inline 4', 'Automatic', 26500.00),
  (6, 'Nissan', 'Altima', 2022, 'Jet black', '1N4BL4BV4NN123456', 'V6', 'CVT', 25000.00),
  (7, 'BMW', 'X5', 2023, 'Titan Silver', '5UXCR6C56M9A12345', 'V8', 'Automatic', 62000.00),
  (8, 'Audi', 'A4', 2022, 'Blue', 'WAUBNAF47MA098765', 'Inline 4', 'Automatic', 39000.00),
  (9, 'Lexus', 'RX350', 2021, 'Fiery red', '2T2BZMCA7MC143210', 'V6', 'Automatic', 45500.00),
  (10, 'Subaru', 'Outback', 2022, 'Jade', '4S4BSANC2N3246801', 'Boxer 4', 'CVT', 28000.00),
  (11, 'Mazda', 'CX-5', 2022, 'Royal Purple', 'JM3KE4DY4N0123456', 'Inline 4', 'Automatic', 29000.00),
  (12, 'Hyundai', 'Tucson', 2023, 'black', 'KM8J3CAL3NU123456', 'Inline 4', 'Automatic', 32000.00),
  (13, 'Kia', 'Sorento', 2021, 'ebony black', '5XYPH4A50MG987654', 'V6', 'Automatic', 32000.00),
  (14, 'Jeep', 'Wrangler', 2022, 'Harbor Gray', '1C4HJXDG3NW123456', 'V6', 'Automatic', 38000.00),
  (15, 'GMC', 'Sierra 1500', 2023, 'Snow White', '1GTU9CED3NZ123456', 'V8', 'Automatic', 45000.00),
  (16, 'Ram', '1500', 2022, 'baby blue', '1C6SRFFT3NN123456', 'V8', 'Automatic', 42000.00),
  (17, 'Mercedes-Benz', 'E-Class', 2021, 'Silver', 'W1KZF8DB1MA123456', 'Inline 6', 'Automatic', 62000.00),
  (18, 'Volkswagen', 'Tiguan', 2022, 'Red', '3VV2B7AX1NM123456', 'Inline 4', 'Automatic', 32000.00),
  (19, 'Volvo', 'XC90', 2023, 'black', 'YV4A22PK3N1234567', 'Inline 4', 'Automatic', 65000.00),
  (20, 'Porsche', '911', 2022, 'white', 'WP0AA2A93NS123456', 'Flat 6', 'Automatic', 120000.00),
  (21, 'Cadillac', 'Escalade', 2023, 'Black', '1GYS4HKJ3MR123456', 'V8', 'Automatic', 85000.00);

-- salespersons
INSERT INTO salespersons (id, first_name, last_name, email, phone, hire_date)
VALUES
  (1, 'John', 'Doe', 'john.doe@autonation.com', '(555)-123-4567', CURRENT_DATE - INTERVAL '2 years'),
  (2, 'Jane', 'Smith', 'jane.smith@autonation.com', '(415)-987-6543', CURRENT_DATE - INTERVAL '3 years'),
  (3, 'Michael', 'Johnson', 'michael.johnson@autonation.com', '(555)-456-7890', CURRENT_DATE - INTERVAL '1 year'),
  (4, 'Emily', 'Brown', 'emily.brown@sonicauto.com', '(444)-111-2222', CURRENT_DATE - INTERVAL '1 year'),
  (5, 'David', 'Wilson', 'david.wilson@sonicauto.com', '(444)-333-4444', CURRENT_DATE - INTERVAL '2 years'),
  (6, 'Sarah', 'Taylor', 'sarah.taylor@sonicauto.com', '(123)-555-6666', '2018-09-01'),
  (7, 'Daniel', 'Anderson', 'daniel.anderson@sonicauto.com', '(555)-777-8888', '2021-07-12'),
  (8, 'Olivia', 'Thomas', 'olivia.thomas@pensake.com', '(333)-415-0000', '2023-01-25'),
  (9, 'James', 'Jackson', 'james.jackson@pensake.com', '(555)-212-3333', '2019-04-30'),
  (10, 'Sophia', 'White', 'sophia.white@pensake.com', '(555)-444-5555', '2022-08-18'),
  (11, 'Robert', 'Johnson', 'robert.johnson@pensake.com', '(001)-415-5678', CURRENT_DATE - INTERVAL '15 days'),
  (12, 'Jennifer', 'Davis', 'jennifer.davis@directauto.com', '(555)-345-6789', CURRENT_DATE - INTERVAL '20 days'),
  (13, 'Jessica', 'Rodriguez', 'jessica.rodriguez@directauto.com', '(555)-789-0123', '2022-06-01');

-- customers
INSERT INTO customers (id, first_name, last_name, email, phone, address, city, state, zip_code, crtd_ts)
VALUES
  (1, 'William', 'Davis', 'william.davis@example.com', '555-888-9999', '123 Main St', 'New York', 'NY', '10001', NOW() - INTERVAL '5 years'),
  (2, 'Ava', 'Miller', 'ava.miller@example.com', '555-777-6666', '456 Oak Ave', 'Los Angeles', 'CA', '90001', NOW() - INTERVAL '4 years'),
  (3, 'Benjamin', 'Wilson', 'benjamin.wilson@example.com', '555-666-5555', '789 Elm St', 'Chicago', 'IL', '60007', NOW() - INTERVAL '3 years'),
  (4, 'Mia', 'Moore', 'mia.moore@example.com', '555-555-4444', '321 Pine Rd', 'Houston', 'TX', '77001', NOW() - INTERVAL '2 years'),
  (5, 'Henry', 'Taylor', 'henry.taylor@example.com', '555-444-3333', '654 Cedar Ln', 'Phoenix', 'AZ', '85001', NOW() - INTERVAL '1 year'),
  (6, 'Charlotte', 'Anderson', 'charlotte.anderson@example.com', '555-333-2222', '987 Birch Dr', 'Philadelphia', 'PA', '19019', NOW() - INTERVAL '5 years'),
  (7, 'Alexander', 'Thomas', 'alexander.thomas@example.com', '555-222-1111', '741 Walnut St', 'San Antonio', 'TX', '78006', NOW() - INTERVAL '4 years'),
  (8, 'Amelia', 'Jackson', 'amelia.jackson@gmail.com', '555-111-0000', '852 Maple Ave', 'San Diego', 'CA', '92101', NOW() - INTERVAL '3 years'),
  (9, 'Daniel', 'White', 'daniel.white@youtube.com', '555-000-9999', '963 Oak St', 'Dallas', 'TX', '75001', NOW() - INTERVAL '2 years'),
  (10, 'Abigail', 'Harris', 'abigail.harris@company.io', '555-999-8888', '159 Pine Ave', 'San Jose', 'CA', '95101', NOW() - INTERVAL '1 year'),
  (11, 'Christopher', 'Brown', 'christopher.brown@ai.com', '555-456-7890', '753 Maple Rd', 'Miami', 'FL', '33101', NOW() - INTERVAL '5 months'),
  (12, 'Sophia', 'Lee', 'sophia.lee@microsoft.com', '555-567-8901', '951 Oak Ln', 'Seattle', 'WA', '98101', NOW() - INTERVAL '6 months'),
  (13, 'Michael', 'Chen', 'michael.chen@company.com', '(555)-456-7890', '123 Oak St', 'San Francisco', 'CA', '94101', NOW() - INTERVAL '3 months');

-- sales
INSERT INTO sales (id, car_id, salesperson_id, customer_id, sale_price, sale_date)
VALUES
  (1, 1, 2, 3, 30500.00, '2023-03-15'),
  (2, 3, 1, 5, 47000.00, '2023-03-20'),
  (3, 6, 4, 2, 26500.00, '2023-03-22'),
  (4, 8, 7, 9, 38000.00, '2023-03-25'),
  (5, 2, 4, 7, 23500.00, '2023-03-28'),
  (6, 10, 6, 1, 30000.00, '2023-04-01'),
  (7, 5, 3, 6, 26800.00, '2023-04-05'),
  (8, 7, 2, 10, 63000.00, '2023-04-10'),
  (9, 4, 6, 8, 42500.00, '2023-04-12'),
  (10, 9, 2, 4, 44500.00, '2023-04-15'),
  (11, 1, 7, 11, 28900.00, CURRENT_DATE - INTERVAL '32 days'),
  (12, 3, 3, 12, 46500.00, CURRENT_DATE - INTERVAL '10 days'),
  (13, 6, 1, 11, 26000.00, CURRENT_DATE - INTERVAL '15 days'),
  (14, 2, 3, 1, 23200.00, CURRENT_DATE - INTERVAL '21 days'),
  (15, 8, 6, 12, 43500.00, CURRENT_DATE - INTERVAL '3 days'),
  (16, 10, 4, 2, 29500.00, CURRENT_DATE - INTERVAL '5 days'),
  (17, 3, 2, 3, 46000.00, DATE_TRUNC('week', CURRENT_DATE) - INTERVAL '1 week' + INTERVAL '1 day'),
  (18, 3, 2, 7, 47500.00, DATE_TRUNC('week', CURRENT_DATE) - INTERVAL '1 week'),
  (19, 3, 2, 10, 46500.00, DATE_TRUNC('week', CURRENT_DATE) - INTERVAL '1 week' - INTERVAL '1 day'),
  (20, 4, 1, 3, 48000.00, DATE_TRUNC('week', CURRENT_DATE) - INTERVAL '8 week' + INTERVAL '1 day'),
  (21, 4, 1, 7, 45000.00, DATE_TRUNC('week', CURRENT_DATE) - INTERVAL '8 week'),
  (22, 4, 1, 10, 49000.00, DATE_TRUNC('week', CURRENT_DATE) - INTERVAL '8 week' - INTERVAL '1 day');


-- inventory_snapshots
INSERT INTO inventory_snapshots (id, snapshot_date, car_id, is_in_inventory)
VALUES
  (1, '2023-03-15', 1, TRUE),
  (2, '2023-03-15', 2, TRUE),
  (3, '2023-03-15', 3, TRUE),
  (4, '2023-03-15', 4, TRUE),
  (5, '2023-03-15', 5, TRUE),
  (6, '2023-03-15', 6, TRUE),
  (7, '2023-03-15', 7, TRUE),
  (8, '2023-03-15', 8, TRUE),
  (9, '2023-03-15', 9, TRUE),
  (10, '2023-03-15', 10, TRUE),
  (11, '2023-03-20', 1, FALSE),
  (12, '2023-03-20', 3, FALSE),
  (13, '2023-03-22', 6, FALSE),
  (14, '2023-03-25', 8, FALSE),
  (15, '2023-03-28', 2, FALSE),
  (16, '2023-04-01', 10, FALSE),
  (17, '2023-04-05', 5, FALSE),
  (18, '2023-04-10', 7, FALSE),
  (19, '2023-04-12', 4, FALSE),
  (20, '2023-04-15', 9, FALSE);

-- payments_received
INSERT INTO payments_received (id, sale_id, payment_date, payment_amount, payment_method)
VALUES
  (1, 1, '2023-03-15', 5000.00, 'check'),
  (2, 1, '2023-03-20', 22500.00, 'financing'),
  (3, 2, '2023-03-20', 44000.00, 'credit_card'),
  (4, 3, '2023-03-22', 24500.00, 'debit_card'),
  (5, 4, '2023-03-25', 38000.00, 'financing'),
  (6, 5, '2023-03-28', 21500.00, 'cash'),
  (7, 6, '2023-04-01', 27000.00, 'credit_card'),
  (8, 7, '2023-04-05', 26000.00, 'debit_card'),
  (9, 8, '2023-04-10', 60000.00, 'financing'),
  (10, 9, '2023-04-12', 40000.00, 'check'),
  (11, 10, '2023-04-15', 44500.00, 'credit_card'),
  (12, 11, CURRENT_DATE - INTERVAL '30 days', 28000.00, 'cash'),
  (13, 12, CURRENT_DATE - INTERVAL '3 days', 43500.00, 'credit_card'),
  (14, 13, CURRENT_DATE - INTERVAL '6 days', 24000.00, 'debit_card'),
  (15, 14, CURRENT_DATE - INTERVAL '1 days', 17200.00, 'financing'),
  (16, 15, CURRENT_DATE - INTERVAL '1 days', 37500.00, 'credit_card'),
  (17, 16, CURRENT_DATE - INTERVAL '5 days', 26500.00, 'debit_card'),
  (18, 17, DATE_TRUNC('week', CURRENT_DATE) - INTERVAL '1 week' + INTERVAL '1 day', 115000.00, 'financing'),
  (19, 18, DATE_TRUNC('week', CURRENT_DATE) - INTERVAL '1 week', 115000.00, 'credit_card'),
  (20, 19, DATE_TRUNC('week', CURRENT_DATE) - INTERVAL '1 week' - INTERVAL '1 day', 115000.00, 'debit_card'),
  (21, 20, DATE_TRUNC('week', CURRENT_DATE) - INTERVAL '8 week' + INTERVAL '1 day', 115000.00, 'cash'),
  (22, 21, DATE_TRUNC('week', CURRENT_DATE) - INTERVAL '8 week', 115000.00, 'check'),
  (23, 22, DATE_TRUNC('week', CURRENT_DATE) - INTERVAL '8 week' - INTERVAL '1 day', 115000.00, 'credit_card');

-- payments_made
INSERT INTO payments_made (id, vendor_name, payment_date, payment_amount, payment_method, invoice_number, invoice_date, due_date)
VALUES
  (1, 'Car Manufacturer Inc', '2023-03-01', 150000.00, 'bank_transfer', 'INV-001', '2023-02-25', '2023-03-25'),
  (2, 'Auto Parts Supplier', '2023-03-10', 25000.00, 'check', 'INV-002', '2023-03-05', '2023-04-04'),
  (3, 'Utility Company', '2023-03-15', 1500.00, 'bank_transfer', 'INV-003', '2023-03-01', '2023-03-31'),
  (4, 'Marketing Agency', '2023-03-20', 10000.00, 'credit_card', 'INV-004', '2023-03-15', '2023-04-14'),
  (5, 'Insurance Provider', '2023-03-25', 5000.00, 'bank_transfer', 'INV-005', '2023-03-20', '2023-04-19'),
  (6, 'Cleaning Service', '2023-03-31', 2000.00, 'check', 'INV-006', '2023-03-25', '2023-04-24'),
  (7, 'Car Manufacturer Inc', '2023-04-01', 200000.00, 'bank_transfer', 'INV-007', '2023-03-25', '2023-04-24'),
  (8, 'Auto Parts Supplier', '2023-04-10', 30000.00, 'check', 'INV-008', '2023-04-05', '2023-05-05'),
  (9, 'Utility Company', '2023-04-15', 1500.00, 'bank_transfer', 'INV-009', '2023-04-01', '2023-04-30'),
  (10, 'Marketing Agency', '2023-04-20', 15000.00, 'credit_card', 'INV-010', '2023-04-15', '2023-05-15'),
  (11, 'Insurance Provider', '2023-04-25', 5000.00, 'bank_transfer', 'INV-011', '2023-04-20', '2023-05-20'),
  (12, 'Cleaning Service', '2023-04-30', 2000.00, 'check', 'INV-012', '2023-04-25', '2023-05-25'),
  (13, 'Toyota Auto Parts', CURRENT_DATE - INTERVAL '5 days', 12500.00, 'bank_transfer', 'INV-013', CURRENT_DATE - INTERVAL '10 days', CURRENT_DATE + INTERVAL '20 days'),
  (14, 'Honda Manufacturing', CURRENT_DATE - INTERVAL '3 days', 18000.00, 'check', 'INV-014', CURRENT_DATE - INTERVAL '8 days', CURRENT_DATE + INTERVAL '22 days'),
  (15, 'Ford Supplier Co', CURRENT_DATE - INTERVAL '2 days', 22000.00, 'bank_transfer', 'INV-015', CURRENT_DATE - INTERVAL '7 days', CURRENT_DATE + INTERVAL '23 days'),
  (16, 'Tesla Parts Inc', CURRENT_DATE - INTERVAL '1 day', 15000.00, 'credit_card', 'INV-016', CURRENT_DATE - INTERVAL '6 days', CURRENT_DATE + INTERVAL '24 days'),
  (17, 'Chevrolet Auto', CURRENT_DATE, 20000.00, 'bank_transfer', 'INV-017', CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE + INTERVAL '25 days');