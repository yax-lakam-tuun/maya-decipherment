#!/bin/bash

exit_code=0

test_case() {
    ahpula_path=$1
    arguments=$2
    nominal=$3

    cmd="python3 $ahpula_path $arguments"
    echo -n "Testing \"$cmd\"....."
    actual=$($cmd)

    if [[ $actual == $nominal ]]; then
        echo "OK"
    else
        echo "FAILED"
        echo "       Expected: $nominal"
        echo "       Actual  : $actual"
        exit_code=1
    fi
}

script_path=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ahpula_path="$script_path/ahpula.py"

test_case "$ahpula_path" "0790-07-20" "9.17.19.13.16"
test_case "$ahpula_path" "0790-07-20" "9.17.19.13.16"
test_case "$ahpula_path" "2022-12-30" "13.0.10.2.18"
test_case "$ahpula_path" "-cr 2022-12-30" "13.0.10.2.18 9 Etz'nab' 11 K'ank'in"
test_case "$ahpula_path" "-cr 2023-01-08" "13.0.10.3.7 5 Manik' End of K'ank'in"
test_case "$ahpula_path" "-cr 2023-04-03" "13.0.10.7.12 12 Eb' End of Wayeb"
test_case "$ahpula_path" "--calendar-round 2022-12-30" "13.0.10.2.18 9 Etz'nab' 11 K'ank'in"
test_case "$ahpula_path" "--no-long-count -cr 2022-12-30" "9 Etz'nab' 11 K'ank'in"
test_case "$ahpula_path" "--tzolkin 2022-12-30" "13.0.10.2.18 9 Etz'nab'"
test_case "$ahpula_path" "--no-long-count --tzolkin 2022-12-30" "9 Etz'nab'"
test_case "$ahpula_path" "--haab 2022-12-30" "13.0.10.2.18 11 K'ank'in"
test_case "$ahpula_path" "--no-long-count --haab 2022-12-30" "11 K'ank'in"

if [[ $exit_code -eq 0 ]]; then
    echo "All tests passed!"
fi

exit $exit_code