@..\initspool r_tests
/***************************************************************************************************
Name: r_tests.sql                       Author: Brendan Furey                      Date: 24-Aug-2019

Unit test driver script component in the plsql_network module. 

The module contains a PL/SQL package for the efficient analysis of networks that can be specified
by a view representing their node pair links. The package has a pipelined function that returns a
record for each link in all connected subnetworks, with the root node id used to identify the
subnetwork that a link belongs to. Examples are included showing how to call the function from SQL
to list a network in detail, or at any desired level of aggregation.

    GitHub: https://github.com/BrenPatF/plsql_network  (31 July 2016)
    Blog:   http://aprogrammerwrites.eu/?p=1426 (10 May 2015)

There are two example networks supplied, with driver SQL scripts noted below, and a unit test
program. Unit testing is optional and depends on the module trapit_oracle_tester.

DRIVER SCRIPTS
====================================================================================================
|  Main/Test .sql   |  Package/sql  |  Notes                                                       |
|==================================================================================================|
|  EXAMPLES                                                                                        |
---------------------------------------------------------------------------------------------------|
|  r_net            |  Net_Pipe     |  Script calls Net_Pipe pipelined function to display network |
|                   |               |  structure within one detail query and two aggregated        |
|                   |               |  queries, based on the view links_v                          |
|-----------------------------------|--------------------------------------------------------------|
|  main_fk          |  r_net        |  Recreates view links_v pointing to the foreign key example  |
|                   |               |  network and calls r_net.sql script to run the analysis      |
|                   |               |  queries                                                     |
|-----------------------------------|--------------------------------------------------------------|
|  main_brightkite  |  r_net        |  Recreates view links_v pointing to the Brightkite example   |
|                   |               |  network and calls r_net.sql script to run the analysis      |
|                   |               |  queries                                                     |
|--------------------------------------------------------------------------------------------------|
|  UNIT TEST                                                                                       |
|--------------------------------------------------------------------------------------------------|
| *r_tests*         |  TT_Net_Pipe  |  Unit testing the Net_Pipe package. Trapit is installed as a |
|                   |  Trapit       |  component of a separate module                              |
====================================================================================================

This file has the Unit test driver script. Note that the test package is called by the unit test 
utility package Trapit, which reads the unit test details from a table, tt_units, populated by the
install scripts.

The test program follows 'The Math Function Unit Testing design pattern':

    GitHub: https://github.com/BrenPatF/trapit_nodejs_tester

Note that the unit test program generates an output file, tt_net_pipe.all_nets_out.json, that is 
processed by a separate nodejs program, npm package trapit (see README for further details).

The output JSON file contains arrays of expected and actual records by group and scenario, in the
format expected by the nodejs program. This program produces listings of the results in HTML and/or
text format, and a sample set of listings is included in the folder test_output.

***************************************************************************************************/
DEFINE LIB=lib
PROMPT Create view links_v in lib schema (will be superseded by any view of same name defined in calling schema)
CREATE OR REPLACE VIEW links_v(
                link_id,
                node_id_fr,
                node_id_to
) AS
SELECT *
  FROM network_links
/
BEGIN

  Trapit_Run.Run_Tests(p_group_nm => '&LIB');

END;
/
@..\endspool