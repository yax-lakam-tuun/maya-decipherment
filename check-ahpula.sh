#!/bin/bash

exit_code=0

test_case() {
    arguments=$1
    nominal=$2

    cmd="python3 ahpula.py $arguments"
    echo -n "Testing \"$cmd\"...."
    actual=$($cmd)

    if [[ $actual == $nominal ]]; then
        echo " OK!"
    else
        echo " FAILED!"
        echo "       Expected: $nominal"
        echo "       Actual  : $actual"
        exit_code=1
    fi
}

test_case "0790-07-20" "9.17.19.13.16"
test_case "0790-07-20" "9.17.19.13.16"
test_case "2022-12-30" "13.0.10.2.18"
test_case "-cr 2022-12-30" "13.0.10.2.18 9 Etz'nab' 11 K'ank'in"
test_case "-cr 2023-01-08" "13.0.10.2.18 9 Etz'nab' End of K'ank'in"
test_case "--calendar-round 2022-12-30" "13.0.10.2.18 9 Etz'nab' 11 K'ank'in"
test_case "--no-long-count -cr 2022-12-30" "9 Etz'nab' 11 K'ank'in"
test_case "--tzolkin 2022-12-30" "13.0.10.2.18 9 Etz'nab'"
test_case "--no-long-count --tzolkin 2022-12-30" "9 Etz'nab'"
test_case "--haab 2022-12-30" "13.0.10.2.18 11 K'ank'in"
test_case "--no-long-count --haab 2022-12-30" "11 K'ank'in"

if [ ! $exit_code ]; then
    echo "All tests passed!"
fi

exit $exit_code