$plsutils_root = $PSScriptRoot + '\..\..\oracle_plsql_utils\'
$trapit_root = $PSScriptRoot + '\..\..\trapit_oracle_tester\'
$lib = $PSScriptRoot + '\lib'
$app = $PSScriptRoot + '\app'

Copy-Item ($plsutils_root + 'c_user.sql') $PSScriptRoot
Copy-Item ($plsutils_root + 'drop_utils_users.sql') $PSScriptRoot
Copy-Item ($plsutils_root + 'endspool.sql') $PSScriptRoot
Copy-Item ($plsutils_root + 'initspool.sql') $PSScriptRoot
Copy-Item ($plsutils_root + 'install_sys.sql') $PSScriptRoot
Copy-Item ($plsutils_root + 'sys.bat') $PSScriptRoot

Copy-Item ($plsutils_root + 'lib\grant_utils_to_app.sql') $lib
Copy-Item ($plsutils_root + 'lib\install_utils.sql') $lib
Copy-Item ($plsutils_root + 'lib\lib.bat') $lib
Copy-Item ($plsutils_root + 'lib\utils.pkb') $lib
Copy-Item ($plsutils_root + 'lib\utils.pks') $lib

Copy-Item ($plsutils_root + 'app\app.bat') $app
Copy-Item ($plsutils_root + 'app\c_utils_syns.sql') $app

Copy-Item ($trapit_root + 'lib\grant_trapit_to_app.sql') $lib
Copy-Item ($trapit_root + 'lib\install_trapit.sql') $lib
Copy-Item ($trapit_root + 'lib\trapit.pkb') $lib
Copy-Item ($trapit_root + 'lib\trapit.pks') $lib
Copy-Item ($trapit_root + 'lib\trapit_run.pkb') $lib
Copy-Item ($trapit_root + 'lib\trapit_run.pks') $lib

Copy-Item ($trapit_root + 'app\c_trapit_syns.sql') $app