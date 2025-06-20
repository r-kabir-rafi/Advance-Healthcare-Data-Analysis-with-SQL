-- Create table matching CSV structure

CREATE TABLE healthcare_dataset_raw(
	name VARCHAR(100),
    age INT,
    gender VARCHAR(10),
    blood_type VARCHAR(5),
    medical_condition VARCHAR(100),
    date_of_admission DATE,
    doctor VARCHAR(100),
    hospital VARCHAR(100),
    insurance_provider VARCHAR(100),
    billing_amount DECIMAL(10,2),
    room_number VARCHAR(10),
    admission_type VARCHAR(20),
    discharge_date DATE,
    medication VARCHAR(100),
    test_results VARCHAR(100)
);

-- HERE, we need to import our csv dataset . then we will nomalize this table as we want to make our analysis clearer. 

-- ====================================
-- NORMALIZATION: STRUCTURED TABLES
-- ====================================


-- Patients table
CREATE TABLE patients (
    patient_id SeRIAL PRIMARY KEY,
  
    name VARCHAR(100),
    age INT,
    gender VARCHAR(10),
    blood_type VARCHAR(5)
);

-- Admissions table
CREATE TABLE admissions (
    admission_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
	
    date_of_admission DATE,
    admission_type VARCHAR(20),
    discharge_date DATE,
    doctor VARCHAR(100),
    hospital VARCHAR(100),
    room_number VARCHAR(10)
);

-- Conditions table
CREATE TABLE conditions (
    condition_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
	
    medical_condition VARCHAR(100),
    medication VARCHAR(100),
    test_results VARCHAR(100)
);

-- Billing table
CREATE TABLE billing (
    billing_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    billing_amount DECIMAL(10,2),
    insurance_provider VARCHAR(100)
);


-- Now we need insert into Noramlized tables from Raw table.

-- ============================================
-- INSERT INTO NORMALIZED TABLES FROM RAW TABLE
-- ============================================

-- Insert distinct patients

INSERT INTO patients(
	name, age, gender, blood_type)
SELECT DISTINCT 
	name, age, gender, blood_type
FROM healthcare_dataset_raw;

-- Insert admissions
INSERT INTO admissions (patient_id, date_of_admission, admission_type, discharge_date, doctor, hospital, room_number)
	SELECT p.patient_id, r.date_of_admission, r.admission_type, r.discharge_date, r.doctor, r.hospital, r.room_number
FROM healthcare_dataset_raw r
JOIN patients p 
	ON r.name = p.name 
	AND r.age = p.age 
	AND r.gender = p.gender;

-- Insert conditions
INSERT INTO conditions(
	patient_id, medical_condition, medication, test_results)
SELECT 
	p.patient_id, r.medical_condition, r.medication, r.test_results
FROM healthcare_dataset_raw r
JOIN patients p 
	ON r.name = p.name 
	AND r.age = p.age 
	AND r.gender = p.gender;

-- Insert billing
INSERT INTO billing(
	patient_id, billing_amount, insurance_provider)
SELECT p.patient_id, r.billing_amount, r.insurance_provider
FROM healthcare_dataset_raw r
JOIN patients p 
	ON r.name = p.name 
	AND r.age = p.age 
	AND r.gender = p.gender;
