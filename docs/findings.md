# Cyclistic Bike-Share: How Members and Casual Riders Differ

**Prepared for:** Director of Marketing, Marketing Analytics Team, Executive Team
**Author:** Ali Akbar
**Data:** 6,115,947 rides, September 2025 - August 2026
**Status:** Analysis and Power BI dashboard complete (`powerbi/Cyclistic_Dashboard.pdf`).

---

## 1. Executive summary

Cyclistic wants more annual members. This analysis compares how members and casual riders use the service, to find where casual riders look most like members and when they are most reachable.

**The short answer:** casual riders are a seasonal, weekend-leaning group; members ride all year, mostly on weekdays with morning and late-afternoon peaks. The two groups are not opposites, though. More than a quarter of casual rides already look like member rides, and in this year of data casual riding rose sharply from April to May.

| | Member | Casual |
|---|---|---|
| Share of rides | 64.7% | 35.3% |
| Median ride | 8.6 min | 10.9 min |
| Weekend share of rides | 23% | 37% |
| Summer (Jun-Aug) share of rides | 38% | 47% |
| Commute-like weekday rides* | 44% | 28% |
| Rides starting 06:00-09:59 | 20% | 11% |

*Weekday ride starting 06:00-09:59 or 16:00-19:59, under 30 minutes. This describes timing and length, not trip purpose.

**Four things to act on**

1. **Target casual riders who already ride like members.** About 602,000 casual rides (28% of casual rides) are weekday, commute-window, short rides. This is the closest behavioural match to members in the data.
2. **Time campaigns to April-June.** Casual rides nearly double from April (131,500) to May (245,100), and casual share of all rides climbs from 29% to 37%. Casual riding peaks in July at 358,000 rides, against 25,000 in January. This is one year of data.
3. **Reach riders in the app and by email; use stations as support.** The 15 busiest casual stations hold only about 12% of all casual rides.
4. **Test before scaling, using rider-level data Cyclistic already has.** This public trip data has no rider IDs or prices, so it shows *who rides when* but cannot show *who would switch*. A pricing break-even and a split test are the next step.

---

## 2. Business task and questions

**Task:** analyse the differences between casual riders and annual members to identify opportunities to convert casual riders into members.

1. How do annual members and casual riders use Cyclistic bikes differently?
2. Why would casual riders buy annual memberships?
3. How can Cyclistic use digital media to influence casual riders to become members?

## 3. Data and method

- **Source:** 12 monthly Divvy trip files, 6,115,982 raw records, 13 columns.
- **Cleaning:** 35 exact cross-file duplicate rides removed; 29 negative durations at the 2 Nov 2025 daylight-saving change flagged and corrected by +60 minutes; rides with missing station or end-coordinate data kept (excluded only from station-specific analysis). Result: 6,115,947 rides. Full rules in `docs/project_management/07_Process_Cleaning_Plan.md`.
- **Tools:** Python (cleaning, validation, analysis, charts), PostgreSQL-syntax SQL (analysis), Excel (summary tables), Power BI (four-page dashboard).
- **Verification:** the same headline metrics were computed independently in SQL and in pandas and agree exactly (checked by `tests/test_reconcile_sql.py`, which queries PostgreSQL and compares it with pandas). The dashboard figures in Appendix A were checked against PostgreSQL output.
- **Month definition:** the dataset's file month (`LEFT(source_file, 6)`), so rides that cross a month boundary stay with their source file.
- **Definitions:** weekend = Saturday and Sunday. Summer = June to August. Commute-like = weekday, start hour 06:00-09:59 or 16:00-19:59, under 30 minutes. Duration buckets: under 15, 15-29, 30-59 and 60+ minutes. "Electric" = `electric_bike` (the only other bike type is `classic_bike`).

## 4. Findings

The dashboard shows these findings on four pages: page 1 timing, page 2 seasonality, page 3 ride length and bike type, page 4 recommendations and limits. Station findings are in this document and the Python charts only; the dashboard has no station page.

### Q1. How do members and casual riders use bikes differently?

**Timing**

- Both groups peak at 17:00 on weekdays. The difference is the morning: 20% of member rides start between 06:00 and 09:59, versus 11% of casual rides.
- On weekends the hourly profiles are almost identical. Casual riders differ in *how much* they ride on weekends (37% of their rides), not *when*. For reference, weekend days are 104 of the 365 days in the period (28.5%).
- Charts: `docs/images/01_hourly_profile.png`, `02_weekday_hour_heatmap.png`; dashboard page 1.

**Seasonality**

- 47% of casual rides fall in June-August, against 38% of member rides. In winter, casual riders are only 4% of casual annual volume (members: 10%).
- Casual share of all rides runs from 18% (January) to 41% (July).
- Casual rides swing 14.5 times between January (24,749) and July (357,756); member rides swing 4.6 times between January (113,038) and August (521,141). Monthly counts are in Appendix A.
- Chart: `03_monthly_rides_and_casual_share.png`; dashboard page 2.

