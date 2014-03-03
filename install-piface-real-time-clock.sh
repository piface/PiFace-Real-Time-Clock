#!/bin/bash
#: Description: Enables the required modules for PiFace Clock.

#=======================================================================
# NAME: set_revision_var
# DESCRIPTION: Stores the revision number of this Raspberry Pi into
#              $RPI_REVISION
#=======================================================================
set_revision_var() {
    rev_str=$(grep "Revision" /proc/cpuinfo)
    # get the last character
    len_rev_str=${#rev_str}
    chr_index=$(($len_rev_str-1))
    chr=${rev_str:$chr_index:$len_rev_str}
    if [[ $chr == "2" || $chr == "3" ]]; then
        RPI_REVISION="1"
    else
        RPI_REVISION="2"
    fi
}

#=======================================================================
# NAME: enable_module
# DESCRIPTION: Enabled the I2C module.
#=======================================================================
enable_module() {
    echo "Enabling I2C module."
    module="i2c-bcm2708"
    modules_file="/etc/modules"
    # if $module not in $modules_file: append $module to $modules_file.
    if ! grep -q $module $modules_file; then
        echo $module >> $modules_file
    fi
}

#=======================================================================
# NAME: start_on_boot
# DESCRIPTION: Load the I2C modules and send magic number to RTC, on boot.
#=======================================================================
start_on_boot() {
    echo "Changing /etc/rc.local to load time from PiFace Clock."

    # remove exit 0
    sed -i "s/exit 0//" /etc/rc.local

    if [[ $RPI_REVISION == "1" ]]; then
        i=0  # i2c-0
    else
        i=1  # i2c-1
    fi

    cat >> /etc/rc.local << EOF
modprobe i2c-dev
modprobe i2c:mcp7941x
echo mcp7941x 0x6f > /sys/class/i2c-dev/i2c-$i/device/new_device
hwclock -s
EOF
}

#=======================================================================
# MAIN
#=======================================================================
# check if the script is being run as root
if [[ $EUID -ne 0 ]]
then
    printf 'This script must be run as root.\nExiting..\n'
    exit 1
fi
RPI_REVISION=""
set_revision_var &&
enable_module &&
start_on_boot &&
printf 'Please *reboot* and then set your clock with:

    sudo date -s "14 JAN 2014 10:10:30"

'
