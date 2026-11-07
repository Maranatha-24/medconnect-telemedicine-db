-- =====================================================
-- MedConnect Telemedicine Platform: PostgreSQL schema
-- MIT 8103 Advanced Database Systems, Portfolio 1
-- Run inside the database "medconnect"
-- =====================================================

DROP TABLE IF EXISTS review CASCADE;
DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS prescription_item CASCADE;
DROP TABLE IF EXISTS prescription CASCADE;
DROP TABLE IF EXISTS diagnosis CASCADE;
DROP TABLE IF EXISTS consultation CASCADE;
DROP TABLE IF EXISTS availability_slot CASCADE;
DROP TABLE IF EXISTS drug CASCADE;
DROP TABLE IF EXISTS doctor CASCADE;
DROP TABLE IF EXISTS patient CASCADE;
DROP TABLE IF EXISTS specialty CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 1. Users (login accounts)
CREATE TABLE users (
    user_id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email          VARCHAR(255) NOT NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,
    role           VARCHAR(10)  NOT NULL
                   CHECK (role IN ('patient', 'doctor', 'admin')),
    created_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Specialty
CREATE TABLE specialty (
    specialty_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name           VARCHAR(100) NOT NULL UNIQUE
);

-- 3. Patient
CREATE TABLE patient (
    patient_id     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id        BIGINT NOT NULL UNIQUE
                   REFERENCES users(user_id) ON DELETE CASCADE,
    full_name      VARCHAR(150) NOT NULL,
    date_of_birth  DATE NOT NULL CHECK (date_of_birth <= CURRENT_DATE),
    gender         VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    phone          VARCHAR(20),
    blood_group    VARCHAR(3)
                   CHECK (blood_group IN ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
    allergies      TEXT
);

-- 4. Doctor
CREATE TABLE doctor (
    doctor_id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id          BIGINT NOT NULL UNIQUE
                     REFERENCES users(user_id) ON DELETE CASCADE,
    specialty_id     INT NOT NULL REFERENCES specialty(specialty_id),
    full_name        VARCHAR(150) NOT NULL,
    license_no       VARCHAR(50)  NOT NULL UNIQUE,
    consultation_fee NUMERIC(10,2) NOT NULL CHECK (consultation_fee >= 0)
);

-- 5. Availability slot
CREATE TABLE availability_slot (
    slot_id     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    doctor_id   BIGINT NOT NULL REFERENCES doctor(doctor_id) ON DELETE CASCADE,
    start_time  TIMESTAMP NOT NULL,
    end_time    TIMESTAMP NOT NULL,
    is_booked   BOOLEAN NOT NULL DEFAULT FALSE,
    CHECK (end_time > start_time),
    UNIQUE (doctor_id, start_time),
    UNIQUE (slot_id, doctor_id)
);

-- 6. Consultation
CREATE TABLE consultation (
    consultation_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id      BIGINT NOT NULL REFERENCES patient(patient_id),
    doctor_id       BIGINT NOT NULL,
    slot_id         BIGINT NOT NULL UNIQUE,
    mode            VARCHAR(10) NOT NULL CHECK (mode IN ('video', 'audio', 'chat')),
    status          VARCHAR(15) NOT NULL DEFAULT 'Scheduled'
                    CHECK (status IN ('Scheduled', 'In-Progress', 'Completed', 'Cancelled')),
    reason          TEXT,
    started_at      TIMESTAMP,
    ended_at        TIMESTAMP,
    CHECK (ended_at IS NULL OR started_at IS NULL OR ended_at > started_at),
    FOREIGN KEY (slot_id, doctor_id)
        REFERENCES availability_slot(slot_id, doctor_id)
);

-- 7. Diagnosis
CREATE TABLE diagnosis (
    diagnosis_id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    consultation_id BIGINT NOT NULL
                    REFERENCES consultation(consultation_id) ON DELETE CASCADE,
    description     VARCHAR(255) NOT NULL,
    notes           TEXT
);

-- 8. Drug
CREATE TABLE drug (
    drug_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name      VARCHAR(150) NOT NULL UNIQUE,
    form      VARCHAR(30),
    unit      VARCHAR(20)
);

-- 9. Prescription
CREATE TABLE prescription (
    prescription_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    consultation_id BIGINT NOT NULL
                    REFERENCES consultation(consultation_id) ON DELETE CASCADE,
    issued_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 10. Prescription item (resolves many-to-many)
CREATE TABLE prescription_item (
    prescription_id BIGINT NOT NULL
                    REFERENCES prescription(prescription_id) ON DELETE CASCADE,
    drug_id         INT NOT NULL REFERENCES drug(drug_id),
    dosage          VARCHAR(100) NOT NULL,
    duration_days   INT NOT NULL CHECK (duration_days > 0),
    PRIMARY KEY (prescription_id, drug_id)
);

-- 11. Payment
CREATE TABLE payment (
    payment_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    consultation_id BIGINT NOT NULL UNIQUE
                    REFERENCES