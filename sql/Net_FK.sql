SET TRIMSPOOL ON
SET SERVEROUTPUT ON
SPOOL ..\lst\Net_FK

PROMPT View links_v based on fk_link
DROP VIEW links_v
/
CREATE VIEW links_v (
                link_id,
                node_id_fr,
                node_id_to
) AS
SELECT constraint_name,
       table_fr,
       table_to
  FROM fk_link
/
COLUMN "Network"        FORMAT A42
COLUMN "Link"           FORMAT A42
@..\sql\R_Net

SET TIMING OFF
SPOOL OFF