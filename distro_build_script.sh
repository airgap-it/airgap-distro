sudo su

add-apt-repository universe
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools

rm -r $HOME/LIVE_BOOT
mkdir  $HOME/LIVE_BOOT

debootstrap \
    --arch=i386 \
    --variant=minbase \
    stretch \
    $HOME/LIVE_BOOT/chroot \
    http://ftp.ch.debian.org/debian/

wget https://github.com/airgap-it/airgap-vault/releases/download/v1.3.1/airgap-vault_1.3.1_i386.deb
mv airgap-vault_1.3.1_i386.deb $HOME/LIVE_BOOT/chroot/


cat << EOF >$HOME/LIVE_BOOT/chroot/chroot.sh
echo "airgapdistro" > /etc/hostname;
echo "airgapdistro 127.0.0.1" > /etc/hosts;

DEBIAN_FRONTEND=noninteractive apt-get update;
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    linux-image-686 \
    live-boot \
    systemd-sysv\
    xserver-xorg-core \
    xserver-xorg \
    xinit \
    libasound2 \
    gconf2 \
    gconf-service \
    libnotify4 \
    libappindicator1 \
    libxtst6 \
    libnss3 \
    libxss1 \
    libgtk-3-0 \
    libv4l-0;

dpkg -i /airgap-vault_1.3.1_i386.deb;
rm /airgap-vault_1.3.1_i386.deb;

DEBIAN_FRONTEND=noninteractive apt --fix-broken -y install;
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends;
DEBIAN_FRONTEND=noninteractive apt-get purge aptitude
DEBIAN_FRONTEND=noninteractive apt-get -y clean autoclean;

echo "exec airgap-vault" > /root/.xinitrc;
chmod +x /root/.xinitrc;

cat << EOFCHROOT > /etc/systemd/system/x11.service
[Service]
ExecStart=/bin/su root -l -c xinit -- VT08

[Install]
WantedBy=multi-user.target
EOFCHROOT

systemctl enable x11


cp rm -rf /lib/modules/**/kernel/net
rm -rf /var/lib/{apt,dpkg,cache,log}/
rm -rf /usr/share/man
rm -rf /usr/share/doc
rm -rf /usr/share/icons
rm -rf /usr/share/locale

EOF

chmod +x $HOME/LIVE_BOOT/chroot/chroot.sh
chroot $HOME/LIVE_BOOT/chroot /chroot.sh

rm -r $HOME/LIVE_BOOT/{scratch,image/live}
mkdir -p $HOME/LIVE_BOOT/{scratch,image/live}

mksquashfs \
    $HOME/LIVE_BOOT/chroot \
    $HOME/LIVE_BOOT/image/live/filesystem.squashfs \
    -e boot;

cp $HOME/LIVE_BOOT/chroot/boot/vmlinuz-* \
    $HOME/LIVE_BOOT/image/vmlinuz && \
cp $HOME/LIVE_BOOT/chroot/boot/initrd.img-* \
    $HOME/LIVE_BOOT/image/initrd


cat << EOF >$HOME/LIVE_BOOT/scratch/grub.cfg

search --set=root --file /DEBIAN_CUSTOM

set default="0"
set timeout=0

menuentry "AirGap Distro" {
    linux /vmlinuz boot=live quiet nomodeset
    initrd /initrd
}
EOF

touch $HOME/LIVE_BOOT/image/DEBIAN_CUSTOM


grub-mkstandalone \
    --format=x86_64-efi \
    --output=$HOME/LIVE_BOOT/scratch/bootx64.efi \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=$HOME/LIVE_BOOT/scratch/grub.cfg";

(cd $HOME/LIVE_BOOT/scratch && \
    dd if=/dev/zero of=efiboot.img bs=1M count=10 && \
    mkfs.vfat efiboot.img && \
    mmd -i efiboot.img efi efi/boot && \
    mcopy -i efiboot.img ./bootx64.efi ::efi/boot/
)

grub-mkstandalone \
    --format=i386-pc \
    --output=$HOME/LIVE_BOOT/scratch/core.img \
    --install-modules="linux normal iso9660 biosdisk memdisk search tar ls" \
    --modules="linux normal iso9660 biosdisk search" \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=$HOME/LIVE_BOOT/scratch/grub.cfg"

cat \
    /usr/lib/grub/i386-pc/cdboot.img \
    $HOME/LIVE_BOOT/scratch/core.img \
> $HOME/LIVE_BOOT/scratch/bios.img

sleep 10

xorriso \
    -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -volid "DEBIAN_CUSTOM" \
    -eltorito-boot \
        boot/grub/bios.img \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        --eltorito-catalog boot/grub/boot.cat \
    --grub2-boot-info \
    --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
    -eltorito-alt-boot \
        -e EFI/efiboot.img \
        -no-emul-boot \
    -append_partition 2 0xef ${HOME}/LIVE_BOOT/scratch/efiboot.img \
    -output "/tmp/airgap-vault-distro.iso" \
    -graft-points \
        "${HOME}/LIVE_BOOT/image" \
        /boot/grub/bios.img=$HOME/LIVE_BOOT/scratch/bios.img \
        /EFI/efiboot.img=$HOME/LIVE_BOOT/scratch/efiboot.img
