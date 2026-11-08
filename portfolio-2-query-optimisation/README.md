# Portfolio 2: Query Processing and Optimisation

## Dataset
50 doctors, 20,000 patients, 200,000 availability slots and 119,537
consultations, generated with SQL (see scripts 01 and 02).

## Query 1: A patient's consultation history

| | Before index | After index |
|---|---|---|
| Scan on consultation | Seq Scan | Bitmap Index Scan on idx_consultation_patient |
| Rows removed by filter | 119,531 | 0 |
| Buffers | 1,667 | 33 |
| Execution time | 59.630 ms | 0.477 ms |

**Index:** `CREATE INDEX idx_consultation_patient ON consultation (patient_id);`

**Analysis:** Without an index, PostgreSQL read all 119,537 consultation rows
to return 6. The index lets it go straight to those 6 rows. The query became
about 125 times faster.

## Query 2: Doctor workload in the last 30 days

| | Before index | After index |
|---|---|---|
| Scan on availability_slot | Parallel Seq Scan | Parallel Index Only Scan on idx_slot_start_time |
| Heap fetches | not applicable | 0 |
| Execution time | 147.526 ms | 125.756 ms |

**Index:** `CREATE INDEX idx_slot_start_time ON availability_slot (start_time) INCLUDE (slot_id);`

**Analysis:** The index removed the sequential scan of 200,000 slots. The
improvement is modest because the query still reads about 107,000 completed
consultations and joins them with about 50,000 recent slots. An index speeds
up the step it targets, but total time depends on the slowest step.