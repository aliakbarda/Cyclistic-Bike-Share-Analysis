# Power BI Model and Dashboard Notes

The dashboard is finished: four pages, exported to `Cyclistic_Dashboard.pdf`, screenshots in `docs/images/dashboard_page1.png` to `dashboard_page4.png`. This note records how it is built, so it can be checked, refreshed or extended.

## Files

| File | What it is |
|---|---|
| `powerbi/Cyclistic_Dashboard.pbix` | The report (open with Power BI Desktop) |
| `powerbi/Cyclistic_Dashboard.pdf` | PDF export of all four pages |
| `docs/images/dashboard_page1.png` to `dashboard_page4.png` | One screenshot per page |
| `sql/06_powerbi_median_views.sql` | The two median views (`vw_median_overall`, `vw_median_by_month`) |

## Pages

| Page | Title (the finding) |
|---|---|
| 1. When they ride | Members ride at commute-like times; casual riders lean towards weekends |
| 2. How seasonal | Casual riding is far more seasonal than member riding |
| 3. How long and what bike | Casual rides run longer; electric bikes do not separate the groups |
| 4. What this means | Start with commute-like casual riders and campaign from April to June |

## Data model

- Import mode: the data is loaded into the `.pbix` file. Refreshing needs the local PostgreSQL database `cyclistic` to be running and loaded (see the main README).
- Four views feed the model: `vw_fact_rides` (6,115,947 rows, one per ride), `vw_dim_month`, `vw_median_by_month` and `vw_median_overall`.
- Shape: `fact_rides` links to `dim_month` on `month_start` (one month to many rides, filtering in one direction). `median_by_month` also links to `dim_month`. `median_overall` stands alone.
- The model has no station, hour or bike-type dimension tables. Hour, weekday, bike type and duration bucket are columns on the ride-level fact table, which was enough for these four pages.

## Why the medians are pre-computed (no slicers)

A median calculated in DAX over 6.1 million rows ran out of resources. The medians are therefore calculated in PostgreSQL (`PERCENTILE_CONT`) and loaded as small tables. They are fixed values: they do not change when a slicer is used. Rather than ship slicers that only half work, the report has none. A month slicer would work with `median_by_month`, which is already one row per month and group.

## Measures

Measure names as they appear in the model; percentage measures return fractions (0.285 displays as 28.5%).

- Counts: Rides, Casual Rides, Member Rides.
- Shares: Weekend Share, Electric Share, Commute-Like Share, Casual Share (casual rides as a share of all rides), Share of Group Rides (a group's rides in a slice as a share of that group's rides).
- Label helpers: Casual Rides Label, Member Rides Label.
- In `median_overall`: Casual Median Minutes, Member Median Minutes, Median Ratio (casual median divided by member median).

## Definitions used in the report

- Weekend = Saturday and Sunday. Summer = June to August.
- Commute-like = weekday ride starting 06:00-09:59 or 16:00-19:59 and lasting under 30 minutes. This describes timing and length, not trip purpose.
- Duration buckets: under 15, 15-29, 30-59, 60+ minutes.
- Electric = `electric_bike`; the only other type is `classic_bike`.
- Month = the dataset's file month.

## Check values for dashboard measures

| Measure | Member | Casual |
|---|---|---|
| Total rides | 3,955,594 | 2,160,353 |
| Median ride (min) | 8.55 | 10.86 |
| Weekend share | 23.3% | 37.3% |
| Electric share | 68.1% | 73.6% |
| Summer share | 37.6% | 46.9% |
| Commute-like rides | 1,737,372 | 602,209 |

If a measure does not match, the model or DAX is wrong, not the data. The full list of dashboard figures and how they are calculated is in `docs/findings.md`, Appendix A.

## Design

- Casual = orange `#eb6834`, member = blue `#2a78d6`, in the Python charts and the dashboard.
- Dark theme: page background `#1C2638`, cards and charts `#0F1829`, white labels, canvas 1920 x 1080.
- Every chart title states its finding. Page 4 cards and text are typed from the SQL results and do not update when the data refreshes.

## Not included

- No slicers (see above) and no station page. 21% of rides have no start station, so station findings stay in `docs/findings.md` and the Python charts.
