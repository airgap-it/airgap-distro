# AirGap Vault Distribution

AirGap Vault Distribution can be started from a CDROM or an USB stick on a computer and being used to sign air gapped transactions. The AirGap Vault Distribution is the equivalent of the mobile version of [AirGap Vault](https://github.com/airgap-it/airgap-vault), use the mobile app [AirGap Wallet](https://github.com/airgap-it/airgap-wallet) to broadcast transactions.

## Setup AirGap Vault Distribution
### Copy AirGap Vault Distribution to a CDROM or USB stick

**CDROM:**  
use your favorite program to burn the ISO to CDROM.
Nothing special. CDROMs are naturally read-only and tamper resistant.

**USB:**  
If you don't burn AirGap to a CDROM, writing AirGap Vault to a
USB stick with a hardware read-write toggle (e.g., Kanguru FlashBlu) is
the next best thing.

On USB sticks without write protection, you can remove the AirGap Vault USB after
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

### How to build from source

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

## How to create and sign transactions

1) Import your mnemonic phrase or generate a new one
2) Add a new wallet ex. Ethereum with the standard or your desired derivation path
3) Sync the wallet address over QR with your AirGap Wallet app
4) Create a new transaction within the AirGap Wallet app
5) Scan the transaction QR code with the AirGap Vault Distribution
6) Sign the transaction within AirGap Vault Distribution
7) Scan the signed transaction QR code with AirGap Wallet
8) Confirm and broadcast the transaction with AirGap Wallet

## Credits

This project was inspired by BitKey. The distribution as well as this readme have been created based on their work.
