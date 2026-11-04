#!/usr/bin/env bash
overall_status=0
for test_dir in Testcase*/; do  # for every directory that starts with "Testcase"

    # get testcase folder number
    tc_num="${test_dir#Testcase}"  # strip "Testcase" prefix from test dir name
    tc_num="${tc_num%/}"  # strip / from test dir name
    
    diff_dir="Testcase${tc_num}Diff"  # create Testcase Diff folder name

    tc_failed=false
    has_diff=false

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
            has_diff=true
            if [ ! -f "$diff_file" ]; then
                tc_failed=true
            else
                live_diff=$(diff -u "$file1" "$file2" | tail -n +3)
                stored_diff=$(tail -n +3 "$diff_file")

                if [ "$live_diff" != "$stored_diff" ]; then
                        echo "Error: Contents of $diff_file do not match expected diff output" >&2
                        tc_failed=true
                fi
            fi
            # check if mkdir and file outputs exist and if files in dir contain the correct content... if any of this fails, echo "Testcase${tc_num}: FAIL" and overall_status=1, else echo "Testcase${tc_num}: PASS"
        elif [ $exit_code -eq 0 ]; then
            if [ -f "$diff_file" ]; then
                    echo "Error: Unexpected diff file exists for identical pair: $diff_file" >&2
                    tc_failed=true
            fi
        fi
    done

    if [ "$has_diff" = true ]; then  # if $has_diff is true, meaning there is a difference between files
        if [ ! -d "$diff_dir" ]; then  # if there is no diff directory
            echo "Error: Missing required diff directory $diff_dir" >&2
            tc_failed=true
        fi
    else
        if [ -d "$diff_dir" ]; then
            echo "Error: Diff directory $diff_dir should not exist when all files match" >&2
            tc_failed=true
        fi
    fi

    if [ "$tc_failed" = true ]; then
        echo "Testcase${tc_num}: FAIL"
        overall_status=1
    else
        echo "Testcase${tc_num}: PASS"
    fi

done

exit $overall_status