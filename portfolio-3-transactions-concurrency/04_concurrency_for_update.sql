-- TAB A (Patient 3): lock the slot
BEGIN;
SELECT slot_id, doctor_id, is_booked
FROM availability_slot
WHERE slot_id = 182101 AND is_booked = FALSE
FOR UPDATE;

-- TAB B (Patient 4): tries to lock the same slot and WAITS
BEGIN;
SELECT slot_id, doctor_id, is_booked
FROM availability_slot
WHERE slot_id = 182101 AND is_booked = FALSE
FOR UPDATE;

-- TAB A: book and commit; Tab B then wakes up and returns 0 rows
INSERT INTO consultation (patient_id, doctor_id, slot_id, mode, status, reason)
VALUES (3, 1, 182101, 'video', 'Scheduled', 'Cough');
UPDATE availability_slot SET is_booked = TRUE WHERE slot_id = 182101;
COMMIT;

-- TAB B: nothing to book, so end the transaction
ROLLBACK;