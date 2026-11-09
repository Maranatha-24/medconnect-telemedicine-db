-- Query 4: specialties with many completed consultations (GROUP BY ... HAVING)
SELECT sp.name AS specialty,
       COUNT(*) AS completed_consultations,
       ROUND(AVG(d.consultation_fee), 0) AS avg_fee
FROM consultation c
JOIN doctor d ON d.doctor_id = c.doctor_id
JOIN specialty sp ON sp.specialty_id = d.specialty_id
WHERE c.status = 'Completed'
GROUP BY sp.name
HAVING COUNT(*) > 9000
ORDER BY completed_consultations DESC;

-- Query 5: rank doctors within each specialty (window function)
SELECT specialty, doctor, completed_consultations,
       RANK() OVER (PARTITION BY specialty
                    ORDER BY completed_consultations DESC) AS rank_in_specialty
FROM (
    SELECT sp.name AS specialty,
           d.full_name AS doctor,
           d.doctor_id,
           COUNT(*) AS completed_consultations
    FROM consultation c
    JOIN doctor d ON d.doctor_id = c.doctor_id
    JOIN specialty sp ON sp.specialty_id = d.specialty_id
    WHERE c.status = 'Completed'
    GROUP BY sp.name, d.full_name, d.doctor_id
) t
ORDER BY specialty, rank_in_specialty;