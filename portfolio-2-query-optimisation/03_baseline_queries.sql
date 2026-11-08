-- Query 1: a patient's consultation history
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.consultation_id, c.reason, c.status, s.start_time, d.full_name AS doctor
FROM consultation c
JOIN availability_slot s ON s.slot_id = c.slot_id
JOIN doctor d ON d.doctor_id = c.doctor_id
WHERE c.patient_id = 500
ORDER BY s.start_time DESC;

-- Query 2: doctor workload in the last 30 days
EXPLAIN (ANALYZE, BUFFERS)
SELECT d.doctor_id, d.full_name, COUNT(*) AS completed_consultations
FROM consultation c
JOIN doctor d ON d.doctor_id = c.doctor_id
JOIN availability_slot s ON s.slot_id = c.slot_id
WHERE c.status = 'Completed'
  AND s.start_time >= CURRENT_DATE - 30
GROUP BY d.doctor_id, d.full_name
ORDER BY completed_consultations DESC;