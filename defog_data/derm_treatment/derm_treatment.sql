-- doctor dimension table
CREATE TABLE doctors (
  doc_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  specialty TEXT, -- possible values: dermatology, immunology, general
  year_reg INT, -- year the doctor was registered and obtained license
  med_school_name VARCHAR(100),
  loc_city VARCHAR(50),
  loc_state CHAR(2),
  loc_zip VARCHAR(10),
  bd_cert_num VARCHAR(20) -- board certification number
);

-- patient dimension table
CREATE TABLE patients (
  patient_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  date_of_birth DATE,
  gender VARCHAR(10),
  email VARCHAR(100),
  phone VARCHAR(20),
  addr_street VARCHAR(100),
  addr_city VARCHAR(50),
  addr_state CHAR(2), 
  addr_zip VARCHAR(10),
  ins_type TEXT, -- possible values: private, medicare, medicaid, uninsured
  ins_policy_num VARCHAR(20),
  height_cm FLOAT,
  weight_kg FLOAT
);

-- drug dimension table  
CREATE TABLE drugs (
  drug_id SERIAL PRIMARY KEY,
  drug_name VARCHAR(100),
  manufacturer VARCHAR(100),
  drug_type TEXT, -- possible values: biologic, small molecule, topical
  moa TEXT, -- mechanism of action
  fda_appr_dt DATE,  -- FDA approval date. NULL if drug is still under trial.
  admin_route TEXT, -- possible values: oral, injection, topical 
  dos_amt DECIMAL(10,2),
  dos_unit VARCHAR(20),
  dos_freq_hrs INT,
  ndc VARCHAR(20) -- National Drug Code  
);

-- diagnosis dimension table
CREATE TABLE diagnoses (
  diag_id SERIAL PRIMARY KEY,  
  diag_code VARCHAR(10),
  diag_name VARCHAR(100),
  diag_desc TEXT
);

-- treatment fact table
CREATE TABLE treatments (
  treatment_id SERIAL PRIMARY KEY,
  patient_id INT REFERENCES patients(patient_id),
  doc_id INT REFERENCES doctors(doc_id), 
  drug_id INT REFERENCES drugs(drug_id),
  diag_id INT REFERENCES diagnoses(diag_id),
  start_dt DATE,
  end_dt DATE,  -- NULL if treatment is ongoing
  is_placebo BOOLEAN,
  tot_drug_amt DECIMAL(10,2),
  drug_unit TEXT -- possible values: mg, ml, g
);

-- outcome fact table  
CREATE TABLE outcomes (
  outcome_id SERIAL PRIMARY KEY,
  treatment_id INT REFERENCES treatments(treatment_id),
  assess_dt DATE,
  day7_lesion_cnt INT, -- lesion counts on day 7.
  day30_lesion_cnt INT,
  day100_lesion_cnt INT,
  day7_pasi_score DECIMAL(4,1), -- PASI score range 0-72
  day30_pasi_score DECIMAL(4,1),
  day100_pasi_score DECIMAL(4,1),
  day7_tewl DECIMAL(5,2), -- in g/m^2/h  
  day30_tewl DECIMAL(5,2),
  day100_tewl DECIMAL(5,2),  
  day7_itch_vas INT, -- visual analog scale 0-100
  day30_itch_vas INT,
  day100_itch_vas INT,
  day7_hfg DECIMAL(4,1), -- hair growth factor range 0-5  
  day30_hfg DECIMAL(4,1),
  day100_hfg DECIMAL(4,1)
);

CREATE TABLE adverse_events (
  id SERIAL PRIMARY KEY, -- 1 row per adverse event per treatment_id
  treatment_id INT REFERENCES treatments(treatment_id),
  reported_dt DATE,
  description TEXT
);

