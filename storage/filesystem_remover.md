#!/bin/bash

wipe_target_partition(){
    local target_label="var_addition"
    local disk_label="/dev/sda"

    local partition_path
    partition_path=$(lsblk -no PATH,PARTLABEL "${disk_label}" | awk -v label="$target_label" '$2 == label {print $1}')

    if [ -z "$partition_path" ]; then
        echo "[ERROR] Partition with label '${target_label}' not found." >&2
        return 1
    fi

    echo "[INFO] Found target partition: ${partition_path}"
    echo "[INFO] Clearing filesystem signatures..."

    sudo wipefs -a "${partition_path}"
}

wipe_target_partition

~~~~~~~~~~~~~~~~~~~~Explanation~~~~~~~~~~~~~~~~~~~

#!/bin/bash
(shebang) Tells the OS kernel to execute this script using the Bash shell interpreter. 

wipe_target_partition(){...}
Defines a function block. Wrapping logic in functions keeps the code modular, reusable, and easily callable inside future pipeline scripts. 

local target_label="var_addition" & local disk_label="/dev/sda"
The local keyword restricts the life of these variables exclusively to the execution of wipe_targe_partition. It prevents "variable pollution" in larger scripts where multiple functions might share variable names. 

partition_path=$(lsblk -no PATH,PARTLABEL "${disk_label}" | awk -v label="target_label" '$2 == label {print $1}')

partition_path$(...) 
Command substitution: Executes the command string inside $() and assigns whatever is printed to standard output (stdout) directly into the variable partition_path

lsblk -no PATH,PARTLABEL "${disk_label}"
	-n (no headings): strips the header line (PATH PARTLABEL) from the output
	-o PATH,PATRLABEL: Specifies the exact metadata colums to display. PATH outputs the full node path (e.g., /dev/sda3), and PARTLABEL displays the GPT partition table naem assigned during partitioning
	"${disk_label}": Expands to /dev/sda so lsblk queries only the target drive

| (pipe operator)
	Redirects the output of lsblk as the direct input to awk

awk -v label="$target_label" '$2 == label {print $1}'
	-v label="$target_label" Safely injects the bash variable into awk as an awk internal variable named label
	$2 == label: Evaluates column 2 (PARTLABEL). If column 2 strictly equals "var_addition" awk processes the block
	{print $1}: Prints column 1 (PATH), which extracts /dev/sda8

if [ -z "$partition_path" ]; then
    echo "[ERROR] Partition with label '${target_label}' not found." >&2
    return 1
fi

This section is for error handling & Validation:
if [ -z "$partition_path" ] 
	tests if the string stored in partition_path is empty -z stands for zero length). if lsblk didnt find a matching label, parititon_path remains empty

>&2
	Redirects the error message output to standard error (stderr) rather than to standard output (stdout) keeping standard error logs clean

return 1
	Exits the function immediately with a failure status code (1) preventing execution of downstream commands on an invalid block path

sudo wipefs -a "${partition_path}"
Executing the wipe

wipefs -a (all) tells wipefs to erase all detected filesystem, RAID, or LVM signatures on the block target. 
"${partition_path}" Expands to /dev/sda8.  This ensures the partition is clean raw storage so pvcreate won't encounter signature conflicts. 


