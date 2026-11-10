-- PART 1: READ COMMITTED (PostgreSQL default): non-repeatable read
-- TAB A
BEGIN;
SELECT doctor_id, consultation_fee FROM doctor WHERE doctor_id = 1;   -- 21000.00
-- TAB B (auto-commit)
UPDATE doctor SET consultation_fee = consultation_fee + 1000 WHERE doctor_id = 1;
-- TAB A
SELECT doctor_id, consultation_fee FROM doctor WHERE doctor_id = 1;   -- 22000.00 (changed!)
COMMIT;

-- PART 2: REPEATABLE READ: same read stays the same
-- TAB A
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT doctor_id, consultation_fee FROM doctor WHERE doctor_id = 1;   -- 22000.00
-- TAB B (auto-commit)
UPDATE doctor SET consultation_fee = consultation_fee + 1000 WHERE doctor_id = 1;
-- TAB A
SELECT doctor_id, consultation_fee FROM doctor WHERE doctor_id = 1;   -- still 22000.00
COMMIT;
SELECT doctor_id, consultation_fee FROM doctor WHERE doctor_id = 1;   -- 23000.00

-- CLEAN-UP: restore the original fee
UPDATE doctor SET consultation_fee = 21000 WHERE doctor_id = 1;