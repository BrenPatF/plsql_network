@..\..\initspool install_fk
/***************************************************************************************************
Name: install_fk.sql                    Author: Brendan Furey                      Date: 24-Aug-2019

Installation script for the foreign key network example in the plsql_network module.

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
|--------------------------------------------------------------------------------------------------|
|  grant_net_pipe_to_app.sql  |  Grants privileges on Net_Pipe components from lib to app schema   |
|--------------------------------------------------------------------------------------------------|
|  c_net_pipe_syns.sql        |  Creates synonyms for Net_Pipe components in app schema to lib     |
|                             |  schema                                                            |
|--------------------------------------------------------------------------------------------------|
|  EXAMPLES                                                                                        |
|--------------------------------------------------------------------------------------------------|
| *install_fk.sql*            |  Installs foreign key example network in app. This copies          |
|                             |  information from the Oracle view all_constraints into table       |
|                             |  fk_links to represent foreign key links as a network. The links   |
|                             |  visible in the Oracle view depend on the tables readable by app   |
|-----------------------------|--------------------------------------------------------------------|
|  install_brightkite.sql     |  Installs example "Friendship network of Brightkite users" in app  |
|                             |  schema, large example having 58,228 nodes and 214,078 links from: |
|                             |  https://snap.stanford.edu/data/loc-brightkite.html                |
|--------------------------------------------------------------------------------------------------|
|  UNIT TEST                                                                                       |
|--------------------------------------------------------------------------------------------------|
|  install_net_pipe_tt.sql    |  Creates unit test components that require a minimum Oracle        |
|                             |  database version of 12.2 in lib schema                            |
====================================================================================================
This file has the install script for the foreign key network example in the app schema.

Components created:

    Tables               Description
    ===================  ===========================================================================
    fk_links             Table used for foreign key network data

    Statistics           Description
    ===================  ===========================================================================
    fk_links             Statistics vias DBMS_Stats.Gather_Table_Stats (default settings)

***************************************************************************************************/
PROMPT Foreign key table setup...
DROP TABLE fk_links
/
CREATE TABLE fk_links(
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
  FROM fk_links
/
PROMPT Non-unique indexes on table_fr and table_to
CREATE INDEX fk_links_N1 ON fk_links(table_fr)
/
CREATE INDEX fk_links_N2 ON fk_links(table_to)
/
PROMPT Gather stats on fk_links
BEGIN

DBMS_Stats.Gather_Table_Stats(
                ownname                 => USER,
                tabname                 => 'fk_links');
END;
/
@..\..\endspool