CREATE TABLE concomitant_meds (
  id SERIAL PRIMARY KEY, -- 1 row per med per treatment_id
  treatment_id INT REFERENCES treatments(treatment_id),
  med_name VARCHAR(100),
  start_dt TEXT, -- YYYY-MM-DD
  end_dt TEXT, -- YYYY-MM-DD NULL if still taking
  dose_amt DECIMAL(10,2),
  dose_unit TEXT, -- possible values: mg, ml, g
  freq_hrs INT
);

-- insert into dimension tables first

INSERT INTO doctors (first_name, last_name, specialty, year_reg, med_school_name, loc_city, loc_state, loc_zip, bd_cert_num) 
VALUES
('John', 'Doe', 'dermatology', 2005, 'Johns Hopkins University', 'Baltimore', 'MD', '21201', 'ABC123'),
('Jane', 'Smith', 'immunology', 2010, 'Harvard Medical School', 'Boston', 'MA', '02115', 'XYZ789'),
('David', 'Johnson', 'general', 1998, 'University of Pennsylvania', 'Philadelphia', 'PA', '19104', 'DEF456'),
('Emily', 'Brown', 'dermatology', 2015, 'Stanford University', 'Palo Alto', 'CA', '94304', 'GHI012'),
('Michael', 'Davis', 'immunology', 2008, 'Duke University', 'Durham', 'NC', '27708', 'JKL345'),
('Sarah', 'Wilson', 'general', 2003, 'University of California, San Francisco', 'San Francisco', 'CA', '94143', 'MNO678'),
('Robert', 'Taylor', 'dermatology', 2012, 'Yale University', 'New Haven', 'CT', '06510', 'PQR901');

INSERT INTO patients (first_name, last_name, date_of_birth, gender, email, phone, addr_street, addr_city, addr_state, addr_zip, ins_type, ins_policy_num, height_cm, weight_kg)
VALUES
('Alice', 'Johnson', '1985-03-15', 'Female', 'alice@email.com', '555-123-4567', '123 Main St', 'Anytown', 'CA', '12345', 'private', 'ABC123456', 165, 60),
('Bob', 'Smith', '1978-11-23', 'Male', 'bob@email.com', '555-987-6543', '456 Oak Ave', 'Somecity', 'NY', '54321', 'medicare', 'XYZ789012', 180, 85),
('Carol', 'Davis', '1992-07-08', 'Female', 'carol@email.com', '555-246-8135', '789 Elm Rd', 'Anothercity', 'TX', '67890', 'private', 'DEF345678', 158, 52),  
('David', 'Wilson', '1965-09-30', 'Male', 'david@email.com', '555-369-2580', '321 Pine Ln', 'Somewhere', 'FL', '13579', 'medicaid', 'GHI901234', 175, 78),
('Eve', 'Brown', '2000-01-01', 'Female', 'eve@email.com', '555-147-2589', '654 Cedar St', 'Nowhere', 'WA', '97531', 'uninsured', NULL, 160, 55),
('Frank', 'Taylor', '1988-05-12', 'Male', 'frank@email.com', '555-753-9514', '987 Birch Dr', 'Anyplace', 'CO', '24680', 'private', 'JKL567890', 183, 90),
('Grace', 'Anderson', '1975-12-25', 'Female', 'grace@email.com', '555-951-7532', '159 Maple Rd', 'Somewhere', 'OH', '86420', 'medicare', 'MNO246810', 170, 68),
('Hannah', 'Garcia', '1982-08-05', 'Female', 'hannah@email.com', '555-369-1470', '753 Walnut Ave', 'Somewhere', 'CA', '97531', 'private', 'PQR135790', 162, 57),
('Isaac', 'Martinez', '1995-02-18', 'Male', 'isaac@email.com', '555-147-8520', '951 Spruce Blvd', 'Anytown', 'TX', '13579', 'medicaid', 'STU024680', 178, 82);


