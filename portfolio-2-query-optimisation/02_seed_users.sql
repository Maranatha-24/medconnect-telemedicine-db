-- Specialties
INSERT INTO specialty (name) VALUES
('General Practice'), ('Paediatrics'), ('Cardiology'), ('Dermatology'),
('Gynaecology'), ('Orthopaedics'), ('Psychiatry'), ('Ophthalmology'),
('ENT'), ('Neurology');

-- 50 doctor accounts and 20,000 patient accounts
INSERT INTO users (email, password_hash, role)
SELECT 'doctor' || g || '@medconnect.test', md5('pass' || g), 'doctor'
FROM generate_series(1, 50) AS g;

INSERT INTO users (email, password_hash, role)
SELECT 'patient' || g || '@medconnect.test', md5('pass' || g), 'patient'
FROM generate_series(1, 20000) AS g;

-- Doctor profiles
INSERT INTO doctor (user_id, specialty_id, full_name, license_no, consultation_fee)
SELECT u.user_id,
       ((u.user_id - 1) % 10) + 1,
       'Dr. ' ||
       (ARRAY['Musa','Okafor','Bello','Adeyemi','Eze','Ibrahim','Nwosu','Balogun','Olawale','Danjuma'])[1 + floor(random() * 10)::int] || ' ' ||
       (ARRAY['Chidi','Amina','Tunde','Ngozi','Segun','Fatima','Emeka','Bisi','Yusuf','Ada'])[1 + floor(random() * 10)::int],
       'MDCN-' || lpad(u.user_id::text, 6, '0'),
       (5 + floor(random() * 20)) * 1000
FROM users u
WHERE u.role = 'doctor';

-- Patient profiles
INSERT INTO patient (user_id, full_name, date_of_birth, gender, phone, blood_group, allergies)
SELECT u.user_id,
       (ARRAY['Chidi','Amina','Tunde','Ngozi','Segun','Fatima','Emeka','Bisi','Yusuf','Ada','Kemi','Ibrahim'])[1 + floor(random() * 12)::int] || ' ' ||
       (ARRAY['Adeyemi','Okafor','Bello','Eze','Musa','Nwosu','Balogun','Olawale','Danjuma','Obi'])[1 + floor(random() * 10)::int],
       DATE '1950-01-01' + (random() * 25000)::int,
       (ARRAY['male','female','other'])[1 + floor(random() * 3)::int],
       '080' || lpad(floor(random() * 100000000)::bigint::text, 8, '0'),
       (ARRAY['A+','A-','B+','B-','AB+','AB-','O+','O-'])[1 + floor(random() * 8)::int],
       CASE WHEN random() < 0.2 THEN 'Penicillin' ELSE NULL END
FROM users u
WHERE u.role = 'patient';