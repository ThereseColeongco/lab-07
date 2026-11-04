#!/usr/bin/env bash
for test_dir in Testcase*/; do  # for every directory that starts with "Testcase"

    # get testcase folder number
    tc_num="${test_dir#Testcase}"  # strip "Testcase" prefix from test dir name
    tc_num="${tc_num%/}"  # strip / from test dir name
    
    diff_dir="Testcase${tc_num}Diff"  # create Testcase Diff folder name

    # remove old diff folder if it exists
    if [ -d "$diff_dir" ]; then
        rm -rf "$diff_dir"
    fi

    # look for file1 whose path is the directory it's in followed by /Version#.1.txt where # is some number
    for file1 in "${test_dir}"Version*.1.txt; do

        file2="${file1%.1.txt}.2.txt"  # file2's path will be exactly like file1's except it ends with .2.txt instead of .1.txt

        filename=$(basename "$file1")  # gets just name of file1 without the rest of the path
        version_num="${filename#Version}"  # strip "Version" from filename
        version_num="${version_num%%.*}"  # strip .#.txt so we just have the version number

        diff_file="${diff_dir}/Version${version_num}Diff.txt"  # create path for diff file

        diff_output=$(diff -u "$file1" "$file2")
        exit_code=$?  # save exit code from diff; it's 1 if files are different; 0 if files are same

        if [ $exit_code -eq 1 ]; then
            mkdir -p "$diff_dir"  # with -p, if the directory already exists, it moves on without crashing or printing an error
            echo "$diff_output" > "$diff_file"
        fi
    done
done