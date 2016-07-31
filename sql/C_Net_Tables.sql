SET TRIMSPOOL ON
SPOOL ..\lst\C_Net_Tables
PROMPT Foreign key table setup...
DROP TABLE fk_link
/
CREATE TABLE fk_link (
                constraint_name,
                table_fr,
                table_to
) AS
SELECT Lower(con_f.constraint_name || '|' || con_f.owner),
       con_f.table_name || '|' || con_f.owner,
       con_t.table_name || '|' || con_t.owner
  FROM all_constraints                  con_f
  JOIN all_constraints                  con_t
    ON con_t.constraint_name            = con_f.r_constraint_name
   AND con_t.owner                      = con_f.r_owner
 WHERE con_f.constraint_type            = 'R'
   AND con_t.constraint_type            = 'P'
   AND con_f.table_name NOT LIKE '%|%'
   AND con_t.table_name NOT LIKE '%|%'
/
SELECT COUNT(*)
  FROM fk_link
/
PROMPT Non-unique indexes on table_fr and table_to
CREATE INDEX fk_link_N1 ON fk_link (table_fr)
/
CREATE INDEX fk_link_N2 ON fk_link (table_to)
/
PROMPT Gather stats on NETWORK.FK_LINK
BEGIN

DBMS_Stats.Gather_Table_Stats (
                ownname                 => 'NETWORK',
                tabname                 => 'FK_LINK');
END;
/
PROMPT Brightkite table setup...
DROP TABLE Net_brightkite
/
CREATE TABLE Net_brightkite (
	link_id         VARCHAR2(10),
	node_id_fr      VARCHAR2(10),
	node_id_to      VARCHAR2(10)
)
/
PROMPT Count dijkstra.arcs_brightkite, the source table that has links in both directions
SELECT COUNT(*)
  FROM dijkstra.arcs_brightkite
/
PROMPT Insert into Net_brightkite using rownum as link id, and only inserting the links in 1 direction
INSERT INTO Net_brightkite
SELECT ROWNUM, l.src, l.dst
  FROM dijkstra.arcs_brightkite l
  LEFT JOIN dijkstra.arcs_brightkite r
    ON r.src = l.dst
   AND r.dst = l.src
 WHERE l.dst > l.src
/
PROMPT PK on link_id
ALTER TABLE Net_brightkite ADD (CONSTRAINT Net_brightkite_pk PRIMARY KEY (link_id))
/
PROMPT Unique index on node_id_fr, node_id_to
CREATE UNIQUE INDEX Net_brightkite_u1 ON Net_brightkite (node_id_fr, node_id_to)
/
PROMPT Non-unique index on node_id_to
CREATE INDEX Net_brightkite_N1 ON Net_brightkite (node_id_to)
/
PROMPT Gather stats on NETWORK.NET_BRIGHTKITE
BEGIN
  DBMS_Stats.Gather_Table_Stats (
              ownname                 => 'NETWORK',
              tabname                 => 'NET_BRIGHTKITE');
END;
/
SPOOL  OFF