**Ride length**

- Median ride: casual 10.9 min, member 8.6 min (1.27x).
- The mean gap is larger (20.7 vs 12.4 min, 1.67x) because a few very long rides inflate casual averages. After removing rides under 1 minute and over 3 hours the gap is 1.46x. The direction holds under every treatment, but the size depends on how outliers are handled, so medians are the safer figure to quote.
- 13.3% of casual rides last 30 minutes or more (287,935 rides), against 5.4% of member rides (211,767).
- Casual classic-bike rides are the main source of long rides: mean 37-43 min, median 14-18 min.
- Chart: `04_duration_distribution.png`; dashboard page 3.

**Bike type**

- Electric-bike use is similar (74% casual, 68% member). Bike type does not separate the groups. Dashboard page 3.

**Places**

- Casual riders are the majority at lakefront and tourist stations, e.g. Shedd Aquarium (82% casual), Field Museum (81%), Navy Pier (76%, the busiest casual start station with about 51,700 casual rides).
- Casual riders make round trips (same start and end station) more often: 10% of classic-bike rides versus 2% for members.
- Casual riding is **dispersed**: the ten busiest casual stations hold about 10% of all casual rides (9.5%), and the 15 busiest about 12% (11.7%). Among only the casual rides that have a start station, the top 15 hold 15.0%.
- Chart: `05_top_casual_stations.png`

### Q2. Why would casual riders buy annual memberships?

The data cannot answer *why*. There is no price, trip-purpose, or rider-level information. It does show which riders have the strongest behavioural overlap with members, which is where a membership offer is most plausible:

- **Commute-like casual riders (about 602,000 rides, 28% of casual rides).** They ride on weekday commute schedules like members. Hypothesis to test: a per-ride price comparison is most favourable for frequent, regular riders.
- **Short weekend riders on electric bikes (about 504,000 casual rides under 30 minutes).** Their median ride (9.6 min) is close to members' (8.4 min). They are over-represented relative to members in weekend short-ride segments by 3 to 5 percentage points. Hypothesis: a lower-commitment or seasonal offer fits them better than a full annual plan.
- **Long-ride and tourist-pattern casual riders** (long durations, round trips, lakefront and museum stations). They show the weakest overlap with members and are the least likely conversion candidates from this evidence.

These are behavioural segments at the ride level. They are not people, and nothing here estimates a conversion rate.

### Q3. How can Cyclistic use digital media to influence casual riders?

Recommendations follow from the timing and location patterns above:

1. **Run the campaign window April-June.** Casual volume is ramping up (April to May: +86% casual rides versus +29% for members), so the pool of reachable casual riders is growing fastest then.
2. **Use in-app and email messages at the moments casual riders ride:** weekday afternoons (peak 17:00) and weekends, with a savings message for weekday riders.
3. **Treat stations as a supporting channel, not the main one.** Geo-targeted promotion at the top lakefront stations makes sense (they are majority-casual), but even the top 15 stations hold only about 12% of all casual rides. In-app and email reach far more.
4. **Test, don't assume.** Run a split test of a membership offer on casual riders in the commute-like segment against a control group, using Cyclistic's own rider-level data.

## 5. Recommendations

| # | Recommendation | Evidence | Confidence |
|---|---|---|---|
| 1 | Prioritise commute-like casual riders for membership messaging | 28% of casual rides match the member weekday pattern | Medium: ride-level, no purpose data |
| 2 | Launch campaigns in April-June as casual volume ramps | Casual rides +86% April to May; casual share 29% to 37% | High for the pattern, one year of data |
| 3 | Use in-app/email as the primary channel, stations as secondary | Top 15 stations hold about 12% of all casual rides | High |
| 4 | Test before scaling: pull rider-level data for frequency and price break-even, then split-test an offer (including a seasonal or lower-commitment option for weekend and summer riders) | 47% of casual rides in summer, winter nearly absent; price and rider data are not in the public trip data | Medium: needs price testing |

## 6. Limitations

- **Rides are not riders.** No rider IDs, so no frequency per person and no conversion measurement.
- **No prices, revenue or trip purpose.** The brief lists membership revenue and conversion rate as metrics; neither can be computed from this dataset.
- **Station data is incomplete.** 1,285,400 rides (21% of all rides) have no start station. All of them are electric-bike rides (about 30% of electric-bike rides), so station and round-trip findings describe the rides that do have one.
- **One year of data.** Seasonal patterns come from a single 12-month window.
- **Descriptive only.** Patterns show association, not cause. "Commute-like" describes timing and length, not purpose.

## 7. Dashboard and next step

The four-page Power BI dashboard is in `powerbi/` (`.pbix` and PDF; screenshots in `docs/images/dashboard_page1.png` to `dashboard_page4.png`). Design decisions:

