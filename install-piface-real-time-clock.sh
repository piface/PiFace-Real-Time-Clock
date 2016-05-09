#!/bin/bash
#: Description: Enables the required modules for PiFace Clock.

#=======================================================================
# NAME: check_for_i2c_tools
# DESCRIPTION: Checks if i2c-tools is installed.
#=======================================================================
check_for_i2c_tools() {
    dpkg -s i2c-tools > /dev/null 2>&1
    if [[ $? -eq 1 ]]; then
        echo "The package `i2c-tools` is not installed. Install it with:"
        echo ""
        echo "    sudo apt-get install i2c-tools"
        echo ""
        exit 1
    fi
}

#=======================================================================
# NAME: set_revision_var
# DESCRIPTION: Stores the revision number of this Raspberry Pi into
#              $RPI_REVISION
#=======================================================================
set_revision_var() {
    revision=$(grep "Revision" /proc/cpuinfo | sed -e "s/Revision\t: //")
    RPI2_REVISION=$((16#a01041))
    RPI3_REVISION=$((16#a02082))
    if [ "$((16#$revision))" -ge "$RPI3_REVISION" ]; then
        RPI_REVISION="3"
    elif [ "$((16#$revision))" -ge "$RPI2_REVISION" ]; then
        RPI_REVISION="2"
    else
        RPI_REVISION="1"
    fi
}

#=======================================================================
# NAME: start_on_boot
# DESCRIPTION: Load the I2C modules and send magic number to RTC, on boot.
#=======================================================================
start_on_boot() {
    echo "Create a new pifacertc init script to load time from PiFace RTC."
    echo "Adding /etc/init.d/pifacertc ."

    if [[ $RPI_REVISION == "3" ]]; then
        i=1  # i2c-1
    elif [[ $RPI_REVISION == "2" ]]; then
        i=1  # i2c-1
    else
        i=0  # i2c-0
    fi

    cat > /etc/init.d/pifacertc  << EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides:          pifacertc
# Required-Start:    udev mountkernfs \$remote_fs raspi-config
# Required-Stop:
# Default-Start:     S
# Default-Stop:
# Short-Description: Add the PiFace RTC
# Description:       Add the PiFace RTC
### END INIT INFO

. /lib/lsb/init-functions

case "\$1" in
  start)
    log_success_msg "Probe the i2c-dev"
    modprobe i2c-dev
    # Calibrate the clock (default: 0x47). See datasheet for MCP7940N
    log_success_msg "Calibrate the clock"
    i2cset -y $i 0x6f 0x08 0x47
    log_success_msg "Probe the mcp7941x driver"
    modprobe i2c:mcp7941x
    log_success_msg "Add the mcp7941x device in the sys filesystem"
    # https://www.kernel.org/doc/Documentation/i2c/instantiating-devices
    echo mcp7941x 0x6f > /sys/class/i2c-dev/i2c-$i/device/new_device
    log_success_msg "Synchronise the system clock and hardware RTC"
    hwclock --hctosys
    ;;
  stop)
    ;;
  restart)
    ;;
  force-reload)
    ;;
  *)
    echo "Usage: \$0 start" >&2
    exit 3
    ;;
esac
EOF
    chmod +x /etc/init.d/pifacertc

    echo "Install the pifacertc init script"
    update-rc.d pifacertc  defaults
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
check_for_i2c_tools &&
set_revision_var &&
start_on_boot &&
if [[ ! -e /sys/class/i2c-dev/i2c-$i ]]; then
    echo "Enable I2C by using:"
    echo ""
    echo "    raspi-config"
    echo ""
    echo "Then navigate to 'Advanced Options' > 'I2C' and select 'yes' to "
    echo "enable the ARM I2C interface. Then *reboot* and set your clock "
    echo "with:"
else
    echo "Now *reboot* and set your clock with:"
fi
echo ""
echo '    sudo date -s "14 JAN 2014 10:10:30"'
echo "    sudo hwclock --systohc"
echo ""
