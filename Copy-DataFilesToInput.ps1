$net_brightkite_file = $PSScriptRoot + '\app\net_brightkite\brightkite_edges.csv'
$bacon_numbers_file = $PSScriptRoot + '\app\bacon_numbers\bacon_numbers.txt'
$json_ut_file = $PSScriptRoot + '\unit_test\tt_net_pipe.purely_wrap_all_nets_inp.json'
$input_dir = 'C:\input'

Copy-Item $net_brightkite_file $input_dir
Copy-Item $bacon_numbers_file $input_dir
Copy-Item $json_ut_file $input_dir
