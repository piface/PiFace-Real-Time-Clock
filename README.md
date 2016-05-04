# PiFace Real Time Clock
PiFace Real Time Clock is a Real Time Clock (RTC) for the Raspberry Pi.

## Install
### Attach PiFace Clock
[Download the install script](https://raw.github.com/piface/PiFace-Real-Time-Clock/master/install-piface-real-time-clock.sh) and copy it to your
SD card. Make the script executable and then run it:

    chmod +x install-piface-real-time-clock.sh
    sudo ./install-piface-real-time-clock.sh

### Enable I2C
Run:

    raspi-config

Then navigate to `Advanced Options` > `I2C` and select `yes` to enable the ARM I2C interface.

### Set the correct date
Reboot and then set the correct date with `sudo date -s`, for example:

    sudo date -s "14 JAN 2014 10:10:30"

Replace `14 JAN 2014 10:10:30` with today's date and time.

### Set the hardware clock
Finally, save the system clock to the hardware clock with:

    hwclock --systohc
