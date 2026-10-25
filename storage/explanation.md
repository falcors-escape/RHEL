Basic storage tools and their use (automated via bash)

1) parted: To view unallocated space with the (print free) option 
2) lsblk: Shows attached disks 
3) awk: pattern scanning and text-processing language built into Linux. It reads text line by line, splitting each line into colums (fields) separated by spaces. 
4) 


Syntax explanation: 
discover_disks() {
    # Extract only root disks (filtering out partitions, loops, etc.)
    local disks
    disks=$(lsblk -d -n -o NAME,TYPE | awk '$2 == "disk" {print $1}')
    
    # Count how many disks were found
    local disk_count
    disk_count=$(echo "$disks" | wc -w)
    
    echo "Total disks discovered: $disk_count"
    echo "Disk name(s):"
    
    for disk in $disks; do
        echo "  - /dev/$disk"
    done
}

# Call the function to test it
discover_disks

EXPLANATION:

discover_disks(){
	local disks
	local disk_count
Function declaration (discover_disks(){...}
local: shell builtin that restricts the variable;s scope to this function only. 

disks=$(lsblk -d -n -o NAME,TYPE | awk '$2 == "disk" {print $1}') 
$(...) Command Substitution, tells Bash to run the command inside the parentheses, capture whatever text it prints out to the screen, and store that output inside the variable (disks)
lsblk: standard Linux utility that lists information about all available block devices (hard drives, parittions, USBs, loop devices)
	-d: (deps/disks flag): tells lsblk to list only the parent devices (the physical disks themselves, like sda, or vda) omitting all child partitions like (sda1, sda2)
	-n: (no headings flag): Suppresses the header row (NAME, etc) at the top of the output so you only get raw data lines. 
	-o NAME, TYPE (output columns flag): Customizes the colums to dispaly. Instead of showing mount points, sizes, and owners, it outputs only the device name and its block type (e.g., sda disk, sda1 part)
awk '$2 == "disk" {print $1}': $2 == "disk" Tells awk to look at the second column ($2) of each line (which lsblk popul;ated with the device type, like disk or part) and check if it exactly equals the word "disk"
{ptins $1}: if the conditino above matches (meaning its a whole disk and not a partition), awk prints only the first column ($1), which is the disk name (e.g., sda or vda)

disk_count=$(echo "$disks" | wc -w)
echo "$disks": takes the list of disk names stored in the variable (e.g., vda/nvdb). The quotes ("$disk") are important because they preserve the newline character. 
wc -w: (word count, words flag): counts how many "words" (or separate lines/items separated by whitespace) are piped into it, giving an accurate count of discovered drives. 

for disk in $disks; do
        echo "  - /dev/$disk"
    done
}
for disk in $disks; do ... done: A bash loop that iterates through each item in the $disks variable one by one, assigning the current item's name to a temporary variable named disk. 
/dev/$disk: Uses variable expansion (The $ symbol) to inject the name of the current disk into a standard Linux device path string, turning a raw name like vda into /dev/vda.  
