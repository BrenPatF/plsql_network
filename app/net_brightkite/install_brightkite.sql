@..\..\initspool install_brightkite
/***************************************************************************************************
Name: install_brightkite.sql            Author: Brendan Furey                      Date: 24-Aug-2019

Installation script for the Brightkite network example in the plsql_network module.

The module contains a PL/SQL package for the efficient analysis of networks that can be specified
by a view representing their node pair links. The package has a pipelined function that returns a
record for each link in all connected subnetworks, with the root node id used to identify the
subnetwork that a link belongs to. Examples are included showing how to call the function from SQL
to list a network in detail, or at any desired level of aggregation.

    GitHub: https://github.com/BrenPatF/plsql_network  (31 July 2016)
    Blog:   http://aprogrammerwrites.eu/?p=1426 (10 May 2015)

There are install scripts for the base install, and optional scripts for the examples, and for 
unit testing.

INSTALL SCRIPTS
====================================================================================================
|  Script                     |  Notes                                                             |
|==================================================================================================|
|  BASE                                                                                            |
|--------------------------------------------------------------------------------------------------|
|  install_net_pipe.sql       |  Creates Net_Pipe package, in lib schema, with grants to app       |
|-----------------------------|--------------------------------------------------------------------|
|  grant_net_pipe_to_app.sql  |  Grants privileges on Net_Pipe components from lib to app schema   |
|-----------------------------|--------------------------------------------------------------------|
|  c_net_pipe_syns.sql        |  Creates synonyms for Net_Pipe components in app schema to lib     |
|                             |  schema                                                            |
|--------------------------------------------------------------------------------------------------|
|  EXAMPLES                                                                                        |
|--------------------------------------------------------------------------------------------------|
|  install_fk.sql             |  Installs foreign key example network in app. This copies          |
|                             |  information from the Oracle view all_constraints into table       |
|                             |  fk_link to represent foreign key links as a network. The links    |
|                             |  visible in the Oracle view depend on the tables readable by app   |
|-----------------------------|--------------------------------------------------------------------|
| *install_brightkite.sql*    |  Installs example "Friendship network of Brightkite users" in app  |
|                             |  schema, large example having 58,228 nodes and 214,078 links from: |
|                             |  https://snap.stanford.edu/data/loc-brightkite.html                |
|--------------------------------------------------------------------------------------------------|
|  UNIT TEST                                                                                       |
|--------------------------------------------------------------------------------------------------|
|  install_net_pipe_tt.sql    |  Creates unit test components that require a minimum Oracle        |
|                             |  database version of 12.2 in lib schema                            |
====================================================================================================
This file has the install script for the Brightkite network example in the app schema.

Components created:

    Tables               Description
    ===================  ===========================================================================
    arcs_brightkite      Table used for Brightkite network data in original format
    arcs_brightkite_ext  External table used to load Brightkite network from Brightkite_edges.csv
    net_brightkite       Table used for Brightkite network data in desired format, with link ids

    Statistics           Description
    ===================  ===========================================================================
    net_brightkite       Statistics vias DBMS_Stats.Gather_Table_Stats (default settings)

***************************************************************************************************/
PROMPT Brightkite table setup...
DROP TABLE arcs_brightkite
/
CREATE TABLE arcs_brightkite (
        src              NUMBER NOT NULL,
        dst              NUMBER NOT NULL,
        CONSTRAINT arcs_brightkite_pk PRIMARY KEY (src, dst)
)
/
DROP TABLE arcs_brightkite_ext
/
CREATE TABLE arcs_brightkite_ext (
        src              NUMBER,
        dst              NUMBER
)
ORGANIZATION EXTERNAL (
  TYPE          oracle_loader
  DEFAULT DIRECTORY input_dir
  ACCESS PARAMETERS
  (
    FIELDS TERMINATED BY ','
    MISSING FIELD VALUES ARE NULL
  )
  LOCATION ('Brightkite_edges.csv')
)
/
INSERT INTO arcs_brightkite SELECT * FROM arcs_brightkite_ext
/
DROP TABLE net_brightkite
/
CREATE TABLE net_brightkite(
	link_id         VARCHAR2(10),
	node_id_fr      VARCHAR2(10),
	node_id_to      VARCHAR2(10)
)
/
PROMPT Count arcs_brightkite, the source table that has links in both directions
SELECT COUNT(*)
  FROM arcs_brightkite
/
PROMPT Insert into net_brightkite using rownum as link id, and only inserting the links in 1 direction
INSERT INTO net_brightkite
SELECT ROWNUM, l.src, l.dst
  FROM arcs_brightkite l
  LEFT JOIN arcs_brightkite r
    ON r.src = l.dst
   AND r.dst = l.src
 WHERE l.dst > l.src
/
PROMPT PK on link_id
ALTER TABLE net_brightkite ADD (CONSTRAINT net_brightkite_pk PRIMARY KEY (link_id))
/
PROMPT Unique index on node_id_fr, node_id_to
CREATE UNIQUE INDEX net_brightkite_u1 ON net_brightkite(node_id_fr, node_id_to)
/
PROMPT Non-unique index on node_id_to
CREATE INDEX net_brightkite_N1 ON net_brightkite(node_id_to)
/
PROMPT Gather stats on net_brightkite
BEGIN
  DBMS_Stats.Gather_Table_Stats(
              ownname                 => USER,
              tabname                 => 'NET_BRIGHTKITE');
END;
/
@..\..\endspool
