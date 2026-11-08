# Normalisation of the MedConnect Database

## 1. Unnormalised starting point

Imagine MedConnect first stored everything in one flat table:

ConsultationRecord(consultation_id, patient_name, patient_phone, doctor_name,
doctor_license, specialty_name, consultation_fee, slot_start, slot_end,
diagnosis, drugs, payment_amount, payment_status)

Example row:

| consultation_id | patient_name | doctor_name | specialty_name | drugs |
|---|---|---|---|---|
| 1 | Ada Obi | Dr Musa | Paediatrics | Amoxicillin 500mg; Paracetamol 500mg |

### Problems (anomalies)

- **Update anomaly:** If Dr Musa changes his fee, every one of his consultation rows must be edited. Missing one leaves inconsistent data.
- **Insert anomaly:** A new doctor or drug cannot be stored until a consultation involves them.
- **Delete anomaly:** Deleting a doctor's only consultation also deletes the doctor's details.
- **Repeating group:** The `drugs` column holds several values in one cell.

## 2. First Normal Form (1NF)

**Rule:** every column holds a single atomic value, and there are no repeating groups.

**Fix:** put each drug on its own row. The key becomes (consultation_id, drug_name).

| consultation_id | drug_name | dosage | patient_name | doctor_name |
|---|---|---|---|---|
| 1 | Amoxicillin | 500mg | Ada Obi | Dr Musa |
| 1 | Paracetamol | 500mg | Ada Obi | Dr Musa |

Patient and doctor details are still repeated on every drug row.

## 3. Second Normal Form (2NF)

**Rule:** the table is in 1NF and no non-key column depends on only part of a composite key.

With key (consultation_id, drug_name):
- patient and doctor details, slot times, and payment depend on **consultation_id only**.
- drug form and unit depend on **drug_name only**.

**Fix:** split into separate tables:
- Consultation (consultation_id, patient details, doctor details, slot, payment)
- Drug (drug_id, name, form, unit)
- PrescriptionItem (prescription_id, drug_id, dosage, duration_days)

## 4. Third Normal Form (3NF)

**Rule:** the table is in 2NF and no non-key column depends on another non-key column (no transitive dependencies).

Transitive dependencies found in Consultation:
- consultation_id -> doctor_id -> doctor_name, license_no, specialty, consultation_fee
- doctor_id -> specialty_id -> specialty_name
- consultation_id -> patient_id -> patient_name, phone, blood_group
- consultation_id -> slot_id -> start_time, end_time

**Fix:** move each into its own table, linked by a foreign key:

| Dependency removed | New table |
|---|---|
| patient details | patient |
| doctor details | doctor |
| specialty name | specialty |
| slot times | availability_slot |
| payment details | payment |
| diagnosis text | diagnosis |
| login details (email, password, role) | users |

## 5. Final result

The final schema has 12 tables in 3NF: users, specialty, patient, doctor,
availability_slot, consultation, diagnosis, drug, prescription,
prescription_item, payment, review.

How the anomalies are now fixed:
- **Update:** a doctor's fee is stored once, in `doctor`.
- **Insert:** doctors and drugs can exist before any consultation.
- **Delete:** removing a consultation does not remove the doctor or patient.
- **Repeating groups:** drugs live in `prescription_item`, one row per drug.

## 6. Deliberate design decisions

- `payment.amount` is stored separately from `doctor.consultation_fee`. The fee can change later, but the amount actually paid must stay as a historical record.
- `consultation.doctor_id` repeats the doctor of the slot. This is intentional: a composite foreign key (slot_id, doctor_id) guarantees both always match.
- `availability_slot.is_booked` can be derived from whether a consultation exists for the slot. It is kept as a small controlled redundancy to make doctor-availability searches faster (used in Portfolio 2).