INSERT INTO drugs (drug_name, manufacturer, drug_type, moa, fda_appr_dt, admin_route, dos_amt, dos_unit, dos_freq_hrs, ndc)
VALUES  
('Drugalin', 'Pharma Inc', 'biologic', 'TNF-alpha inhibitor', '2010-01-15', 'injection', 40, 'mg', 336, '12345-678-90'),
('Medicol', 'Acme Pharma', 'small molecule', 'IL-17A inhibitor', '2015-06-30', 'oral', 30, 'mg', 24, '54321-012-34'),
('Topizol', 'BioMed Ltd', 'topical', 'PDE4 inhibitor', '2018-11-01', 'topical', 15, 'g', 12, '98765-432-10'),
('Biologic-X', 'Innova Biologics', 'biologic', 'IL-23 inhibitor', NULL, 'injection', 100, 'mg', 672, '13579-246-80'), 
('Smallazine', 'Chem Co', 'small molecule', 'JAK inhibitor', '2020-03-15', 'oral', 5, 'mg', 24, '97531-864-20'),
('Topicort', 'Derma Rx', 'topical', 'Corticosteroid', '2005-09-30', 'topical', 30, 'g', 12, '24680-135-79'),
('Biologic-Y', 'BioPharm Inc', 'biologic', 'IL-12/23 inhibitor', '2012-07-01', 'injection', 50, 'mg', 504, '75319-951-46'),
('Smallitol', 'PharmaGen', 'small molecule', 'IL-6 inhibitor', '2017-04-15', 'oral', 10, 'mg', 24, '36915-258-07'),
('Topicalin', 'DermiCare', 'topical', 'Calcineurin inhibitor', '2019-10-01', 'topical', 20, 'g', 12, '14785-369-02'),
('Biologic-Z', 'BioMed Ltd', 'biologic', 'IL-17F inhibitor', '2021-01-01', 'injection', 80, 'mg', 336, '95146-753-19');

INSERT INTO diagnoses (diag_code, diag_name, diag_desc)
VALUES
('L40.0', 'Psoriasis vulgaris', 'Plaque psoriasis, the most common form'),  
('L40.1', 'Generalized pustular psoriasis', 'Widespread pustules on top of red skin'),
('L40.4', 'Guttate psoriasis', 'Small, teardrop-shaped lesions'), 
('L40.8', 'Other psoriasis', 'Includes flexural, erythrodermic, and other rare types'),
('L40.9', 'Psoriasis, unspecified', 'Psoriasis not further specified'),
('L40.50', 'Arthropathic psoriasis, unspecified', 'Psoriatic arthritis, unspecified'),
('L40.51', 'Distal interphalangeal psoriatic arthropathy', 'Psoriatic arthritis mainly affecting the ends of fingers and toes'),
('L40.52', 'Psoriatic arthritis mutilans', 'Severe, deforming psoriatic arthritis'),   
('L40.53', 'Psoriatic spondylitis', 'Psoriatic arthritis of the spine'),
('L40.59', 'Other psoriatic arthropathy', 'Other specified types of psoriatic arthritis');

