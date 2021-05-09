CREATE OR REPLACE PACKAGE TT_Net_Pipe AS
/***************************************************************************************************
Name: tt_net_pipe.pks                   Author: Brendan Furey                      Date: 24-Aug-2019

Package spec component in the plsql_network module. 

The module contains a PL/SQL package for the efficient analysis of networks that can be specified
by a view representing their node pair links. The package has a pipelined function that returns a
record for each link in all connected subnetworks, with the root node id used to identify the
subnetwork that a link belongs to. Examples are included showing how to call the function from SQL
to list a network in detail, or at any desired level of aggregation.

    GitHub: https://github.com/BrenPatF/plsql_network  (31 July 2016)
    Blog:   http://aprogrammerwrites.eu/?p=1426 (10 May 2015)

PACKAGES
====================================================================================================
|  Package      |  Notes                                                                           |
|==================================================================================================|
|  Net_Pipe     |  Package with pipelined function for network analysis                            |
|---------------|----------------------------------------------------------------------------------|
| *TT_Net_Pipe* |  Unit testing the Net_Pipe package. Depends on the module trapit_oracle_tester   |
====================================================================================================

This file has the TT_Net_Pipe package spec. Note that the test package is called by the unit
test driver package Trapit_Run, which reads the unit test details from a table, tt_units, populated
by the install scripts.

The test program follows 'The Math Function Unit Testing design pattern':

    GitHub: https://github.com/BrenPatF/trapit_nodejs_tester

Note that the unit test program generates an output file, tt_utils.purely_wrap_all_nets_out.json,
that is processed by a separate nodejs program, npm package trapit (see README for further details).

The output JSON file contains arrays of expected and actual records by group and scenario, in the
format expected by the nodejs program. This program produces listings of the results in HTML and/or
text format, and a sample set of listings is included in the folder test_data\test_output

***************************************************************************************************/
FUNCTION Purely_Wrap_All_Nets(
              p_inp_3lis                     L3_chr_arr)
              RETURN                         L2_chr_arr;

END TT_Net_Pipe;
/
