#!/bin/bash

NEW_HOSTNAME="kvm-host"

change_hostname(){
	echo "[INFO] Changing system hostname to ${NEW_HOSTNAME}..."
	sudo hostnamectl set-hostname "${NEW_HOSTNAME}"

	if [ $? -eq 0 ]; then
		echo "[SUCCESS] Hostname updated successfully"
		hostnamectl status | grep "Static hostname"
	else
		echo "[ERROR] Failed to change hostname." >&2
	fi
}
change_hostname
