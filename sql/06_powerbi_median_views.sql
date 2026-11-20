-- 06_powerbi_median_views.sql
-- Purpose: pre-computed medians for Power BI.
--
-- Why this file exists: a median needs all 6.1 million ride lengths sorted in
-- memory. Power BI Desktop runs out of resources doing that inside a chart
-- ("Query has exceeded the available resources"). PostgreSQL does it once, here,
-- and Power BI only loads the small result.
--
-- Trade-off: these numbers are fixed. They do not react to slicers
-- (for example, a weekend-only filter). Use them for the member vs casual
-- headline and the monthly trend only.
--
-- Same definition as the pandas code: median of ride_length_minutes.

CREATE OR REPLACE VIEW vw_median_overall AS
SELECT
    member_casual,
    ROUND(
        (PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ride_length_minutes))::NUMERIC,
        2
    ) AS median_ride_minutes
FROM vw_fact_rides
GROUP BY member_casual;


CREATE OR REPLACE VIEW vw_median_by_month AS
SELECT
    member_casual,
    month_start,
    ROUND(
        (PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ride_length_minutes))::NUMERIC,
        2
    ) AS median_ride_minutes
FROM vw_fact_rides
GROUP BY member_casual, month_start;
