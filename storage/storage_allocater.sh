#!/bin/bash

echo "Run the storage capacity script first to get sector and disk information to add the sector values"

start_sector="291682304"
DISK_LABEL="/dev/sda"

calculate_end_sector(){
	local start="$1"
	local size_gb="$2"

	#1 GB = 1,073,741,824 bytes / 514 bytes per sector = 2,097,152 sectors per GB
	local sectors_per_gb=2097152

	#Compute total sectors needed for the target size
	local total_sectors=$(( size_gb * sectors_per_gb ))

	echo $(( start + total_sectors ))

}

end_sector=$(calculate_end_sector "$start_sector" 100)

partition_creator(){
	sudo parted -s "${DISK_LABEL}" mkpart var_addition xfs "${start_sector}s" "${end_sector}s" 
}

kernel_reload(){
	sudo partprobe "${DISK_LABEL}"
}

calculate_end_sector
partition_creator
kernel_reload



