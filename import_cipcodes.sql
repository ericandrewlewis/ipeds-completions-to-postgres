\connect ipeds;

DROP TABLE IF EXISTS cip_codes;

CREATE TABLE cip_codes (
  CIPFamily TEXT,
  CIPCode TEXT,
  Action TEXT,
  TextChange TEXT,
  CIPTitle TEXT,
  CIPDefinition TEXT,
  CrossReferences TEXT,
  Examples TEXT
);

COPY cip_codes(CIPFamily,CIPCode,Action,TextChange,CIPTitle,CIPDefinition,CrossReferences,Examples)
FROM '/Users/ericlewis/Desktop/ipeds-completions-to-postgres/CIPCode2010.csv' DELIMITER ',' CSV HEADER;