# AirGap.it

The Most Secure And Practical Way To Do Crypto Transactions. With AirGap you can now be your own bank.

## Installing AirGap on a USB stick or CDROM

AirGap on CDROM: use your favorite program to burn the ISO to CDROM.
Nothing special. CDROMs are naturally read-only and tamper resistant.

AirGap on USB: If you don't burn AirGap to a CDROM, writing AirGap to a
USB stick with a hardware read-write toggle (e.g., Kanguru FlashBlu) is
the next best thing.

On USB sticks without write protection, you can remove AirGap USB after
booting as an additional security measure. AirGap loads into RAM so
after booting you no longer need the USB.

1) Insert USB stick and detect the device path::
```
$ dmesg|grep Attached | tail --lines=1
[583494.891574] sd 19:0:0:0: [sdf] Attached SCSI removable disk
```
2) Write ISO to USB::
```
$ sudo dd if=path/to/airgap.iso of=/dev/sdf
$ lsblk | grep sdf
sdf                                8:80   1   7.4G  1 disk  
└─sdf1                             8:81   1   444M  1 part 
```

## How to build from source

AirGap is built with `TKLDev`_, the TurnKey GNU/Linux build system.

1) Deploy TKLDev (e.g., as a local VM)
2) SSH into TKLDev and clone the AirGap git repo:

```
$ ssh tkldev
$ cd products
$ git-clone https://github.com/airgap-it/airgap-distro.git 
$ cd airgap-distro
$ make
```
## Credits

This project was inspired by BitKey. The distribution as well as this readme have been created based on their work.
