\connect ipeds;

DROP TABLE IF EXISTS dapip_data;

CREATE TABLE dapip_data (
  DapipId TEXT,
  OpeId TEXT,
  IpedsUnitIds TEXT,
  LocationName TEXT,
  ParentName TEXT,
  ParentDapipId TEXT,
  LocationType TEXT,
  Address TEXT,
  GeneralPhone TEXT,
  AdminName TEXT,
  AdminPhone TEXT,
  AdminEmail TEXT,
  Fax TEXT,
  UpdateDate TEXT
);

COPY dapip_data(DapipId,OpeId,IpedsUnitIds,LocationName,ParentName,ParentDapipId,LocationType,Address,GeneralPhone,AdminName,AdminPhone,AdminEmail,Fax,UpdateDate)
FROM '/Users/ericlewis/Desktop/ipeds-completions-to-postgres/InstitutionCampus.csv' DELIMITER ',' CSV HEADER;
