PiFace Clock
============
PiFace Clock is a Real Time Clock (RTC) for the Raspberry Pi.

Install
=======
Attach PiFace Clock. Then download the install script and copy it to your
SDCard. Make the script executable and then run it with:

    $ chmod +x install-piface-real-time-clock.sh
    $ sudo ./install-piface-real-time-clock.sh

Reboot and then set the correct date with `sudo date -s`, for example:

    $ sudo date -s "14 JAN 2014 10:10:30"

Replace `14 JAN 2014 10:10:30` with today's date and time.
