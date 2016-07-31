SET LINES 500
SET PAGES 50000
COLUMN "Lev"            FORMAT 99990
COLUMN "#Links"         FORMAT 999990
COLUMN "#Nodes"         FORMAT 999990
COLUMN "Node"           FORMAT A70

BREAK ON "Network" ON "#Links" ON "#Nodes"

SET TIMING ON
PROMPT Network detail
SELECT root_node_id             "Network",
       Count (DISTINCT link_id) OVER (PARTITION BY root_node_id) - 1 "#Links",
       Count (DISTINCT node_id) OVER (PARTITION BY root_node_id) "#Nodes",
       node_level "Lev",
       LPad (dirn || ' ', Least (2*node_level, 60), ' ') || node_id || loop_flag "Node",
       link_id                  "Link"
  FROM TABLE (Net_Pipe.All_Nets)
 ORDER BY line_no
/
PROMPT Network summary 1 - by network
SELECT root_node_id             "Network",
       Count (DISTINCT link_id) "#Links",
       Count (DISTINCT node_id) "#Nodes",
       Max (node_level) "Max Lev"
  FROM TABLE (Net_Pipe.All_Nets)
 GROUP BY root_node_id
 ORDER BY 2
/
PROMPT Network summary 2 - grouped by numbers of nodes
WITH network_counts AS (
SELECT root_node_id,
       Count (DISTINCT node_id) n_nodes
  FROM TABLE (Net_Pipe.All_Nets)
 GROUP BY root_node_id
)
SELECT n_nodes "#Nodes",
       COUNT(*) "#Networks"
  FROM network_counts
 GROUP BY n_nodes
 ORDER BY 1
/
SET TIMING OFF
