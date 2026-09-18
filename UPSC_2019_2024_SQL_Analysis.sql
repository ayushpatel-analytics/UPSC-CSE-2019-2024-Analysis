-- =====================================================
-- UPSC CIVIL SERVICES EXAMINATION ANALYSIS
-- 2019–2024
-- =====================================================
-- Purpose:
-- SQL-based analysis of UPSC Civil Services Examination
-- data covering the years 2019–2024.
--
-- Tools:
-- Google BigQuery | SQL
--
-- Author: Ayush Patel
-- =====================================================


CREATE OR REPLACE TABLE `upsc_analysis.upsc_exam_data` (
  year INT64,
  applied INT64,
  appeared INT64,
  mains_qualified INT64,
  interview INT64,
  recommended INT64,
  vacancies INT64
);


-- =====================================================
-- 2. INSERT UPSC EXAMINATION DATA (2019–2024)
-- =====================================================

INSERT INTO `upsc_analysis.upsc_exam_data`
(year, applied, appeared, mains_qualified, interview, recommended, vacancies)
VALUES
  (2019, 1135261, 576712, 11845, 2034, 829, 927),
  (2020, 1040060, 482770, 10564, 2053, 761, 836),
  (2021, 1093984, 508619, 9214, 1824, 685, 749),
  (2022, 1135697, 573735, 13090, 2529, 933, 1022),
  (2023, 1016850, 592141, 14624, 2855, 1016, 1143),
  (2024, 992599, 583213, 14627, 2845, 1009, 1129);


-- =====================================================
-- 3. DATA VERIFICATION
-- Preview and verify the loaded UPSC examination data
-- =====================================================
-- Preview the loaded UPSC examination data
-- =====================================================

SELECT *
FROM `upsc_analysis.upsc_exam_data`
LIMIT 10;

-- Preview the loaded data
SELECT *
FROM `upsc_analysis.upsc_exam_data`
LIMIT 10;

-- Verify all records in chronological order
SELECT *
FROM `upsc_analysis.upsc_exam_data`
ORDER BY year;


-- =====================================================
-- 4. DATA QUALITY / VALIDATION
-- Checks row coverage, missing values, and logical
-- consistency across examination stages.
-- =====================================================

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT year) AS unique_years,
  MIN(year) AS earliest_year,
  MAX(year) AS latest_year,

  COUNTIF(applied IS NULL) AS missing_applied,
  COUNTIF(appeared IS NULL) AS missing_appeared,
  COUNTIF(mains_qualified IS NULL) AS missing_mains_qualified,
  COUNTIF(interview IS NULL) AS missing_interview,
  COUNTIF(recommended IS NULL) AS missing_recommended,
  COUNTIF(vacancies IS NULL) AS missing_vacancies,

  COUNTIF(applied < appeared) AS invalid_applied_appeared,
  COUNTIF(appeared < mains_qualified) AS invalid_appeared_mains,
  COUNTIF(mains_qualified < interview) AS invalid_mains_interview,
  COUNTIF(interview < recommended) AS invalid_interview_recommended

FROM `upsc_analysis.upsc_final_analysis`;


-- =====================================================
-- 5. ANALYSIS
-- =====================================================

-- 5.1 Examination Funnel & Conversion Rates
-- Calculates stage-wise conversion rates from application
-- through recommendation.

SELECT
  year,
  applied,
  appeared,
  mains_qualified,
  interview,
  recommended,
  vacancies,

  ROUND((appeared / applied) * 100, 2) AS prelims_appearance_rate,

  ROUND((mains_qualified / appeared) * 100, 2) AS mains_qualification_rate,

  ROUND((interview / mains_qualified) * 100, 2) AS interview_rate,

  ROUND((recommended / interview) * 100, 2) AS recommendation_rate,

  ROUND((recommended / applied) * 100, 4) AS overall_selection_rate

FROM `upsc_analysis.upsc_exam_data`

ORDER BY year;

-- =====================================================
-- 5.2 EXAMINATION FUNNEL ANALYSIS
-- Stage-to-stage conversion rates across the
-- UPSC examination process.
-- =====================================================

