CREATE OR REPLACE PACKAGE BODY TT_Net_Pipe AS
/***************************************************************************************************
Name: tt_net_pipe.pkb                   Author: Brendan Furey                      Date: 24-Aug-2019

Package body component in the plsql_network module. 

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

This file has the TT_Net_Pipe package body. Note that the test package is called by the unit
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

/***************************************************************************************************

add_Links: Insert link records to the network links table from an input array of triples

***************************************************************************************************/
PROCEDURE add_Links(
            p_link_2lis                    L2_chr_arr) IS -- list of (from node, to node, link id) triples
BEGIN

  FOR i IN 1..p_link_2lis.COUNT LOOP

    INSERT INTO network_links VALUES (p_link_2lis(i)(1), p_link_2lis(i)(2), p_link_2lis(i)(3));

  END LOOP;

END add_Links;

/***************************************************************************************************

cursor_To_List: Call Utils Cursor_To_List function, passing an open cursor, and delimiter, and 
                return the resulting list of delimited records

***************************************************************************************************/
FUNCTION cursor_To_List(
            p_cursor_text                  VARCHAR2)     -- cursor text
            RETURN                         L1_chr_arr IS -- list of delimited records
  l_csr             SYS_REFCURSOR;
BEGIN

  OPEN l_csr FOR p_cursor_text;
  RETURN Utils.Cursor_To_List(x_csr    => l_csr,
                              p_delim  => '|');

END cursor_To_List;

/***************************************************************************************************

Purely_Wrap_All_Nets: Unit test wrapper function for Net_Pipe network analysis package

    Returns the 'actual' outputs, given the inputs for a scenario, with the signature expected for
    the Math Function Unit Testing design pattern, namely:

      Input parameter: 3-level list (type L3_chr_arr) with test inputs as group/record/field
      Return Value: 2-level list (type L2_chr_arr) with test outputs as group/record (with record as
                   delimited fields string)

***************************************************************************************************/
FUNCTION Purely_Wrap_All_Nets(
            p_inp_3lis                     L3_chr_arr)   -- input list of lists (group, record, field)
            RETURN                         L2_chr_arr IS -- output list of lists (group, record)

  l_act_2lis                     L2_chr_arr := L2_chr_arr();
BEGIN

  add_Links(p_link_2lis => p_inp_3lis(1));
  l_act_2lis.EXTEND;
  l_act_2lis(1) := cursor_To_List(p_cursor_text => 'SELECT * FROM TABLE(Net_Pipe.All_Nets)');
  ROLLBACK;
  RETURN l_act_2lis;

END Purely_Wrap_All_Nets;

END TT_Net_Pipe;
/
SHO ERR