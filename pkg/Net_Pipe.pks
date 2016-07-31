CREATE OR REPLACE PACKAGE Net_Pipe AS
/**************************************************************************************************

Author:         Brendan Furey
Date:           10 May 2015
Description:    Brendan's network analysis PL/SQL package, (http://aprogrammerwrites.eu/?p=1426).
                Pipelined function returns a record for each link in all connected subnetworks 
		specified by the view links_v. The root_node_id field identifies the subnetwork that
		a link belongs to. Use SQL to list the network in detail, or at any desired level of
		aggregation. Here is an example call:

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
***************************************************************************************************/

TYPE net_rec_type IS RECORD (
		root_node_id				VARCHAR2(100),
		dirn					VARCHAR2(1),
		node_id					VARCHAR2(100),
		link_id					VARCHAR2(100),
                node_level                              NUMBER,
		loop_flag				VARCHAR2(1),
		line_no 				NUMBER
);
TYPE net_tab_type IS TABLE OF net_rec_type;

FUNCTION All_Nets RETURN net_tab_type PIPELINED;

END Net_Pipe;
/
SHO ERR