-- insert into fact tables
INSERT INTO treatments (patient_id, doc_id, drug_id, diag_id, start_dt, end_dt, is_placebo, tot_drug_amt, drug_unit)
VALUES
(1, 1, 1, 1, '2022-01-01', '2022-06-30', false, 240, 'mg'),
(2, 2, 2, 2, '2022-02-15', '2022-08-14', true, 180, 'mg'),
(3, 3, 3, 3, '2022-03-10', '2022-09-09', false, 360, 'g'),
(4, 4, 4, 4, '2022-04-01', NULL, false, 200, 'mg'),
(5, 5, 5, 5, '2022-05-01', '2022-10-31', false, 180, 'mg'),
(6, 6, 6, 6, '2022-06-15', '2022-12-14', false, 720, 'g'),
(1, 7, 1, 7, '2022-07-01', '2022-12-31', true, 240, 'mg'),
(2, 1, 2, 8, '2022-08-01', '2023-01-31', false, 180, 'mg'),
(3, 2, 3, 9, '2022-09-01', '2023-02-28', false, 360, 'g'),
(4, 3, 4, 10, '2022-10-01', NULL, true, 0, NULL),
(5, 4, 5, 1, '2022-11-01', '2023-04-30', true, 180, 'mg'),
(6, 5, 6, 2, '2022-12-01', '2023-05-31', false, 720, 'g'),
(7, 6, 1, 3, '2023-01-01', '2023-06-30', false, 240, 'mg'),
(1, 7, 2, 4, '2023-02-01', '2023-07-31', false, 180, 'mg'),
(2, 1, 3, 5, '2023-03-01', '2023-08-31', false, 360, 'g'),
(1, 2, 4, 6, DATE_TRUNC('month', CURRENT_DATE - INTERVAL '2 year'), DATE_TRUNC('month', CURRENT_DATE - INTERVAL '2 months'), false, 300, 'mg'),
(2, 5, 1, 8, DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 year'), DATE_TRUNC('month', CURRENT_DATE - INTERVAL '4 months'), false, 80, 'mg'),
(3, 6, 2, 9, DATE_TRUNC('month', CURRENT_DATE - INTERVAL '5 months'), NULL, true, 200, 'mg'),
(1, 7, 3, 10, DATE_TRUNC('month', CURRENT_DATE - INTERVAL '4 months'), NULL, false, 150, 'g'),
(2, 1, 4, 1, DATE_TRUNC('month', CURRENT_DATE - INTERVAL '3 months'), NULL, false, 100, 'mg'),
(3, 2, 5, 2, DATE_TRUNC('month', CURRENT_DATE - INTERVAL '2 months'), NULL, false, 250, 'mg'),
(1, 3, 6, 3, DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month'), NULL, false, 300, 'g'),
(2, 4, 1, 4, CURRENT_DATE, NULL, true, 200, 'mg'),
(3, 5, 2, 5, CURRENT_DATE, NULL, false, 150, 'mg');

INSERT INTO outcomes (treatment_id, assess_dt, day7_lesion_cnt, day30_lesion_cnt, day100_lesion_cnt, day7_pasi_score, day30_pasi_score, day100_pasi_score, day7_tewl, day30_tewl, day100_tewl, day7_itch_vas, day30_itch_vas, day100_itch_vas, day7_hfg, day30_hfg, day100_hfg)  
VALUES
(1, '2022-01-08', 20, 15, 5, 12.5, 8.2, 2.1, 18.2, 15.6, 12.1, 60, 40, 20, 1.5, 2.5, 4.0),
(2, '2022-02-22', 25, 18, 8, 15.0, 10.1, 3.5, 20.1, 17.2, 13.5, 70, 50, 30, 1.0, 2.0, 3.5),
(3, '2022-03-17', 18, 12, 3, 10.8, 6.4, 1.2, 16.5, 14.0, 10.8, 55, 35, 15, 2.0, 3.0, 4.5),
(4, '2022-04-08', 30, 25, 12, 18.2, 13.9, 5.8, 22.4, 19.1, 15.2, 80, 60, 40, 0.5, 1.5, 3.0),
(5, '2022-05-08', 22, 16, 6, 13.1, 8.7, 2.6, 19.0, 16.3, 12.7, 65, 45, 25, 1.2, 2.2, 3.8),
(6, '2022-06-22', 28, 21, 10, 16.7, 11.5, 4.3, 21.3, 18.1, 14.3, 75, 55, 35, 0.8, 1.8, 3.3),
(7, '2022-07-08', 19, 13, 4, 11.2, 6.9, 1.5, 17.1, 14.5, 11.2, 58, 38, 18, 1.8, 2.8, 4.3),
(8, '2022-08-08', 26, 19, 9, 15.6, 10.6, 3.8, 20.7, 17.6, 13.9, 72, 52, 32, 0.7, 1.7, 3.2),
(9, '2022-09-08', 21, 15, 5, 12.3, 8.0, 2.0, 18.6, 15.9, 12.4, 62, 42, 22, 1.4, 2.4, 3.9),
(10, '2022-10-08', 32, 30, 25, 19.5, 17.8, 14.1, 23.2, 21.4, 18.7, 85, 80, 70, 0.2, 0.4, 0.8),
(11, '2022-11-08', 23, 17, 7, 13.7, 9.2, 2.9, 19.5, 16.8, 13.1, 68, 48, 28, 1.1, 2.1, 3.6),
(12, '2022-12-08', 29, 23, 11, 17.4, 12.3, 4.9, 21.8, 18.7, 14.8, 78, 58, 38, 0.6, 1.6, 3.1),
(13, '2023-01-08', 18, 12, 3, 10.5, 6.1, 1.0, 16.9, 14.3, 11.0, 56, 36, 16, 1.9, 2.9, 4.4),
(14, '2023-02-08', 27, 20, 10, 16.2, 11.1, 4.1, 21.0, 17.9, 14.1, 74, 54, 34, 0.5, 1.5, 3.0), 
(15, '2023-03-08', 20, 14, 4, 11.8, 7.3, 1.7, 17.8, 15.2, 11.8, 60, 40, 20, 1.6, 2.6, 4.1),
(16, DATE_TRUNC('month', CURRENT_DATE - INTERVAL '5 months') + INTERVAL '7 days', 24, 18, 8, 14.4, 9.6, 3.2, 20.4, 17.4, 13.7, 70, 50, 30, 0.9, 1.9, 3.4),
(17, DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month') + INTERVAL '7 days', 22, 16, NULL, 13.2, 8.8, NULL, 19.1, 16.3, NULL, 65, 45, NULL, 1.3, 2.3, NULL);

INSERT INTO adverse_events (treatment_id, reported_dt, description)
VALUES  
(1, '2022-01-15', 'Mild injection site reaction'),
(2, '2022-02-28', 'Headache, nausea'),
(4, '2022-04-10', 'Severe allergic reaction, hospitalization required'),
(5, '2022-05-20', 'Upper respiratory infection'),
(7, '2022-07-22', 'Mild injection site reaction'), 
(9, '2022-09-18', 'Diarrhea'),
(11, '2022-11-30', 'Elevated liver enzymes'),
(14, '2023-02-25', 'Mild skin rash');

INSERT INTO concomitant_meds (treatment_id, med_name, start_dt, end_dt, dose_amt, dose_unit, freq_hrs)
VALUES
(1, 'Acetaminophen', '2022-01-01', '2022-01-07', 500, 'mg', 6),
(1, 'Ibuprofen', '2022-01-08', '2022-01-14', 200, 'mg', 8), 
(2, 'Loratadine', '2022-02-15', '2022-03-15', 10, 'mg', 24),
(3, 'Multivitamin', '2022-03-10', NULL, 1, 'tablet', 24),
(4, 'Epinephrine', '2022-04-10', '2022-04-10', 0.3, 'mg', NULL),
(4, 'Diphenhydramine', '2022-04-10', '2022-04-17', 50, 'mg', 6),
(5, 'Amoxicillin', '2022-05-20', '2022-05-30', 500, 'mg', 8),
(6, 'Calcium supplement', '2022-06-15', NULL, 600, 'mg', 24), 
(7, 'Acetaminophen', '2022-07-15', '2022-07-21', 500, 'mg', 6),
(8, 'Cetirizine', '2022-08-01', '2022-08-14', 10, 'mg', 24),
(9, 'Loperamide', '2022-09-18', '2022-09-20', 4, 'mg', 6),
(11, 'Ursodiol', '2022-11-30', '2022-12-30', 300, 'mg', 8),
(12, 'Vitamin D', '2022-12-01', NULL, 1000, 'IU', 24),
(13, 'Acetaminophen', '2023-01-08', '2023-01-14', 500, 'mg', 6),
(14, 'Hydrocortisone cream', '2023-02-25', '2023-03-07', 10, 'g', 12);