- The medians are pre-computed in PostgreSQL because a DAX median over 6.1 million rows ran out of resources. As a result the report has no slicers.
- The dashboard covers timing, season, ride length, bike type and recommendations. It has no station page; stations are covered here and in the Python charts.
- Page 4 cards and text are typed from the SQL results; each number is listed in Appendix A.

**Next step:** use Cyclistic's rider-level data (frequency, price break-even) and a split test, as in recommendation 4. A month slicer fed by pre-aggregated medians would be the next dashboard improvement.

## Appendix: where things are

| What | Where |
|---|---|
| Cleaning and validation scripts | `src/cyclistic/clean.py`, `src/cyclistic/validate.py`, `tests/` |
| Analysis definitions and charts | `src/cyclistic/analysis.py`, `src/cyclistic/plot_charts.py` |
| SQL | `sql/` (analysis scripts 01-04 and the Power BI views) |
| Summary tables | `excel/summary_tables.xlsx` |
| Python charts | `docs/images/01_*.png` to `06_*.png` |
| Power BI dashboard | `powerbi/Cyclistic_Dashboard.pbix`, `powerbi/Cyclistic_Dashboard.pdf` |
| Dashboard screenshots | `docs/images/dashboard_page1.png` to `dashboard_page4.png` |
| Dashboard model notes | `powerbi/README_PowerBI_handoff.md` |

## Appendix A: numbers behind the dashboard

Rides and median ride length per month by file month. The ride counts add up to the totals: 2,160,353 casual and 3,955,594 member rides. The medians come from `vw_median_by_month`.

| Month | Casual | Member | Casual share | Median ride, casual (min) | Median ride, member (min) |
|---|---|---|---|---|---|
| Sep 2025 | 265,461 | 449,298 | 37.1% | 11.50 | 9.13 |
| Oct 2025 | 224,010 | 422,029 | 34.7% | 10.27 | 8.42 |
| Nov 2025 | 99,149 | 257,479 | 27.8% | 8.59 | 7.76 |
| Dec 2025 | 28,080 | 112,454 | 20.0% | 7.45 | 7.30 |
| Jan 2026 | 24,749 | 113,038 | 18.0% | 6.92 | 7.00 |
| Feb 2026 | 41,173 | 160,277 | 20.4% | 8.00 | 7.29 |
| Mar 2026 | 87,856 | 229,181 | 27.7% | 9.55 | 7.69 |
| Apr 2026 | 131,502 | 316,715 | 29.3% | 9.72 | 7.98 |
| May 2026 | 245,105 | 408,599 | 37.5% | 11.37 | 8.68 |
| Jun 2026 | 308,462 | 454,088 | 40.5% | 11.91 | 9.27 |
| Jul 2026 | 357,756 | 511,295 | 41.2% | 11.59 | 9.17 |
| Aug 2026 | 347,050 | 521,141 | 40.0% | 11.39 | 9.16 |

Figures quoted on the dashboard pages and how they are calculated:

| Figure | Value | Calculation |
|---|---|---|
| Casual swing, January to July | 14.5 times | 357,756 / 24,749 |
| Member swing, January to August | 4.6 times | 521,141 / 113,038 |
| Casual rides, April to May | +86.4% | 245,105 / 131,502 - 1 |
| Member rides, April to May | +29.0% | 408,599 / 316,715 - 1 |
| Weekend share | 37.27% casual, 23.34% member | weekend rides / all rides of the group |
| Even-spread line on the weekend chart | 28.5% | 104 weekend days / 365 days |
| Commute-like rides | 602,209 casual (27.88%), 1,737,372 member (43.92%) | commute-like rides / all rides of the group |
| Electric-bike share | 73.60% casual (1,590,057), 68.06% member (2,692,072) | electric rides / all rides of the group |
| Rides of 30 minutes or more | 13.3% casual (287,935), 5.4% member (211,767) | rides of 30+ minutes / all rides of the group |
| Duration split, casual | 64.4% / 22.2% / 9.3% / 4.1% | under 15 / 15-29 / 30-59 / 60+ minutes |
| Duration split, member | 76.3% / 18.3% / 4.7% / 0.7% | under 15 / 15-29 / 30-59 / 60+ minutes |
| Median ride | 10.86 min casual, 8.55 min member (1.27 times) | PostgreSQL `PERCENTILE_CONT(0.5)` |
| Monthly median ride, casual | 6.9 min in January, 11.9 in June (the peak) | `vw_median_by_month`, 6.92 and 11.91 |
| Monthly median ride, member | 7.0 to 9.3 min across the year | `vw_median_by_month`, 7.00 (Jan) to 9.27 (Jun) |
| Top 10 and top 15 casual stations | 9.5% and 11.7% of all casual rides | 205,406 and 253,423 rides / 2,160,353 |
| Top 15 among rides with a start station | 15.0% | 253,423 / 1,687,614 |

The casual duration bars on page 3 add up to 13.4% for 30+ minutes (9.3% + 4.1%) because of rounding; the unrounded figure is 13.33%, shown as 13.3% in the chart title.