SELECT
  year,
  applied,
  appeared,
  mains_qualified,
  interview,
  recommended,

  ROUND((mains_qualified / appeared) * 100, 2) AS prelims_to_mains_rate,

  ROUND((interview / mains_qualified) * 100, 2) AS mains_to_interview_rate,

  ROUND((recommended / interview) * 100, 2) AS interview_to_recommendation_rate

FROM `upsc_analysis.upsc_exam_metrics`

ORDER BY year;
-- =====================================================
-- 5.3 YEAR-OVER-YEAR TREND ANALYSIS
-- Calculates annual changes and percentage changes
-- in applications, appearances, recommendations,
-- and vacancies.
-- =====================================================

SELECT
  year,
  applied,
  appeared,
  recommended,
  vacancies,

  applied - LAG(applied) OVER (ORDER BY year) AS change_in_applied,

  ROUND(
    ((applied - LAG(applied) OVER (ORDER BY year))
    / LAG(applied) OVER (ORDER BY year)) * 100, 2
  ) AS applied_yoy_pct,

  appeared - LAG(appeared) OVER (ORDER BY year) AS change_in_appeared,

  ROUND(
    ((appeared - LAG(appeared) OVER (ORDER BY year))
    / LAG(appeared) OVER (ORDER BY year)) * 100, 2
  ) AS appeared_yoy_pct,

  recommended - LAG(recommended) OVER (ORDER BY year) AS change_in_recommended,

  ROUND(
    ((recommended - LAG(recommended) OVER (ORDER BY year))
    / LAG(recommended) OVER (ORDER BY year)) * 100, 2
  ) AS recommended_yoy_pct,

  vacancies - LAG(vacancies) OVER (ORDER BY year) AS change_in_vacancies,

  ROUND(
    ((vacancies - LAG(vacancies) OVER (ORDER BY year))
    / LAG(vacancies) OVER (ORDER BY year)) * 100, 2
  ) AS vacancies_yoy_pct

FROM `upsc_analysis.upsc_exam_data`

ORDER BY year;
-- =====================================================
-- 5.4 2019–2024 PERIOD COMPARISON
-- Compares key examination metrics between the
-- first and last years of the analysis period.
-- =====================================================

WITH first_last AS (
  SELECT
    year,
    applied,
    appeared,
    mains_qualified,
    interview,
    recommended,
    vacancies
  FROM `upsc_analysis.upsc_exam_data`
  WHERE year IN (2019, 2024)
)

SELECT
  2019 AS start_year,
  2024 AS end_year,

  MAX(IF(year = 2019, applied, NULL)) AS applied_2019,
  MAX(IF(year = 2024, applied, NULL)) AS applied_2024,
  ROUND(
    ((MAX(IF(year = 2024, applied, NULL)) -
      MAX(IF(year = 2019, applied, NULL)))
      / MAX(IF(year = 2019, applied, NULL))) * 100, 2
  ) AS applied_change_pct,

  MAX(IF(year = 2019, appeared, NULL)) AS appeared_2019,
  MAX(IF(year = 2024, appeared, NULL)) AS appeared_2024,
  ROUND(
    ((MAX(IF(year = 2024, appeared, NULL)) -
      MAX(IF(year = 2019, appeared, NULL)))
      / MAX(IF(year = 2019, appeared, NULL))) * 100, 2
  ) AS appeared_change_pct,

  MAX(IF(year = 2019, recommended, NULL)) AS recommended_2019,
  MAX(IF(year = 2024, recommended, NULL)) AS recommended_2024,
  ROUND(
    ((MAX(IF(year = 2024, recommended, NULL)) -
      MAX(IF(year = 2019, recommended, NULL)))
      / MAX(IF(year = 2019, recommended, NULL))) * 100, 2
  ) AS recommended_change_pct,

  MAX(IF(year = 2019, vacancies, NULL)) AS vacancies_2019,
  MAX(IF(year = 2024, vacancies, NULL)) AS vacancies_2024,
  ROUND(
    ((MAX(IF(year = 2024, vacancies, NULL)) -
      MAX(IF(year = 2019, vacancies, NULL)))
      / MAX(IF(year = 2019, vacancies, NULL))) * 100, 2
  ) AS vacancies_change_pct

