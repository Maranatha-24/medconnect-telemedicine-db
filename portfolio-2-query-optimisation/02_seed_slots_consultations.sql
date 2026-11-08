-- 1. Availability slots: 50 doctors x 200 days x 20 slots = 200,000 rows
INSERT INTO availability_slot (doctor_id, start_time, end_time, is_booked)
SELECT d.doctor_id,
       t.ts,
       t.ts + interval '30 minutes',
       FALSE
FROM doctor d
CROSS JOIN generate_series(0, 199) AS day_offset
CROSS JOIN generate_series(0, 19) AS slot_no
CROSS JOIN LATERAL (
    SELECT (CURRENT_DATE - 180 + day_offset) + time '08:00'
           + slot_no * interval '30 minutes' AS ts
) t;

-- 2. Consultations on roughly 60% of the slots
INSERT INTO consultation
    (patient_id, doctor_id, slot_id, mode, status, reason, started_at, ended_at)
SELECT patient_id, doctor_id, slot_id, mode, status, reason,
       CASE WHEN status = 'Completed' THEN start_time END,
       CASE WHEN status = 'Completed' THEN end_time END
FROM (
    SELECT (SELECT min(patient_id) FROM patient)
             + floor(random() * (SELECT count(*) FROM patient))::bigint AS patient_id,
           s.doctor_id,
           s.slot_id,
           s.start_time,
           s.end_time,
           (ARRAY['video','audio','chat'])[1 + floor(random() * 3)::int] AS mode,
           CASE
               WHEN s.start_time >= now() THEN 'Scheduled'
               WHEN random() < 0.9 THEN 'Completed'
               ELSE 'Cancelled'
           END AS status,
           (ARRAY['Fever and headache','Persistent cough','Skin rash',
                  'Follow-up visit','Back pain','Anxiety and sleep problems',
                  'Child vaccination advice','Blood pressure review',
                  'Stomach pain','Eye irritation'])[1 + floor(random() * 10)::int] AS reason
    FROM availability_slot s
    WHERE random() < 0.6
) x;

-- 3. Mark the booked slots
UPDATE availability_slot
SET is_booked = TRUE
WHERE slot_id IN (SELECT slot_id FROM consultation);

-- 4. Refresh the planner's statistics
ANALYZE;