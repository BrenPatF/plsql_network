Import-Module ..\powershell_utils\TrapitUtils\TrapitUtils
Test-FormatDB 'lib/lib' 'orclpdb' 'lib' $PSScriptRoot `
'CREATE OR REPLACE VIEW links_v(
                link_id,
                node_id_fr,
                node_id_to
) AS
SELECT *
  FROM network_links
/'
