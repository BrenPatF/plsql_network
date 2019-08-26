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
|===================================================================================================
|  Net_Pipe     |  Package with pipelined function for network analysis                            |
----------------------------------------------------------------------------------------------------
| *TT_Net_Pipe* |  Unit testing the Net_Pipe package. Depends on the module trapit_oracle_tester   |
====================================================================================================

This file has the TT_Net_Pipe package body. See README for API specification and examples of use.

***************************************************************************************************/

/***************************************************************************************************

cursor_To_List: Call Utils Cursor_To_List function, passing an open cursor, regex filter, and,
                optionally, delimiter, and return the resulting list of delimited records.
                Input group array count zero means omit group

***************************************************************************************************/
FUNCTION cursor_To_List(
            p_cursor_text                  VARCHAR2,     -- cursor text
            p_delim                        VARCHAR2)     -- delimiter
            RETURN                         L1_chr_arr IS -- list of delimited records
  l_csr             SYS_REFCURSOR;
  l_ret_value_lis   L1_chr_arr;
BEGIN

  OPEN l_csr FOR p_cursor_text;

  l_ret_value_lis := Utils.Cursor_To_List(x_csr    => l_csr,
                                          p_delim  => p_delim);

  RETURN l_ret_value_lis;

END cursor_To_List;

PROCEDURE add_Links(p_link_2lis  L2_chr_arr) IS
BEGIN

  FOR i IN 1..p_link_2lis.COUNT LOOP

    INSERT INTO network_links VALUES (p_link_2lis(i)(1), p_link_2lis(i)(2), p_link_2lis(i)(3));

  END LOOP;

END add_Links;

/***************************************************************************************************

purely_Wrap_API: Design pattern has the API call wrapped in a 'pure' function, called once per 
                 scenario, with the output 'actuals' array including everything affected by the API,
                 whether as output parameters, or on database tables, etc. The inputs are also
                 extended from the API parameters to include any other effective inputs. Assertion 
                 takes place after all scenarios and is against the extended outputs, with extended
                 inputs also listed. The API call is timed

***************************************************************************************************/
FUNCTION purely_Wrap_API(
            p_delim                        VARCHAR2,     -- delimiter
            p_inp_3lis                     L3_chr_arr)   -- input list of lists (record, field)
            RETURN                         L2_chr_arr IS -- output list of lists (group, record)

  l_act_2lis                     L2_chr_arr := L2_chr_arr();
BEGIN

  add_Links(p_link_2lis => p_inp_3lis(1));
  l_act_2lis.EXTEND;
  l_act_2lis(1) := cursor_To_List(     p_cursor_text    => 'SELECT * FROM TABLE(Net_Pipe.All_Nets)',
                                       p_delim          => Nvl(p_delim, '|'));
  ROLLBACK;
  RETURN l_act_2lis;

END purely_Wrap_API;
/***************************************************************************************************

All_Nets: Entry point method for the unit test. Uses Trapit to read the test data from JSON clob
          into a 4-d list of (scenario, group, record, field), then calls a 'pure' wrapper function
          within a loop over the scenarios to get the actuals. A final call to Trapit.Set_Outputs
          creates the output JSON in tt_units as well as on file to be processed by trapit_nodejs

***************************************************************************************************/
PROCEDURE All_Nets IS

  PROC_NM                        CONSTANT VARCHAR2(30) := 'ALL_NETS';

  l_act_3lis                     L3_chr_arr := L3_chr_arr();
  l_sces_4lis                    L4_chr_arr;
  l_scenarios                    Trapit.scenarios_rec;
  l_delim                        VARCHAR2(10);
BEGIN

  l_scenarios := Trapit.Get_Inputs(p_package_nm   => $$PLSQL_UNIT,
                                   p_procedure_nm => PROC_NM);
  l_sces_4lis := l_scenarios.scenarios_4lis;
  l_delim := l_scenarios.delim;
  l_act_3lis.EXTEND(l_sces_4lis.COUNT);
  FOR i IN 1..l_sces_4lis.COUNT LOOP
    l_act_3lis(i) := purely_Wrap_API(p_delim    => l_delim,
                                     p_inp_3lis => l_sces_4lis(i));

  END LOOP;

  Trapit.Set_Outputs(p_package_nm   => $$PLSQL_UNIT,
                     p_procedure_nm => PROC_NM,
                     p_act_3lis     => l_act_3lis);

END All_Nets;

END TT_Net_Pipe;
/
SHO ERR