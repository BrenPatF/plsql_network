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
|===================================================================================================
|  Net_Pipe     |  Package with pipelined function for network analysis                            |
----------------------------------------------------------------------------------------------------
| *TT_Net_Pipe* |  Unit testing the Net_Pipe package. Depends on the module trapit_oracle_tester   |
====================================================================================================

This file has the TT_Net_Pipe package spec. See README for API specification and examples of use.

***************************************************************************************************/
PROCEDURE All_Nets;

END TT_Net_Pipe;
/
