# MedConnect: Advanced Database Systems Portfolio

**Student:** Iyanda Maranatha
**Course:** MIT 8103 Advanced Database Systems, Master of Information Technology

## Case study: MedConnect

MedConnect is an online healthcare and telemedicine platform in Nigeria. Patients book video consultations with doctors, pay online, and receive diagnoses and prescriptions. The database users are patients and doctors. The main data are patients, doctors, availability slots, consultations, payments, diagnoses and prescriptions. All five portfolios use this same case study.

## Portfolio overview

| Portfolio | Topic | What it contains |
|---|---|---|
| [Portfolio 1](portfolio-1-database-design/) | Database Design and Modelling | PostgreSQL schema (12 tables), DBML model, ER diagram, normalisation explanation |
| [Portfolio 2](portfolio-2-query-optimisation/) | Query Processing and Optimisation | Seeded data (200,000 slots, 119,537 consultations), 5 queries, indexes, before/after `EXPLAIN ANALYZE` |
| [Portfolio 3](portfolio-3-transactions-concurrency/) | Transactions and Concurrency | COMMIT, ROLLBACK, race condition, `SELECT ... FOR UPDATE`, isolation levels |
| [Portfolio 4](portfolio-4-nosql/) | NoSQL and Advanced Data Models | MongoDB document model, queries, aggregation pipeline |
| [Portfolio 5](portfolio-5-distributed-cloud/) | Distributed and Cloud Database | MongoDB Atlas replica set, majority write, CAP and sharding discussion |

## Tools used

PostgreSQL 18, pgAdmin 4, MongoDB Atlas (free M0 cluster), MongoDB Compass, Visual Studio Code, Git and GitHub.

## How to review this repository

Each portfolio folder has its own `README.md` that explains what was done, how it was run and tested, and shows screenshots of the results. Scripts are numbered in the order they should be run, and screenshots are in each folder's `Screenshots` folder.

## Declaration of Responsibility

I acknowledge that the use of AI tools does not relieve me of my responsibility for the accuracy and understanding of the submitted work. I understand that I am the primary author of this portfolio.

AI tool used: Claude (Anthropic)

What it was used for: Guidance, writing and explaining the SQL and MongoDB scripts, drafting the README files and explaining database concepts.

How I retrieved and verified the output: I ran every script myself in pgAdmin, MongpDB compass and the MongoDB shell, captured the results as screenshots, corrected error that appeared, committed the work progressively to GitHub and checked the published repository. 
