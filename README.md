# Importing an IPEDS Completions data file to Postgres

This repository is a reference guide for how to import an IPEDS Completions data
file into a Postgres database table.

## Download IPEDS Completions data file CSV

Data for each year of the Completions survey is available on [this IPEDS page](https://nces.ed.gov/ipeds/use-the-data) under the Survey Data section. In Select download option, I chose the “Complete data files” option, which will deliver you CSV files. In the list of data files, you’ll see the data into separate files for each year. I downloaded the “Awards/degrees conferred by program (6-digit CIP code), award level, race/ethnicity, and gender” data file.

The [`c2018_a.csv`](./c2018_a.csv) file in this repository is a copy of one of these files for demonstration purposes.

I downloaded the Dictionary file for the survey as well, which I placed in this repo under [`c2018_a.xlsx`](c2018_a.xlsx). It describes what the abbreviated column headers in the CSV mean (`CHISPT` = “Hispanic or Latino total”), as well as describing the data type for each column.

## Create a database

To create the database `ipeds` which will hold the various tables, run

```bash
psql -f create_db.sql
```

## Create the `completions` table and import CSV data

From this, I was able to write the [`import_completions.sql`](./import_completions.sql) script, which creates an `ipeds` database, a `completions` table, and imports the data from the CSV file into the table.

_**NOTE**: If you plan to run this on your own computer, open up [`import_completions.sql`](./import.sql) and edit the path on line 73 to match the path where you checked out the repository. Unfortunately Postgres doesn't support relative paths ¯\\\_(ツ)\_/¯_

To import, run:

```bash
psql -f import_completions.sql
```

## Query the database

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

## Related tables

I've also included the import code I wrote for related tables:

### Importing UNITID data

UNITIDs are integers that represent an educational institution. When working with this data, I wanted metadata on the institution, like its actual name and physical location. Thankfully, I found the DOE publishes a [Database of Accredited Postsecondary Institutions and Programs](https://ope.ed.gov/dapip/#/download-data-files) (DAPIP), which you can download in CSV format.

The file [`InstitutionCampus.csv`](./InstitutionCampus.csv) contains the relevant information.

_**NOTE**: If you plan to run this on your own computer, open up [`import_dapip_data.sql`](./import_dapip_data.sql) and edit the path on line 73 to match the path where you checked out the repository. Unfortunately Postgres doesn't support relative paths ¯\\\_(ツ)\_/¯_

To import, run:

```bash
psql -f import_dapip_data.sql
```

You can join the Completions and DAPIP tables, although unfortunately a cast is required because of the uneven types:

```sql
SELECT cipcode, locationname, address FROM completions JOIN dapip_data on CAST(completions.unitid AS TEXT) = dapip_data.ipedsunitids LIMIT 1;
```

```
 cipcode |       locationname       |                address
---------+--------------------------+----------------------------------------
 01.0999 | Alabama A & M University | 4900 Meridian Street, Normal, AL 35762
(1 row)
```

### Importing CIP Codes

A CIP Code identifies a type of program an educational institution offers. For example, the CIP code `11.0101` which represents "Computer and Information Sciences, General." A [list of all CIP Codes based on the 2010 definition is available](https://nces.ed.gov/ipeds/cipcode/resources.aspx?y=56) in CSV format.

The CSV format avalable on the site is Excel-formatted, which is a format that doesn’t work with Postgres’ COPY command. To correct, I imported the CSV into Google Sheets and exported it as a CSV, which is how I left the file in this repository in [`CIPCode2010.csv`](./CIPCode2010.csv).

_**NOTE**: If you plan to run this on your own computer, open up [`import_cipcodes.sql`](./import_cipcodes.sql) and edit the path on line 73 to match the path where you checked out the repository. Unfortunately Postgres doesn't support relative paths ¯\\\_(ツ)\_/¯_

To import, run:

```bash
psql -f import_cipcodes.sql
```

You can join the CIP Codes table and the Completions table to get the proper name a CIP Code represents.

For example, we see total number of Bachelor's degrees granted at NYU for the CIP Code `11.0101` from the completions table and get the proper title for the CIP code.

```sql
SELECT
  CTOTALT as all_graduates,
  ciptitle
FROM completions
JOIN cip_codes ON completions.cipcode = cip_codes.cipcode
WHERE UNITID=193900 AND AWLEVEL=5 AND completions.CIPCODE = '11.0101' AND majornum = 1;
```

```
 all_graduates |                  ciptitle
---------------+---------------------------------------------
           295 | Computer and Information Sciences, General.
```