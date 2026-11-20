-- ============================================================
-- 05_powerbi_views.sql: the data model the Power BI report loads
-- ============================================================
--
-- Star schema with one fact table and one dimension:
--
--   vw_dim_month (12 rows)  1 ----< *  vw_fact_rides (6.1 million rows)
--        month_start  (primary key)         month_start  (foreign key)
--
-- GRAIN of vw_fact_rides: one row = one ride. Every number in the
-- report is a count, median or share of single rides.
--
-- What is left out, and why:
--   * ride_id: 6.1 million different values, so it is the most
--     expensive column to store, and no chart needs it (counting
--     rows counts rides).
--   * started_at / ended_at: replaced by start_hour, day_number and
--     month_start. A full timestamp has millions of different values;
--     the three small columns have 24, 7 and 12.
--   * station and coordinate columns: the dashboard does not answer
--     station questions.
--
-- month_start comes from the raw FILE name (LEFT(source_file, 6)),
-- not from started_at. The 951 rides that start in the last minutes
-- of a month but belong to the next month's file therefore stay in
-- the same month as in sql/04_final_queries.sql and docs/findings.md.
-- A Power BI date table built from started_at would silently move
-- those rides and the numbers would no longer match.
--
-- The rules (weekend, commute-like, duration buckets) are written
-- here once, so Power BI measures can stay simple and the numbers
-- reconcile with the SQL and Python results.
-- ============================================================

CREATE OR REPLACE VIEW vw_fact_rides AS
SELECT
    member_casual,
    rideable_type,
    TO_DATE(LEFT(source_file, 6) || '01', 'YYYYMMDD')         AS month_start,
    EXTRACT(ISODOW FROM started_at)::SMALLINT                 AS day_number,
    day_of_week,
    EXTRACT(HOUR FROM started_at)::SMALLINT                   AS start_hour,
    ROUND(ride_length_minutes::NUMERIC, 2)                    AS ride_length_minutes,
    CASE
        WHEN ride_length_minutes < 15 THEN '<15 min'
        WHEN ride_length_minutes < 30 THEN '15-29 min'
        WHEN ride_length_minutes < 60 THEN '30-59 min'
        ELSE '60+ min'
    END                                                       AS duration_bucket,
    CASE
        WHEN ride_length_minutes < 15 THEN 1
        WHEN ride_length_minutes < 30 THEN 2
        WHEN ride_length_minutes < 60 THEN 3
        ELSE 4
    END::SMALLINT                                             AS duration_bucket_sort,
    day_of_week IN ('Saturday', 'Sunday')                     AS is_weekend,
    (
        day_of_week NOT IN ('Saturday', 'Sunday')
        AND (EXTRACT(HOUR FROM started_at) BETWEEN 6 AND 9
             OR EXTRACT(HOUR FROM started_at) BETWEEN 16 AND 19)
        AND ride_length_minutes < 30
    )                                                         AS is_commute_like
FROM cyclistic_clean;


CREATE OR REPLACE VIEW vw_dim_month AS
SELECT
    month_start,
    TO_CHAR(month_start, 'Mon YY')                            AS month_label,
    CASE
        WHEN EXTRACT(MONTH FROM month_start) IN (12, 1, 2) THEN 'Winter'
        WHEN EXTRACT(MONTH FROM month_start) IN (3, 4, 5)  THEN 'Spring'
        WHEN EXTRACT(MONTH FROM month_start) IN (6, 7, 8)  THEN 'Summer'
        ELSE 'Autumn'
    END                                                       AS season
FROM (
    SELECT DISTINCT TO_DATE(LEFT(source_file, 6) || '01', 'YYYYMMDD') AS month_start
    FROM cyclistic_clean
) AS months;
