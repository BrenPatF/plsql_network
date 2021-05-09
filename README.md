# Net_Pipe
<img src="mountains.png">
Oracle PL/SQL network analysis module.

:globe_with_meridians:

The module contains a PL/SQL package for the efficient analysis of networks that can be specified
by a view representing their node pair links. The package has a pipelined function that returns a
record for each link in all connected subnetworks, with the root node id used to identify the
subnetwork that a link belongs to. Examples are included showing how to call the function from SQL
to list a network in detail, or at any desired level of aggregation. I find it quite useful to map out a database schema like this.

See [PL/SQL Pipelined Function for Network Analysis](http://aprogrammerwrites.eu/?p=1426), May 2015

The package is tested using the Math Function Unit Testing design pattern, with test results in HTML and text format included (see `test_data\test_output` for the unit test results folder).

The module also comes with two example networks.

## In this README...
- [Usage - Example for app schema foreign key network](https://github.com/BrenPatF/plsql_network#usage---example-for-app-schema-foreign-key-network)
- [API](https://github.com/BrenPatF/plsql_network#api)
- [Installation](https://github.com/BrenPatF/plsql_network#installation)
- [Unit Testing](https://github.com/BrenPatF/plsql_network#unit-testing)
- [Operating System/Oracle Versions](https://github.com/BrenPatF/plsql_network#operating-systemoracle-versions)

## Usage - Example for app schema foreign key network
- [In this README...](https://github.com/BrenPatF/plsql_network#in-this-readme)
- [Network Detail](https://github.com/BrenPatF/plsql_network#network-detail)
- [Network Summary](https://github.com/BrenPatF/plsql_network#network-summary)

### Network Detail
```sql
SELECT root_node_id                                                            "Network",
       Count(DISTINCT link_id) OVER (PARTITION BY root_node_id) - 1            "#Links",
       Count(DISTINCT node_id) OVER (PARTITION BY root_node_id)                "#Nodes",
       node_level                                                              "Lev",
       LPad(dirn || ' ', Least(2*node_level, 60), ' ') || node_id || loop_flag "Node",
       link_id                                                                 "Link"
  FROM TABLE(Net_Pipe.All_Nets)
 ORDER BY line_no

[Extract of ouput for 1 subnetwork, see app/net_fk folder for full output]

Network              #Links #Nodes Lev Node                                                Link
-------------------- ------ ------ --- --------------------------------------------------- ------------------------------------
SDO_COORD_AXES|MDSYS     31     15   0 SDO_COORD_AXES|MDSYS                                ROOT
                                     1 > SDO_COORD_AXIS_NAMES|MDSYS                        coord_axis_foreign_axis|mdsys
                                     1 > SDO_COORD_SYS|MDSYS                               coord_axis_foreign_cs|mdsys
                                     2   < SDO_COORD_REF_SYS|MDSYS                         coord_ref_sys_foreign_cs|mdsys
                                     3     < SDO_COORD_OPS|MDSYS                           coord_operation_foreign_source|mdsys
                                     4       = SDO_COORD_OPS|MDSYS*                        coord_operation_foreign_legacy|mdsys
                                     4       > SDO_COORD_OP_METHODS|MDSYS                  coord_operation_foreign_method|mdsys
                                     5         < SDO_COORD_OP_PARAM_USE|MDSYS              coord_op_para_use_foreign_meth|mdsys
                                     6           > SDO_COORD_OP_PARAMS|MDSYS               coord_op_para_use_foreign_para|mdsys
                                     7             < SDO_COORD_OP_PARAM_VALS|MDSYS         coord_op_para_val_foreign_para|mdsys
                                     8               > SDO_COORD_OPS|MDSYS*                coord_op_para_val_foreign_op|mdsys
                                     8               > SDO_COORD_OP_METHODS|MDSYS*         coord_op_para_val_foreign_meth|mdsys
                                     8               > SDO_UNITS_OF_MEASURE|MDSYS          coord_op_para_val_foreign_uom|mdsys
                                     9                 < SDO_COORD_AXES|MDSYS*             coord_axis_foreign_uom|mdsys
                                     9                 > SDO_ELLIPSOIDS|MDSYS              ellipsoid_foreign_legacy|mdsys
                                    10                   < SDO_DATUMS|MDSYS                datum_foreign_ellipsoid|mdsys
                                    11                     < SDO_COORD_REF_SYS|MDSYS*      coord_ref_sys_foreign_datum|mdsys
                                    11                     = SDO_DATUMS|MDSYS*             datum_foreign_legacy|mdsys
                                    11                     > SDO_PRIME_MERIDIANS|MDSYS     datum_foreign_meridian|mdsys
                                    12                       > SDO_UNITS_OF_MEASURE|MDSYS* prime_meridian_foreign_uom|mdsys
                                    10                   > SDO_UNITS_OF_MEASURE|MDSYS*     ellipsoid_foreign_uom|mdsys
                                     9                 = SDO_UNITS_OF_MEASURE|MDSYS*       unit_of_measure_foreign_legacy|mdsys
                                     9                 = SDO_UNITS_OF_MEASURE|MDSYS*       unit_of_measure_foreign_uom|mdsys
                                     4       > SDO_COORD_REF_SYS|MDSYS*                    coord_operation_foreign_target|mdsys
                                     4       < SDO_COORD_REF_SYS|MDSYS*                    coord_ref_sys_foreign_proj|mdsys
                                     3     < SDO_COORD_OP_PATHS|MDSYS                      coord_op_path_foreign_source|mdsys
                                     4       > SDO_COORD_REF_SYS|MDSYS*                    coord_op_path_foreign_target|mdsys
                                     3     = SDO_COORD_REF_SYS|MDSYS*                      coord_ref_sys_foreign_geog|mdsys
                                     3     = SDO_COORD_REF_SYS|MDSYS*                      coord_ref_sys_foreign_horiz|mdsys
                                     3     = SDO_COORD_REF_SYS|MDSYS*                      coord_ref_sys_foreign_legacy|mdsys
                                     3     = SDO_COORD_REF_SYS|MDSYS*                      coord_ref_sys_foreign_vert|mdsys
                                     3     < SDO_SRIDS_BY_URN|MDSYS                        sys_c006526|mdsys

```
### Network Summary
- [Usage - Example for app schema foreign key network](https://github.com/BrenPatF/plsql_network#usage---example-for-app-schema-foreign-key-network)

```sql
SELECT root_node_id            "Network",
       Count(DISTINCT link_id) "#Links",
       Count(DISTINCT node_id) "#Nodes",
       Max(node_level)         "Max Lev"
  FROM TABLE(Net_Pipe.All_Nets)
 GROUP BY root_node_id
 ORDER BY 2

Network summary 1 - by subnetwork

Network                                     #Links  #Nodes    Max Lev
------------------------------------------ ------- ------- ----------
BATCH_JOBS|LIB                                   2       2          1
OGIS_GEOMETRY_COLUMNS|MDSYS                      2       2          1
DR$THS_PHRASE|CTXSYS                             2       2          1
SDO_WS_CONFERENCE_PARTICIPANTS|MDSYS             2       2          1
LOG_HEADERS|BENCH                                2       2          1
LOG_CONFIGS|LIB                                  3       3          2
DEPARTMENTS|HR                                   4       2          2
SDO_COORD_AXES|MDSYS                            32      15         12

8 rows selected.

Elapsed: 00:00:00.01
```

To run the examples in a slqplus session from app subfolders (after installation, including examples):

[net_fk]
```
SQL> @main_fk
```

[net_brightkite]
```
SQL> @main_brightkite
```
This is a fairly large example, the "Friendship network of Brightkite users", having 58,228 nodes and 214,078 links taken from: https://snap.stanford.edu/data/loc-brightkite.html. The analysis SQL ran in around 38 seconds at summary level on my laptop, and 85 seconds at detail level with 214,625 lines spooled.

## API
- [In this README...](https://github.com/BrenPatF/plsql_network#in-this-readme)

### View links_v
The pipelined function reads the network configuration by means of a view representing all the links in the network. The view must be created with three character fields, up to 100 characters long:
- link_id
- node_id_fr
- node_id_to

### Querying the network
The detailed network structure can be obtained from a simple query of the pipelined function:
```sql
SELECT * FROM TABLE(Net_Pipe.All_Nets) ORDER BY line_no
```
Options for formatting and aggregating the output can be seen in the usage section above.

## Installation
- [In this README...](https://github.com/BrenPatF/plsql_network#in-this-readme)
- [Install 1: Install Utils module (optional)](https://github.com/BrenPatF/plsql_network#install-1-install-utils-module-optional)
- [Install 2: Create Net_Pipe components](https://github.com/BrenPatF/plsql_network#install-2-create-net_pipe-components)
- [Install 3: Example networks (optional)](https://github.com/BrenPatF/plsql_network#install-3-example-networks-optional)
- [Install 4: Install unit test code (optional)](https://github.com/BrenPatF/plsql_network#install-4-install-unit-test-code-optional)

The base code consists of a PL/SQL package containing a pipelined function, and a view links_v pointing to network data. These can be easily installed into an existing schema following the steps in Install 2 below.

The install steps below also allow for a fuller installation that  includes optional creation of new lib and app schemas, with example network structures and full unit testing. The `lib` schema refers to the schema in which the base package is installed, while the `app` schema refers to the schema where the package is called from and where the optional examples are installed (Install 3).

### Install 1: Install Utils module (optional)
- [Installation](https://github.com/BrenPatF/plsql_network#installation)

#### [Schema: lib; Folder: (Utils) lib]
- Download and install the Utils module:
[Oracle PL/SQL general utilities module on GitHub](https://github.com/BrenPatF/oracle_plsql_utils)

This module allows for optional creation of new lib and app schemas. Both base and unit test Utils installs are required for the unit test Net_Pipe install (Install 4).

### Install 2: Create Net_Pipe components
- [Installation](https://github.com/BrenPatF/plsql_network#installation)

#### [Schema: lib; Folder: lib]

- Run script from slqplus:

```
SQL> @install_net_pipe app
```

This creates the required components for the base install along with grants for them to the app schema (passing none instead of app will bypass the grants). This install is all that is required to use the package within the lib schema and app schema (if passed). To grant privileges to another schema, run the grants script directly, passing `schema`:

```
SQL> @grant_net_pipe_to_app schema
```
The package reads the network from a view links_v and the install script above creates a 1-link dummy view. To run against any other network, simply recreate the view to point to the network data, as shown in the example scripts (Install 3).

### Install 3: Example networks (optional)
- [Installation](https://github.com/BrenPatF/plsql_network#installation)

#### Synonym [Schema: app; Folder: app]

- Run script from slqplus to create the synonym to the lib package:

```
SQL> @c_net_pipe_syns lib
```

#### Foreign keys [Schema: app; Folder: app\net_fk]
- Run script from slqplus:

```
SQL> @install_fk
```
This install creates and populates the table fk_link with the Oracle foreign key network defined by the standard Oracle view all_constraints (which depends on the privileges granted to the app schema). To run the network analysis script against this example:
```
SQL> @main_fk
```
#### Brightkite [Schema: app; Folder: app\net_brightkite]
- Ensure Oracle directory  INPUT_DIR is set up and points to a folder with read/write access
- Place file Brightkite_edges.csv in folder pointed to by Oracle directory INPUT_DIR
- Run script from slqplus:

```
SQL> @install_brightkite
```
This install creates and populates the table net_brightkite with the Brightkite example network. To run the network analysis script against this example:

```
SQL> @main_brightkite
```

### Install 4: Install unit test code (optional)
- [Installation](https://github.com/BrenPatF/plsql_network#installation)

#### [Schema: lib; Folder: lib]
This step requires the Trapit module option to have been installed as part of Install 1, and requires a minimum Oracle version of 12.2.
- Copy the following file from the root folder to the server folder pointed to by the Oracle directory INPUT_DIR:
  - tt_net_pipe.all_nets_inp.json
- Run script from slqplus:

```
SQL> @install_net_pipe_tt
```

## Unit Testing
- [In this README...](https://github.com/BrenPatF/plsql_network#in-this-readme)
- [Unit Testing Process](https://github.com/BrenPatF/plsql_network#unit-testing-process)
- [Wrapper Function Signature Diagram](https://github.com/BrenPatF/plsql_network#wrapper-function-signature-diagram)
- [Scenarios](https://github.com/BrenPatF/plsql_network#scenarios)

### Unit Testing Process
- [Unit Testing](https://github.com/BrenPatF/plsql_network#unit-testing)

The package is tested using the Math Function Unit Testing design pattern, described here: [The Math Function Unit Testing design pattern, implemented in nodejs](https://github.com/BrenPatF/trapit_nodejs_tester#trapit). In this approach, a 'pure' wrapper function is constructed that takes input parameters and returns a value, and is tested within a loop over scenario records read from a JSON file.

The program is data-driven from the input file tt_utils.purely_wrap_utils_inp.json and produces an output file, tt_utils.purely_wrap_utils_out.json (in the Oracle directory `INPUT_DIR`), that contains arrays of expected and actual records by group and scenario.

The unit test program may be run from the Oracle lib subfolder:

```
SQL> @r_tests
```

The output file is processed by a nodejs program that has to be installed separately from the `npm` nodejs repository, as described in the Trapit install in `Install 1` above. The nodejs program produces listings of the results in HTML and/or text format, and a sample set of listings is included in the subfolder test_output. To run the processor, open a powershell window in the npm trapit package folder after placing the output JSON file, tt_utils.purely_wrap_utils_out.json, in the subfolder ./examples/externals and run:

```
$ node ./examples/externals/test-externals
```

This creates, or updates, a subfolder, oracle-pl_sql-network-analysis, with the formatted results output files. The three testing steps can easily be automated in Powershell (or Unix bash).

[An easy way to generate a starting point for the input JSON file is to use a powershell utility [Powershell Utilites module](https://github.com/BrenPatF/powershell_utils) to generate a template file with a single scenario with placeholder records from simple .csv files. See the script purely_wrap_all_nets.ps1 in the `test_data` subfolder for an example]

### Wrapper Function Signature Diagram
- [Unit Testing](https://github.com/BrenPatF/plsql_network#unit-testing)

<img src="test_data\plsql_networkJSD.png">

### Scenarios
- [Unit Testing](https://github.com/BrenPatF/plsql_network#unit-testing)

The art of unit testing lies in choosing a set of scenarios that will produce a high degree of confidence in the functioning of the unit under test across the often very large range of possible inputs.

A useful approach to this can be to think in terms of categories of inputs, where we reduce large ranges to representative categories. In our case we might consider the following category sets, and create scenarios accordingly:

- Value Size: Small / Large 
- Multiplicity: 1 / Multiple
  - links
  - networks
- Looping: Loop / Tree

The summary report in text format shows the scenarios tested:

      #    Scenario                        Fails (of 1)  Status 
      ---  ------------------------------  ------------  -------
      1    1 link                          0             SUCCESS
      2    1 loop, 100ch names             0             SUCCESS
      3    4 subnetworks, looped and tree  0             SUCCESS

You can review the formatted unit test results obtained by the author here, [Unit Test Report: utils](http://htmlpreview.github.io/?https://github.com/BrenPatF/oracle_plsql_utils/blob/master/test_output/oracle-pl_sql-utilities.html), and the files are available in the `test_data\test_output` subfolder [oracle-pl_sql-utilities.html is the root page for the HTML version and oracle-pl_sql-utilities.txt has the results in text format].

#### Scenario 3 Network Diagram
- [Scenarios](https://github.com/BrenPatF/plsql_network#scenarios)

This is a diagram of the 4-subnetwork network in scenario 3
<img src="plsql_network - Scenario 3.png">

You can review the formatted unit test results obtained by the author here, [Unit Test Report: net_pipe](http://htmlpreview.github.io/?https://github.com/BrenPatF/plsql_network/blob/master/test_output/net_pipe.html), and the files are available in the `test_output` subfolder [net_pipe.html is the root page for the HTML version and net_pipe.txt has the results in text format].

## Operating System/Oracle Versions
- [In this README...](https://github.com/BrenPatF/plsql_network#in-this-readme)

### Windows
Windows 10, should be OS-independent

### Oracle
- Tested on Oracle Database Version 18.3.0.0.0
- Base code (and example) should work on earlier versions at least as far back as v10 and v11, while the unit test code requires a minimum version of 12.2

## See also
- [Utils - Oracle PL/SQL general utilities module](https://github.com/BrenPatF/oracle_plsql_utils)
- [Trapit - Oracle PL/SQL unit testing module](https://github.com/BrenPatF/trapit_oracle_tester)
- [Trapit - nodejs unit test processing package](https://github.com/BrenPatF/trapit_nodejs_tester)
   
## License
MIT