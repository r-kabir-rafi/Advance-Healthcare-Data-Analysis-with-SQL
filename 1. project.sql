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


-- Smallest medical bill greater than $0.00

SELECT 
    p.name, 
    p.patient_id, 
    MIN(b.billing_amount) AS min_bill_amount
FROM billing b
JOIN patients p ON b.patient_id = p.patient_id
GROUP BY p.name, p.patient_id
HAVING MIN(b.billing_amount) > 0.00
ORDER BY min_bill_amount;

-- Average medical bill

SELECT 
    CAST(AVG(billing_amount) AS DECIMAL(10, 2)) AS average_bill_amount
FROM billing;

-- Patients with same name as doctor

SELECT *
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
WHERE p.name = a.doctor;

-- All entries of Michael Williams

SELECT *
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
WHERE p.name = 'Michael Williams'
ORDER BY p.patient_id;

-- Doctors working at more than one hospital

SELECT COUNT(*) AS doctor_count
FROM (
    SELECT doctor
    FROM admissions
    GROUP BY doctor
    HAVING COUNT(DISTINCT hospital) > 1
) AS multi_hospital_docs;

-- Doctors with most patient visits

SELECT 
    doctor,
    COUNT(*) AS number_of_patient_visits
FROM admissions
GROUP BY doctor
ORDER BY number_of_patient_visits DESC
LIMIT 10;

-- Condition treatment counts

SELECT 
    medical_condition, 
    COUNT(patient_id) AS number_of_instances
FROM conditions
GROUP BY medical_condition
ORDER BY number_of_instances DESC;

-- Visits per year (2019-2024)

SELECT 
    EXTRACT(YEAR FROM date_of_admission) AS year, 
    COUNT(*) AS visit_count
FROM admissions
GROUP BY EXTRACT(YEAR FROM date_of_admission)
ORDER BY visit_count DESC;

-- Most prescribed medication for asthma

SELECT 
    medication, 
    COUNT(*) AS condition_count
FROM conditions
WHERE medical_condition = 'asthma'
GROUP BY medication
ORDER BY condition_count DESC
LIMIT 1;

-- Patient gender distribution

SELECT 
    gender, 
    COUNT(*) AS patient_count
FROM patients
GROUP BY gender
ORDER BY patient_count DESC;

-- Admission types distribution

SELECT
    admission_type,
    COUNT(*) AS count
FROM admissions
GROUP BY admission_type
ORDER BY count DESC;

-- Emergency visits by condition

SELECT 
    c.medical_condition,
    COUNT(*) AS emergency_visits
FROM admissions a
JOIN conditions c ON a.patient_id = c.patient_id
WHERE a.admission_type = 'Emergency'
GROUP BY c.medical_condition
ORDER BY emergency_visits DESC;

-- Common blood types

SELECT 
    blood_type, 
    COUNT(*) AS blood_type_count
FROM patients
GROUP BY blood_type
ORDER BY blood_type_count DESC;

-- Most common insurance providers

SELECT 
    insurance_provider, 
    COUNT(*) AS provider_count
FROM billing
GROUP BY insurance_provider
ORDER BY provider_count DESC;

-- Average billing amount by medical condition

SELECT 
    c.medical_condition, 
    CAST(AVG(b.billing_amount) AS DECIMAL(10, 2)) AS average_bill
FROM conditions c
JOIN billing b ON c.patient_id = b.patient_id
GROUP BY c.medical_condition
ORDER BY average_bill DESC;

-- Hospitals with highest billing totals

SELECT 
    a.hospital, 
    SUM(b.billing_amount) AS bill_sum
FROM admissions a
JOIN billing b ON a.patient_id = b.patient_id
GROUP BY a.hospital
ORDER BY bill_sum DESC
LIMIT 10;

-- Average length of stay by condition

SELECT
    c.medical_condition,
    AVG(DATE_PART('day', discharge_date - date_of_admission)) AS average_length_of_stay
FROM admissions a
JOIN conditions c ON a.patient_id = c.patient_id
GROUP BY c.medical_condition
ORDER BY average_length_of_stay DESC;

-- Monthly trend of hospital visits

SELECT 
    TO_CHAR(date_of_admission, 'YYYY-MM') AS admission_month, 
    COUNT(*) AS visit_count
