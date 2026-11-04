Explanation document of the storage_allocator script and its functions

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

Explanation: 

1) Global Configuration Variables
start_sector: defines the absolute starting sector boundary on the disk where unallocated space beings (sourced from prior discovery scripts)
DISK_LABEL: specifies the target block device for modification

2) calculate_end_sector() Function
Computes the exact ending sector address based on a desired size in gigabytes
Conversion math: Multiplies the target size (100 GB) by 2,097,152 sectors per GB (derived from 1,072,741,824 bytes per GiB divided by 512 bytes per hardware sector. 
Addition & output: Adds the total required sectors to the start_sector and uses echo to return the calcualted integer value so it can be captured by the calling script scop (end_sector=$(...)

3) partition_creator() function
sudo parted -s: invokes parted in script mode (supressing all interactive user prompts)
"${DISK_LABEL}" Targets /dev/sda
mkpart var_addition xfs: Creates a partition labeled var_addition with an XFS file system type identifier
"${start_sector}s" "${end_sector}s": sets the exact start and end boundaries using sector units (s)

4) kernel_reload() function
sudo partprobe "${DISK_LABEL}": Forces the Linux kernel to re-read the partition table of /dev/sda without requiring a system reboot, ensuring the OS immediately recognizes the new partition node. 



