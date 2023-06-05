@..\initspool install_bacon_numbers
/***************************************************************************************************
Name: install_bacon_numbers.sql         Author: Brendan Furey                      Date: 13-Feb-2022

Installation script for the Bacon Numbers network example in the plsql_network module.

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
|  install_brightkite.sql     |  Installs example "Friendship network of Brightkite users" in app  |
|                             |  schema, large example having 58,228 nodes and 214,078 links from: |
|                             |  https://snap.stanford.edu/data/loc-brightkite.html                |
|-----------------------------|--------------------------------------------------------------------|
| *install_bacon_numbers.sql* |  Installs example "Bacon Numbers" in app schema, from a data set   |
|                             |  of 1817 actor/film pairs that results in 161 nodes and 3,396      |
|                             |  links from: http://cs.oberlin.edu/~gr151/imdb/imdb.small.txt      |
|                             |  created by the Oberlin College Computer Science department        |
|--------------------------------------------------------------------------------------------------|
|  UNIT TEST                                                                                       |
|--------------------------------------------------------------------------------------------------|
|  install_net_pipe_tt.sql    |  Creates unit test components that require a minimum Oracle        |
|                             |  database version of 12.2 in lib schema                            |
====================================================================================================
This file has the install script for the Bacon Numbers network example in the app schema.

Components created:

    Tables               Description
    ===================  ===========================================================================
    bacon_numbers_ext    External table used to load Bacon Numbers network from bacon_numbers.txt
    arcs_bacon_numbers   Table used for bacon_numbers network data, with link ids

    Statistics           Description
    ===================  ===========================================================================
    arcs_bacon_numbers   Statistics vias DBMS_Stats.Gather_Table_Stats (default settings)

***************************************************************************************************/
PROMPT bacon_numbers table setup...
DROP TABLE bacon_numbers_ext
/
CREATE TABLE bacon_numbers_ext (
        actor            VARCHAR2(100),
        film             VARCHAR2(100)
)
ORGANIZATION EXTERNAL (
  TYPE          oracle_loader
  DEFAULT DIRECTORY input_dir
  ACCESS PARAMETERS
  (
    FIELDS TERMINATED BY '|'
    MISSING FIELD VALUES ARE NULL
  )
  LOCATION ('bacon_numbers.txt')
)
/
DROP TABLE arcs_bacon_numbers
/
CREATE TABLE arcs_bacon_numbers(
  link_id         VARCHAR2(200),
  node_id_fr      VARCHAR2(100),
  node_id_to      VARCHAR2(100)
)
/
INSERT INTO arcs_bacon_numbers 
SELECT src.film || '-' || Row_Number() OVER (PARTITION BY src.film ORDER BY src.actor, dst.actor),
       src.actor, dst.actor
FROM bacon_numbers_ext src
JOIN bacon_numbers_ext dst
  ON dst.film = src.film AND dst.actor > src.actor
/
PROMPT Count arcs_bacon_numbers
SELECT COUNT(*)
  FROM arcs_bacon_numbers
/
PROMPT PK on link_id
ALTER TABLE arcs_bacon_numbers ADD (CONSTRAINT arcs_bacon_numbers_pk PRIMARY KEY (link_id))
/
PROMPT Non-unique index on node_id_to
CREATE INDEX arcs_bacon_numbers_N1 ON arcs_bacon_numbers(node_id_to)
/
PROMPT Gather stats on arcs_bacon_numbers
BEGIN
  DBMS_Stats.Gather_Table_Stats(
              ownname                 => USER,
              tabname                 => 'ARCS_BACON_NUMBERS');
END;
/
@..\endspool
