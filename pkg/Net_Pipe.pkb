CREATE OR REPLACE PACKAGE BODY Net_Pipe AS
/**************************************************************************************************

Author:         Brendan Furey
Date:           10 May 2015
Description:    Brendan's network analysis PL/SQL package, (http://aprogrammerwrites.eu/?p=1426).
                Pipelined function returns a record for each link in all connected subnetworks 
		specified by the view links_v. The root_node_id field identifies the subnetwork that
		a link belongs to. Use SQL to list the network in detail, or at any desired level of
		aggregation. See spec for an example call.

***************************************************************************************************/

c_root_link_id          CONSTANT VARCHAR2(100) := 'ROOT';
c_loop_flag             CONSTANT VARCHAR2(1) := '*';
c_dirn_fr               CONSTANT VARCHAR2(1) := '<';
c_dirn_to               CONSTANT VARCHAR2(1) := '>';
c_dirn_sj               CONSTANT VARCHAR2(1) := '=';

g_root_node_id                   VARCHAR2(100);
g_line_no                        NUMBER;

PROCEDURE Write_Log (p_line VARCHAR2) IS
BEGIN

  DBMS_Output.Put_Line (p_line);

END Write_Log;

FUNCTION All_Nets RETURN net_tab_type PIPELINED IS
  g_net_tab				net_tab_type;
  TYPE id_hash_type IS                  TABLE OF PLS_INTEGER INDEX BY VARCHAR2(61);
  g_node_hash                           id_hash_type;
  g_link_hash                           id_hash_type;

  l_is_loop                             BOOLEAN;

  PROCEDURE Init_Net IS
  BEGIN

    g_net_tab := net_tab_type ();
    g_link_hash.DELETE;

  END Init_net;

  PROCEDURE Add_Net (p_root_node_id     VARCHAR2,
                     p_dirn             VARCHAR2,
                     p_node_id          VARCHAR2,
                     p_link_id          VARCHAR2,
                     p_node_level       PLS_INTEGER,
                     x_is_loop          OUT BOOLEAN) IS

    l_net_rec				net_rec_type;

  BEGIN

    IF g_link_hash.EXISTS (p_link_id) THEN
      x_is_loop := TRUE;
      RETURN;
    ELSE
      g_link_hash (p_link_id) := 1;
    END IF;

    g_line_no                   := g_line_no + 1;
    l_net_rec.line_no           := g_line_no;
    l_net_rec.root_node_id      := p_root_node_id;
    l_net_rec.dirn              := p_dirn;
    l_net_rec.node_id           := p_node_id;
    l_net_rec.link_id           := p_link_id;
    l_net_rec.node_level        := p_node_level;

    x_is_loop := g_node_hash.EXISTS (p_node_id);
    IF x_is_loop THEN

      l_net_rec.loop_flag := c_loop_flag;

    ELSE

      g_node_hash (p_node_id) := 1;

    END IF;
    g_net_tab.EXTEND;
    g_net_tab (g_net_tab.COUNT)  := l_net_rec;

  END Add_Net;

  PROCEDURE Expand_Node (p_node_id VARCHAR2, p_link_id_prior VARCHAR2, p_node_level PLS_INTEGER) IS

    CURSOR lin_csr IS
    SELECT link_id, node_id_fr node_id, c_dirn_fr dirn
      FROM links_v
     WHERE node_id_to   = p_node_id
       AND node_id_to  != node_id_fr
       AND link_id     != p_link_id_prior
     UNION
    SELECT link_id, node_id_to, c_dirn_to
      FROM links_v
     WHERE node_id_fr   = p_node_id
       AND node_id_to  != node_id_fr
       AND link_id     != p_link_id_prior
     UNION
    SELECT link_id, node_id_to, c_dirn_sj
      FROM links_v
     WHERE node_id_fr   = p_node_id
       AND node_id_to   = node_id_fr
       AND link_id     != p_link_id_prior
     ORDER BY 2, 1;
    TYPE lin_tab_type IS TABLE OF lin_csr%ROWTYPE;
    l_lin_tab		lin_tab_type;

  BEGIN

    OPEN lin_csr;
    FETCH lin_csr BULK COLLECT -- avoids too many open cursors
     INTO l_lin_tab;
    CLOSE lin_csr;

    FOR i IN 1..l_lin_tab.COUNT LOOP

      Add_Net (g_root_node_id, l_lin_tab(i).dirn, l_lin_tab(i).node_id, l_lin_tab(i).link_id, p_node_level + 1, l_is_loop);
      IF NOT l_is_loop THEN

        Expand_Node (l_lin_tab(i).node_id, l_lin_tab(i).link_id, p_node_level + 1);

      END IF;

    END LOOP;

  END Expand_Node;

BEGIN

  g_line_no := 0;
  FOR r_nod IN (
          SELECT node_id_fr root_node_id
            FROM links_v
           UNION
          SELECT node_id_to
            FROM links_v) LOOP

    IF g_node_hash.EXISTS (r_nod.root_node_id) THEN CONTINUE; END IF;

    g_root_node_id := r_nod.root_node_id;
    Init_Net;
    Add_Net (g_root_node_id, ' ', g_root_node_id, c_root_link_id, 0, l_is_loop);

    Expand_Node (g_root_node_id, c_root_link_id, 0);

    FOR i IN 1..g_net_tab.COUNT LOOP

      PIPE ROW (g_net_tab(i));

    END LOOP;

  END LOOP;

END All_Nets;

END Net_Pipe;
/
SHO ERR
