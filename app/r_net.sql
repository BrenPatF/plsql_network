/***************************************************************************************************
Name: r_net.sql                         Author: Brendan Furey                      Date: 24-Aug-2019

Network analysis driver script component in the plsql_network module. 

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
|===================================================================================================
|  EXAMPLES                                                                                        |
----------------------------------------------------------------------------------------------------
| *r_net*           |  Net_Pipe     |  Script calls Net_Pipe pipelined function to display network |
|                   |               |  structure within one detail query and two aggregated        |
|                   |               |  queries, based on the view links_v                          |
----------------------------------------------------------------------------------------------------
|  main_fk          |  r_net        |  Recreates view links_v pointing to the foreign key example  |
|                   |               |  network and calls r_net.sql script to run the analysis      |
|                   |               |  queries                                                     |
----------------------------------------------------------------------------------------------------
|  main_brightkite  |  r_net        |  Recreates view links_v pointing to the Brightkite example   |
|                   |               |  network and calls r_net.sql script to run the analysis      |
|                   |               |  queries                                                     |
----------------------------------------------------------------------------------------------------
|  UNIT TEST                                                                                       |
----------------------------------------------------------------------------------------------------
|  r_tests          |  TT_Net_Pipe  |  Unit testing the Net_Pipe package. Trapit is installed as a |
|                   |  Trapit       |  component of a separate module                              |
====================================================================================================

This file has a network analysis driver script that calls the Net_Pipe.All_Nets pipelined
function from an SQL query to display the network structure in three ways:

(i)   In detail, with all links displayed, and analytic counts of links and nodes
(ii)  In summary, grouping by subnetwork
(iii) In summary, grouping by numbers of nodes

This script is called from the two example network driver scripts.

***************************************************************************************************/
SET LINES 500
SET PAGES 50000
COLUMN "Lev"            FORMAT 99990
COLUMN "#Links"         FORMAT 999990
COLUMN "#Nodes"         FORMAT 999990
COLUMN "Node"           FORMAT A70

BREAK ON "Network" ON "#Links" ON "#Nodes"

SET TIMING ON
PROMPT Network detail
SELECT root_node_id                                                            "Network",
       Count(DISTINCT link_id) OVER (PARTITION BY root_node_id) - 1            "#Links",
       Count(DISTINCT node_id) OVER (PARTITION BY root_node_id)                "#Nodes",
       node_level                                                              "Lev",
       LPad(dirn || ' ', Least(2*node_level, 60), ' ') || node_id || loop_flag "Node",
       link_id                                                                 "Link"
  FROM TABLE(Net_Pipe.All_Nets)
 ORDER BY line_no
/
PROMPT Network summary 1 - by subnetwork
SELECT root_node_id            "Network",
       Count(DISTINCT link_id) "#Links",
       Count(DISTINCT node_id) "#Nodes",
       Max(node_level)         "Max Lev"
  FROM TABLE(Net_Pipe.All_Nets)
 GROUP BY root_node_id
 ORDER BY 2
/
PROMPT Network summary 2 - grouped by numbers of nodes
WITH network_counts AS (
SELECT root_node_id,
       Count(DISTINCT node_id) n_nodes
  FROM TABLE(Net_Pipe.All_Nets)
 GROUP BY root_node_id
)
SELECT n_nodes "#Nodes",
       COUNT(*) "#Networks"
  FROM network_counts
 GROUP BY n_nodes
 ORDER BY 1
/
SET TIMING OFF