FROM first_last;
-- =====================================================
-- 5.5 YEAR-OVER-YEAR SELECTION RATE CHANGE
-- Measures the annual change in overall selection rate
-- in percentage points.
-- =====================================================

SELECT
  year,
  applied,
  recommended,
  overall_selection_rate,

  ROUND(
    overall_selection_rate -
    LAG(overall_selection_rate) OVER (ORDER BY year),
    4
  ) AS change_from_previous_year_pp

FROM `upsc_analysis.upsc_exam_metrics`

ORDER BY year;
5.6 SELECTION RATE SUMMARY STATISTICS
SELECT 
  ROUND(MAX(overall_selection_rate), 4) AS highest_selection_rate_pct, 
  ROUND(MIN(overall_selection_rate), 4) AS lowest_selection_rate_pct, 
  ROUND(AVG(overall_selection_rate), 4) AS average_selection_rate_pct 
FROM `upsc_analysis.upsc_exam_metrics`;
-- =====================================================
-- 5.7 VACANCY UTILIZATION ANALYSIS
-- Compares recommended candidates with available
-- vacancies and calculates the recommendation gap.
-- =====================================================

SELECT
  year,
  recommended,
  vacancies,
  vacancy_utilization_rate,

  recommended - vacancies AS recommendation_vs_vacancy_gap

FROM `upsc_analysis.upsc_exam_metrics`

ORDER BY year;
-- =====================================================
-- 5.8 CREATE FINAL ANALYSIS VIEW
-- Combines examination funnel metrics with year-over-year
-- changes into a single analytical view for Power BI
-- and downstream analysis.
-- =====================================================

CREATE OR REPLACE VIEW `upsc_analysis.upsc_final_analysis` AS

WITH metrics AS (
  SELECT
    year,
    applied,
    appeared,
    mains_qualified,
    interview,
    recommended,
    vacancies,

    ROUND((appeared / applied) * 100, 2)
      AS prelims_appearance_rate,

    ROUND((mains_qualified / appeared) * 100, 2)
      AS mains_qualification_rate,

    ROUND((interview / mains_qualified) * 100, 2)
      AS interview_rate,

    ROUND((recommended / interview) * 100, 2)
      AS recommendation_rate,

    ROUND((recommended / applied) * 100, 4)
      AS overall_selection_rate,

    ROUND((recommended / vacancies) * 100, 2)
      AS vacancy_utilization_rate

  FROM `upsc_analysis.upsc_exam_data`
)

SELECT
  *,

  applied - LAG(applied) OVER (ORDER BY year)
    AS applied_yoy_change,

  ROUND(
    ((applied - LAG(applied) OVER (ORDER BY year))
    / LAG(applied) OVER (ORDER BY year)) * 100, 2
  ) AS applied_yoy_pct,

  appeared - LAG(appeared) OVER (ORDER BY year)
    AS appeared_yoy_change,

  ROUND(
    ((appeared - LAG(appeared) OVER (ORDER BY year))
    / LAG(appeared) OVER (ORDER BY year)) * 100, 2
  ) AS appeared_yoy_pct,

  recommended - LAG(recommended) OVER (ORDER BY year)
    AS recommended_yoy_change,

  ROUND(
    ((recommended - LAG(recommended) OVER (ORDER BY year))
    / LAG(recommended) OVER (ORDER BY year)) * 100, 2
  ) AS recommended_yoy_pct,

  vacancies - LAG(vacancies) OVER (ORDER BY year)
    AS vacancies_yoy_change,

  ROUND(
    ((vacancies - LAG(vacancies) OVER (ORDER BY year))
    / LAG(vacancies) OVER (ORDER BY year)) * 100, 2
  ) AS vacancies_yoy_pct

FROM metrics;


-- =====================================================
-- 6. FINAL ANALYSIS VERIFICATION
-- Verifies the final analytical view used for
-- downstream analysis and Power BI.
-- =====================================================

SELECT *
FROM `upsc_analysis.upsc_final_analysis`
ORDER BY year;