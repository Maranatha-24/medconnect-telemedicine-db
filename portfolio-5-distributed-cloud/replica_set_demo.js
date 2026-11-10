// Portfolio 5: MedConnect distributed/cloud demo (MongoDB Atlas replica set)
use medconnect_nosql

// 1. Show the replica set: 3 servers, one primary
h = db.hello(); ({ setName: h.setName, hosts: h.hosts, primary: h.primary, isWritablePrimary: h.isWritablePrimary })

// 2. Majority write: confirmed only after most servers have the data
db.replication_test.insertOne({ note: "MedConnect majority write", at: new Date() }, { writeConcern: { w: "majority" } })

// 3. Read the same data from a secondary (a replica copy)
db.getMongo().setReadPref("secondary")
db.replication_test.find()

// 4. Switch back to the primary
db.getMongo().setReadPref("primary")