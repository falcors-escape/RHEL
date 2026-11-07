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
	echo "[INFO] Clearning filesystem signatures..."

	sudo wipefs -a "${partition_path}"

}
wipe_target_partition

