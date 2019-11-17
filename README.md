# Importing an IPEDS Completions data file to Postgres

This repository is a reference guide for how to import an IPEDS Completions data
file into a Postgres database table.

## Download IPEDS Completions data file CSV

Data for each year of the Completions survey is available on [this IPEDS page](https://nces.ed.gov/ipeds/use-the-data) under the Survey Data section. In Select download option, I chose the “Complete data files” option, which will deliver you CSV files. In the list of data files, you’ll see the data into separate files for each year. I downloaded the “Awards/degrees conferred by program (6-digit CIP code), award level, race/ethnicity, and gender” data file.

The `c2018_a.csv` file in this repository is a copy of one of these files for demonstration purposes.

I downloaded the Dictionary file for the survey as well, which I placed in this repo under `c2018_a.xlsx`. It describes what the abbreviated column headers in the CSV mean (`CHISPT` = “Hispanic or Latino total”), as well as describing the data type for each column.

From this, I was able to write the `import.sql` script, which creates an `ipeds` database, a `completions` table, and imports the data from the CSV file into the table.

NOTE: If you plan to run this on your own computer, open up `import.sql` and edit the path on line 73 to match the path where you checked out the repository. Unfortunately Postgres doesn't support relative paths ¯\_(ツ)_/¯

Then run:

```bash
psql -f import.sql
```

After that, you should be able to connect to the database and query away! For example, let's look at Computer Science & Information Technology degrees awarded at New York University, and how those break down over sexes:

```bash
$ psql -f example.sql
You are now connected to database "ipeds" as user "ericlewis".
 cipcode | all_graduates | male_graduates | female_graduates | percent_male | percent_female
---------+---------------+----------------+------------------+--------------+----------------
 11.9999 |             4 |              2 |                2 |         0.50 |           0.50
 11.0101 |           295 |            212 |               83 |         0.71 |           0.28
 11.0103 |            54 |             32 |               22 |         0.59 |           0.40
 11.0199 |             5 |              4 |                1 |         0.80 |           0.20
 11.0803 |             0 |              0 |                0 |            0 |              0
 11.0899 |            16 |             12 |                4 |         0.75 |           0.25
 11.0901 |             0 |              0 |                0 |            0 |              0
(7 rows)
```