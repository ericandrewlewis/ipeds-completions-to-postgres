\connect ipeds;

SELECT
  CIPCODE as cipcode,
  CTOTALT as all_graduates,
  CTOTALM as male_graduates,
  CTOTALW as female_graduates,
  CASE WHEN CTOTALT = 0 THEN 0
  ELSE TRUNC(
    CAST(CTOTALM AS NUMERIC) / CTOTALT,
    2)
  END as percent_male,
  CASE WHEN CTOTALT = 0 THEN 0
  ELSE TRUNC(
    CAST(CTOTALW AS NUMERIC) / CTOTALT,
    2)
  END as percent_female
FROM completions
WHERE
  -- NYU
  UNITID=193900 AND
  -- Bachelors Degrees
  AWLEVEL=5 AND
  -- Look at any Computer Science/Information Science-ish degree
  CIPCODE LIKE '11.%' AND
  -- Only look at students whose primary major is CS
  majornum = 1;