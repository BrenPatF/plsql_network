@..\initspool main_brightkite
/***************************************************************************************************
Name: main_brightkite.sql                         Author: Brendan Furey            Date: 24-Aug-2019

Driver script component in the plsql_network module, for the Brightkite example network.

The module contains a PL/SQL package for the efficient analysis of networks that can be specified
by a view representing their node pair links. The package has a pipelined function that returns a
record for each link in all connected subnetworks, with the root node id used to identify the
subnetwork that a link belongs to. Examples are included showing how to call the function from SQL
to list a network in detail, or at any desired level of aggregation.

    GitHub: https://github.com/BrenPatF/plsql_network  (31 July 2016)
    Blog:   http://aprogrammerwrites.eu/?p=1426 (10 May 2015)

There are three example networks supplied, with driver SQL scripts noted below, and a unit test
program. Unit testing is optional and depends on the module trapit_oracle_tester.

DRIVER SCRIPTS
====================================================================================================
|  Main/Test .sql      | Package/sql | Notes                                                       |
|==================================================================================================|
|  EXAMPLES                                                                                        |
|--------------------------------------------------------------------------------------------------|
|  r_net               | Net_Pipe    | Script calls Net_Pipe pipelined function to display network |
|                      |             | structure within one detail query and two aggregated        |
|                      |             | queries, based on the view links_v                          |
|----------------------|-------------|-------------------------------------------------------------|
|  main_fk             | r_net       | Recreates view links_v pointing to the foreign key example  |
|                      |             | network and calls r_net.sql script to run the analysis      |
|                      |             | queries                                                     |
|----------------------|-------------|-------------------------------------------------------------|
| *main_brightkite*    | r_net       | Recreates view links_v pointing to the Brightkite example   |
|                      |             | network and calls r_net.sql script to run the analysis      |
|                      |             | queries                                                     |
|----------------------|---------------------------------------------------------------------------|
|  main_bacon_numbers  | r_net       | Recreates view links_v pointing to the Bacon Numbers        |
|                      |             | example network and calls r_net.sql script to run the       |
|                      |             | analysis queries                                            |
|--------------------------------------------------------------------------------------------------|
|  UNIT TEST                                                                                       |
|--------------------------------------------------------------------------------------------------|
|  r_tests             | TT_Net_Pipe | Unit testing the Net_Pipe package. Trapit is installed as a |
|                      | Trapit      | component of a separate module                              |
====================================================================================================

Driver script component for the Brightkite example network: Calls r_net.sql.

***************************************************************************************************/
PROMPT links_v based on net_brightkite
CREATE OR REPLACE VIEW links_v (
  link_id,
  node_id_fr,
  node_id_to
)
AS
SELECT link_id,
  node_id_fr,
  node_id_to
  FROM net_brightkite
/
COLUMN "Network"        FORMAT A10
COLUMN "Link"           FORMAT A10

@..\r_net

@..\endspool