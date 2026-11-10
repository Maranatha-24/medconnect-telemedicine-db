-- TAB A (Patient 3)
BEGIN;
SELECT is_booked FROM availability_slot WHERE slot_id = 181717;

-- TAB B (Patient 4)
BEGIN;
SELECT is_booked FROM availability_slot WHERE slot_id = 181717;

-- TAB A
INSERT INTO consultation (patient_id, doctor_id, slot_id, mode, status, reason)
VALUES (3, 17, 181717, 'video', 'Scheduled', 'Cough');
UPDATE availability_slot SET is_booked = TRUE WHERE slot_id = 181717;
COMMIT;

-- TAB B (fails with a duplicate key error)
INSERT INTO consultation (patient_id, doctor_id, slot_id, mode, status, reason)
VALUES (4, 17, 181717, 'chat', 'Scheduled', 'Fever');
ROLLBACK;