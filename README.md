# plsql_network

Author:         Brendan Furey
Date:           10 May 2015 (blog); 31 July 2016 (github)

This is a package containing a pipelined function for analysis of any network that can be represented by an Oracle view whose records are links between two nodes. The pipelined function returns a record for each link in all connected subnetworks specified by the view links_v.  The root_node_id field identifies the subnetwork that a link belongs to. You can use SQL to list the network in detail, or at any desired level of aggregation. The output can be used to show the structure of the network, with tree and loop-joining links identified, as in the example below. I find it quite useful to map out a database schema like this.

See 'PL/SQL Pipelined Function for Network Analysis'
    http://aprogrammerwrites.eu/?p=1426

<pre>
SQL
===
SELECT root_node_id             "Network",
       Count (DISTINCT link_id) OVER (PARTITION BY root_node_id) - 1 "#Links",
       Count (DISTINCT node_id) OVER (PARTITION BY root_node_id) "#Nodes",
       node_level "Lev",
       LPad (dirn || ' ', Least (2*node_level, 60), ' ') || node_id || loop_flag "Node",
       link_id                  "Link"
  FROM TABLE (Net_Pipe.All_Nets)
 ORDER BY line_no

Output sample for an Oracle v12.1 foreign key network
=====================================================
Network       #Links  #Nodes Lev  Node                                     Link
------------  ------  ------ ---  ---------------------------------------  -------------------------------
COUNTRIES|HR      21      16   0  COUNTRIES|HR                             ROOT
                               1  < LOCATIONS|HR                           loc_c_id_fk|hr
                               2    < DEPARTMENTS|HR                       dept_loc_fk|hr
                               3      > EMPLOYEES|HR                       dept_mgr_fk|hr
                               4        < CUSTOMERS|OE                     customers_account_manager_fk|oe
                               5          < ORDERS|OE                      orders_customer_id_fk|oe
                               6            > EMPLOYEES|HR*                orders_sales_rep_fk|oe
                               6            < ORDER_ITEMS|OE               order_items_order_id_fk|oe
                               7              > PRODUCT_INFORMATION|OE     order_items_product_id_fk|oe
                               8                < INVENTORIES|OE           inventories_product_id_fk|oe
                               9                  > WAREHOUSES|OE          inventories_warehouses_fk|oe
                              10                    > LOCATIONS|HR*        warehouses_location_fk|oe
                               8                < ONLINE_MEDIA|PM          loc_c_id_fk|pm
                               8                < PRINT_MEDIA|PM           printmedia_fk|pm
                               8                < PRODUCT_DESCRIPTIONS|OE  pd_product_id_fk|oe
                               4        > DEPARTMENTS|HR*                  emp_dept_fk|hr
                               4        = EMPLOYEES|HR*                    emp_manager_fk|hr
                               4        > JOBS|HR                          emp_job_fk|hr
                               5          < JOB_HISTORY|HR                 jhist_job_fk|hr
                               6            > DEPARTMENTS|HR*              jhist_dept_fk|hr
                               6            > EMPLOYEES|HR*                jhist_emp_fk|hr
                               1  > REGIONS|HR                             countr_reg_fk|hr

1 of 69 subnetworks is shown above
</pre>
Pre-requisites
==============
The package just requires a sufficiently recent version of Oracle,a nd the creation of the view against some network source data. I believe it should work from v10.1 upwards at least and on any edition including XE.

The example above reports on the subnetwork comprising Oracle's HR, OE and PM demo schemas in v12.1 (which differ from simpler earlier versions).

The sql scripts refer to two examples discussed in the blog article. The foreign key example has no pre-requisites other than Oracle database, while the Brightkite example would require population of a table dijkstra.arcs_brightkite. If you are interested, see the blog article for sourcing information.

Oracle Database Sample Schemas
    https://docs.oracle.com/cd/E11882_01/server.112/e10831/installation.htm#COMSC001

SQL Files
=========
C_Net_Tables.sql - this creates tables for the foreign key network and the Brightkite example (which will fail unless you have created dijkstra.arcs_brightkite)

Net_FK.sql - driver script that creates the view pointing to the foreign key sourcing table, then calls a script to do the SQL reports via the pipelined function

Net_Brightkite.sql - driver script that creates the view pointing to the Brightkite example sourcing table (that won't exist by default), then calls a script to do the SQL reports via the pipelined function

R_Net.sql - this script does the SQL reports via the pipelined function