FROM admissions
GROUP BY TO_CHAR(date_of_admission, 'YYYY-MM')
ORDER BY admission_month;

-- Patients with highest billing totals

SELECT 
    p.name, 
    b.patient_id,
    SUM(b.billing_amount) AS total_billing_amount
FROM billing b
JOIN patients p ON b.patient_id = p.patient_id
GROUP BY b.patient_id, p.name
ORDER BY total_billing_amount DESC;

-- Doctors with most diverse conditions treated

SELECT 
    a.doctor, 
    COUNT(DISTINCT c.medical_condition) AS unique_conditions_treated
FROM admissions a
JOIN conditions c ON a.patient_id = c.patient_id
GROUP BY a.doctor
ORDER BY unique_conditions_treated DESC
LIMIT 100;

-- Patients admitted for multiple conditions

SELECT
    p.name,
    COUNT(DISTINCT c.medical_condition) AS multiple_conditions
FROM patients p
JOIN conditions c ON p.patient_id = c.patient_id
GROUP BY p.name
HAVING COUNT(DISTINCT c.medical_condition) > 1
ORDER BY multiple_conditions DESC;

-- Conditions among patients with six distinct conditions

WITH PatientConditions AS (
    SELECT p.name, c.medical_condition
    FROM conditions c
    JOIN patients p ON c.patient_id = p.patient_id
),
PatientsWithSixConditions AS (
    SELECT name
    FROM PatientConditions
    GROUP BY name
    HAVING COUNT(DISTINCT medical_condition) = 6
)
SELECT 
    pc.medical_condition, 
    COUNT(*) AS condition_count
FROM PatientConditions pc
JOIN PatientsWithSixConditions p6 ON pc.name = p6.name
GROUP BY pc.medical_condition
ORDER BY condition_count DESC;

-- Conditions among patients with five distinct conditions

WITH PatientConditions AS (
    SELECT p.name, c.medical_condition
    FROM conditions c
    JOIN patients p ON c.patient_id = p.patient_id
),
PatientsWithFiveConditions AS (
    SELECT name
    FROM PatientConditions
    GROUP BY name
    HAVING COUNT(DISTINCT medical_condition) = 5
)
SELECT 
    pc.medical_condition, 
    COUNT(*) AS condition_count
FROM PatientConditions pc
JOIN PatientsWithFiveConditions p5 ON pc.name = p5.name
GROUP BY pc.medical_condition
ORDER BY condition_count DESC;

-- Patients readmitted within 30 days


WITH AdmissionsSorted AS (
    SELECT 
        patient_id,
        date_of_admission,
        LEAD(date_of_admission) OVER (PARTITION BY patient_id ORDER BY date_of_admission) AS next_admission
    FROM admissions
)
SELECT 
    patient_id,
    COUNT(*) AS readmission_count
FROM AdmissionsSorted
WHERE next_admission IS NOT NULL AND (next_admission - date_of_admission) <= 30
GROUP BY patient_id
ORDER BY readmission_count DESC;

-- Correlation between age and billing


SELECT 
    p.age,
    CAST(AVG(b.billing_amount) AS DECIMAL(10,2)) AS average_bill
FROM billing b
JOIN patients p ON b.patient_id = p.patient_id
GROUP BY p.age
ORDER BY p.age;

-- Correlation coefficient between age and billing


WITH BillingByAge AS (
    SELECT 
        CAST(p.age AS FLOAT) AS age,
        CAST(AVG(b.billing_amount) AS FLOAT) AS avg_billing_amount
    FROM billing b
    JOIN patients p ON b.patient_id = p.patient_id
    GROUP BY p.age
),
Stats AS (
    SELECT 
        COUNT(*) AS n,
        SUM(age) AS sum_x,
        SUM(avg_billing_amount) AS sum_y,
        SUM(age * avg_billing_amount) AS sum_xy,
        SUM(age * age) AS sum_x2,
        SUM(avg_billing_amount * avg_billing_amount) AS sum_y2
    FROM BillingByAge
)
SELECT 
    (n * sum_xy - sum_x * sum_y) /
    (SQRT((n * sum_x2 - sum_x * sum_x) * (n * sum_y2 - sum_y * sum_y))) AS correlation_coefficient
FROM Stats;
