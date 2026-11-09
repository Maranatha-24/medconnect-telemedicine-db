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
## Query 3: Open Cardiology slots in the next 7 days

| | Without idx_slot_start_time | With idx_slot_start_time |
|---|---|---|
| Access to availability_slot | Bitmap Index Scan on constraint index (doctor_id, start_time) | Index Scan on idx_slot_start_time |
| Sort step | top-N heapsort (282 rows) | none |
| Execution time | 9.382 ms | 3.622 ms |

**Analysis:** Even without the new index, PostgreSQL used the index created by
the UNIQUE (doctor_id, start_time) constraint from Portfolio 1, so the query was
already fast. The new index stores slots in start_time order, so PostgreSQL
reads them in the order the query asks for, skips booked slots, and stops as
soon as LIMIT 20 is satisfied. This removed the sort and made the query about
2.6 times faster. The gain is small in absolute terms because the dataset is
only 200,000 slots, and the effect would grow with a larger table.
## Queries 4 and 5: aggregation and window functions

**Query 4** uses GROUP BY with HAVING to list specialties with more than 9,000
completed consultations, with the average doctor fee. All 10 specialties
qualified, with between 9,617 and 9,871 completed consultations each.

**Query 5** uses RANK() OVER (PARTITION BY specialty ORDER BY
completed_consultations DESC) to rank the five doctors in each specialty. The
result has 50 rows. Two Orthopaedics doctors tied on 1,904 consultations and
share rank 4, which shows that RANK() gives tied rows the same rank and skips
the next rank.

Screenshots: Screenshots/query4-result.png, query5-result.png and
query5-result-tie.png.

## Summary of Portfolio 2

| Query | Technique | Index added | Before | After | Change |
|---|---|---|---|---|---|
| 1. Patient history | joins, selective filter | idx_consultation_patient | 59.630 ms | 0.477 ms | about 125x faster |
| 2. Doctor workload | joins, GROUP BY, date filter | idx_slot_start_time | 147.526 ms | 131.905 ms | about 11% faster |
| 3. Open Cardiology slots | joins, ORDER BY, LIMIT | idx_slot_start_time | 9.382 ms | 3.622 ms | about 2.6x faster |
| 4. Specialty totals | GROUP BY, HAVING | none needed | not tuned | | |
| 5. Doctor ranking | window function RANK() | none needed | not tuned | | |

**Conclusion:** Indexes helped most when a query selected a tiny fraction of a
table (Query 1). When a query read a large share of the data (Query 2), the
gain was small, because the slowest step was not the one the index targeted.