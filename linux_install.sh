
set -xe

timedatectl set-ntp true
read -r -p "Have you already partitioned your disk, built filesystem, and mounted to /mnt correctly? [y/N]" confirm
if [[ ! "$confirm" =~ ^(y|Y) ]]; then
  exit
fi

curl -sSL 'https://www.archlinux.org/mirrorlist/?country=CN&protocol=https&ip_version=4' | sed 's/^#Server/Server/g' > /etc/pacman.d/mirrorlist
pacman -Sy
pacman -S --noconfirm pacman-contrib

update_mirrorlist(){
  curl -sSL 'https://www.archlinux.org/mirrorlist/?country=CN&protocol=https&ip_version=4&use_mirror_status=on' | sed 's/^#Server/Server/g' | rankmirrors - > /etc/pacman.d/mirrorlist
}

while true; do
  update_mirrorlist
  cat /etc/pacman.d/mirrorlist
  read -r -p "Is this mirrorlist OK? [Y/n]" confirm
  if [[ ! "$confirm" =~ ^(n|N) ]]; then
    break
  fi
done
pacman -Syy

pacstrap /mnt base base-devel linux linux-firmware

pacman -S grub efibootmgr networkmanager network-manager-applet dialog wireless_tools wpa_supplicant os-prober mtools dosfstools ntfs-3g base-devel linux-headers reflector git sudo

genfstab /mnt >> /mnt/etc/fstab

rm -rf /mnt/archlinux-installer && mkdir /mnt/archlinux-installer
cp -r ./* /mnt/archlinux-installer/
arch-chroot /mnt /archlinux-installer/setup.sh

if [[ "$?" == "0" ]]; then
  echo "Finished successfully."
  read -r -p "Reboot now? [Y/n]" confirm
  if [[ ! "$confirm" =~ ^(n|N) ]]; then
    reboot
  fi
fi