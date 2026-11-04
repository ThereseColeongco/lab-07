#!/usr/bin/env bash
for test_dir in Testcase*/; do  # for every directory that starts with "Testcase"
    # look for file1 whose path is the directory it's in followed by /Version#.1.txt where # is some number
    for file1 in "${test_dir}"Version*.1.txt; do
        file2="${file1%.1.txt}.2.txt"  # file2's path will be exactly like file1's except it ends with .2.txt instead of .1.txt
        diff -u "$file1" "$file2" || true  # run diff on the two files with file1 coming before file2... if files aren't the same, it will result in exit code 1 and terminate the loop, so do || true to make sure it goes through each file pair in the directory
    done
done