#!/bin/bash

discover_disks(){
	#Extract only root disks (filtering out partitions, loops, etc.)
	local disks
	disks=$(lsblk -d -n -o NAME,TYPE | awk '$2 == "disk" {print $1}')

	#Count how many disks were found
	local disk_count
	disk_count=$(echo "$disks" | wc -w)

	echo "Total disks discovered: $disk_count"
	echo "Disk name(s):"

	for disk in $disks; do
		echo " - /dev/$disk"
	done
}

#Call function to test
discover_disks
