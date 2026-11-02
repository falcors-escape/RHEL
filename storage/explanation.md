Basic storage tools and their use (automated via bash)

1) parted: To view unallocated space with the (print free) option
2) lsblk: Shows attached disks and their attributes (like SIZE and TYPE)
3) awk: Pattern scanning and text-processing language built into Linux. It reads text line by line, splitting each line into columns (fields) separated by spcaes. 
4) grep: Command line utility for searching text using patterns/regular expressions. 
5) While read: A safe stream-processing loop used to read piped input line by line. 

### Script Implementation (`storage_capacity.sh`)

```bash
#!/bin/bash

discover_disks(){
    # Extract only root disks (filtering out partitions, loops, etc.)
    local disks
    disks=$(lsblk -d -n -o NAME,TYPE | awk '$2 == "disk" {print $1}')

    # Send human info to stderr so it doesn't pollute the pipe
    echo "[INFO] Scanning disks...." >&2

    for disk in $disks; do
        echo "/dev/$disk"
    done
}

get_disk_sizes(){
    # Read each line piped into this function
    while read -r disk_path; do
        lsblk -o SIZE,NAME "$disk_path"
    done
}

get_free_space(){
    while read -r disk_path; do
        echo "[INFO] Checking unallocated space on $disk_path..." >&2

        # Run parted to print free space and filter for lines containing free space
        sudo parted -s "$disk_path" print free | grep "Free Space"
    done
}

# Call function to test pipeline
discover_disks | get_free_space


###################Detailed Code Breakdown#######################

1. discover_disks() & Stream Separation (stdout vs stderr)
local disks: Restricts the variable scop strictly to this function
lsblk -d -n -o NAME, TYPE | awk '$2 == "disk" {print $1}' 
	Captures only whoe disks (omitting child partitions) and prints their device names
echo "[INFO] Scanning disks..." >&2
	>&2 redirects this human readable status message to Standard Error
echo "/dev/$disk"	
	Outputs clean device paths to Standard output (stdout) creating a pure data stream for downstream pipeline functions. 

2. get_disk_sizes() & Pipe processing
while read -r disk_path; do ... done
	Bash loop that reads incoming lines from a pipe one by one, safelty storing each line into the $disk_path variable. 
lsblk -o SIZE, NAME "$disk_path" 
	Queries the system specifically for the size and name of each individual disk passed down the pipe. 

3. get_free_space() & parted Partitioning Analysis
sudo parted -s "$disk_path" print free
	-s (script mode): runs parted non-interactively without prompting the user for confirmation. 
print free
	instructs parted to output the partition table layout along with all the unallocated gaps ("Free Space")
| grep "Free Space" 
	Filters the multi-line parted output so that only the exact rows detailing unallocated free space are displayed. 

