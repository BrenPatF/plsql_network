SET TRIMSPOOL ON
SET SERVEROUTPUT ON
SPOOL ..\lst\Net_Brightkite

PROMPT links_v based on Net_Brightkite
DROP VIEW links_v
/
CREATE VIEW links_v (
	link_id,
	node_id_fr,
	node_id_to
)
AS
SELECT  link_id,
	node_id_fr,
	node_id_to
  FROM Net_Brightkite
/
COLUMN "Network"        FORMAT A10
COLUMN "Link"           FORMAT A10

@..\sql\R_Net

SET TIMING OFF
SPOOL OFF