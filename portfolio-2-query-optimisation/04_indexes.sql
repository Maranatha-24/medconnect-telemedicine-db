-- Query 1: patient history lookups
CREATE INDEX idx_consultation_patient ON consultation (patient_id);
ANALYZE consultation;

-- Query 2: doctor workload in the last 30 days
-- Run the next two statements separately in pgAdmin
-- (VACUUM cannot run inside a transaction block)
CREATE INDEX idx_slot_start_time ON availability_slot (start_time) INCLUDE (slot_id);
-- then, as a separate execution:
VACUUM ANALYZE availability_slot;