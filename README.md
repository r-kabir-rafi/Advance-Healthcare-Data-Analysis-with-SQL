# Advance-Healthcare-Data-Analysis-with-SQL

This project is all about exploring healthcare data using SQL. I used PostgreSQL to design tables, clean messy records, and analyze real-world patterns in patient demographics, clinical visits, test results, and billing. It's a hands-on way to understand how raw data can turn into valuable insights in a healthcare setting.

---

##  Project Structure

The dataset contains **15 columns**, which are divided into **4 logical categories**:

###  Patient Demographics
- Name
- Age
- Gender
- Blood Type

###  Clinical Information
- Medical Condition
- Medication
- Test Results

###  Admission Details
- Date of Admission
- Admission Type
- Discharge Date
- Doctor
- Hospital
- Room Number

###  Financial Information
- Billing Amount
- Insurance Provider

---

## ⚙️ Technologies Used
- SQL (PostgreSQL syntax)
- DBeaver (SQL GUI Client)
- CSV file import
- GitHub for version control

---

##  Data Preparation & Cleaning

Key steps include:
- Creating normalized relational tables with constraints and foreign keys.
- Capitalizing patient names and standardizing gender values.
- Validating blood types and test result values.
- Removing negative billing entries.
- Checking illogical admission/discharge sequences.

---

## 📊 Analysis Sections

### 1. Descriptive Analysis
- Average hospital stay by condition.
- Revenue per condition.
- Monthly admission and billing trends.
- Gender-wise billing summary.

### 2. Diagnostic Analysis
- Detecting missing values and outliers.
- Readmission trends.
- Doctor workload analysis.
- Insurance provider billing efficiency.

### 3. Advanced Analysis with Window Functions
- Cumulative billing per patient.
- Ranking hospitals by revenue.
- Billing quartile distribution.
- Time between patient admissions.

---

##  Database Design (Schema)

Four tables are used:

- `patients`
- `conditions`
- `admissions`
- `billing`

Each table is interlinked using foreign keys and constraints to maintain data integrity.

---

##  How to Run

1. Clone this repo.
2. Use DBeaver or any SQL client connected to PostgreSQL.
3. Create the database and tables from the SQL script.
4. Import the `CSV` file ensuring columns align with the schema.
5. Run queries section-wise to analyze the data.

---

##  Notes

- This dataset is fictional and used for educational purposes.
- SQL code is written with readability and modularity in mind.

---

##  Learning Outcome

By the end of this project, you will understand:
- How to clean and structure real-world healthcare data.
- How to write efficient queries using joins and window functions.
- How to extract valuable insights from medical datasets using SQL alone.
