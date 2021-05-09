@..\initspool install_net_pipe_tt
/***************************************************************************************************
Name: install_net_pipe_tt.sql           Author: Brendan Furey                      Date: 24-Aug-2019

Installation script for the unit test components in the plsql_network module.

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
|--------------------------------------------------------------------------------------------------|
|  UNIT TEST                                                                                       |
|--------------------------------------------------------------------------------------------------|
| *install_net_pipe_tt.sql*   |  Creates unit test components that require a minimum Oracle        |
|                             |  database version of 12.2 in lib schema                            |
====================================================================================================
This file has the install script for the unit test components in the lib schema. It requires a
minimum Oracle database version of 12.2, owing to the use of v12.2 PL/SQL JSON features.

Components created, with NO synonyms or grants - only accessible within lib schema:

    Tables         Description
    =============  =================================================================================
    network_links  Table for the networks created in unit testing

    Packages       Description
    =============  =================================================================================
    TT_Net_Pipe    Unit test package for Net_Pipe. Uses Oracle v12.2 JSON features

    Metadata       Description
    =============  =================================================================================
    tt_units       Record for package, procedure ('TT_NET_PIPE', 'ALL_NETS'). The input JSON file,
                   tt_net_pipe.all_nets_inp.json, must first be placed in the OS folder pointed to
                   by INPUT_DIR directory

Pre-requisite: Installation of the oracle_plsql_utils module:

    GitHub: https://github.com/BrenPatF/oracle_plsql_utils

***************************************************************************************************/
PROMPT Create empty links table in lib schema
DROP TABLE network_links
/
CREATE TABLE network_links(
                link_id           VARCHAR2(100),
                node_id_fr        VARCHAR2(100),
                node_id_to        VARCHAR2(100),
                CONSTRAINT network_links_pk PRIMARY KEY (link_id)
)
/

PROMPT Create package tt_net_pipe
@tt_net_pipe.pks
@tt_net_pipe.pkb

PROMPT Add the tt_units record, reading in JSON file from INPUT_DIR
DEFINE LIB=lib
BEGIN

  Trapit.Add_Ttu(
            p_unit_test_package_nm         => 'TT_NET_PIPE',
            p_purely_wrap_api_function_nm  => 'Purely_Wrap_All_Nets', 
            p_group_nm                     => '&LIB',
            p_active_yn                    => 'Y', 
            p_input_file                   => 'tt_net_pipe.purely_wrap_all_nets_inp.json');

END;
/
@..\endspool