#!/bin/bash

discover_disks(){
	#Extract only root disks (filtering out partitions, loops, etc.)
	local disks
	disks=$(lsblk -d -n -o NAME,TYPE | awk '$2 == "disk" {print $1}')

	#Send human info to stderr so it doesn't pollute the pipe
	echo "[INFO] Scanning disks...." >&2

	for disk in $disks; do
		echo "/dev/$disk"
	done
}

get_disk_sizes(){
	#Read each line piped into this function
	while read -r disk_path; do
		lsblk -o SIZE,NAME "$disk_path"
	done
}


get_free_space(){
	while read -r disk_path; do
		echo "[INFO] Checking unallocated space on $disk_path..." >&2

		#run parted to print free space and filter for lines containing free space"
		sudo parted -s "$disk_path" print free | grep "Free Space"
	done
}

#Call function to test
discover_disks | get_free_space
