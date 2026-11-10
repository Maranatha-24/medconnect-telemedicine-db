// Portfolio 4: MedConnect NoSQL (MongoDB Atlas, document model)
use medconnect_nosql

db.createCollection("consultation_records")

db.consultation_records.insertMany([
  {
    consultation_id: 119538, patient_id: 1,
    doctor: { doctor_id: 2, fee: 19000 }, slot_id: 181702,
    status: "Scheduled", symptoms: [], prescriptions: [],
    payment: { amount: 19000, status: "Paid" }
  },
  {
    consultation_id: 119540, patient_id: 3,
    doctor: { doctor_id: 1, fee: 21000 }, slot_id: 181705,
    status: "Completed", symptoms: ["fever", "headache", "body aches"],
    diagnosis: "Malaria (suspected)",
    prescriptions: [
      { drug: "Artemether/Lumefantrine", dose: "80/480mg", days: 3 },
      { drug: "Paracetamol", dose: "500mg", days: 3 }
    ],
    payment: { amount: 21000, status: "Paid" }
  },
  {
    consultation_id: 119541, patient_id: 4,
    doctor: { doctor_id: 2, fee: 19000 }, slot_id: 181708,
    status: "Completed", symptoms: ["cough", "sore throat"],
    diagnosis: "Upper respiratory infection",
    prescriptions: [{ drug: "Amoxicillin", dose: "500mg", days: 5 }],
    follow_up: { needed: true, in_days: 7 },
    payment: { amount: 19000, status: "Paid" }
  }
])

// Query 1: full consultation for one patient (no joins)
db.consultation_records.find({ patient_id: 3 })

// Query 2: consultations where the patient had a fever
db.consultation_records.find({ symptoms: "fever" })

// Query 3: aggregation, revenue per doctor
db.consultation_records.aggregate([
  { $group: { _id: "$doctor.doctor_id", consultations: { $sum: 1 }, revenue: { $sum: "$payment.amount" } } },
  { $sort: { revenue: -1 } }
])